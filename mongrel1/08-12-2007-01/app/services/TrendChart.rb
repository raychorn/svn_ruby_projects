require 'weborb/context'
require 'weborb/log'
require 'rbconfig'
require 'set'

class TrendChart
	def getTrendForWidget(args)
		if args.computer_group.nil? || args.metric.nil?
			return {:success => false, :message => "You must choose a Computer Group and a Metric"}
		end

		computer_group = ComputerGroup.find(args.computer_group.id)
		computer_groups = computer_group.children.empty? ? [computer_group] : computer_group.children

		# build our series data
		trend_data = []
		computer_groups.each do |computer_group|
			trend_data << {:name => computer_group.name, :id => computer_group.id, :data => makeFakeTrend(args.days)}
		end

		# finally, return
		{
			:trend_data => trend_data,
			:threshold => 20 + rand(40),
			:success => true
		}
	end

	def getTrendForAnalysis(args)
		if args.computer_group.nil? || args.metric.nil?
			return {:success => false, :message => "You must choose a Computer Group and a Metric"}
		end

		computer_group = ComputerGroup.find(args.computer_group.id)
		computer_groups = computer_group.children.empty? ? [computer_group] : computer_group.children

		# first build our series data
		trend_data = []
		computer_groups.each do |computer_group|
			trend_data << {:name => computer_group.name, :id => computer_group.id, :data => makeFakeTrend}
		end

		# now build our delta_data
		delta_data = []
		# figure out which delta types to show based on the selected metric
		subject_ids = ReportMetric.find(args.metric.id, :include => :report_subjects).report_subjects.collect &:id
		delta_types = ReportDeltaType.find(:all, :include => :report_subjects).select do |delta_type|
			delta_type_subject_ids = delta_type.report_subjects.collect &:id
			delta_type_subject_ids.to_set.subset?(subject_ids.to_set)
		end

		# now get data for each delta type
		computer_group_ids = computer_groups.collect &:id
		delta_types.each do |delta_type|
			delta_data << {
				:id => delta_type.id,
				:name => delta_type.name,
				:events => []
			}
			ReportDeltaEvent.find_all_by_report_delta_type_id(delta_type.id, :conditions => ["(instance_id is null or instance_id IN (?))", computer_group_ids]).each do |report_delta_event|
				delta_data.last[:events] << {
					:computer_group_id => report_delta_event.instance_id,
					:value => report_delta_event.value,
					:xValue => report_delta_event.time_stamp.to_i.to_s + '000'
				}
			end
		end

		# finally, return
		{
			:trend_data => trend_data,
			:threshold => 20 + rand(40),
			:delta_data => delta_data,
			:delta_types => delta_types,
			:success => true
		}
	end

	def getMacroTrendForAnalysis(args)
		if args.computer_group.nil? || args.metric.nil?
			return {:success => false, :message => "You must choose a Computer Group and a Metric"}
		end

		computer_group = ComputerGroup.find(args.computer_group.id)

		# first build our series data
		trend_data = []
		trend_data << {:name => computer_group.name, :id => computer_group.id, :data => makeFakeTrend}

		# finally, return
		{
			:trend_data => trend_data,
			:success => true
		}
	end

	private
	def makeFakeTrend(days = nil)
		# yay for fake data!
		days = 365 if days.nil?

		startDate = Date.today - days
		endDate = Date.today

		data_points = []
		priorYValue = rand(80)
		startDate.upto(endDate) do |day|
			priorYValue += ((rand(2) < 1 ? 1 : -1) * rand(3))
			priorYValue = 0 unless priorYValue >= 0
			data_points << {:xValue => Time.parse(day.to_s).to_i.to_s + '000', :yValue => priorYValue}
		end
		data_points
	end
end