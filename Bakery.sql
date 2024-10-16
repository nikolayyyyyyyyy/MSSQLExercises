CREATE DATABASE Bakery

USE Bakery

CREATE TABLE Countries(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Customers(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(25) NOT NULL,
LastName NVARCHAR(25) NOT NULL,
Gender CHAR(1) NOT NULL
CONSTRAINT CK_GENDER CHECK (Gender in ('M','F')),
Age INT NOT NULL,
PhoneNumber VARCHAR(10),
CONSTRAINT CK_PhoneNumber CHECK (LEN(PhoneNumber) = 10),
CountryId INT FOREIGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Products(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(25) UNIQUE NOT NULL,
[Description] NVARCHAR(250) NOT NULL,
Recipe VARCHAR(MAX) NOT NULL,
Price DECIMAL(18,2) NOT NULL,
CONSTRAINT CK_Price CHECK (Price > 0)
)

CREATE TABLE FeedBacks(
Id INT PRIMARY KEY IDENTITY,
[Description] NVARCHAR(255) NOT NULL,
Rate DECIMAL(2,1) NOT NULL,
CONSTRAINT CK_Rate CHECK (Rate between 0 AND 10),
ProductId INT FOREIGN KEY REFERENCES Products(Id),
CustomerId INT FOREIGN KEY REFERENCES Customers(Id)
)

CREATE TABLE Distributors(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(25) UNIQUE NOT NULL,
AddressText NVARCHAR(30) NOT NULL,
Summary NVARCHAR(200) NOT NULL,
CountryId INT FOREIGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Ingredients(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50),
[Description] NVARCHAR(200) NOT NULL,
OriginCountryId INT FOREIGN KEY REFERENCES Countries(Id),
DistributorId INT FOREIGN KEY REFERENCES Distributors(Id)
)

CREATE TABLE ProductsIngredients(
ProductId INT FOREIGN KEY REFERENCES Products(Id) NOT NULL,
IngredientId INT FOREIGN KEY REFERENCES Ingredients(Id) NOT NULL
PRIMARY KEY(ProductId,IngredientId)
)

INSERT INTO Distributors([Name],CountryId,AddressText,Summary)
Values
('Deloitte & Touche',2,'6 Arch St #9757','Customizable neutral traveling'),
('Congress Title',13,'58 Hancock St','Customer loyalty'),
('Kitchen People',1,'3 E 31st St #77','Triple-buffered stable delivery'),
('General Color Co Inc',21,'6185 Bohn St #72','Focus group'),
('Beck Corporation',23,'21 E 64th Ave','Quality-focused 4th generation hardware')

INSERT INTO Customers(FirstName,LastName,Age,Gender,PhoneNumber,CountryId)
VALUES
('Francoise','Rautenstrauch',15,'M','0195698399',5),
('Kendra','Loud',22,'F','0006365484',11),
('Lourdes','Bauswell',50,'M','0139037043',8),
('Hannah','Edmison',18,'F','0043343686',1),
('Tom','Loeza',31,'M','0144876096',23),
('Queenie','Kramarczyk',30,'F','0064215793',29),
('Hiu','Portaro',25,'M','0068277755',16),
('Josefa','Opitz',43,'F','0197887645',17)

GO

BEGIN TRANSACTION

	UPDATE I
	SET DistributorId = 35
FROM Ingredients AS I
WHERE I.[Name] IN ('Bay Leaf','Paprika','Poppy')

UPDATE I
	SET I.OriginCountryId = 14
FROM Ingredients AS I
WHERE I.OriginCountryId = 8

ROLLBACK
COMMIT

GO

BEGIN TRANSACTION

DELETE FROM FeedBacks
WHERE CustomerId = 14 OR ProductId = 5

COMMIT 
ROLLBACK

GO

SELECT
P.[Name],
P.Price,
P.[Description]
FROM Products AS P
ORDER BY P.Price DESC, P.[Name]

GO

SELECT
F.ProductId,
F.Rate,
F.[Description],
F.CustomerId,
C.Age,
C.Gender
FROM FeedBacks AS F
JOIN Customers AS C ON C.Id = F.CustomerId
WHERE F.Rate < 5
ORDER BY F.ProductId DESC,F.Rate

GO

SELECT
	CONCAT_WS(' ',C.FirstName,C.LastName) AS CustomersName,
	C.PhoneNumber,
	C.Gender
FROM FeedBacks AS F
RIGHT JOIN Customers AS C ON C.Id = F.CustomerId
WHERE F.Id IS NULL
ORDER BY C.Id

GO

SELECT
C.FirstName,
C.Age,
C.PhoneNumber
FROM Customers AS C
JOIN Countries AS CN ON CN.Id = C.CountryId
WHERE C.Age >= 21 AND C.FirstName LIKE '%an%'
OR
C.PhoneNumber LIKE '%38' AND CN.[Name] != 'Greece'
ORDER BY C.FirstName,C.Age DESC

GO

SELECT
D.[Name] AS DistributorName,
I.[Name] AS IngredientName,
P.[Name] AS ProductName,
AVG(F.Rate) AS AverageRate
FROM Ingredients AS I
JOIN ProductsIngredients AS PR ON PR.IngredientId = I.Id
JOIN Products AS P ON P.Id = PR.ProductId
JOIN Distributors AS D ON D.Id = I.DistributorId
JOIN FeedBacks AS F ON F.ProductId = P.Id
GROUP BY D.[Name],I.[Name],P.[Name]
HAVING AVG(F.Rate) BETWEEN 5 AND 8
ORDER BY D.[Name],I.[Name],P.[Name]

GO

WITH DistributorCounts AS (
    SELECT
        C.[Name] AS CountryName,
        D.[Name] AS DistributorName,
        COUNT(I.Id) AS IngredientCount
    FROM Countries AS C
    JOIN Distributors AS D ON D.CountryId = C.Id
    JOIN Ingredients AS I ON I.DistributorId = D.Id
    GROUP BY C.[Name], D.[Name]
),
RankedDistributors AS (
    SELECT
        CountryName,
        DistributorName,
        IngredientCount,
        DENSE_RANK() OVER (PARTITION BY CountryName ORDER BY IngredientCount DESC) AS Rank
    FROM DistributorCounts
)
SELECT
    CountryName,
    DistributorName,
    IngredientCount
FROM RankedDistributors
WHERE Rank = 1
ORDER BY CountryName, DistributorName;

GO

CREATE VIEW v_UserWithCountries AS
	SELECT 
	CONCAT_WS(' ',C.FirstName,C.LastName) AS CustomerName,
	C.Age,
	C.Gender,
	CN.[Name]
	FROM Customers AS C
	JOIN Countries AS CN ON CN.Id = C.CountryId

GO
CREATE TRIGGER trg_DeleteProductRelatio
ON Products
AFTER DELETE
AS
BEGIN
	ALTER TABLE FeedBacks
	nocheck constraint all
	ALTER TABLE ProductsIngredients
	nocheck constraint all
	ALTER TABLE Products
	nocheck constraint all

	DELETE FROM Products
	WHERE Id IN (SELECT Id FROM deleted);
END

DELETE FROM Products WHERE Id = 1
