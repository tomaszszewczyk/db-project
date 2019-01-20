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
