--1
--room_in_booking
USE [hotel_complex]
GO

ALTER TABLE [dbo].[room_in_booking]  WITH CHECK ADD  CONSTRAINT [FK_room_in_booking_room] FOREIGN KEY([id_room])
REFERENCES [dbo].[room] ([id_room])
GO

ALTER TABLE [dbo].[room_in_booking] CHECK CONSTRAINT [FK_room_in_booking_room]
GO

ALTER TABLE [dbo].[room_in_booking]  WITH CHECK ADD  CONSTRAINT [FK_room_in_booking_booking] FOREIGN KEY([id_booking])
REFERENCES [dbo].[booking] ([id_booking])
GO

ALTER TABLE [dbo].[room_in_booking] CHECK CONSTRAINT [FK_room_in_booking_booking]
GO
--room
USE [hotel_complex]
GO

ALTER TABLE [dbo].[room]  WITH CHECK ADD  CONSTRAINT [FK_room_hotel] FOREIGN KEY([id_hotel])
REFERENCES [dbo].[hotel] ([id_hotel])
GO

ALTER TABLE [dbo].[room] CHECK CONSTRAINT [FK_room_hotel]
GO

ALTER TABLE [dbo].[room]  WITH CHECK ADD  CONSTRAINT [FK_room_room_category] FOREIGN KEY([id_room_category])
REFERENCES [dbo].[room_category] ([id_room_category])
GO

ALTER TABLE [dbo].[room] CHECK CONSTRAINT [FK_room_room_category]
GO
--booking
USE [hotel_complex]
GO

ALTER TABLE [dbo].[booking]  WITH CHECK ADD  CONSTRAINT [FK_booking_client] FOREIGN KEY([id_client])
REFERENCES [dbo].[client] ([id_client])
GO

ALTER TABLE [dbo].[booking] CHECK CONSTRAINT [FK_booking_client]
GO

--2
SELECT c.id_client, c.[name], c.phone
FROM client AS c
LEFT JOIN booking AS b ON b.id_client = c.id_client
LEFT JOIN room_in_booking AS rib ON rib.id_booking = b.id_booking
LEFT JOIN room AS r ON rib.id_room = r.id_room
LEFT JOIN room_category AS rc ON r.id_room_category = rc.id_room_category
LEFT JOIN hotel as h ON r.id_hotel = h.id_hotel
WHERE h.[name] = 'Космос' AND rib.checkout_date >= '2019-04-01' AND rib.checkin_date <= '2019-04-01' AND rc.[name] = 'Люкс';

--3
SELECT *
FROM room AS r
WHERE r.id_room NOT IN (
	SELECT rib.id_room
	FROM room_in_booking AS rib
	WHERE MONTH(rib.checkout_date) >= '04' AND DAY(rib.checkout_date) >= '22' AND MONTH(rib.checkin_date) <= '04' AND DAY(rib.checkin_date) <= '22'
);

--4
SELECT rc.[name], SUM(ribbd.cnt) AS sum
FROM room_category AS rc
LEFT JOIN room AS r ON r.id_room_category = rc.id_room_category
LEFT JOIN (
	SELECT rib.id_room, COUNT(*) AS cnt
	FROM room_in_booking AS rib
	WHERE MONTH(rib.checkout_date) >= '03' AND DAY(rib.checkout_date) >= '23' AND MONTH(rib.checkin_date) <= '03' AND DAY(rib.checkin_date) <= '23'
	GROUP BY rib.id_room
) AS ribbd ON ribbd.id_room = r.id_room
GROUP BY rc.[name];

--5
-- name
SELECT c.[name], r.number
FROM booking AS b
LEFT JOIN room_in_booking AS rib ON rib.id_booking = b.id_booking
JOIN client AS c ON c.id_client = b.id_client
JOIN room AS r ON r.id_room = rib.id_room
WHERE rib.checkout_date IN (
	SELECT MAX(ribbd.checkout_date)
	FROM room_in_booking AS ribbd
	LEFT JOIN room AS r ON r.id_room = ribbd.id_room
	LEFT JOIN hotel AS h ON h.id_hotel = r.id_hotel
	WHERE MONTH(ribbd.checkout_date) = '04' AND h.[name] = 'Космос'
	GROUP BY ribbd.id_room
	HAVING ribbd.id_room = rib.id_room
)ORDER BY 2 ;

--6
UPDATE room_in_booking
SET checkout_date = DATEADD(day, 2, checkout_date)
WHERE id_room IN (
	SELECT r.id_room
	FROM room AS r
	LEFT JOIN room_category AS rc ON rc.id_room_category = r.id_room_category
	WHERE rc.[name] = 'Бизнес'
);

SELECT rib.checkout_date
FROM room_in_booking AS rib
WHERE rib.id_room IN (
	SELECT r.id_room
	FROM room AS r
	LEFT JOIN room_category AS rc ON rc.id_room_category = r.id_room_category
	WHERE rc.[name] = 'Бизнес'
);

--7
SELECT *
FROM room_in_booking AS a
INNER JOIN (
	SELECT *
	FROM room_in_booking
) AS b ON a.checkin_date < b.checkout_date AND a.checkout_date > b.checkin_date AND a.id_room = b.id_room
WHERE a.id_room_in_booking != b.id_room_in_booking

--8
--SCOPE_IDENTITY()
BEGIN TRANSACTION;
	INSERT INTO client VALUES ('Daniil Khudyakov', '+71284123883');
	INSERT INTO booking VALUES (SCOPE_IDENTITY(), '2022-03-29');
	INSERT INTO room_in_booking VALUES (
		SCOPE_IDENTITY(),
		(SELECT TOP 1 id_room FROM room ORDER BY NEWID()),
		'2022-03-29',
		'2022-04-11'
	);
COMMIT;

--9
--room_in_booking
USE [hotel_complex]
GO

/****** Object:  Index [IX_room_in_booking_checkin-date_checkout-date]    Script Date: 05.04.2022 21:33:33 ******/
CREATE NONCLUSTERED INDEX [IX_room_in_booking_checkin-date_checkout-date] ON [dbo].[room_in_booking]
(
	[checkin_date] ASC,
	[checkout_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

/****** Object:  Index [IX_room_in_booking_id-booking]    Script Date: 05.04.2022 21:33:59 ******/
CREATE NONCLUSTERED INDEX [IX_room_in_booking_id-booking] ON [dbo].[room_in_booking]
(
	[id_booking] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

/****** Object:  Index [IX_room_in_booking_id-room]    Script Date: 05.04.2022 21:34:13 ******/
CREATE NONCLUSTERED INDEX [IX_room_in_booking_id-room] ON [dbo].[room_in_booking]
(
	[id_room] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

--room
USE [hotel_complex]
GO

/****** Object:  Index [IX_room_id-hotel]    Script Date: 05.04.2022 21:34:36 ******/
CREATE NONCLUSTERED INDEX [IX_room_id-hotel] ON [dbo].[room]
(
	[id_hotel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

/****** Object:  Index [IX_room_id-room-category]    Script Date: 05.04.2022 21:36:10 ******/
CREATE NONCLUSTERED INDEX [IX_room_id-room-category] ON [dbo].[room]
(
	[id_room_category] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

--booking
USE [hotel_complex]
GO

/****** Object:  Index [IX_booking_id-client]    Script Date: 05.04.2022 21:37:22 ******/
CREATE NONCLUSTERED INDEX [IX_booking_id-client] ON [dbo].[booking]
(
	[id_client] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
	