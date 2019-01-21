CREATE OR ALTER VIEW all_conferences AS (SELECT * from Conference)
GO

CREATE OR ALTER VIEW upcoming_conferences AS SELECT * from Conference WHERE DATEDIFF(month, GETDATE(), StartDate) BETWEEN 0 AND 3 -- Shows conferences starting within 3 months of current date
GO

CREATE OR ALTER VIEW reservations_not_paid AS SELECT SUM(Amount) AS Paid, dbo.get_total_cost(ReservationsID) AS Cost, ReservationsID AS ReservationID from Payments GROUP BY ReservationsID HAVING (SUM(Amount)<dbo.get_total_cost(ReservationsID))
GO
