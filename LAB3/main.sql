CREATE OR REPLACE PROCEDURE CHECK_TABLES(DEV_SCHEMA_NAME VARCHAR2, PROD_SCHEMA_NAME VARCHAR2) IS
    CURSOR TABLE_NAMES IS
        SELECT *
        FROM (SELECT TABLE_NAME DEVELOPER_TABLE_NAME FROM ALL_TABLES WHERE OWNER = UPPER(DEV_SCHEMA_NAME)) DEVELEPOER
                 FULL OUTER JOIN
             (SELECT TABLE_NAME PRODUCTOR_TABLE_NAME FROM ALL_TABLES WHERE OWNER = UPPER(PROD_SCHEMA_NAME)) PRODUCTOR
             ON DEVELEPOER.DEVELOPER_TABLE_NAME = PRODUCTOR.PRODUCTOR_TABLE_NAME;
BEGIN

    FOR RECORD IN TABLE_NAMES
        LOOP
            IF RECORD.PRODUCTOR_TABLE_NAME IS NULL THEN
                DBMS_OUTPUT.PUT_LINE('NO SUCH TABLE AS # ' || RECORD.DEVELOPER_TABLE_NAME || ' # IN PRODUCTOR SCHEMA.');
                CONTINUE;
            END IF;
            IF RECORD.DEVELOPER_TABLE_NAME IS NULL THEN
                DBMS_OUTPUT.PUT_LINE('DROP TABLE ' || RECORD.PRODUCTOR_TABLE_NAME || ';' || ' IN DEVELOPER SCHEMA.');
                CONTINUE;
            END IF;
            CHECK_TABLES_STRUCTURE(DEV_SCHEMA_NAME, PROD_SCHEMA_NAME, RECORD.DEVELOPER_TABLE_NAME);
            CHECK_TABLES_STRUCTURE_CONSTRAINTS(DEV_SCHEMA_NAME, PROD_SCHEMA_NAME, RECORD.DEVELOPER_TABLE_NAME);

        END LOOP;

END CHECK_TABLES;

CREATE OR REPLACE PROCEDURE CHECK_TABLES_STRUCTURE(DEV_SCHEMA_NAME VARCHAR2, PROD_SCHEMA_NAME VARCHAR2,
                                                   TABLE_NAME_TO_CHECK VARCHAR2) IS
    CURSOR TABLE_COLUMNS IS
        SELECT *
        FROM ((SELECT COLUMN_NAME DEVELOPER_COLUMN_NAME
               FROM ALL_TAB_COLUMNS
               WHERE OWNER = UPPER(DEV_SCHEMA_NAME)
                 AND TABLE_NAME = UPPER(TABLE_NAME_TO_CHECK))) DEVELOPER
                 FULL OUTER JOIN
             (SELECT COLUMN_NAME PRODUCTOR_COLUMN_NAME
              FROM ALL_TAB_COLUMNS
              WHERE OWNER = UPPER(PROD_SCHEMA_NAME)
                AND TABLE_NAME = UPPER(TABLE_NAME_TO_CHECK)) PRODUCTOR
             ON DEVELOPER.DEVELOPER_COLUMN_NAME = PRODUCTOR.PRODUCTOR_COLUMN_NAME;
BEGIN
    FOR RECORD IN TABLE_COLUMNS
        LOOP
            IF RECORD.DEVELOPER_COLUMN_NAME IS NULL THEN
                DBMS_OUTPUT.PUT_LINE('NO SUCH COLUMN AS # ' || RECORD.PRODUCTOR_COLUMN_NAME || ' # IN TABLE ' ||
                                     TABLE_NAME_TO_CHECK || ' IN DEVELOPER SCHEME');
                CONTINUE;
            END IF;
            IF RECORD.PRODUCTOR_COLUMN_NAME IS NULL THEN
                DBMS_OUTPUT.PUT_LINE('NO SUCH COLUMN AS # ' || RECORD.DEVELOPER_COLUMN_NAME || ' # IN TABLE ' ||
                                     TABLE_NAME_TO_CHECK || ' IN PRODUCTOR SCHEME');
                CONTINUE;
            END IF;
            CHECK_TABLES_STRUCTURE_DATA_TYPES(DEV_SCHEMA_NAME, PROD_SCHEMA_NAME, RECORD.DEVELOPER_COLUMN_NAME,
                                              TABLE_NAME_TO_CHECK);
        END LOOP;
