-- PROCEDURE
--
--
SET SERVEROUTPUT ON SIZE 30000;
ALTER SESSION SET NLS_DATE_FORMAT =' DD/MM/YYYY ';
CONNECT Director/director;

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

-- Run Statement
BEGIN
    addInvoiceLine('INV40','ME35',10);
END;

/* ==========================================================
   Them thanh cong: ME35 - Tra Sua Hokkaido
   So luong: 10
   Don gia: 40000
   Thanh tien: 400000
  ------------------------------------------------------
   Tong tien tam tinh: 928000
   Chi tiet hoa don: INV40
  1/ Ca Phe Den Nong/Da --- 10 --- 240000
  2/ Tra Sua Hokkaido --- 10 --- 400000
  3/ Avocado Panna Cotta Tart --- 12 --- 288000
========================================================== */

-- Procedure 2// Cap nhat tich luy cua khach hang theo thang [input: thang]
CREATE OR REPLACE PROCEDURE calculateCumulativeTotal (in_month IN VARCHAR2) AS
    v_total NUMBER;
    cur_cusid VARCHAR2(5);
    CURSOR CUR IS SELECT CustomerID
                    FROM CN02.INVOICE
                    WHERE to_char(InvoiceDate,'mm') = in_month;
    v_type CUSTOMER_INFO.CustomerType%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('==================================================================');
    -- Mac dinh loai khach hang la: Stardard
    v_type := 'Stardard';
    -- In chi tiet cap nhat
    OPEN CUR;
    LOOP 
        FETCH CUR INTO cur_cusid;
        EXIT WHEN CUR%NOTFOUND;

        -- Tinh tich luy cua khach hang
        SELECT SUM (Total) 
        INTO v_total
        FROM (  SELECT Total
                FROM CN02.INVOICE
                WHERE CustomerID = cur_cusid;
                UNION
                SELECT Total
                FROM CN01.INVOICE@GD_CN01
                WHERE CustomerID = cur_cusid;);

        -- Cap nhat tich luy cua khach hang
        UPDATE CN02.CUSTOMER_MANAGER
        SET CumulativeTotal = v_total
        WHERE CustomerID = cur_cusid; 
        UPDATE CN01.CUSTOMER_MANAGER@GD_CN01
        SET CumulativeTotal = v_total
        WHERE CustomerID = cur_cusid; 

        -- Cap nhap loai khach hang
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
        
        DBMS_OUTPUT.PUT_LINE('   Cap nhat thanh cong tich luy cua: ' || cur_cusid || ' = ' ||  v_total || ' - ' || v_type);
    END LOOP;
    CLOSE CUR;
    DBMS_OUTPUT.PUT_LINE('==================================================================');
    
    EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SYSDATE || ' Error: Khong the thuc hien!!');
END;

-- Run Statement 
BEGIN
    calculateCumulativeTotal('11');
END;

/* ==================================================================
   Cap nhat thanh cong tich luy cua: CUS06 = 288000 - Stardard
   Cap nhat thanh cong tich luy cua: CUS07 = 228000 - Stardard
   Cap nhat thanh cong tich luy cua: CUS08 = 300000 - Stardard
   Cap nhat thanh cong tich luy cua: CUS09 = 768000 - Stardard
   Cap nhat thanh cong tich luy cua: CUS10 = 1530000 - Silver
   Cap nhat thanh cong tich luy cua: CUS11 = 620000 - Silver
   Cap nhat thanh cong tich luy cua: CUS12 = 660000 - Silver
   Cap nhat thanh cong tich luy cua: CUS13 = 384000 - Silver
   Cap nhat thanh cong tich luy cua: CUS32 = 528000 - Silver
   Cap nhat thanh cong tich luy cua: CUS20 = 1528000 - Silver
   Cap nhat thanh cong tich luy cua: CUS11 = 620000 - Silver
   Cap nhat thanh cong tich luy cua: CUS17 = 480000 - Silver
   Cap nhat thanh cong tich luy cua: CUS05 = 624000 - Silver
   Cap nhat thanh cong tich luy cua: CUS30 = 912000 - Silver
   Cap nhat thanh cong tich luy cua: CUS10 = 1530000 - Silver
   Cap nhat thanh cong tich luy cua: CUS20 = 1528000 - Silver
================================================================== */

-- Procedure 3// In hoa don [input: ma hoa don]
CREATE OR REPLACE PROCEDURE printInvoice (invid IN VARCHAR2) AS
    r_invoice CN02.INVOICE%ROWTYPE;
    v_cusid VARCHAR2(5);
    r_customerinfo CN02.CUSTOMER_INFO%ROWTYPE;
    v_branchid VARCHAR2(5);
    r_branch CN02.BRANCH%ROWTYPE;
    v_empid VARCHAR2(5);
    r_emp CN02.EMPLOYEE%ROWTYPE;
    cur_menuid VARCHAR2(5);
    CURSOR CUR IS SELECT MenuID
                    FROM CN02.INVOICELINE 
                    WHERE InvoiceID = invid;
    v_menuname CN02.MENU.MenuName%TYPE;
    v_quantity CN02.INVOICELINE.Quantity%TYPE;
    v_subtotal CN02.INVOICELINE.SubTotal%TYPE;
