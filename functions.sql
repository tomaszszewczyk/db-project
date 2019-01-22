Create OR ALTER function get_seminar_reservation_cost(@SeminarReservationID int)
RETURNS INT
AS
  begin
    RETURN (select SUM(Price) FROM Seminar JOIN SeminarReservations ON Seminar.SeminarID=SeminarReservations.SeminarID WHERE SeminarReservationID=@SeminarReservationID);
end

Create OR ALTER function get_conference_reservation_cost(@ReservationID int)
RETURNS INT
AS
  begin
    RETURN (SELECT SUM(PRICE) FROM ConferenceDay JOIN Reservations ON Reservations.ConferenceDayID=ConferenceDay.ConferenceDayID WHERE Reservations.ReservationID=@ReservationID);
    end

Create OR ALTER function get_total_cost(@Reservation int)
RETURNS INT
AS
  BEGIN
    DECLARE @seminar int = (SELECT SUM(dbo.get_seminar_reservation_cost(SeminarReservationID)) FROM SeminarReservations WHERE ReservationID=@Reservation)
    DECLARE @conference int = (SELECT SUM(dbo.get_conference_reservation_cost(ReservationID)) FROM Reservations WHERE ReservationID=@Reservation)
    RETURN @seminar+@conference
  END;

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
    DECLARE @conference int = (SELECT SUM(dbo.get_conference_reservation_cost(ReservationID)) FROM Reservations WHERE ReservationID=@Reservation)
    DECLARE @discount int
        IF(dbo.is_student_customer(@CustomerID)=1)
        BEGIN
        SET @discount = (SELECT StudentDiscount FROM dbo.get_discount_table(dbo.get_conference(dbo.get_conference_day(@Reservation))))
        end
        ELSE
          BEGIN
        SET @discount = (SELECT Discount FROM dbo.get_discount_table(dbo.get_conference(dbo.get_conference_day(@Reservation))))
          end
      RETURN (@seminar+@conference)*(1-@discount)
  END
go

