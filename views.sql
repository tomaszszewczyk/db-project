CREATE OR ALTER VIEW all_conferences AS (SELECT * from Conference)
GO

CREATE OR ALTER VIEW upcoming_conferences AS SELECT * from Conference WHERE DATEDIFF(month, GETDATE(), StartDate) BETWEEN 0 AND 3 -- Shows conferences starting within 3 months of current date
GO

CREATE OR ALTER VIEW reservations_not_paid AS SELECT SUM(Amount) AS Paid, dbo.get_total_cost(ReservationsID) AS Cost, ReservationsID AS ReservationID from Payments GROUP BY ReservationsID HAVING (SUM(Amount)<dbo.get_total_cost(ReservationsID))
GO

-- View reservations without attendants assigned
CREATE OR ALTER VIEW ReservationsWithoutAttendants AS
SELECT Conference.Topic, Customers.*
FROM ConferenceParticipants
       LEFT JOIN Reservations ON Reservations.ReservationID = ConferenceParticipants.ReservationsID
       LEFT JOIN ConferenceDay ON ConferenceDay.ConferenceDayID = Reservations.ConferenceDayID
       LEFT JOIN Conference ON Conference.ConferenceID = ConferenceDay.ConferenceID
       LEFT JOIN Customers ON Customers.CustomerID = Reservations.CustomerID
  WHERE ConferenceParticipants.AttendantID IS NULL
GO

-- View client summary
CREATE OR ALTER VIEW CustomersReservationCount AS
SELECT Customers.CustomerID, COUNT(*) AS NumOfReservations
FROM Customers
       JOIN Reservations ON Reservations.CustomerID = Customers.CustomerID
GROUP BY Customers.CustomerID
GO

-- View best customers
CREATE OR ALTER VIEW BestCustomersView AS
SELECT Customers.*, customer_count.NumOfReservations
FROM Customers
       JOIN CustomersReservationCount customer_count ON customer_count.CustomerID = Customers.CustomerID
GO

-- View conference days
CREATE OR ALTER VIEW ConferenceDayView AS
  SELECT * FROM ConferenceDay
GO

-- View conference days within conference
CREATE OR ALTER FUNCTION DaysWithinConferenceView (@ConferenceID INT) RETURNS TABLE
AS RETURN SELECT * FROM ConferenceDay WHERE ConferenceDay.ConferenceID = @ConferenceID
GO

-- View discounts
CREATE OR ALTER VIEW DiscountsView AS
  SELECT * FROM Discounts
GO

-- View discounts within conference
CREATE OR ALTER FUNCTION DiscountsWithinConferenceView (@ConferenceID INT) RETURNS TABLE
AS RETURN SELECT * FROM Discounts WHERE Discounts.ConferenceID = @ConferenceID
GO

-- View seminar
CREATE OR ALTER VIEW SeminarView AS
  SELECT * FROM Seminar
GO

-- View seminar within Conference Day
CREATE OR ALTER FUNCTION SeminarWithinConferenceDayView (@ConferenceDayID INT) RETURNS TABLE
  AS RETURN SELECT * FROM Seminar WHERE Seminar.ConferenceDayID = @ConferenceDayID
GO

-- View seminar within Conference
CREATE OR ALTER FUNCTION SeminarWithinConferenceView (@Conference INT) RETURNS TABLE
  AS RETURN
  SELECT Seminar.* FROM Seminar
  LEFT JOIN ConferenceDay ON Seminar.ConferenceDayID = ConferenceDay.ConferenceDayID
  WHERE ConferenceDay.ConferenceID = @Conference

-- View reservations
CREATE OR ALTER VIEW ReservationsView AS
  SELECT *,
         dbo.GetConferenceReservationCost(Reservations.ReservationID) AS Total,
         dbo.GetReservationPaid(Reservations.ReservationID) AS Paid
  FROM Reservations
GO

-- View conference day reservations
CREATE OR ALTER FUNCTION ReservationWithinConferenceDayView (@ConferenceDayID INT) RETURNS TABLE
  AS RETURN SELECT *,
         dbo.GetConferenceReservationCost(Reservations.ReservationID) AS Total,
         dbo.GetReservationPaid(Reservations.ReservationID) AS Paid
  FROM Reservations WHERE Reservations.ConferenceDayID = @ConferenceDayID
GO

-- View not paid reservations
CREATE OR ALTER VIEW DuePaidReservationView
AS
  SELECT *,
         dbo.GetConferenceReservationCost(Reservations.ReservationID) AS Total,
         dbo.GetReservationPaid(Reservations.ReservationID) AS Paid
  FROM Reservations
  WHERE dbo.GetConferenceReservationCost(Reservations.ReservationID) > dbo.GetReservationPaid(Reservations.ReservationID)
GO

-- View seminar reservations
CREATE OR ALTER VIEW ReservationsView AS
  SELECT * FROM SeminarReservations
GO

-- View seminar reservations by conference day reservation
CREATE OR ALTER FUNCTION ReservationWithinConferenceDayView (@ConferenceDayReservationID INT) RETURNS TABLE
  AS RETURN SELECT * FROM SeminarReservations WHERE SeminarReservations.ReservationID = @ConferenceDayReservationID
GO
