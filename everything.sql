use master
if exists(select *
          from sys.databases
          where name = 'conference_project')
  drop database conference_project
create database conference_project
use conference_project


CREATE TABLE Attendants
(
  AttendantID int         NOT NULL IDENTITY (1,1),
  FirstName   varchar(20) NOT NULL,
  LastName    varchar(40) NOT NULL,
  CustomerID  int         NOT NULL,
  CONSTRAINT Attendants_pk PRIMARY KEY (AttendantID)
);

-- Table: Conference
CREATE TABLE Conference
(
  ConferenceID int         NOT NULL IDENTITY (1,1),
  Topic        varchar(50) NOT NULL,
  StartDate    date        NOT NULL,
  EndDate      date        NOT NULL,
  Adress       text        NOT NULL,
  IsCanceled   int DEFAULT 0
    CONSTRAINT Conference_pk PRIMARY KEY (ConferenceID),
  CONSTRAINT dates CHECK (EndDate > StartDate),
);

-- Table: ConferenceDay
CREATE TABLE ConferenceDay
(
  ConferenceDayID int           NOT NULL IDENTITY (1,1),
  Date            date          NOT NULL,
  Seats           int           NOT NULL CHECK (Seats > 0),
  Price           numeric(6, 2) NOT NULL,
  ConferenceID    int           NOT NULL,
  IsCanceled      int DEFAULT 0
    CONSTRAINT ConferenceDay_pk PRIMARY KEY (ConferenceDayID)
);

-- Table: ConferenceParticipants
CREATE TABLE ConferenceParticipants
(
  ConferenceParticipantID int NOT NULL IDENTITY (1,1),
  AttendantID             int NOT NULL,
  ReservationsID          int NOT NULL,
  IsCanceled              int DEFAULT 0
    CONSTRAINT ConferenceParticipants_pk PRIMARY KEY (ConferenceParticipantID)
);

-- Table: Customers
CREATE TABLE Customers
(
  CustomerID int         NOT NULL IDENTITY (1,1),
  Name       varchar(50) NOT NULL,
  Email      varchar(50) NOT NULL CHECK (Email LIKE '_*@_*._*'),
  Phone      int         NOT NULL CHECK (Phone BETWEEN 100000000 and 999999999),
  CONSTRAINT Customers_pk PRIMARY KEY (CustomerID)
);

-- Table: Discounts
CREATE TABLE Discounts
(
  MinOutrunning   int           NOT NULL,
  MaxOutrunning   int           NOT NULL,
  Discount        decimal(4, 2) NOT NULL CHECK (Discount > 0 AND Discount < 1),
  StudentDiscount decimal(4, 2) NOT NULL CHECK (StudentDiscount > 0 AND StudentDiscount < 1),
  ConferenceID    int           NOT NULL,
  CONSTRAINT Discounts_pk PRIMARY KEY (MinOutrunning)
);

-- Table: Payments
CREATE TABLE Payments
(
  PaymentID      int           NOT NULL IDENTITY (1,1),
  Amount         numeric(6, 2) NOT NULL CHECK (Amount > 0),
  ReservationsID int           NOT NULL,
  PaymentDate    date          NOT NULL,
  CONSTRAINT Payments_pk PRIMARY KEY (PaymentID)
);

-- Table: Reservations
CREATE TABLE Reservations
(
  ReservationID   int  NOT NULL IDENTITY (1,1),
  ReservationDate date NOT NULL,
  PaymentDate     date NULL,
  CustomerID      int  NOT NULL,
  SeatsReserved   int  NOT NULL CHECK (SeatsReserved >= 0),
  ConferenceDayID int  NOT NULL,
  IsCanceled      int DEFAULT 0
    CONSTRAINT Reservations_pk PRIMARY KEY (ReservationID)
);

-- Table: Seminar
CREATE TABLE Seminar
(
  SeminarID       int           NOT NULL IDENTITY (1,1),
  Seats           int           NOT NULL CHECK (Seats > 0),
  Price           numeric(6, 2) NULL,
  StartTime       time          NOT NULL,
  EndTime         time          NOT NULL,
  ConferenceDayID int           NOT NULL,
  IsCanceled      int DEFAULT 0
    CONSTRAINT Seminar_pk PRIMARY KEY (SeminarID),
  CONSTRAINT Times CHECK (EndTime > StartTime)
);

