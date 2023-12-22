#Added column revenue
ALTER Table sales
ADD COLUMN Revenue Decimal(10,2);
UPDATE sales
SET Revenue = qty*price* (1 - discount/100);

#added column discount_amount
ALTER Table sales
ADD COLUMN Discount_amount Decimal(10,2);
UPDATE sales
SET Discount_amount = qty*price*discount/100

#1.What was the total quantity sold for all products?
select SUM(qty) as total_qty from sales;

#2.What is the total generated revenue for all products before discounts?
SELECT SUM(qty * price) as revenue_before_discount 
from sales;

#3.What was the total discount amount for all products?
SELECT round(sum(qty * price * discount/100),0) as total_discount_amount
from sales;
                 #(OR)
select sum(Discount_amount) from sales;

-------------------------------------------------------------------------------------------------------
##Transaction Analysis
#1.How many unique transactions were there?
SELECT count(DISTINCT txn_id) as unique_transactions from sales

#2.What is the average unique products purchased in each transaction?
with up as (
SELECT
  txn_id,
  COUNT(DISTINCT prod_id) AS Upc-- unique product count
FROM
  balanced_tree.sales
GROUP BY
  txn_id
)
select round(avg(upc),0) as avg_unique_products from up
  
#3.What are the 25th, 50th and 75th percentile values for the revenue per transaction?
WITH cte_transaction_revenue AS (
  SELECT
    txn_id,
    SUM(revenue) AS revenue_after_discount
  FROM balanced_tree.sales
  GROUP BY txn_id
),
Quartiles AS (
  SELECT
    txn_id,
    revenue_after_discount,
    NTILE(4) OVER (ORDER BY revenue_after_discount) AS quartile
  FROM cte_transaction_revenue
)

SELECT
  CASE 
    WHEN quartile = 1 THEN "percentile_25"
    WHEN quartile = 2 THEN "percentile_50"
    WHEN quartile = 3 THEN "percentile_75"
  END AS percentile,
  ROUND(MAX(revenue_after_discount), 0) AS revenue
FROM Quartiles
WHERE quartile IN (1, 2, 3)
GROUP BY quartile;

 #4.What is the average discount value per transaction?
 WITH ADV AS
 (SELECT txn_id,
		SUM(Discount_amount) as discount 
         from sales
GROUP BY txn_id)
SELECT ROUND(AVG(discount),2) as avg_discount  from adv

#4.What is the percentage split of all transactions for members vs non-members?
SELECT
  Case when member ='t' then 'members'
	   when member ='f' then'non-members' 
       end as member_category,
  ROUND(COUNT(txn_id) * 100.0 / (SELECT COUNT(txn_id) FROM sales), 2) AS percentage_split
FROM sales
GROUP BY member_category;

#5.What is the average revenue for member transactions and non-member transactions?
SELECT Case when member ='t' then 'members'
	   when member ='f' then'non-members' 
       end as member_category,
       ROUND(AVG(revenue),2) as avg_revnue
       from sales
       group by member_category
       
---------------------------------------------------------------------------------------------------------------------------------
##Product Analysis
#1.What are the top 3 products by total revenue before discount?
SELECT p.product_name ,
	   SUM(s.qty* s.price) as Total_Revenue
from product_details p
JOIN sales s ON p.product_id = s.prod_id
GROUP BY p.product_name
ORDER BY Total_Revenue desc
LIMIT 3;

#2.What is the total quantity, revenue and discount for each segment?
SELECT p.segment_name,
       SUM(s.qty) as Total_quantity,
       SUM(s.revenue) as Total_revenue_after_discount,
       SUM(s.discount_amount) as Total_Discount
FROM product_details p
JOIN sales s ON p.product_id = s.prod_id
GROUP BY p.segment_name
order by p.segment_name

#3. What is the top selling product for each segment?
WITH cte as (
SELECT p.segment_name,
	   p.product_name,
       SUM(s.qty) as total_quantity_sold,
	   RANK() OVER (PARTITION BY p.segment_name ORDER BY SUM(s.qty) DESC ) as rnk
       from product_details p
       JOIN sales s 
       ON p.product_id = s.prod_id
	   GROUP BY p.segment_name,p.product_name
) 
SELECT segment_name,
       product_name,
       total_quantity_sold
from cte 
WHERE 
  rnk = 1;

