/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM PortfolioProject1.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)


--------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM PortfolioProject1.dbo.NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelId


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject1.dbo.NashvilleHousing a 
JOIN PortfolioProject1.dbo.NashvilleHousing b
    On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject1.dbo.NashvilleHousing a 
JOIN PortfolioProject1.dbo.NashvilleHousing b
    On a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject1.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--order by ParcelId

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
FROM PortfolioProject1.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


SELECT OwnerAddress
FROM PortfolioProject1.dbo.NashvilleHousing


SELECT 
PARSENAME (REPLACE(OwnerAddress, ',', ' .') , 3)
,PARSENAME (REPLACE(OwnerAddress, ',', ' .') , 2)
,PARSENAME (REPLACE(OwnerAddress, ',', ' .') , 1)
FROM PortfolioProject1.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', ' .') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', ' .') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', ' .') , 1)


------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject1.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
,CASE When SoldAsVacant = 'Y' then 'Yes'
      WHEN SoldAsVacant = 'N' then 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProject1.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
      WHEN SoldAsVacant = 'N' then 'No'
	  ELSE SoldAsVacant
	  END

-----------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE AS(
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePRice,
				SaleDate,
				LegalReference
				ORDER BY
				  UniqueID
				  ) row_num
FROM PortfolioProject1.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * 
FROM PortfolioProject1.dbo.Nashvillehousing

ALTER TABLE PortfolioProject1.dbo.Nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject1.dbo.Nashvillehousing
DROP COLUMN OwnerAddressSplitAddress




