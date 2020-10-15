require 'weborb/context'
require 'weborb/log'
require 'rbconfig'
require 'set'
require_dependency 'ReportingServiceBase'

class ComputerList < ReportingServiceBase

	GroupTypeDistinctAll = 1
	GroupTypeDistinctComputer = 2
	GroupTypeDistinctSubject = 3

	SQLComputers_FromClause = "
		computers INNER JOIN computers_operating_systems ON (
			computers.id = computers_operating_systems.computer_id AND (
				computers_operating_systems.valid_from <= from_unixtime(::vintage::) AND (computers_operating_systems.valid_to > from_unixtime(::vintage::) OR computers_operating_systems.valid_to IS NULL)
			)
		) INNER JOIN operating_systems ON (computers_operating_systems.operating_system_id = operating_systems.id)
		INNER JOIN computer_groups_computers ON (
			computers.id = computer_groups_computers.computer_id AND (
				computer_groups_computers.valid_from <= from_unixtime(::vintage::) AND (computer_groups_computers.valid_to > from_unixtime(::vintage::) OR computer_groups_computers.valid_to IS NULL)
			)
		)
	"
	SQLVulns_FromClause = "
		INNER JOIN computer_vulns ON (
			computers.id = computer_vulns.computer_id AND (
				computer_vulns.valid_from <= from_unixtime(::vintage::) AND (computer_vulns.valid_to > from_unixtime(::vintage::) OR computer_vulns.valid_to IS NULL)
			)
		) INNER JOIN vulns ON (computer_vulns.vuln_id = vulns.id)
	"
	def initialize()
		super

		@columns_distinct_computers = {
			:computer_id => {:label => 'Computer ID', :select => 'computers.id'},
			:operating_system_name => {:label => 'Operating System', :select => 'operating_systems.name'}
		}
		@dbh.select_all('select * from properties').each do |row|
			@columns_distinct_computers[row['name'].gsub(/\s+/,'_').downcase] = {:label => row['name']}
		end

		@columns_aggregate_computers = {
			:total_computers => {:label => 'Total Computers', :select => 'count(distinct computers.id)'}
		}

		@columns_distinct_vulns = {
			:vuln_id => {:label => 'Vuln ID', :select => 'vulns.id'},
			:vuln_name => {:label => 'Vulnerability', :select => 'vulns.name'},
			:vuln_cvss_base_score => {:label => 'CVSS Score', :select => 'vulns.cvss_base_score'},
			:vuln_publish_date => {:label => 'Publish Date', :select => 'vulns.publish_date'}
		}

		@columns_aggregate_vulns = {
			:total_vulns => {:label => 'Number of Vulns', :select => 'COUNT(vulns.id)'},
			:total_vuln_score => {:label => 'Total Vuln Score', :select => 'SUM(vulns.cvss_base_score)'},
			:avg_vuln_score => {:label => 'Average Vuln Score', :select => 'AVG(vulns.cvss_base_score)'}
		}

		@table_name = "tmp_computer_list_" + RequestContext.get_session.session_id
	end

	def getList(offset, limit, args)
		vintage = (args['vintage'].nil?) ? Time.now.to_i : args['vintage']

		order_by = (args['order_by'].empty?) ? 'computer_id' : args['order_by']

		# get computers
		computer_sql = "select * from #{@table_name} order by #{order_by} limit #{limit} offset #{offset}"
		computers = @dbh.select_all(computer_sql)
		# build a hash where the key is the computer_id and the value is an array of all rows with that computer_id
		computer_hash = {}
		computers.each do |row|
			computer_hash[row['computer_id']] ||= []
			computer_hash[row['computer_id']] << row
		end

		# get properties (join against a subselect of previous query)
		property_sql = "SELECT computer_properties.computer_id, properties.name as property_name, computer_properties.value as property_value
			FROM properties INNER JOIN computer_properties ON (
				properties.id = computer_properties.property_id AND (
					computer_properties.valid_from <= from_unixtime(#{vintage}) AND (computer_properties.valid_to > from_unixtime(#{vintage}) OR computer_properties.valid_to IS NULL)
				)
			) INNER JOIN (#{computer_sql}) as computer USING (computer_id)"
		computer_properties = @dbh.select_all(property_sql)

		# itterate through properties and attach it to the proper computer records by looking through the computer_hash
		computer_properties.each do |property_row|
			computer_hash[property_row['computer_id']].each do |computer_row|
				computer_row[property_row['property_name'].gsub(/\s+/,'_').downcase] = property_row['property_value']
			end
		end
		computers
	end

	def getTotalRecords(args)
		required_args = ['computer_group_id', 'subject_id', 'grouping_type'].to_set
		raise "you didn't pass any arguments!" if args.empty?
		raise "You didn't pass the require arguments!" if !required_args.subset?(args.keys.to_set)
		vintage = (args['vintage'].nil?) ? Time.now.to_i : args['vintage']

		sql = {:from => SQLComputers_FromClause.gsub(/::vintage::/, vintage.to_s), :select => [], :group_by => []}
		case args['subject_id']
			when SubjectVuln then
				sql[:from] += ' ' + SQLVulns_FromClause.gsub(/::vintage::/, vintage.to_s)
				case args['grouping_type']
					when GroupTypeDistinctAll then
						@columns_distinct_computers.merge(@columns_distinct_vulns).each do |col_name, col_props|
							next if col_props[:select].nil?
							sql[:select] << col_props[:select] + " as " + col_name.to_s
							sql[:group_by] << col_props[:select]
						end
					when GroupTypeDistinctComputer then
						@columns_distinct_computers.each do |col_name, col_props|
							next if col_props[:select].nil?
							sql[:select] << col_props[:select] + " as " + col_name.to_s
							sql[:group_by] << col_props[:select]
						end
						@columns_aggregate_vulns.each do |col_name, col_props|
							sql[:select] << col_props[:select] + " as " + col_name.to_s
						end
					when GroupTypeDistinctSubject then
						@columns_distinct_vulns.each do |col_name, col_props|
							sql[:select] << col_props[:select] + " as " + col_name.to_s
							sql[:group_by] << col_props[:select]
						end
						@columns_aggregate_computers.each do |col_name, col_props|
							sql[:select] << col_props[:select] + " as " + col_name.to_s
						end
				end
			when SubjectPolicy then
				case args['grouping_type']
					when GroupTypeDistinctAll then
						"not implemented"
					when GroupTypeDistinctComputer then
						"not implemented"
					when GroupTypeDistinctSubject then
						"not implemented"
				end
			when SubjectDLP then
				case args['grouping_type']
					when GroupTypeDistinctAll then
						"not implemented"
					when GroupTypeDistinctComputer then
						"not implemented"
					when GroupTypeDistinctSubject then
						"not implemented"
				end
			when SubjectVirus then
				case args['grouping_type']
					when GroupTypeDistinctAll then
						"not implemented"
					when GroupTypeDistinctComputer then
						"not implemented"
					when GroupTypeDistinctSubject then
						"not implemented"
				end
		end
		@dbh.execute("drop table if exists #{@table_name}")
		whole_sql = "SELECT #{sql[:select].join(', ')} FROM #{sql[:from]} WHERE computer_groups_computers.computer_group_id = #{args['computer_group_id']} GROUP BY #{sql[:group_by].join(',')}"
		@dbh.execute("create table #{@table_name} #{whole_sql}")
		@dbh.select_value("select count(*) from #{@table_name}")
	end

	def getDefaultOptions()
		{ :subject_id => SubjectVuln, :grouping_type => GroupTypeDistinctAll, :included_columns => [:ip_address, :netbios_name, :operating_system_name, :vuln_name, :vuln_cvss_base_score] }
	end

	def getAvailableColumns(args)
		required_args = ['subject_id', 'grouping_type'].to_set
		raise "you didn't pass any arguments!" if args.empty?
		raise "ComputerList.getAvailableColumns: You didn't pass the required arguments! #{args}"  if !required_args.subset?(args.keys.to_set)

		cols = case args['subject_id']
			when SubjectVuln then
				case args['grouping_type']
					when GroupTypeDistinctAll then
						@columns_distinct_computers.merge(@columns_distinct_vulns)
					when GroupTypeDistinctComputer then
						@columns_distinct_computers.merge(@columns_aggregate_vulns)
					when GroupTypeDistinctSubject then
						@columns_distinct_vulns.merge(@columns_aggregate_computers)
				end
			when SubjectPolicy then
				case args['grouping_type']
					when GroupTypeDistinctAll then
					when GroupTypeDistinctComputer then
					when GroupTypeDistinctSubject then
				end
			when SubjectDLP then
				case args['grouping_type']
					when GroupTypeDistinctAll then
					when GroupTypeDistinctComputer then
					when GroupTypeDistinctSubject then
				end
			when SubjectVirus then
				case args['grouping_type']
					when GroupTypeDistinctAll then
					when GroupTypeDistinctComputer then
					when GroupTypeDistinctSubject then
				end
		end
		available_columns = []
		cols.each do |col_name, col_props|
			available_columns << {:name => col_name.to_s, :label => col_props[:label]}
		end
		available_columns
	end

	def getDistribution(col_name)
		@dbh.select_all("select #{col_name} as label, count(*) as total from #{@table_name} group by 1")
	end
end