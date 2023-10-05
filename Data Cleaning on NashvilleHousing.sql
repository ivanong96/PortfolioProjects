/*

Cleaning Data in SQL Queries

*/

Select * 
From PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------
-- Standardize Data Format

Select SaleDate
From PortfolioProject..NashvilleHousing

-- Not Working
update PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

-- Alter the table to update the value
ALTER TABLE PortfolioProject..NashvilleHousing
ALTER COLUMN SaleDate DATE;


---------------------------------------------------------------------------
-- Populate Property Address data

Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
Where a.[UniqueID ] != b.[UniqueID ]
and a.PropertyAddress is null

--if a.PropertyAddress is null, replace with value in b.PropertyAddress
update a
Set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
Where a.[UniqueID ] != b.[UniqueID ]
and a.PropertyAddress is null


---------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing

-- Using SubString and CharIndex on PropertyAddress

Select
SubString(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SubString(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add PropertyAddressEx nvarchar(255),
	PropertyStateEx	nvarchar(255)

update PortfolioProject..NashvilleHousing
Set PropertyAddressEx = SubString(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 
,   PropertyStateEx = SubString(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))


-- Using ParseName(delimited by specific value) on OwnerAddress

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3 ) as OwnerSplitAddress
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2 ) as OwnerSplitCity
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1 ) as OwnerSplitState
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress nvarchar(255)
,	OwnerSplitCity nvarchar(255)
,	OwnerSplitState nvarchar(255)

update PortfolioProject..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3 )
,	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2 )
,	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1 )


---------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
 
 Select SoldAsVacant, COUNT(SoldAsVacant)
 From PortfolioProject..NashvilleHousing
 group by SoldAsVacant
 order by 2

Select SoldAsVacant,
CASE
	When SoldAsVacant = 'N' Then 'No'
	When SoldAsVacant = 'Y' Then 'Yes'
	Else SoldAsVacant
END
From PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
Set SoldAsVacant =
CASE
	When SoldAsVacant = 'N' Then 'No'
	When SoldAsVacant = 'Y' Then 'Yes'
	Else SoldAsVacant
END


---------------------------------------------------------------------------
-- Remove Duplicate

-- Using CTE

WITH CTE_RowNum as(
	Select *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID, 
		PropertyAddress, 
		LegalReference,
		SaleDate,
		SalePrice
	Order By
		UniqueID
	) row_num
From PortfolioProject..NashvilleHousing
)

Select *
From CTE_RowNum
Where row_num =1
Order by PropertyAddress


---------------------------------------------------------------------------
-- Delete Unused Columns

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress

