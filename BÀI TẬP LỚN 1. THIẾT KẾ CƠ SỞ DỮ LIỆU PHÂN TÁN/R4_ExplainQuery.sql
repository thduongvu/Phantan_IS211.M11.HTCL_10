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
            UPDATE CN02.CUSTOMER_INFO
            SET CUSTOMER_INFO.CustomerType = 'Silver'
            WHERE CUSTOMER_INFO.CustomerID = cur_cusid;

            UPDATE CN01.CUSTOMER_INFO@GD_CN01
            SET CUSTOMER_INFO.CustomerType = 'Silver'
            WHERE CUSTOMER_INFO.CustomerID = cur_cusid;
            v_type := 'Silver';
        ELSIF v_total > 3000000 THEN  
            UPDATE CN02.CUSTOMER_INFO
            SET CUSTOMER_INFO.CustomerType = 'Gold'
            WHERE CUSTOMER_INFO.CustomerID = cur_cusid;

            UPDATE CN01.CUSTOMER_INFO@GD_CN01
            SET CUSTOMER_INFO.CustomerType = 'Gold'
            WHERE CUSTOMER_INFO.CustomerID = cur_cusid;
            v_type := 'Gold';  
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
    COMMIT;
END; 

-- Run Statement 
BEGIN
    calculateCumulativeTotal;
END;

5// Fix loi display sql plus //// bat dau bat camera

6// Thuc hien truy van: File: QUERY

7.0// 
-- Procedure 1// Them chi tiet hoa don (Moi lan them se tu dong tinh thanh tien va tinh lai tong hoa don) [input: ma hoa don, ma san pham, so luong]
CREATE OR REPLACE PROCEDURE addInvoiceLine (in_inv IN VARCHAR2, 
                                            in_menu IN VARCHAR2,
                                            in_quantity IN NUMBER) IS
    v_total NUMBER;
    v_price NUMBER;
    v_menuname CN02.MENU.MenuName%TYPE;
    v_quantity CN02.INVOICELINE.Quantity%TYPE;
    v_subtotal CN02.INVOICELINE.SubTotal%TYPE;
    cur_menuid VARCHAR2(5);
    CURSOR CUR IS SELECT MenuID
                    FROM CN02.INVOICELINE 
                    WHERE InvoiceID = in_inv;
    v_count NUMBER;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    
    SELECT SalePrice, MenuName
    INTO v_price, v_menuname
    FROM CN02.MENU
    WHERE MenuID = in_menu;

    -- Tinh thanh tien: subtotal = quantity * saleprice
    v_subtotal := v_price * in_quantity;
    
    -- Them chi tiet hoa don
    INSERT INTO CN02.INVOICELINE VALUES (in_inv,in_menu,in_quantity,v_subtotal);

    -- Tinh tong hoa don sau cap nhat
    SELECT sum(SubTotal) 
    INTO v_total
    FROM CN02.INVOICELINE
    WHERE InvoiceID = in_inv;

    -- Cap nhat tong hoa don
    UPDATE CN02.INVOICE
    SET Total =  v_total
    WHERE InvoiceID = in_inv;

    DBMS_OUTPUT.PUT_LINE('   Them thanh cong: ' || in_menu || ' - ' || v_menuname);
    DBMS_OUTPUT.PUT_LINE('   So luong: ' || in_quantity);
    DBMS_OUTPUT.PUT_LINE('   Don gia: ' || v_price);
    DBMS_OUTPUT.PUT_LINE('   Thanh tien: ' || v_subtotal);
    DBMS_OUTPUT.PUT_LINE('  ------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('   Tong tien tam tinh: ' || v_total);
    DBMS_OUTPUT.PUT_LINE('   Chi tiet hoa don: ' || in_inv);
    v_count := 1;
    -- In chi tiet hoa don
    OPEN CUR;
    LOOP 
        FETCH CUR INTO cur_menuid;
        EXIT WHEN CUR%NOTFOUND;
        SELECT MenuName, Quantity, SubTotal 
        INTO v_menuname, v_quantity, v_subtotal
        FROM CN02.INVOICELINE INVOICELINE, CN02.MENU MENU
        WHERE INVOICELINE.MenuID = MENU.MenuID AND
              MENU.MenuID = cur_menuid AND
              INVOICELINE.InvoiceID = in_inv;
        DBMS_OUTPUT.PUT_LINE('  ' ||  v_count ||'/ '||v_menuname || ' --- ' || v_quantity || ' --- ' || v_subtotal);
        v_count := v_count + 1;
    END LOOP;
    CLOSE CUR;
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    
    EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SYSDATE || ' Error: Khong the thuc hien!!');
END;


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


CREATE OR REPLACE PROCEDURE calculateCumulativeTotal AS       
BEGIN  
    DBMS_OUTPUT.PUT_LINE('ok');  
    
    EXCEPTION  
    WHEN OTHERS THEN  
    DBMS_OUTPUT.PUT_LINE(SYSDATE || ' Error: Khong the thuc hien!!');  
END; 

BEGIN 
    calculateCumulativeTotal;
END;