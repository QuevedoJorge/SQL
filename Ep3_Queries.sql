/*
==========================================(1)===================================================
En la Base de datos Northwind mostrar el monto total de cada pedido. (incluidos los descuentos).
Presentar: El número de pedido, el monto bruto, el monto de descuento, 
y el monto total del pedido. 
Solo para los productos de dos categorías ingresadas por el usuario y 
además, solo para los totales comprendidos entre dos montos ingresados por el usuario
================================================================================================
*/
USE Northwind
GO

SELECT 
	O.OrderID AS [Número de Pedido], 
	ROUND(SUM(OD.UnitPrice * OD.Quantity), 2) AS [Monto Bruto], 
	ROUND(SUM((OD.UnitPrice * OD.Quantity) * OD.Discount), 2) AS [Monto de Descuento], 
	ROUND(SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount)), 2) AS [Monto Total]
FROM Orders O

INNER JOIN [Order Details] OD	ON OD.OrderID	= O.OrderID
INNER JOIN Products P			ON P.ProductID	= OD.ProductID
INNER JOIN Categories C			ON C.CategoryID	= P.CategoryID

WHERE C.CategoryName IN ('Beverages', 'Condiments')
GROUP BY O.OrderID
HAVING ROUND(SUM(OD.UnitPrice * OD.Quantity - (1 - OD.Discount)), 2) BETWEEN 1000 AND 2000

EXEC sp_help Categories

GO
CREATE PROCEDURE ep3_procedure01
	@categoryName1 VARCHAR(30),
	@categoryName2 VARCHAR(30),
	@montoMin money,
	@montoMax money
AS
SELECT 
	O.OrderID AS [Número de Pedido], 
	ROUND(SUM(OD.UnitPrice * OD.Quantity), 2) AS [Monto Bruto], 
	ROUND(SUM((OD.UnitPrice * OD.Quantity) * OD.Discount), 2) AS [Monto de Descuento], 
	ROUND(SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount)), 2) AS [Monto Total]
FROM Orders O

INNER JOIN [Order Details] OD	ON OD.OrderID	= O.OrderID
INNER JOIN Products P			ON P.ProductID	= OD.ProductID
INNER JOIN Categories C			ON C.CategoryID	= P.CategoryID

WHERE C.CategoryName IN (@categoryName1, @categoryName2)
GROUP BY O.OrderID
HAVING ROUND(SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount)), 2) BETWEEN @montoMin AND @montoMax
GO

EXEC ep3_procedure01 'Beverages', 'Condiments', 0, 10000
DROP PROCEDURE ep3_procedure01
/*
==========================================(2)===================================================
En Northwind crear un Procedimiento Almacenado que permita ingresar un nuevo Cliente.
Se deben considerar los campos obligatorios y además el País.
Si no se ingresara el País en forma predeterminada será Argentina.
================================================================================================
*/

USE Northwind
GO

SP_HELP Customers

GO
CREATE PROCEDURE ep3_agregarCliente
	-- Campos obligatorios
	@customerId NVARCHAR(10),
    @postalCode NVARCHAR(20),
    @city NVARCHAR(30),
	@companyName NVARCHAR(80),
    @region NVARCHAR(30),
	-- Campos NO obligatorios
	@contactName NVARCHAR(60) = NULL,
	@contactTitle NVARCHAR(60) = NULL,
	@address NVARCHAR(120) = NULL,
	@phone NVARCHAR(48) = NULL,
	@fax NVARCHAR(48) = NULL,
    @country NVARCHAR(30) = 'Argentina'
AS
GO


/*
==========================================(3)===================================================
Crear Procedimiento Almacenado que presente una lista 
en Northwind que presente el monto total 
de ventas correspondientes
a cada Región por cada empleado.
Se debe mostrar el nombre de la región, 
los Apellidos y nombres del empleado y 
el monto total de las ventas que realizo en cada región.
================================================================================================
*/
USE Northwind
GO

GO
CREATE PROCEDURE ep3_procedure03

AS

SELECT 
	R.RegionDescription												AS [Región], 
	E.LastName + ', ' + E.FirstName									AS [Apellidos y Nombres], 
	ROUND(SUM(OD.UnitPrice * OD.Quantity), 2)						AS [Monto Bruto], 
	ROUND(SUM((OD.UnitPrice * OD.Quantity) * OD.Discount), 2)		AS [Monto de Descuento], 
	ROUND(SUM(OD.UnitPrice * OD.Quantity * (1 - OD.Discount)), 2)	AS [Monto Total]
