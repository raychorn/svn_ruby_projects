require 'report_subject'
require 'report_subject_property'
require 'property_type_operator'
require 'all_computer_group_distribution'
require 'aggregate_function'

class WebOrbResult
    attr_accessor :status, :type, :info, :statusMsg
	
	def initialize
		@type = 'WebOrbResult'
		@status = -1
        @info = ''
        @statusMsg = ''
	end
end

class ComputerGroupTreeNode
	attr_accessor :id, :name, :children
end

class ColumnWidget
	attr_accessor :computer_groups, :aggregate_function, :computer_group_distribution, :sub_distribution_property, :data_filters, :ignore_computer_group_children
end

class ColumnAnalysis
	attr_accessor :computer_groups, :aggregate_function, :computer_group_distribution, :sub_distribution_property, :data_filters, :ignore_computer_group_children
end

class TrendWidget
	attr_accessor :ignore_computer_group_children, :days, :subject, :computer_group, :metric, :data_filters
end

class TrendAnalysis
	attr_accessor :subject, :computer_group, :metric, :data_filters
end

class ListWidget
	# :list_subjects is an array of ListSubject
	# :list_columns is an array of AllProperties
	attr_accessor :list_subjects, :list_columns, :row_limit, :user_temp_table_id, :sort_columns

	# this method is used to determine if 'other' is a subset of 'self'
	def is_subset_of?(other)
		if (
			list_subjects.collect{|list_subject| list_subject.subject.id}.to_set == other.list_subjects.collect{|list_subject| list_subject.subject.id}.to_set && # check subjects
			list_columns.collect(&:id).to_set.subset?(other.list_columns.collect(&:id).to_set)
		) then
			list_subjects.each do |list_subject|
				other_list_subject = other.list_subjects.select{|item| item.subject.id == list_subject.subject.id}.first
				if (!(list_subject.data_filters.to_set == other_list_subject.data_filters.to_set))
					return false
				end
			end
			return true
		end
		return false
	end
end

class ListAnalysis
	attr_accessor :list_subjects, :list_columns, :sort_columns, :user_temp_table_id
  def deep_copy
    Marshal.load(Marshal.dump(self))
  end
end

class ListSubject
	attr_accessor :subject, :data_filters, :is_aggregate
  def deep_copy
    Marshal.load(Marshal.dump(self))
  end
end

class ReportBuilder
	attr_accessor :shapeType, :x, :y, :width, :height, :widgetName, :widgetID, :text, :source
end

class DataFilter
	attr_accessor :property, :property_operator, :value
  def deep_copy
    Marshal.load(Marshal.dump(self))
  end

	def generateSQL(columnSpec)
		return case property_operator.id
			when 1 then # in set
				# special hackery here to deal with OS, Application, and Computer Group IDs
				# XXX: Are these IDs even correct?
				if ([1, 7, 8].member?(property.id)) then
					real_property = ReportSubjectProperty.find(property.id)
					"#{columnSpec} IN (#{real_property.ar_class.classify.constantize.descendants.collect(&:id).join(", ")}) "
				else
					"#{columnSpec} IN (#{value}) "
				end
			when 2 then # not in set
				# XXX: Are these IDs even correct?
				if ([1, 7, 8].member?(property.id)) then
					real_property = ReportSubjectProperty.find(property.id)
					"#{columnSpec} NOT IN (#{real_property.ar_class.classify.constantize.descendants.collect(&:id).join(", ")}) "
				else
					"#{columnSpec} NOT IN (#{value}) "
				end
			when 3 then # begins with
				"lower(#{columnSpec}) like '#{value.downcase}%' "
			when 4 then # does not begin with
				"lower(#{columnSpec}) not like '#{value.downcase}%' "
			when 5 then # is
				"lower(#{columnSpec}) = '#{value.downcase}' "
			when 6 then # is not
				"lower(#{columnSpec}) != '#{value.downcase}' "
			when 7 then # ends with
				"lower(#{columnSpec}) like '%#{value.downcase}' "
			when 8 then # does not end with
				"lower(#{columnSpec}) not like '%#{value.downcase}' "
			when 9 then # contains
				"lower(#{columnSpec}) like '%#{value.downcase}%' "
			when 10 then # does not contain
				"lower(#{columnSpec}) not like '%#{value.downcase}%' "
			when 11 then # is less than
				"#{columnSpec} < #{value.downcase} "
			when 12 then # equals
				"#{columnSpec} = #{value.downcase} "
			when 13 then # does not equal
				"#{columnSpec} != #{value.downcase} "
			when 14 then # is greater than
				"#{columnSpec} > #{value.downcase} "
			when 15 then # is between
				# unimplemented
			when 16 then # is (IP)
				# unimplemented
			when 17 then # is between (IP)
				# unimplemented
			when 18 then # is before (date)
				# unimplemented
			when 19 then # is after (date)
				# unimplemented
			when 20 then # is between (date)
				# unimplemented
		end
	end

	def eql?(other)
		(property ? property.id == other.property.id : other.property == nil) && \
		(property_operator ? property_operator.id == other.property_operator.id : other.property_operator == nil) && \
		value == other.value
	end

	def hash
		(property ? property.id : 0) ^ (property_operator ? property_operator.id : 0) ^ value.hash
	end
end