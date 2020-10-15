module Import
  class Lexer
    def initialize(patterns)
      @patterns = patterns
    end
  
    def match(string)
      # XXX: Replace me with a proper composite state machine.
    
      match = @patterns.find { |p, v| string =~ p }
      match[1] if match
    end
  end

  class ComputerIDMapping
    def initialize(datasourceID, dssDatabase)
      @datasourceID = datasourceID
      @dssDatabase = dssDatabase
      @cache = dssDatabase.get_datasource_computer_id_map(datasourceID)
    end
  
    def datasource_to_internal(datasource_computer_id)
      return @cache[datasource_computer_id] if @cache.has_key?(datasource_computer_id)
    
      c = Computer.create!
      @cache[datasource_computer_id] = c.id
      @dssDatabase.add_datasource_computer(@datasourceID, datasource_computer_id, c.id)

      c.id
    end
    
    def create_many(datasource_computer_ids)
      m = {}
      computer_ids = @dssDatabase.create_many_computers(datasource_computer_ids.length)
      datasource_computer_ids.each do |ds_computer_id|
        m[ds_computer_id.to_i] = computer_ids.shift
      end
      @dssDatabase.add_datasource_computers(@datasourceID, m)
      @cache.update(m)
    end
    
    alias_method :d2i, :datasource_to_internal
  end

  class DSSDatabase
    attr_reader :connection
  
    def initialize(connection=ActiveRecord::Base.connection)
      @connection=connection
    end
  
    def execute(queries)
      queries.each do |query|
        @connection.execute(query)
      end
      nil
    end
  
    def sql_update_computer_groups(groups)
      queries = []
    
      groups.each do |group_id, member_ids|
        queries += sql_update_computer_group(group_id, member_ids)
      end
    
      queries
    end
  
    def sql_update_computer_group(group_id, member_ids, update_time=Time.new.to_s(:db))
      current_member_ids = get_current_computer_group_members(group_id)
      missing_member_ids = Set.new(member_ids) - current_member_ids
      old_member_ids = current_member_ids - member_ids
      missing_members = missing_member_ids.map \
        { |computer_id| "(#{group_id}, #{computer_id}, '#{update_time}')"}

      queries = []
    
      queries << \
       "UPDATE computer_groups_computers " \
       "SET valid_from = valid_from, valid_to = '#{update_time}' " \
       "WHERE computer_group_id = #{group_id}" \
       " AND valid_to IS NULL " \
       " AND computer_id IN (#{old_member_ids.map(&:to_s).join(',')})" unless old_member_ids.empty?
    
      queries << \
       "INSERT INTO computer_groups_computers" \
       "(computer_group_id, computer_id, valid_from) " \
       "VALUES#{missing_members.join(',')}" unless missing_members.empty?
     
      queries
    end

    def get_current_computer_group_members(group_id)
      Set.new(@connection.select_values("SELECT computer_id FROM computer_groups_computers WHERE computer_group_id = #{group_id} AND valid_to IS NULL").map(&:to_i))
    end
  
    def current_apps_for_computer(computer_id)
      Set.new(@connection.select_values("SELECT app_id FROM computer_apps WHERE computer_id = #{computer_id} AND valid_to IS NULL").map(&:to_i))
    end
  
    def sql_update_app_records(computer_apps)
      sql = []
    
      computer_apps.each do |computer_id, app_ids|
        current_app_ids = current_apps_for_computer(computer_id)
        added_apps = app_ids - current_app_ids
        removed_apps = current_app_ids - app_ids

        unless removed_apps.empty?
          sql += sql_invalidate_records('computer_apps', removed_apps.to_a,
                                        'app_id',
                                        "computer_id = #{computer_id} AND valid_to IS NULL")
        end
      
        unless added_apps.empty?
          sql += sql_insert_new_app_records(computer_id, added_apps)
        end
      end
    
      sql
    end
    
    def sql_insert_fresh_app_records(computer_apps)
      sql = []
      computer_apps.each do |computer_id, app_ids|
        sql += sql_insert_new_app_records(computer_id, app_ids)
      end
      sql
    end
  
    def sql_insert_new_app_records(computer_id, added_apps, update_time=Time.now.to_s(:db))
      ["INSERT INTO computer_apps(computer_id,app_id,valid_from) VALUES" + \
         added_apps.map { |app_id| "(#{computer_id}, #{app_id}, '#{update_time}')" }.join(',')]
    end
  
    def current_os_for_computers(computer_ids=nil)
      return {} if computer_ids == []
    
      query = "SELECT computer_id, operating_system_id FROM computers_operating_systems " \
              "WHERE valid_to IS NULL"
      if computer_ids
        query += " AND computer_id IN (#{computer_ids.map(&:to_s).join(',')})"
      end
    
      rows = @connection.select_values(query)
      returning computers = {} do
        rows.each do |row|
          computers[row['computer_id'].to_i] = [row['id'].to_i, row['os_id'].to_i]
        end
      end
    end
  
    def sql_update_os_records(computer_os_records, update_time=Time.new.to_s(:db))
      sql = []
      current_os_ids = current_os_for_computers(computer_os_records.keys)
    
      old_os_computer_ids = []
      new_os_records = []
    
      computer_os_records.each do |computer_id, os_id|
        if (r = current_os_ids[computer_id]).nil? || r[1] != os_id
          if r
            old_computer_os_ids << r[0]
          end
          new_os_records << "(#{computer_id},#{os_id},'#{update_time}')"
        end
      end

      unless old_os_computer_ids.empty?
        sql += sql_invalidate_records('computers_operating_systems',
                                      old_computer_os_ids)
      end

      unless new_os_records.empty?
        sql << "INSERT INTO computers_operating_systems" \
               "(computer_id, operating_system_id, valid_from) " \
               "VALUES#{new_os_records.join(',')}"
      end
    
      sql
    end
  
    def current_vulns_for_computer(computer_id)
      Set.new(@connection.select_values("SELECT vuln_id FROM computer_vulns WHERE computer_id = #{computer_id} AND valid_to IS NULL").map(&:to_i))
    end
  
    def sql_update_vuln_records(computer_id, vulns)
      current_vuln_ids = current_vulns_for_computer(computer_id)

      sql_insert_new_vuln_records(computer_id, vulns, current_vuln_ids) + \
        sql_invalidate_old_vuln_records(computer_id, vulns, current_vuln_ids)
    end
  
    def sql_insert_new_vuln_records(computer_id, vulns, current_vuln_ids)
      rows = []
      vulns.each do |vuln_id, (present, delta_time)|
        if present && !current_vuln_ids.member?(vuln_id)
          rows << "(#{computer_id}, #{vuln_id}, '#{delta_time.to_s(:db)}')"
        end
      end

      if rows.empty?
        []
      else
        ["INSERT INTO computer_vulns(computer_id, vuln_id, valid_from) VALUES#{rows.join(',')}"]
      end
    end
      
    def sql_invalidate_old_vuln_records(computer_id, vulns, current_vuln_ids)
      queries = []
      vulns.each do |vuln_id, (present, delta_time)|
        if !present && current_vuln_ids.member?(vuln_id)
          # We can do this quicker by computer_vulns.id if we take the time
          # to store them.
          queries << "UPDATE computer_vulns " \
                     "SET valid_from = valid_from, valid_to = '#{delta_time.to_s(:db)}' " \
                     "WHERE vuln_id = #{vuln_id}" \
                     " AND valid_to IS NULL" \
                     " AND computer_id = #{computer_id}"
        end
      end
    
      queries
    end
  
    def sql_update_property_records(propertyID, records, update_time=Time.now.to_s(:db))
      sql = []
      # XXX: Inefficient: too many queries
      records.each do |computerID, text|
        if (v = Computer.find(computerID, :include => :computer_properties).property_value(propertyID)) != text
          sql << "UPDATE computer_properties SET valid_from = valid_from, valid_to = '#{update_time}' " \
                 "WHERE computer_id = #{computerID} AND property_id = #{propertyID}" \
                 " AND valid_to IS NULL" unless v.nil?
          sql << "INSERT INTO computer_properties (computer_id,property_id,value,valid_from) " \
                 "VALUES(#{computerID},#{propertyID},#{@connection.quote(text)},'#{update_time}')"
        end
      end

      sql
    end
  
    def sql_invalidate_records(table_name, record_ids, id_column_name='id',
                               conditions=nil, valid_to=Time.now)
      ["UPDATE #{table_name} " \
       "SET valid_from = valid_from, valid_to = '#{valid_to.to_s(:db)}' " \
       "WHERE #{id_column_name} IN (#{record_ids.map(&:to_s).join(',')})" \
       "#{conditions ? ' AND ' + conditions : ''}"]
    end
  
    def get_datasource_computer_id_map(datasourceID)
      rows = @connection.select_all("SELECT computer_id, datasource_computer_id FROM computers_datasources WHERE datasource_id = #{datasourceID}")
      returning map = {} do
        rows.each do |row|
          map[row['datasource_computer_id'].to_i] = row['computer_id'].to_i
        end
      end
    end
  
    def add_datasource_computers(datasourceID, ids)
      ids.each_page(5000) do |id_page|
        @connection.execute("INSERT INTO computers_datasources(computer_id, datasource_id, datasource_computer_id) VALUES#{id_page.map { |dscid, cid| "(#{cid}, #{datasourceID}, #{dscid})" }.join(',')}")
      end
    end
  
    def add_datasource_computer(datasourceID, datasourceComputerID, computerID)
      add_datasource_computers(datasourceID, [[datasourceComputerID, computerID]])
    end

    def create_many_computers(count)
      @connection.transaction do
        max_computer_id = @connection.select_value("SELECT max(id) FROM computers").to_i
        ids = (max_computer_id + 1 .. max_computer_id + 1 + count).to_a
        
        ids.each_page(5000) do |id_page|
          @connection.execute("INSERT INTO computers(id) VALUES#{id_page.map {|i| "(#{i})"}.join(',')}")
        end
        
        ids
      end
    end
    
    def has_datasource_computer_group(groupID, groupName, datasourceID=1)
      rows = @connection.select_all("SELECT id FROM datasource_computer_groups WHERE datasource_id = #{datasourceID} AND datasource_computer_group_id = #{groupID}")
      puts("has_datasource_computer_group(#{groupID}, #{groupName}, #{datasourceID}) => #{rows.join(',')}")
      not rows.empty?
    end

    def sql_insert_datasource_computer_group(groupID, groupName, datasourceID=1)
      "INSERT INTO datasource_computer_groups (datasource_computer_group_id, datasource_id, name) VALUES(#{groupID}, #{datasourceID}, #{@connection.quote(groupName)})"
    end
  end
end
