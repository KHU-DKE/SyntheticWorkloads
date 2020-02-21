/***********************************************************
This procedure is generated by the query 97 template
in TPC-DS. This query is to generate counts of promotional 
sales and total sales, and their ratio from the web channel 
for a particular item category and month to customers in a 
given time zone. The scalar parameter is threshold.


The detail steps for generating the procedure with loops 
by transforming CTE query are as follows. Each CTE table
variable is transformed to the SQL assignment statement
Then, each query with table variables is decomposed.


In addition, we only caclulates ferquent_ss_itmes and v1 
when the the count of date which the dms is between 1196 ~ 1196+11 
is bigger than threshold for adding branch to block inlining.
**************************************************************/

CREATE PROCEDURE "func10_if"(in threshold bigint) -- 365
as begin
declare date_cnt integer;
select count(*) into date_cnt from date_dim where d_month_seq BETWEEN 1196 AND 1196 + 11;
if :date_cnt > :threshold then
ssci = SELECT ss_customer_sk customer_sk, ss_item_sk item_sk, d_month_seq
       FROM store_sales, date_dim
       WHERE ss_sold_date_sk = d_date_sk 
       GROUP BY ss_customer_sk, ss_item_sk, d_month_seq;
       
       
csci = SELECT cs_bill_customer_sk customer_sk, cs_item_sk item_sk, d_month_seq
       FROM catalog_sales, date_dim
       WHERE cs_sold_date_sk = d_date_sk 
       GROUP BY cs_bill_customer_sk, cs_item_sk, d_month_seq;
end if;

ssci_2 = select * from :ssci where d_month_seq BETWEEN 1196 AND 1196 + 11;
csci_2 = select * from :csci where d_month_seq BETWEEN 1196 AND 1196 + 11 ;

SELECT Sum(CASE WHEN ssci.customer_sk IS NOT NULL AND csci.customer_sk IS NULL THEN 1 ELSE 0 END) store_only,
       Sum(CASE WHEN ssci.customer_sk IS NULL AND csci.customer_sk IS NOT NULL THEN 1 ELSE 0 END) catalog_only,
       Sum(CASE WHEN ssci.customer_sk IS NOT NULL AND csci.customer_sk IS NOT NULL THEN 1 ELSE 0 END) store_and_catalog
FROM :ssci_2 ssci FULL OUTER JOIN :csci_2 csci ON (ssci.customer_sk = csci.customer_sk
                              AND ssci.item_sk = csci.item_sk);
end;