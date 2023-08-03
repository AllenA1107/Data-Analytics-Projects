# Data analysis on HR Employee Attrition 
create database project;
use project;

select * from employee_attrition ;

# 1.Write a SQL query to find the details of the employees under attrition having 5+ years of experience in between age group of 27 - 35
select *
from employee_attrition
where age between 27 and 35 
and totalworkingyears >= 5;

# 2.Fetch the details of employees having maximum and minimum salary working in different departments who received less than 13% salary hike

select max(monthlyincome) as max_salary , min(monthlyincome) as min_salary , department 
from employee_attrition
where percentsalaryhike < 13
group by department;

# 3.Calculate the average income of all the employees who worked more than 3 years and whose education background is medical

select avg(monthlyincome)
from employee_attrition
where yearsatcompany > 3
and educationfield = 'medical'
group by educationfield;

# 4.Itendify the total no of males and females employees under attrition and marital status is married and havent received promotion in last 2 years

select gender,count(employee_id)
from employee_attrition
where maritalstatus = 'married'
and yearssincelastpromotion = 2
and attrition = 'yes'
group by gender;

# 5.Employees with max performance rating but no promotion for 4 years and above

select *
from employee_attrition
where performancerating = (select max(performancerating) from employee_attrition )
and yearssincelastpromotion >= 4 ;

# 6.Who has max and min percentage of salary hike

select yearsatcompany , performancerating , yearssincelastpromotion ,
	max(percentsalaryhike),
    min(percentsalaryhike)
from employee_attrition 
group by yearsatcompany , performancerating , yearssincelastpromotion 
order by max(percentsalaryhike) desc,
    min(percentsalaryhike) asc;
    
# 7.Employees working overtime but given min salary hike and are more than 5 yrs with the company

select *
from employee_attrition
where overtime = 'yes'
and percentsalaryhike = (select min(percentsalaryhike) from employee_attrition)
and yearsatcompany > 5 ;

# 8.Employees working overtime but given max salary hike and are less than 3 yrs with the company

select *
from employee_attrition
where overtime = 'yes'
and percentsalaryhike = (select max(percentsalaryhike) from employee_attrition)
and yearsatcompany  < 3 ;

# 9.Employees not working overtime but given max salary hike and are more than 5 yrs with the company

select *
from employee_attrition
where overtime = 'no'
and percentsalaryhike = (select max(percentsalaryhike) from employee_attrition)
and yearsatcompany > 5 ;

# 10.Employees working more than the average hourly rate but given min salary hike

select *
from employee_attrition
where percentsalaryhike = (select min(percentsalaryhike) from employee_attrition)
and hourlyrate > (select avg(hourlyrate) from employee_attrition);

# 11.Fetech the employees who travel frequenty whose total working years more than 5 yrs

select *
from employee_attrition
where businesstravel = 'travel_frequently'
and totalworkingyears > 5;

# 12.Fetch Employees with max job satisfaction and years at work more than 5

select *
from employee_attrition
where jobsatisfaction = (select max(jobsatisfaction) from employee_attrition)
and yearsatcompany >= 5;

# 13.Calculate the average income of all the employees whose education is more than 2 and based on education background 

select educationfield , avg(monthlyincome)
from employee_attrition
where education > 2
group by educationfield;