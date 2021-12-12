-- QUERY
--
--

-- Cap nhat mot so san pham khong duoc phep ban o moi chi nhanh, de thuc hien mot so cau truy van lien quan
-- CN01
CONNECT Manager/Manager;
UPDATE  CN01.MANAGEMENU_MANAGER
SET     Stage = 0
WHERE   (MenuID = 'ME25' OR MenuID = 'ME26' OR MenuID = 'ME27' OR MenuID = 'ME28' OR MenuID = 'ME29' OR MenuID = 'ME30' OR 
        MenuID = 'ME31' OR MenuID = 'ME32' OR MenuID = 'ME33' OR MenuID = 'ME34' OR MenuID = 'ME35' OR MenuID = 'ME36' OR
        MenuID = 'ME37' OR MenuID = 'ME38' OR MenuID = 'ME39' OR MenuID = 'ME40');
-- CN02
CONNECT Manager/Manager;
UPDATE  CN02.MANAGEMENU_MANAGER
SET     Stage = 0
WHERE   (MenuID = 'ME30' OR MenuID = 'ME31' OR MenuID = 'ME32' OR MenuID = 'ME33' OR MenuID = 'ME34' OR MenuID = 'ME35' OR 
        MenuID = 'ME36' OR MenuID = 'ME37' OR MenuID = 'ME38' OR MenuID = 'ME39' OR MenuID = 'ME40' OR MenuID = 'ME41' OR
        MenuID = 'ME42' OR MenuID = 'ME43' OR MenuID = 'ME44' OR MenuID = 'ME45');

--
-- CN02: Nguyen Gia Tri
-- CN02: Nguyen Gia Tri
-- CN02: Nguyen Gia Tri
--

CREATE PUBLIC DATABASE LINK NV_CN01 CONNECT TO Staff IDENTIFIED BY staff USING 'CN01_LINK';
SELECT * FROM CN01.MENU@NV_CN01;

-- 1// Staff: Tim tat ca khach hang mua o ca hai chi nhanh
-- [unchecked]
CONNECT Staff/staff;

SELECT DISTINCT CUS1.CustomerID, CustomerName, PhoneNumber
FROM    CN02.CUSTOMER_INFO CUS1
JOIN    CN02.INVOICE INV1
ON      CUS1.CustomerID = INV1.CustomerID
INTERSECT
SELECT DISTINCT CUS2.CustomerID, CustomerName, PhoneNumber
FROM    CN01.CUSTOMER_INFO@NV_CN01 CUS2 
JOIN    CN01.INVOICE@NV_CN01 INV2
ON      CUS2.CustomerID = INV2.CustomerID;
-- Check
SELECT * FROM CN01.INVOICE WHERE CustomerID = '';
/*CN2*/ SELECT * FROM CN02.INVOICE WHERE CustomerID = '';

-- 2// Staff: Tim tat ca khach hang co hoa don tren 500000 o bat ky chi nhanh
-- [unchecked]
SELECT  CUS1.CustomerID, CustomerName, PhoneNumber
FROM    CN02.CUSTOMER_INFO CUS1, CN02.INVOICE INV1
WHERE   CUS1.CustomerID = INV1.CustomerID AND INV1.Total > 500000
UNION 
SELECT  CUS2.CustomerID, CustomerName, PhoneNumber 
FROM    CN01.CUSTOMER_INFO@NV_CN01 CUS2, CN01.INVOICE@NV_CN01 INV2
WHERE   CUS2.CustomerID = INV2.CustomerID AND INV2.Total > 500000;

-- 3// Director: Tim mat hang la 'banh ngot' duoc ban o ca hai chi nhanh
-- [unchecked]
CONNECT Director/director;

CREATE PUBLIC DATABASE LINK GD_CN01 CONNECT TO Director IDENTIFIED BY director USING 'CN01_LINK';

SELECT  MEMA1.MenuID, ME1.MenuName
FROM    CN02.MANAGEMENU_MANAGER MEMA1, CN02.MENU ME1
WHERE   MEMA1.MenuID = ME1.MenuID AND MEMA1.Stage = 1 AND MenuType = 'Banh Ngot'
INTERSECT
SELECT  MEMA2.MenuID, ME2.MenuName
FROM    CN01.MANAGEMENU_MANAGER@GD_CN01 MEMA2, MENU@GD_CN01 ME2
WHERE   MEMA2.MenuID = ME2.MenuID AND MEMA2.Stage = 1 AND MenuType = 'Banh Ngot'
ORDER BY MenuID;
-- Check 
UPDATE CN02.MANAGEMENU_MANAGER SET Stage = 0 WHERE MenuID = 'ME43' OR MenuID = 'Menu44';
/* Re run query */

-- 4// Director: Tim san pham duoc phep ban o chi nhanh 1 nhung khong duoc phep ban o chi nhanh 2
CONNECT Director/director;
SELECT  MenuID, MenuName, MenuType
FROM    CN02.MENU
WHERE   MenuID IN ( SELECT MenuID 
                    FROM CN02.MANAGEMENU_MANAGER
                    WHERE Stage = 1)
AND MenuID IN ( SELECT MenuID
                FROM CN01.MANAGEMENU_MANAGER@GD_CN01
                WHERE Stage = 1);
-- Check
/*CN1*/ SELECT * FROM CN01.MANAGEMENU_MANAGER WHERE MenuID = '';
/*CN2*/ SELECT * FROM CN02.MANAGEMENU_MANAGER WHERE MenuID = '';

