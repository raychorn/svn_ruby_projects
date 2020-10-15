#!/usr/bin/env ruby
require 'rubygems'
require 'mysql'
require 'CSV'

def writeRandomData(report_delta_type_id, instance_id = nil)
	outfile = File.open('report_delta_events.data', 'a')
	CSV::Writer.generate(outfile) do |csv|
		rand(20).times do
			startDate = Date.today - 365 + rand(365)
			random_numeric = rand(200)+1
			random_string = case report_delta_type_id
				when 7 then
					"Enforcing 'Audit Policy' configuration"
				else
					random_numeric
			end
			csv << [report_delta_type_id, startDate.to_s, "Enforcing 'Audit Policy' configuration", instance_id.nil? ? '\N' : instance_id]
		end
	end
	outfile.close
end


dbh = Mysql.real_connect(nil, 'mluu', nil, 'reports_development')
res = dbh.query("begin")

res = dbh.query("select id from computer_groups")
computer_group_ids = []
res.each do |row| computer_group_ids << row[0] end

outfile = File.open('report_delta_events.data', 'w')
outfile.close
res = dbh.query("select id from report_delta_types")
res.each do |row|
	case row[0].to_i
		when 1, 6, 7, 8 then
			computer_group_ids.each do |instance_id|
				writeRandomData(row[0], instance_id)
			end
		else
			writeRandomData(row[0])
	end
end

res = dbh.query("delete from report_delta_events")
res = dbh.query("load data local infile 'report_delta_events.data' replace into table report_delta_events fields terminated by ',' optionally enclosed by '\"' (report_delta_type_id, time_stamp, value, instance_id)")
res = dbh.query("commit")

