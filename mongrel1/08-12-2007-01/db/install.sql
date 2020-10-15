/*==============================================================*/
/* DBMS name:      MySQL 5.0                                    */
/* Created on:     7/27/2007 11:36:02 AM                        */
/*==============================================================*/


drop view if exists all_computer_group_distributions;

drop view if exists all_properties;

drop view if exists platforms;

drop table if exists agg_computer_groups;

drop table if exists agg_computer_groups_benchmarks;

drop table if exists agg_computer_groups_dlp_rule_events;

drop table if exists agg_computer_groups_vulns;

drop table if exists aggregate_functions;

drop table if exists app_relationship_types;

-- drop index index_1 on app_relationships;

drop table if exists app_relationships;

drop table if exists app_upgrades;

drop table if exists apps;

drop table if exists apps_bes;

drop table if exists apps_vulns;

drop table if exists benchmark_check_groups;

drop table if exists benchmark_check_remediations;

-- drop index index_1 on benchmark_check_results;

drop table if exists benchmark_check_results;

-- drop index index_1 on benchmark_checks;

drop table if exists benchmark_checks;

drop table if exists benchmark_platforms;

-- drop index index_1 on benchmark_versions;

drop table if exists benchmark_versions;

drop table if exists benchmarks;

drop table if exists bes_sites;

-- drop index index_1 on computer_apps;

drop table if exists computer_apps;

drop table if exists computer_benchmark_check_remediations;

-- drop index index_1 on computer_benchmarks;

drop table if exists computer_benchmarks;

drop table if exists computer_contact_relationships;

drop table if exists computer_contacts;

drop table if exists computer_group_distributions;

drop table if exists computer_groups;

drop table if exists computer_groups_computers;

drop table if exists computer_groups_datasource_computer_groups;

drop table if exists computer_groups_roles;

-- drop index index_1 on computer_malwares;

drop table if exists computer_malwares;

drop table if exists computer_properties;

drop table if exists computer_relationship_type;

drop table if exists computer_vuln_remediations;

-- drop index index_1 on computer_vulns;

drop table if exists computer_vulns;

drop table if exists computers;

drop table if exists computers_datasources;

-- drop index index_1 on computers_operating_systems;

drop table if exists computers_operating_systems;

drop table if exists contacts;

drop table if exists cvss_metric_groups;

drop table if exists cvss_metric_values;

drop table if exists cvss_metrics;

drop table if exists dashboard_dashboard_widgets;

drop table if exists dashboard_layouts;

drop table if exists dashboard_widgets;

drop table if exists dashboards;

-- drop index index_1 on datasource_computer_groups;

drop table if exists datasource_computer_groups;

drop table if exists datasource_types;

drop table if exists datasources;

drop table if exists dlp_rules;

drop table if exists dlp_severities;

drop table if exists malware_statuses;

drop table if exists malware_types;

drop table if exists malwares;

drop table if exists metric_thresholds;

drop table if exists operating_systems;

drop table if exists operating_systems_bes;

drop table if exists properties;

drop table if exists property_type_operators;

drop table if exists property_types;

drop table if exists remediation_types;

drop table if exists report_delta_events;

drop table if exists report_delta_types;

drop table if exists report_delta_types_report_subjects;

drop table if exists report_metrics;

drop table if exists report_metrics_report_subjects;

drop table if exists report_schedules;

drop table if exists report_subject_properties;

drop table if exists report_subjects;

drop table if exists reports;

drop table if exists roles;

drop table if exists roles_users;

drop table if exists user_temp_tables;

drop table if exists users;

drop table if exists visualization_types;

-- drop index index_1 on vuln_advisories;

drop table if exists vuln_advisories;

drop table if exists vuln_advisory_publishers;

drop table if exists vuln_cvss_metric_values;

drop table if exists vuln_remediations;

drop table if exists vuln_remediations_vulns;

drop table if exists vuln_severities;

drop table if exists vulns;

drop table if exists vulns_apps;

drop table if exists vulns_bes;

