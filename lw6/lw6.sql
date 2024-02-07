--1
--order
ALTER TABLE [dbo].[order]  WITH CHECK ADD  CONSTRAINT [FK_order_dealer] FOREIGN KEY([id_dealer])
REFERENCES [dbo].[dealer] ([id_dealer])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[order] CHECK CONSTRAINT [FK_order_dealer]
GO

ALTER TABLE [dbo].[order]  WITH CHECK ADD  CONSTRAINT [FK_order_pharmacy] FOREIGN KEY([id_pharmacy])
REFERENCES [dbo].[pharmacy] ([id_pharmacy])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[order] CHECK CONSTRAINT [FK_order_pharmacy]
GO

ALTER TABLE [dbo].[order]  WITH CHECK ADD  CONSTRAINT [FK_order_production] FOREIGN KEY([id_production])
REFERENCES [dbo].[production] ([id_production])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[order] CHECK CONSTRAINT [FK_order_production]
GO

--dealer
ALTER TABLE [dbo].[dealer]  WITH CHECK ADD  CONSTRAINT [FK_dealer_company] FOREIGN KEY([id_company])
REFERENCES [dbo].[company] ([id_company])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[dealer] CHECK CONSTRAINT [FK_dealer_company]
GO

--production
ALTER TABLE [dbo].[production]  WITH CHECK ADD  CONSTRAINT [FK_production_company] FOREIGN KEY([id_company])
REFERENCES [dbo].[company] ([id_company])
GO

ALTER TABLE [dbo].[production] CHECK CONSTRAINT [FK_production_company]
GO

ALTER TABLE [dbo].[production]  WITH CHECK ADD  CONSTRAINT [FK_production_medicine] FOREIGN KEY([id_medicine])
REFERENCES [dbo].[medicine] ([id_medicine])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[production] CHECK CONSTRAINT [FK_production_medicine]
GO

--2
SELECT ph.[name], o.[date], o.quantity
FROM [order] AS o
JOIN pharmacy AS ph ON ph.id_pharmacy = o.id_pharmacy
WHERE o.id_production IN (
	SELECT pr.id_production
	FROM production as pr
	JOIN company AS c ON c.id_company = pr.id_company
	JOIN medicine AS m ON m.id_medicine = pr.id_medicine
	WHERE m.[name] = 'Кордерон' AND c.[name] = 'Аргус'
)
--3
-- ошибочка
SELECT m.[name]
FROM medicine AS m
JOIN production AS pr ON pr.id_medicine =m.id_medicine
LEFT JOIN (
	SELECT o.id_production
	FROM [order] AS o
	WHERE o.[date] < '2019-01-25'
) AS o_before ON pr.id_production = o_before.id_production
JOIN company AS c ON c.id_company = pr.id_company
WHERE o_before.id_production IS NULL AND c.[name] = 'Фарма'

SELECT m.[name]
FROM medicine AS m
JOIN production AS pr ON pr.id_medicine = m.id_medicine
JOIN (
	SELECT o.id_production
	FROM [order] AS o
	GROUP BY o.id_production
	HAVING MIN(o.[date]) >= '2019-01-25'
) AS o_after ON o_after.id_production = pr.id_production
JOIN company AS c On c.id_company = pr.id_company
WHERE c.[name] = 'Фарма'


SELECT m.[name]
FROM medicine AS m
JOIN production AS pr ON pr.id_medicine = m.id_medicine
JOIN company AS c On c.id_company = pr.id_company
WHERE c.[name] = 'Фарма' AND id_production IN (
	SELECT o.id_production
	FROM [order] AS o
	GROUP BY o.id_production
	HAVING MIN(o.[date]) >= '2019-01-25'
)


--4
-- фирма и мин балл лек. + макс балл лек.
SELECT c.[name], min_max_rating.min_rating, min_max_rating.max_rating
FROM company AS c
JOIN (
	SELECT pr.id_company, MIN(pr.rating) AS min_rating, MAX(pr.rating) AS max_rating
	FROM production AS pr
	GROUP BY pr.id_company
) AS min_max_rating ON c.id_company = min_max_rating.id_company;
--5
SELECT d.[name], ph.[name]
FROM dealer AS d
JOIN company AS c ON c.id_company = d.id_company
LEFT JOIN [order] AS o ON o.id_dealer = d.id_dealer
LEFT JOIN pharmacy AS ph ON ph.id_pharmacy = o.id_pharmacy
WHERE c.[name] = 'AstraZeneca'
--6
-- JOIN
UPDATE production
SET price = price * 0.8
WHERE price > 3000 AND id_medicine IN (
	SELECT m.id_medicine
	FROM medicine AS m
	WHERE m.cure_duration <= 7
)

UPDATE pr
SET pr.price = pr.price * 0.8
FROM production AS pr
JOIN medicine AS m ON m.id_medicine = pr.id_medicine
WHERE pr.price > 3000 AND m.cure_duration <= 7

UPDATE production
SET price = price * 1.25
WHERE price > 3000 AND id_medicine IN (
	SELECT m.id_medicine
	FROM medicine AS m
	WHERE m.cure_duration <= 7
)

SELECT *
FROM production AS pr
WHERE pr.price > 3000 AND pr.id_medicine IN (
	SELECT m.id_medicine
	FROM medicine AS m
	WHERE m.cure_duration <= 7
)
--7
--order
USE [pharmacy]
GO

/****** Object:  Index [IX_order_id-production]    Script Date: 10.04.2022 23:03:00 ******/
CREATE NONCLUSTERED INDEX [IX_order_id-production] ON [dbo].[order]
(
	[id_production] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

/****** Object:  Index [IX_order_id-pharmacy]    Script Date: 10.04.2022 23:03:27 ******/
CREATE NONCLUSTERED INDEX [IX_order_id-pharmacy] ON [dbo].[order]
(
	[id_pharmacy] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

/****** Object:  Index [IX_order_id-dealer]    Script Date: 10.04.2022 23:03:43 ******/
CREATE NONCLUSTERED INDEX [IX_order_id-dealer] ON [dbo].[order]
(
	[id_dealer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

--production
USE [pharmacy]
GO

/****** Object:  Index [IX_production_id-medicine]    Script Date: 10.04.2022 23:04:18 ******/
CREATE NONCLUSTERED INDEX [IX_production_id-medicine] ON [dbo].[production]
(
	[id_medicine] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

/****** Object:  Index [IX_production_id-company]    Script Date: 10.04.2022 23:04:28 ******/
CREATE NONCLUSTERED INDEX [IX_production_id-company] ON [dbo].[production]
(
	[id_company] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

--dealer
USE [pharmacy]
GO

/****** Object:  Index [IX_dealer_id-company]    Script Date: 10.04.2022 23:05:06 ******/
CREATE NONCLUSTERED INDEX [IX_dealer_id-company] ON [dbo].[dealer]
(
	[id_company] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

--company
USE [pharmacy]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_company_name]    Script Date: 10.04.2022 23:05:29 ******/
CREATE NONCLUSTERED INDEX [IX_company_name] ON [dbo].[company]
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

--medicine
USE [pharmacy]
GO

SET ANSI_PADDING ON
GO

/****** Object:  Index [IX_medicine_name]    Script Date: 10.04.2022 23:05:54 ******/
CREATE NONCLUSTERED INDEX [IX_medicine_name] ON [dbo].[medicine]
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO