-- Tao User, Grant quyen
CREATE USER CN01 IDENTIFIED BY CN01;
CREATE USER CN02 IDENTIFIED BY CN02;
CREATE USER Director IDENTIFIED BY director;
CREATE USER Manager IDENTIFIED BY manager;
CREATE USER Staff IDENTIFIED BY staff;
GRANT CONNECT, DBA TO CN01;

-- Dung tai khoan CN01 connect den chi nhanh 1 de tao bang
CONNECT CN01/CN01;

-- SETTING TABLES
--
--

-- Setting table MENU (Replication) 
CREATE TABLE CN01.MENU (
    MenuID VARCHAR2(5) NOT NULL,
    MenuName VARCHAR2(50) NOT NULL,
    MenuType VARCHAR2(50) NULL,
    SalePrice NUMBER NULL,
    CONSTRAINT PK_MENU PRIMARY KEY (MenuID)
);

-- Setting table CN01.BRANCH (Phan manh ngang)
CREATE TABLE CN01.BRANCH (
    BranchID VARCHAR2(5) NOT NULL,
    BranchName VARCHAR2(50) NOT NULL,
    BranchAddress VARCHAR2(100) NULL,
    BranchPhone VARCHAR2(10) NULL,
    CONSTRAINT PK_BRANCH PRIMARY KEY (BranchID)
);

-- Setting table CN01.EMPLOYEE (Phan manh ngang dan xuat)
CREATE TABLE CN01.EMPLOYEE (
    EmployeeID VARCHAR2(5) NOT NULL,
    EmployeeName VARCHAR2(50) NOT NULL,
    Birthday DATE NULL,
    PhoneNumber VARCHAR2(10) NULL,
    EmployeeAddress VARCHAR2(50) NULL,
    BranchID VARCHAR2(5) NOT NULL,
    CONSTRAINT PK_EMPLOYEE PRIMARY KEY (EmployeeID)
);

-- Setting table CN01.INVOICE (Phan manh ngang dan xuat)
CREATE TABLE CN01.INVOICE (
    InvoiceID VARCHAR2(5) NOT NULL,
    InvoiceDate DATE NOT NULL,
    CustomerID VARCHAR2(5) NOT NULL,
    EmployeeID VARCHAR2(5) NOT NULL,
    Total NUMBER NULL,
    BranchID VARCHAR2(5) NOT NULL,
    CONSTRAINT PK_INVOICE PRIMARY KEY (InvoiceID)
);

-- Setting table CN01.INVOICELINE 
CREATE TABLE CN01.INVOICELINE (
    InvoiceID VARCHAR2(5) NOT NULL,
    MenuID VARCHAR2(5) NOT NULL,
    Quantity NUMBER NULL,
    SubTotal NUMBER NULL,
    CONSTRAINT PK_INVOICELINE PRIMARY KEY (InvoiceID, MenuID)
);

-- Setting table CN01.CUSTOMER_INFO
CREATE TABLE CN01.CUSTOMER_INFO (
    CustomerID VARCHAR2(5) NOT NULL,
    CustomerName VARCHAR2(50) NOT NULL,
    PhoneNumber VARCHAR2(10) NULL,
    CustomerAddress VARCHAR2(50) NULL,
    Birthday DATE NULL,
    CustomerType VARCHAR2(25) NULL,
    CONSTRAINT PK_CUSTOMERINFO PRIMARY KEY (CustomerID)
);

-- Setting table CN01.CUSTOMER_MANAGER
CREATE TABLE CN01.CUSTOMER_MANAGER (
    CustomerID VARCHAR2(5) NOT NULL,
    CumulativeTotal NUMBER,
    CONSTRAINT PK_CUSTOMERMANAGER PRIMARY KEY (CustomerID)
);

-- Setting table CN01.MANAGEMENU_MANAGER (Phan manh doc khong du thua tu bang MANAGEMENU) 
CREATE TABLE CN01.MANAGEMENU_MANAGER (
    BranchID VARCHAR2(5) NOT NULL,
    MenuID VARCHAR2(5) NOT NULL,
    Stage NUMBER NULL,
    UpdatedDate DATE NULL,
    CONSTRAINT PK_MENUMANAGER PRIMARY KEY (BranchID, MenuID)
);

