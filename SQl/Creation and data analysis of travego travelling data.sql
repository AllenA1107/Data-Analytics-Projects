-- Creation and data analysis of travego travelling data

/* 1. Creating the schema and required tables using MySQL workbench
a. Create a schema named Travego and create the tables mentioned above with the mentioned
column names. Also, declare the relevant datatypes for each feature/column in the dataset.
b. Insert the data in the newly created tables.*/
show schemas;
create schema if not exists Travego;
use Travego;
drop table Travego.passenger;
drop table Travego.price;
create table IF NOT exists passenger(
passenger_id int not null primary key,
passenger_name varchar(20),
category varchar(20),
GENDER VARCHAR(20),
boarding_city varchar(20),
destination_city varchar(20),
distance int,
bus_type varchar(20)
);
create table price(
id int not null primary key,
bus_type varchar(20),
distance int,
price int
);

insert into passenger values
(1,'Sejal','AC','F','Bengaluru','Chennai',350,'Sleeper'),
(2,'Anmol','Non-AC','M','Mumbai','Hyderabad',700,'Sitting'),
(3,'Pallavi','AC','F','Panaji','Bengaluru',600,'Sleeper'),
(4,'Khusboo','AC','F','Chennai','Mumbai',1500,'Sleeper'),
(5,'Udit','Non-AC','M','Trivandrum','Panaji',1000,'Sleeper'),
(6,'Ankur','AC','M','Nagpur','Hyderabad',500,'Sitting'),
(7,'Hemant','Non-AC','M','Panaji','Mumbai',700,'Sleeper'),
(8,'Manish','Non-AC','M','Hyderabad','Bengaluru',500,'Sitting'),
(9,'Piyush','AC','M','Pune','Nagpur',700,'Sitting');

insert into price values
(1,'Sleeper',350,770),
(2,'Sleeper',500,1100),
(3,'Sleeper',600,1320),
(4,'Sleeper',700,1540),
(5,'Sleeper',1000,2200),
(6,'Sleeper',1200,2640),
(7,'Sleeper',1500,2700),
(8,'Sitting',500,620),
(9,'Sitting',600,744),
(10,'Sitting',700,868),
(11,'Sitting',1000,1240),
(12,'Sitting',1200,1488),
(13,'Sitting',1500,1860)
;
SELECT * FROM passenger;
select * from price;

-- a.How many female passengers traveled a minimum distance of 600 KMs?
select *
from passenger where gender = 'f' and distance >= 600;

-- b.Write a query to display the passenger details whose travel distance is greater than 500 and who are traveling in a sleeper bus.
select *
from passenger where bus_type = 'sleeper'and distance >= 500;

-- c.Select passenger names whose names start with the character 'S'.
select *
from passenger where passenger_name like 's%';

-- d.Calculate the price charged for each passenger, displaying the Passenger name, Boarding City,Destination City, Bus type, and Price in the output.
select p.passenger_name , p.boarding_city , p.destination_city , p.bus_type , r.price
from passenger p left join price r on p.bus_type = r.bus_type
and p.distance=r.distance;

-- e.What are the passenger name(s) and the ticket price for those who traveled 1000 KMs Sitting in a bus?
select p.passenger_name, p.bus_type , r.price
from passenger p left join price r on p.bus_type = r.bus_type
and p.distance=r.distance
where p.distance = 1000 and p.bus_type = 'sitting';

-- f.What will be the Sitting and Sleeper bus charge for Pallavi to travel from Bangalore to Panaji?
select p.passenger_name , p.boarding_city , p.destination_city , p.bus_type , r.price
from passenger p left join price r on p.bus_type = r.bus_type
and p.distance=r.distance
where passenger_name = 'pallavi';

-- g.Alter the column category with the value "Non-AC" where the Bus_Type is sleeper.
update passenger 
set category = 'Non_AC' 
where category = 'sleeper';

update price
set category = 'Non_AC' 
where category = 'sleeper';

select * from passenger;

-- h.Delete an entry from the table where the passenger name is Piyush and commit this change in the database.
set auto_commit = 0;
delete from passenger where passenger_name = 'piyush';
commit;
select * from passenger;

-- i.Truncate the table passenger and comment on the number of rows in the table (explain if required).
truncate passenger;
select * from passenger;
-- Truncate removes every values in the table only the schema remains .

-- j.Delete the table passenger from the database.
drop table passenger;