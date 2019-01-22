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

CREATE OR ALTER FUNCTION is_student_customer(@CustomerID int)
  returns bit
    AS
    BEGIN
        IF((SELECT COUNT(AttendantID) FROM Attendants GROUP BY CustomerID HAVING CustomerID=@CustomerID)>1)
      BEGIN
          return 0
      end
      else
      DECLARE @AttendantID INT = (SELECT MAX(AttendantID) FROM Attendants Group BY CustomerID HAVING CustomerID=@CustomerID)
      if EXISTS(SELECT * FROM Students WHERE AttendantID=@AttendantID)
      BEGIN
        RETURN 1
      end
      ELSE return 0;
      return 0;
    end

Create OR ALTER function get_total_cost(@Reservation int)
RETURNS INT
AS
  BEGIN
    DECLARE @CustomerID int = (SELECT CustomerID FROM Reservations WHERE ReservationID=@Reservation)
    DECLARE @seminar int = (SELECT SUM(dbo.get_seminar_reservation_cost(SeminarReservationID)) FROM SeminarReservations WHERE ReservationID=@Reservation)
    DECLARE @conference int = dbo.get_conference_reservation_cost(ReservationID)
    RETURN @seminar+@conference
  END;

CREATE OR ALTER function conference_day_list(@DayID int)
RETURNS TABLE
AS RETURN
  SELECT DISTINCT FirstName, LastName from Attendants JOIN ConferenceParticipants ON ConferenceParticipants.AttendantID=Attendants.AttendantID JOIN Reservations on ConferenceParticipants.ReservationsID = Reservations.ReservationID WHERE @DayID=Reservations.ConferenceDayID


CREATE OR ALTER function seminar_day_list(@SeminarID int)
RETURNS TABLE
AS RETURN
  SELECT DISTINCT FirstName, LastName from Attendants JOIN ConferenceParticipants ON ConferenceParticipants.AttendantID=Attendants.AttendantID JOIN SeminarParticipants on ConferenceParticipants.ConferenceParticipantID = SeminarParticipants.ConferenceParticipantID JOIN SeminarReservations SR on SeminarParticipants.SeminarReservationID = SR.SeminarReservationID WHERE @SeminarID=SeminarID
