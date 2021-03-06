/****************************************************************
This procedure is generated by the query 75 template
in TPC-DS. This query is to track the sales of items by 
brand, class and category for two consecutive years. 
The detail steps for generating the procedure with loops
by transforming CTE query are as follows. 
The scalar parameter are threshold and _year.

The detail steps for generating the procedure with loops 
by transforming CTE query are as follows. Each CTE table
variable is transformed to the SQL assignment statement
Then, each query with table variables is decomposed.

In addition, we only caclulates v1,v2,v3 when the each count of v1,v2 and v3 
is bigger than threshold to add branch for blocking inlining.

Finally, for each scalar parameter that is used in the query
template, the loop, which calculates the query iteratively for
every range of parameter, is inserted. 
**********************************************************************/

create procedure "func8_loop"(in yearInfo integer) as begin

declare _year integer;
declare v4 table (d_year integer, i_brand_id integer, i_class_id integer, i_category char(50), i_category_id integer,
 i_manufact_id integer, sales_cnt integer, sales_amt decimal(8,2));
_year = :yearInfo;
v1 = SELECT d_year,
                        i_brand_id,
                        i_class_id,
                        i_category,
                        i_category_id,
                        i_manufact_id,
                        cs_quantity - COALESCE(cr_return_quantity, 0)        AS
                        sales_cnt,
                        cs_ext_sales_price - COALESCE(cr_return_amount, 0.0) AS
                        sales_amt
                 FROM   catalog_sales
                        JOIN item
                          ON i_item_sk = cs_item_sk
                        JOIN date_dim
                          ON d_date_sk = cs_sold_date_sk
                        LEFT JOIN catalog_returns
                               ON ( cs_order_number = cr_order_number
                                    AND cs_item_sk = cr_item_sk);
 v2 = SELECT d_year,
                        i_brand_id,
                        i_class_id,
                        i_category,
                        i_category_id,
                        i_manufact_id,
                        ss_quantity - COALESCE(sr_return_quantity, 0)     AS
                        sales_cnt,
                        ss_ext_sales_price - COALESCE(sr_return_amt, 0.0) AS
                        sales_amt
                 FROM   store_sales
                        JOIN item
                          ON i_item_sk = ss_item_sk
                        JOIN date_dim
                          ON d_date_sk = ss_sold_date_sk
                        LEFT JOIN store_returns
                               ON ( ss_ticket_number = sr_ticket_number
                                    AND ss_item_sk = sr_item_sk ) ;
 v3 = SELECT d_year,
                        i_brand_id,
                        i_class_id,
                        i_category,
                        i_category_id,
                        i_manufact_id,
                        ws_quantity - COALESCE(wr_return_quantity, 0)     AS
                        sales_cnt,
                        ws_ext_sales_price - COALESCE(wr_return_amt, 0.0) AS
                        sales_amt
                 FROM   web_sales
                        JOIN item
                          ON i_item_sk = ws_item_sk
                        JOIN date_dim
                          ON d_date_sk = ws_sold_date_sk
                        LEFT JOIN web_returns
                               ON ( ws_order_number = wr_order_number
                                    AND ws_item_sk = wr_item_sk ) ;

v4 = select * from :v1
    union 
     select * from :v2
    union 
     select * from :v3;

while (:_year > 1999) do
curr_yr =
     SELECT d_year,
                i_brand_id,
                i_class_id,
                i_category,
                i_category_id,
                i_manufact_id,
                Sum(sales_cnt) AS sales_cnt,
                Sum(sales_amt) AS sales_amt
         FROM  :v4 sales_detail
         WHERE  i_category = 'Men'
         and d_year = :_year
         
         GROUP  BY d_year,
                   i_brand_id,
                   i_class_id,
                   i_category,
                   i_category_id,
                   i_manufact_id;
prev_yr =
     SELECT d_year,
                i_brand_id,
                i_class_id,
                i_category,
                i_category_id,
                i_manufact_id,
                Sum(sales_cnt) AS sales_cnt,
                Sum(sales_amt) AS sales_amt
         FROM  :v4 sales_detail
         WHERE  i_category = 'Men'
         and d_year = :_year -1 
         
         GROUP  BY d_year,
                   i_brand_id,
                   i_class_id,
                   i_category,
                   i_category_id,
                   i_manufact_id;
                   
SELECT prev_yr.d_year                        AS prev_year,
               curr_yr.d_year                        AS year1,
               curr_yr.i_brand_id,
               curr_yr.i_class_id,
               curr_yr.i_category_id,
               curr_yr.i_manufact_id,
               prev_yr.sales_cnt                     AS prev_yr_cnt,
               curr_yr.sales_cnt                     AS curr_yr_cnt,
               curr_yr.sales_cnt - prev_yr.sales_cnt AS sales_cnt_diff,
               curr_yr.sales_amt - prev_yr.sales_amt AS sales_amt_diff
FROM   :curr_yr curr_yr,
       :prev_yr prev_yr
WHERE  curr_yr.i_brand_id = prev_yr.i_brand_id
       AND curr_yr.i_class_id = prev_yr.i_class_id
       AND curr_yr.i_category_id = prev_yr.i_category_id
       AND curr_yr.i_manufact_id = prev_yr.i_manufact_id         
       AND Cast(curr_yr.sales_cnt AS DECIMAL(17, 2)) / Cast(prev_yr.sales_cnt AS
                                                                DECIMAL(17, 2))
           < 0.9
ORDER  BY sales_cnt_diff
LIMIT 100;
_year = :_year -1;
end while;

end;

----- call func8_loop
call "func8_loop"(2001);