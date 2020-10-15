module Summarize
  SummarizeComputerGroups = \
    'INSERT INTO agg_computer_groups (computer_group_id, total_members) ' \
    'SELECT computer_group_id, count(computer_id) FROM computer_groups_computers ' \
    'WHERE valid_to IS NULL ' \
    'GROUP BY computer_group_id'
  
  SummarizeComputerGroupVulns = \
    'INSERT INTO agg_computer_groups_vulns' \
    ' (agg_computer_group_id, vuln_id, total_instances) ' \
    'SELECT acg.id, cv.vuln_id, count(cv.computer_id)' \
    ' FROM computer_vulns AS cv' \
    ' INNER JOIN computer_groups_computers AS cgc' \
    '  ON (cgc.computer_id = cv.computer_id)' \
    ' INNER JOIN (SELECT max(id) AS id, computer_group_id' \
    '             FROM agg_computer_groups GROUP BY computer_group_id) AS acg' \
    '  ON (acg.computer_group_id = cgc.computer_group_id) ' \
    'WHERE computer_vulns.valid_to IS NULL ' \
    'GROUP BY acg.id, vuln_id'
  
  SummarizeComputerGroupBenchmarks = \
    'INSERT INTO agg_computer_groups_benchmarks' \
    ' (agg_computer_group_id, benchmark_id, total_applicable_computers, total_passed_checks) ' \
    'SELECT acg.id, cb.benchmark_id, count(cb.computer_id), sum(cb.num_checks_passed)' \
    ' FROM computer_benchmarks AS cb' \
    ' INNER JOIN computer_groups_computers AS cgc' \
    '  ON (cgc.computer_id = cb.computer_id)' \
    ' INNER JOIN (SELECT max(id) AS id, computer_group_id' \
    '             FROM agg_computer_groups GROUP BY computer_group_id) AS acg' \
    '  ON (acg.computer_group_id = cgc.computer_group_id) ' \
    'WHERE computer_vulns.valid_to IS NULL ' \
    'GROUP BY acg.id, cb.benchmark_id'
end