BEGIN
    SELECT *
    INTO r_invoice
    FROM CN02.INVOICE
    WHERE InvoiceID = invid;
    
    SELECT CustomerID, BranchID, EmployeeID
    INTO v_cusid, v_branchid, v_empid
    FROM CN02.INVOICE
    WHERE InvoiceID = invid;
    
    SELECT *
    INTO r_customerinfo
    FROM CN02.CUSTOMER_INFO
    WHERE CustomerID = v_cusid;
    
    SELECT *
    INTO r_branch
    FROM CN02.BRANCH
    WHERE BranchID = v_branchid;
    
    SELECT *
    INTO r_emp
    FROM CN02.EMPLOYEE
    WHERE EmployeeID = v_empid;
    
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('              HOA DON: ' || r_invoice.InvoiceID);
    DBMS_OUTPUT.PUT_LINE('=============================================');
    DBMS_OUTPUT.PUT_LINE('   Chi nhanh: ' || v_branchid || ' - ' || r_branch.BranchName);
    DBMS_OUTPUT.PUT_LINE('   Nhan vien: ' || v_empid || ' - ' || r_emp.EmployeeName);
    DBMS_OUTPUT.PUT_LINE('   Khach hang: ' || v_cusid || ' - ' || r_customerinfo.CustomerName);
    DBMS_OUTPUT.PUT_LINE('   Ngay hoa don: ' || r_invoice.InvoiceDate );
    DBMS_OUTPUT.PUT_LINE('  ________________________________________ ');

    -- In chi tiet hoa don
    OPEN CUR;
    LOOP 
        FETCH CUR INTO cur_menuid;
        EXIT WHEN CUR%NOTFOUND;
        SELECT MenuName, Quantity, SubTotal 
        INTO v_menuname, v_quantity, v_subtotal
        FROM CN02.INVOICELINE, CN02.MENU
        WHERE INVOICELINE.MenuID = MENU.MenuID AND
              MENU.MenuID = cur_menuid AND
              INVOICELINE.InvoiceID = invid;
        DBMS_OUTPUT.PUT_LINE('   '||v_menuname || ' --- ' || v_quantity || ' --- ' || v_subtotal);
    END LOOP;
    CLOSE CUR;
    DBMS_OUTPUT.PUT_LINE('  ________________________________________ ');
    DBMS_OUTPUT.PUT_LINE('   Tong tien: ' || r_invoice.Total );
    DBMS_OUTPUT.PUT_LINE('   Hang thanh vien: ' || r_customerinfo.CustomerType );
    DBMS_OUTPUT.PUT_LINE('=============================================');
    DBMS_OUTPUT.PUT_LINE('   Ngay xuat: ' || SYSDATE);
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
    
    EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: Hoa don nay khong ton tai trong he thong!!');
END;

-- Run Statement
BEGIN
    printInvoice('INV10');
END;

/* ---------------------------------------------
              HOA DON: INV40
=============================================
   Chi nhanh: BR15 - Riverside Residence
   Nhan vien: EMP13 - Ho Nam Kha
   Khach hang: CUS20 - Nguyen Thi Ngoc Mai
   Ngay hoa don:  17/11/2021 
  ________________________________________ 
   Ca Phe Den Nong/Da --- 10 --- 240000
   Avocado Panna Cotta Tart --- 12 --- 288000
  ________________________________________ 
   Tong tien: 528000
   Hang thanh vien: Stardard
=============================================
   Ngay xuat:  09/12/2021 
--------------------------------------------- */

-- Procedure 4// In thong tin khach hang + Hang thanh vien + Tien tich luy + So don hang da mua + So chi nhanh da mua hang [input: ma khach hang]
CREATE OR REPLACE PROCEDURE printCustomerInfo (cusid IN VARCHAR2) AS
    r_customerinfo CN02.CUSTOMER_INFO%ROWTYPE;
    r_customermanager CN02.CUSTOMER_MANAGER%ROWTYPE;
    r_numberofinvoice NUMBER;
    r_numberofbranch NUMBER;
    r_invoice CN02.INVOICE%ROWTYPE;
    r_branch CN02.BRANCH%ROWTYPE;
