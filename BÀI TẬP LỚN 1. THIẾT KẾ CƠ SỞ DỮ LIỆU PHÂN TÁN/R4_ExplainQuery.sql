-- EXPLAIN QUERY   
EXPLAIN PLAN FOR
Select CI.CustomerName, CI.CustomerAddress, BR.BranchName, MN.MenuName
From CUSTOMER_INFO CI, INVOICE IV, INVOICELINE IL, BRANCH BR, MENU MN
Where BR.BranchID = IV.BranchID AND IV.InvoiceID = IL.InvoiceID
            AND MN.MenuID = IL.MenuID AND CI.CustomerID = IV.CustomerID
            AND CI.CustomerAddress = 'Ho Chi Minh' AND BR.BranchID = 'BR02'
            AND CI.CustomerType = 'Gold' AND MN.MenuType = 'Ca Phe Italy';
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-- SELECT /*+ GATHER_PLAN_STATISTICS */ t2.owner, SUM(b.object_id)
-- FROM  big_table b, t2 ,t1
-- WHERE b.object_id = t2.object_id
-- AND   b.data_object_id = t1.data_object_id
-- AND   t1.object_type='TABLE'
-- AND   t2.owner ='SSB'
-- GROUP BY t2.owner;
 
-- SELECT * FROM TABLE(DBMS_XPLAN.display_cursor(format=>'ALLSTATS LAST'));