-- Setting table CN01.MANAGEMENU_STAFF (Phan manh doc khong du thua tu bang MANAGEMENU) 
CREATE TABLE CN01.MANAGEMENU_STAFF (
    BranchID VARCHAR2(5) NOT NULL,
    MenuID VARCHAR2(5) NOT NULL,
    Status VARCHAR2(25) NULL,
    Promo NUMBER NULL,
    CONSTRAINT PK_MENUSTAFF PRIMARY KEY (BranchID, MenuID)
);

-- SETTING FOREIGN KEYS
--
--

ALTER TABLE CN01.EMPLOYEE
ADD CONSTRAINT FK_EMPLOYEE_BRANCH FOREIGN KEY (BranchID) REFERENCES CN01.BRANCH(BranchID);

ALTER TABLE CN01.INVOICE
ADD CONSTRAINT FK_INVOICE_CUSTOMER FOREIGN KEY (CustomerID) REFERENCES CN01.CUSTOMER_INFO(CustomerID);

ALTER TABLE CN01.INVOICE
ADD CONSTRAINT FK_INVOICE_EMPLOYEE FOREIGN KEY (EmployeeID) REFERENCES CN01.EMPLOYEE(EmployeeID);

ALTER TABLE CN01.INVOICE
ADD CONSTRAINT FK_INVOICE_BRANCH FOREIGN KEY (BranchID) REFERENCES CN01.BRANCH(BranchID);

ALTER TABLE CN01.INVOICELINE
ADD CONSTRAINT FK_INVOICELINE_INVOICE FOREIGN KEY (InvoiceID) REFERENCES CN01.INVOICE(InvoiceID);

ALTER TABLE CN01.INVOICELINE
ADD CONSTRAINT FK_INVOICELINE_MENU FOREIGN KEY (MenuID) REFERENCES CN01.MENU(MenuID);

ALTER TABLE CN01.MANAGEMENU_MANAGER
ADD CONSTRAINT FK_MENUMANAGER_BRANCH FOREIGN KEY (BranchID) REFERENCES CN01.BRANCH(BranchID);

ALTER TABLE CN01.MANAGEMENU_MANAGER
ADD CONSTRAINT FK_MENUMANAGER_MENU FOREIGN KEY (MenuID) REFERENCES CN01.MENU(MenuID);

ALTER TABLE CN01.MANAGEMENU_STAFF
ADD CONSTRAINT FK_MENUSTAFF_BRANCH FOREIGN KEY (BranchID) REFERENCES CN01.BRANCH(BranchID);

ALTER TABLE CN01.MANAGEMENU_STAFF
ADD CONSTRAINT FK_MENUSTAFF_MENU FOREIGN KEY (MenuID) REFERENCES CN01.MENU(MenuID);

-- CREATE TRIGGER
--
--
-- Trigger: Khong the them vao chi tiet hoa don san pham o trang thai "Khong duoc phep ban"
CREATE OR REPLACE TRIGGER  TRIGGER_INSERT_UPDATE_ON_INVOICELINE
BEFORE INSERT OR UPDATE ON CN01.INVOICELINE
FOR EACH ROW
DECLARE
    v_status CN01.MANAGEMENU_STAFF.Status%TYPE;
BEGIN
    SELECT Status
    INTO v_status
    FROM CN01.MANAGEMENU_STAFF
    WHERE MenuID = :NEW.MenuID;
    
	IF v_status != 'Duoc Phep Ban' THEN
		BEGIN
		RAISE_APPLICATION_ERROR (-20102,'San pham khong duoc phep tai chi nhanh nay!');
		ROLLBACK;
		END;
	END IF;
END;

CREATE OR REPLACE TRIGGER  TRIGGER_INSERT_UPDATE_ON_MANAGEMENU_MANAGER
AFTER INSERT OR UPDATE ON CN01.MANAGEMENU_MANAGER
FOR EACH ROW
BEGIN    
	IF :NEW.Stage = 1 THEN
		UPDATE CN01.MANAGEMENU_STAFF
        SET Status = 'Duoc Phep Ban'
        WHERE MenuID = :NEW.MenuID;
    ELSE
        UPDATE CN01.MANAGEMENU_STAFF
        SET Status = 'Khong Duoc Phep Ban'
        WHERE MenuID = :NEW.MenuID;
	END IF;
END;


-- INSERT DATA
--
--

-- Date format
ALTER SESSION SET NLS_DATE_FORMAT =' DD/MM/YYYY ';

