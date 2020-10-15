begin;
delete from computer_groups;

-- root entries
insert into computer_groups (id, name, parent_id) values (1, 'By Location', NULL);
insert into computer_groups (id, name, parent_id) values (2, 'By Function', NULL);
--insert into computer_groups (id, name, parent_id) values (3, 'By Owner', NULL);
insert into computer_groups (id, name, parent_id) values (4, 'By Business Unit', NULL);

-- location based entries
insert into computer_groups (id, name, parent_id) values (5, 'North America', 1);
insert into computer_groups (id, name, parent_id) values (6, 'EMEA', 1);
insert into computer_groups (id, name, parent_id) values (7, 'Asia Pacific', 1);
insert into computer_groups (id, name, parent_id) values (8, 'United States', 5);
insert into computer_groups (id, name, parent_id) values (9, 'Canada', 5);
insert into computer_groups (id, name, parent_id) values (10, 'San Francisco', 8);
insert into computer_groups (id, name, parent_id) values (11, 'New York', 8);
insert into computer_groups (id, name, parent_id) values (12, 'Los Angeles', 8);
insert into computer_groups (id, name, parent_id) values (13, 'Chicago', 8);
insert into computer_groups (id, name, parent_id) values (14, 'Boston', 8);
insert into computer_groups (id, name, parent_id) values (15, 'Toronto', 9);
insert into computer_groups (id, name, parent_id) values (16, 'Montreal', 9);
insert into computer_groups (id, name, parent_id) values (17, 'Vancouver', 9);
insert into computer_groups (id, name, parent_id) values (18, 'Great Britain', 6);
insert into computer_groups (id, name, parent_id) values (19, 'Germany', 6);
insert into computer_groups (id, name, parent_id) values (20, 'France', 6);
insert into computer_groups (id, name, parent_id) values (21, 'London', 18);
insert into computer_groups (id, name, parent_id) values (22, 'Glasgow', 18);
insert into computer_groups (id, name, parent_id) values (23, 'LiverPool', 18);
insert into computer_groups (id, name, parent_id) values (24, 'Edinburgh', 18);
insert into computer_groups (id, name, parent_id) values (25, 'Manchester', 18);
insert into computer_groups (id, name, parent_id) values (26, 'Berlin', 19);
insert into computer_groups (id, name, parent_id) values (27, 'Hamburg', 19);
insert into computer_groups (id, name, parent_id) values (28, 'Frankfurt', 19);
insert into computer_groups (id, name, parent_id) values (29, 'Hannover', 19);
insert into computer_groups (id, name, parent_id) values (30, 'Paris', 20);
insert into computer_groups (id, name, parent_id) values (31, 'Marseille', 20);
insert into computer_groups (id, name, parent_id) values (32, 'Lyon', 20);
insert into computer_groups (id, name, parent_id) values (33, 'Toulouse', 20);
insert into computer_groups (id, name, parent_id) values (34, 'Nice', 20);
insert into computer_groups (id, name, parent_id) values (35, 'Tokyo', 7);
insert into computer_groups (id, name, parent_id) values (36, 'Hong Kong', 7);
insert into computer_groups (id, name, parent_id) values (37, 'Taipei', 7);
insert into computer_groups (id, name, parent_id) values (38, 'Sydney', 7);
insert into computer_groups (id, name, parent_id) values (39, 'Beijing', 7);

-- functional entries
insert into computer_groups (id, name, parent_id) values (40, 'Desktops', 2);
insert into computer_groups (id, name, parent_id) values (41, 'Servers', 2);
insert into computer_groups (id, name, parent_id) values (42, 'Infrastructure', 2);
insert into computer_groups (id, name, parent_id) values (43, 'Printers', 2);
insert into computer_groups (id, name, parent_id) values (44, 'Tethered', 40);
insert into computer_groups (id, name, parent_id) values (45, 'Mobile', 40);
insert into computer_groups (id, name, parent_id) values (46, 'CRM', 41);
insert into computer_groups (id, name, parent_id) values (47, 'Financial', 41);
insert into computer_groups (id, name, parent_id) values (48, 'HR', 41);
insert into computer_groups (id, name, parent_id) values (49, 'Operations', 41);
insert into computer_groups (id, name, parent_id) values (50, 'Engineering', 41);
insert into computer_groups (id, name, parent_id) values (51, 'External Presence', 41);

-- Business Unit
insert into computer_groups (id, name, parent_id) values (52, 'Lending', 4);
insert into computer_groups (id, name, parent_id) values (53, 'Corporate Banking', 4);
insert into computer_groups (id, name, parent_id) values (54, 'Peronsal Banking', 4);
insert into computer_groups (id, name, parent_id) values (55, 'Leasing', 4);
insert into computer_groups (id, name, parent_id) values (56, 'Credit', 4);
insert into computer_groups (id, name, parent_id) values (57, 'Refinance', 4);

commit;