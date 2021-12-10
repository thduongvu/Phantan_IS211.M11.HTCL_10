-- TRIGGER
--
--
-- Trigger 1// Khong the them vao chi tiet hoa don san pham o trang thai "Khong duoc phep ban"
/*  Boi canh: INVOICELINE, MANAGEMENU_STAFF
    Noi dung:
    Bang tam anh huong: 
    -------------------------------------------------------
                     | INSERT | DELETE |       UPDATE
    -------------------------------------------------------
    INVOICELINE      |   +    |    -   | + (MenuID)
    -------------------------------------------------------
    MANAGEMENU_STAFF |   -    |    -   | + (MenuID, Stage)
*/

CREATE OR REPLACE TRIGGER  TRIGGER_INSERT_UPDATE_ON_INVOICELINE
BEFORE INSERT OR UPDATE ON CN02.INVOICELINE
FOR EACH ROW
DECLARE
    v_status CN02.MANAGEMENU_STAFF.Status%TYPE;
BEGIN
    SELECT Status
    INTO v_status
    FROM CN02.MANAGEMENU_STAFF
    WHERE MenuID = :NEW.MenuID;
    
	IF v_status != 'Duoc Phep Ban' THEN
		BEGIN
		RAISE_APPLICATION_ERROR (-20102,'San pham khong duoc phep tai chi nhanh nay!');
		ROLLBACK;
		END;
	END IF;
END;

-- Check
SELECT * 
FROM CN02.MANAGEMEMU_MANAGER MEMA, CN02.MANAGEMEMU_STAFF MESA
WHERE MEMA.MenuID = MESA.MenuID;

INSERT INTO CN02.INVOICELINE VALUES ('INV18','M35',10,400000);
INSERT INTO CN02.INVOICELINE VALUES ('INV18','M20',10,300000);

-- Trigger 2// Cap nhat thong tin quan ly menu cua nhan vien khi quan ly cap nhat
/*  Boi canh: 
    Noi dung:
    Bang tam anh huong: 
    
*/
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