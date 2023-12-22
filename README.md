# Balanced-Tree-Clothing-Co.
-----------------------------------------------------------------------------------------------------

<p align="center">
  <img width="450" src="https://github.com/hemaprabhavathi20/8-Week-SQL-Challenge/assets/147178268/0685c8b7-a3d7-449a-80b7-863a0024e4d9" alt="Image">
</p>

Table Of Contents:
----------------------------------------------------------------------------------
* Business Problem
* Available Data
* ER Diagram
* Case Study Question
_________________________________________________________________________________________________________________________

Business Problem
------------------------------------------------------------------------
Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer!

Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams analyse their sales performance and generate a basic financial report to share with the wider business

Available Data
---------------------------------------------------------------------------------
There are 2 main tables for the case study and are as follows:    
1. **Product_details** - Includes all information about the entire range that Balanced Clothing sells in their store.
2. **sales**          - contains product level information for all the transactions made for Balanced Tree including quantity, price, percentage discount, member status, a transaction ID and also the transaction timestamp.

ER Diagram 
------------------------------------------------------------------------------------
<p align="center">
  <img src="https://github.com/hemaprabhavathi20/8-Week-SQL-Challenge/assets/147178268/9fc6fe6c-fd67-457b-97f7-10603626f0df" width="650" alt="Screenshot">
</p>

Case Study Questions:
--------------------------------------------------------------------------------
**High Level Sales Analysis**

1. What was the total quantity sold for all products?
2. What is the total generated revenue for all products before discounts?
3. What was the total discount amount for all products?



**Transaction Analysis**

1. How many unique transactions were there?
2. What is the average unique products purchased in each transaction?
3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
4.What is the average discount value per transaction?
5. What is the percentage split of all transactions for members vs non-members?
6.What is the average revenue for member transactions and non-member transactions?



**Product Analysis**

1. What are the top 3 products by total revenue before discount?
2. What is the total quantity, revenue and discount for each segment?
3. What is the top selling product for each segment?
4. What is the total quantity, revenue and discount for each category?
5. What is the top selling product for each category?
6. What is the percentage split of revenue by product for each segment?
7. What is the percentage split of revenue by segment for each category?
8. What is the percentage split of total revenue by category?
9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

_______________________________________________________________________

**Changes made to table**
1. Added 2 new columns named discount and revenue in the sales table