#4.What is the total quantity, revenue and discount for each category?
SELECT p.category_name,
       SUM(s.qty) as Total_quantity,
       SUM(s.revenue) as Total_revenue_after_discount,
       SUM(s.discount_amount) as Total_Discount
FROM product_details p
JOIN sales s ON p.product_id = s.prod_id
GROUP BY p.category_name
order by p.category_name

#5.What is the top selling product for each category?
WITH cte as (
SELECT p.category_name,
	   p.product_name,
       SUM(s.qty) as total_quantity_sold,
	   RANK() OVER (PARTITION BY p.category_name ORDER BY SUM(s.qty) DESC ) as rnk
       from product_details p
       JOIN sales s 
       ON p.product_id = s.prod_id
	   GROUP BY p.category_name,p.product_name
) 
SELECT category_name,
       product_name,
       total_quantity_sold
from cte 
WHERE 
  rnk = 1;
  
#6.What is the percentage split of revenue by product for each segment?
WITH cte AS (
  SELECT
    p.segment_name,
    p.product_name,
    SUM(s.revenue) AS total_revenue
  FROM
    product_details p
  JOIN
    sales s ON p.product_id = s.prod_id
  GROUP BY
    p.segment_name, p.product_name
   ORDER BY total_revenue DESC
)
SELECT
  segment_name,
  product_name,
  total_revenue,
  ROUND(total_revenue * 100 / SUM(total_revenue) OVER (PARTITION BY segment_name ), 2) AS revenue_percentage
FROM
  cte;

#7.What is the percentage split of revenue by segment for each category
WITH cte AS (
  SELECT
    p.category_name,
    p.segment_name,
    SUM(s.revenue) AS total_revenue
  FROM
    product_details p
  JOIN
    sales s ON p.product_id = s.prod_id
  GROUP BY
    p.category_name,p.segment_name
   ORDER BY total_revenue DESC
)

SELECT
  category_name,
  segment_name,
  total_revenue,
  ROUND(total_revenue * 100 / SUM(total_revenue) OVER (PARTITION BY category_name), 2) AS revenue_percentage
FROM
  cte;
  ;
  
#8.What is the percentage split of total revenue by category?
WITH cte as(
SELECT p.category_name,
	   SUM(s.revenue) as total_revenue
       from 
	   product_details p
       JOIN
       sales s
       ON p.product_id = s.prod_id
       GROUP 
       BY p.category_name
)
SELECT category_name,
        total_revenue,
        round(total_revenue * 100.0 / SUM(total_revenue) OVER(),2) as percentage_split
FROM
    cte
ORDER BY percentage_split desc;

#9.What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a 
# product was purchased divided by total number of transactions)?
select product_name, 
	   round(count(distinct txn_id)*100.0/(select count(distinct txn_id) from sales ),2) as penetration
from sales s
join product_details pd on s.prod_id = pd.product_id
where qty>=1
group by product_name
order by penetration desc;

----------------------------------------------------------------------------------------------------------------------------
#Additional Analysis
#1..How many transactions had a discount applied?
SELECT COUNT(txn_id) as dicount_applied from sales
WHERE discount > 0;
#How many transactions had no discount applied?
SELECT COUNT(txn_id) from sales
WHERE DISCOUNT <=0;

#2.Calculate the average discount percentage for transactions involving members. Compare it to transactions without members.
SELECT member,round(AVG(discount),2) as avg_discount_for_members from sales
where discount > 0
group by member;    

#3.Total Sales per Month
SELECT
  DATE_FORMAT(start_txn_time, '%Y-%m') AS TransactionMonth,
  SUM(qty * price) AS TotalSales
FROM
  balanced_tree.sales
GROUP BY
  TransactionMonth
ORDER BY
  TransactionMonth;

# 4.What percentage of transactions have high, medium, or low discounts?
SELECT
  CASE
    WHEN discount >= 20 THEN 'High Discount'
    WHEN discount >= 10 THEN 'Medium Discount'
    ELSE 'Low Discount'
  END AS DiscountCategory,
  COUNT(txn_id) AS TransactionCount,
  COUNT(txn_id) * 100.0 / (SELECT COUNT(txn_id) FROM balanced_tree.sales) AS Percentage
FROM
  balanced_tree.sales
GROUP BY
  DiscountCategory;