-- Insert to CN01.MENU
INSERT INTO CN01.MENU VALUES ('ME01','Sinh To Dau','Sinh To',20000);
INSERT INTO CN01.MENU VALUES ('ME02','Sinh To Bo','Sinh To',15000);
INSERT INTO CN01.MENU VALUES ('ME03','Sinh To Mang Cau','Sinh To',18000);
INSERT INTO CN01.MENU VALUES ('ME04','Sinh To Sapoche','Sinh To',15000);
INSERT INTO CN01.MENU VALUES ('ME05','Ca Phe Den Nong/Da','Ca Phe Pha Phin',24000);
INSERT INTO CN01.MENU VALUES ('ME06','Ca Phe Nau Nong/Da','Ca Phe Pha Phin',28000);
INSERT INTO CN01.MENU VALUES ('ME07','Ca Phe Sua Tuoi Nong/Da','Ca Phe Pha Phin',32000);
INSERT INTO CN01.MENU VALUES ('ME08','Ca Phe Sua Bac Ha','Ca Phe Pha Phin',34000);
INSERT INTO CN01.MENU VALUES ('ME09','Ca Phe Trung','Ca Phe Pha Phin',70000);
INSERT INTO CN01.MENU VALUES ('ME10','Latte Macchiato','Ca Phe Italy',45000);
INSERT INTO CN01.MENU VALUES ('ME11','Cappuccino','Ca Phe Italy',45000);
INSERT INTO CN01.MENU VALUES ('ME12','Caffé Latte','Ca Phe Italy',45000);
INSERT INTO CN01.MENU VALUES ('ME13','Mocaccino','Ca Phe Italy',45000);
INSERT INTO CN01.MENU VALUES ('ME14','Ristretto','Ca Phe Italy',45000);
INSERT INTO CN01.MENU VALUES ('ME15','Espresso','Ca Phe Italy',45000);
INSERT INTO CN01.MENU VALUES ('ME16','Lungo Espresso','Ca Phe Italy',45000);
INSERT INTO CN01.MENU VALUES ('ME17','Tra Gao Nau','Tra',30000);
INSERT INTO CN01.MENU VALUES ('ME18','Tra Dau','Tra',30000);
INSERT INTO CN01.MENU VALUES ('ME19','Tra Hoa Luc Tra','Tra',30000);
INSERT INTO CN01.MENU VALUES ('ME20','Tra Bi Dao','Tra',30000);
INSERT INTO CN01.MENU VALUES ('ME21','Tra Vai','Tra',36000);
INSERT INTO CN01.MENU VALUES ('ME22','Tra Mat Ong','Tra',39000);
INSERT INTO CN01.MENU VALUES ('ME23','Tra Alisan','Tra',39000);
INSERT INTO CN01.MENU VALUES ('ME24','Tra Oolong','Tra',39000);
INSERT INTO CN01.MENU VALUES ('ME25','Tra Den','Tra',39000);
INSERT INTO CN01.MENU VALUES ('ME26','Yogurt Blueberry','Da Xay',30000);
INSERT INTO CN01.MENU VALUES ('ME27','Choco Caramel','Da Xay',35000);
INSERT INTO CN01.MENU VALUES ('ME28','Matcha','Da Xay',32000);
INSERT INTO CN01.MENU VALUES ('ME29','Tra Sua Gao Nau','Da Xay',30000);
INSERT INTO CN01.MENU VALUES ('ME30','Tra Sua Okinawa Coffee','Da Xay',45000);
INSERT INTO CN01.MENU VALUES ('ME31','Tra Sua Okinawa Oreo Cream','Da Xay',45000);
INSERT INTO CN01.MENU VALUES ('ME32','Tra Sua Hokkaido','Tra Sua',38000);
INSERT INTO CN01.MENU VALUES ('ME33','Tra Sua Earl Grey','Tra Sua',38000);
INSERT INTO CN01.MENU VALUES ('ME34','Tra Sua Hazelnut','Tra Sua',38000);
INSERT INTO CN01.MENU VALUES ('ME35','Tra Sua Hokkaido','Tra Sua',40000);
INSERT INTO CN01.MENU VALUES ('ME36','Tra Sua Earl Grey','Tra Sua',40000);
INSERT INTO CN01.MENU VALUES ('ME37','Tra Sua Hazelnut','Tra Sua',40000);
INSERT INTO CN01.MENU VALUES ('ME38','Tra Sua Oreo','Tra Sua',40000);
INSERT INTO CN01.MENU VALUES ('ME39','Tra Sua Panna Cotta','Tra Sua',40000);
INSERT INTO CN01.MENU VALUES ('ME40','Tra Sua Hoa Dau Biec','Tra Sua',30000);
INSERT INTO CN01.MENU VALUES ('ME41','Tra Sua Chocolate Cake Cream','Tra Sua',35000);
INSERT INTO CN01.MENU VALUES ('ME42','Tiramisu','Banh Ngot',24000);
INSERT INTO CN01.MENU VALUES ('ME43','Oreo Cheesecake','Banh Ngot',24000);
INSERT INTO CN01.MENU VALUES ('ME44','Brownie Cookies Ice Cream','Banh Ngot',24000);
INSERT INTO CN01.MENU VALUES ('ME45','Caramel Macchiato Chocomallow','Banh Ngot',18000);
INSERT INTO CN01.MENU VALUES ('ME46','Mini Cookies','Banh Ngot',40000);
INSERT INTO CN01.MENU VALUES ('ME47','Soft Chocolate Chips Cookies','Banh Ngot',24000);
INSERT INTO CN01.MENU VALUES ('ME48','Cream Puffs','Banh Ngot',35000);
INSERT INTO CN01.MENU VALUES ('ME49','Avocado Panna Cotta Tart','Banh Ngot',24000);
INSERT INTO CN01.MENU VALUES ('ME50','Cupcakes','Banh Ngot',20000);

