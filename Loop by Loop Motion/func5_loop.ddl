create procedure "func5_loop"(in dmsInfo integer)
as begin
declare dms integer;
dms := :dmsInfo; --1176

while (:dms < 1209) DO
web_v1 = select d_date, sum(sum(ws_sales_price)) over (partition by item_sk order by d_date rows between unbounded preceding and current row) cume_sales , item_sk
	     from (select ws_item_sk item_sk, ws_sales_price, ws_item_sk, ws_sold_date_sk from web_sales where ws_item_sk is not NULL), date_dim where ws_sold_date_sk=d_date_sk and d_month_seq between :dms and :dms + 11 group by item_sk, d_date;


store_v1 = select d_date, sum(sum(ss_sales_price)) over (partition by ss_item_sk order by d_date rows between unbounded preceding and current row) cume_sales , item_sk
           from (select ss_item_sk item_sk , ss_sold_date_sk, ss_item_sk, ss_sales_price from store_sales where ss_item_sk is not NULL) ,date_dim where ss_sold_date_sk=d_date_sk and d_month_seq between :dms and :dms + 11  group by ss_item_sk, d_date, item_sk;

v3 = select case when web.item_sk is not null then web.item_sk else store.item_sk end item_sk, case when web.d_date is not null then web.d_date else store.d_date end d_date, web.cume_sales web_sales, store.cume_sales store_sales 
     from :web_v1 web full outer join :store_v1 store on (web.item_sk = store.item_sk and web.d_date = store.d_date);
     
v4 = select item_sk ,d_date ,web_sales ,store_sales, max(web_sales) over (partition by item_sk order by d_date rows between unbounded preceding and current row) web_cumulative ,max(store_sales)
         over (partition by item_sk order by d_date rows between unbounded preceding and current row) store_cumulative
     from :v3;
select top 100 * from :v4 where web_cumulative > store_cumulative order by item_sk, d_date;

dms = :dms + 11;
end while;
end;