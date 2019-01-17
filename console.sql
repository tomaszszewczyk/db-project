use master
if exists(select * from sys.databases where name='tomek')
    drop database tomek
create database tomek
use tomek

create table Conferences (
    ConferenceID int not null primary key identity(1,1),
    DateStart date not null,
    DateEnd date not null,
    Seats int
)

create table Workshops (
    WorkshopID int not null primary key identity(1,1),
    Date date not null,
    Time time not null,
    ConferenceID int foreign key references Conferences(ConferenceID),
    Seats int,
    Price numeric
)

create table Discounts (
  DiscountID int not null primary key identity(1, 1),
  MinOutrunning int not null,
  MaxOutrunning int,
  Discount numeric not null
)

create table Payments (
  PaymentID int not null primary key identity(1,1),
  Bill numeric not null,
  Paid numeric not null,
  DueDate date not null,
  DiscountID int foreign key references Discounts(DiscountID),
  StudentID char(6)
)

create table Customers (
  CustomerID int not null primary key identity(1, 1),
  Name varchar(128) not null,
  Telephone varchar(9),
  IsACompany bit not null
)

create table Attendants (
  AttendantID int not null primary key identity(1, 1),
  Name varchar(128) not null,
  CustomerID int foreign key references Customers(CustomerID)
)

create table ConferenceReservations (
  ConferenceReservationID int not null primary key identity(1, 1),
  Data date not null,
  ConferenceID int not null foreign key references Conferences(ConferenceID),
  AttendantID int not null foreign key references Attendants(AttendantID),
  PaymentID int not null foreign key references Payments(PaymentID)
)

create table WorkShopReservations (
  WorkShopReservationID int not null primary key identity(1, 1),
  Date date not null,
  WorkshopID int not null foreign key references Workshops(WorkshopID),
  AttendantID int not null foreign key references Attendants(AttendantID),
  PaymentID int not null foreign key references Payments(PaymentID)
)