SELECT * FROM CN01.MENU;

-- Insert into CN01.BRANCH 
INSERT INTO CN01.BRANCH VALUES ('BR01','Xo Viet Nghe Tinh','141 Xo Viet Nghe Tinh, Phuong 17, Quan Binh Thanh','0366866701');
INSERT INTO CN01.BRANCH VALUES ('BR02','Nguyen Gia Tri','6 Nguyen Gia Tri, Phuong 26, Quan Binh Thanh','0764853497');
INSERT INTO CN01.BRANCH VALUES ('BR03','Su Van Hanh','782 Su Van Hanh, Phuong 12, Quan 10','0971179784');
INSERT INTO CN01.BRANCH VALUES ('BR04','Phan Van Tri','190C Phan Van Tri, Phuong 12, Quan Binh Thanh','0938223929');
INSERT INTO CN01.BRANCH VALUES ('BR05','Hong Bang','307 Hong Bang, Phuong 11, Quan 5','0902542628');
INSERT INTO CN01.BRANCH VALUES ('BR06','Thanh Thai','154 Thanh Thai, Phuong 12, Quan 10','0909944516');
INSERT INTO CN01.BRANCH VALUES ('BR07','Hoa Lan','47G Hoa Lan, Phuong 2, Quan Phu Nhuan','0367823840');
INSERT INTO CN01.BRANCH VALUES ('BR08','Nguyen Du','53G Nguyen Du, Phuong Ben Nghe, Quan 1','0979159599');
INSERT INTO CN01.BRANCH VALUES ('BR09','Le Thi Rieng','41 Le Thi Rieng, Phuong Ben Thanh, Quan 1','0366866701');
INSERT INTO CN01.BRANCH VALUES ('BR10','Cong Hoa','43 Cong Hoa, Phuong 4, Quan Tan Binh','0366866701');
INSERT INTO CN01.BRANCH VALUES ('BR11','Phan Huy Ich','416 Phan Huy Ich, Phuong 12, Quan Go Vap','0366866701');
INSERT INTO CN01.BRANCH VALUES ('BR12','Huynh Van Banh','44 Huynh Van Banh, Phuong 15, Quan Phu Nhuan','0328067166');
INSERT INTO CN01.BRANCH VALUES ('BR13','Phan Xich Long','22 Phan Xich Long, Phuong 3, Quan Phu Nhuan','0379300292');
INSERT INTO CN01.BRANCH VALUES ('BR14','Thong Nhat','469 Thong Nhat, Phuong 16, Quan Go Vap','0366866701');
INSERT INTO CN01.BRANCH VALUES ('BR15','Riverside Residence','ST-04 Riverside Residence, Phuong Tan Phu, Quan 7','0862532339');
INSERT INTO CN01.BRANCH VALUES ('BR16','Huynh Tan Phat','485 Huynh Tan Phat, Phuong Tan Thuan Dong, Quan 7','0366866701');
INSERT INTO CN01.BRANCH VALUES ('BR17','Thoai Ngoc Hau','7A Thoai Ngoc Hau, Phuong Hoa Thach, Quan Tan Phu','0366866701');
INSERT INTO CN01.BRANCH VALUES ('BR18','Nguyen Thi Thap','402 Nguyen Thi Thap, Phuong Tan Quy, Quan 7','0366866701');
INSERT INTO CN01.BRANCH VALUES ('BR19','Tran Nhan Ton','2H Tran Nhan Ton, Phuong 2, Quan 10','0366866701');
INSERT INTO CN01.BRANCH VALUES ('BR20','Citizen Apartment','Citizen Apartment, Xa Binh Hung, Huyen Binh Chanh','0366866701');