END CHECK_TABLES_STRUCTURE;

CREATE OR REPLACE PROCEDURE CHECK_TABLES_STRUCTURE_DATA_TYPES(DEV_SCHEMA_NAME VARCHAR2, PROD_SCHEMA_NAME VARCHAR2,
                                                              COLUMN_NAME_TO_CHECK VARCHAR2,
                                                              TABLE_NAME_FOR_OUTPUT VARCHAR2) IS
    TMP NUMBER;
    CURSOR COLUMN_DATA_TYPES IS
        SELECT *
        FROM ((SELECT DATA_TYPE DEVELOPER_COLUMN_DATA_TYPE
               FROM ALL_TAB_COLUMNS
               WHERE OWNER = UPPER(DEV_SCHEMA_NAME)
                 AND COLUMN_NAME = UPPER(COLUMN_NAME_TO_CHECK))) DEVELOPER
                 FULL OUTER JOIN
             (SELECT DATA_TYPE PRODUCTOR_COLUMN_DATA_TYPE
              FROM ALL_TAB_COLUMNS
              WHERE OWNER = UPPER(PROD_SCHEMA_NAME)
                AND COLUMN_NAME = UPPER(COLUMN_NAME_TO_CHECK)) PRODUCTOR
             ON DEVELOPER.DEVELOPER_COLUMN_DATA_TYPE = PRODUCTOR.PRODUCTOR_COLUMN_DATA_TYPE;
BEGIN
    FOR RECORD IN COLUMN_DATA_TYPES
        LOOP
            IF RECORD.PRODUCTOR_COLUMN_DATA_TYPE = RECORD.DEVELOPER_COLUMN_DATA_TYPE THEN
                CONTINUE;
            ELSE
                IF TMP = 1 THEN
                    TMP := 9999;
                    CONTINUE;
                END IF;
                DBMS_OUTPUT.PUT_LINE('MISMATCH OF DATA TYPE IN # ' || COLUMN_NAME_TO_CHECK || ' # IN ' ||
                                     TABLE_NAME_FOR_OUTPUT || ' TABLE');
                TMP := 1;
            END IF;
        END LOOP;
END CHECK_TABLES_STRUCTURE_DATA_TYPES;

CREATE OR REPLACE PROCEDURE CHECK_TABLES_STRUCTURE_CONSTRAINTS(DEV_SCHEMA_NAME VARCHAR2, PROD_SCHEMA_NAME VARCHAR2,
                                                               TABLE_NAME_TO_CHECK VARCHAR2) IS
    TMP NUMBER;
    CURSOR TABLE_CONSTRAINTS_NAMES IS
        SELECT *
        FROM (SELECT CONSTRAINT_NAME DEVELOPER_CONSTRAINT_NAME
              FROM ALL_CONSTRAINTS
              WHERE OWNER = UPPER(DEV_SCHEMA_NAME)
                AND TABLE_NAME = UPPER(TABLE_NAME_TO_CHECK)
                AND NOT REGEXP_LIKE(CONSTRAINT_NAME, '^SYS_C\d+')) DEVELOPER
                 FULL OUTER JOIN
             (SELECT CONSTRAINT_NAME PRODUCTOR_CONSTRAINT_NAME
              FROM ALL_CONSTRAINTS
              WHERE OWNER = UPPER(PROD_SCHEMA_NAME)
                AND TABLE_NAME = UPPER(TABLE_NAME_TO_CHECK)
                AND NOT REGEXP_LIKE(CONSTRAINT_NAME, '^SYS_C\d+')) PRODUCTOR
             ON DEVELOPER.DEVELOPER_CONSTRAINT_NAME = PRODUCTOR.PRODUCTOR_CONSTRAINT_NAME;
