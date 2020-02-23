/***************************************************************
This procedure is generated by the query 11 template in TPC-DS.
This query is to find customers whose increase in spending was 
large over the web than in stores this year compared to last year.
The scalar parameters are _year and threshold.

The detail steps for generating the procedure with loops 
by transforming CTE query are as follows. Each CTE table
variable is transformed to the SQL assignment statement
Then, each query with table variables is decomposed.

In addition, we only caclulates year_total when the count of year_total 
is bigger than threshold for adding branch to block inlining.

Finally, for each scalar parameter that is used in the query
template, the loop, which calculates the query iteratively for
every range of parameter, is inserted. 
***************************************************************/ 

create procedure "func2_loop"(in threshold bigint, in _year integer) as begin
v1 = SELECT c_customer_id                                customer_id, 
                c_first_name                                 customer_first_name 
                , 
                c_last_name 
                customer_last_name, 
                c_preferred_cust_flag 
                   customer_preferred_cust_flag 
                    , 
                c_birth_country 
                    customer_birth_country, 
                c_login                                      customer_login, 
                c_email_address 
                customer_email_address, 
                d_year                                       dyear, 
                Sum(ss_ext_list_price - ss_ext_discount_amt) year_total, 
                's'                                          sale_type 
         FROM   customer, 
                store_sales, 
                date_dim 
         WHERE  c_customer_sk = ss_customer_sk 
                AND ss_sold_date_sk = d_date_sk 
         GROUP  BY c_customer_id, 
                   c_first_name, 
                   c_last_name, 
                   c_preferred_cust_flag, 
                   c_birth_country, 
                   c_login, 
                   c_email_address, 
                   d_year;
v2 = SELECT c_customer_id                                customer_id, 
                c_first_name                                 customer_first_name 
                , 
                c_last_name 
                customer_last_name, 
                c_preferred_cust_flag 
                customer_preferred_cust_flag 
                , 
                c_birth_country 
                customer_birth_country, 
                c_login                                      customer_login, 
                c_email_address 
                customer_email_address, 
                d_year                                       dyear, 
                Sum(ws_ext_list_price - ws_ext_discount_amt) year_total, 
                'w'                                          sale_type 
         FROM   customer, 
                web_sales, 
                date_dim 
         WHERE  c_customer_sk = ws_bill_customer_sk 
                AND ws_sold_date_sk = d_date_sk 
         GROUP  BY c_customer_id, 
                   c_first_name, 
                   c_last_name, 
                   c_preferred_cust_flag, 
                   c_birth_country, 
                   c_login, 
                   c_email_address, 
                   d_year;
year_total = select * from :v1 
         UNION ALL 
         	 select * from :v2;
         	 
t_s_firstyear = select * from :year_total  with hint(no_inline);
t_s_secyear = select * from :year_total with hint(no_inline);
t_w_firstyear = select * from :year_total with hint(no_inline);
t_w_secyear = select * from :year_total with hint(no_inline);

while :_year < 2002 do 
SELECT t_s_secyear.customer_id, 
               t_s_secyear.customer_first_name, 
               t_s_secyear.customer_last_name, 
               t_s_secyear.customer_birth_country 
FROM   :t_s_firstyear t_s_firstyear, 
       :t_s_secyear t_s_secyear, 
       :t_w_firstyear t_w_firstyear, 
       :t_w_secyear t_w_secyear 
WHERE  t_s_secyear.customer_id = t_s_firstyear.customer_id 
       AND t_s_firstyear.customer_id = t_w_secyear.customer_id 
       AND t_s_firstyear.customer_id = t_w_firstyear.customer_id 
       AND t_s_firstyear.sale_type = 's' 
       AND t_w_firstyear.sale_type = 'w' 
       AND t_s_secyear.sale_type = 's' 
       AND t_w_secyear.sale_type = 'w' 
       AND t_s_firstyear.dyear = :_year
       AND t_s_secyear.dyear = :_year + 1
       AND t_w_firstyear.dyear = :_year
       AND t_w_secyear.dyear = :_year + 1
       AND t_s_firstyear.year_total > 0 
       AND t_w_firstyear.year_total > 0 
       AND CASE 
             WHEN t_w_firstyear.year_total > 0 THEN t_w_secyear.year_total / 
                                                    t_w_firstyear.year_total 
             ELSE 0.0 
           END > CASE 
                   WHEN t_s_firstyear.year_total > 0 THEN 
                   t_s_secyear.year_total / 
                   t_s_firstyear.year_total 
                   ELSE 0.0 
                 END 
ORDER  BY t_s_secyear.customer_id, 
          t_s_secyear.customer_first_name, 
          t_s_secyear.customer_last_name, 
          t_s_secyear.customer_birth_country
LIMIT 100; 
_year = :_year + 1;
end while;
end;