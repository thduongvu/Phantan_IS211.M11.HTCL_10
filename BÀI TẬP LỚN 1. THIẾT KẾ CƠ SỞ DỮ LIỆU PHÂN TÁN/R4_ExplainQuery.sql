-- EXPLAIN QUERY   
--
-- 

SELECT /*+ GATHER_PLAN_STATISTICS */ CI.CustomerName, CI.CustomerAddress, IL.SubTotal , MN.MenuName 
FROM    CN02.CUSTOMER_INFO CI, CN02.INVOICE IV, CN02.INVOICELINE IL, CN02.BRANCH BR, CN02.MENU MN 
WHERE   BR.BranchID = IV.BranchID AND IV.InvoiceID = IL.InvoiceID AND 
        MN.MenuID = IL.MenuID AND CI.CustomerID = IV.CustomerID AND 
        CI.CustomerAddress = 'Ho Chi Minh' AND BR.BranchID = 'BR02' 
        AND CI.CustomerType = 'Gold' AND MN.MenuType = 'Ca Phe Italy';


SELECT /*+ GATHER_PLAN_STATISTICS */  CustomerName, CustomerAddress, Subtotal, MenuName
FROM (  SELECT BranchName, MenuName, CustomerID
        FROM (  SELECT  BranchName, InvoiceID, CustomerID
                FROM (  SELECT InvoiceID, CustomerID FROM CN02.INVOICE WHERE BranchID='BR02') E 
                            INNER JOIN
                            (   SELECT  MenuName, InvoiceID
                                FROM (  SELECT  MenuID, MenuName 
                                        FROM    CN02.MENU 
                                        WHERE   MenuType = 'Ca Phe Italy') C 
                                        INNER JOIN
                                        (   SELECT  InvoiceID, MenuID, Subtotal 
                                            FROM    CN02.INVOICELINE)  D ON C.MenuID=D.MenuID) F ON E.InvoiceID = F.InvoiceID) H 
                                            INNER JOIN
                                            (   SELECT  CustomerID, CustomerAddress, CustomerName 
                                                FROM    CN02.CUSTOMER_INFO 
                                                WHERE   CustomerAddress = 'Ho Chi Minh' AND
                                                        CustomerType='Gold') 
                                                        G ON H.CustomerID = G.CustomerID);


SELECT CustomerName, CustomerAddress, Subtotal, MenuName 
FROM ( SELECT BranchName, MenuName, CustomerID 
FROM ( SELECT BranchName, InvoiceID, CustomerID 
FROM ( SELECT InvoiceID, CustomerID 
FROM INVOICE WHERE BranchID='BR02') E INNER JOIN ( SELECT MenuName, InvoiceID 
FROM ( SELECT MenuID, MenuName 
FROM MENU WHERE MenuType = 'Ca Phe Italy') C INNER JOIN ( SELECT InvoiceID, MenuID, Subtotal 
FROM INVOICELINE) D ON C.MENUID=D.MENUID) F ON E.InvoiceID = F.InvoiceID) H 
INNER JOIN ( SELECT CustomerID, CustomerAddress, CustomerName 
FROM CUSTOMER_INFO 
WHERE CustomerAddress = 'Ho Chi Minh' AND CustomerType='Gold') G ON H.CustomerID = G.CustomerID);


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
-- [unchecked]
SELECT /*+ GATHER_PLAN_STATISTICS */ CustomerName, CustomerAddress, BranchName, MenuName
FROM (SELECT BranchName, MenuName, CustomerID
            FROM (SELECT BranchName, InvoiceID, CustomerID
                         FROM (SELECT BranchName, BranchID FROM BRANCH WHERE BranchID = 'BR02') A INNER JOIN
                                     (SELECT BranchID, InvoiceID, CustomerID FROM INVOICE) B ON A.BranchID=B.BranchID) 
                          E INNER JOIN
                         (SELECT MenuName, InvoiceID
                         FROM (SELECT MenuID, MenuName FROM MENU WHERE MenuType = 'Ca Phe Italy') C INNER JOIN
                                    (SELECT InvoiceID, MenuID FROM INVOICELINE)  D ON C.MENUID=D.MENUID)
                          F ON E.InvoiceID = F.InvoiceID)
              H INNER JOIN
             (SELECT CustomerID, CustomerAddress, CustomerName FROM CUSTOMER_INFO WHERE CustomerAddress = 'Ho Chi Minh' AND
                                                                                        CustomerType='Gold')
              G ON H.CustomerID = G.CustomerID;