BEGIN
    FOR RECORD IN TABLE_CONSTRAINTS_NAMES
        LOOP
            IF RECORD.PRODUCTOR_CONSTRAINT_NAME = RECORD.DEVELOPER_CONSTRAINT_NAME THEN
                CONTINUE;
            ELSE
                IF TMP = 1 THEN
                    TMP := 9999;
                    CONTINUE;
                END IF;
                DBMS_OUTPUT.PUT_LINE('MISMATCH OF CONSTRAINT IN # ' || TABLE_NAME_TO_CHECK || ' #');
                TMP := 1;
            END IF;
        END LOOP;
END CHECK_TABLES_STRUCTURE_CONSTRAINTS;

CREATE OR REPLACE PROCEDURE CHECK_FUNCTIONS_OR_PROCEDURES(DEV_SCHEMA_NAME VARCHAR2, PROD_SCHEMA_NAME VARCHAR2,
                                                          TYPE_TO_CHECK VARCHAR2) IS
    CURSOR FUNCTIONS_AND_PROCEDURES_NAMES IS
        SELECT *
        FROM (SELECT OBJECT_NAME DEVELOPER_FUNCTION_OR_PROCEDURE_NAME
              FROM ALL_PROCEDURES
              WHERE OWNER = UPPER(DEV_SCHEMA_NAME)
                AND OBJECT_TYPE = UPPER(TYPE_TO_CHECK)) DEVELOPER
                 FULL OUTER JOIN
             (SELECT OBJECT_NAME PRODUCTOR_FUNCTION_OR_PROCEDURE_NAME
              FROM ALL_PROCEDURES
              WHERE OWNER = UPPER(PROD_SCHEMA_NAME)
                AND OBJECT_TYPE = UPPER(TYPE_TO_CHECK)) PRODUCTOR
             ON DEVELOPER.DEVELOPER_FUNCTION_OR_PROCEDURE_NAME = PRODUCTOR.PRODUCTOR_FUNCTION_OR_PROCEDURE_NAME;
BEGIN
    FOR RECORD IN FUNCTIONS_AND_PROCEDURES_NAMES
        LOOP
            IF RECORD.DEVELOPER_FUNCTION_OR_PROCEDURE_NAME IS NULL THEN
                DBMS_OUTPUT.PUT_LINE('DROP ' || TYPE_TO_CHECK || ' ' || RECORD.PRODUCTOR_FUNCTION_OR_PROCEDURE_NAME ||
                                     '; IN ' || PROD_SCHEMA_NAME || '.');
            END IF;

            IF RECORD.PRODUCTOR_FUNCTION_OR_PROCEDURE_NAME IS NULL OR
               GET_FUNCTION_OR_PROCEDURE_TEXT(DEV_SCHEMA_NAME, TYPE_TO_CHECK,
                                              RECORD.DEVELOPER_FUNCTION_OR_PROCEDURE_NAME)
                   !=
               GET_FUNCTION_OR_PROCEDURE_TEXT(PROD_SCHEMA_NAME, TYPE_TO_CHECK,
                                              RECORD.PRODUCTOR_FUNCTION_OR_PROCEDURE_NAME)
            THEN
                ADD_FUNCTION_OR_PROCEDURE(DEV_SCHEMA_NAME, RECORD.DEVELOPER_FUNCTION_OR_PROCEDURE_NAME, TYPE_TO_CHECK);
            END IF;
        END LOOP;
END CHECK_FUNCTIONS_OR_PROCEDURES;

CREATE OR REPLACE FUNCTION GET_FUNCTION_OR_PROCEDURE_TEXT(SCHEMA_NAME VARCHAR2,
                                                          OBJECT_TYPE VARCHAR2,
                                                          OBJECT_NAME VARCHAR2)
    RETURN VARCHAR2
    IS
    CURSOR FUNCTION_OR_PROCEDURE_TEXT IS
        SELECT UPPER(TRIM(' ' FROM (TRANSLATE(TEXT, CHR(10) || CHR(13), ' ')))) OBJECT_TEXT
        FROM ALL_SOURCE
        WHERE OWNER = UPPER(SCHEMA_NAME)
          AND NAME = UPPER(OBJECT_NAME)
          AND OBJECT_TYPE = UPPER(OBJECT_TYPE)
          AND TEXT != chr(10);
    BODY VARCHAR2(32000) := '';
BEGIN
    FOR RECORD IN FUNCTION_OR_PROCEDURE_TEXT
        LOOP
            BODY := BODY || RECORD.OBJECT_TEXT;
        END LOOP;
    RETURN BODY;