SELECT * FROM CN01.BRANCH;

-- Insert to CN01.EMPLOYEE
INSERT INTO CN01.EMPLOYEE VALUES ('EMP11','Nguyen Chung Thuy Dan',to_date('21/07/2001','dd/mm/yyyy'),'0366866701','Ho Chi Minh','BR15');
INSERT INTO CN01.EMPLOYEE VALUES ('EMP12','Nguyen Ngoc Linh Dan',to_date('07/07/2001','dd/mm/yyyy'),'0366866701','Nam Dinh','BR15'); 
INSERT INTO CN01.EMPLOYEE VALUES ('EMP13','Ho Nam Kha',to_date('01/01/2001','dd/mm/yyyy'),'0366866701','Nghe An','BR15'); 
INSERT INTO CN01.EMPLOYEE VALUES ('EMP14','Vu Lan Anh',to_date('01/01/2001','dd/mm/yyyy'),'0366866701','Da Lat','BR15'); 
INSERT INTO CN01.EMPLOYEE VALUES ('EMP15','Bui Nhat Linh',to_date('01/01/2001','dd/mm/yyyy'),'0366866701','Dong Nai','BR15'); 
INSERT INTO CN01.EMPLOYEE VALUES ('EMP16','Nguyen Do Thuy Tran',to_date('01/01/2001','dd/mm/yyyy'),'0366866701','Da Nang','BR15'); 
INSERT INTO CN01.EMPLOYEE VALUES ('EMP17','Ngo Ngoc Quynh Hoa',to_date('18/09/2000','dd/mm/yyyy'),'0366866701','Ha Noi','BR15'); 
INSERT INTO CN01.EMPLOYEE VALUES ('EMP18','Phan Quynh Hoa',to_date('01/01/1999','dd/mm/yyyy'),'0366866701','Vinh Phuc','BR15'); 
INSERT INTO CN01.EMPLOYEE VALUES ('EMP19','Dao Gia Bao',to_date('01/01/2000','dd/mm/yyyy'),'0366866701','Phu Tho','BR15'); 
INSERT INTO CN01.EMPLOYEE VALUES ('EMP20','Nguyen Viet Anh',to_date('01/01/2000','dd/mm/yyyy'),'0366866701','Ho Chi Minh','BR15');

SELECT * FROM CN01.EMPLOYEE;