SELECT * FROM TABLE(DBMS_XPLAN.display_cursor(format=>'ALLSTATS LAST'));

-- Distributed environment
-- [unchecked]
SELECT  CustomerName, CustomerAddress, BranchName, MenuName
FROM (  SELECT  BranchName, MenuName, CustomerID
        FROM (  SELECT  BranchName, InvoiceID, CustomerID
                FROM    (SELECT BranchName, BranchID 
                        FROM    CN02.BRANCH
                        UNION 
                        SELECT BranchName, BranchID 
                        FROM    CN01.BRANCH@GD_CN01) A 
                        JOIN
                        (SELECT BranchID, InvoiceID, CustomerID 
                        FROM    CN02.INVOICE
                        UNION
                        SELECT BranchID, InvoiceID, CustomerID 
                        FROM    CN01.INVOICE@GD_CN01) B 
                        ON      A.BranchID=B.BranchID) E 
                        INNER JOIN
                        (SELECT MenuName, InvoiceID
                        FROM    (SELECT MenuID, MenuName 
                                FROM    CN02.MENU 
                                WHERE   MenuType = 'Ca Phe Italy'
                                UNION
                                SELECT MenuID, MenuName 
                                FROM    CN01.MENU@GD_CN01
                                WHERE   MenuType = 'Ca Phe Italy') C 
                                INNER JOIN
                                (SELECT InvoiceID, MenuID 
                                FROM    CN02.INVOICELINE
                                UNION
                                SELECT InvoiceID, MenuID 
                                FROM    CN01.INVOICELINE@GD_CN01)  D 
                                ON      C.MenuID = D.MenuID) F 
                                ON      E.InvoiceID = F.InvoiceID) H 
                                INNER JOIN
                                (SELECT CustomerID, CustomerAddress, CustomerName 
                                FROM    CN02.CUSTOMER_INFO 
                                WHERE   CustomerAddress = 'Ho Chi Minh' AND
                                        CustomerType = 'Gold'
                                UNION
                                SELECT CustomerID, CustomerAddress, CustomerName 
                                FROM    CN01.CUSTOMER_INFO@GD_CN01
                                WHERE   CustomerAddress = 'Ho Chi Minh' AND
                                        CustomerType = 'Gold') G 
                                ON      H.CustomerID = G.CustomerID;

-- SELECT * FROM TABLE(DBMS_XPLAN.display_cursor(format=>'ALLSTATS LAST'));

EXPLAIN PLAN FOR
SELECT   CI.CustomerName, CI.CustomerAddress, BR.BranchName, MN.MenuName
FROM     CUSTOMER_INFO CI, INVOICE IV, INVOICELINE IL, BRANCH BR, MENU MN
WHERE    BR.BranchID = IV.BranchID AND IV.InvoiceID = IL.InvoiceID AND 
         MN.MenuID = IL.MenuID AND CI.CustomerID = IV.CustomerID AND 
         CI.CustomerAddress = 'Ho Chi Minh' AND BR.BranchID = 'BR02' AND 
         CI.CustomerType = 'Gold' AND MN.MenuType = 'Ca Phe Italy';
            
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

EXPLAIN PLAN FOR
SELECT  CustomerName, CustomerAddress, BranchName, MenuName
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
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());


