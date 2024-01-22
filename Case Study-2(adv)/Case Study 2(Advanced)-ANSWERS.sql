--SQL Advance Case Study


--Q1--BEGIN 
	select distinct State from FACT_TRANSACTIONS as t1
join DIM_LOCATION as t2 on t1.IDLocation=t2.IDLocation
where year(t1.Date)>=2005
--Q1--END

--Q2--BEGIN
	select top 1 State, sum(Quantity) as QTY from FACT_TRANSACTIONS t1
join DIM_LOCATION t2 on t1.IDLocation=t2.IDLocation
join DIM_MODEL t3 on t1.IDModel=t3.IDModel
join DIM_MANUFACTURER t4 on t3.IDManufacturer=t4.IDManufacturer
where Manufacturer_Name='Samsung' and Country='US'
group by State
order by sum(Quantity) desc
--Q2--END

--Q3--BEGIN      
	
select State, ZipCode, Model_Name,Manufacturer_Name, 
       count(Quantity) [Number of Transactions] from FACT_TRANSACTIONS t1
join DIM_LOCATION t2 on t1.IDLocation=t2.IDLocation
join DIM_MODEL t3 on t1.IDModel=t3.IDModel
join DIM_MANUFACTURER t4 on t3.IDManufacturer=t4.IDManufacturer
group by State, ZipCode,Manufacturer_Name, Model_Name

--Q3--END

--Q4--BEGIN
select top 1 IDModel, Model_Name, Manufacturer_Name,Unit_price from DIM_MODEL as t1
join DIM_MANUFACTURER t4 on t1.IDManufacturer=t4.IDManufacturer
order by t1.Unit_price
--Q4--END

--Q5--BEGIN
select t1.[IDModel],Manufacturer_Name,sum(Quantity) [Quantity sold],avg([TotalPrice]) [avg price] from FACT_TRANSACTIONS as t1
join DIM_model t2 on t1.IDModel=t2.IDModel
join DIM_MANUFACTURER t3 on t2.IDManufacturer=t3.IDManufacturer
where Manufacturer_Name in (select top 5 Manufacturer_Name from FACT_TRANSACTIONS as t1
                            join DIM_MODEL as t2 on t1.IDModel=t2.IDModel
                            join DIM_MANUFACTURER as t3 on t3.IDManufacturer=t2.IDManufacturer
                            group by Manufacturer_Name
                            order by sum(Quantity) desc)
group by Manufacturer_Name, t1.[IDModel]
order by [avg price] desc
--Q5--END

--Q6--BEGIN
select t1.IDCustomer,t2.Customer_Name, avg ([TotalPrice]) as average from FACT_TRANSACTIONS as t1
join [dbo].[DIM_CUSTOMER] as t2 on t1.IDCustomer=t2.IDCustomer
where year(date)=2009
group by t1.IDCustomer,t2.Customer_Name
having (sum(totalprice)/count(quantity)) > 500
order by average desc
--Q6--END
	
--Q7--BEGIN  
select * from (select top 5 IDModel from FACT_TRANSACTIONS
where year(date)='2008'
group by IDModel
order by sum(quantity) desc) as X
intersect
select * from (select top 5  IDModel from FACT_TRANSACTIONS
where year(date)='2009'
group by IDModel
order by sum(quantity) desc) as Y
intersect
select * from (select top 5 IDModel from FACT_TRANSACTIONS
where year(date)='2010'
group by IDModel
order by sum(quantity) desc) as Z	
	

--Q7--END	

--Q8--BEGIN
select top 1* from
      (select top 1* from
                (select top 2 Manufacturer_Name, sum(totalprice) as sales from FACT_TRANSACTIONS t1
                left join DIM_MODEL t2 on t1.IDModel=t2.IDModel
                left join DIM_MANUFACTURER t3 on t2.IDManufacturer=t3.IDManufacturer
                where year(date)='2009'
                group by Manufacturer_Name
                order by sum(totalprice) desc) as x
      order by sales) xx
union
select top 1* from
      (select top 1* from
                (select top 2 Manufacturer_Name, sum(totalprice) as sales from FACT_TRANSACTIONS t1
                left join DIM_MODEL t2 on t1.IDModel=t2.IDModel
                left join DIM_MANUFACTURER t3 on t2.IDManufacturer=t3.IDManufacturer
                where year(date)='2010'
                group by Manufacturer_Name
                order by sum(totalprice) desc) as y
      order by sales) yy


--Q8--END
--Q9--BEGIN
	select Manufacturer_Name, sum(totalprice) as sales from FACT_TRANSACTIONS t1
                left join DIM_MODEL t2 on t1.IDModel=t2.IDModel
                left join DIM_MANUFACTURER t3 on t2.IDManufacturer=t3.IDManufacturer
                where year(date)='2010' and Manufacturer_Name not in (select Manufacturer_Name from FACT_TRANSACTIONS t1
                left join DIM_MODEL t2 on t1.IDModel=t2.IDModel
                left join DIM_MANUFACTURER t3 on t2.IDManufacturer=t3.IDManufacturer
                where year(date)='2009' 
                group by Manufacturer_Name
                )
                group by Manufacturer_Name
                order by sum(totalprice) desc
--Q9--END

--Q10--BEGIN
select *, ((avg_price-lag_price)/lag_price) as percentage_change from(
    select *, lag(avg_price,1) over (partition by IDCustomer order by year) as lag_price from(
          Select IDCustomer,year([Date]) as year, avg(TotalPrice) as avg_price, sum(Quantity) 
          as total from [dbo].[FACT_TRANSACTIONS]
          where IDCustomer in (Select top 10 IDCustomer from [dbo].[FACT_TRANSACTIONS]
                                group by IDCustomer
                                order by sum(TotalPrice) desc)
     group by IDCustomer, year([Date])) as X) 
as Y
	

--Q10--END
	