-- Insert to CN01.CUSTOMER_INFO
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS01','Bui Ngoc Bao Thy','0375130491','Ho Chi Minh',to_date('28/06/2000','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS02','Vo Ngoc Hoai Thuong','0901006848','Binh Dinh',to_date('07/06/2001','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS03','Nguyen Ngoc Hai Yen','0931127827','Ho Chi Minh',to_date('19/08/1998','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS04','Nguyen Huu Khac Phuc','0931199244','Quang Nam',to_date('28/06/2001','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS05','Nguyen Ba Hoc','0931199844','Da Lat',to_date('08/07/2000','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS06','Cao Huy','0901006025','Sa Pa',to_date('18/12/2004','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS07','Ngo Le Thao Dung','0931900611','Nha Trang',to_date('12/12/2005','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS08','Nguyen Minh Toan','0904391156','Ha Noi',to_date('12/12/2005','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS09','Le Huu Nhat Khoa','0375130491','Quang Nam',to_date('02/08/1990','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS10','Nguyen Trong Kien','0901006848','Gia Lai',to_date('23/09/1997','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS11','Nguyen Hieu Kien','0931127827','Vung Tau',to_date('23/01/2001','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS12','Nguyen Bich Tram','0931199244','Nghe An',to_date('29/03/1999','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS13','Do Hong Dung','0931199844','Dak Lak',to_date('09/07/2000','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS14','Hoang Hanh Nguyen','0901006025','Da Lat',to_date('31/12/2001','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS15','Pham Duy Ngoc Tram','0931900611','Long An',to_date('05/10/1998','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS16','Nguyen Ngoc Thao Nhi','0904391156','Hai Phong',to_date('06/07/2003','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS17','Do Nguyen Lam','0375130491','Ho Chi Minh',to_date('17/05/1997','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS18','Vu Nhat Linh','0901006848','Lam Dong',to_date('23/09/1990','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS19','Nguyen Thao Huong','0931127827','Bien Hoa',to_date('27/08/1991','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS20','Nguyen Thi Ngoc Mai','0931199244','Binh Dinh',to_date('04/04/1992','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS21','Nguyen Ngan Thi','0931199844','Binh Phuoc',to_date('06/09/1993','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS22','Nguyen Ngoc Phuong Thuy','0901006025','Quang Ngai',to_date('30/10/2002','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS23','Tran Do Tuong Vy','0931900611','Phan Thiet',to_date('09/08/1998','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS24','Nguyen Ngoc Thuy Tien','0904391156','Quang Binh',to_date('04/05/2000','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS25','Tran Ngoc Minh','0375130491','Binh Duong',to_date('28/09/1996','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS26','Vu Hong Phuong Anh','0375130491','Ca Mau',to_date('19/10/1996','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS27','Le Anh Thu','0901006848','Ben Tre',to_date('30/10/2008','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS28','Tran Thao Ngan','0931127827','Tien Giang',to_date('28/03/2001','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS29','Nguyen Ngoc Quynh Thanh','0931199244','Dong Thap',to_date('27/09/2002','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS30','Mai Ha Hoang Yen','0931199844','Can Tho',to_date('29/11/1978','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS31','Trinh Hong Phuc','0901006025','Ha Noi ',to_date('23/12/2003','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS32','Le Thanh Vi','0931900611','Ha Nam',to_date('05/11/2009','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS33','Nguyen Minh Tuyen','0904391156','Phu Tho',to_date('02/03/1994','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS34','Mai Thanh Thao','0375130491','Da Nang',to_date('05/09/2005','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS35','Duong Thanh Ngan','0901006848','Soc Trang',to_date('25/12/1988','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS36','Ngoc Phuong Trang','0931127827','Sa Pa',to_date('14/07/1998','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS37','Nguyen Kieu Trang','0931199244','Lang Son',to_date('28/12/1995','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS38','Bui Minh Hoai','0931199844','Son La',to_date('17/08/1975','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS39','Tran Man Chi','0901006025','Ho Chi Minh',to_date('07/12/1993','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS40','Ngo Bao Hoa','0931900611','Binh Duong',to_date('11/09/1977','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS41','Tran Nguyen Yen Vy','0904391156','Da Nang',to_date('30/03/1998','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS42','Thach Diep Thao Nguyen','0375130491','Can Gio',to_date('09/04/1999','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS43','Ho Thi Ngoc Tram','0901006848','Ca Mau',to_date('01/05/2001','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS44','Vuong Gia Han','0931127827','Ha Noi ',to_date('19/12/1975','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS45','Ngo Ngoc Dan Thy','0931199244','Dong Thap',to_date('14/09/2000','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS46','Nguyen Ha Bao Ngan','0931199844','Phan Thiet',to_date('07/08/1974','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS47','Vu Nguyen Anh Vy','0901006025','Ho Chi Minh',to_date('27/11/2002','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS48','Nguyen Do Anh Vy','0931900611','Vinh Phuc',to_date('12/10/1982','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS49','Tran Thu Huong','0904391156','Bac Ninh',to_date('24/11/1999','dd/mm/yyyy'),'Stardard');
INSERT INTO CN01.CUSTOMER_INFO VALUES ('CUS50','Nguyen Ha Thao Linh','0375130492','Hung Yen',to_date('24/01/1997','dd/mm/yyyy'),'Stardard');

SELECT * FROM CN01.CUSTOMER_INFO;

