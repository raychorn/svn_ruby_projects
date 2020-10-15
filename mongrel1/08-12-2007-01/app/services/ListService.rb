require 'weborb/context'
require 'weborb/log'
require 'rbconfig'
require 'set'
require 'CSV'

class ListService
	def initialize
		super
		@dbh = ActiveRecord::Base.connection
		@session = RequestContext.get_session
	end

	def checkListArgs(args)
		if args.list_subjects.nil? || args.list_columns.nil?
			return {:success => false, :message => "You must choose at least one subject and some columns"}
		end
		return {:success => true}
	end

	#
	# this method is called once per list refresh
	# it creates the temporary table with all records which futher list methods will access
	#
	def generateTable(args)
		return nil unless checkListArgs(args)[:success]

		# check to see if we need to even regenerate the table..
		createTable = true
		user_temp_table = UserTempTable.find_all_by_id(args.user_temp_table_id).first
		if (user_temp_table) then
			if (args.is_subset_of?(user_temp_table.table_arguments)) then
				createTable = false
			end
		else
			user_temp_table = UserTempTable.new(:user_id => @session[:user], :session_id => @session.session_id)
		end

		if (createTable) then
			# save the table_arguments in user_temp_table
			user_temp_table.table_arguments = args
			user_temp_table.save!

			sql_parts = {:joins => [], :select => [], :group_by => [], :order_by => [], :where => [], :having => []}

			# build join based on list_subjects
			# always include the primary key of each subject in the select clause, this is required for link generation...
			sql_parts[:joins] = args.list_subjects.collect do |list_subject|
				if (!list_subject.is_aggregate) then
				  sql_parts[:select] << "#{list_subject.subject.table_name}.id as #{list_subject.subject.table_name}_id"
				end
				if (list_subject.subject.table_name != 'computers') then # we'll always join this clause in
					SQLStatements.const_get("SQLFromClauseFor_#{list_subject.subject.table_name}")
				end
			end

			# build select clause
			args.list_columns.each do |property|
				if (property.source_table == 'properties') then
					# computer property
					sql_parts[:joins] << SQLStatements::SQLFromClauseFor_computer_properties.gsub(/::table_alias::/, 'computer_property_'+property.id.to_s).gsub(/::property_id::/, property.id.to_s)
					sql_parts[:select] << "computer_property_#{property.id}.value as `#{property.name}`"
					sql_parts[:group_by] << "`#{property.name}`"
				else
					# report subject property
					real_property = ReportSubjectProperty.find(property.id, :include => :ReportSubject)
					sql_parts[:select] << "#{real_property.select_clause} as `#{real_property.name}`"
					if (!real_property.is_aggregate) then
						sql_parts[:group_by] << "`#{real_property.name}`"
					end
				end
			end

			# parse data filters. take note of special behavior here for multiple filters for the same property. (they're ORed!)
			sql_where_by_prop_id = {}
			sql_having_by_prop_id = {}
			args.list_subjects.each do |list_subject|
				if (list_subject.data_filters) then
					list_subject.data_filters.each do |data_filter|
						sql_where_by_prop_id[data_filter.property.id] = [] unless sql_where_by_prop_id[data_filter.property.id]
						sql_having_by_prop_id[data_filter.property.id] = [] unless sql_having_by_prop_id[data_filter.property.id]
						if (data_filter.property.source_table == 'properties') then
							# computer property
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
				end
			end
			# go through sql_where_by_prop_id and add to sql_parts[:where]
			sql_parts[:where] = sql_where_by_prop_id.collect do |property_id, criteria|
				if criteria.empty? then nil else
					"(" + criteria.join(" OR ") + ")"
				end
			end.compact
			# go through sql_having_by_prop_id and add to sql_parts[:having]
			sql_parts[:having] = sql_having_by_prop_id.collect do |property_id, criteria|
				if criteria.empty? then nil else
					"(" + criteria.join(" OR ") + ")"
				end
			end.compact

			# build final sql
			sql = "SELECT " + sql_parts[:select].join(", ") +
			" FROM " + SQLStatements::SQLFromClauseFor_computers + sql_parts[:joins].join(" ") +
			((sql_parts[:where].empty?) ? '' : " WHERE " + sql_parts[:where].join(" AND ")) +
			((sql_parts[:group_by].empty?) ? '' : " GROUP BY " + sql_parts[:group_by].join(", ")) +
			((sql_parts[:having].empty?) ? '' : " HAVING " + sql_parts[:having].join(" AND "))

			#vintage = (args.respond_to?(:vintage)) ? Time.now.to_i : args.vintage
			vintage = Time.now.to_i
			sql.gsub!(/::vintage::/, vintage.to_s)

			@dbh.execute("drop table if exists `#{user_temp_table.table_name}`")
			@dbh.execute("create table `#{user_temp_table.table_name}` #{sql}")
		end
		
		column_meta_data = Hash.new
    if (args.class == ListAnalysis) then
      # gather meta data for links about the columns in this table
      # data structure is 
      #   column_meta_data[property_name] = 
      #     :align String
      #     :isLink Boolean
      #     :hasLinks Boolean
      #     :links = [
      #       :name String
      #       :currentAnalysisOptions ListAnalysis
      #       :replacementMaps = {
      #         :columnName String
      #         :analysisOptionPropertyDescriptor Array of names of properties
      #       }
      #     ]
      
  		args.list_columns.each do |property|
  		  column_meta_data[property.name] = {
  		    :align => nil,
  		    :links => []
  		  }
  		  # figure out alignment
  		  column_meta_data[property.name][:align] = case property.property_type_id
    	    when DSSConstants::PropertyTypeID, DSSConstants::PropertyTypeNumber, DSSConstants::PropertyTypeTime, DSSConstants::PropertyTypeBoolean
    	      'right'
    	    else
    	      'left'
  		  end

  	    # generate link template for aggregate column to instances
  	    if (property.is_aggregate)
  	      listAnalysisTemplate = nil
  	      replacementMaps = []
  	      # copy the ListAnalysis options
  	      listAnalysisTemplate = args.deep_copy
  	      # mark the associated Subject as 'non-aggregate'
  	      listSubject = listAnalysisTemplate.list_subjects.find {|list_subject| list_subject.subject.id == property.report_subject_id}
  	      listSubject.is_aggregate = false
  	      # remove all current columns for this subject (because they are aggregate)
  	      # and replace with default set of columns
  	      listAnalysisTemplate.list_columns.delete_if {|list_column| list_column.report_subject_id == property.report_subject_id}
  	      listAnalysisTemplate.list_columns += AllProperty.find_all_by_report_subject_id_and_is_default_and_is_aggregate(property.report_subject_id, true, false)
  	      # remove data filters on all subjects excluding the subject that previously was 'aggregate'
  	      listAnalysisTemplate.list_subjects.each_with_index do |list_subject, index|
  	        if (list_subject != listSubject) then
  	          pkDataFilter = DataFilter.new
  	          report_subject_property = ReportSubjectProperty.find_by_report_subject_id_and_is_primary(list_subject.subject.id, true)
  	          pkDataFilter.property = AllProperty.find(report_subject_property.id)
  	          pkDataFilter.property_operator = PropertyTypeOperator.find(DSSConstants::PropertyType_ID_Operator_IsInSet)
  	          pkDataFilter.value = nil
  	          replacementMaps << {
  	            :columnName => "#{list_subject.subject.table_name}_id",
  	            :analysisOptionPropertyDescriptor => ['list_subjects',index,'data_filters',0,'value']
  	          }
  	          list_subject.data_filters = [pkDataFilter]
  	        end
  	      end
  	      column_meta_data[property.name][:links] << {
  	        :name => 'View instances',
  	        :currentAnalysisOptions => listAnalysisTemplate,
  	        :replacementMaps => replacementMaps
  	      }
  	    end
  		end
  	end
		return {
		  :success => true, 
		  :user_temp_table_id => user_temp_table.id, 
		  :column_meta_data => column_meta_data
		}
	end

	#
	# this method is called once per list refresh
	#
	def getListCount(args)
		return getRealRowLimit(args) if !getRealRowLimit(args).nil?
		@dbh.select_value("select count(*) from `#{UserTempTable.find(args.user_temp_table_id).table_name}`")
	end

	def getListForWidget(args, limit, offset, sortArgs)
	  sort_clause = getRealSortClause(args, sortArgs)
		@dbh.select_all("select * from `#{UserTempTable.find(args.user_temp_table_id).table_name}` #{sort_clause} limit #{(getRealRowLimit(args).nil?) ? limit : getRealRowLimit(args) } offset #{offset}")
	end
	
	def getRealRowLimit(args)
	  if (args.respond_to?(:row_limit)) then
  		return args.row_limit if (args.row_limit > 0)
  	end
  	return nil
	end
	
	def getRealSortClause(args, sortArgs)
	  # determine sorting. sortArgs will always trump args.sort_columns
	  begin
	    sort_clause = sortArgs.join(", ")
	  rescue
	    begin
	      sort_clause = args.sort_columns.join(", ")
	    rescue
	      sort_clause = ''
	    end
    end
    return (sort_clause.empty?) ? "" : "ORDER BY #{sort_clause}"
	end

  def deleteCSVFileByName(aName)
    ar = aName.split("/")
    ar.delete_at(0)
    ar.delete_at(0)
    ar.delete_at(0)
    fName = "public/" + ar.join("/")
    if (File.exists?(fName)) then 
      File.delete(fName)
    end
  end

  def getCSVListForWidget(args, limit, offset, sortArgs, userName)
    sort_clause = getRealSortClause(args, sortArgs)
   dirName = 'public/csv/' + userName
   ar = dirName.split("/")
   fDir = ""
   ar.each{ |each| 
    fDir += each
     begin
       Dir.mkdir(fDir)
       rescue
     end
     fDir += "/"
   }
    for i in 1..100
      fPat = Date.today.to_s + Time.new.usec.to_s
      fName = dirName + '/' + userName + '-data' + fPat + i.to_s + '.csv'
      break if File.exists?(fName)
    end
    if i == 100 then i = 1 end
    rows = @dbh.select_all("select `"+args.list_columns.collect(&:name).join("`, `")+"` from `#{UserTempTable.find(args.user_temp_table_id).table_name}` #{sort_clause}")
    fName = dirName + '/' + userName + '-data' + fPat + (i+1).to_s + '.csv'
    outfile = File.open(fName, 'w')
    rowCount = 0
    CSV::Writer.generate(outfile) do |csv|
      rows.each { |row| 
        if (rowCount == 0) then csv << row.keys end
        csv << row.values 
        rowCount += 1
      }
    end 
    outfile.close
    fName
  end
end