-- Table: SeminarParticipants
CREATE TABLE SeminarParticipants
(
  SeminarParticipantsID   int NOT NULL IDENTITY (1,1),
  SeminarReservationID    int NOT NULL,
  ConferenceParticipantID int NOT NULL,
  IsCanceled              int DEFAULT 0
    CONSTRAINT SeminarParticipants_pk PRIMARY KEY (SeminarParticipantsID)
);

-- Table: SeminarReservations
CREATE TABLE SeminarReservations
(
  SeminarReservationID int NOT NULL IDENTITY (1,1),
  ReservationID        int NOT NULL,
  SeatsReserved        int NOT NULL CHECK (SeatsReserved >= 0),
  SeminarID            int NOT NULL,
  IsCanceled           int DEFAULT 0
    CONSTRAINT SeminarReservations_pk PRIMARY KEY (SeminarReservationID)
);

-- Table: Students
CREATE TABLE Students
(
  StudentID     int NOT NULL IDENTITY (1,1),
  StudentNumber int NOT NULL,
  AttendantID   int NOT NULL UNIQUE,
  CONSTRAINT Students_pk PRIMARY KEY (StudentID)
);

-- foreign keys
-- Reference: Attendants_ConferenceParticipants (table: ConferenceParticipants)
ALTER TABLE ConferenceParticipants
  ADD CONSTRAINT Attendants_ConferenceParticipants FOREIGN KEY (AttendantID) REFERENCES Attendants (AttendantID);

-- Reference: Attendants_Customers (table: Attendants)
ALTER TABLE Attendants
  ADD CONSTRAINT Attendants_Customers FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID);

-- Reference: ConferenceDay_Conference (table: ConferenceDay)
ALTER TABLE ConferenceDay
  ADD CONSTRAINT ConferenceDay_Conference FOREIGN KEY (ConferenceID) REFERENCES Conference (ConferenceID);

-- Reference: ConferenceParticipants_Reservations (table: ConferenceParticipants)
ALTER TABLE ConferenceParticipants
  ADD CONSTRAINT ConferenceParticipants_Reservations FOREIGN KEY (ReservationsID) REFERENCES Reservations (ReservationID);

-- Reference: Conference_Discounts (table: Discounts)
ALTER TABLE Discounts
  ADD CONSTRAINT Conference_Discounts FOREIGN KEY (ConferenceID) REFERENCES Conference (ConferenceID);

-- Reference: Payments_Reservations (table: Payments)
ALTER TABLE Payments
  ADD CONSTRAINT Payments_Reservations FOREIGN KEY (ReservationsID) REFERENCES Reservations (ReservationID);

-- Reference: Reservations_ConferenceDay (table: Reservations)
ALTER TABLE Reservations
  ADD CONSTRAINT Reservations_ConferenceDay FOREIGN KEY (ConferenceDayID) REFERENCES ConferenceDay (ConferenceDayID);

-- Reference: Reservations_Customers (table: Reservations)
ALTER TABLE Reservations
  ADD CONSTRAINT Reservations_Customers FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID);

-- Reference: Reservations_SeminarReservations (table: SeminarReservations)
ALTER TABLE SeminarReservations
  ADD CONSTRAINT Reservations_SeminarReservations FOREIGN KEY (ReservationID) REFERENCES Reservations (ReservationID);

-- Reference: SeminarParticipants_ConferenceParticipants (table: SeminarParticipants)
ALTER TABLE SeminarParticipants
  ADD CONSTRAINT SeminarParticipants_ConferenceParticipants FOREIGN KEY (ConferenceParticipantID) REFERENCES ConferenceParticipants (ConferenceParticipantID);

-- Reference: SeminarParticipants_SeminarReservations (table: SeminarParticipants)
ALTER TABLE SeminarParticipants
  ADD CONSTRAINT SeminarParticipants_SeminarReservations FOREIGN KEY (SeminarReservationID) REFERENCES SeminarReservations (SeminarReservationID);

