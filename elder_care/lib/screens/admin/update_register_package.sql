DELIMITER $$

CREATE TRIGGER update_register_package
AFTER UPDATE ON bill
FOR EACH ROW
BEGIN
    -- Check if the conditions are met: merchant_id = 0, elder_id != 0, approval is updated to 1, and payment_type matches
    IF NEW.merchant_id = 0 AND NEW.elder_id != 0 AND NEW.approval = 1 AND NEW.payment_type = 'package' THEN
        -- Update the package field in the register table based on the service value in the bill table
        CASE NEW.service
            WHEN 'Silver' THEN
                UPDATE register
                SET package = 1
                WHERE id = NEW.elder_id;
            WHEN 'Premium' THEN
                UPDATE register
                SET package = 2
                WHERE id = NEW.elder_id;
            WHEN 'Gold' THEN
                UPDATE register
                SET package = 3
                WHERE id = NEW.elder_id;
        END CASE;
    END IF;
END$$

DELIMITER ;
