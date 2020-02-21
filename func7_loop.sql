create procedure "func7_loop"(in threshold bigint, in _year integer ) as begin
declare total_cnt bigint;

v1 = SELECT c_customer_id    customer_id, 
                c_first_name     customer_first_name, 
                c_last_name      customer_last_name, 
                d_year           AS year1, 
                Sum(ss_net_paid) year_total, 
                's'              sale_type 
         FROM   customer, 
                store_sales, 
                date_dim 
         WHERE  c_customer_sk = ss_customer_sk 
                AND ss_sold_date_sk = d_date_sk 
                AND d_year IN ( :_year, :_year + 1 ) 
         GROUP  BY c_customer_id, 
                   c_first_name, 
                   c_last_name, 
                   d_year ;

v2 = SELECT c_customer_id    customer_id, 
                c_first_name     customer_first_name, 
                c_last_name      customer_last_name, 
                d_year           AS year1, 
                Sum(ws_net_paid) year_total, 
                'w'              sale_type 
         FROM   customer, 
                web_sales, 
                date_dim 
         WHERE  c_customer_sk = ws_bill_customer_sk 
                AND ws_sold_date_sk = d_date_sk 
                AND d_year IN ( :_year, :_year + 1 ) 
         GROUP  BY c_customer_id, 
                   c_first_name, 
                   c_last_name, 
                   d_year;
year_total = select * from :v1 union all select * from :v2;
select count(*) into total_cnt from :year_total;
if (:total_cnt > :threshold) then
t_s_firstyear = select * from :year_total;
t_s_secyear = select * from :year_total;
t_w_firstyear = select * from :year_total;
t_w_secyear = select * from :year_total;
end if;

while :_year < 2002 do 
SELECT t_s_secyear.customer_id, 
               t_s_secyear.customer_first_name, 
               t_s_secyear.customer_last_name 
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
       AND t_s_firstyear.year1 = :_year 
       AND t_s_secyear.year1 = :_year + 1
       AND t_w_firstyear.year1 = :_year 
       AND t_w_secyear.year1 = :_year + 1
       AND t_s_firstyear.year_total > 0 
       AND t_w_firstyear.year_total > 0 
       AND CASE 
             WHEN t_w_firstyear.year_total > 0 THEN t_w_secyear.year_total / 
                                                    t_w_firstyear.year_total 
             ELSE NULL 
           END > CASE 
                   WHEN t_s_firstyear.year_total > 0 THEN 
                   t_s_secyear.year_total / 
                   t_s_firstyear.year_total 
                   ELSE NULL 
                 END 
ORDER  BY 1, 
          2, 
          3
LIMIT 100; 
_year = :_year + 1;
end while;
end;