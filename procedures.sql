-- Add conference procedure with end date
CREATE OR ALTER PROCEDURE AddConferenceWithEndDate @Topic TEXT,
                                                   @StartDate DATE,
                                                   @EndDate DATE,
                                                   @Address TEXT,
                                                   @DefaultPrice NUMERIC(6, 2),
                                                   @DefaultSeats INT
AS
BEGIN
  IF (@StartDate > @EndDate)
    BEGIN
      RAISERROR ('Start date cannot be later than end date', 0, 0)

      RETURN
    END

  INSERT INTO Conference(Topic, StartDate, EndDate, Address) VALUES (@Topic, @StartDate, @EndDate, @Address);

  DECLARE @conference_day AS DATE
  DECLARE @last_conference_id AS INT
  SET @conference_day = @StartDate
  SET @last_conference_id = @@IDENTITY
  WHILE @conference_day <= @EndDate
  BEGIN
    EXEC AddConferenceDay
         @Date = @conference_day,
         @Seats = @DefaultSeats,
         @Price = @DefaultPrice,
         @ConferenceID = @last_conference_id;
    SET @conference_day = DATEADD(day, 1, @conference_day)
  END
END
GO

-- Add conference procedure
CREATE OR ALTER PROCEDURE AddConference @Topic TEXT, @StartDate DATE, @Address TEXT, @DefaultPrice NUMERIC(6, 2),
                                        @DefaultSeats INT
AS
EXEC AddConferenceWithEndDate
     @Topic = @Topic,
     @StartDate = @StartDate,
     @EndDate = @StartDate,
     @Address = @Address,
     @DefaultPrice = @DefaultPrice,
     @DefaultSeats = @DefaultSeats
GO

-- Get conference start date by conference ID
CREATE OR ALTER FUNCTION GetConferenceStartDate(@ConferenceID INT)
  RETURNS DATE
AS
BEGIN
  DECLARE @result as DATE
  SET @result = (SELECT StartDate FROM Conference WHERE Conference.ConferenceID = @ConferenceID)
  RETURN @result
END
GO

-- Get conference end date by conference ID
CREATE OR ALTER FUNCTION GetConferenceEndDate(@ConferenceID INT)
  RETURNS DATE
AS
BEGIN
  DECLARE @result as DATE
  SET @result = (SELECT EndDate FROM Conference WHERE Conference.ConferenceID = @ConferenceID)
  RETURN @result
END
GO

-- Adds new conference day
CREATE OR ALTER PROCEDURE AddConferenceDay @Date DATE, @Seats INT, @Price NUMERIC(6, 2), @ConferenceID INT
AS
BEGIN
  IF @Seats < 0
    BEGIN
      RAISERROR ('Number of seats must be a positive number', 0, 0)

      RETURN
    END

  IF NOT @Date BETWEEN dbo.GetConferenceStartDate(@ConferenceID) AND dbo.GetConferenceEndDate(@ConferenceID)
    BEGIN
      RAISERROR ('Conference day date must be within conference', 0, 0)

      RETURN
    END

  INSERT INTO ConferenceDay(Date, Seats, Price, ConferenceID) values (@Date, @Seats, @Price, @ConferenceID)
END
GO

-- Adds new discount
CREATE OR ALTER PROCEDURE AddDiscount @MinOutrunning INT,
                                      @MaxOutrunning INT,
                                      @Discount NUMERIC(4, 2),
                                      @StudentDiscount NUMERIC(4, 2),
                                      @ConferenceID INT
AS
BEGIN
  IF @MinOutrunning > @MaxOutrunning
    BEGIN
      RAISERROR ('Min outrunning cannot be bigger than max outrunning', 0, 0)

      RETURN
    END

  IF NOT EXISTS(SELECT * FROM Conference WHERE Conference.ConferenceID = @ConferenceID)
    BEGIN
      RAISERROR ('Conference ID does not exist', 0, 0)

      RETURN
    END

  INSERT INTO Discounts(MinOutrunning, MaxOutrunning, Discount, StudentDiscount, ConferenceID)
  VALUES (@MinOutrunning, @MaxOutrunning, @Discount, @StudentDiscount, @ConferenceID)