FROM Region R

INNER JOIN Territories T			ON T.RegionID = R.RegionID
INNER JOIN EmployeeTerritories ET	ON ET.TerritoryID = T.TerritoryID
INNER JOIN Employees E				ON E.EmployeeID = ET.EmployeeID
INNER JOIN Orders O					ON O.EmployeeID = E.EmployeeID
INNER JOIN [Order Details] OD		ON OD.OrderID = O.OrderID

GROUP BY R.RegionDescription, E.LastName + ', ' + E.FirstName
GO

-- TEST
EXEC ep3_procedure03

/*
==========================================(4)===================================================
En la Base de datos Northwind, crear un Procedimiento Almacenado que muestre 
a todos los clientes de Sudamérica, cuyo Nombre de la empresa 
termine en una letra que se debe ingresar como dato de entrada   
Presentar el nombre de la empresa cliente, el país de procedencia.
================================================================================================
*/

USE Northwind
GO

SELECT * FROM Customers C
WHERE 
	C.CompanyName LIKE '%' + 'A' 
	AND 
	C.Country IN ('Brazil', 'Venezuela', 'Argentina')

GO

SP_HELP Customers

GO
CREATE PROCEDURE ep3_procedure04
	@lastLetter CHAR(1)
AS

SELECT 
	CompanyName AS [Nombre de la Empresa], 
	ContactName AS [Cliente], 
	Country AS [País]
FROM Customers C
WHERE 
	C.CompanyName LIKE '%' + @lastLetter 
	AND 
	C.Country IN ('Brazil', 'Venezuela', 'Argentina')
GO

-- TEST
EXEC ep3_procedure04 'a'

/*
==========================================(5)===================================================
En Northwind crear un Procedimiento Almacenado que verifique 
si el stock de un producto está por debajo de 
una cantidad determinada, 
para saber si se puede vender a no el producto.  
Usar un RETURN Value.
================================================================================================
*/
USE Northwind
GO

SP_HELP Products

GO
CREATE PROCEDURE ep3_procedure05
	@product NVARCHAR(80),
	@stock SMALLINT
AS
IF (SELECT UnitsInStock FROM Products WHERE ProductName = @product) > @stock
	BEGIN
		PRINT 'Se puede vender el producto'
		RETURN 0
	END
ELSE
	BEGIN
		PRINT 'No se puede vender el producto'
		RETURN 1
	END
GO

DECLARE @test INT
EXEC @test = ep3_procedure05  'Chai', 33
PRINT @test

/*
==========================================(6)===================================================
Crear un Procedimiento Almacenado en Northwind, que al entregarle el código 
de un producto, devuelva el nombre del producto y 
el nombre del Proveedor y el total de unidades vendidas del producto 
================================================================================================
*/
USE Northwind
GO

SELECT 
	P.ProductName		AS [Nombre del Producto], 
	S.CompanyName		AS [Nombre del Proveedor],
	S.ContactName		AS [Nombre de Contacto],
	SUM(OD.Quantity)	AS [Total de Unidades Vendidas] 
FROM [Order Details] OD

INNER JOIN Products P	ON P.ProductID	= OD.ProductID
INNER JOIN Suppliers S	ON S.SupplierID	= P.SupplierID

WHERE P.ProductID = 2
GROUP BY P.ProductName, S.CompanyName, S.ContactName

GO

SP_HELP Products

GO
CREATE PROCEDURE ep3_procedure06
	@productId int
AS

SELECT 
	P.ProductName		AS [Nombre del Producto], 
	S.CompanyName		AS [Nombre del Proveedor],
	S.ContactName		AS [Nombre de Contacto],
	SUM(OD.Quantity)	AS [Total de Unidades Vendidas] 
FROM [Order Details] OD

INNER JOIN Products P	ON P.ProductID	= OD.ProductID
INNER JOIN Suppliers S	ON S.SupplierID = P.SupplierID

WHERE P.ProductID = @productId
GROUP BY P.ProductName, S.CompanyName, S.ContactName
GO

EXEC ep3_procedure06 5