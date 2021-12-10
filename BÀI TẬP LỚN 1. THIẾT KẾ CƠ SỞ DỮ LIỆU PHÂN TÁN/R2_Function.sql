-- FUNCTION
--
--

-- Function 1// Tinh doanh thu hang thang [input: thang]
CREATE OR REPLACE FUNCTION calculateMonthlyRevenue(in_month IN number)
RETURN NUMBER
AS
    v_total number;
BEGIN
    SELECT SUM (Total) 
    INTO v_total
    FROM (  SELECT Total
            FROM CN02.INVOICE
            WHERE EXTRACT(MONTH FROM InvoiceDate) = in_month
            UNION
            SELECT Total
            FROM CN01.INVOICE@GD_CN01
            WHERE EXTRACT(MONTH FROM InvoiceDate) = in_month);
    RETURN v_total;
END;

CREATE OR REPLACE FUNCTION calculateMonthlyRevenue(in_month IN number)
RETURN NUMBER
AS
    v_total number;
BEGIN
    SELECT SUM (Total) 
    INTO v_total
    FROM (  SELECT Total
            FROM INVOICE
            WHERE EXTRACT(MONTH FROM InvoiceDate) = in_month);
    RETURN v_total;
END;
/

-- Run Statement 
DECLARE
    in_month NUMBER;
BEGIN
    in_month := 11;
    DBMS_OUTPUT.PUT_LINE('===================================');
    DBMS_OUTPUT.PUT_LINE('         THONG KE THANG: ' || in_month);
    DBMS_OUTPUT.PUT_LINE('   Tong doanh thu: ' || calculateMonthlyRevenue(in_month) || ' VND');
    DBMS_OUTPUT.PUT_LINE('   Ngay xuat: ' || SYSDATE);
    DBMS_OUTPUT.PUT_LINE('===================================');
END;
/

/* ===================================
          THONG KE THANG: 11
    Tong doanh thu: 8498000 VND
    Ngay xuat:  09/12/2021 
=================================== */

-- Function 2// Tinh ngay nghi huu cua nhan vien [input: ma nhan vien]
CREATE OR REPLACE FUNCTION getRetireDateOfEmployee(in_empid EMPLOYEE.EmployeeID%TYPE) 
RETURN DATE 
AS
    v_year NUMBER;
    v_birthday EMPLOYEE.Birthday%TYPE;
    v_retire EMPLOYEE.Birthday%TYPE;
BEGIN
    SELECT Birthday
    INTO v_birthday
    FROM EMPLOYEE
    WHERE EmployeeID = in_empid;
    
    v_year := 60;
    v_retire := add_months(v_birthday, 12*v_year);
    RETURN v_retire;
END;
/

-- Run Statement 
DECLARE
    in_empid EMPLOYEE.EmployeeID%TYPE;
BEGIN
    in_empid := 'EMP11';
    
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('         THONG TIN NHAN VIEN: ' || in_empid);
    DBMS_OUTPUT.PUT_LINE('   Ngay nghi huu du kien: ' || getRetireDateOfEmployee(in_empid));
    DBMS_OUTPUT.PUT_LINE('   Ngay xuat: ' || SYSDATE);
    DBMS_OUTPUT.PUT_LINE('==========================================');
END;
/

/* ==========================================
         THONG TIN NHAN VIEN: EMP11
   Ngay nghi huu du kien:  21/07/2061 
   Ngay xuat:  09/12/2021 
========================================== */