/*==============================================================*/
/* Table: agg_computer_groups                                   */
/*==============================================================*/
create table agg_computer_groups
(
   id                   bigint unsigned not null auto_increment,
   computer_group_id    smallint unsigned not null,
   total_members        bigint unsigned not null,
   time_stamp           timestamp not null default current_timestamp,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: agg_computer_groups_benchmarks                        */
/*==============================================================*/
create table agg_computer_groups_benchmarks
(
   id                   bigint unsigned not null auto_increment,
   agg_computer_group_id bigint unsigned not null,
   benchmark_id         smallint not null,
   total_applicable_computers bigint unsigned not null,
   total_passed_checks  bigint unsigned not null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: agg_computer_groups_dlp_rule_events                   */
/*==============================================================*/
create table agg_computer_groups_dlp_rule_events
(
   id                   bigint unsigned not null auto_increment,
   agg_computer_group_id bigint unsigned not null,
   dlp_rule_id          bigint not null,
   total_instances      bigint unsigned not null,
   time_stamp           timestamp not null default current_timestamp,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: agg_computer_groups_vulns                             */
/*==============================================================*/
create table agg_computer_groups_vulns
(
   id                   bigint unsigned not null auto_increment,
   agg_computer_group_id bigint unsigned not null,
   vuln_id              int not null,
   total_instances      bigint unsigned not null,
   time_stamp           timestamp not null default current_timestamp,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: aggregate_functions                                   */
/*==============================================================*/
create table aggregate_functions
(
   id                   tinyint unsigned not null,
   name                 varchar(255) not null,
   function_name        varchar(255) not null,
   primary key (id)
)
type = myisam;

insert into aggregate_functions (id, name, function_name) values (1, 'Total', 'sum');
insert into aggregate_functions (id, name, function_name) values (2, 'Average', 'avg');
insert into aggregate_functions (id, name, function_name) values (3, 'Minimum', 'min');
insert into aggregate_functions (id, name, function_name) values (4, 'Maximum', 'max');

/*==============================================================*/
/* Table: app_relationship_types                                */
/*==============================================================*/
create table app_relationship_types
(
   id                   tinyint unsigned not null,
   name                 varchar(255) not null,
   rev_name             varchar(255) not null,
   primary key (id)
)
type = myisam;

insert into app_relationship_types (id, name) values (1,'publishes');
insert into app_relationship_types (id, name) values (2,'bundles');
insert into app_relationship_types (id, name) values (3,'is instantiated by');
insert into app_relationship_types (id, name) values (4,'offers');
insert into app_relationship_types (id, name) values (5,'uses');
insert into app_relationship_types (id, name) values (6,'is an alias of');

/*==============================================================*/
/* Table: app_relationships                                     */
/*==============================================================*/
create table app_relationships
(
   id                   int unsigned not null auto_increment,
   app_id               int unsigned not null,
   related_app_id       int unsigned not null,
   app_relationship_type_id tinyint unsigned not null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Index: index_1                                               */
/*==============================================================*/
create index index_1 on app_relationships
(
   app_id,
   related_app_id,
   app_relationship_type_id
);

/*==============================================================*/
/* Table: app_upgrades                                          */
/*==============================================================*/
create table app_upgrades
(
   id                   smallint unsigned not null auto_increment,
   description          text not null,
   from_app_id          int unsigned not null,
   to_app_id            int unsigned not null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: apps                                                  */
/*==============================================================*/
create table apps
(
   id                   int unsigned not null auto_increment,
   name                 varchar(255) not null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: apps_bes                                              */
/*==============================================================*/
create table apps_bes
(
   id                   bigint unsigned not null auto_increment,
   app_id               int unsigned not null,
   pattern              varchar(512) not null,
   primary key (id),
   unique key ak_apps_bes_key_2 (app_id, pattern)
)
type = myisam;

/*==============================================================*/
/* Table: apps_vulns                                            */
/*==============================================================*/
create table apps_vulns
(
   app_id               int unsigned not null,
   vuln_id              int unsigned not null,
   primary key (app_id, vuln_id)
)
type = myisam;

alter table apps_vulns comment 'this table stores all possible vulnerabilities for a given a';

/*==============================================================*/
/* Table: benchmark_check_groups                                */
/*==============================================================*/
create table benchmark_check_groups
(
   id                   smallint unsigned not null auto_increment,
   name                 varchar(255) not null,
   parent_id            smallint unsigned null,
   benchmark_version_id smallint unsigned null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: benchmark_check_remediations                          */
/*==============================================================*/
create table benchmark_check_remediations
(
   id                   int unsigned not null auto_increment,
   benchmark_check_id   int unsigned not null,
   remediation_type_id  tinyint unsigned not null,
   description          text null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: benchmark_check_results                               */
/*==============================================================*/
create table benchmark_check_results
(
   id                   bigint unsigned not null auto_increment,
   computer_id          bigint unsigned not null,
   benchmark_check_id   int unsigned not null,
   current_state        varchar(255) null,
   pass                 bool not null,
   valid_from           timestamp not null default current_timestamp,
   valid_to             timestamp null default null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Index: index_1                                               */
/*==============================================================*/
create index index_1 on benchmark_check_results
(
   computer_id,
   benchmark_check_id
);

/*==============================================================*/
/* Table: benchmark_checks                                      */
/*==============================================================*/
create table benchmark_checks
(
   id                   int unsigned not null auto_increment,
   name                 varchar(255) not null,
   description          text null,
   desired_state        varchar(255) null,
   benchmark_version_id smallint unsigned not null,
   benchmark_check_group_id smallint unsigned null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Index: index_1                                               */
/*==============================================================*/
create index index_1 on benchmark_checks
(
   benchmark_version_id,
   benchmark_check_group_id
);

/*==============================================================*/
/* Table: benchmark_platforms                                   */
/*==============================================================*/
create table benchmark_platforms
(
   benchmark_id         smallint unsigned not null,
   platform_id          smallint unsigned not null,
   primary key (benchmark_id, platform_id)
)
type = myisam;

/*==============================================================*/
/* Table: benchmark_versions                                    */
/*==============================================================*/
create table benchmark_versions
(
   id                   smallint unsigned not null auto_increment,
   benchmark_id         smallint unsigned not null,
   version              tinyint unsigned not null,
   publish_time         timestamp not null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Index: index_1                                               */
/*==============================================================*/
create index index_1 on benchmark_versions
(
   benchmark_id,
   version
);

/*==============================================================*/
/* Table: benchmarks                                            */
/*==============================================================*/
create table benchmarks
(
   id                   smallint unsigned not null auto_increment,
   name                 varchar(255) not null,
   description          text null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: bes_sites                                             */
/*==============================================================*/
create table bes_sites
(
   id                   smallint unsigned not null auto_increment,
   url                  varchar(255) not null,
   primary key (id),
   unique key ak_bes_sites_key_2 (url)
)
type = myisam;

/*==============================================================*/
/* Table: computer_apps                                         */
/*==============================================================*/
create table computer_apps
(
   id                   bigint unsigned not null auto_increment,
   computer_id          bigint unsigned not null,
   app_id               int unsigned not null,
   port                 smallint unsigned null,
   valid_from           timestamp not null default current_timestamp,
   valid_to             timestamp null default null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Index: index_1                                               */
/*==============================================================*/
create index index_1 on computer_apps
(
   computer_id,
   app_id
);

/*==============================================================*/
/* Table: computer_benchmark_check_remediations                 */
/*==============================================================*/
create table computer_benchmark_check_remediations
(
   id                   bigint not null auto_increment,
   computer_id          bigint not null,
   benchmark_check_remediation_id int unsigned not null,
   time_stamp           timestamp not null default current_timestamp,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: computer_benchmarks                                   */
/*==============================================================*/
create table computer_benchmarks
(
   id                   bigint unsigned not null auto_increment,
   computer_id          bigint unsigned not null,
   benchmark_id         smallint unsigned not null,
   num_checks_tested    smallint unsigned not null,
   num_checks_passed    smallint unsigned not null,
   valid_from           timestamp not null default current_timestamp,
   valid_to             timestamp null default null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Index: index_1                                               */
/*==============================================================*/
create index index_1 on computer_benchmarks
(
   computer_id,
   benchmark_id
);

/*==============================================================*/
/* Table: computer_contact_relationships                        */
/*==============================================================*/
create table computer_contact_relationships
(
   id                   bigint unsigned not null auto_increment,
   contact_id           int not null,
   relevance            text not null,
   computer_relationship_type_id tinyint unsigned not null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: computer_contacts                                     */
/*==============================================================*/
create table computer_contacts
(
   id                   bigint unsigned not null auto_increment,
   computer_id          bigint unsigned not null,
   contact_id           int unsigned not null,
   computer_relationship_type_id tinyint unsigned not null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: computer_group_distributions                          */
/*==============================================================*/
create table computer_group_distributions
(
   id                   bigint unsigned not null auto_increment,
   name                 varchar(512) not null,
   select_clause        varchar(255) not null,
   report_subject_id    tinyint unsigned not null,
   primary key (id)
)
type = myisam;

insert into computer_group_distributions (report_subject_id, name, select_clause) values (2, 'Vulnerabilities', 'count(distinct vulns.id)');
insert into computer_group_distributions (report_subject_id, name, select_clause) values (2, 'Vulnerability Score', 'sum(vulns.cvss_base_score)');
insert into computer_group_distributions (report_subject_id, name, select_clause) values (3, 'Policy Compliance', '(100 * computer_benchmarks.num_checks_passed / computer_benchmarks.num_checks_tested)');
insert into computer_group_distributions (report_subject_id, name, select_clause) values (4, 'DLP Events', 'count(dlp_rules.id)');
insert into computer_group_distributions (report_subject_id, name, select_clause) values (5, 'Malwares', 'count(malwares.id)');
insert into computer_group_distributions (report_subject_id, name, select_clause) values (8, 'Applications', 'count(apps.id)');

/*==============================================================*/
/* Table: computer_groups                                       */
/*==============================================================*/
create table computer_groups
(
   id                   smallint unsigned not null auto_increment,
   name                 varchar(255) not null,
   parent_id            smallint unsigned null,
   filter               text null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: computer_groups_computers                             */
/*==============================================================*/
create table computer_groups_computers
(
   id                   bigint unsigned not null auto_increment,
   computer_group_id    smallint unsigned not null,
   computer_id          bigint unsigned not null,
   valid_from           timestamp not null default current_timestamp,
   valid_to             timestamp null default null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: computer_groups_datasource_computer_groups            */
/*==============================================================*/
create table computer_groups_datasource_computer_groups
(
   computer_group_id    smallint not null,
   datasource_computer_group_id smallint not null,
   primary key (computer_group_id, datasource_computer_group_id)
)
type = myisam;

/*==============================================================*/
/* Table: computer_groups_roles                                 */
/*==============================================================*/
create table computer_groups_roles
(
   computer_group_id    smallint unsigned not null,
   role_id              int unsigned not null,
   primary key (computer_group_id, role_id)
)
type = myisam;

/*==============================================================*/
/* Table: computer_malwares                                     */
/*==============================================================*/
create table computer_malwares
(
   id                   bigint unsigned not null,
   computer_id          bigint unsigned not null,
   malware_id           bigint unsigned not null,
   malware_status_id    tinyint unsigned not null,
   valid_from           timestamp not null default current_timestamp,
   valid_to             timestamp null default null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Index: index_1                                               */
/*==============================================================*/
create index index_1 on computer_malwares
(
   computer_id,
   malware_id
);

/*==============================================================*/
/* Table: computer_properties                                   */
/*==============================================================*/
create table computer_properties
(
   id                   bigint unsigned not null auto_increment,
   computer_id          bigint unsigned not null,
   property_id          smallint unsigned not null,
   value                varchar(255) not null,
   valid_from           timestamp not null default current_timestamp,
   valid_to             timestamp null default null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: computer_relationship_type                            */
/*==============================================================*/
create table computer_relationship_type
(
   id                   tinyint unsigned not null auto_increment,
   name                 varchar(255) not null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: computer_vuln_remediations                            */
/*==============================================================*/
create table computer_vuln_remediations
(
   id                   bigint unsigned not null auto_increment,
   computer_id          bigint not null,
   vuln_remediation_id  int not null,
   time_stamp           timestamp not null default current_timestamp,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: computer_vulns                                        */
/*==============================================================*/
create table computer_vulns
(
   id                   bigint unsigned not null auto_increment,
   computer_id          bigint unsigned not null,
   vuln_id              int unsigned not null,
   valid_from           timestamp not null default current_timestamp,
   valid_to             timestamp null default null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Index: index_1                                               */
/*==============================================================*/
create index index_1 on computer_vulns
(
   computer_id,
   vuln_id
);

/*==============================================================*/
/* Table: computers                                             */
/*==============================================================*/
create table computers
(
   id                   bigint unsigned not null auto_increment,
   last_seen            timestamp not null default current_timestamp,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: computers_datasources                                 */
/*==============================================================*/
create table computers_datasources
(
   id                   bigint unsigned not null auto_increment,
   computer_id          bigint unsigned not null,
   datasource_id        smallint unsigned not null,
   datasource_computer_id bigint unsigned not null,
   primary key (id),
   unique key ak_computers_datasources_key_2 (computer_id, datasource_id),
   unique key ak_computers_datasources_key_3 (datasource_id, datasource_computer_id)
)
type = myisam;

/*==============================================================*/
/* Table: computers_operating_systems                           */
/*==============================================================*/
create table computers_operating_systems
(
   id                   bigint unsigned not null auto_increment,
   computer_id          bigint unsigned not null,
   operating_system_id  int unsigned not null,
   valid_from           timestamp not null default current_timestamp,
   valid_to             timestamp null default null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Index: index_1                                               */
/*==============================================================*/
create index index_1 on computers_operating_systems
(
   computer_id,
   operating_system_id
);

/*==============================================================*/
/* Table: contacts                                              */
/*==============================================================*/
create table contacts
(
   id                   int unsigned not null auto_increment,
   user_id              int unsigned null,
   vcard                text not null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: cvss_metric_groups                                    */
/*==============================================================*/
create table cvss_metric_groups
(
   id                   tinyint unsigned not null,
   name                 varchar(255) not null,
   primary key (id)
)
type = myisam;

insert into cvss_metric_groups (id, name) values (1, 'Base');
insert into cvss_metric_groups (id, name) values (2, 'Temporal');
insert into cvss_metric_groups (id, name) values (3, 'Environmental');

/*==============================================================*/
/* Table: cvss_metric_values                                    */
/*==============================================================*/
create table cvss_metric_values
(
   id                   tinyint unsigned not null,
   cvss_metric_id       tinyint unsigned not null,
   name                 varchar(255) not null,
   description          text not null,
   score                float not null,
   primary key (id)
)
type = myisam;

insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (1, 1, 'Local', 'The vulnerability is only exploitable locally (i.e., it requires physical access or authenticated login to the target system)', 0.7);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (1, 2, 'Remote', 'The vulnerability is exploitable remotely', 1.0);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (2, 3, 'High', 'Specialized access conditions exist; for example: the system is exploitable during specific windows of time (a race condition), the system is exploitable under specific circumstances (nondefault configurations), or the system is exploitable with victim interaction (vulnerability exploitable only if user opens e-mail)', 0.8);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (2, 4, 'Low', 'Specialized access conditions or extenuating circumstances do not exist; the system is always exploitable', 1.0);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (3, 5, 'Required', 'Authentication is required to access and exploit the vulnerability', 0.6);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (3, 6, 'Not Required', 'Authentication is not required to access or exploit the vulnerability', 1.0);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (4, 7, 'None', 'No impact on confidentiality.', 0.0);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (4, 8, 'Partial', 'There is considerable informational disclosure. Access to critical system files is possible. There is a loss of important information, but the attacker doesn''t have control over what is obtainable or the scope of the loss is constrained. For example, a partial confidentiality impact would indicate a vulnerability that divulges bits in an encryption key or password hash information. Or, privileges are altered by one user to gain access to files of another user.', 0.7);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (4, 9, 'Complete', 'A total compromise of critical system information. A complete loss of system protection resulting in all critical system files being revealed. The attacker has sovereign control to read all of the system''s data (memory, files, etc).', 1.0);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (5, 10, 'None', 'No impact on integrity.', 0.0);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (5, 11, 'Partial', 'Considerable breach in integrity. Modification of critical system files or information is possible, but the attacker does not have control over what can be modified, or the scope of what the attacker can affect is constrained. For example, key system or program files may be overwritten or modified, but at random or in a limited context or scope.', 0.7);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (5, 12, 'Complete', 'A total compromise of system integrity. There is a complete loss of system protection resulting in the entire system being compromised. The attacker has sovereign control to modify any system files.', 1.0);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (6, 13, 'None', 'No impact on availability.', 0.0);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (6, 14, 'Partial', 'Considerable lag in or interruptions in resource availability. For example, a network-based flood attack that reduces available bandwidth to a web server farm to such an extent that only a small number of connections successfully complete.', 0.7);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (6, 15, 'Complete', 'Total shutdown of the affected resource. The attacker can render the resource completely unavailable.', 1.0);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (7, 16, 'Normal', 'Confidentiality Impact, Integrity Impact, and Availability Impact are all assigned the same weight.', 0.333);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (7, 17, 'Confidentiality', 'Confidentiality impact is assigned greater weight than Integrity Impact or Availability Impact.', 0.25);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (7, 18, 'Integrity', 'Integrity Impact is assigned greater weight than Confidentiality Impact or Availability Impact.', 0.25);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (7, 19, 'Availability', 'Availability Impact is assigned greater weight than Confidentiality Impact or Integrity Impact.', 0.5);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (8, 20, 'Unproven', 'No exploit code is yet available or an exploit method is entirely theoretical.', 0.85);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (8, 21, 'Proof of Concept', 'Proof of concept exploit code or an attack demonstration that is not practically applicable to deployed systems is available. The code or technique is not functional in all situations and may require substantial hand tuning by a skilled attacker for use against deployed systems.', 0.9);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (8, 22, 'Functional', 'Functional exploit code is available. The code works in most situations where the vulnerability is exploitable.', 0.95);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (8, 23, 'High', 'Either the vulnerability is exploitable by functional mobile autonomous code or no exploit is required (manual trigger) and the details for the manual technique are widely available. The code works in every situation where the vulnerability is exploitable and/or is actively being delivered via a mobile autonomous agent (a worm or virus).', 1.0);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (9, 24, 'Official Fix', 'A complete vendor solution is available. Either the vendor has issued the final, official patch which eliminates the vulnerability or an upgrade that is not vulnerable is available.', 0.87);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (9, 25, 'Temporary Fix', 'There is an official but temporary fix available. This includes instances where the vendor issues a temporary hotfix, tool or official workaround.', 0.9);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (9, 26, 'Workaround', 'There is an unofficial, non-vendor solution available. In some cases, users of the affected technology will create a patch of their own or provide steps to work around or otherwise mitigate against the vulnerability. When it is generally accepted that these unofficial fixes are adequate in plugging the hole for the mean time and no official remediation is available, this value can be set.', 0.95);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (9, 27, 'Unavailable', 'There is either no solution available or it is impossible to apply.', 1.0);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (10, 28, 'Unconfirmed', 'A single unconfirmed source or possibly several conflicting reports. There is little confidence in the validity of the report. For example, a rumor that surfaces from the hacker underground.', 0.9);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (10, 29, 'Uncorroborated', 'Multiple non-official sources; possibily including independent security companies or research organizations. At this point there may be conflicting technical details or some other lingering ambiguity. ', 0.95);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (10, 30, 'Confirmed', 'Vendor or author of the affected technology has acknowledged that the vulnerability exists. This value may also be set when existence of a vulnerability is confirmed with absolute confidence through some other event, such as publication of functional proof of concept exploit code or widespread exploitation.', 1.0);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (11, 31, 'None', 'There is no potential for physical or property damage.', 0.0);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (11, 32, 'Low', 'A successful exploit of this vulnerability may result in light physical or property damage or loss. The system itself may be damaged or destroyed.', 0.1);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (11, 33, 'Medium', 'A successful exploit of this vulnerability may result in significant physical or property damage or loss.', 0.3);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (11, 34, 'High', 'A successful exploit of this vulnerability may result in catastrophic physical or property damage and loss. The range of effect may be over a wide area.', 0.5);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (12, 35, 'None', 'No target systems exist, or targets are so highly specialized that they only exist in a laboratory setting. Effectively 0% of the environment is at risk.', 0.0);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (12, 36, 'Low', 'Targets exist inside the environment, but on a small scale. Between 1% - 15% of the total environment is at risk.', 0.25);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (12, 37, 'Medium', 'Targets exist inside the environment, but on a medium scale. Between 16% - 49% of the total environment is at risk.', 0.75);
insert into cvss_metric_values (cvss_metric_id, id, name, description, score) values (12, 38, 'High', 'Targets exist inside the environment on a considerable scale. Between 50% - 100% of the total environment is considered at risk.', 1.0);

/*==============================================================*/
/* Table: cvss_metrics                                          */
/*==============================================================*/
create table cvss_metrics
(
   id                   tinyint unsigned not null,
   name                 varchar(255) not null,
   description          text not null,
   cvss_metric_group_id tinyint unsigned not null,
   primary key (id)
)
type = myisam;

insert into cvss_metrics (cvss_metric_group_id, id, name, description) values (1, 1, 'Access Vector', 'This metric measures whether or not the vulnerability is exploitable locally or remotely. A vulnerability exploitable with only local access typically means the attacker must have either physical or authenticated login access to the target system, often either a walk-in scenario or a local account on a target computer system. Remote access typically means the attacker can trigger the vulnerability from across a network, either from across a wireless network or from across the Internet.');
insert into cvss_metrics (cvss_metric_group_id, id, name, description) values (1, 2, 'Access Complexity', 'This metric measures the complexity of attack required to exploit the vulnerability once an attacker has access to the target system. In most cases, once the target system is contacted, exploit of the vulnerability is academic. The traditional example is a simple remotely exploitable buffer overflow in an Internet server program that runs continuously. Once the target system is located, there is no additional complexity in accessing the target - an attacker presumably can exploit at the target at will. Other vulnerabilities require specialized access considerations in order to become exploitable. In other words, once the system is accessed, there may be additional barriers to exploitation. An example in this case would be a vulnerability in an email program that is only exploitable when the user downloads and opens a tainted attachment.');
insert into cvss_metrics (cvss_metric_group_id, id, name, description) values (1, 3, 'Authentication', 'This metric measures whether or not an attacker needs to be authenticated to the target system in order to exploit the vulnerability. The specific type of and mechanism for authentication is not important because it is considered that authentication in any form will add significant complexity to the exploitation process. Additionally, authentication is an either-or consideration. Attackers without valid credentials should not be able to access the target in order to exploit the vulnerability. Therefore, this metric''s values are mutually exclusive; only one of them can be true. If authentication of some sort is required, the final CVSS score will be considerably lower than if it were not required.');
insert into cvss_metrics (cvss_metric_group_id, id, name, description) values (1, 4, 'Confidentiality Impact', 'This metric measures the impact on confidentiality of a successful exploit of the vulnerability on the target system. Confidentiality refers to limiting information access and disclosure to only authorized users, as well as preventing access by or disclosure to unauthorized ones. Confidentiality is usually preserved by a system''s information protection mechanisms: cryptography, data compartmentalization, identification and authentication, etc.. Compromise of a system''s information protection mechanism can negatively impact confidentiality.');
insert into cvss_metrics (cvss_metric_group_id, id, name, description) values (1, 5, 'Integrity Impact', 'This metric measures the impact on integrity a successful exploit of the vulnerability will have on the target system. Integrity refers to the trustworthiness and guaranteed veracity of information. Integrity measures are meant to protect data from unauthorized modification. When the integrity of a system is sound, it is fully proof from unauthorized modification of its contents.');
insert into cvss_metrics (cvss_metric_group_id, id, name, description) values (1, 6, 'Availability Impact', 'This metric measures the impact on availability a successful exploit of the vulnerability will have on the target system. Availability refers to the accessibility of information resources. Almost exclusive to this domain are denial-of-service vulnerabilities. Attacks that compromise network bandwidth, processor cycles, disk space, or administrator time all impact the availability of a system.');
insert into cvss_metrics (cvss_metric_group_id, id, name, description) values (1, 7, 'Impact Bias', 'This metric allows a score to convey greater weighting to one of three impact metrics over the other two. An important consideration of the impact metrics is that the importance of the individual properties they measure can vary among systems. For example, a vulnerability affecting the confidentiality of an encrypted file system is far more severe than one affecting its availability. The Impact Bias metric will have no effect if the three impact metrics are all assigned the same value.');
insert into cvss_metrics (cvss_metric_group_id, id, name, description) values (2, 8, 'Exploitability', 'This metric attempts to measure the current state of exploit technique or code availability and suggests a likelihood of exploitation. It is assumed that there are far more unskilled attackers than there are attackers who are skilled enough to investigate vulnerabilities and create their own functional exploit code.');
insert into cvss_metrics (cvss_metric_group_id, id, name, description) values (2, 9, 'Remediation Level', 'The remediation status of a vulnerability is an important factor for prioritization. The typical vulnerability is unpatched when initially published. Workarounds or hotfixes submitted by the vendor or users may offer interim remediation until an official patch or upgrade is issued. Each of these respective stages adjusts the temporal score downwards, reflecting the decreasing urgency as remediation becomes final.');
insert into cvss_metrics (cvss_metric_group_id, id, name, description) values (2, 10, 'Report Confidence', 'This metric measures the degree of confidence in the existence of the vulnerability and the credibility of the known technical details. In many cases, vulnerabilities are initially reported by individual users either directly or indirectly through symptoms that suggest the existence of the vulnerability. The vulnerability may later be corroborated and then confirmed through acknowledgement by the author or vendor of the affected technology. The urgency of a vulnerability is the higher when a vulnerability is known to exist with certainty. This metric also suggests the level of technical knowledge available to would-be attackers.');
insert into cvss_metrics (cvss_metric_group_id, id, name, description) values (3, 11, 'Collateral Damage Potential', 'This metric measures the potential for a loss in physical equipment, property damage or loss of life or limb.');
insert into cvss_metrics (cvss_metric_group_id, id, name, description) values (3, 12, 'Target Distribution', 'This metric measures the relative size of the field of target systems susceptible to the vulnerability. It is meant as an environment-specific indicator in order to approximate the percentage of systems within the environment that could be affected by the vulnerability.');

/*==============================================================*/
/* Table: dashboard_dashboard_widgets                           */
/*==============================================================*/
create table dashboard_dashboard_widgets
(
   id                   bigint unsigned not null auto_increment,
   dashboard_id         bigint unsigned not null,
   dashboard_widget_id  bigint unsigned not null,
   position             tinyint unsigned not null default 1,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: dashboard_layouts                                     */
/*==============================================================*/
create table dashboard_layouts
(
   id                   tinyint unsigned not null auto_increment,
   rows                 tinyint unsigned not null,
   cols                 tinyint unsigned not null,
   layout_data          text not null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: dashboard_widgets                                     */
/*==============================================================*/
create table dashboard_widgets
(
   id                   bigint unsigned not null auto_increment,
   visualization_type_id tinyint unsigned not null,
   user_id              int unsigned not null,
   name                 varchar(255) not null,
   description          text null,
   visualization_type_options text not null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: dashboards                                            */
/*==============================================================*/
create table dashboards
(
   id                   bigint unsigned not null auto_increment,
   user_id              int unsigned not null,
   name                 varchar(255) not null,
   position             tinyint unsigned not null default 1,
   dashboard_layout_id  tinyint unsigned not null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: datasource_computer_groups                            */
/*==============================================================*/
create table datasource_computer_groups
(
   id                   smallint not null auto_increment,
   datasource_computer_group_id bigint unsigned not null,
   datasource_id        smallint not null,
   name                 varchar(255) not null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Index: index_1                                               */
/*==============================================================*/
create unique index index_1 on datasource_computer_groups
(
   datasource_computer_group_id,
   datasource_id
);

/*==============================================================*/
/* Table: datasource_types                                      */
/*==============================================================*/
create table datasource_types
(
   id                   tinyint unsigned not null,
   name                 varchar(255) not null,
   primary key (id)
)
type = myisam;

insert into datasource_types (id, name) values (1, 'DSS');
insert into datasource_types (id, name) values (2, 'BES');
insert into datasource_types (id, name) values (3, 'ActiveDirectory');
insert into datasource_types (id, name) values (4, 'CiscoWorks');
insert into datasource_types (id, name) values (5, 'Nmap');

/*==============================================================*/
/* Table: datasources                                           */
/*==============================================================*/
create table datasources
(
   id                   smallint unsigned not null auto_increment,
   name                 varchar(255) not null,
   datasource_type_id   tinyint unsigned not null,
   connection_params    text not null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: dlp_rules                                             */
/*==============================================================*/
create table dlp_rules
(
   id                   bigint unsigned not null,
   name                 varchar(255) not null,
   dlp_severity_id      tinyint unsigned not null,
   primary key (id)
)
type = myisam;

insert into dlp_rules (id, name, dlp_severity_id) values (1, 'Social Security', 1);
insert into dlp_rules (id, name, dlp_severity_id) values (2, 'Credit Card', 1);
insert into dlp_rules (id, name, dlp_severity_id) values (3, 'Internal Document', 2);
insert into dlp_rules (id, name, dlp_severity_id) values (4, 'VPN Client Certificate', 2);
insert into dlp_rules (id, name, dlp_severity_id) values (5, 'Phone Number', 3);

/*==============================================================*/
/* Table: dlp_severities                                        */
/*==============================================================*/
create table dlp_severities
(
   id                   tinyint unsigned not null,
   name                 varchar(255) not null,
   weight               float not null,
   primary key (id)
)
type = myisam;

insert into dlp_severities (id, name, weight) values (1, 'High', 1);
insert into dlp_severities (id, name, weight) values (2, 'Medium', .7);
insert into dlp_severities (id, name, weight) values (3, 'Low', .4);

/*==============================================================*/
/* Table: malware_statuses                                      */
/*==============================================================*/
create table malware_statuses
(
   id                   tinyint unsigned not null,
   name                 varchar(255) not null,
   primary key (id)
)
type = myisam;

insert into malware_statuses (id, name) values (1, 'Detected');
insert into malware_statuses (id, name) values (2, 'Inoculated');
insert into malware_statuses (id, name) values (3, 'Quarantined');

/*==============================================================*/
/* Table: malware_types                                         */
/*==============================================================*/
create table malware_types
(
   id                   tinyint unsigned not null auto_increment,
   name                 varchar(255) not null,
   primary key (id)
)
type = myisam;

insert into malware_types (name) values ('Virus');
insert into malware_types (name) values ('Spyware');
insert into malware_types (name) values ('Adware');
insert into malware_types (name) values ('Dialers');
insert into malware_types (name) values ('Remote Access');
insert into malware_types (name) values ('Hoaxes');
insert into malware_types (name) values ('Trackware');

/*==============================================================*/
/* Table: malwares                                              */
/*==============================================================*/
create table malwares
(
   id                   bigint unsigned not null auto_increment,
   malware_type_id      tinyint unsigned not null,
   name                 varchar(255) not null,
   description          text null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: metric_thresholds                                     */
/*==============================================================*/
create table metric_thresholds
(
   id                   int unsigned not null auto_increment,
   threshold            float not null,
   report_metric_id     smallint unsigned not null,
   computer_group_id    smallint unsigned not null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: operating_systems                                     */
/*==============================================================*/
create table operating_systems
(
   id                   int unsigned not null auto_increment,
   name                 varchar(255) not null,
   parent_id            smallint unsigned null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: operating_systems_bes                                 */
/*==============================================================*/
create table operating_systems_bes
(
   id                   bigint unsigned not null auto_increment,
   operating_system_id  int unsigned not null,
   pattern              varchar(512) not null,
   primary key (id),
   key ak_operating_systems_bes_key_2 (operating_system_id, pattern)
)
type = myisam;

/*==============================================================*/
/* Table: properties                                            */
/*==============================================================*/
create table properties
(
   id                   smallint unsigned not null auto_increment,
   name                 varchar(512) not null,
   property_type_id     tinyint unsigned not null,
   datasource_type_id   tinyint unsigned not null,
   is_default           bool not null default 0,
   is_enum              bool not null default 0,
   primary key (id)
)
type = myisam;

insert into properties (property_type_id, name, datasource_type_id, is_default, is_enum) values (4, 'IP Address', 2, 1, 0);
insert into properties (property_type_id, name, datasource_type_id, is_default, is_enum) values (2, 'DNS Name', 2, 1, 0);
insert into properties (property_type_id, name, datasource_type_id, is_default, is_enum) values (2, 'NetBIOS Name', 2, 1, 0);
insert into properties (property_type_id, name, datasource_type_id, is_default, is_enum) values (2, 'Processor Architecture', 2, 0, 1);
insert into properties (property_type_id, name, datasource_type_id, is_default, is_enum) values (3, 'Installed RAM', 2, 0, 0);
insert into properties (property_type_id, name, datasource_type_id, is_default, is_enum) values (3, 'Processor Speed', 2, 0, 0);

/*==============================================================*/
/* Table: property_type_operators                               */
/*==============================================================*/
create table property_type_operators
(
   id                   tinyint not null,
   name                 varchar(255) not null,
   property_type_id     tinyint unsigned not null,
   primary key (id)
)
type = myisam;

insert into property_type_operators (property_type_id, id, name) values (1, 1, 'is in set');
insert into property_type_operators (property_type_id, id, name) values (1, 2, 'is not in set');
insert into property_type_operators (property_type_id, id, name) values (2, 3, 'begins with');
insert into property_type_operators (property_type_id, id, name) values (2, 4, 'does not begin with');
insert into property_type_operators (property_type_id, id, name) values (2, 5, 'is');
insert into property_type_operators (property_type_id, id, name) values (2, 6, 'is not');
insert into property_type_operators (property_type_id, id, name) values (2, 7, 'ends with');
insert into property_type_operators (property_type_id, id, name) values (2, 8, 'does not end with');
insert into property_type_operators (property_type_id, id, name) values (2, 9, 'contains');
insert into property_type_operators (property_type_id, id, name) values (2, 10, 'does not contain');
insert into property_type_operators (property_type_id, id, name) values (3, 11, 'is less than');
insert into property_type_operators (property_type_id, id, name) values (3, 12, 'equals');
insert into property_type_operators (property_type_id, id, name) values (3, 13, 'does not equal');
insert into property_type_operators (property_type_id, id, name) values (3, 14, 'is greater than');
insert into property_type_operators (property_type_id, id, name) values (3, 15, 'is between');
insert into property_type_operators (property_type_id, id, name) values (4, 16, 'is');
insert into property_type_operators (property_type_id, id, name) values (4, 17, 'is between');
insert into property_type_operators (property_type_id, id, name) values (5, 18, 'is before');
insert into property_type_operators (property_type_id, id, name) values (5, 19, 'is after');
insert into property_type_operators (property_type_id, id, name) values (6, 20, 'is');

/*==============================================================*/
/* Table: property_types                                        */
/*==============================================================*/
create table property_types
(
   id                   tinyint unsigned not null,
   name                 varchar(255) not null,
   primary key (id)
)
type = myisam;

insert into property_types (id, name) values (1, 'ID');
insert into property_types (id, name) values (2, 'String');
insert into property_types (id, name) values (3, 'Number');
insert into property_types (id, name) values (4, 'IP');
insert into property_types (id, name) values (5, 'Time');
insert into property_types (id, name) values (6, 'Boolean');

/*==============================================================*/
/* Table: remediation_types                                     */
/*==============================================================*/
create table remediation_types
(
   id                   tinyint unsigned not null,
   name                 varchar(255) not null,
   primary key (id)
)
type = myisam;

insert into remediation_types (id, name) values (1, 'Software Patch');
insert into remediation_types (id, name) values (2, 'Configuration Change');
insert into remediation_types (id, name) values (3, 'Network Block');
insert into remediation_types (id, name) values (4, 'Disable Application');

/*==============================================================*/
/* Table: report_delta_events                                   */
/*==============================================================*/
create table report_delta_events
(
   id                   bigint unsigned not null auto_increment,
   report_delta_type_id tinyint unsigned not null,
   instance_id          bigint unsigned null,
   value                varchar(255) not null,
   time_stamp           timestamp not null default current_timestamp,
   primary key (id)
)
type = myisam;

alter table report_delta_events comment 'arrg. the instance_id here means the event is only applicabl';

/*==============================================================*/
/* Table: report_delta_types                                    */
/*==============================================================*/
create table report_delta_types
(
   id                   tinyint unsigned not null,
   name                 varchar(255) not null,
   threshold            float null,
   primary key (id)
)
type = myisam;

insert into report_delta_types (id, name) values (1, 'Change in number of Computers');
insert into report_delta_types (id, name) values (2, 'New Vulnerability definitions published');
insert into report_delta_types (id, name) values (3, 'New Virus definitions published');
insert into report_delta_types (id, name) values (4, 'Benchmark definition changed');
insert into report_delta_types (id, name) values (5, 'DLP definition changed');
insert into report_delta_types (id, name) values (6, 'Security Action taken');
insert into report_delta_types (id, name) values (7, 'Compliance Action taken');
insert into report_delta_types (id, name) values (8, 'Anti-threat Action taken');

/*==============================================================*/
/* Table: report_delta_types_report_subjects                    */
/*==============================================================*/
create table report_delta_types_report_subjects
(
   report_subject_id    tinyint not null,
   report_delta_type_id tinyint not null,
   primary key (report_subject_id, report_delta_type_id)
)
type = myisam;

insert into report_delta_types_report_subjects (report_delta_type_id, report_subject_id) values (1, 1);
insert into report_delta_types_report_subjects (report_delta_type_id, report_subject_id) values (2, 2);
insert into report_delta_types_report_subjects (report_delta_type_id, report_subject_id) values (3, 5);
insert into report_delta_types_report_subjects (report_delta_type_id, report_subject_id) values (4, 3);
insert into report_delta_types_report_subjects (report_delta_type_id, report_subject_id) values (5, 4);
insert into report_delta_types_report_subjects (report_delta_type_id, report_subject_id) values (6, 1);
insert into report_delta_types_report_subjects (report_delta_type_id, report_subject_id) values (6, 2);
insert into report_delta_types_report_subjects (report_delta_type_id, report_subject_id) values (7, 1);
insert into report_delta_types_report_subjects (report_delta_type_id, report_subject_id) values (7, 3);
insert into report_delta_types_report_subjects (report_delta_type_id, report_subject_id) values (8, 1);
insert into report_delta_types_report_subjects (report_delta_type_id, report_subject_id) values (8, 5);

/*==============================================================*/
/* Table: report_metrics                                        */
/*==============================================================*/
create table report_metrics
(
   id                   smallint unsigned not null,
   name                 varchar(255) not null,
   primary key (id)
)
type = myisam;

insert into report_metrics (id, name) values (1, 'Total Computers');
insert into report_metrics (id, name) values (2, 'Total Vulnerabilities');
insert into report_metrics (id, name) values (3, 'Average number of Vulnerbilities per Computer');
insert into report_metrics (id, name) values (4, 'Total CVSS Score');
insert into report_metrics (id, name) values (5, 'Average CVSS Score per Computer');
insert into report_metrics (id, name) values (6, 'Average Compliance Percentage per Computer');
insert into report_metrics (id, name) values (7, 'Total Incidents');
insert into report_metrics (id, name) values (8, 'Average number of Incidents per Computer');
insert into report_metrics (id, name) values (9, 'Total Malwares');
insert into report_metrics (id, name) values (11, 'Average number of Malwares detected per Computer');

/*==============================================================*/
/* Table: report_metrics_report_subjects                        */
/*==============================================================*/
create table report_metrics_report_subjects
(
   report_metric_id     smallint not null,
   report_subject_id    tinyint not null,
   group_by             bool not null,
   primary key (report_metric_id, report_subject_id)
)
type = myisam;

insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (1, 1, 1);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (2, 1, 0);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (2, 2, 1);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (3, 1, 0);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (3, 2, 1);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (4, 1, 0);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (4, 2, 1);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (5, 1, 0);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (5, 2, 1);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (6, 1, 0);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (6, 3, 1);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (7, 1, 0);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (7, 4, 1);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (8, 1, 0);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (8, 4, 1);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (9, 1, 0);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (9, 5, 1);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (11, 1, 0);
insert into report_metrics_report_subjects (report_metric_id, report_subject_id, group_by) values (11, 5, 1);

/*==============================================================*/
/* Table: report_schedules                                      */
/*==============================================================*/
create table report_schedules
(
   id                   int unsigned not null,
   report_id            int unsigned not null,
   schedule             text not null,
   primary key (id)
)
--type = myisam;

/*==============================================================*/
/* Table: report_subject_properties                             */
/*==============================================================*/
create table report_subject_properties
(
   id                   smallint unsigned not null,
   name                 varchar(512) not null,
   report_subject_id    tinyint unsigned not null,
   property_type_id     tinyint unsigned not null,
   select_clause        varchar(255) null,
   ar_class             varchar(255) null,
   is_aggregate         bool not null,
   is_default           bool not null,
   is_enum              bool not null default 0,
   is_primary           bool not null default 0,
   primary key (id)
)
type = myisam;

insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values (1,'Vulnerability','2',1,'vulns.id','vuln',0,0,0,1);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('2','Affected Application','2',1,'app_vulns.app_id','app',0,0,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('3','CVSS Score','2','3','vulns.cvss_final_score',null,0,1,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('4','Vulnerability Name','2','2','vulns.name',null,0,1,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('5','Remote Vector','2','6',null,null,0,0,1,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('6','Policy','3',1,'benchmarks.id','benchmark',0,0,0,1);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('7','Policy Name','3','2','benchmarks.name',null,0,1,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('8','Platform','3',1,'platforms.id','platform',0,0,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('9','DLP','4',1,'dlp_rules.id','dlp_rule',0,0,0,1);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('10','DLP Rule Name','4','2','dlp_rules.name',null,0,1,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('11','Severity','4','1','dlp_severities.id','dlp_severity',0,0,1,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('12','Malware','5',1,'malwares.id','malware',0,0,0,1);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('13','Type','5',1,'malware_types.id','malware_types',0,0,1,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('14','Malware Name','5','2','malware.name',null,0,1,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('15','Operating System','6',1,'operating_systems.id','operating_system',0,0,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('16','Computer Group Name',1,'2','computer_groups.name',null,0,1,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('17','Application Name','8','2','apps.name',null,0,1,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('18','Operating System Name','6','2','operating_systems.name',null,0,1,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('19','Operating System Name','7','2','operating_systems.name',null,0,1,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('20','Total Computers','6','3','count(distinct computers.id)',null,1,1,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('21','Total Applications','8','3','count(distinct computers.id, apps.id)',null,1,1,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('22','Total Vulnerabilities','2','3','count(distinct computers.id, vulns.id)',null,1,1,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('23','Average Number of Vulnerabilities Per Computer','2','3','count(distinct computers.id, vulns.id)/count(distinct computers.id)',null,1,0,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('24','Average Number of Applications Per Computer','8','3','count(distinct computers.id, apps.id)/count(distinct computers.id)',null,1,0,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('25','Total CVSS Score','2','3','sum(vulns.cvss_base_score)',null,1,0,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('26','Average CVSS Score per Computer','2','3','sum(vulns.cvss_base_score)/count(distinct computers.id)',null,1,0,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('27','Computer Group',1,1,'computer_groups.id','computer_group',0,0,0,1);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('28','Policy Compliance','3','3','(100 * computer_benchmarks.num_checks_passed / computer_benchmarks.num_checks_tested)',null,0,1,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('29','Total Malwares','5','3','count(distinct computers.id, malwares.id)',null,1,1,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('30','Total DLP Events','4','3','count(computers.id, dlp_rules.id)',null,1,1,0,0);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('31','Computer','6','1','computers.id','computer',0,0,0,1);
insert into report_subject_properties (id, name, report_subject_id, property_type_id, select_clause, ar_class, is_aggregate, is_default, is_enum, is_primary) values ('32','Operating System','7',1,'operating_systems.id','operating_system',0,0,0,1);

/*==============================================================*/
/* Table: report_subjects                                       */
/*==============================================================*/
create table report_subjects
(
   id                   tinyint unsigned not null,
   name                 varchar(255) not null,
   name_plural          varchar(255) not null,
   table_name           varchar(255) not null,
   primary key (id)
)
type = myisam;

insert into report_subjects (id, name, name_plural, table_name) values (1, 'Computer Group', 'Computer Groups', 'computer_groups');
insert into report_subjects (id, name, name_plural, table_name) values (2, 'Vulnerability', 'Vulnerabilities', 'vulns');
insert into report_subjects (id, name, name_plural, table_name) values (3, 'Policy', 'Policies', 'benchmarks');
insert into report_subjects (id, name, name_plural, table_name) values (4, 'DLP', 'DLP', 'dlp_rules');
insert into report_subjects (id, name, name_plural, table_name) values (5, 'Malware', 'Malwares', 'malwares');
insert into report_subjects (id, name, name_plural, table_name) values (6, 'Computer', 'Computers', 'computers');
insert into report_subjects (id, name, name_plural, table_name) values (7, 'Operating System', 'Operating Systems', 'operating_systems');
insert into report_subjects (id, name, name_plural, table_name) values (8, 'Application', 'Applications', 'apps');

/*==============================================================*/
/* Table: reports                                               */
/*==============================================================*/
create table reports
(
   id                   int unsigned not null auto_increment,
   name                 varchar(255) not null,
   next_scheduled_runtime datetime null,
   user_id              int unsigned not null,
   data                 text not null,
   primary key (id)
)
--type = myisam;

/*==============================================================*/
/* Table: roles                                                 */
/*==============================================================*/
create table roles
(
   id                   int unsigned not null auto_increment,
   name                 varchar(255) not null,
   admin                bool not null default 0,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: roles_users                                           */
/*==============================================================*/
create table roles_users
(
   role_id              int unsigned not null,
   user_id              int unsigned not null,
   primary key (role_id, user_id)
)
type = myisam;

/*==============================================================*/
/* Table: user_temp_tables                                      */
/*==============================================================*/
create table user_temp_tables
(
   id                   bigint unsigned not null auto_increment,
   user_id              int unsigned not null,
   session_id           varchar(32) not null,
   table_arguments      text null,
   table_name           varchar(64) not null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: users                                                 */
/*==============================================================*/
create table users
(
   id                   int unsigned not null auto_increment,
   name                 varchar(200) not null,
   email                varchar(200) not null,
   hashed_password      varchar(40) not null,
   username             varchar(200) not null,
   remember_token_expires_at timestamp null,
   remember_token       varchar(40) null,
   salt                 varchar(40) not null,
   primary key (id),
   unique key ak_users_key_2 (email),
   unique key ak_users_key_3 (username)
)
type = myisam;

/*==============================================================*/
/* Table: visualization_types                                   */
/*==============================================================*/
create table visualization_types
(
   id                   tinyint unsigned not null,
   name                 varchar(255) not null,
   primary key (id)
)
type = myisam;

insert into visualization_types (id, name) values (1, 'Table');
insert into visualization_types (id, name) values (3, 'Distribution');
insert into visualization_types (id, name) values (6, 'Trend');

/*==============================================================*/
/* Table: vuln_advisories                                       */
/*==============================================================*/
create table vuln_advisories
(
   id                   int unsigned not null auto_increment,
   vuln_id              int unsigned not null,
   vuln_advisory_publisher_id tinyint unsigned not null,
   advisory_id          varchar(20) not null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Index: index_1                                               */
/*==============================================================*/
create index index_1 on vuln_advisories
(
   vuln_id,
   vuln_advisory_publisher_id
);

/*==============================================================*/
/* Table: vuln_advisory_publishers                              */
/*==============================================================*/
create table vuln_advisory_publishers
(
   id                   tinyint unsigned not null auto_increment,
   name                 varchar(255) not null,
   url_prefix           varchar(255) not null,
   url_suffix           varchar(255) null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: vuln_cvss_metric_values                               */
/*==============================================================*/
create table vuln_cvss_metric_values
(
   vuln_id              int unsigned not null,
   cvss_metric_value_id tinyint unsigned not null,
   primary key (vuln_id)
)
type = myisam;

/*==============================================================*/
/* Table: vuln_remediations                                     */
/*==============================================================*/
create table vuln_remediations
(
   id                   int unsigned not null auto_increment,
   remediation_type_id  tinyint unsigned not null,
   description          varchar(255) not null,
   app_upgrade_id       smallint unsigned null,
   primary key (id)
)
type = myisam;

/*==============================================================*/
/* Table: vuln_remediations_vulns                               */
/*==============================================================*/
create table vuln_remediations_vulns
(
   vuln_id              int not null,
   vuln_remediation_id  int not null,
   primary key (vuln_id, vuln_remediation_id)
)
type = myisam;

/*==============================================================*/
/* Table: vuln_severities                                       */
/*==============================================================*/
create table vuln_severities
(
   id                   tinyint unsigned not null,
   name                 varchar(255) not null,
   primary key (id)
)
type = myisam;

insert into vuln_severities (id, name) values (1, 'Low');
insert into vuln_severities (id, name) values (2, 'Moderate');
insert into vuln_severities (id, name) values (3, 'Important');
insert into vuln_severities (id, name) values (4, 'Critical');

/*==============================================================*/
/* Table: vulns                                                 */
/*==============================================================*/
create table vulns
(
   id                   int unsigned not null auto_increment,
   name                 varchar(255) not null,
   description          text null,
   vuln_severity_id     tinyint unsigned null,
   publish_date         timestamp null,
   cvss_base_score      float null,
   cvss_temporal_score  float null,
   cvss_environmental_score float null,
   cvss_final_score     float null,
   primary key (id)
)
type = myisam;

alter table vulns comment 'currently only using cvss_base_score to compute cvss_final_s';

/*==============================================================*/
/* Table: vulns_apps                                            */
/*==============================================================*/
create table vulns_apps
(
   app_id               int unsigned not null,
   vuln_id              int unsigned not null,
   primary key (app_id, vuln_id)
)
type = myisam;

alter table vulns_apps comment 'this table isn''t really used. If anything, we can import da';

/*==============================================================*/
/* Table: vulns_bes                                             */
/*==============================================================*/
create table vulns_bes
(
   id                   bigint unsigned not null auto_increment,
   vuln_id              int unsigned not null,
   fixlet_id            bigint unsigned not null,
   bes_site_id          smallint unsigned not null,
   primary key (id),
   unique key ak_vulns_bes_key_2 (vuln_id, fixlet_id, bes_site_id)
)
type = myisam;

/*==============================================================*/
/* View: all_computer_group_distributions                       */
/*==============================================================*/
create view all_computer_group_distributions as select
                                                   id,
                                                   name,
                                                   6 as report_subject_id,
                                                   'properties' as source_table
                                                from
                                                   properties
                                                where
                                                   property_type_id = 3
                                                union
                                                select
                                                   id,
                                                   name,
                                                   report_subject_id,
                                                   'computer_group_distributions' as source_table
                                                from
                                                   computer_group_distributions;

/*==============================================================*/
/* View: all_properties                                         */
/*==============================================================*/
create view all_properties as select id, name, report_subject_id, property_type_id, 'report_subject_properties' as source_table, is_aggregate, is_default, is_enum
                              from report_subject_properties
                              union
                              select id, name, 6 as report_subject_id, property_type_id, 'properties' as source_table, 0 as is_aggregate, is_default, is_enum
                              from properties;

/*==============================================================*/
/* View: platforms                                              */
/*==============================================================*/
create view platforms as select id, name from apps
                         union
                         select id, name from operating_systems;

alter table agg_computer_groups add constraint fk_reference_67 foreign key (computer_group_id)
      references computer_groups (id) on delete restrict on update restrict;

alter table agg_computer_groups_benchmarks add constraint fk_reference_68 foreign key (agg_computer_group_id)
      references agg_computer_groups (id) on delete restrict on update restrict;

alter table agg_computer_groups_benchmarks add constraint fk_reference_69 foreign key (benchmark_id)
      references benchmarks (id) on delete restrict on update restrict;

alter table agg_computer_groups_dlp_rule_events add constraint fk_reference_73 foreign key (agg_computer_group_id)
      references agg_computer_groups (id) on delete restrict on update restrict;

alter table agg_computer_groups_dlp_rule_events add constraint fk_reference_74 foreign key (dlp_rule_id)
      references dlp_rules (id) on delete restrict on update restrict;

alter table agg_computer_groups_vulns add constraint fk_reference_70 foreign key (agg_computer_group_id)
      references agg_computer_groups (id) on delete restrict on update restrict;

alter table agg_computer_groups_vulns add constraint fk_reference_71 foreign key (vuln_id)
      references vulns (id) on delete restrict on update restrict;

alter table app_relationships add constraint fk_reference_20 foreign key (related_app_id)
      references apps (id) on delete restrict on update restrict;

alter table app_relationships add constraint fk_reference_21 foreign key (app_id)
      references apps (id) on delete restrict on update restrict;

alter table app_relationships add constraint fk_reference_22 foreign key (app_relationship_type_id)
      references app_relationship_types (id) on delete restrict on update restrict;

alter table app_upgrades add constraint fk_reference_40 foreign key (to_app_id)
      references apps (id) on delete restrict on update restrict;

alter table app_upgrades add constraint fk_reference_41 foreign key (from_app_id)
      references apps (id) on delete restrict on update restrict;

alter table apps_bes add constraint fk_reference_98 foreign key (app_id)
      references apps (id) on delete restrict on update restrict;

alter table apps_vulns add constraint fk_reference_25 foreign key (app_id)
      references apps (id) on delete restrict on update restrict;

alter table apps_vulns add constraint fk_reference_27 foreign key (vuln_id)
      references vulns (id) on delete restrict on update restrict;

alter table benchmark_check_groups add constraint fk_reference_18 foreign key (benchmark_version_id)
      references benchmark_versions (id) on delete restrict on update restrict;

alter table benchmark_check_remediations add constraint fk_reference_57 foreign key (benchmark_check_id)
      references benchmark_checks (id) on delete restrict on update restrict;

alter table benchmark_check_remediations add constraint fk_reference_58 foreign key (remediation_type_id)
      references remediation_types (id) on delete restrict on update restrict;

alter table benchmark_check_results add constraint fk_reference_34 foreign key (computer_id)
      references computers (id) on delete restrict on update restrict;

alter table benchmark_check_results add constraint fk_reference_35 foreign key (benchmark_check_id)
      references benchmark_checks (id) on delete restrict on update restrict;

alter table benchmark_checks add constraint fk_reference_17 foreign key (benchmark_version_id)
      references benchmark_versions (id) on delete restrict on update restrict;

alter table benchmark_checks add constraint fk_benchmark_checks_to_benchma foreign key (benchmark_check_group_id)
      references benchmark_check_groups (id) on delete restrict on update restrict;

alter table benchmark_platforms add constraint fk_reference_36 foreign key (benchmark_id)
      references benchmarks (id) on delete restrict on update restrict;

alter table benchmark_versions add constraint fk_reference_14 foreign key (benchmark_id)
      references benchmarks (id) on delete restrict on update restrict;

alter table computer_apps add constraint fk_reference_28 foreign key (computer_id)
      references computers (id) on delete restrict on update restrict;

alter table computer_apps add constraint fk_reference_29 foreign key (app_id)
      references apps (id) on delete restrict on update restrict;

alter table computer_benchmark_check_remediations add constraint fk_reference_61 foreign key (computer_id)
      references computers (id) on delete restrict on update restrict;

alter table computer_benchmark_check_remediations add constraint fk_reference_62 foreign key (benchmark_check_remediation_id)
      references benchmark_check_remediations (id) on delete restrict on update restrict;

alter table computer_benchmarks add constraint fk_reference_76 foreign key (computer_id)
      references computers (id) on delete restrict on update restrict;

alter table computer_benchmarks add constraint fk_reference_77 foreign key (benchmark_id)
      references benchmarks (id) on delete restrict on update restrict;

alter table computer_contact_relationships add constraint fk_reference_83 foreign key (contact_id)
      references contacts (id) on delete restrict on update restrict;

alter table computer_contact_relationships add constraint fk_reference_84 foreign key (computer_relationship_type_id)
      references computer_relationship_type (id) on delete restrict on update restrict;

alter table computer_contacts add constraint fk_reference_85 foreign key (contact_id)
      references contacts (id) on delete restrict on update restrict;

alter table computer_contacts add constraint fk_reference_86 foreign key (computer_id)
      references computers (id) on delete restrict on update restrict;

alter table computer_contacts add constraint fk_reference_87 foreign key (computer_relationship_type_id)
      references computer_relationship_type (id) on delete restrict on update restrict;

alter table computer_group_distributions add constraint fk_reference_93 foreign key (report_subject_id)
      references report_subjects (id) on delete restrict on update restrict;

alter table computer_groups_computers add constraint fk_reference_1 foreign key (computer_id)
      references computers (id) on delete restrict on update restrict;

alter table computer_groups_computers add constraint fk_reference_51 foreign key (computer_group_id)
      references computer_groups (id) on delete restrict on update restrict;

alter table computer_groups_datasource_computer_groups add constraint fk_computer_groups_datasource_ foreign key (computer_group_id)
      references computer_groups (id) on delete restrict on update restrict;

alter table computer_groups_datasource_computer_groups add constraint fk_reference_97 foreign key (datasource_computer_group_id)
      references datasource_computer_groups (id) on delete restrict on update restrict;

alter table computer_groups_roles add constraint fk_reference_80 foreign key (computer_group_id)
      references computer_groups (id) on delete restrict on update restrict;

alter table computer_groups_roles add constraint fk_reference_81 foreign key (role_id)
      references roles (id) on delete restrict on update restrict;

alter table computer_malwares add constraint fk_reference_90 foreign key (malware_id)
      references malwares (id) on delete restrict on update restrict;

alter table computer_malwares add constraint fk_reference_91 foreign key (malware_status_id)
      references malware_statuses (id) on delete restrict on update restrict;

alter table computer_malwares add constraint fk_computer_malwares_to_comput foreign key (computer_id)
      references computers (id) on delete restrict on update restrict;

alter table computer_properties add constraint fk_computer_properties_to_comp foreign key (computer_id)
      references computers (id) on delete restrict on update restrict;

alter table computer_properties add constraint fk_reference_56 foreign key (property_id)
      references properties (id) on delete restrict on update restrict;

alter table computer_vuln_remediations add constraint fk_reference_59 foreign key (computer_id)
      references computers (id) on delete restrict on update restrict;

alter table computer_vuln_remediations add constraint fk_reference_60 foreign key (vuln_remediation_id)
      references vuln_remediations (id) on delete restrict on update restrict;

alter table computer_vulns add constraint fk_reference_30 foreign key (computer_id)
      references computers (id) on delete restrict on update restrict;

alter table computer_vulns add constraint fk_reference_31 foreign key (vuln_id)
      references vulns (id) on delete restrict on update restrict;

alter table computers_datasources add constraint fk_reference_100 foreign key (datasource_id)
      references datasources (id) on delete restrict on update restrict;

alter table computers_datasources add constraint fk_reference_101 foreign key (computer_id)
      references computers (id) on delete restrict on update restrict;

alter table computers_operating_systems add constraint fk_reference_32 foreign key (operating_system_id)
      references operating_systems (id) on delete restrict on update restrict;

alter table computers_operating_systems add constraint fk_reference_33 foreign key (computer_id)
      references computers (id) on delete restrict on update restrict;

alter table contacts add constraint fk_reference_82 foreign key (user_id)
      references users (id) on delete restrict on update restrict;

alter table cvss_metric_values add constraint fk_reference_45 foreign key (cvss_metric_id)
      references cvss_metrics (id) on delete restrict on update restrict;

alter table cvss_metrics add constraint fk_reference_46 foreign key (cvss_metric_group_id)
      references cvss_metric_groups (id) on delete restrict on update restrict;

alter table dashboard_dashboard_widgets add constraint fk_reference_93 foreign key (dashboard_id)
      references dashboards (id) on delete restrict on update restrict;

alter table dashboard_dashboard_widgets add constraint fk_reference_94 foreign key (dashboard_widget_id)
      references dashboard_widgets (id) on delete restrict on update restrict;

alter table dashboard_widgets add constraint fk_reference_95 foreign key (visualization_type_id)
      references visualization_types (id) on delete restrict on update restrict;

alter table dashboard_widgets add constraint fk_reference_96 foreign key (user_id)
      references users (id) on delete restrict on update restrict;

alter table dashboards add constraint fk_reference_94 foreign key (dashboard_layout_id)
      references dashboard_layouts (id) on delete restrict on update restrict;

alter table dashboards add constraint fk_reference_92 foreign key (user_id)
      references users (id) on delete restrict on update restrict;

alter table datasource_computer_groups add constraint fk_reference_95 foreign key (datasource_id)
      references datasources (id) on delete restrict on update restrict;

alter table datasources add constraint fk_reference_88 foreign key (datasource_type_id)
      references datasource_types (id) on delete restrict on update restrict;

alter table dlp_rules add constraint fk_reference_72 foreign key (dlp_severity_id)
      references dlp_severities (id) on delete restrict on update restrict;

alter table malwares add constraint fk_reference_89 foreign key (malware_type_id)
      references malware_types (id) on delete restrict on update restrict;

alter table metric_thresholds add constraint fk_reference_90 foreign key (report_metric_id)
      references report_metrics (id) on delete restrict on update restrict;

alter table metric_thresholds add constraint fk_reference_91 foreign key (computer_group_id)
      references computer_groups (id) on delete restrict on update restrict;

alter table operating_systems_bes add constraint fk_reference_99 foreign key (operating_system_id)
      references operating_systems (id) on delete restrict on update restrict;

alter table properties add constraint fk_reference_53 foreign key (property_type_id)
      references property_types (id) on delete restrict on update restrict;

alter table properties add constraint fk_reference_89 foreign key (datasource_type_id)
      references datasource_types (id) on delete restrict on update restrict;

alter table property_type_operators add constraint fk_reference_50 foreign key (property_type_id)
      references property_types (id) on delete restrict on update restrict;

alter table report_delta_events add constraint fk_reference_55 foreign key (report_delta_type_id)
      references report_delta_types (id) on delete restrict on update restrict;

alter table report_delta_types_report_subjects add constraint fk_reference_52 foreign key (report_subject_id)
      references report_subjects (id) on delete restrict on update restrict;

alter table report_delta_types_report_subjects add constraint fk_reference_54 foreign key (report_delta_type_id)
      references report_delta_types (id) on delete restrict on update restrict;

alter table report_metrics_report_subjects add constraint fk_reference_63 foreign key (report_metric_id)
      references report_metrics (id) on delete restrict on update restrict;

alter table report_metrics_report_subjects add constraint fk_reference_64 foreign key (report_subject_id)
      references report_subjects (id) on delete restrict on update restrict;

alter table report_schedules add constraint fk_reference_99 foreign key (report_id)
      references reports (id) on delete restrict on update restrict;

alter table report_subject_properties add constraint fk_reference_47 foreign key (report_subject_id)
      references report_subjects (id) on delete restrict on update restrict;

alter table report_subject_properties add constraint fk_reference_49 foreign key (property_type_id)
      references property_types (id) on delete restrict on update restrict;

alter table reports add constraint fk_reference_98 foreign key (user_id)
      references users (id) on delete restrict on update restrict;

alter table roles_users add constraint fk_reference_78 foreign key (role_id)
      references roles (id) on delete restrict on update restrict;

alter table roles_users add constraint fk_reference_79 foreign key (user_id)
      references users (id) on delete restrict on update restrict;

alter table user_temp_tables add constraint fk_reference_103 foreign key (user_id)
      references users (id) on delete restrict on update restrict;

alter table vuln_advisories add constraint fk_reference_38 foreign key (vuln_advisory_publisher_id)
      references vuln_advisory_publishers (id) on delete restrict on update restrict;

alter table vuln_advisories add constraint fk_reference_39 foreign key (vuln_id)
      references vulns (id) on delete restrict on update restrict;

alter table vuln_cvss_metric_values add constraint fk_reference_43 foreign key (cvss_metric_value_id)
      references cvss_metric_values (id) on delete restrict on update restrict;

alter table vuln_cvss_metric_values add constraint fk_reference_44 foreign key (vuln_id)
      references vulns (id) on delete restrict on update restrict;

alter table vuln_remediations add constraint fk_reference_75 foreign key (app_upgrade_id)
      references app_upgrades (id) on delete restrict on update restrict;

alter table vuln_remediations add constraint fk_reference_9 foreign key (remediation_type_id)
      references remediation_types (id) on delete restrict on update restrict;

alter table vuln_remediations_vulns add constraint fk_reference_65 foreign key (vuln_id)
      references vulns (id) on delete restrict on update restrict;

alter table vuln_remediations_vulns add constraint fk_reference_66 foreign key (vuln_remediation_id)
      references vuln_remediations (id) on delete restrict on update restrict;

alter table vulns add constraint fk_reference_16 foreign key (vuln_severity_id)
      references vuln_severities (id) on delete restrict on update restrict;

alter table vulns_apps add constraint fk_reference_23 foreign key (app_id)
      references apps (id) on delete restrict on update restrict;

alter table vulns_apps add constraint fk_reference_24 foreign key (vuln_id)
      references vulns (id) on delete restrict on update restrict;

alter table vulns_bes add constraint fk_reference_102 foreign key (bes_site_id)
      references bes_sites (id) on delete restrict on update restrict;

alter table vulns_bes add constraint fk_reference_97 foreign key (vuln_id)
      references vulns (id) on delete restrict on update restrict;