-- Reference: SeminarReservations_Seminar (table: SeminarReservations)
ALTER TABLE SeminarReservations
  ADD CONSTRAINT SeminarReservations_Seminar FOREIGN KEY (SeminarID) REFERENCES Seminar (SeminarID);

-- Reference: Seminar_ConferenceDay (table: Seminar)
ALTER TABLE Seminar
  ADD CONSTRAINT Seminar_ConferenceDay FOREIGN KEY (ConferenceDayID) REFERENCES ConferenceDay (ConferenceDayID);

-- Reference: Students_Attendants (table: Students)
ALTER TABLE Students
  ADD CONSTRAINT Students_Attendants FOREIGN KEY (AttendantID) REFERENCES Attendants (AttendantID);

-- Constraints
ALTER TABLE Conference
  ADD CONSTRAINT Conference_DateCheck CHECK (Conference.StartDate <= Conference.EndDate);

ALTER TABLE ConferenceDay
  ADD CONSTRAINT ConferenceDay_SeatsCheck CHECK (ConferenceDay.Seats >= 0);

ALTER TABLE Seminar
  ADD CONSTRAINT Seminar_SeatsCheck CHECK (Seminar.Seats >= 0);

ALTER TABLE Discounts
  ADD CONSTRAINT Discounts_OutrunningCheck CHECK (Discounts.MinOutrunning <= Discounts.MaxOutrunning);

ALTER TABLE Reservations
  ADD CONSTRAINT Reservation_SeatsResercedCheck CHECK (Reservations.SeatsReserved >= 0);

ALTER TABLE SeminarReservations
  ADD CONSTRAINT SeminarReservations_SeatsReservedCheck CHECK (SeminarReservations.SeatsReserved >= 0);

GO

  CREATE OR ALTER function GetConferenceReservationCost(@ReservationID INT)
  RETURNS NUMERIC(6, 2)
AS
BEGIN
  DECLARE @result AS NUMERIC(6, 2)
  SET @result = (SELECT SeatsReserved *
                        (SELECT Price
                         FROM ConferenceDay
                         WHERE ConferenceDay.ConferenceDayID = Reservations.ConferenceDayID)
                 FROM Reservations
                 WHERE ReservationID = @ReservationID);
  RETURN @result
END
GO

CREATE OR ALTER FUNCTION GetReservationPaid(@ReservationID INT) RETURNS NUMERIC(6, 2)
AS
BEGIN
  DECLARE @result AS NUMERIC(6, 2)
  SET @result = (SELECT SUM(Amount) FROM Payments WHERE ReservationsID = @ReservationID GROUP BY ReservationsID)
  IF @result IS NOT NULL
    BEGIN
      RETURN @result
    END

  RETURN 0
END
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

CREATE OR ALTER FUNCTION IsAStudent(@CustomerID int)
  returns bit
AS
BEGIN
  IF ((SELECT COUNT(AttendantID) FROM Attendants GROUP BY CustomerID HAVING CustomerID = @CustomerID) > 1)
    BEGIN
      return 0
    end
  else
    DECLARE @AttendantID INT = (SELECT MAX(AttendantID)
                                FROM Attendants
                                Group BY CustomerID
                                HAVING CustomerID = @CustomerID)
  if EXISTS(SELECT * FROM Students WHERE AttendantID = @AttendantID)
    BEGIN
      RETURN 1
    END

  RETURN 0;
end
GO

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

  INSERT INTO Conference(Topic, StartDate, EndDate, Adress) VALUES (@Topic, @StartDate, @EndDate, @Address);

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

-- Add one day conference procedure
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

Create trigger unpaid_reservation
  ON Reservations
  AFTER INSERT, UPDATE AS
  begin
    if exists(SELECT SUM(Amount) FROM Payments GROUP BY ReservationsID HAVING Sum(Amount)<dbo.get_total_cost(ReservationsID))
    BEGIN
      RAISERROR('One of the reservations was not paid in time', 0, 0);
    end
  end
  go

  CREATE FUNCTION GetSeminarStartTime(@SeminarID INT)
  RETURNS time
