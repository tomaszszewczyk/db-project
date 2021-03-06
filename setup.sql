use master
if exists(select *
          from sys.databases
          where name = 'conference_project')
  drop database conference_project
create database conference_project
use conference_project

CREATE TABLE Attendants (
    AttendantID int NOT NULL IDENTITY(1,1),
    FirstName varchar(20) NOT NULL,
    LastName varchar(40) NOT NULL,
    CustomerID int NOT NULL,
    CONSTRAINT Attendants_pk PRIMARY KEY (AttendantID)
);

-- Table: Conference
CREATE TABLE Conference (
    ConferenceID int NOT NULL IDENTITY(1,1),
    Topic varchar(50) NOT NULL,
    StartDate date NOT NULL,
    EndDate date NOT NULL,
    Adress text NOT NULL,
    CONSTRAINT Conference_pk PRIMARY KEY (ConferenceID),
    CONSTRAINT dates CHECK(EndDate>StartDate),
);

-- Table: ConferenceDay
CREATE TABLE ConferenceDay (
    ConferenceDayID int NOT NULL IDENTITY(1,1),
    Date date NOT NULL,
    Seats int NOT NULL CHECK (Seats>0),
    Price numeric(6,2) NOT NULL,
    ConferenceID int NOT NULL,
    CONSTRAINT ConferenceDay_pk PRIMARY KEY (ConferenceDayID)
);

-- Table: ConferenceParticipants
CREATE TABLE ConferenceParticipants (
    ConferenceParticipantID int NOT NULL IDENTITY(1,1),
    AttendantID int NOT NULL,
    ReservationsID int NOT NULL,
    CONSTRAINT ConferenceParticipants_pk PRIMARY KEY (ConferenceParticipantID)
);

-- Table: Customers
CREATE TABLE Customers (
    CustomerID int NOT NULL IDENTITY(1,1),
    Name varchar(50) NOT NULL,
    Email varchar(50) NOT NULL CHECK(Email LIKE '_*@_*._*'),
    Phone int NOT NULL CHECK(Phone BETWEEN 100000000 and 999999999),
    CONSTRAINT Customers_pk PRIMARY KEY (CustomerID)
);

-- Table: Discounts
CREATE TABLE Discounts (
    MinOutrunning int NOT NULL,
    MaxOutrunning int NOT NULL,
    Discount decimal(4,2) NOT NULL CHECK (Discount>0 AND Discount<1),
    StudentDiscount decimal(4,2) NOT NULL CHECK(StudentDiscount>0 AND StudentDiscount<1),
    ConferenceID int NOT NULL,
    CONSTRAINT Discounts_pk PRIMARY KEY (MinOutrunning)
);

-- Table: Payments
CREATE TABLE Payments (
    PaymentID int NOT NULL IDENTITY(1,1),
    Amount numeric(6,2) NOT NULL CHECK(Amount>0),
    ReservationsID int NOT NULL,
    CONSTRAINT Payments_pk PRIMARY KEY (PaymentID)
);

-- Table: Reservations
CREATE TABLE Reservations (
    ReservationID int NOT NULL IDENTITY(1,1),
    ReservationDate date NOT NULL,
    PaymentDate date NULL,
    CustomerID int NOT NULL,
    SeatsReserved int NOT NULL CHECK(SeatsReserved>=0,
    ConferenceDayID int NOT NULL,
    CONSTRAINT Reservations_pk PRIMARY KEY (ReservationID)
);

-- Table: Seminar
CREATE TABLE Seminar (
    SeminarID int NOT NULL IDENTITY(1,1),
    Seats int NOT NULL CHECK(Seats>0),
    Price numeric(6,2) NULL,
    StartTime time NOT NULL,
    EndTime time NOT NULL,
    ConferenceDayID int NOT NULL,
    CONSTRAINT Seminar_pk PRIMARY KEY (SeminarID),
    CONSTRAINT Times CHECK (EndTime>StartTime)
);

-- Table: SeminarParticipants
CREATE TABLE SeminarParticipants (
    SeminarParticipantsID int NOT NULL IDENTITY(1,1),
    SeminarReservationID int NOT NULL,
    ConferenceParticipantID int NOT NULL,
    CONSTRAINT SeminarParticipants_pk PRIMARY KEY (SeminarParticipantsID)
);

-- Table: SeminarReservations
CREATE TABLE SeminarReservations (
    SeminarReservationID int NOT NULL IDENTITY(1,1),
    ReservationID int NOT NULL,
    SeatsReserved int NOT NULL CHECK(SeatsReserved>=0),
    SeminarID int NOT NULL,
    CONSTRAINT SeminarReservations_pk PRIMARY KEY (SeminarReservationID)
);

-- Table: Students
CREATE TABLE Students (
    StudentID int NOT NULL IDENTITY(1,1),
    StudentNumber int NOT NULL,
    AttendantID int NOT NULL UNIQUE,
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