END
GO

-- Adds new seminar
CREATE OR ALTER PROCEDURE AddSeminar @Seats INT, @Price NUMERIC(6, 2), @StartTime TIME, @EndTime TIME,
                                     @ConferenceDayID INT
AS
BEGIN
  IF @StartTime > @EndTime
    BEGIN
      RAISERROR ('Seminar start time cannot be later than end time', 0, 0)

      RETURN
    end

  IF NOT EXISTS(SELECT * FROM ConferenceDay WHERE ConferenceDay.ConferenceDayID = @ConferenceDayID)
    BEGIN
      RAISERROR ('Conference day ID does not exist', 0, 0)

      RETURN
    END

  IF @Seats < 0
    BEGIN
      RAISERROR ('Number of seats must be a positive number', 0, 0)

      RETURN
    END

  INSERT INTO Seminar(Seats, Price, StartTime, EndTime, ConferenceDayID)
  VALUES (@Seats, @Price, @StartTime, @EndTime, @ConferenceDayID)
END
GO

-- Get available seats by conference day ID
CREATE OR ALTER FUNCTION GetFreeSeatsByConferenceDayID(@ConferenceDayID INT)
  RETURNS INT
AS
BEGIN

  DECLARE @all_seats_at_conference AS INT
  DECLARE @already_taken_seats AS INT
  DECLARE @result AS INT
  SET @all_seats_at_conference =
      (SELECT Seats FROM ConferenceDay WHERE ConferenceDay.ConferenceDayID = @ConferenceDayID)
  SET @already_taken_seats =
      (SELECT SUM(SeatsReserved)
       FROM Reservations
       WHERE Reservations.ConferenceDayID = @ConferenceDayID
       GROUP BY Reservations.ConferenceDayID)
  SET @result = @all_seats_at_conference - @already_taken_seats
  RETURN @result
END
GO

-- Get available seats by conference day ID
CREATE OR ALTER FUNCTION GetFreeSeatsBySeminarID(@SeminarID INT)
  RETURNS INT
AS
BEGIN

  DECLARE @all_seats_at_seminar AS INT
  DECLARE @already_taken_seats AS INT
  DECLARE @result AS INT
  SET @all_seats_at_seminar = (SELECT Seats FROM Seminar WHERE Seminar.SeminarID = @SeminarID)
  SET @already_taken_seats =
      (SELECT SUM(SeatsReserved)
       FROM SeminarReservations
       WHERE SeminarReservations.SeminarID = @SeminarID
       GROUP BY SeminarReservations.SeminarID)
  SET @result = @all_seats_at_seminar - @already_taken_seats
  RETURN @result
END
GO

-- Adds new reservation
CREATE OR ALTER PROCEDURE AddReservation @CustomerID INT, @SeatsReserved INT, @ConferenceDayID INT
AS
BEGIN
  IF @SeatsReserved < 0
    BEGIN
      RAISERROR ('Reservation for zero seats does not make sense', 0, 0)

      RETURN
    END

  IF @SeatsReserved > dbo.GetFreeSeatsByConferenceDayID(@ConferenceDayID)
    BEGIN
      RAISERROR ('Not enough free seats to make a reservation', 0, 0)

      RETURN
    END

  IF NOT EXISTS(SELECT * FROM Customers WHERE Customers.CustomerID = @CustomerID)
    BEGIN
      RAISERROR ('Conference day ID does not exist', 0, 0)

      RETURN
    END

  IF NOT EXISTS(SELECT * FROM ConferenceDay WHERE ConferenceDay.ConferenceDayID = @ConferenceDayID)
    BEGIN
      RAISERROR ('Conference day ID does not exist', 0, 0)

      RETURN
    END

  INSERT INTO Reservations(ReservationDate,
                           PaymentDate,
                           CustomerID,
                           SeatsReserved,
                           ConferenceDayID)
  VALUES (GETDATE(),
          null,
          @CustomerID,
          @SeatsReserved,
          @ConferenceDayID)

  DECLARE @last_added_reservation_id AS INT
  SET @last_added_reservation_id = @@identity
  DECLARE @index AS INT
  SET @index = 0
  WHILE @index < @SeatsReserved
  BEGIN
    EXEC AddConferenceParticipant @ReservationsID = @last_added_reservation_id, @AttendantID = null
    SET @index = @index + 1
  end
