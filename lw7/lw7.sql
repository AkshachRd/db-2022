--1
--mark
ALTER TABLE [dbo].[mark]  WITH CHECK ADD  CONSTRAINT [FK_mark_lesson] FOREIGN KEY([id_lesson])
REFERENCES [dbo].[lesson] ([id_lesson])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[mark] CHECK CONSTRAINT [FK_mark_lesson]
GO

ALTER TABLE [dbo].[mark]  WITH CHECK ADD  CONSTRAINT [FK_mark_student] FOREIGN KEY([id_student])
REFERENCES [dbo].[student] ([id_student])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[mark] CHECK CONSTRAINT [FK_mark_student]
GO
--student
ALTER TABLE [dbo].[student]  WITH CHECK ADD  CONSTRAINT [FK_student_group] FOREIGN KEY([id_group])
REFERENCES [dbo].[group] ([id_group])
GO

ALTER TABLE [dbo].[student] CHECK CONSTRAINT [FK_student_group]
GO
--lesson
ALTER TABLE [dbo].[lesson]  WITH CHECK ADD  CONSTRAINT [FK_lesson_subject] FOREIGN KEY([id_subject])
REFERENCES [dbo].[subject] ([id_subject])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[lesson] CHECK CONSTRAINT [FK_lesson_subject]
GO

ALTER TABLE [dbo].[lesson]  WITH CHECK ADD  CONSTRAINT [FK_lesson_teacher] FOREIGN KEY([id_teacher])
REFERENCES [dbo].[teacher] ([id_teacher])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[lesson] CHECK CONSTRAINT [FK_lesson_teacher]
GO

--2
SELECT st.[name], m.mark
FROM student AS st
JOIN mark AS m ON m.id_student = st.id_student
JOIN lesson AS l ON l.id_lesson = m.id_lesson
JOIN [subject] as su ON su.id_subject = l.id_subject
WHERE su.[name] = 'Информатика'
ORDER BY m.mark DESC

CREATE VIEW [dbo].[View_1]
AS
SELECT TOP (100) PERCENT st.name, m.mark
FROM     dbo.student AS st INNER JOIN
                  dbo.mark AS m ON m.id_student = st.id_student INNER JOIN
                  dbo.lesson AS l ON l.id_lesson = m.id_lesson INNER JOIN
                  dbo.subject AS su ON su.id_subject = l.id_subject
WHERE  (su.name = 'Информатика')
ORDER BY m.mark DESC
GO
--3
CREATE PROCEDURE s
	@groupId AS INT
AS
	SELECT st.[name], su.[name]
	FROM mark AS m
	RIGHT JOIN student AS st ON st.id_student = m.id_student
	JOIN lesson AS l ON l.id_group = st.id_group
	JOIN [subject] AS su ON su.id_subject = l.id_subject
	WHERE st.id_group = 1 AND m.id_mark IS NULL
	GROUP BY st.[name], su.[name]
	ORDER BY st.[name]
GO

EXECUTE s @groupId = 3;

IF OBJECT_ID('s','P') IS NOT NULL
	DROP PROC s
--4
SELECT su.[name], ROUND(AVG(CAST(m.mark AS FLOAT)), 2) AS avg_mark
FROM [subject] AS su
JOIN (
	SELECT l.id_subject, l.id_group
	FROM lesson AS l
	GROUP BY l.id_subject, l.id_group
) AS su_g ON su_g.id_subject = su.id_subject
JOIN student AS st ON st.id_group = su_g.id_group
JOIN mark AS m ON m.id_student = st.id_student
GROUP BY su.[name], st.id_student
HAVING COUNT(*) >= 35

SELECT *
FROM [subject] AS su
JOIN (
	SELECT l.id_subject, l.id_group
	FROM lesson AS l
	GROUP BY l.id_subject, l.id_group
) AS su_g ON su_g.id_subject = su.id_subject
JOIN student AS st ON st.id_group = su_g.id_group
GROUP BY su.[name], st.id_student
HAVING COUNT(*) >= 35

