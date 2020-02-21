CREATE PROCEDURE "func10_loop"(in dmsInfo integer) -- 365
as begin
declare dms integer;
dms = :dmsInfo;
ssci = SELECT ss_customer_sk customer_sk, ss_item_sk item_sk, d_month_seq
       FROM store_sales, date_dim
       WHERE ss_sold_date_sk = d_date_sk 
       GROUP BY ss_customer_sk, ss_item_sk, d_month_seq ;
       
csci = SELECT cs_bill_customer_sk customer_sk, cs_item_sk item_sk, d_month_seq
       FROM catalog_sales, date_dim
       WHERE cs_sold_date_sk = d_date_sk 
       GROUP BY cs_bill_customer_sk, cs_item_sk, d_month_seq ;
       
while(:dms < 1209) DO
ssci_2 = select * from :ssci where d_month_seq BETWEEN :dms AND :dms + 11;
csci_2 = select * from :csci where d_month_seq BETWEEN :dms AND :dms + 11 ;

SELECT Sum(CASE WHEN ssci.customer_sk IS NOT NULL AND csci.customer_sk IS NULL THEN 1 ELSE 0 END) store_only,
       Sum(CASE WHEN ssci.customer_sk IS NULL AND csci.customer_sk IS NOT NULL THEN 1 ELSE 0 END) catalog_only,
       Sum(CASE WHEN ssci.customer_sk IS NOT NULL AND csci.customer_sk IS NOT NULL THEN 1 ELSE 0 END) store_and_catalog
FROM :ssci_2 ssci FULL OUTER JOIN :csci_2 csci ON (ssci.customer_sk = csci.customer_sk
                              AND ssci.item_sk = csci.item_sk);
dms = :dms + 11;
end while;
end;