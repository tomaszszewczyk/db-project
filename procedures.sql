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
CREATE OR ALTER PROCEDURE AddSeminar @Seats INT, @Price NUMERIC(6, 2), @StartTime TIME, @EndTime TIME, @ConferenceDayID INT
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
CREATE OR ALTER FUNCTION GetFreeSeatsByConferenceID(@ConferenceDayID INT)
  RETURNS INT
AS
BEGIN
  DECLARE @all_seats_at_conference AS INT
  DECLARE @already_taken_seats AS INT
  DECLARE @result AS INT
  SET @all_seats_at_conference = (SELECT Seats FROM ConferenceDay WHERE ConferenceDay.ConferenceDayID = @ConferenceDayID)
  SET @already_taken_seats =
      (SELECT SUM(SeatsReserved)
       FROM Reservations
       WHERE Reservations.ConferenceDayID = @ConferenceDayID
       GROUP BY Reservations.ConferenceDayID)
  SET @result = @all_seats_at_conference - @already_taken_seats
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

  IF @SeatsReserved > dbo.GetFreeSeatsByConferenceID(@ConferenceDayID)
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

EXEC AddConferenceWithEndDate @Topic = '', @StartDate = '2013-01-01', @EndDate = '2013-02-01', @Address = null,
     @DefaultPrice = 100, @DefaultSeats = 10
EXEC AddDiscount @MinOutrunning = 1, @MaxOutrunning = 2, @Discount = 10.00, @StudentDiscount = 20.00,
     @ConferenceID = 1
EXEC AddCustomer @Name = 'Tomek', @Email = 'tomek@gmail.com', @Phone = '123321123'
EXEC AddReservation @CustomerID = 1, @SeatsReserved = 10, @ConferenceDayID = 1

SELECT *
FROM Reservations