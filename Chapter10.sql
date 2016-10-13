--Listing 10-1*********************************************************************
SELECT CompanyName
FROM dbo.Invoice
WHERE isPaid = 1

--Listing 10-2*********************************************************************
SELECT CompanyName
FROM dbo.Invoice
WHERE isPaid= 0

--Listing 10-3*********************************************************************
CREATE CLUSTERED INDEX ix_SalesOrderId ON apWriter.SalesOrderHeader(SalesOrderId)
CREATE CLUSTERED INDEX ix_ProductId ON apWriter.Product(ProductId)

SELECT *
FROM apWriter.SalesOrderDetail
WHERE SalesOrderId = 74853

CREATE CLUSTERED INDEX ix_SalesOrderIdDetailId ON apWriter.SalesOrderDetail(SalesOrderId,SalesOrderDetailId)

SELECT *
FROM apWriter.SalesOrderDetail
WHERE SalesOrderId = 74853

--Listing 10-4*********************************************************************
CREATE NONCLUSTERED INDEX ix_OrderDate ON apWriter.SalesOrderHeader(OrderDate)

SELECT soh.SalesOrderID,soh.SubTotal, soh.TaxAmt, soh.TotalDue
FROM apWriter.SalesOrderHeader soh
WHERE soh.OrderDate > '2003-12-31'

SELECT OrderDate,soh.SalesOrderID,soh.SubTotal, soh.TaxAmt, soh.TotalDue
FROM AdventureWorks2008.apWriter.SalesOrderHeader soh
WHERE soh.OrderDate = '2004-01-01'

--Listing 10-5*********************************************************************
SELECT soh.SalesOrderID,soh.SubTotal, soh.TaxAmt, soh.TotalDue
FROM apWriter.SalesOrderHeader soh with(index(ix_OrderDate))
WHERE soh.OrderDate > '2003-12-31'
SELECT soh.SalesOrderID,soh.SubTotal, soh.TaxAmt, soh.TotalDue
FROM apWriter.SalesOrderHeader soh
WHERE soh.OrderDate > '2003-12-31'

--Listing 10-6*********************************************************************
CREATE NONCLUSTERED INDEX ix_OrderDatewInclude ON apWriter.SalesOrderHeader(OrderDate) INCLUDE (SubTotal, TaxAmt, TotalDue)

SELECT soh.SalesOrderID,soh.SubTotal, soh.TaxAmt, soh.TotalDue
FROM apWriter.SalesOrderHeader soh WITH (index(ix_OrderDate))
WHERE soh.OrderDate > '2003-12-31'

SELECT soh.SalesOrderID,soh.SubTotal, soh.TaxAmt, soh.TotalDue
FROM apWriter.SalesOrderHeader soh WITH(index(ix_OrderDatewInclude))
WHERE soh.OrderDate > '2003-12-31'

SELECT soh.SalesOrderID,soh.SubTotal, soh.TaxAmt, soh.TotalDue
FROM apWriter.SalesOrderHeader soh WITH(index(ix_SalesOrderId))
WHERE soh.OrderDate > '2003-12-31'

--Listing 10-7*********************************************************************
CREATE NONCLUSTERED INDEX ix_ProductId ON apWriter.SalesOrderDetail(ProductId)
CREATE NONCLUSTERED INDEX ix_ProductIdInclude ON apWriter.SalesOrderDetail(ProductId) INCLUDE (OrderQty)

SELECT sod.SalesOrderID,sod.SalesOrderDetailID,p.Name,sod.OrderQty
FROM AdventureWorks2008.apWriter.SalesOrderDetail sod
WITH (index(ix_ProductIdInclude)) JOIN AdventureWorks2008.apWriter.Product p
ON sod.ProductId = p.ProductId
WHERE p.ProductId = 843

SELECT sod.SalesOrderID,sod.SalesOrderDetailID,p.Name,sod.OrderQty
FROM apWriter.SalesOrderDetail sod with(index(ix_ProductId))
JOIN apWriter.Product p on sod.ProductId = p.ProductId
WHERE p.ProductId = 843

--Listing 10-8*********************************************************************
CREATE NONCLUSTERED INDEX ix_Territory ON apWriter.SalesOrderHeader(TerritoryID) INCLUDE (OrderDate,TotalDue)
CREATE NONCLUSTERED INDEX ix_TerritoryFiltered ON apWriter.SalesOrderHeader(TerritoryID) INCLUDE (OrderDate,TotalDue)
WHERE TerritoryID = 4
GO

SELECT SalesOrderId, OrderDate,TotalDue
FROM apWriter.SalesOrderHeader soh WITH(index(ix_Territory))
WHERE TerritoryID = 4

SELECT SalesOrderId, OrderDate,TotalDue
FROM apWriter.SalesOrderHeader soh WITH (index(ix_TerritoryFiltered))
WHERE TerritoryID = 4