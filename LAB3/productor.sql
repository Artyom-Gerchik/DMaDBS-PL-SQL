CREATE TABLE PERSONS
(
    PERSON_ID  NUMBER GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL PRIMARY KEY,
    FIRST_NAME VARCHAR2(100)                                                         NOT NULL,
    LAST_NAME  VARCHAR2(100)                                                         NOT NULL,
    PATRONYMIC VARCHAR2(100)                                                         NOT NULL,
    CONSTRAINT UINT_ID CHECK (PERSON_ID BETWEEN 0 AND 4294967295)
);
CREATE INDEX INDEX_ON_TABLE_PERSONS ON PERSONS (PERSON_ID, LAST_NAME);

CREATE TABLE TESTTABLE
(
    ABOBA_ID NUMBER GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL PRIMARY KEY
);

CREATE OR REPLACE FUNCTION TEST_FUNCTIONOOOOO(TMP1 VARCHAR2) RETURN NUMBER IS
BEGIN
    return 30;
END TEST_FUNCTIONOOOOO;

CREATE OR REPLACE FUNCTION TEST_FUNCTION(TMP1 VARCHAR2) RETURN NUMBER IS
BEGIN
    return 999;
END TEST_FUNCTION;

CREATE PACKAGE PAKETIK AS
    FUNCTION ABOBA RETURN VARCHAR2;
END PAKETIK;

DROP PACKAGE PAKETIK;