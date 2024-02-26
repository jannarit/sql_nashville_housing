-- Create Table 

USE nashville;
DROP TABLE IF EXISTS nashville_housing;

CREATE TABLE nashville_housing (
    UniqueID INT NOT NULL PRIMARY KEY,
    ParcelID VARCHAR(20) NOT NULL,
    LandUse VARCHAR(50) NOT NULL,
    PropertyAddress VARCHAR(100) NULL,
    SaleDate DATETIME NOT NULL,
    SalePrice INT NOT NULL,
    LegalReference VARCHAR(50) NOT NULL,
    SoldAsVacant VARCHAR(10) NOT NULL,
    OwnerName VARCHAR(100) NULL,
    OwnerAddress VARCHAR(100) NULL,
    Acreage DECIMAL(10,2) NULL,
    TaxDistrict VARCHAR(50) NULL,
    LandValue INT NULL,
    BuildingValue INT NULL,
    TotalValue INT NULL,
    YearBuilt INT NULL,
    Bedrooms INT NULL,
    FullBath INT NULL,
    HalfBath INT NULL
);

SELECT * 
FROM nashville_housing;
-- WHERE ParcelID = '034 16 0A 004.00';

------------------------------------------------------
-- change Datatype for column SaleDate to DATE Format

ALTER TABLE nashville_housing
MODIFY SaleDate DATE NULL;

------------------------------------------------------

-- Populate PropertyAddress data 
-- 29 Rows NULL in PropertyAddress

SELECT *
FROM nashville_housing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL (a.PropertyAddress, b.PropertyAddress) AS Updated_PropertyAddress
FROM nashville.nashville_housing a
JOIN nashville.nashville_housing b
	on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

SET SQL_SAFE_UPDATES = 0;

UPDATE nashville_housing a
JOIN nashville_housing b
	on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE (a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

SET SQL_SAFE_UPDATES = 1;

----------------------------------------------------

-- Breaking out PropertyAddress into individual columns (Address, City)

ALTER TABLE nashville_housing
ADD COLUMN PropertyStreet VARCHAR(255),
ADD COLUMN PropertyCity VARCHAR(255);

SET SQL_SAFE_UPDATES = 0;

UPDATE nashville_housing
SET 
	PropertyStreet = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', 1 )),
    PropertyCity = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1 ));

SET SQL_SAFE_UPDATES = 1;

------------------------------------------------------

-- Breaking out OwnerAddress into individual columns (Address, City, State)

SELECT * FROM nashville_housing;

ALTER TABLE nashville_housing
ADD COLUMN OwnerStreet VARCHAR(255),
ADD COLUMN OwnerCity VARCHAR(255),
ADD COLUMN OwnerState VARCHAR(255);

SET SQL_SAFE_UPDATES = 0;

UPDATE nashville_housing
SET
    OwnerStreet = SUBSTRING_INDEX(OwnerAddress, ',', 1),
	OwnerCity = SUBSTRING_INDEX(SUBSTRING(OwnerAddress, INSTR(OwnerAddress, ',') + 2), ',', 1),
    OwnerState = SUBSTRING_INDEX(SUBSTRING(OwnerAddress, INSTR(OwnerAddress, ',') + INSTR(SUBSTRING(OwnerAddress, INSTR(OwnerAddress, ',') + 2), ',') + 3), ',', -1);

SET SQL_SAFE_UPDATES = 1;

------------------------------------------------------

-- Change Y and N to Yes and No in "SoldAsVacant" field

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2;

SET SQL_SAFE_UPDATES = 0;

UPDATE nashville_housing
SET SoldAsVacant = CASE
                      WHEN SoldAsVacant = 'N' THEN 'No'
                      WHEN SoldAsVacant = 'Y' THEN 'Yes'
                      ELSE SoldAsVacant
                   END;

SET SQL_SAFE_UPDATES = 1;

------------------------------------------------------

-- Remove Duplicates

SELECT t1.*
FROM nashville_housing t1
INNER JOIN nashville_housing t2
    ON t1.ParcelID = t2.ParcelID
    AND t1.PropertyAddress = t2.PropertyAddress
    AND t1.SalePrice = t2.SalePrice
    AND t1.SaleDate = t2.SaleDate
    AND t1.LegalReference = t2.LegalReference
    AND t1.UniqueID > t2.UniqueID;
    
    
------------------------------------------------------

-- Delete unused Columns

SELECT * FROM nashville_housing;

ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress,
DROP COLUMN PropertyAddress;