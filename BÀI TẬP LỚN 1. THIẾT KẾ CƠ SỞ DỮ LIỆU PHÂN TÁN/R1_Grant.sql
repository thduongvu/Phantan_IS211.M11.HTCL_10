-- QUERY
--
--
-- MAY 01
-- TAO CAC QUYEN:
-- Role: Manager
CREATE ROLE ROLE_MANAGER NOT IDENTIFIED;
GRANT SELECT ON CN02.MENU TO ROLE_MANAGER;
GRANT SELECT, UPDATE, INSERT ON CN02.MANAGEMENU_MANAGER TO ROLE_MANAGER;
GRANT SELECT ON CN02.EMPLOYEE TO ROLE_MANAGER;
GRANT SELECT, UPDATE ON CN02.CUSTOMER_MANAGER TO ROLE_MANAGER;
-- Cap quyen cho Manager
GRANT CONNECT TO Manager;
GRANT ROLE_MANAGER to Manager;

-- Cap quyen cho CN01
GRANT CONNECT TO CN01;
GRANT SELECT ON CN02.MENU TO CN01;
GRANT SELECT ON CN02.MANAGEMENU_MANAGER TO CN01;
GRANT SELECT ON CN02.MANAGEMENU_STAFF TO CN01;
GRANT SELECT ON CN02.EMPLOYEE TO CN01;
GRANT SELECT ON CN02.BRANCH TO CN01;
GRANT SELECT ON CN02.CUSTOMER_INFO TO CN01;
GRANT SELECT ON CN02.CUSTOMER_MANAGER TO CN01;
GRANT SELECT ON CN02.INVOICE TO CN01;
GRANT SELECT ON CN02.INVOICELINE TO CN01;

-- Cap quyen cho Director
GRANT CONNECT TO Director;
GRANT SELECT ON CN02.MENU TO Director;
GRANT SELECT ON CN02.MANAGEMENU_MANAGER TO Director;
GRANT SELECT ON CN02.MANAGEMENU_STAFF TO Director;
GRANT SELECT ON CN02.EMPLOYEE TO Director;
GRANT SELECT ON CN02.BRANCH TO Director;
GRANT SELECT ON CN02.CUSTOMER_INFO TO Director;
GRANT SELECT ON CN02.CUSTOMER_MANAGER TO Director;
GRANT SELECT ON CN02.INVOICE TO Director;
GRANT SELECT ON CN02.INVOICELINE TO Director;
GRANT CREATE DATABASE LINK TO Director; 

-- Cap quyen cho Staff
GRANT CONNECT TO Staff;
GRANT SELECT ON CN02.MENU TO Staff;
GRANT SELECT ON CN02.MANAGEMENU_STAFF TO Staff;
GRANT SELECT ON CN02.CUSTOMER_INFO TO Staff;
GRANT SELECT ON CN02.INVOICE TO Staff;
GRANT SELECT ON CN02.INVOICELINE TO Staff;
GRANT CREATE DATABASE LINK TO Staff;

-- MAY 02
-- TAO CAC QUYEN:
-- Role: Manager
CREATE ROLE ROLE_MANAGER NOT IDENTIFIED;
GRANT SELECT ON CN01.MENU TO ROLE_MANAGER;
GRANT SELECT, UPDATE, INSERT ON CN01.MANAGEMENU_MANAGER TO ROLE_MANAGER;
GRANT SELECT ON CN01.EMPLOYEE TO ROLE_MANAGER;
GRANT SELECT, UPDATE ON CN01.CUSTOMER_MANAGER TO ROLE_MANAGER;
GRANT SELECT ON CN01.INVOICE TO ROLE_MANAGER;

-- Cap quyen cho Manager
GRANT CONNECT TO Manager;
GRANT ROLE_MANAGER to Manager;

-- Cap quyen cho CN02
GRANT CONNECT TO CN02;
GRANT SELECT ON CN01.MENU TO CN02;
GRANT SELECT ON CN01.MANAGEMENU_MANAGER TO CN02;
GRANT SELECT ON CN01.MANAGEMENU_STAFF TO CN02;
GRANT SELECT ON CN01.EMPLOYEE TO CN02;
GRANT SELECT ON CN01.BRANCH TO CN02;
GRANT SELECT ON CN01.CUSTOMER_INFO TO CN02;
GRANT SELECT ON CN01.CUSTOMER_MANAGER TO CN02;
GRANT SELECT ON CN01.INVOICE TO CN02;
GRANT SELECT ON CN01.INVOICELINE TO CN02;

-- Cap quyen cho Director
GRANT CONNECT TO Director;
GRANT SELECT ON CN01.MENU TO Director;
GRANT SELECT ON CN01.MANAGEMENU_MANAGER TO Director;
GRANT SELECT ON CN01.MANAGEMENU_STAFF TO Director;
GRANT SELECT ON CN01.EMPLOYEE TO Director;
GRANT SELECT ON CN01.BRANCH TO Director;
GRANT SELECT ON CN01.CUSTOMER_INFO TO Director;
GRANT SELECT ON CN01.CUSTOMER_MANAGER TO Director;
GRANT SELECT ON CN01.INVOICE TO Director;
GRANT SELECT ON CN01.INVOICELINE TO Director;

-- Cap quyen cho Staff
GRANT CONNECT TO Staff;
GRANT SELECT ON CN01.MENU TO Staff;
GRANT SELECT ON CN01.MANAGEMENU_STAFF TO Staff;
GRANT SELECT ON CN01.CUSTOMER_INFO TO Staff;
GRANT SELECT ON CN01.INVOICE TO Staff;
GRANT SELECT ON CN01.INVOICELINE TO Staff;
GRANT CREATE DATABASE LINK TO Staff;
