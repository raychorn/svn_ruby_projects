require 'import'
require 'relevance'
require 'bidirectional_mapping'
require 'odbc'

module Import
  module BES
    class SiteNameMap < BidirectionalMapping
      def get_site_name(siteID)
        forward_lookup(siteID)
      end
  
      def get_site_id(siteName)
        backward_lookup(siteID)
      end
    end

    class SiteURLMap < BidirectionalMapping
      def get_site_url(siteID)
        forward_lookup(siteID)
      end
  
      def get_site_id(siteURL)
        backward_lookup(siteID)
      end
    end
    
    class Database
      attr_reader :most_recent_seq
  
      def initialize(connection_params, lastSeq=0)
        @connection = ODBC::connect(connection_params['dsn'],
                                    connection_params['username'],
                                    connection_params['password'])
        @lastSeq = lastSeq
        @most_recent_seq = current_sequence_number
      end

      def run(query)
        @connection.run(query)
      end
      
      def select_all(query)
        run(query).fetch_all
      end
      
      def select_value(query)
        run(query).fetch_all[0][0]
      end
      
      def select_values(query)
        run(query).fetch_all.map { |r| r[0] }
      end

      def reset_last_sequence
        @lastSeq = 0
      end
      
      def sequence_constraint(tablename=nil)
        if tablename
          seq_expr = "#{tablename}.sequence"
        else
          seq_expr = "sequence"
        end
        "#{seq_expr} > #{@lastSeq} AND #{seq_expr} <= #{@most_recent_seq}"
      end
  
      def get_windows_apps_cursor()
        get_universal_analysis_cursor('Installed Applications')
      end
  
      def get_ip_addresses_cursor()
        get_universal_analysis_cursor('IP Address')
      end
  
      def get_computer_names_cursor()
        get_universal_analysis_cursor('Computer Name')
      end
      
      def get_dns_names_cursor()
        get_universal_analysis_cursor('DNS Name')
      end
      
      def get_os_names_cursor()
        get_universal_analysis_cursor('OS')
      end

      def get_universal_analysis_cursor(analysis_name)
        get_analysis_results_cursor(action_site_id, get_analysis_id(analysis_name), 1)
      end

      def get_analysis_results_cursor(siteid, analysisid, propertyid)
        run("SELECT computerid, resultstext " \
            "FROM questionresults " \
            "WHERE siteid = #{siteid}" \
            " AND analysisid = #{analysisid}" \
            " AND propertyid = #{propertyid}" \
            " AND IsFailure = 0" \
            " AND #{sequence_constraint}")
      end
      
      def get_fixlet_results_cursor()
        query = "SELECT computerid, siteid, id, lastbecamenonrelevant," \
                " lastbecamerelevant, isrelevant " \
                "FROM fixletresults " \
                "WHERE #{sequence_constraint}"
        run(query)
      end
  
      def site_url_mapping
        @site_url_map ||=
        returning name_map = SiteURLMap.new do
          select_all("SELECT SiteID, SiteURL FROM sitenamemap").each do |siteid, siteurl|
            name_map.add(siteid.to_i, siteurl)
          end
        end
      end

      def site_name_mapping
        @site_name_map ||=
        returning name_map = SiteNameMap.new do
          select_all("SELECT SiteID, Sitename FROM sitenamemap").each do |siteid, sitename|
            name_map.add(siteid.to_i, sitename)
          end
        end
      end
      
      def get_analysis_id(name)
        select_value("SELECT id FROM local_object_defs where contenttype = 5 and parentid = 0 and dbo.fn_ExtractField('IsReserved', 0, fields) = 'Yes' and name = '#{name.gsub("'", "''")}'").to_i
      end
      
      def get_computer_ids()
        select_values("SELECT computerid FROM computers WHERE isdeleted = 0")
      end

      private
      def action_site_id
        site_name_mapping['ActionSite']
      end

      def audit_site_id
        audit_site_url = 'http://sync.bigfix.com/cgi-bin/bfgather/besinventory'
        site_url_mapping[audit_site_url]
      end
  
      def current_sequence_number
        '0x' + select_value("SELECT @@DBTS")
      end
    end

    class CatalogMapping
      def initialize(dss_db)
        @connection = dss_db.connection
      end
  
      def app_mapping
        @app_map ||= Lexer.new(@connection.select_all("SELECT app_id, pattern FROM apps_bes").map { |r| [Regexp.new(r['pattern']), r['app_id'].to_i] })
      end
  
      def os_name_mapping
        @os_map ||= Lexer.new(@connection.select_all("SELECT operating_system_id, pattern FROM operating_systems_bes").map { |r| [Regexp.new(r['pattern']), r['operating_system_id'].to_i] })
      end
  
      def vuln_mapping
        return @vuln_map if @vuln_map
        
        rows = @connection.select_all("SELECT bes_site_id, fixlet_id, vuln_id FROM vulns_bes")
        @vuln_map ||= rows.group_to_hash \
             { |row| [row['bes_site_id'].to_i,
                      row['fixlet_id'].to_i,
                      row['vuln_id'].to_i] }
        @fixlet_map ||= rows.group_to_hash \
        { |row| [row['vuln_id'].to_i,
                 [row['bes_site_id'].to_i, row['fixlet_id'].to_i]
                 ] }
      end
      
      def fixlet_mapping
        vuln_mapping unless @fixlet_map
        @fixlet_map
      end
  
      def site_mapping
        returning sitemap = SiteURLMap.new do
          @connection.select_all("SELECT id, url FROM bes_sites").each do |row|
            sitemap.add(row['id'].to_i, row['url'])
          end
        end
      end
    end

    class Transformer
      def initialize(catalog_mapping, computer_id_mapping, site_url_mapping)
        @catalog_map = catalog_mapping
        @site_map = @catalog_map.site_mapping
        @site_url_map = site_url_mapping
        @cid_map = computer_id_mapping
      end
      
      def transform_computer_ids(bes_computer_ids)
        bes_computer_ids.map { |id| @cid_map.d2i(id.to_i) }
      end
  
      def transform_fixlet_results(fixletResults)
        computerVulns = {}
        review = []
        vulnMap = @catalog_map.vuln_mapping
        fixletMap = @catalog_map.fixlet_mapping

        fixletResults.each do |besComputerID, besSiteID, fixletID, lastNonRelevant, lastRelevant, isRelevant|
          computerID = @cid_map.d2i(besComputerID.to_i)
          computer = (computerVulns[computerID] ||= {})
          local_site_id = bes_site_to_local_site_id besSiteID.to_i
          sitemap = vulnMap[local_site_id]
          vuln_ids = sitemap.nil? ? [] : (sitemap[fixletID.to_i] || [])
          isRelevant = isRelevant != '0'
          delta_time = isRelevant ? lastRelevant : lastNonRelevant
          delta_time = delta_time ? ODBC.to_time(delta_time) : Time.now

          vuln_ids.each do |vuln_id|
            # To determine whether a vulnerability is present, we look for the
            # relevance of any associated fixlet.  This means that if we
            # find a relevant fixlet, the vulnerability is known to be present,
            # but if we find a non-relevant fixlet, the vulnerability may or
            # may not be present, depending on other fixlet results we may see.
            # If only one fixlet is associated with the vulnerability, then we
            # can conclude that the vulnerability is not present if the fixlet
            # is not relevant.  If more than one fixlet is associated, we must
            # make a note to review the status of the other fixlets before
            # making a determination.
            
            if isRelevant
              computer[vuln_id] = [true, delta_time]
            elsif !computer.has_key?(vuln_id)
              fixlets = fixletMap[vuln_id]
              if fixlets.length <= 1
                computer[vuln_id] = [false, delta_time]
              else
                review << [computerID, vuln_id, fixlets]
              end
            end
          end
        end

        return computerVulns, review
      end
  
      def transform_app_results(appResults)
        computerApps = {}
        appMap = @catalog_map.app_mapping

        appResults.each do |besComputerID, resultsText|
          computerID = @cid_map.d2i(besComputerID.to_i)
          appNames = resultsText.split("\n")
      
          appIDs = Set.new
          appNames.each do |appname|
            if appID = appMap.match(appname)
              appIDs << appID
            end
          end
      
          computerApps[computerID] = appIDs unless appIDs.empty?
        end
    
        computerApps
      end
  
      def transform_os_results(osResults)
        currentComputerID = nil
        osName = ''
        osMap = @catalog_map.os_name_mapping
    
        computerOS = {}
    
        # This assumes that the rows are sorted by computerid, then propertyid
        osResults.each do |besComputerID, resultsText|
          besComputerID = besComputerID.to_i
          if besComputerID != currentComputerID && !currentComputerID.nil?
            computerID = @cid_map.d2i(currentComputerID)
            computerOS[computerID] = osMap.match(osName) || 0
            osName = ''
          end
          currentComputerID = besComputerID
      
          unless resultsText.nil?
            osName += ' ' unless osName.empty?
            osName += resultsText
          end
        end
    
        # Deal with the last computer in the list.
        unless currentComputerID.nil?
          computer_id = @cid_map.d2i(currentComputerID)
          computerOS[computer_id] = osMap.match(osName) || 0
        end
    
        computerOS
      end
  
      def transform_property_results(propertyResults)
        computerPropValues = {}
    
        propertyResults.each do |besComputerID, resultsText|
          computerPropValues[@cid_map.d2i(besComputerID.to_i)] = resultsText.chomp
        end
    
        computerPropValues
      end
  
      private
      def bes_site_to_local_site_id(bes_site_id)
        @site_map[@site_url_map[bes_site_id]]
      end
    end

    class Importer
      def initialize(besDatabase, dssDatabase, qna, datasourceID)
        @update_time = Time.new.to_s(:db)
        @bes_database = besDatabase
        @dss_database = dssDatabase
        @qna = qna
        @datasourceID = datasourceID
        @cid_mapping = ComputerIDMapping.new(datasourceID, dssDatabase)
        @transformer = Transformer.new(CatalogMapping.new(dssDatabase),
                                       @cid_mapping,
                                       besDatabase.site_url_mapping)
      end
      
      def fresh_import
        # Perform an import, assuming that we have never imported from this
        # datasource before.
        
        raise "Cannot preform a fresh import: Computers already exist from this datasource." \
          unless Datasource.find(@datasourceID).computers.count == 0
        
        # Step 1: Bulk load computer IDs
        besComputerIDs = @bes_database.get_computer_ids
        @cid_mapping.create_many(besComputerIDs)
        
        # Step 2: Load all data, assuming no existing records to update.
        import(:full => true, :fresh => true)
      end
      
      def import(options={})
        if options[:full]
          @bes_database.reset_last_sequence
        end
        import_all_property_records(options)
        import_os_records(options)
        import_app_records(options)
        import_vuln_records(options)
        import_computer_groups(options)
        nil
      end
      
      def paged_import(fetchFunction, transformFunction, insertFunction, page_size=1000)
        cursor = fetchFunction.call()
        n = 0
        nrows = cursor.nrows
        loop do
          puts "Fetching rows #{n+1}-#{n+page_size}..."
          records = cursor.fetch_many(page_size)
          break if records.nil? || records.empty?
          puts "Fetched #{records.length} records."
          n += records.length
          transform_result = transformFunction.call(records)
          insertFunction.call(transform_result)
          break if records.length < page_size
        end
        cursor.drop
        nil
      end
      
      def import_vuln_records(options={})
        if options[:fresh]
          emptySet = Set.new()
          insertFunc = lambda do |computer_id, vulns|
            @dss_database.sql_insert_new_vuln_records(computer_id, vulns, emptySet)
          end
        else
          insertFunc = @dss_database.method(:sql_update_vuln_records)
        end
           
        importFunc = lambda do |x|
          (vuln_records, post_checks) = x
          sql ||= []
          vuln_records.each do |computer_id, vulns|
            sql += insertFunc.call(computer_id, vulns)
          end
          
          @dss_database.execute(sql)
        end
        
        paged_import(@bes_database.method(:get_fixlet_results_cursor),
                     @transformer.method(:transform_fixlet_results),
                     importFunc)
      end

      def import_app_records(options = {})
        if options[:fresh]
          insertFunc = @dss_database.method(:sql_insert_fresh_app_records)
        else
          insertFunc = @dss_database.method(:sql_update_app_records)
        end
        puts 'Fetching application records...'
        paged_import(@bes_database.method(:get_windows_apps_cursor),
                     @transformer.method(:transform_app_results),
                     lambda do |records|
                       @dss_database.execute(insertFunc.call(records))
                     end)
      end
    
      def import_os_records(options = {})
        puts 'Fetching OS records...'
        paged_import(@bes_database.method(:get_os_names_cursor),
                     @transformer.method(:transform_os_results),
                     lambda do |records|
                       @dss_database.execute(@dss_database.sql_update_os_records(records))
                     end)
      end
      
      def import_property_records(fetchFunction, dssPropertyID, options={})
        paged_import(fetchFunction, @transformer.method(:transform_property_results),
                     lambda do |records|
                       @dss_database.execute(@dss_database.sql_update_property_records(dssPropertyID, records))
                      end)
      end
      
      def import_all_property_records(options={})
        import_property_records(@bes_database.method(:get_ip_addresses_cursor), 1000, options)
        import_property_records(@bes_database.method(:get_dns_names_cursor), 1001, options)
        import_property_records(@bes_database.method(:get_computer_names_cursor), 1002, options)
      end
    
      def import_computer_groups(options={})
        ComputerGroup.find(:all).each do |cg|          
          bes_computer_groups = cg.relevance.split
          puts "Getting DSS computer group #{cg.id}: BES computer groups #{bes_computer_groups.inspect}"
          bes_computer_ids = get_computer_group_members(bes_computer_groups)
          dss_computer_ids = @transformer.transform_computer_ids(bes_computer_ids)
          #puts "BES computer IDs: #{bes_computer_ids.inspect}"
          #puts "DSS computer IDs: #{dss_computer_ids.inspect}"
          @dss_database.execute(@dss_database.sql_update_computer_groups({ cg.id => dss_computer_ids }))
        end
      end
      
      def get_computer_group_members(group_ids)
        group_ids = [group_ids] unless group_ids.respond_to?(:each)
        @qna.query("ids of members of bes computer groups whose " \
                   "(#{group_ids.map { |gid| 'id of it = ' + gid }.join(' or ')})").map(&:to_i)
      end
    end
  end
end

if false
  # test
  cfg = 'qabes'
  c = ActiveRecord::Base.sqlserver_connection(ActiveRecord::Base.configurations[cfg])
  
  bes_db = BESDatabase.new(c, '0x0000000000970000')
  dss_db = DSSDatabase.new
  qna = RelevanceQNA.new('qabes', 'bigfix', 'bigfix')
  importer = Importer::BES.new(bes_db, dss_db, qna, 1)
  #p importer.getWindowsApps
  p bes_db.get_os_names
  puts importer.import_os_records
  #p importer.getFixletRelevance.length
  #puts importer.import_vuln_records
  puts importer.import_app_records
end

##
## Import remediations
##