AS
BEGIN
  DECLARE @result as time
  SET @result = (SELECT StartTime FROM Seminar WHERE SeminarID = @SeminarID)
  RETURN @result
END
go

CREATE FUNCTION GetSeminarEndTime(@SeminarID INT)
  RETURNS time
AS
BEGIN
  DECLARE @result as time
  SET @result = (SELECT EndTime FROM Seminar WHERE SeminarID = @SeminarID)
  RETURN @result
END
go

  CREATE FUNCTION overlapping_seminar(@SeminarID int)
  RETURNS TABLE
  AS RETURN SELECT SeminarID FROM Seminar WHERE (dbo.GetSeminarStartTime(@SeminarID)<dbo.GetSeminarEndTime(SeminarID) AND dbo.GetSeminarStartTime(SeminarID)<dbo.GetSeminarEndTime(@SeminarID) AND SeminarID != @SeminarID )
  GO



Create function GetSeminarID(@SeminarReservationID int)
returns int
  AS
  begin
    return (SELECT SeminarID FROM SeminarReservations WHERE @SeminarReservationID=SeminarReservationID)
  end
  GO

Create trigger seminar_participant_check
  ON SeminarParticipants
  AFTER INSERT, UPDATE AS
  BEGIN
    IF EXISTS( SELECT * FROM SeminarParticipants WHERE dbo.GetSeminarID(SeminarReservationID) IN (dbo.overlapping_seminar(dbo.GetSeminarID(SeminarReservationID))))
    BEGIN
    RAISERROR ('Participant is already signed up for seminar in that time', 16, 1)
    ROLLBACK TRANSACTION
    END
  end;
  GO

CREATE OR ALTER VIEW AllConferencesView AS SELECT * from Conference;
GO

CREATE OR ALTER VIEW UpcomingConferencesView AS SELECT * from Conference
WHERE DATEDIFF(month, GETDATE(), StartDate) BETWEEN 0 AND 3;-- Shows conferences starting within 3 months of current date
  GO

CREATE OR ALTER VIEW NotPaidReservationView AS
SELECT SUM(Amount) AS Paid, dbo.GetConferenceReservationCost(ReservationsID) AS Cost, ReservationsID AS ReservationID
from Payments
GROUP BY ReservationsID
HAVING (SUM(Amount) < dbo.GetConferenceReservationCost(ReservationsID));
GO

-- View reservations without attendants assigned
CREATE OR ALTER VIEW ReservationsWithoutAttendants AS
SELECT Conference.Topic, Customers.*
FROM ConferenceParticipants
       LEFT JOIN Reservations ON Reservations.ReservationID = ConferenceParticipants.ReservationsID
       LEFT JOIN ConferenceDay ON ConferenceDay.ConferenceDayID = Reservations.ConferenceDayID
       LEFT JOIN Conference ON Conference.ConferenceID = ConferenceDay.ConferenceID
       LEFT JOIN Customers ON Customers.CustomerID = Reservations.CustomerID
WHERE ConferenceParticipants.AttendantID IS NULL;
GO

-- View client summary
CREATE OR ALTER VIEW CustomersReservationCount AS
SELECT Customers.CustomerID, COUNT(*) AS NumOfReservations
FROM Customers
       JOIN Reservations ON Reservations.CustomerID = Customers.CustomerID
GROUP BY Customers.CustomerID;
GO

-- View best customers
CREATE OR ALTER VIEW BestCustomersView AS
SELECT Customers.*, customer_count.NumOfReservations
FROM Customers
       JOIN CustomersReservationCount customer_count ON customer_count.CustomerID = Customers.CustomerID;
       GO

-- View conference days
CREATE OR ALTER VIEW ConferenceDayView AS
SELECT *
FROM ConferenceDay;
GO

-- View conference days within conference

CREATE OR ALTER FUNCTION DaysWithinConferenceView(@ConferenceID INT) RETURNS TABLE
  AS RETURN (SELECT *
            FROM ConferenceDay
            WHERE ConferenceDay.ConferenceID = @ConferenceID)
  GO

