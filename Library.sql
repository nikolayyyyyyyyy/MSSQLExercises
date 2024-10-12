--Creating Database

CREATE DATABASE [Library]

GO

--Using the created database

USE [Library]

--Creating tables for our database

CREATE TABLE Authors(
Id INT PRIMARY KEY IDENTITY NOT NULL,
FirstName NVARCHAR(50) NOT NULL,
LastName NVARCHAR(50) NOT NULL
)

CREATE TABLE PushingHouses(
Id INT PRIMARY KEY IDENTITY NOT NULL,
[Name] NVARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE Genres(
Id INT PRIMARY KEY IDENTITY NOT NULL,
[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Positions(
Id INT PRIMARY KEY IDENTITY NOT NULL,
[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Telephones(
Id INT PRIMARY KEY IDENTITY NOT NULL,
PhoneNumber NVARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE Books(
Id INT PRIMARY KEY IDENTITY NOT NULL,
[Name] NVARCHAR(30) UNIQUE NOT NULL,
DateOfIssue DATE NOT NULL,
AuthorId INT FOREIGN KEY REFERENCES Authors(Id) NOT NULL,
PushingHouseId INT FOREIGN KEY REFERENCES PushingHouses(Id) NOT NULL,
GenreId INT FOREIGN KEY REFERENCES Genres(Id) NOT NULL
)

CREATE TABLE Employees(
Id INT PRIMARY KEY IDENTITY NOT NULL,
FirstName NVARCHAR(50) NOT NULL,
LastName NVARCHAR(50) NOT NULL,
PositionId INT FOREIGN KEY REFERENCES Positions(Id) NOT NULL,
TelephoneId INT FOREIGN KEY REFERENCES Telephones(Id) NOT NULL
)


CREATE TABLE Readers(
Id INT PRIMARY KEY IDENTITY NOT NULL,
FirstName NVARCHAR(50) NOT NULL,
LastName NVARCHAR(50) NOT NULL,
TelephoneId INT FOREIGN KEY REFERENCES Telephones(Id) NOT NULL
)

CREATE TABLE Browings(
BookId INT FOREIGN KEY REFERENCES Books(Id) NOT NULL,
ReaderId INT FOREIGN KEY REFERENCES Readers(Id) NOT NULL,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
DateOfTaking DATE NOT NULL,
Term DATE NOT NULL,
IsReturned BIT NOT NULL
)

GO

-- Inserts
INSERT INTO Authors (FirstName,LastName) 
VALUES 
('Nikolay', 'Nikolaev'), 
('Ivan', 'Kalimarov'),
('Kristiqn','Merakov'),
('Djenko','Djenkov')

INSERT INTO PushingHouses ([Name]) 
VALUES 
('SmyadovoOOD'), 
('ShumenLTD')

INSERT INTO Genres ([Name]) 
VALUES 
('History'), 
('Medieval History'),
('Action')

INSERT INTO Positions ([Name]) 
VALUES 
('Librarian'), 
('Assistant'),
('Big Boss')

INSERT INTO Telephones (PhoneNumber) 
VALUES 
('+3590887445248'), 
('+3590584489454'), 
('+3590848949888'),
('+35971268219'),
('+3598888772'),
('+35971626262')

INSERT INTO Books ([Name], DateOfIssue, AuthorId, PushingHouseId, GenreId) 
VALUES 
('The last battle', '2024-06-08', 1, 1, 1), 
('King Arthur', '2024-01-28', 2, 2, 2),
('Enemy at the gates','2024-04-10',1,1,1)

INSERT INTO Employees ([FirstName],[LastName], PositionId,TelephoneId) 
VALUES 
('Atanas','Genchev',1, 1), 
('Ivan','Radkev', 2, 2),
('Georgi','Mirqnov',2,3),
('Plamen','Georgiev',2,4)

INSERT INTO Readers ([FirstName],[LastName],TelephoneId) 
VALUES 
('Mikaela','Vasileva',5), 
('Debora','Ivanova', 6)

INSERT INTO Browings (BookId, ReaderId, EmployeeId, DateOfTaking, Term, IsReturned) 
VALUES

(1, 1, 3, '2024-10-01', '2024-11-01',0), 
(2, 2, 2, '2024-10-05', '2024-11-05',0),
(3,2,4,'2024-12-06','2024-11-05',0)

GO
SELECT
*
FROM Authors AS A
WHERE A.FirstName LIKE '%y%'

GO
SELECT
*
FROM Genres AS G
WHERE G.Id = 2

GO
SELECT
*
FROM Positions AS P
WHERE P.[Name] = 'Big Boss'

GO
SELECT 
*
FROM PushingHouses

GO
SELECT 
*
FROM Telephones

GO
SELECT
B.[Name] AS BookName,
A.FirstName AS [Author First Name],
A.LastName AS [Author Last Name],
P.[Name] AS [Pushing House],
G.[Name]
FROM Books AS B
JOIN Authors AS A ON A.Id = B.AuthorId
JOIN PushingHouses AS P ON P.Id = B.PushingHouseId
JOIN Genres AS G ON G.Id = B.GenreId
WHERE B.[Name] LIKE 'The%'

GO
UPDATE Browings
	SET IsReturned = 1
WHERE ReaderId = 1

GO
SELECT
BK.[Name] AS [BookName],
CONCAT_WS(' ',R.FirstName,R.LastName) AS [Reader],
CONCAT_WS(' ',E.FirstName,E.LastName) AS [Employee],
B.DateOfTaking,
B.Term,
B.IsReturned
FROM Browings AS B
JOIN Books AS BK ON BK.Id = B.BookId
JOIN Readers AS R ON R.Id = B.ReaderId
JOIN Employees AS E ON E.Id = B.EmployeeId
WHERE B.IsReturned = 1

GO

SELECT
B.[Name] AS BookName,
A.[FirstName] AS [Author First Name],
A.LastName AS [Athor Last Name],
R.FirstName AS [Reader First Name],
R.LastName AS [Reader Last Name]
FROM Books AS B
JOIN Browings AS BR ON BR.BookId = B.Id
JOIN Readers AS R ON R.Id = BR.ReaderId
JOIN Authors AS A ON B.AuthorId = A.Id
WHERE A.FirstName = 'Ivan'

GO

SELECT
B.[Name]
FROM Books AS B
JOIN Browings as BR ON BR.BookId = B.Id
JOIN Readers as R ON R.Id = BR.ReaderId
WHERE R.Id = 1

GO

SELECT
B.[Name] AS BookName,
CONCAT_WS(' ',R.FirstName,R.LastName) AS ReaderName,
CONCAT_WS(' ',E.FirstName,E.LastName) AS EmployeeName,
P.[Name] AS EmployeePosition,
G.[Name] AS BookGenre,
CONCAT_WS(' ',A.FirstName,A.LastName) AS AuthorName
FROM Browings AS BR
JOIN Employees AS E ON E.Id = BR.EmployeeId
JOIN Books AS B ON B.Id = BR.BookId
JOIN Readers AS R ON R.Id = BR.ReaderId
JOIN Positions AS P ON P.Id = E.PositionId
JOIN Genres AS G ON G.Id = B.GenreId
JOIN Authors AS A ON A.Id = B.AuthorId

GO

SELECT
B.[Name],BR.DateOfTaking
FROM Books AS B
JOIN Browings AS BR ON BR.BookId = B.Id
WHERE BR.IsReturned = 0
ORDER BY BR.DateOfTaking