END
GO

-- Adds customer
CREATE OR ALTER PROCEDURE AddCustomer @Name VARCHAR(50), @Email VARCHAR(50), @Phone VARCHAR(9)
AS
BEGIN
  IF @Name = ''
    BEGIN
      RAISERROR ('Name cannot be empty string', 0, 0)

      RETURN
    end

  IF @Email = ''
    BEGIN
      RAISERROR ('Email cannot be empty string', 0, 0)

      RETURN
    end

  IF @Phone = ''
    BEGIN
      RAISERROR ('Phone cannot be empty string', 0, 0)

      RETURN
    end

  INSERT INTO Customers(Name, Email, Phone) VALUES (@Name, @Email, @Phone)
end
GO

-- Adds payment
CREATE OR ALTER PROCEDURE AddPayment @Amount NUMERIC(6, 2), @ReservationsID INT
AS
BEGIN

  IF NOT EXISTS(SELECT * FROM Reservations WHERE Reservations.ReservationID = @ReservationsID)
    BEGIN
      RAISERROR ('Reservation ID does not exist', 0, 0)

      RETURN
    END

  INSERT INTO Payments(Amount, ReservationsID, PaymentDate) VALUES (@Amount, @ReservationsID, GETDATE())
end
GO

-- Adds conference participant
CREATE OR ALTER PROCEDURE AddConferenceParticipant @ReservationsID INT, @AttendantID INT
AS
BEGIN

  IF NOT EXISTS(SELECT * FROM Reservations WHERE Reservations.ReservationID = @ReservationsID)
    BEGIN
      RAISERROR ('Reservation ID does not exist', 0, 0)

      RETURN
    END

  INSERT INTO ConferenceParticipants (AttendantID, ReservationsID) VALUES (@AttendantID, @ReservationsID)
end
GO

-- Adds seminar participant
CREATE OR ALTER PROCEDURE AddSeminarParticipant @SeminarReservationID INT, @ConferenceParticipantID INT
AS
BEGIN

  IF NOT EXISTS(
      SELECT * FROM SeminarReservations WHERE SeminarReservations.SeminarReservationID = @SeminarReservationID)
    BEGIN
      RAISERROR ('Seminar reservation ID does not exist', 0, 0)

      RETURN
    END

  IF NOT EXISTS(SELECT *
                FROM ConferenceParticipants
                WHERE ConferenceParticipants.ConferenceParticipantID = @ConferenceParticipantID)
    BEGIN
      RAISERROR ('Conference participant ID does not exist', 0, 0)

      RETURN
    END
end
GO

