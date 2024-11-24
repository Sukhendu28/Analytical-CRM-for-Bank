-- 	Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)
select g.GeographyLocation, count(b.CustomerId) as ActiveCustomer
from bankcrm.geography g 
join bankcrm.customerinfo c on g.GeographyID = c.GeographyID
join bankcrm.bank_churn b on c.CustomerId = b.CustomerId
where b.Tenure > 5 AND b.IsActiveMember = 1
group by 1
order by activecustomer desc
limit 1; 

-- 11.	Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it.

select extract(year from Bank_DOJ_UPDATED) as JoinYear,
extract(month from Bank_DOJ_UPDATED) AS JoinMonth,
count(CustomerId) as TotalCustomers
from bankcrm.customerinfo
group by 1, 2
order by 1, 2 ;

-- Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. Also, rank the gender according to the average value. (SQL)

with cte as (
SELECT gy.GeographyLocation, g.GenderCategory, round(AVG(c.EstimatedSalary),2) AS averageIncome
from bankcrm.customerinfo c 
join bankcrm.gender g on c.GenderID = g.GenderID
JOIN bankcrm.geography gy on c.GeographyID = gy.GeographyID
group by 1, 2)
select GeographyLocation, GenderCategory, averageIncome, dense_rank() over(partition by GeographyLocation order by averageIncome desc) as genderRanking
from cte ;

-- Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).

select 
case when c.Age BETWEEN 18 AND 30 THEN 'Young'
	when c.Age BETWEEN 31 AND 50 THEN 'MiddleAged'
    when c.Age >50 then 'OldAged' end as AgeBracket,
    avg(b.tenure) as avgTenure
from bankcrm.customerinfo c join 
bankcrm.bank_churn b on c.CustomerId = b.CustomerId
where b.Exited = 1
group by 1 ; 

-- According to the age buckets find the number of customers who have a credit card. 
-- Also retrieve those buckets that have lesser than average number of credit cards per bucket.

with cte as 
(select
case when c.Age between 18 and 30 then 'Young'
	when c.Age between 31 and 50 then 'MiddleAged'
    when c.Age > 50 then 'Old' end as AgeBucket,
count(b.CustomerId) as NoOfCustomer
from bankcrm.customerinfo c
join bankcrm.bank_churn b on c.CustomerId = b.CustomerId
where b.HasCrCard = 1
group by 1)
select *
from cte where NoOfCustomer < (select avg(NoOfCustomer) from cte) ;

-- Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.

select *,
case when Exited = 1 then 'Exit' else 'Retain' end as ExitCategory
from bankcrm.bank_churn;

-- 25.	Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.

select c.CustomerId, c.Surname,
case when b.IsActiveMember = 1 then 'Active' else 'Inactive'end as ActiveStatus
from bankcrm.customerinfo c 
join bankcrm.bank_churn b on c.CustomerId = b.CustomerId
where c.Surname like '%on'
order by c.Surname ;

-- Calculate the average number of products used by customers who have a credit card. (SQL)
select avg(NumOfProducts) as avgPrCrCard
 from bankcrm.bank_churn
where HasCrCard = 1 ;

-- Compare the average credit score of customers who have exited and those who remain. (SQL)
select Exited, avg(CreditScore) as avgCreditScore
from bankcrm.bank_churn
group by 1;

-- 6.	Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
select g.GenderCategory, count(c.CustomerId) as ActiveAcoounts,  round(avg(EstimatedSalary),2) as AvgSalary
from bankcrm.customerinfo c
left join  bankcrm.bank_churn b on c.CustomerId = b.CustomerId
JOIN bankcrm.gender g ON c.GenderID = g.GenderID
where b.IsActiveMember = 1
group by 1;

-- 	Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)

with cte as 
(select CustomerId, Exited, CreditScore,
case when CreditScore between 350 and 400 then 'Very Poor'
when CreditScore between 401 and 500 then 'Poor'
when CreditScore between 501 and 600 then 'Fair'
when CreditScore between 601 and 700 then 'Good'
when CreditScore between 701 and 800 then 'Very Good'
when CreditScore > 800 then 'Excellent' end as CreditSegment
from bankcrm.bank_churn)
select CreditSegment, round(sum(Exited)/(select sum(Exited) from cte),2)*100 AS ExitRate
from cte
group by 1
order by ExitRate desc limit 1;

/* Utilize SQL queries to segment customers based on demographics and account details.*/
SELECT gy.GeographyLocation, ge.GenderCategory,
CASE WHEN c.EstimatedSalary< 25000 then "Low Salary"
	 when c.EstimatedSalary < 50000 THEN "Low Mid Salary"
     when c.EstimatedSalary < 100000 then "High Mid Salary"
     else "High Salary" end as Salary_Segment,
case when c.age <= 30 then "Young"
	when c.age between 31 and 50 then "Middle aged"
    else "Old" end as Age_Segment,
     count(c.CustomerId) as No_Of_Customer
from bankcrm.customerinfo c 
join bankcrm.geography gy on c.GeographyID = gy.GeographyID
JOIN bankcrm.gender ge on c.GenderID = ge.GenderID
group by 1,2,3,4
order by 1,4;

alter table bankcrm.bank_churn
rename column HasCrCard to Has_creditcard;

-- Query to add column : 
alter table bankcrm.customerinfo
add column Bank_DOJ_UPDATED DATE;
-- Query to update column: 
UPDATE bankcrm.customerinfo 
SET Bank_DOJ_UPDATED = STR_TO_DATE(`Bank DOJ`, '%d-%m-%Y');

select customerID, Surname, EstimatedSalary
from bankcrm.customerinfo
where extract(quarter from Bank_DOJ_Updated) = 4
order by EstimatedSalary desc limit 5 ;



 




























