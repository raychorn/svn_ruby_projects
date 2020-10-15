drop database if exists pomodo_development;
create database pomodo_development;
drop database if exists pomodo_test;
create database pomodo_test;
drop database if exists pomodo_production;
create database pomodo_production;
GRANT ALL PRIVILEGES ON pomodo_development.*
  TO 'pomodo'@'localhost'
  IDENTIFIED BY 'YourPasswordHere' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON pomodo_test.* TO 'pomodo'@'localhost'
  IDENTIFIED BY 'YourPasswordHere' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON pomodo_production.*
  TO 'pomodo'@'localhost'
  IDENTIFIED BY 'YourPasswordHere' WITH GRANT OPTION;