require 'CSV'

dbh = ActiveRecord::Base.connection


computer_ids = dbh.select_values("select id from computers")

outfile = File.open('benchmarks.data', 'w')
CSV::Writer.generate(outfile) do |csv|
	benchmark_ids = dbh.select_values("select id from benchmarks")
	benchmark_ids.each do |benchmark_id|
		computer_ids.each do |computer_id|
			random_num_tests = rand(100)+1
			random_num_passed = rand(random_num_tests)
			csv << [computer_id, benchmark_id, random_num_tests, random_num_passed]
		end
	end
end
outfile.close

dbh.begin_db_transaction
dbh.execute("delete from computer_benchmarks")
dbh.execute("load data local infile 'benchmarks.data' replace into table computer_benchmarks fields terminated by ',' optionally enclosed by '\"' (computer_id, benchmark_id, num_checks_tested, num_checks_passed)")
dbh.commit_db_transaction