-- Adds seminar reservations
CREATE OR ALTER PROCEDURE AddSeminarReservation @ReservationID INT, @SeatsReserved INT, @SeminarID INT
AS
BEGIN
  IF @SeatsReserved < 0
    BEGIN
      RAISERROR ('Reservation for zero seats does not make sense', 0, 0)

      RETURN
    END

  IF NOT EXISTS(SELECT * FROM Seminar WHERE Seminar.SeminarID = @SeminarID)
    BEGIN
      RAISERROR ('Seminar ID does not exist', 0, 0)

      RETURN
    END

  IF @SeatsReserved > dbo.GetFreeSeatsBySeminarID(@SeminarID)
    BEGIN
      RAISERROR ('Not enough free seats to make a reservation', 0, 0)

      RETURN
    END

  IF NOT EXISTS(SELECT * FROM Reservations WHERE Reservations.ReservationID = @ReservationID)
    BEGIN
      RAISERROR ('Conference reservation ID does not exist', 0, 0)

      RETURN
    END

  INSERT INTO SeminarReservations(ReservationID,
                                  SeatsReserved,
                                  SeminarID)
  VALUES (@ReservationID, @SeatsReserved, @SeminarID)

  DECLARE @last_added_reservation_id AS INT
  SET @last_added_reservation_id = @@identity
  DECLARE @index AS INT
  SET @index = 0
  WHILE @index < @SeatsReserved
  BEGIN
    EXEC AddSeminarParticipant @SeminarReservationID = @last_added_reservation_id, @ConferenceParticipantID = null
    SET @index = @index + 1
  end
END
GO

-- Adds attendant
CREATE OR ALTER PROCEDURE AddAttendant @FirstName VARCHAR(20), @LastName VARCHAR(40), @CustomerID INT
AS
BEGIN
  IF @FirstName = ''
    BEGIN
      RAISERROR ('First name cannot be empty string', 0, 0)

      RETURN
    end

  IF @LastName = ''
    BEGIN
      RAISERROR ('Last name cannot be empty string', 0, 0)

      RETURN
    end

  IF NOT EXISTS(SELECT * FROM Customers WHERE Customers.CustomerID = @CustomerID)
    BEGIN
      RAISERROR ('Customer ID does not exist', 0, 0)

      RETURN
    END

  INSERT INTO Attendants(FirstName, LastName, CustomerID) VALUES (@FirstName, @LastName, @CustomerID)
end
GO

-- Adds student ID
CREATE OR ALTER PROCEDURE AddStudent @AttendantID INT, @StudendNumber INT
AS
BEGIN

  IF NOT EXISTS(SELECT * FROM Attendats WHERE Attendants.AttendantID = @AttendantID)
    BEGIN
      RAISERROR ('Attendant ID does not exist', 0, 0)

      RETURN
    END

  INSERT INTO Students(AttendantID, StudentNumber) VALUES (@AttendantID, @StudendNumber)
END
GO

-- View reservations without attendants assigned
CREATE OR ALTER VIEW ReservationsWithoutAttendants AS
SELECT Conference.Topic, Customers.*
FROM ConferenceParticipants
       LEFT JOIN Reservations ON Reservations.ReservationID = ConferenceParticipants.ReservationsID
       LEFT JOIN ConferenceDay ON ConferenceDay.ConferenceDayID = Reservations.ConferenceDayID
       LEFT JOIN Conference ON Conference.ConferenceID = ConferenceDay.ConferenceID
       LEFT JOIN Customers ON Customers.CustomerID = Reservations.CustomerID
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

-- Change number od seats at conference day
CREATE OR ALTER PROCEDURE ChangeSeatsConferenceDay @ConferenceDayID INT, @NewSeats INT
AS
BEGIN

  IF NOT EXISTS(SELECT * FROM ConferenceDay WHERE ConferenceDay.ConferenceDayID = @ConferenceDayID)
    BEGIN
      RAISERROR ('Conference day ID does not exist', 0, 0)
      RETURN
    END

  IF @NewSeats < 0
    BEGIN
      RAISERROR ('Negative number of seats does not make sense', 0, 0)
      RETURN
    END

  DECLARE @current_seats AS INT
  SET @current_seats = (SELECT Seats FROM ConfrenceDay WHERE ConferenceDay.ConferenceDayID = @ConferenceDayID)
  DECLARE @diff AS INT
  SET @diff = @NewSeats - @current_seats

  IF dbo.GetFreeSeatsByConferenceDayID(@ConferenceDayID) < (@diff * -1)
    BEGIN
      RAISERROR ('Cannot remove already reserved seats', 0, 0)
      RETURN
    END

  UPDATE ConferenceDay SET Seats = @NewSeats WHERE ConferenceDayID = @ConferenceDayID