BEGIN
    SELECT * 
    INTO r_customerinfo
    FROM CN02.CUSTOMER_INFO 
    WHERE CustomerID = cusid;
    
    SELECT *
    INTO r_customermanager
    FROM CN02.CUSTOMER_MANAGER
    WHERE CustomerID = cusid;
    
    -- Dem so luong hoa don da mua
    SELECT count(CustomerID) 
    INTO r_numberofinvoice
    FROM CN02.INVOICE
    WHERE CustomerID = cusid;

    -- Dem so luong chi nhanh da mua
    SELECT count(DISTINCT BranchID) 
    INTO r_numberofbranch
    FROM CN02.INVOICE
    WHERE CustomerID = cusid;
    
    SELECT *
    INTO r_invoice
    FROM CN02.INVOICE
    WHERE CustomerID = cusid
    ORDER BY InvoiceDate DESC
    FETCH FIRST 1 ROWS ONLY;
    
    SELECT *
    INTO r_branch
    FROM CN02.BRANCH
    WHERE BranchID = r_invoice.BranCHID;

    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('         THONG TIN KHACH HANG: ' || r_customerinfo.CustomerID);
    DBMS_OUTPUT.PUT_LINE('=============================================');
    DBMS_OUTPUT.PUT_LINE('   Ho va ten: ' || r_customerinfo.CustomerName );
    DBMS_OUTPUT.PUT_LINE('   So dien thoai: ' || r_customerinfo.PhoneNumber );
    DBMS_OUTPUT.PUT_LINE('   Dia chi: ' || r_customerinfo.CustomerAddress );
    DBMS_OUTPUT.PUT_LINE('   Ngay sinh: ' || r_customerinfo.Birthday);
    DBMS_OUTPUT.PUT_LINE('  _________________________________________');
    DBMS_OUTPUT.PUT_LINE('   So luong don hang da thuc hien: ' || r_numberofinvoice);
    DBMS_OUTPUT.PUT_LINE('   So chi nhanh da mua hang: ' || r_numberofbranch);
    DBMS_OUTPUT.PUT_LINE('   Tich luy: ' || r_customermanager.CumulativeTotal );
    DBMS_OUTPUT.PUT_LINE('   Thanh vien: ' || r_customerinfo.CustomerType );
    DBMS_OUTPUT.PUT_LINE('=============================================');
    DBMS_OUTPUT.PUT_LINE('   Don hang gan day: ' || r_invoice.InvoiceID || ' - ' || r_invoice.InvoiceDate);
    DBMS_OUTPUT.PUT_LINE('   Chi nhanh gan day: ' || r_invoice.BranchID || ' - ' || r_branch.BranchName);
    DBMS_OUTPUT.PUT_LINE('   Ngay xuat: ' || SYSDATE);
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');

    EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: Khach hang nay khong ton tai trong he thong!!');
END;

-- Run Statement
BEGIN
    printCustomerInfo('CUS11');
END;

/* ---------------------------------------------
         THONG TIN KHACH HANG: CUS11
=============================================
   Ho va ten: Nguyen Hieu Kien
   So dien thoai: 0931127827
   Dia chi: Vung Tau
   Ngay sinh:  23/01/2001 
  _________________________________________
   So luong don hang da thuc hien: 2
   So chi nhanh da mua hang: 1
   Tich luy: 310000
   Thanh vien: Stardard
=============================================
   Don hang gan day: INV35 -  16/11/2021 
   Chi nhanh gan day: BR15 - Riverside Residence
   Ngay xuat:  09/12/2021 
--------------------------------------------- */

-- Procedure 5// Cap nhat quan ly Menu [input: ma chi nhanh, ma san pham, stage]
CREATE OR REPLACE PROCEDURE updateMenuManager (in_branch IN VARCHAR2, 
                                            in_menu IN VARCHAR2,
                                            in_stage IN NUMBER) IS
    r_branch CN02.BRANCH%ROWTYPE;
    r_menu CN02.MENU%ROWTYPE;
    v_status CN02.MANAGEMENU_STAFF.Status%TYPE;
BEGIN
    SELECT *
    INTO r_branch
    FROM CN02.BRANCH
    WHERE BranchID = in_branch;
    
    SELECT *
    INTO r_menu
    FROM CN02.MENU
    WHERE MenuID = in_menu;
    
    UPDATE CN02.MANAGEMENU_MANAGER
    SET Stage = in_stage, UpdatedDate = SYSDATE
    WHERE BranchID = in_branch AND MenuID = in_menu;
    
    IF in_stage = 0 THEN
        UPDATE CN02.MANAGEMENU_STAFF
        SET Status = 'Khong Duoc Phep Ban'
        WHERE BranchID = in_branch AND MenuID = in_menu;
        v_status := 'Khong Duoc Phep Ban';
    ELSE
        UPDATE CN02.MANAGEMENU_STAFF
        SET Status = 'Duoc Phep Ban'
        WHERE BranchID = in_branch AND MenuID = in_menu;
        v_status := 'Duoc Phep Ban';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('=============================================================');
    DBMS_OUTPUT.PUT_LINE('  Cap nhat thanh cong tai: ' || in_branch || ' - ' || r_branch.BranchName);
    DBMS_OUTPUT.PUT_LINE('  Thong tin: ' || in_menu || ' - ' || r_menu.MenuName);
    DBMS_OUTPUT.PUT_LINE('  Trang thai: ' || in_stage || ' - ' || v_status);
    DBMS_OUTPUT.PUT_LINE('=============================================================');
    
    EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SYSDATE || ' Error: Khong the thuc hien!!');
END;

-- Run Statement
BEGIN
    updateMenuManager('BR15','ME30',0);
END;

/* =============================================================
  Cap nhat thanh cong tai: BR15 - Riverside Residence
  Thong tin: ME30 - Tra Sua Okinawa Coffee
  Trang thai: 0 - Khong Duoc Phep Ban
============================================================= */