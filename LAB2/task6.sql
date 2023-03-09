CREATE OR REPLACE TRIGGER CONTROL_VALUES_IN_GROUPS
    BEFORE INSERT OR DELETE OR UPDATE
    ON STUDENTS
    FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF INSERTING THEN
        UPDATE GROUPS SET C_VAL = C_VAL + 1 WHERE ID = :NEW.GROUP_ID;
    ELSIF UPDATING THEN
        IF :OLD.GROUP_ID != :NEW.GROUP_ID THEN
            UPDATE GROUPS SET C_VAL = C_VAL + 1 WHERE ID = :NEW.GROUP_ID;
            UPDATE GROUPS SET C_VAL = C_VAL - 1 WHERE ID = :OLD.GROUP_ID;
        END IF;
    ELSIF DELETING THEN
        UPDATE GROUPS SET C_VAL = C_VAL - 1 WHERE ID = :OLD.GROUP_ID;
    END IF;
    COMMIT;
END CONTROL_VALUES_IN_GROUPS;