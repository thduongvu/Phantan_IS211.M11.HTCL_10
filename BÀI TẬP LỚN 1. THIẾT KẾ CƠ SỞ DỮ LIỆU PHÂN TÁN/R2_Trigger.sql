-- TRIGGER
--
--
-- Trigger 1// Khong the them vao chi tiet hoa don san pham o trang thai "Khong duoc phep ban"
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

-- Trigger 2// 
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