SELECT k.[name], ROUND(AVG(CAST(m.mark AS FLOAT)), 2) AS avg_mark
FROM mark AS m
JOIN (
	SELECT su.id_subject
	FROM [subject] AS su
	JOIN (
		SELECT l.id_subject, l.id_group
		FROM lesson AS l
		GROUP BY l.id_subject, l.id_group
	) AS su_g ON su_g.id_subject = su.id_subject
	JOIN student AS st ON st.id_group = su_g.id_group
	GROUP BY su.id_subject
	HAVING COUNT(*) >= 35
) AS k ON k.id_student = m.id_student
GROUP BY k.[name], m.id_student

SELECT su.[name], ROUND(AVG(CAST(m.mark AS FLOAT)), 2) AS avg_mark
FROM mark AS m
LEFT JOIN lesson AS l ON l.id_lesson = m.id_lesson
JOIN (
	SELECT su.id_subject
	FROM [subject] AS su
	JOIN (
		SELECT l.id_subject, l.id_group
		FROM lesson AS l
		GROUP BY l.id_subject, l.id_group
	) AS su_g ON su_g.id_subject = su.id_subject
	JOIN student AS st ON st.id_group = su_g.id_group
	GROUP BY su.id_subject
	HAVING COUNT(*) >= 35
) AS k ON k.id_subject = l.id_subject
JOIN [subject] AS su ON su.id_subject = l.id_subject
GROUP BY su.[name]

SELECT su.[name], ROUND(AVG(CAST(m.mark AS FLOAT)), 2) AS avg_mark
FROM [subject] AS su
JOIN lesson AS l ON l.id_subject = su.id_subject
JOIN student AS st ON st.id_group = l.id_group
JOIN mark AS m ON m.id_student = st.id_student
GROUP BY su.[name]
HAVING COUNT(DISTINCT st.id_student) >= 35

--5
SELECT g.[name] AS group_name, st.[name] AS student_name, su.[name] AS subject_name, l.[date], m.mark
FROM student AS st
LEFT JOIN mark AS m ON m.id_student = st.id_student
LEFT JOIN lesson AS l ON l.id_lesson = m.id_lesson
JOIN [group] AS g ON g.id_group = st.id_group
LEFT JOIN [subject] AS su ON su.id_subject = l.id_subject
WHERE g.[name] = N'ВМ'

--6
UPDATE m
SET m.mark = m.mark + 1	
FROM mark AS m
JOIN lesson AS l ON l.id_lesson = m.id_lesson
JOIN [subject] AS su ON su.id_subject = l.id_subject
JOIN [group] AS g ON g.id_group = l.id_group
WHERE g.[name] = 'ПС' AND su.[name] = 'БД' AND DAY(l.[date]) < 12 AND MONTH(l.[date]) < 5 AND m.id_mark < 5

--7
USE [university]
GO

/****** Object:  Index [IX_student]    Script Date: 23.05.2022 0:12:38 ******/
CREATE NONCLUSTERED INDEX [IX_student-id-group] ON [dbo].[student]
(
	[id_group] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

USE [university]
GO

/****** Object:  Index [IX_mark_id-lesson]    Script Date: 23.05.2022 0:16:09 ******/
CREATE NONCLUSTERED INDEX [IX_mark_id-lesson] ON [dbo].[mark]
(
	[id_lesson] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

USE [university]
GO

/****** Object:  Index [IX_mark_id-student]    Script Date: 23.05.2022 0:16:20 ******/
CREATE NONCLUSTERED INDEX [IX_mark_id-student] ON [dbo].[mark]
(
	[id_student] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

USE [university]
GO

/****** Object:  Index [IX_lesson_id-group]    Script Date: 23.05.2022 0:18:15 ******/
CREATE NONCLUSTERED INDEX [IX_lesson_id-group] ON [dbo].[lesson]
(
	[id_group] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

USE [university]
GO

/****** Object:  Index [IX_lesson_id-subject]    Script Date: 23.05.2022 0:18:24 ******/
CREATE NONCLUSTERED INDEX [IX_lesson_id-subject] ON [dbo].[lesson]
(
	[id_subject] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

USE [university]
GO

/****** Object:  Index [IX_lesson_id-teacher]    Script Date: 23.05.2022 0:18:32 ******/
CREATE NONCLUSTERED INDEX [IX_lesson_id-teacher] ON [dbo].[lesson]
(
	[id_teacher] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

