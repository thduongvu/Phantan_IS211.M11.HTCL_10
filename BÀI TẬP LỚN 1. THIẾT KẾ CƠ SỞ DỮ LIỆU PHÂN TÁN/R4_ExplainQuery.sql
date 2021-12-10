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

////////////// TO DO LIST 
////////////// TO DO LIST 
////////////// TO DO LIST 

1// Nhap them du lieu vao tung chi nhanh 
ALTER SESSION SET NLS_DATE_FORMAT =' DD/MM/YYYY ';

2// grant them quyen cho director
GRANT SELECT, INSERT, UPDATE ON CN02.MENU TO Director;
GRANT SELECT, INSERT, UPDATE ON CN02.MANAGEMENU_MANAGER TO Director;
GRANT SELECT, INSERT, UPDATE ON CN02.MANAGEMENU_STAFF TO Director;
GRANT SELECT, INSERT, UPDATE ON CN02.EMPLOYEE TO Director;
GRANT SELECT, INSERT, UPDATE ON CN02.BRANCH TO Director;
GRANT SELECT, INSERT, UPDATE ON CN02.CUSTOMER_INFO TO Director;
GRANT SELECT, INSERT, UPDATE ON CN02.CUSTOMER_MANAGER TO Director;
GRANT SELECT, INSERT, UPDATE ON CN02.INVOICE TO Director;
GRANT SELECT, INSERT, UPDATE ON CN02.INVOICELINE TO Director;

GRANT SELECT, INSERT, UPDATE ON CN02.MENU TO Manager;
GRANT SELECT, INSERT, UPDATE ON CN02.MANAGEMENU_MANAGER TO Manager;
GRANT SELECT, INSERT, UPDATE ON CN02.MANAGEMENU_STAFF TO Manager;
GRANT SELECT, INSERT, UPDATE ON CN02.EMPLOYEE TO Manager;
GRANT SELECT, INSERT, UPDATE ON CN02.BRANCH TO Manager;
GRANT SELECT, INSERT, UPDATE ON CN02.CUSTOMER_INFO TO Manager;
GRANT SELECT, INSERT, UPDATE ON CN02.CUSTOMER_MANAGER TO Manager;
GRANT SELECT, INSERT, UPDATE ON CN02.INVOICE TO Manager;
GRANT SELECT, INSERT, UPDATE ON CN02.INVOICELINE TO Manager;

GRANT SELECT, INSERT, UPDATE ON CN01.MENU TO Manager;
GRANT SELECT, INSERT, UPDATE ON CN01.MANAGEMENU_MANAGER TO Manager;
GRANT SELECT, INSERT, UPDATE ON CN01.MANAGEMENU_STAFF TO Manager;
GRANT SELECT, INSERT, UPDATE ON CN01.EMPLOYEE TO Manager;
GRANT SELECT, INSERT, UPDATE ON CN01.BRANCH TO Manager;
GRANT SELECT, INSERT, UPDATE ON CN01.CUSTOMER_INFO TO Manager;
GRANT SELECT, INSERT, UPDATE ON CN01.CUSTOMER_MANAGER TO Manager;
GRANT SELECT, INSERT, UPDATE ON CN01.INVOICE TO Manager;
GRANT SELECT, INSERT, UPDATE ON CN01.INVOICELINE TO Manager;

3// Thay doi stage cho menumanager
CONNECT Manager/Manager;
UPDATE  CN02.MANAGEMENU_MANAGER
SET     Stage = 0
WHERE   (MenuID = 'ME30' OR MenuID = 'ME31' OR MenuID = 'ME32' OR MenuID = 'ME33' OR MenuID = 'ME34' OR MenuID = 'ME35' OR 
        MenuID = 'ME36' OR MenuID = 'ME37' OR MenuID = 'ME38' OR MenuID = 'ME39' OR MenuID = 'ME40' OR MenuID = 'ME41' OR
        MenuID = 'ME42' OR MenuID = 'ME43' OR MenuID = 'ME44' OR MenuID = 'ME45');

CONNECT Manager/Manager;
UPDATE  CN01.MANAGEMENU_MANAGER
SET     Stage = 0
WHERE   (MenuID = 'ME25' OR MenuID = 'ME26' OR MenuID = 'ME27' OR MenuID = 'ME28' OR MenuID = 'ME29' OR MenuID = 'ME30' OR 
        MenuID = 'ME31' OR MenuID = 'ME32' OR MenuID = 'ME33' OR MenuID = 'ME34' OR MenuID = 'ME35' OR MenuID = 'ME36' OR
        MenuID = 'ME37' OR MenuID = 'ME38' OR MenuID = 'ME39' OR MenuID = 'ME40');

