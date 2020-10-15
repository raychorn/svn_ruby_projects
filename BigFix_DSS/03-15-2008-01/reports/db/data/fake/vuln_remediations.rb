#!/usr/bin/env ruby
require 'rubygems'
require 'mysql'
require 'CSV'

dbh = Mysql.real_connect(nil, 'mluu', nil, 'reports_development')
res = dbh.query("begin")

res = dbh.query("select id from vulns");
CSV.open('vuln_remediations.data', 'w') do |writer|
	res.each do |row|
		(rand(3)+1).times do
			remediation_type_id = rand(4) + 1;
			description = case remediation_type_id
				when 1 then "a patch for this vuln"
				when 2 then "changing reg setting blah to x"
				when 3 then "blocking port foo"
				when 4 then "turning of this application"
			end
			writer << [row[0], remediation_type_id, description]
		end
	end
end

res = dbh.query("delete from vuln_remediations")
res = dbh.query("load data local infile 'vuln_remediations.data' replace into table vuln_remediations fields terminated by ',' optionally enclosed by '\"' (vuln_id, remediation_type_id, description)")
res = dbh.query("commit")
dbh.close