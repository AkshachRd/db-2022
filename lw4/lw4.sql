--3.1 INSERT
--a
INSERT INTO prisoner VALUES ('19770812', 'Makar', 'Sidorov');
INSERT INTO imprisonment VALUES ('19681101', '19701101', 'strong', 4);
INSERT INTO imprisonment_has_criminal_code_article VALUES (21, 1);
INSERT visit VALUES ('209-01-01 00:00:00', '2010-01-01 00:00:00', 'Makar', 'Mikhail');

--b
INSERT INTO prisoner (birthday, first_name, last_name) VALUES ('19770812', 'Sidorov', 'Makar');
--c
INSERT INTO prisoner VALUES ('19770812', (SELECT visit.visitor_first_name, visit.visitor_first_name FROM visit WHERE visit.id_visit = 1));

--3.2 DELETE
--a
--DELETE FROM prisoner;
TRUNCATE TABLE prisoner;
--b
DELETE FROM prisoner WHERE prisoner.id_prisoner = 1;

--3.3 UPDATE
--a
UPDATE prisoner SET prisoner.first_name = 'Zakhar';
--b
UPDATE prisoner SET prisoner.first_name = 'Ilya' WHERE prisoner.id_prisoner = 1;
--c
UPDATE prisoner SET prisoner.first_name = 'Ilya', prisoner.last_name = 'Makarov' WHERE prisoner.id_prisoner = 1;

--3.4 SELECT
--a
SELECT prisoner.id_prisoner, prisoner.first_name FROM prisoner;
--b
SELECt * FROM prisoner;
--c
SELECT * FROM prisoner WHERE prisoner.id_prisoner = 1;

--3.5 SELECT ORDER BY + TOP (LIMIT)
--a
SELECT TOP (1) * FROM prisoner ORDER BY prisoner.first_name ASC;
--b
SELECT * FROM prisoner ORDER BY prisoner.id_prisoner DESC;
--c
SELECT TOP (5) * FROM prisoner ORDER BY prisoner.first_name, prisoner.last_name ASC;
--d
SELECT * FROM prisoner ORDER BY 1 DESC;

--3.6 WORKING WITH DATES
--a
SELECT * FROM visit WHERE visit.[begin] = '2021-01-01 00:00:00';
--b
SELECT * FROM visit WHERE visit.[begin] BETWEEN '2010-01-01 00:00:00' AND '2022-01-01 00:00:00';
--c
SELECT prisoner.id_prisoner, YEAR(prisoner.birthday) FROM prisoner;

--3.7 AGGREGATION FUNCTION
--a
SELECT COUNT(prisoner.id_prisoner) as records_number FROM prisoner;
--b
SELECT COUNT(DISTINCT prisoner.first_name) as unique_records_number FROM prisoner;
--c
SELECT DISTINCT prisoner.first_name FROM prisoner;
--d
SELECT MAX(criminal_code_article.max_sentence) FROM criminal_code_article;
--e
SELECT MIN(criminal_code_article.max_sentence) FROM criminal_code_article;
--f
SELECT COUNT(prisoner.first_name) as first_name_num FROM prisoner GROUP BY prisoner.first_name;

--3.8 SELECT GROUP BY + HEAVING
--показывает количество заключенных, которые имели больше 3 отсидок => они склонные к нарушению закона в последующем
SELECT imprisonment.id_prisoner, COUNT(imprisonment.id_prisoner) as sentences_number
FROM imprisonment
GROUP BY imprisonment.id_prisoner
HAVING COUNT(*) > 3;
--INSERT INTO imprisonment (imprisonment.severity, imprisonment.id_prisoner) VALUES ('weak', 2);

--показывает статьи уголовного кодекса, которые применяются болльше 2 раз
SELECT imprisonment_has_criminal_code_article.id_criminal_code_article, COUNT(*)
FROM imprisonment_has_criminal_code_article
GROUP BY imprisonment_has_criminal_code_article.id_criminal_code_article
HAVING COUNT(*) > 2
ORDER BY 2 ASC;

--показывает заключенных, которые были осужденны больше чем по 2 разным статьям
SELECT *
FROM imprisonment AS i
LEFT JOIN imprisonment_has_criminal_code_article AS ihcca
ON ihcca.id_imprisonment = i.id_prisoner
WHERE ihcca.id_criminal_code_article IN (
	SELECT id_criminal_code_article
	FROM imprisonment_has_criminal_code_article
	GROUP BY id_criminal_code_article
	HAVING COUNT(*) > 2
);



--3.9. SELECT JOIN
--a
SELECT imprisonment.id_imprisonment, CONCAT(prisoner.first_name, ' ', prisoner.last_name) as full_name, prisoner.id_prisoner
FROM imprisonment
LEFT JOIN prisoner ON prisoner.id_prisoner = imprisonment.id_prisoner
WHERE prisoner.birthday > '1977-01-01';
--b
SELECT imprisonment.id_imprisonment, CONCAT(prisoner.first_name, ' ', prisoner.last_name) as full_name, prisoner.id_prisoner
FROM prisoner
RIGHT JOIN imprisonment ON prisoner.id_prisoner = imprisonment.id_prisoner
WHERE prisoner.birthday > '1977-01-01';
--c
SELECT *
FROM prisoner
LEFT JOIN prisoner_has_visit ON prisoner.id_prisoner = prisoner_has_visit.id_prisoner
LEFT JOIN visit ON prisoner_has_visit.id_visit = visit.id_visit;
--d
SELECT *
FROM prisoner
INNER JOIN prisoner_has_visit ON prisoner.id_prisoner = prisoner_has_visit.id_prisoner

--3.10. SUBQUERIES
--a
SELECT *
FROM prisoner
WHERE prisoner.id_prisoner IN (
	SELECT prisoner_has_visit.id_prisoner
	FROM prisoner_has_visit
	WHERE prisoner.id_prisoner = prisoner_has_visit.id_prisoner
);
--b
SELECT prisoner.id_prisoner, prisoner.birthday, (
	SELECT prisoner.first_name FROM prisoner AS p WHERE prisoner.id_prisoner = p.id_prisoner) AS first_name
FROM prisoner;
--c
SELECT *
FROM (SELECT prisoner.first_name, prisoner.last_name FROM prisoner) AS p;
--d
SELECT *
FROM prisoner
INNER JOIN (SELECT * FROM imprisonment) AS i ON prisoner.id_prisoner = i.id_prisoner;