-- 5// Director: Tim hoa don mua tat ca san pham la 'Ca Phe Italy' (truy van cuc bo)
SELECT  INV.InvoiceID, InvoiceDate, INFO.CustomerID, CustomerName, Total, INV.EmployeeID, EmployeeName
FROM    CN02.INVOICE INV, CN02.CUSTOMER_INFO INFO, CN02.EMPLOYEE EMP
WHERE NOT EXISTS(   SELECT *
                    FROM CN02.MENU ME
                    WHERE MenuType = 'Ca Phe Italy'
                    AND NOT EXISTS( SELECT * 
                                    FROM CN02.INVOICELINE INVL
                                    WHERE INVL.InvoiceID = INV.InvoiceID
                                    AND INVL.MenuID = ME.MenuID))
        AND INV.CustomerID = INFO.CustomerID 
        AND INV.EmployeeID = EMP.EmployeeID;
-- Check
SELECT  * 
FROM    CN02.MENU
WHERE   MenuType = 'Ca Phe Italy';

SELECT  * 
FROM    CN02.INVOICELINE INVL, CN02.MENU ME
WHERE   InvoiceID = 'IN149' AND 
        INVL.MenuID = ME.MenuID AND
        MenuType = 'Ca Phe Italy';

-- 6// Director: Tim khach hang co tich luy cao nhat va co so lan mua hang nhieu nhat (truy van cuc bo)
-- [unchecked]
SELECT  RES.CustomerID, CustomerName, CustomerAddress, Birthday, CustomerType, CumulativeTotal, RES.NUMBERofINVOICE
FROM (  SELECT  CUSMA.CustomerID, COUNT(InvoiceID) NUMBERofINVOICE
        FROM    CN02.CUSTOMER_MANAGER CUSMA FULL OUTER JOIN CN02.INVOICE INV
        ON      CUSMA.CustomerID = INV.CustomerID
        GROUP BY CUSMA.CustomerID
        ORDER BY NUMBERofINVOICE DESC) RES, CN02.CUSTOMER_MANAGER MANA, CN02.CUSTOMER_INFO INFO
WHERE   RES.CustomerID = MANA.CustomerID AND 
        RES.CustomerID = INFO.CustomerID
ORDER BY CUMULATIVETOTAL DESC
FETCH FIRST 1 ROWS ONLY;

-- 7// Manager: Tim nhung san pham khong duoc ban trong thang 11 (truy van cuc bo)
-- [unchecked]
CONNECT Manager/manager;
SELECT  MenuID, MenuName
FROM    CN02.MENU 
WHERE   MenuID NOT IN(  SELECT  MenuID 
                        FROM    CN02.INVOICELINE INVL INNER JOIN CN02.INVOICE INV
                        ON      INVL.InvoiceID = INV.InvoiceID
                        WHERE   to_char(InvoiceDate,'MM') = '11');

--
-- CN01: Riverside Residence
-- CN01: Riverside Residence
-- CN01: Riverside Residence
--

-- 8// Staff: Dua ra thong tin menu, phan tram khuyen mai cao nhat, tong so chi nhanh phan phoi san pham thuoc loai "Tra Sua"
-- [unchecked]
CONNECT Staff/staff;
CREATE PUBLIC DATABASE LINK NV_CN02 CONNECT TO Staff IDENTIFIED BY staff USING 'CN02_LINK';

SELECT  MENU.MenuID, MENU.MenuName, MA.NUMBERofBRANCH, MA.PROMOTION
FROM    CN02.MENU@NV_CN02 MENU JOIN (SELECT MenuID, COUNT(BranchID) NUMBERofBRANCH, MAX(Promo) PROMOTION
                                        FROM (  SELECT * FROM CN02.MANAGEMENU_STAFF@NV_CN02
                                                UNION 
                                                SELECT * FROM CN01.MANAGEMENU_STAFF)
                                        GROUP BY MenuID) MA
                                        ON      MENU.MenuID = MA.MenuID
                                        WHERE   MenuType = 'Tra Sua';

-- 9// Manager: Tim khach hang co tri gia hoa don cao nhat trong thang 11 (truy van cuc bo)
-- [unchecked]
CONNECT Manager/manager;
SELECT  InvoiceID, Total, InvoiceDate, INFO.CustomerID, CustomerName, CustomerType, 
FROM    CN01.CUSTOMER_INFO INFO INNER JOIN CN01.INVOICE INV
ON      INFO.CustomerID = INV.CustomerID AND 
        InvoiceID= (SELECT InvoiceID
                    FROM   CN01.INVOICE
                    WHERE  Total = (SELECT MAX(Total)
                                    FROM   CN01.INVOICE
                                    WHERE to_char(InvoiceDate,'MM') = '11')
                    FETCH FIRST 1 ROWS ONLY);

-- 10// Manager: Tinh doanh thu tung thang trong nam 2021 cua chi nhanh nay
-- [unchecked]
SELECT  EXTRACT(month FROM InvoiceDate) "MONTH", SUM(Total) AS MONTHLY_REVENUE
FROM    CN01.INVOICE
WHERE   to_char(InvoiceDate,'YYYY') = '2021'
GROUP BY EXTRACT(month FROM InvoiceDate);

-- 11// Manager: Tim 1 san pham co luong ban ra thap nhat nam 2021
-- [unchecked]
SELECT  MenuID, MenuName, MenuType, SalePrice
FROM    CN01.MENU
WHERE   MenuID=(SELECT  MenuID
                FROM    CN01.INVOICELINE 
                GROUP BY MenuID
                ORDER BY SUM(Quantity) DESC
                FETCH FIRST 1 ROWS ONLY);

-- 12// Manager: Tim hoa don mua it nhat 15 san pham o chi nhanh minh
-- [unchecked]

SELECT  *
FROM    CN01.INVOICE
WHERE   InvoiceID IN(   SELECT  InvoiceID
                        FROM    CN01.INVOICELINE
                        WHERE   Quantity >= 15);
-- Check
SELECT * FROM CN01.INVOICELINE WHERE InvoiceID = '';






