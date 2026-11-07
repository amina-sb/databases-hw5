-- CSCI-UA 60 | Assignment 5 - SQL Queries
-- Amina Salamatolla (as20312)
-- Run against the United Helpers database created by unitedHelpers.sql (SQLite).


-- Question 1
-- How many containers of antibiotics are currently available?
SELECT
    quantityOnHand AS antibioticsAvailable
FROM item
WHERE itemDescription LIKE '%antibiotic%';


-- Question 2
-- Which volunteer(s), if any, have phone numbers that do not start with
-- the number 2 and whose last name is not Jones?
SELECT
    volunteerName
FROM volunteer
WHERE volunteerTelephone IS NOT NULL
    AND volunteerTelephone NOT LIKE '2%'
    AND volunteerName NOT LIKE '% Jones';


-- Question 3
-- Which volunteer(s) are working on transporting tasks?
SELECT DISTINCT
    v.volunteerName
FROM volunteer AS v
JOIN assignment AS a
    ON v.volunteerId = a.volunteerId
JOIN task AS t
    ON a.taskCode = t.taskCode
JOIN task_type AS tt
    ON t.taskTypeId = tt.taskTypeId
WHERE tt.taskTypeName = 'transporting';


-- Question 4
-- Which task(s) have yet to be assigned to any volunteers?
SELECT
    t.taskDescription
FROM task AS t
LEFT JOIN assignment AS a
    ON t.taskCode = a.taskCode
WHERE a.taskCode IS NULL;


-- Question 5
-- Which type(s) of package contain some kind of bottle?
SELECT DISTINCT
    pt.packageTypeName
FROM package_type AS pt
JOIN package AS p
    ON pt.packageTypeId = p.packageTypeId
JOIN package_contents AS pc
    ON p.packageId = pc.packageId
JOIN item AS i
    ON pc.itemId = i.itemId
WHERE i.itemDescription LIKE '%bottle%';


-- Question 6
-- Which items, if any, are not in any packages?
SELECT
    i.itemDescription
FROM item AS i
LEFT JOIN package_contents AS pc
    ON i.itemId = pc.itemId
WHERE pc.itemId IS NULL;


-- Question 7
-- Which task(s) are assigned to volunteer(s) that live in New Jersey (NJ)?
-- Note: tasks 103 and 108 are two different tasks that share the same
-- description, so that description appears twice (once per task).
SELECT
    t.taskDescription
FROM task AS t
WHERE t.taskCode IN (
    SELECT
        a.taskCode
    FROM assignment AS a
    JOIN volunteer AS v
        ON a.volunteerId = v.volunteerId
    WHERE v.volunteerAddress LIKE '% NJ'
)
ORDER BY t.taskCode;


-- Question 8
-- Which volunteers began their assignments in the first half of 2021?
SELECT DISTINCT
    v.volunteerName
FROM volunteer AS v
JOIN assignment AS a
    ON v.volunteerId = a.volunteerId
WHERE a.startDateTime >= '2021-01-01'
    AND a.startDateTime < '2021-07-01';


-- Question 9
-- Which volunteers have been assigned to tasks that include packing spam?
SELECT DISTINCT
    v.volunteerName
FROM volunteer AS v
JOIN assignment AS a
    ON v.volunteerId = a.volunteerId
JOIN package AS p
    ON a.taskCode = p.taskCode
JOIN package_contents AS pc
    ON p.packageId = pc.packageId
JOIN item AS i
    ON pc.itemId = i.itemId
WHERE i.itemDescription LIKE '%spam%';


-- Question 10
-- Which item(s) (if any) have a total value of exactly $100 in one package?
SELECT DISTINCT
    i.itemDescription
FROM item AS i
JOIN package_contents AS pc
    ON i.itemId = pc.itemId
WHERE i.itemValue * pc.itemQuantity = 100;


-- Question 11
-- How many volunteers are assigned to tasks with each different status?
-- Sorted from highest to lowest number of volunteers.
SELECT
    ts.taskStatusName AS taskStatus,
    COUNT(DISTINCT a.volunteerId) AS numVolunteers
FROM task_status AS ts
JOIN task AS t
    ON ts.taskStatusId = t.taskStatusId
JOIN assignment AS a
    ON t.taskCode = a.taskCode
GROUP BY
    ts.taskStatusId,
    ts.taskStatusName
ORDER BY numVolunteers DESC;


-- Question 12
-- Which task creates the heaviest set of packages and what is the weight?
SELECT
    taskCode,
    SUM(packageWeight) AS totalWeight
FROM package
GROUP BY taskCode
ORDER BY totalWeight DESC
LIMIT 1;


-- Question 13
-- How many tasks are there that do not have a type of "packing"?
SELECT
    COUNT(*) AS nonPackingTasks
FROM task AS t
JOIN task_type AS tt
    ON t.taskTypeId = tt.taskTypeId
WHERE tt.taskTypeName <> 'packing';


-- Question 14
-- Of those items that have been packed, which item (or items) were
-- touched by fewer than 3 volunteers?
SELECT
    i.itemDescription
FROM item AS i
JOIN package_contents AS pc
    ON i.itemId = pc.itemId
JOIN package AS p
    ON pc.packageId = p.packageId
LEFT JOIN assignment AS a
    ON p.taskCode = a.taskCode
GROUP BY
    i.itemId,
    i.itemDescription
HAVING COUNT(DISTINCT a.volunteerId) < 3;


-- Question 15
-- Which packages have a total value of more than 100?
-- Sorted from lowest to highest value.
SELECT
    pc.packageId,
    SUM(pc.itemQuantity * i.itemValue) AS packageValue
FROM package_contents AS pc
JOIN item AS i
    ON pc.itemId = i.itemId
GROUP BY pc.packageId
HAVING SUM(pc.itemQuantity * i.itemValue) > 100
ORDER BY packageValue ASC;