-- Insert into CN01.CUSTOMER_MANAGER
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS01',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS02',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS03',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS04',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS05',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS06',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS07',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS08',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS09',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS10',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS11',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS12',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS13',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS14',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS15',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS16',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS17',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS18',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS19',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS20',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS21',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS22',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS23',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS24',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS25',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS26',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS27',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS28',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS29',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS30',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS31',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS32',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS33',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS34',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS35',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS36',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS37',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS38',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS39',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS40',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS41',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS42',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS43',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS44',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS45',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS46',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS47',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS48',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS49',0);
INSERT INTO CN01.CUSTOMER_MANAGER VALUES ('CUS50',0);

SELECT * FROM CN01.CUSTOMER_MANAGER;

-- Insert into CN01.MANAGEMENU_MANAGER
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME01',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME02',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME03',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME04',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME05',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME06',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME07',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME08',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME09',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME10',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME11',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME12',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME13',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME14',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME15',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME16',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME17',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME18',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME19',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME20',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME21',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME22',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME23',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME24',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME25',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME26',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME27',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME28',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME29',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME30',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME31',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME32',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME33',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME34',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME35',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME36',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME37',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME38',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME39',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME40',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME41',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME42',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME43',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME44',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME45',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME46',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME47',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME48',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME49',1,to_date('05/12/2021','dd/mm/yyyy'));
INSERT INTO CN01.MANAGEMENU_MANAGER VALUES ('BR15','ME50',1,to_date('05/12/2021','dd/mm/yyyy'));

SELECT * FROM CN01.MANAGEMENU_MANAGER;

-- Insert into CN01.MANAGEMENU_STAFF
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME01','Duoc Phep Ban',30);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME02','Duoc Phep Ban',20);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME03','Duoc Phep Ban',6);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME04','Duoc Phep Ban',44);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME05','Duoc Phep Ban',39);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME06','Duoc Phep Ban',7);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME07','Duoc Phep Ban',44);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME08','Duoc Phep Ban',37);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME09','Duoc Phep Ban',2);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME10','Duoc Phep Ban',24);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME11','Duoc Phep Ban',3);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME12','Duoc Phep Ban',19);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME13','Duoc Phep Ban',26);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME14','Duoc Phep Ban',27);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME15','Duoc Phep Ban',32);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME16','Duoc Phep Ban',2);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME17','Duoc Phep Ban',20);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME18','Duoc Phep Ban',10);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME19','Duoc Phep Ban',0);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME20','Duoc Phep Ban',43);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME21','Duoc Phep Ban',41);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME22','Duoc Phep Ban',24);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME23','Duoc Phep Ban',19);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME24','Duoc Phep Ban',50);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME25','Duoc Phep Ban',20);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME26','Duoc Phep Ban',29);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME27','Duoc Phep Ban',4);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME28','Duoc Phep Ban',4);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME29','Duoc Phep Ban',23);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME30','Duoc Phep Ban',10);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME31','Duoc Phep Ban',10);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME32','Duoc Phep Ban',3);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME33','Duoc Phep Ban',33);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME34','Duoc Phep Ban',18);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME35','Duoc Phep Ban',48);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME36','Duoc Phep Ban',21);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME37','Duoc Phep Ban',36);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME38','Duoc Phep Ban',2);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME39','Duoc Phep Ban',40);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME40','Duoc Phep Ban',1);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME41','Duoc Phep Ban',39);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME42','Duoc Phep Ban',24);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME43','Duoc Phep Ban',8);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME44','Duoc Phep Ban',47);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME45','Duoc Phep Ban',48);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME46','Duoc Phep Ban',31);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME47','Duoc Phep Ban',11);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME48','Duoc Phep Ban',47);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME49','Duoc Phep Ban',15);
INSERT INTO CN01.MANAGEMENU_STAFF VALUES ('BR15','ME50','Duoc Phep Ban',6);

SELECT * FROM CN01.MANAGEMENU_STAFF;

