create procedure "func4_loop"(in monthInfo integer) 
as begin
declare _month integer;
_month := :monthInfo;

frequent_items = (select substr(i_item_desc,1,30) itemdesc,d_year, i_item_sk item_sk,d_date solddate,count(*) cnt
  from store_sales
      ,date_dim
      ,item
  where ss_sold_date_sk = d_date_sk
    and ss_item_sk = i_item_sk
      group by substr(i_item_desc,1,30),i_item_sk,d_date,d_year having count(*) >4);

max_sub_store_sales = select *
        from store_sales
            ,customer
            ,date_dim 
        where ss_customer_sk = c_customer_sk
         and ss_sold_date_sk = d_date_sk;


max_sub_store_sales2 = select c_customer_sk,sum(ss_quantity*ss_sales_price) csales
        from :max_sub_store_sales
          where d_year in (1999,1999+1,1999+2,1999+3)
		 group by c_customer_sk;
         
frequent_ss_items =
 select * from :frequent_items
  where d_year in (1999,1999 + 1,1999 + 2,1999 + 3) ;

max_store_sales =
 select max(csales) tpcds_cmax
  from :max_sub_store_sales2;

best_ss_customer =
 (select c_customer_sk,sum(ss_quantity*ss_sales_price) ssales
  from store_sales
      ,customer
  where ss_customer_sk = c_customer_sk
  group by c_customer_sk
  having sum(ss_quantity*ss_sales_price) > (95/100.0) * (select
  * from :max_store_sales)) ;

while (:_month < 13) DO
v0 = (select c_last_name,c_first_name,sum(cs_quantity*cs_list_price) sales
        from catalog_sales
            ,customer
            ,date_dim 
        where d_year = 1999 
         and d_moy = :_month 
         and cs_sold_date_sk = d_date_sk 
         and cs_item_sk in (select item_sk from :frequent_ss_items)
         and cs_bill_customer_sk = c_customer_sk 
       group by c_last_name,c_first_name
      union all
      select c_last_name,c_first_name,sum(ws_quantity*ws_list_price) sales
       from web_sales
           ,customer
           ,date_dim 
       where d_year = 1999 
         and d_moy = :_month
         and ws_sold_date_sk = d_date_sk 
         and ws_item_sk in (select item_sk from :frequent_ss_items)
         and ws_bill_customer_sk = c_customer_sk
       group by c_last_name,c_first_name);

 select top 100 c_last_name,c_first_name,sales
 from  :v0
     order by c_last_name,c_first_name,sales
  ;
 _month = :_month + 1;
end while;
end;