END GET_FUNCTION_OR_PROCEDURE_TEXT;

CREATE OR REPLACE PROCEDURE ADD_FUNCTION_OR_PROCEDURE(DEV_SCHEMA_NAME VARCHAR2,
                                                      OBJECT_NAME VARCHAR2,
                                                      OBJECT_TYPE VARCHAR2)
    IS
    CURSOR GET_OBJECT IS
        SELECT TRIM(' ' FROM (TRANSLATE(ALL_SOURCE.TEXT, CHR(10) || CHR(13), ' '))) AS text
        FROM ALL_SOURCE
        WHERE OWNER = UPPER(DEV_SCHEMA_NAME)
          AND NAME = UPPER(OBJECT_NAME)
          AND OBJECT_TYPE = UPPER(OBJECT_TYPE);
    TMP VARCHAR2(1000);
BEGIN
    OPEN GET_OBJECT;
    FETCH GET_OBJECT INTO TMP;
    CLOSE GET_OBJECT;
    IF TMP IS NULL THEN
        RETURN;
    END IF;
    DBMS_OUTPUT.PUT_LINE('--- IN PRODUCTOR---');
    DBMS_OUTPUT.PUT_LINE('CREATE OR REPLACE ');
    FOR RECORD IN GET_OBJECT
        LOOP
            DBMS_OUTPUT.PUT_LINE(RECORD.TEXT);
        END LOOP;
    DBMS_OUTPUT.PUT_LINE('--- IN PRODUCTOR ---');
END ADD_FUNCTION_OR_PROCEDURE;

CREATE OR REPLACE PROCEDURE CHECK_INDEXES(DEV_SCHEMA_NAME VARCHAR2,
                                          PROD_SCHEMA_NAME VARCHAR2)
    IS
    CURSOR ALL_INDEXES IS
        SELECT DISTINCT DEVELOPER_UNIQUENESS, DEVELOPER_INDEX_NAME, PRODUCTOR_UNIQUENESS, PRODUCTOR_INDEX_NAME
        FROM (SELECT AI.INDEX_NAME   DEVELOPER_INDEX_NAME,
                     AI.TABLE_NAME   DEVELOPER_TABLE_NAME,
                     AI.UNIQUENESS   DEVELOPER_UNIQUENESS,
                     AIC.COLUMN_NAME DEVELOPER_COLUMN_NAME
              FROM ALL_INDEXES AI
                       INNER JOIN ALL_IND_COLUMNS AIC
                                  ON AI.INDEX_NAME = AIC.INDEX_NAME AND AI.OWNER = AIC.INDEX_OWNER
              WHERE AI.OWNER = UPPER('DEVELOPER')
                AND NOT REGEXP_LIKE(AI.INDEX_NAME, '^SYS_C\d+')) DEVELOPER
                 FULL OUTER JOIN
             (SELECT AI.INDEX_NAME   PRODUCTOR_INDEX_NAME,
                     AI.TABLE_NAME   PRODUCTOR_TABLE_NAME,
                     AI.UNIQUENESS   PRODUCTOR_UNIQUENESS,
                     AIC.COLUMN_NAME PRODUCTOR_COLUMN_NAME
              FROM ALL_INDEXES AI
                       INNER JOIN ALL_IND_COLUMNS AIC
                                  ON AI.INDEX_NAME = AIC.INDEX_NAME AND AI.OWNER = AIC.INDEX_OWNER
              WHERE AI.OWNER = UPPER('PRODUCTOR')
                AND NOT REGEXP_LIKE(AI.INDEX_NAME, '^SYS_C\d+')) PRODUCTOR
             ON DEVELOPER.DEVELOPER_TABLE_NAME = PRODUCTOR.PRODUCTOR_TABLE_NAME
                 AND DEVELOPER.DEVELOPER_COLUMN_NAME = PRODUCTOR.PRODUCTOR_COLUMN_NAME;