end
GO

-- Change number od seats at conference day
CREATE OR ALTER PROCEDURE ChangeSeatsSeminar @SeminarID INT, @NewSeats INT
AS
BEGIN

  IF NOT EXISTS(SELECT * FROM Seminar WHERE Seminar.SeminarID = @SeminarID)
    BEGIN
      RAISERROR ('Seminar ID does not exist', 0, 0)
      RETURN
    END

  IF @NewSeats < 0
    BEGIN
      RAISERROR ('Negative number of seats does not make sense', 0, 0)
      RETURN
    END

  DECLARE @current_seats AS INT
  SET @current_seats = (SELECT Seats FROM Seminar WHERE Seminar.SeminarID = @SeminarID)
  DECLARE @diff AS INT
  SET @diff = @NewSeats - @current_seats

  IF dbo.GetFreeSeatsBySeminarID(@SeminarID) < (@diff * -1)
    BEGIN
      RAISERROR ('Cannot remove already reserved seats', 0, 0)
      RETURN
    END

  UPDATE Seminar SET Seats = @NewSeats WHERE SeminarID = @SeminarID
end
GO

-- Cancel conference
CREATE OR ALTER PROCEDURE CancelConference @ConferenceID INT
AS
BEGIN

  IF NOT EXISTS(SELECT * FROM Conference WHERE Conference.ConferenceID = @ConferenceID)
    BEGIN
      RAISERROR ('Conference ID does not exist', 0, 0)
      RETURN
    END

  UPDATE Conference SET IsCanceled = 1 WHERE ConferenceID = @ConferenceID
end
GO

-- Cancel conference
CREATE OR ALTER PROCEDURE CancelConferenceDay @ConferenceDayID INT
AS
BEGIN

  IF NOT EXISTS(SELECT * FROM ConferenceDay WHERE ConferenceDay.ConferenceDayID = @ConferenceDayID)
    BEGIN
      RAISERROR ('Conference day ID does not exist', 0, 0)
      RETURN
    END

  UPDATE ConferenceDay SET IsCanceled = 1 WHERE ConferenceDayID = @ConferenceDayID
end
GO

-- Cancel seminar
CREATE OR ALTER PROCEDURE CancelSeminar @SeminarID INT
AS
BEGIN

  IF NOT EXISTS(SELECT * FROM Seminar WHERE Seminar.SeminarID = @SeminarID)
    BEGIN
      RAISERROR ('Seminar ID does not exist', 0, 0)
      RETURN
    END

  UPDATE Seminar SET IsCanceled = 1 WHERE SeminarID = @SeminarID
end
GO

-- Cancel reservation
CREATE OR ALTER PROCEDURE CancelReservation @ReservationID INT
AS
BEGIN

  IF NOT EXISTS(SELECT * FROM Reservation WHERE Reservation.ReservationID = @ReservationID)
    BEGIN
      RAISERROR ('Reservation ID does not exist', 0, 0)
      RETURN
    END

  UPDATE Reservation SET IsCanceled = 1 WHERE ReservationID = @ReservationID
end
GO

-- Cancel seminar reservation
CREATE OR ALTER PROCEDURE CancelSeminarReservation @SeminarReservationID INT
AS
BEGIN

  IF NOT EXISTS(SELECT * FROM SeminarReservation WHERE SeminarReservation.SeminarReservationID = @SeminarReservationID)
    BEGIN
      RAISERROR ('Seminar Reservation ID does not exist', 0, 0)
      RETURN
    END

  UPDATE SeminarReservation SET IsCanceled = 1 WHERE SeminarReservationID = @SeminarReservationID
end
GO

