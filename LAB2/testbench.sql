INSERT INTO STUDENTS
VALUES (1, 'NIGGER', 1);
INSERT INTO STUDENTS
VALUES (3, '3333333', 2);

SELECT *
FROM STUDENTS;

DELETE
FROM STUDENTS
WHERE ID = 3;


SELECT *
FROM GROUPS;

INSERT INTO GROUPS
VALUES (2, 'NIGGERSS', 0);

DELETE
FROM GROUPS
WHERE ID = 1;

BEGIN
    RESTORE_STUDENTS_BY_LOGS(TO_DATE('2023-03-09 12:30:18', 'yyyy-mm-dd hh24:mi:ss'),
                             TO_DATE('2023-03-09 12:35:18', 'yyyy-mm-dd hh24:mi:ss'));
END;


SELECT *
FROM STUDENTS_LOGS;

SELECT * FROM GROUPS;



