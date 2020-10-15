module SQLStatements
	SQLFromClauseFor_computers = "
		computers LEFT OUTER JOIN (
			computers_operating_systems INNER JOIN operating_systems ON (computers_operating_systems.operating_system_id = operating_systems.id)
		) ON (
			computers.id = computers_operating_systems.computer_id AND
			computers_operating_systems.valid_from <= from_unixtime(::vintage::) AND
			(computers_operating_systems.valid_to > from_unixtime(::vintage::) OR computers_operating_systems.valid_to IS NULL)
		)
	".freeze

	SQLFromClauseFor_vulns = "
		LEFT OUTER JOIN (
			computer_vulns INNER JOIN vulns ON (computer_vulns.vuln_id = vulns.id)
		) ON (
			computers.id = computer_vulns.computer_id AND
			computer_vulns.valid_from <= from_unixtime(::vintage::) AND
			(computer_vulns.valid_to > from_unixtime(::vintage::) OR computer_vulns.valid_to IS NULL)
		)
	".freeze

	SQLFromClauseFor_apps = "
		LEFT OUTER JOIN (
			computer_apps INNER JOIN apps ON (computer_apps.app_id = apps.id)
		) ON (
			computers.id = computer_apps.computer_id AND
			computer_apps.valid_from <= from_unixtime(::vintage::) AND
			(computer_apps.valid_to > from_unixtime(::vintage::) OR computer_apps.valid_to IS NULL)
		)
	".freeze

	SQLFromClauseFor_benchmarks = "
		LEFT OUTER JOIN (
			computer_benchmarks INNER JOIN benchmarks ON (computer_benchmarks.benchmark_id = benchmarks.id)
			INNER JOIN benchmark_platforms ON (benchmarks.id = benchmark_platforms.benchmark_id)
			INNER JOIN platforms ON (benchmark_platforms.platform_id = platforms.id)
		) ON (
			computers.id = computer_benchmarks.computer_id AND
			computer_benchmarks.valid_from <= from_unixtime(::vintage::) AND
			(computer_benchmarks.valid_to > from_unixtime(::vintage::) OR computer_benchmarks.valid_to IS NULL)
		)
	".freeze

	SQLFromClauseFor_computer_groups = "
		LEFT OUTER JOIN (
			computer_groups_computers INNER JOIN computer_groups ON (computer_groups_computers.computer_group_id = computer_groups.id)
		) ON (
			computers.id = computer_groups_computers.computer_id AND
			computer_groups_computers.valid_from <= from_unixtime(::vintage::) AND
			(computer_groups_computers.valid_to > from_unixtime(::vintage::) OR computer_groups_computers.valid_to IS NULL)
		)
	".freeze

	SQLFromClauseFor_operating_systems = "".freeze # blank because Operating Systems are already joined in our base query

	#
	# here's some crazy property join template which will be included for each distinct computer property the user is requesting
	# the special replacement vars here are ::table_alias:: and ::property_id::
	#
	SQLFromClauseFor_computer_properties = "
		LEFT OUTER JOIN computer_properties as ::table_alias:: ON (
			computers.id = ::table_alias::.computer_id AND
			::table_alias::.property_id = ::property_id:: AND
			::table_alias::.valid_from <= from_unixtime(::vintage::) AND
			(::table_alias::.valid_to > from_unixtime(::vintage::) OR ::table_alias::.valid_to IS NULL)
		)
	".freeze
end