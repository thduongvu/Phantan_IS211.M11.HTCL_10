-- EXPLAIN QUERY   
--
-- 

-- Clear all cached items
alter system flush buffer_cache;
alter system flush shared_pool;

UPDATE CUSTOMER_INFO
SET CustomerAddress = 'Ho Chi Minh';

BEGIN
    calculateCumulativeTotal;
END;

-- Not optimized
-- [unchecked]
SELECT /*+ GATHER_PLAN_STATISTICS */ CI.CustomerName, CI.CustomerAddress, BR.BranchName, MN.MenuName
FROM    CUSTOMER_INFO CI, INVOICE IV, INVOICELINE IL, BRANCH BR, MENU MN
WHERE   BR.BranchID = IV.BranchID AND IV.InvoiceID = IL.InvoiceID AND 
        MN.MenuID = IL.MenuID AND CI.CustomerID = IV.CustomerID AND 
        CI.CustomerAddress = 'Ho Chi Minh' AND BR.BranchID = 'BR02' AND
        CI.CustomerType = 'Gold' AND MN.MenuType = 'Ca Phe Italy';
 
SELECT * FROM TABLE(DBMS_XPLAN.display_cursor(format=>'ALLSTATS LAST'));

-- Clear all cached items
alter system flush buffer_cache;
alter system flush shared_pool;

-- Optimized
SELECT /*+ GATHER_PLAN_STATISTICS */  CustomerName, CustomerAddress, SubTotal, MenuName
FROM (  SELECT  MenuName, CustomerID, SubTotal
        FROM  (  SELECT CustomerID, MenuID, Subtotal 
                 FROM ( SELECT InvoiceID, CustomerID FROM CN02.INVOICE WHERE BranchID='BR02') A
                        INNER JOIN
                      ( SELECT InvoiceID, MenuID, SubTotal FROM CN02.INVOICELINE) B ON A.InvoiceID=B.InvoiceID) C
                 INNER JOIN
              ( SELECT MenuID, MenuName FROM CN02.MENU WHERE MenuType = 'Ca Phe Italy') D ON C.MenuID=D.MenuID) E
        INNER JOIN
     (  SELECT CustomerID, CustomerAddress, CustomerName 
        FROM CN02.CUSTOMER_INFO 
        WHERE   CustomerAddress = 'Ho Chi Minh' AND CustomerType='Gold') F ON E.CustomerID=F.CustomerID;

SELECT * FROM TABLE(DBMS_XPLAN.display_cursor(format=>'ALLSTATS LAST'));

-- Distributed environment
SELECT /*+ GATHER_PLAN_STATISTICS */  CustomerName, CustomerAddress, SubTotal, MenuName
FROM (  SELECT  MenuName, CustomerID, SubTotal
        FROM  (  SELECT CustomerID, MenuID, Subtotal 
                 FROM ( SELECT InvoiceID, CustomerID FROM CN02.INVOICE 
                        UNION 
                        SELECT InvoiceID, CustomerID FROM CN01.INVOICE@GD_CN01
                        ) A
                        INNER JOIN
                      ( SELECT InvoiceID, MenuID, SubTotal FROM CN02.INVOICELINE
                        UNION
                        SELECT InvoiceID, MenuID, SubTotal FROM CN01.INVOICELINE@GD_CN01) B 
                        ON A.InvoiceID=B.InvoiceID) C
                 INNER JOIN
              ( SELECT MenuID, MenuName 
                FROM CN02.MENU 
                WHERE MenuType = 'Ca Phe Italy'
                UNION
                SELECT MenuID, MenuName 
                FROM CN01.MENU@GD_CN01
                WHERE MenuType = 'Ca Phe Italy'
                ) D ON C.MenuID=D.MenuID) E
        INNER JOIN
     (  SELECT CustomerID, CustomerAddress, CustomerName 
        FROM   CN02.CUSTOMER_INFO 
        WHERE   CustomerAddress = 'Ho Chi Minh' AND 
                CustomerType='Gold'
        UNION
        SELECT CustomerID, CustomerAddress, CustomerName 
        FROM   CN01.CUSTOMER_INFO@GD_CN01
        WHERE   CustomerAddress = 'Ho Chi Minh' AND 
                CustomerType='Gold') F ON E.CustomerID=F.CustomerID;

SELECT * FROM TABLE(DBMS_XPLAN.display_cursor(format=>'ALLSTATS LAST'));
