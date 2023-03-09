CREATE OR REPLACE TRIGGER STUDENTS_INSERT
    BEFORE INSERT
    ON STUDENTS
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
        IF :NEW.ID > MAX_ID THEN
            :NEW.ID := MAX_ID + 1;
        ELSIF :NEW.ID > 0 THEN
            SELECT COUNT(*) INTO AMOUNT FROM STUDENTS WHERE ID = :NEW.ID;
            IF AMOUNT > 0 THEN
                :NEW.ID := MAX_ID + 1; -- ELSE :NEW.ID NOT CHANGING
            END IF;
        ELSE
            :NEW.ID := MAX_ID + 1;
        END IF;
    END IF;
END STUDENTS_INSERT;

CREATE OR REPLACE TRIGGER GROUPS_INSERT
    BEFORE INSERT
    ON GROUPS
    FOR EACH ROW
DECLARE
    NAME_EXCEPTION EXCEPTION;
    PRAGMA EXCEPTION_INIT (NAME_EXCEPTION, -20111);

    AMOUNT NUMBER;
    MAX_ID NUMBER;
BEGIN
    SELECT COUNT(*) INTO AMOUNT FROM GROUPS WHERE NAME = :NEW.NAME;
    IF AMOUNT = 0 THEN
        SELECT COUNT(*) INTO AMOUNT FROM GROUPS;
        IF AMOUNT = 0 THEN
            :NEW.ID := 1;
        ELSE
            SELECT MAX(ID) INTO MAX_ID FROM GROUPS;
            IF :NEW.ID > MAX_ID THEN
                :NEW.ID := MAX_ID + 1;
            ELSIF :NEW.ID > 0 THEN
                SELECT COUNT(*) INTO AMOUNT FROM GROUPS WHERE ID = :NEW.ID;
                IF AMOUNT > 0 THEN
                    :NEW.ID := MAX_ID + 1; -- ELSE :NEW.ID NOT CHANGING
                END IF;
            ELSE
                :NEW.ID := MAX_ID + 1;
            END IF;
        END IF;
    ELSE
        RAISE_APPLICATION_ERROR(-20111, 'GROUP WITH THE SAME NAME ALREADY EXISTS');
    END IF;

END GROUPS_INSERT;