Create trigger unpaid_reservation
  ON Reservations
  AFTER INSERT, UPDATE AS
  begin
    if exists(SELECT SUM(Amount) FROM Payments GROUP BY ReservationID HAVING Sum(Amount)<get_total_cost(ReservationID))
    BEGIN
      RAISERROR('One of the reservations was not paid in time', 0, 0);
    end
  end
  go

  CREATE FUNCTION overlapping_seminar(@SeminarID int)
  RETURNS TABLE
  AS RETURN SELECT SeminarID FROM Seminar WHERE (dbo.GetSeminarStartTime(@SeminarID)<dbo.GetSeminarEndTime(SeminarID) AND dbo.GetSeminarStartTime(SeminarID)<dbo.GetSeminarEndTime(@SeminarID) AND SeminarID != @SeminarID )

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

Create function GetSeminarID(@SeminarReservationID int)
returns int
  AS
  begin
    return (SELECT SeminarID FROM SeminarReservations WHERE @SeminarReservationID=SeminarReservationID)
  end

Create trigger seminar_participant_check
  ON SeminarParticipants
  AFTER INSERT, UPDATE AS
  BEGIN
    IF (SELECT * FROM SeminarParticipants WHERE dbo.GetSeminarID(SeminarReservationID) IN (dbo.overlapping_seminar(dbo.GetSeminarID(SeminarReservationID))))
    BEGIN
    RAISERROR ('Participant is already signed up for seminar in that time', 16, 1);
  ROLLBACK TRANSACTION
  END
  end

