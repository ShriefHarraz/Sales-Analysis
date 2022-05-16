----inspecting full data -----

SELECT *
FROM [dbo].[sales_data]

---checking our Uniqe Values -----
select distinct status from [dbo].[sales_data];---nice to plot ----
select distinct YEAR_ID from [dbo].[sales_data];
select distinct PRODUCTLINE from [dbo].[sales_data];---nice to plot ----
select distinct COUNTRY from [dbo].[sales_data];---nice to plot ----
select distinct DEALSIZE from [dbo].[sales_data];---nice to plot ----
select distinct TERRITORY from [dbo].[sales_data];---nice to plot ----

   -------------- GENERAL ANALYSIS ----------
---- Q1 which product is selling the most ---

select PRODUCTLINE, sum(sales) REVENUE
from [dbo].[sales_data]
group by PRODUCTLINE
order by 2 DESC;

---- Q2 which YEAR is selling the most ---

select YEAR_ID, sum(sales) REVENUE
from [dbo].[sales_data]
group by YEAR_ID
order by 2 DESC;

--- WHY 2005 IS THE LESS SALE ----
select MONTH_ID
from [dbo].[sales_data]
WHERE YEAR_ID = 2005
GROUP BY MONTH_ID
ORDER BY 1  ---   THE DATA THAT I HAVE FOR 2005 IS ONLY FOR 5 MONTHS ---

---- Q3 which DEALSIZE is selling the most ---

select DEALSIZE, sum(sales) REVENUE
from [dbo].[sales_data]
group by DEALSIZE
order by 2 DESC;

---- Q4 which COUNTRY is selling the most ---

select COUNTRY, sum(sales) REVENUE
from [dbo].[sales_data]
group by COUNTRY
order by 2 DESC;


 ---- Q5 WHICH MONTH IS SELLING THE MOST IN A SPACIFIC YEAR -----

 SELECT MONTH_ID,SUM(SALES) REVENUE, COUNT(ORDERNUMBER) FREQUENCY
 FROM[dbo].[sales_data]
 WHERE YEAR_ID = 2003 --- YOU CAN CHANGE ONLY THE YEAR ---
 GROUP BY MONTH_ID
 ORDER BY 2 DESC;

  ---- Q6 WHICH PRODUCTLINE IN THE MONTH OF NOV(THE HIGHEST MONTH FOR SALES) IS SELLING THE MOST IN A SPACIFIC YEAR -----

 SELECT PRODUCTLINE, SUM(SALES) REVENUE, COUNT(ORDERNUMBER) FREQUENCY
 FROM[dbo].[sales_data]
 WHERE YEAR_ID = 2004 AND MONTH_ID = 11 --- YOU CAN CHANGE ONLY THE YEAR ---
 GROUP BY PRODUCTLINE
 ORDER BY 2 DESC;

 ------ EXPLORING OUR BEST CUSTOMERS USING RFM ANALYSIS (RECENCY, FREQUENCY & MONETARY )----

 DROP TABLE IF EXISTS #RFM
 ;WITH RFM AS
 (
 SELECT CUSTOMERNAME, 
 SUM(SALES) MONETARY,
 AVG(SALES) AVG_SALES,
 COUNT(ORDERNUMBER) FREQUENCY,
 MAX(ORDERDATE) LASTORDERDATE,
 (SELECT MAX(ORDERDATE)FROM[dbo].[sales_data])MAX_DATE,
 DATEDIFF(DAY, MAX(ORDERDATE),(SELECT MAX(ORDERDATE)FROM[dbo].[sales_data])) RECENCY
 FROM[dbo].[sales_data]
 GROUP BY CUSTOMERNAME
 ),
 rfm_seg as 
 (
 SELECT *,
 NTILE(3) OVER(ORDER BY RECENCY desc  ) RFM_RECENCY,
 NTILE(3) OVER(ORDER BY FREQUENCY) RFM_FREQUENCY,
 NTILE(3) OVER(ORDER BY MONETARY  ) RFM_MONETARY
 FROM RFM
 )
 select *, RFM_RECENCY + RFM_FREQUENCY + RFM_MONETARY as RFM_CELL
 INTO #RFM
 from rfm_seg

 ------  Customer Segmentation analysis using the RFM technique ----
 SELECT customername, RFM_CELL,
 CASE 
 WHEN RFM_CELL = 9 THEN 'loyal customer'
 WHEN RFM_CELL >= 6 and RFM_CELL <= 8 THEN 'Mid customers'
 WHEN Rfm_CELL >= 3 and RFM_CELL <6 THEN 'low loyal customer'
 end CUSTOMER_SEG
 FROM #RFM
 ORDER BY 2 DESC

                             ------- WHICH PRODUCTS ARE MOSTLY SELLING TOGETHER ---
 ----- DOWN THERE I MADE THE MOST TWO PRODUCTS SELLING TOGETHER WE CAN CHANGE IT EASILY TO ANY NUMBER THAT WE WANT-----

 select distinct (ordernumber), stuff(
(
 select ',' + productcode
 from [dbo].[sales_data]s
 where ordernumber in 
 (
     select ordernumber
      from 
     (
     select  ordernumber, count (productcode) totalproduct_per_order 
      from [dbo].[sales_data]
      where STATUS = 'shipped' 
     group by ordernumber
     )sh
       where totalproduct_per_order = 2  ---- HERE YOU CAN CJANGE TO 3 OR 4 OR ETC PRODUCTS ----
 ) and s.ORDERNUMBER = r.ORDERNUMBER
 for xml path ('')), 1,1,' ') productscodes
 from [dbo].[sales_data]r
 order by productscodes DESC




 