-- View discounts
CREATE OR ALTER VIEW DiscountsView AS
SELECT *
FROM Discounts;
GO

-- View discounts within conference

CREATE OR ALTER FUNCTION DiscountsWithinConferenceView(@ConferenceID INT) RETURNS TABLE
  AS RETURN SELECT *
            FROM Discounts
            WHERE Discounts.ConferenceID = @ConferenceID;
            GO

-- View seminar
CREATE OR ALTER VIEW SeminarView AS
SELECT *
FROM Seminar;
GO

-- View seminar within Conference Day

CREATE OR ALTER FUNCTION SeminarWithinConferenceDayView(@ConferenceDayID INT) RETURNS TABLE
  AS RETURN SELECT *
            FROM Seminar
            WHERE Seminar.ConferenceDayID = @ConferenceDayID;
            GO


-- View seminar within Conference

CREATE OR ALTER FUNCTION SeminarWithinConferenceView(@Conference INT) RETURNS TABLE
  AS RETURN
  SELECT Seminar.*
  FROM Seminar
         LEFT JOIN ConferenceDay ON Seminar.ConferenceDayID = ConferenceDay.ConferenceDayID
  WHERE ConferenceDay.ConferenceID = @Conference;
  GO

-- View reservations
CREATE OR ALTER VIEW ReservationsView AS
SELECT *,
       dbo.GetConferenceReservationCost(Reservations.ReservationID) AS Total,
       dbo.GetReservationPaid(Reservations.ReservationID)           AS Paid
FROM Reservations;
GO
-- View conference day reservations

CREATE OR ALTER FUNCTION ReservationWithinConferenceDayView(@ConferenceDayID INT) RETURNS TABLE
  AS RETURN SELECT *,
                   dbo.GetConferenceReservationCost(Reservations.ReservationID) AS Total,
                   dbo.GetReservationPaid(Reservations.ReservationID)           AS Paid
            FROM Reservations
            WHERE Reservations.ConferenceDayID = @ConferenceDayID;
            GO

-- View not paid reservations
CREATE OR ALTER VIEW DuePaidReservationView
AS
SELECT *,
       dbo.GetConferenceReservationCost(Reservations.ReservationID) AS Total,
       dbo.GetReservationPaid(Reservations.ReservationID)           AS Paid
FROM Reservations
WHERE dbo.GetConferenceReservationCost(Reservations.ReservationID) > dbo.GetReservationPaid(Reservations.ReservationID);
GO

-- View seminar reservations
CREATE OR ALTER VIEW ReservationsView AS
SELECT *
FROM SeminarReservations;
GO
-- View seminar reservations by conference day reservation

CREATE OR ALTER FUNCTION ReservationWithinConferenceDayView(@ConferenceDayReservationID INT) RETURNS TABLE
  AS RETURN SELECT *
            FROM SeminarReservations
            WHERE SeminarReservations.ReservationID = @ConferenceDayReservationID;
            GO


-- View conference day list
CREATE OR ALTER function ConferenceDayListView(@DayID int)
  RETURNS TABLE
    AS RETURN
    SELECT DISTINCT FirstName, LastName
    from Attendants
           JOIN ConferenceParticipants ON ConferenceParticipants.AttendantID = Attendants.AttendantID
           JOIN Reservations on ConferenceParticipants.ReservationsID = Reservations.ReservationID
    WHERE @DayID = Reservations.ConferenceDayID;
    GO


-- View seminar day list
CREATE OR ALTER function SeminarDayListView(@SeminarID int)
  RETURNS TABLE
    AS RETURN
    SELECT DISTINCT FirstName, LastName
    from Attendants
           JOIN ConferenceParticipants ON ConferenceParticipants.AttendantID = Attendants.AttendantID
           JOIN SeminarParticipants
                on ConferenceParticipants.ConferenceParticipantID = SeminarParticipants.ConferenceParticipantID
           JOIN SeminarReservations SR on SeminarParticipants.SeminarReservationID = SR.SeminarReservationID
    WHERE @SeminarID = SeminarID;
GO