-- Insert into CN01.INVOICE
INSERT INTO CN01.INVOICE VALUES ('INV13',to_date('11/11/2021','dd/mm/yyyy'),'CUS06','EMP11',144000,'BR15');
INSERT INTO CN01.INVOICE VALUES ('INV14',to_date('11/11/2021','dd/mm/yyyy'),'CUS07','EMP11',114000,'BR15');
INSERT INTO CN01.INVOICE VALUES ('INV15',to_date('11/11/2021','dd/mm/yyyy'),'CUS08','EMP11',150000,'BR15');
INSERT INTO CN01.INVOICE VALUES ('INV16',to_date('11/11/2021','dd/mm/yyyy'),'CUS09','EMP11',384000,'BR15');
INSERT INTO CN01.INVOICE VALUES ('INV17',to_date('11/11/2021','dd/mm/yyyy'),'CUS10','EMP17',90000,'BR15');
INSERT INTO CN01.INVOICE VALUES ('INV18',to_date('12/11/2021','dd/mm/yyyy'),'CUS11','EMP17',30000,'BR15');
INSERT INTO CN01.INVOICE VALUES ('INV19',to_date('12/11/2021','dd/mm/yyyy'),'CUS12','EMP17',330000,'BR15');
INSERT INTO CN01.INVOICE VALUES ('INV20',to_date('12/11/2021','dd/mm/yyyy'),'CUS13','EMP17',192000,'BR15');
INSERT INTO CN01.INVOICE VALUES ('INV33',to_date('15/11/2021','dd/mm/yyyy'),'CUS32','EMP12',264000,'BR15');
INSERT INTO CN01.INVOICE VALUES ('INV34',to_date('15/11/2021','dd/mm/yyyy'),'CUS20','EMP12',300000,'BR15');
INSERT INTO CN01.INVOICE VALUES ('INV35',to_date('16/11/2021','dd/mm/yyyy'),'CUS11','EMP12',280000,'BR15');
INSERT INTO CN01.INVOICE VALUES ('INV36',to_date('16/11/2021','dd/mm/yyyy'),'CUS17','EMP13',240000,'BR15');
INSERT INTO CN01.INVOICE VALUES ('INV37',to_date('16/11/2021','dd/mm/yyyy'),'CUS05','EMP13',312000,'BR15');
INSERT INTO CN01.INVOICE VALUES ('INV38',to_date('16/11/2021','dd/mm/yyyy'),'CUS30','EMP13',456000,'BR15');
INSERT INTO CN01.INVOICE VALUES ('INV39',to_date('16/11/2021','dd/mm/yyyy'),'CUS10','EMP13',675000,'BR15');
INSERT INTO CN01.INVOICE VALUES ('INV40',to_date('17/11/2021','dd/mm/yyyy'),'CUS20','EMP13',288000,'BR15');

SELECT * FROM CN01.INVOICE;

-- Insert into CN01.INVOICELINE
INSERT INTO CN01.INVOICELINE VALUES ('INV13','ME49',6,144000);
INSERT INTO CN01.INVOICELINE VALUES ('INV14','ME32',3,114000);
INSERT INTO CN01.INVOICELINE VALUES ('INV15','ME18',5,150000);
INSERT INTO CN01.INVOICELINE VALUES ('INV16','ME28',12,384000);
INSERT INTO CN01.INVOICELINE VALUES ('INV17','ME30',2,90000);
INSERT INTO CN01.INVOICELINE VALUES ('INV18','ME18',1,30000);
INSERT INTO CN01.INVOICELINE VALUES ('INV19','ME19',11,330000);
INSERT INTO CN01.INVOICELINE VALUES ('INV20','ME07',6,192000);
INSERT INTO CN01.INVOICELINE VALUES ('INV33','ME47',11,264000);
INSERT INTO CN01.INVOICELINE VALUES ('INV34','ME20',10,300000);
INSERT INTO CN01.INVOICELINE VALUES ('INV35','ME38',7,280000);
INSERT INTO CN01.INVOICELINE VALUES ('INV36','ME38',6,240000);
INSERT INTO CN01.INVOICELINE VALUES ('INV37','ME22',8,312000);
INSERT INTO CN01.INVOICELINE VALUES ('INV38','ME33',12,456000);
INSERT INTO CN01.INVOICELINE VALUES ('INV39','ME11',15,675000);
INSERT INTO CN01.INVOICELINE VALUES ('INV40','ME49',12,288000);

SELECT * FROM CN01.INVOICELINE;
SELECT * FROM CN01.CUSTOMER_MANAGER;