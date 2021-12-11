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
SELECT /*+ GATHER_PLAN_STATISTICS */ CustomerName, CustomerAddress, BranchName, MenuName
FROM (  SELECT BranchName, MenuName, CustomerID
        FROM (  SELECT  BranchName, InvoiceID, CustomerID
                FROM (  SELECT  BranchName, BranchID 
                        FROM    BRANCH 
                        WHERE   BranchID = 'BR02') 
                        A INNER JOIN
                        (   SELECT  BranchID, InvoiceID, CustomerID 
                            FROM    INVOICE) B ON A.BranchID=B.BranchID) E 
                            INNER JOIN
                            (   SELECT  MenuName, InvoiceID
                                FROM (  SELECT  MenuID, MenuName 
                                        FROM    MENU 
                                        WHERE   MenuType = 'Ca Phe Italy') C 
                                        INNER JOIN
                                        (   SELECT  InvoiceID, MenuID 
                                            FROM    INVOICELINE)  D ON C.MENUID=D.MENUID) F ON E.InvoiceID = F.InvoiceID) H 
                                            INNER JOIN
                                            (   SELECT  CustomerID, CustomerAddress, CustomerName 
                                                FROM    CUSTOMER_INFO 
                                                WHERE   CustomerAddress = 'Ho Chi Minh' AND
                                                        CustomerType='Gold') G ON H.CustomerID = G.CustomerID;

-- SELECT * FROM TABLE(DBMS_XPLAN.display_cursor(format=>'ALLSTATS LAST'));

-- EXPLAIN PLAN FOR
-- SELECT   CI.CustomerName, CI.CustomerAddress, BR.BranchName, MN.MenuName
-- FROM     CUSTOMER_INFO CI, INVOICE IV, INVOICELINE IL, BRANCH BR, MENU MN
-- WHERE    BR.BranchID = IV.BranchID AND IV.InvoiceID = IL.InvoiceID AND 
--          MN.MenuID = IL.MenuID AND CI.CustomerID = IV.CustomerID AND 
--          CI.CustomerAddress = 'Ho Chi Minh' AND BR.BranchID = 'BR02' AND 
--          CI.CustomerType = 'Gold' AND MN.MenuType = 'Ca Phe Italy';
            
-- SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

-- EXPLAIN PLAN FOR
-- SELECT  CustomerName, CustomerAddress, BranchName, MenuName
-- FROM (  SELECT BranchName, MenuName, CustomerID
--         FROM (  SELECT  BranchName, InvoiceID, CustomerID
--                 FROM (  SELECT  BranchName, BranchID 
--                         FROM    BRANCH 
--                         WHERE   BranchID = 'BR02') 
--                         A INNER JOIN
--                         (   SELECT  BranchID, InvoiceID, CustomerID 
--                             FROM    INVOICE) B ON A.BranchID=B.BranchID) E 
--                             INNER JOIN
--                             (   SELECT  MenuName, InvoiceID
--                                 FROM (  SELECT  MenuID, MenuName 
--                                         FROM    MENU 
--                                         WHERE   MenuType = 'Ca Phe Italy') C 
--                                         INNER JOIN
--                                         (   SELECT  InvoiceID, MenuID 
--                                             FROM    INVOICELINE)  D ON C.MENUID=D.MENUID) F ON E.InvoiceID = F.InvoiceID) H 
--                                             INNER JOIN
--                                             (   SELECT  CustomerID, CustomerAddress, CustomerName 
--                                                 FROM    CUSTOMER_INFO 
--                                                 WHERE   CustomerAddress = 'Ho Chi Minh' AND
--                                                         CustomerType='Gold') G ON H.CustomerID = G.CustomerID;
-- SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());
