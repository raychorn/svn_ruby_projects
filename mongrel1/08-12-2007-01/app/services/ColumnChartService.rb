require 'weborb/context'
require 'weborb/log'
require 'rbconfig'
require 'set'

class ColumnChartService
	def initialize
		super
		@dbh = ActiveRecord::Base.connection
		@session = RequestContext.get_session
	end

	def getColumnsForWidget(args)
		if args.aggregate_function.nil? || args.computer_group_distribution.nil? || args.computer_groups.nil?
			return {:success => false, :message => "You must choose a distribution and at least one computer group"}
		end
		has_sub_distribution = false
		
		sql_parts = {
		  :joins => [], 
		  :distribution_select => '', 
		  :inner_select => ['computer_groups.id', 'computer_groups.name'], 
		  :outer_select => ['id', 'name'],
		  :inner_group_by => ['computer_groups.id', 'computer_groups.name', 'computers.id'], 
		  :outer_group_by => ['id', 'name'],
		  :order_by => [], 
		  :where => [], 
		  :having => []
		}

    # build join
    if (args.computer_group_distribution.source_table == 'properties') then
      sql_parts[:joins] << SQLStatements::SQLFromClauseFor_computer_properties.gsub(/::table_alias::/, 'computer_properties').gsub(/::property_id::/, args.computer_group_distribution.id.to_s)
      sql_parts[:distribution_select] = 'computer_properties.value'
    else
      real_computer_group_distribution = ComputerGroupDistribution.find(args.computer_group_distribution.id, :include => :ReportSubject)
      report_subject = real_computer_group_distribution.ReportSubject
      sql_parts[:joins] << SQLStatements.const_get("SQLFromClauseFor_#{report_subject.table_name}")
      sql_parts[:distribution_select] = real_computer_group_distribution.select_clause
    end

		# parse data filters. take note of special behavior here for multiple filters for the same property. (they're ORed!)
		sql_where_by_prop_id = {}
		sql_having_by_prop_id = {}
		args.data_filters.each do |data_filter|
			sql_where_by_prop_id[data_filter.property.id] = [] unless sql_where_by_prop_id[data_filter.property.id]
			sql_having_by_prop_id[data_filter.property.id] = [] unless sql_having_by_prop_id[data_filter.property.id]
			if (data_filter.property.source_table == 'properties') then
				# computer property, join it and add to where clause
				sql_parts[:joins] << SQLStatements::SQLFromClauseFor_computer_properties.gsub(/::table_alias::/, 'computer_property_'+data_filter.property.id.to_s).gsub(/::property_id::/, data_filter.property.id.to_s)
				sql_where_by_prop_id[data_filter.property.id] << data_filter.generateSQL("computer_property_#{data_filter.property.id.to_s}.value")
			else
				# report subject property
				real_property = ReportSubjectProperty.find(data_filter.property.id)
				if (real_property.is_aggregate)
					sql_having_by_prop_id[data_filter.property.id] << data_filter.generateSQL(real_property.select_clause)
				else
					sql_where_by_prop_id[data_filter.property.id] << data_filter.generateSQL(real_property.select_clause)
				end
			end
		end
		# go through sql_where_by_prop_id and add to sql_parts[:where], this is where we OR multiple criteria for the same property
		sql_parts[:where] = sql_where_by_prop_id.collect do |property_id, criteria|
			if criteria.empty? then nil else
				"(" + criteria.join(" OR ") + ")"
			end
		end.compact
		# go through sql_having_by_prop_id and add to sql_parts[:having], this is where we OR multiple criteria for the same property
		sql_parts[:having] = sql_having_by_prop_id.collect do |property_id, criteria|
			if criteria.empty? then nil else
				"(" + criteria.join(" OR ") + ")"
			end
		end.compact
		
		# handle sub distribution
		if (args.sub_distribution_property) then
		  puts "ColumnChartService is being asked for a sub_distribution_property of ",args.sub_distribution_property.inspect
		  has_sub_distribution = true
		  if (args.sub_distribution_property.source_table == 'properties') then
		    # computer property, add join and grouping clause
		    sql_parts[:joins] << SQLStatements::SQLFromClauseFor_computer_properties.gsub(/::table_alias::/, 'computer_properties_sub_distribution').gsub(/::property_id::/, args.sub_distribution_property.id.to_s)
		    sql_parts[:inner_select] << 'computer_properties_sub_distribution.value as sub_distribution'
		    sql_parts[:inner_group_by] << 'computer_properties_sub_distribution.value'
		  else
		    report_subject_property = ReportSubjectProperty.find(args.sub_distribution_property.id)
		    sql_parts[:inner_select] << "#{report_subject_property.ar_class.pluralize}.name as sub_distribution"
		    sql_parts[:inner_group_by] << "#{report_subject_property.ar_class.pluralize}.name"
		  end
		  sql_parts[:outer_select] << 'sub_distribution'
		  sql_parts[:outer_group_by] << 'sub_distribution'
		end

    # build final sql
		sql = "SELECT #{sql_parts[:outer_select].join(', ')}, #{args.aggregate_function.function_name}(sub_agg) as yValue
		FROM (
		  SELECT #{sql_parts[:inner_select].join(', ')}, #{sql_parts[:distribution_select]} as sub_agg
  		FROM computer_groups LEFT OUTER JOIN (
  		  computer_groups_computers INNER JOIN computers ON (computer_groups_computers.computer_id = computers.id)
  		) ON (computer_groups.id = computer_groups_computers.computer_group_id) 
  		#{sql_parts[:joins].join(" ")}
      WHERE computer_groups.id IN (#{args.computer_groups.collect( &:id ).join(', ')})
			#{((sql_parts[:where].empty?) ? '' : " AND " + sql_parts[:where].join(" AND "))}
      GROUP BY #{sql_parts[:inner_group_by].join(', ')}
      #{((sql_parts[:having].empty?) ? '' : " HAVING " + sql_parts[:having].join(" AND "))}
    ) AS sub_query
    GROUP BY #{sql_parts[:outer_group_by].join(', ')}
		"
		#vintage = (args.respond_to?(:vintage)) ? Time.now.to_i : args.vintage
		vintage = Time.now.to_i
		sql.gsub!(/::vintage::/, vintage.to_s)
		data = @dbh.select_all(sql)

    # bah, we have to massage data for Flex for stacking series
    sub_distribution_name = ""
    unique_sub_distribution_values = Hash.new
    if (has_sub_distribution) then
      sub_distribution_name = args.sub_distribution_property.name
      new_data = Hash.new
      data.each do |row|
        if (!new_data.has_key?(row['id'])) then
          new_data[row['id']] = {
            :id => row['id'],
            :name => row['name']
          }
        end
        row['sub_distribution'] = 'Unknown' if row['sub_distribution'].nil?
        unique_sub_distribution_values[row['sub_distribution']] = true
        new_data[row['id']][row['sub_distribution']] = row['yValue']
      end
      data = new_data.values
    end
		return {
		  :success => true, 
		  :has_sub_distribution => has_sub_distribution, 
		  :data => data, 
		  :sub_distribution_name => sub_distribution_name,
		  :unique_sub_distribution_values => unique_sub_distribution_values.keys
		}
	end
end