-- Update conference day on conference update
CREATE OR ALTER TRIGGER CancelConferenceDayOnConferenceCancelation
  ON Conference
  AFTER UPDATE
  AS
  UPDATE ConferenceDay
  SET ConferenceDay.IsCanceled = (ConferenceDay.IsCanceled | Conference.IsCanceled)
  FROM ConferenceDay
         LEFT JOIN Conference ON ConferenceDay.ConferenceID = Conference.ConferenceID
GO

-- Update reservations on conference day update
CREATE OR ALTER TRIGGER CancelReservationOnConferenceDayCancelation
  ON ConferenceDay
  AFTER UPDATE
  AS
  UPDATE Reservations
  SET Reservations.IsCanceled = (Reservations.IsCanceled | ConferenceDay.IsCanceled)
  FROM Reservations
         LEFT JOIN ConferenceDay ON Reservations.ConferenceDayID = ConferenceDay.ConferenceDayID
GO

-- Update seminar on conference update
CREATE OR ALTER TRIGGER CancelSeminarOnConferenceDayCancelation
  ON ConferenceDay
  AFTER UPDATE
  AS
  UPDATE Seminar
  SET Seminar.IsCanceled = (Seminar.IsCanceled | ConferenceDay.IsCanceled)
  FROM Seminar
         LEFT JOIN ConferenceDay ON Seminar.ConferenceDayID = ConferenceDay.ConferenceDayID
GO

-- Update seminar reservation on seminar update
CREATE OR ALTER TRIGGER CancelSeminarReservationOnSeminarCancelation
  ON Seminar
  AFTER UPDATE
  AS
  UPDATE SeminarReservation
  SET SeminarReservation.IsCanceled = (SeminarReservation.IsCanceled | Seminar.IsCanceled)
  FROM SeminarReservation
         LEFT JOIN Seminar ON SeminarReservation.SeminarID = Seminar.SeminarID
GO

-- Update seminar participants on seminar reservation update
CREATE OR ALTER TRIGGER CancelSeminarParticipantOnSeminarReservationCancelation
  ON SeminarReservations
  AFTER UPDATE
  AS
  UPDATE SeminarParticipant
  SET SeminarParticipant.IsCanceled = (SeminarParticipant.IsCanceled | SeminarReservations.IsCanceled)
  FROM SeminarParticipant
         LEFT JOIN SeminarReservations
                   ON SeminarParticipant.SeminarReservationID = SeminarReservations.SeminarReservationID
GO

-- Update participants on reservation update
CREATE OR ALTER TRIGGER CancelParticipantOnReservationCancelation
  ON Reservations
  AFTER UPDATE
  AS
  UPDATE Participant
  SET Participant.IsCanceled = (Participant.IsCanceled | Reservations.IsCanceled)
  FROM Participant
         LEFT JOIN Reservations ON Participant.ReservationID = Reservations.ReservationID
GO

EXEC AddConferenceWithEndDate @Topic = 'Nuddyyyy', @StartDate = '2013-01-01', @EndDate = '2013-02-01', @Address = null,
     @DefaultPrice = 100, @DefaultSeats = 10
EXEC AddDiscount @MinOutrunning = 1, @MaxOutrunning = 2, @Discount = 10.00, @StudentDiscount = 20.00,
     @ConferenceID = 1
EXEC AddCustomer @Name = 'Tomek', @Email = 'tomek@gmail.com', @Phone = '123321123'
EXEC AddReservation @CustomerID = 1, @SeatsReserved = 5, @ConferenceDayID = 1
EXEC AddSeminar @Seats = 100, @Price = 10, @StartTime = '10:00:00', @EndTime = '11:00:00', @ConferenceDayID = 1
EXEC AddSeminarReservation @ReservationID = 1, @SeatsReserved = 2, @SeminarID = 1

SELECT *
From ReservationsWithoutAttendants

SELECT *
FROM SeminarReservations

SELECT *
FROM BestCustomersView
ORDER BY NumOfReservations