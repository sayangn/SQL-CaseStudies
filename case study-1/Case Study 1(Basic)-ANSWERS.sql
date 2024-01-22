--DATA PREPARATION AND UNDERSTANDING

--Q1
select count(*) as [The Count of Rows] from TRANSACTIONS
union
select count(*) from PROD_CAT_INFO
union
select count(*) from CUSTOMER
--END

--Q2
Select count(*) as [Total Number of Return] from TRANSACTIONS
Where RATE<0
--END

--Q3
select convert(date,tran_date,103) as tran_dat_nw from TRANSACTIONS
--END

--Q4
select datediff(year,min(convert(date,tran_date,103)),max(convert(date,tran_date,103))) as year,
       datediff(month,min(convert(date,tran_date,103)),max(convert(date,tran_date,103))) as month,
       datediff(day,min(convert(date,tran_date,103)),max(convert(date,tran_date,103))) as day
     from TRANSACTIONS
--END

--Q5
select PROD_CAT as [DIY is present in]
FROM PROD_CAT_INFO
WHERE PROD_SUBCAT = 'DIY'
--END

--DATA ANALYSIS


--Q1
select top 1 store_type as [Different Channels], 
      count(store_type) as [Count of Different Channels] 
      from Transactions
group by store_type
order by [Count of Different Channels] desc
--END


--Q2
Select gender as GENDER, count(gender) as [COUNT OF GENDER] from customer
where gender != 'null'
group by gender
order by count(gender) desc
--END


--Q3
select top 1 city_code as [Code of the City] , count(city_code) as [Count of Customers] from customer
group by city_code
order by [Count of Customers] desc
--END

--Q4
select distinct prod_subcat as [Subcategories of Books] from PROD_CAT_INFO
where PROD_CAT = 'books'
--END

--Q5
select [PROD_CAT_CODE],max(TRANSACTIONS.QTY) as [Maximum Quantity] from TRANSACTIONS
group by [PROD_CAT_CODE]
--END

--Q6
select t2.prod_cat as [Product Category], 
                sum(t1.total_amt) as [Total Revenue] from TRANSACTIONS t1
join PROD_CAT_INFO t2 on t1.PROD_CAT_CODE=t2.PROD_CAT_CODE
Where PROD_CAT in ('electronics','books')
group by t2.prod_cat
--END

--Q7
Select count(*) from (
           select t1.CUST_ID from TRANSACTIONS t1
           where t1.qty>0
           group by t1.CUST_ID
           having count(t1.qty)>10) as t2
--END

--Q8
select sum(t1.total_amt) as [Total Revenue] from TRANSACTIONS t1
left join PROD_CAT_INFO t2 on t1.PROD_CAT_CODE=t2.PROD_CAT_CODE and t1.PROD_SUBCAT_CODE=t2.PROD_SUB_CAT_CODE
where (t2.prod_cat='Electronics' or t2.prod_cat='clothing') and t1.STORE_TYPE='Flagship store' and t1.QTY>0
--END

--Q9
select t2.PROD_SUBCAT Sub_category, sum(t1.total_amt) as Revenue from TRANSACTIONS t1
join PROD_CAT_INFO t2 on t1.PROD_CAT_CODE=t2.PROD_CAT_CODE and t1.PROD_SUBCAT_CODE=t2.PROD_SUB_CAT_CODE
join CUSTOMER t3 on t1.CUST_ID=t3.CUSTOMER_ID
where t3.GENDER='M' and t2.prod_cat='Electronics'
group by t2.PROD_SUBCAT
--END

--Q10
Select Sales.PROD_SUBCAT,[%Total Sales],[%Total Return] from 
  (select top 5 t2.PROD_SUBCAT, sum(t1.TOTAL_AMT) as [Total Sales], 
  (cast((sum(t1.TOTAL_AMT)*100) as float)/(select sum(TOTAL_AMT) from TRANSACTIONS where qty>0)) as [%Total Sales] 
  from TRANSACTIONS t1
  join PROD_CAT_INFO as t2 
  on t1.PROD_CAT_CODE=t2.PROD_CAT_CODE and t1.PROD_SUBCAT_CODE=t2.PROD_SUB_CAT_CODE
  where t1.qty>0
  group by t2.PROD_SUBCAT
  order by [%Total Sales] desc) as Sales
join
  (select t2.PROD_SUBCAT, sum(t1.TOTAL_AMT) as [Total Return], 
  (cast((sum(t1.TOTAL_AMT)*100) as float)/(select sum(TOTAL_AMT) from TRANSACTIONS where qty<0)) as [%Total Return] 
  from TRANSACTIONS t1
  join PROD_CAT_INFO as t2 
  on t1.PROD_CAT_CODE=t2.PROD_CAT_CODE and t1.PROD_SUBCAT_CODE=t2.PROD_SUB_CAT_CODE
  where t1.qty<0
  group by t2.PROD_SUBCAT)
  as returns
  on sales.PROD_SUBCAT=returns.PROD_SUBCAT
--END

--Q11
Select t5.CUST_ID, age from (
Select * from
(select t3.CUST_ID, datediff(year,dob,[Last Transaction]) as age from 
(SELECT t1.CUST_ID,convert(date,t2.DOB,103) as dob,max(convert(date,t1.[TRAN_DATE],103)) as [Last Transaction] from [dbo].[TRANSACTIONS] as t1
join [dbo].[CUSTOMER] as t2 on t1.CUST_ID=t2.CUSTOMER_ID
group by t1.CUST_ID,t2.DOB) as t3) as t4
where age between 25 and 35) as t5
join (select CUST_ID from TRANSACTIONS
where convert(date,[TRAN_DATE],103) 
>= (select DATEADD(day,-30, max(convert(date,[TRAN_DATE],103))) from TRANSACTIONS)) as t6 on
t5.CUST_ID=t6.CUST_ID
--END

--Q12
select top 1 PROD_CAT_CODE,sum(qty) [Total Returns] from TRANSACTIONS
where QTY<0 and convert(date,[TRAN_DATE],103) >= (select DATEADD(month,-3, max(convert(date,[TRAN_DATE],103))) from TRANSACTIONS)
group by PROD_CAT_CODE
order by sum(qty)
--END

--Q13
Select STORE_TYPE, sum(total_amt) Total_Sales ,sum(qty) Total_Quantity from TRANSACTIONS
where QTY>0
group by STORE_TYPE
Order by sum(total_amt) desc
--END

--Q14
select PROD_CAT_CODE, AVG([TOTAL_AMT]) avg from TRANSACTIONS
where QTY>0
group by PROD_CAT_CODE
having AVG([TOTAL_AMT])>(select AVG([TOTAL_AMT]) avg from TRANSACTIONS where QTY>0)
--END

--Q15
select top 5 * from 
(select PROD_CAT_CODE, PROD_SUBCAT_CODE, AVG([TOTAL_AMT]) avg, SUM([TOTAL_AMT]) sum , sum([QTY]) quantity from TRANSACTIONS
where QTY>0
group by PROD_CAT_CODE, PROD_SUBCAT_CODE) as t1
order by t1.quantity desc
--END