BEGIN
    FOR RECORD IN ALL_INDEXES
        LOOP
            IF RECORD.PRODUCTOR_INDEX_NAME IS NULL THEN
                DBMS_OUTPUT.PUT_LINE('CREATE ' || RECORD.DEVELOPER_UNIQUENESS
                    || ' INDEX ' || RECORD.DEVELOPER_INDEX_NAME
                    || GET_INDEX_TEXT(dev_schema_name, RECORD.DEVELOPER_INDEX_NAME) || '; IN PRODUCTOR.');
                CONTINUE;
            END IF;

            IF RECORD.DEVELOPER_INDEX_NAME IS NULL THEN
                DBMS_OUTPUT.PUT_LINE('DROP INDEX ' || RECORD.PRODUCTOR_INDEX_NAME || '; IN PRODUCTOR');
                CONTINUE;
            END IF;
            IF GET_INDEX_TEXT(DEV_SCHEMA_NAME, RECORD.DEVELOPER_INDEX_NAME)
                   !=
               GET_INDEX_TEXT(PROD_SCHEMA_NAME, RECORD.PRODUCTOR_INDEX_NAME)
                OR RECORD.DEVELOPER_UNIQUENESS != RECORD.PRODUCTOR_UNIQUENESS THEN
                DBMS_OUTPUT.PUT_LINE('DROP INDEX ' || RECORD.PRODUCTOR_INDEX_NAME || '; IN PRODUCTOR.');
                DBMS_OUTPUT.PUT_LINE('CREATE ' || RECORD.DEVELOPER_UNIQUENESS || ' INDEX '
                    || RECORD.PRODUCTOR_INDEX_NAME
                    || GET_INDEX_TEXT(DEV_SCHEMA_NAME, RECORD.DEVELOPER_INDEX_NAME) || '; IN PRODUCTOR');
            END IF;
        END LOOP;
END CHECK_INDEXES;

CREATE OR REPLACE FUNCTION GET_INDEX_TEXT(SCHEMA_NAME VARCHAR2,
                                          INDEX_NAME_TO_GET VARCHAR2)
    RETURN VARCHAR2
    IS
    CURSOR GOT_INDEX IS
        SELECT AIC.INDEX_NAME,
               AIC.TABLE_NAME,
               AIC.COLUMN_NAME,
               AIC.COLUMN_POSITION,
               AI.UNIQUENESS
        FROM ALL_IND_COLUMNS AIC
                 INNER JOIN ALL_INDEXES AI
                            ON AI.INDEX_NAME = AIC.INDEX_NAME AND AI.OWNER = AIC.INDEX_OWNER
        WHERE AIC.INDEX_OWNER = UPPER(SCHEMA_NAME)
          AND AIC.INDEX_NAME = UPPER(INDEX_NAME_TO_GET)
        ORDER BY aic.column_position;
    RECORD GOT_INDEX%ROWTYPE;
    TEXT   VARCHAR2(200);
BEGIN
    OPEN GOT_INDEX;
    FETCH GOT_INDEX INTO RECORD;
    TEXT := TEXT || ' ' || RECORD.TABLE_NAME || '(';
    WHILE GOT_INDEX%FOUND
        LOOP
            TEXT := TEXT || RECORD.COLUMN_NAME || ', ';
            FETCH GOT_INDEX INTO RECORD;
        END LOOP;
    CLOSE GOT_INDEX;
    TEXT := RTRIM(TEXT, ', ');
    TEXT := TEXT || ')';
    RETURN TEXT;
END GET_INDEX_TEXT;


CREATE OR REPLACE PROCEDURE CHECK_SCHEMAS(DEV_SCHEMA_NAME VARCHAR2, PROD_SCHEMA_NAME VARCHAR2) IS
BEGIN
    CHECK_TABLES(DEV_SCHEMA_NAME, PROD_SCHEMA_NAME);
    CHECK_FUNCTIONS_OR_PROCEDURES(DEV_SCHEMA_NAME, PROD_SCHEMA_NAME, 'FUNCTION');
    CHECK_FUNCTIONS_OR_PROCEDURES(DEV_SCHEMA_NAME, PROD_SCHEMA_NAME, 'PROCEDURE');
    CHECK_INDEXES(DEV_SCHEMA_NAME, PROD_SCHEMA_NAME);
END;

BEGIN
    CHECK_SCHEMAS('DEVELOPER', 'PRODUCTOR');
END;