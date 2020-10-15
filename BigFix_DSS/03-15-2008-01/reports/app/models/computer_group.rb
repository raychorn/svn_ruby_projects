require 'acts_as_temporal'
require 'editor_support'

# This is included to make sure that the filter gets deserialized correctly.
require_dependency 'all_property'
require_dependency 'flex_only_classes'

class ComputerGroup < ActiveRecord::Base
	acts_as_tree :order => "name"
	acts_as_temporal
	has_and_belongs_to_many_temporal :computers
	has_and_belongs_to_many :roles
	has_and_belongs_to_many :datasource_computer_groups
	validates_presence_of :name
	validates_presence_of :parent, :if => :parent_id
	serialize :filter

	editable

  before_validation do |cg|
    cg.parent_id = nil if cg.parent_id == 0
  end

	def descendants
		# This will loop infinitely if there is a cycle in the tree!
		children + children.dup.map { |c| c.descendants }.flatten
	end

	def is_viewable_by?(user)
		user.admin? || !(user.roles.find(:first, :include => :computer_groups, :conditions => ["computer_group_id = ?", id]).nil?)
	end

	def is_editable_by?(user)
		user.admin?
	end

  def property_is_viewable_by?(property_name, user)
    property_name == 'datasource_computer_group_ids' || property_name == 'role_ids'
  end
  
  def property_is_editable_by?(property_name, user)
    property_name == 'datasource_computer_group_ids' || \
    (property_name == 'role_ids' && user.admin?)
  end

	def after_initialize
		@old_parent_id = parent_id
	end

	def after_save
		# If we got reparented, repair permissions on all roles that have perms on
		# our parent.
		if parent_id != @old_parent_id && parent != nil
			Role.repair_permissions(parent.role_ids)
		end
	end

	def self.user_find_options(user, args={})
		return args if user.nil? || user.admin?

		args[:select] ||= "computer_groups.*"
		args[:joins] ||= ""
		args[:joins] += " INNER JOIN computer_groups_roles" \
										" ON (computer_groups.id = computer_groups_roles.computer_group_id)" \
										" INNER JOIN roles_users" \
										" ON (roles_users.role_id = computer_groups_roles.role_id)"
		args[:conditions] = args[:conditions].blank? ? "" : sanitize_sql(args[:conditions]) + " AND "
		args[:conditions] += sanitize_sql(["roles_users.user_id = ?", user.id])

		args
	end

	def self.find_for_user(user, what, args={})
		args[:user] = user
		find(what, args)
	end

	def self.make_tree(nodes)
		tree = []
		nodes.each do |node|
			tree.push(node) if node.parent_id.nil?
			node.children.loaded
			node.children.target = []
			nodes.each do |child|
				node.children.target.push(child) if child.parent_id == node.id
			end
		end
		tree
	end

	def self.find_all_as_tree(user=nil)
		all = user.nil? ? find(:all, :order => 'name') : find_for_user(:all, :order => 'name')
		make_tree(all)
	end

	def self.find_all_as_indexed_tree(user=nil, index_method=:id)
		all = user.nil? ? find(:all, :order => 'name') : find_for_user(:all, :order => 'name')
		make_tree(all)
		all.index_by &index_method
	end

	def self.insert_aggregate_data_at(time)
		connection.transaction do
			connection.execute computer_aggregation_sql(time)
			connection.execute vuln_aggregation_sql(time)
			connection.execute benchmark_aggregation_sql(time)
		end
	end

	def self.computer_aggregation_sql(time)
		cg_table = table_name
		join_table = reflections[:computers].options[:join_table]
		quoted_time = quote_value(time)
		"INSERT INTO agg_computer_groups (computer_group_id, total_members, time_stamp) " \
		"SELECT #{cg_table}.#{primary_key} as computer_group_id," \
		" count(computer_id) AS total_members," \
		" #{quoted_time} AS time_stamp " \
		"FROM #{cg_table} " \
		"LEFT OUTER JOIN #{join_table}" \
		" ON (#{cg_table}.#{primary_key} = #{join_table}.computer_group_id" \
		"  AND #{join_table}.valid_from <= #{quoted_time}" \
		"  AND (#{join_table}.valid_to > #{quoted_time} OR #{join_table}.valid_to IS NULL)) " \
		"GROUP BY #{cg_table}.#{primary_key}"
	end

	def self.vuln_aggregation_sql(time)
		cg_table = table_name
		comp_join_table = reflections[:computers].options[:join_table]
		vuln_join_table = reflections[:computers].klass.reflections[:computer_vulns].table_name
		quoted_time = quote_value(time)

		"INSERT INTO agg_computer_groups_vulns (vuln_id, total_instances, agg_computer_group_id) " \
		"SELECT #{vuln_join_table}.vuln_id," \
		" count(#{vuln_join_table}.computer_id) AS total_instances," \
		" agg_computer_groups.id AS agg_computer_group_id " \
		"FROM agg_computer_groups " \
		"INNER JOIN #{comp_join_table}" \
		" ON (agg_computer_groups.computer_group_id = #{comp_join_table}.computer_group_id" \
		"  AND #{comp_join_table}.valid_from <= #{quoted_time}" \
		"  AND (#{comp_join_table}.valid_to > #{quoted_time} OR #{comp_join_table}.valid_to IS NULL)) " \
		"INNER JOIN #{vuln_join_table}" \
		" ON (#{comp_join_table}.computer_id = #{vuln_join_table}.computer_id" \
		"  AND #{vuln_join_table}.valid_from <= #{quoted_time}" \
		"  AND (#{vuln_join_table}.valid_to > #{quoted_time} OR #{vuln_join_table}.valid_to IS NULL)) " \
		"WHERE agg_computer_groups.time_stamp = #{quoted_time} " \
		"GROUP BY agg_computer_groups.id, #{vuln_join_table}.vuln_id"
	end

	def self.benchmark_aggregation_sql(time)
		cg_table = table_name
		comp_join_table = reflections[:computers].options[:join_table]
		bench_join_table = reflections[:computers].klass.reflections[:computer_benchmarks].table_name
		quoted_time = quote_value(time)

		"INSERT INTO agg_computer_groups_benchmarks (benchmark_id, total_applicable_computers, total_passed_checks, agg_computer_group_id) " \
		"SELECT #{bench_join_table}.benchmark_id," \
		" COUNT(computer_benchmarks.computer_id) AS total_applicable_computers," \
		" SUM(num_checks_passed) AS total_passed_checks," \
		" agg_computer_groups.id AS agg_computer_group_id " \
		"FROM agg_computer_groups " \
		"INNER JOIN #{comp_join_table}" \
		" ON (agg_computer_groups.computer_group_id = #{comp_join_table}.computer_group_id" \
		"  AND #{comp_join_table}.valid_from <= #{quoted_time}" \
		"  AND (#{comp_join_table}.valid_to > #{quoted_time} OR #{comp_join_table}.valid_to IS NULL)) " \
		"INNER JOIN #{bench_join_table}" \
		" ON (#{comp_join_table}.computer_id = #{bench_join_table}.computer_id" \
		"  AND #{bench_join_table}.valid_from <= #{quoted_time}" \
		"  AND (#{bench_join_table}.valid_to > #{quoted_time} OR #{bench_join_table}.valid_to IS NULL)) " \
		"WHERE agg_computer_groups.time_stamp = #{quoted_time} " \
		"GROUP BY agg_computer_groups.id, benchmark_id"
	end

	def self.most_recent_aggregation_time
		v = connection.select_value("SELECT max(time_stamp) FROM agg_computer_groups")
		v.nil? ? nil : Time.parse(v)
	end
end
