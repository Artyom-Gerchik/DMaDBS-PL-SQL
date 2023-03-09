CREATE OR REPLACE TRIGGER STUDENTS_INSERT
    BEFORE INSERT ON STUDENTS
    FOR EACH ROW
DECLARE
    AMOUNT NUMBER;
    MAX_ID NUMBER;
BEGIN
    SELECT COUNT(*) INTO AMOUNT FROM STUDENTS;
    IF AMOUNT = 0 THEN
        :NEW.ID := 1;
    ELSE
        SELECT MAX(ID) INTO MAX_ID FROM STUDENTS;
        :NEW.ID := MAX_ID + 1;
    END IF;
END STUDENTS_INSERT;