#!/bin/sh

TABLES="apps apps_bes apps_vulns bes_sites operating_systems operating_systems_bes vuln_advisories vulns vulns_bes vuln_remediations vuln_remediations_vulns"
/usr/local/mysql/bin/mysqldump -u root reports_development $TABLES