4// Excute Procedure 2// Cap nhat tich luy cua khach hang 
CONNECT Director/director;
CREATE OR REPLACE PROCEDURE calculateCumulativeTotal AS  
    v_total NUMBER;  
    v_total1 NUMBER;  
    v_total2 NUMBER;  
    cur_cusid VARCHAR2(5);  
    CURSOR CUR IS SELECT CustomerID  
                    FROM CN02.CUSTOMER_MANAGER; 
    v_type CN02.CUSTOMER_INFO.CustomerType%TYPE;  
BEGIN  
    DBMS_OUTPUT.PUT_LINE('==================================================================');  
    
    OPEN CUR;  
    LOOP   
        FETCH CUR INTO cur_cusid;  
        EXIT WHEN CUR%NOTFOUND;  
         
        v_type := 'Stardard';
        v_total := 0;
        
        -- Tinh tich luy cua khach hang
        SELECT sum(Total)   
        INTO v_total1
        FROM CN02.INVOICE  
        WHERE CustomerID = cur_cusid; 
        
        SELECT sum(Total)   
        INTO v_total2 
        FROM CN01.INVOICE@GD_CN01
        WHERE CustomerID = cur_cusid; 
        
        v_total := v_total1 + v_total2;
        
        -- Cap nhat tich luy cua khach hang
        UPDATE CN02.CUSTOMER_MANAGER
        SET CumulativeTotal = v_total
        WHERE CustomerID = cur_cusid; 

        UPDATE CN01.CUSTOMER_MANAGER@GD_CN01
        SET CumulativeTotal = v_total
        WHERE CustomerID = cur_cusid;   
  
        IF v_total > 1000000 AND v_total <= 3000000 THEN  
        BEGIN
            UPDATE CN02.CUSTOMER_INFO
            SET CUSTOMER_INFO.CustomerType = 'Silver'
            WHERE CUSTOMER_INFO.CustomerID = cur_cusid;

            UPDATE CN01.CUSTOMER_INFO@GD_CN01
            SET CUSTOMER_INFO.CustomerType = 'Silver'
            WHERE CUSTOMER_INFO.CustomerID = cur_cusid;
            v_type := 'Silver';
        END
        ELSIF v_total > 3000000 THEN  
        BEGIN
            UPDATE CN02.CUSTOMER_INFO
            SET CUSTOMER_INFO.CustomerType = 'Gold'
            WHERE CUSTOMER_INFO.CustomerID = cur_cusid;

            UPDATE CN01.CUSTOMER_INFO@GD_CN01
            SET CUSTOMER_INFO.CustomerType = 'Gold'
            WHERE CUSTOMER_INFO.CustomerID = cur_cusid;
            v_type := 'Gold';  
        END
        END IF;  
        
        IF v_total != 0 THEN
        DBMS_OUTPUT.PUT_LINE('   Cap nhat thanh cong tich luy cua: ' || cur_cusid || ' = ' ||  v_total || ' - ' || v_type);  
        END IF;
        
    END LOOP;  
    CLOSE CUR;  
    DBMS_OUTPUT.PUT_LINE('==================================================================');  
      
    EXCEPTION  
    WHEN OTHERS THEN  
    DBMS_OUTPUT.PUT_LINE(SYSDATE || ' Error: Khong the thuc hien!!');  
END; 

-- Run Statement 
BEGIN
    calculateCumulativeTotal;
END;

5// Fix loi display sql plus //// bat dau bat camera

6// Thuc hien truy van: File: QUERY

7// Trigger: FILE: TRIGGER

8// set lai stage  
CONNECT Manager/Manager;
UPDATE  CN02.MANAGEMENU_MANAGER
SET     Stage = 1;

CONNECT Manager/Manager;
UPDATE  CN01.MANAGEMENU_MANAGER
SET     Stage = 1;

9// Procedure: FILE: PROCEDURE

10// Function: FILE: FUNCTION

11// Isolation: FILE: ISOLATION LEVEL

12/ Explain Query: FILE: EXPLAIN QUERY


