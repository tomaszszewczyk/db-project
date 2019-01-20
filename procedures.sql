-- Add conference procedure with end date
CREATE PROCEDURE AddConferenceWithEndDate @Topic TEXT,
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
CREATE PROCEDURE AddConference @Topic TEXT, @StartDate DATE, @Address TEXT, @DefaultPrice NUMERIC(6, 2),
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
CREATE FUNCTION GetConferenceStartDate(@ConferenceID INT)
  RETURNS DATE
AS
BEGIN
  DECLARE @result as DATE
  SET @result = (SELECT StartDate FROM Conference WHERE Conference.ConferenceID = @ConferenceID)
  RETURN @result
END
GO

-- Get conference end date by conference ID
CREATE FUNCTION GetConferenceEndDate(@ConferenceID INT)
  RETURNS DATE
AS
BEGIN
  DECLARE @result as DATE
  SET @result = (SELECT EndDate FROM Conference WHERE Conference.ConferenceID = @ConferenceID)
  RETURN @result
END
GO

-- Adds new conference day
CREATE PROCEDURE AddConferenceDay @Date DATE, @Seats INT, @Price NUMERIC(6, 2), @ConferenceID INT
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
CREATE PROCEDURE AddDiscount @MinOutrunning INT,
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
CREATE PROCEDURE AddSeminar @Seats INT, @Price NUMERIC(6, 2), @StartTime TIME, @EndTime TIME, @ConferenceDayID INT
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

  INSERT INTO Seminar(SeminarID, Seats, Price, StartTime, EndTime, ConferenceDayID)
  VALUES (@SeminarID, @Seats, @Price, @StartTime, @EndTime, @ConferenceDayID)
END

EXEC AddConferenceWithEndDate @Topic = '', @StartDate = '2013-01-01', @EndDate = '2013-02-01', @Address = null,
     @DefaultPrice = 100, @DefaultSeats = 10
EXEC AddDiscount @MinOutrunning = 1, @MaxOutrunning = 2, @Discount = 10.00, @StudentDiscount = 20.00, @ConferenceID = 1

SELECT *
FROM Discounts