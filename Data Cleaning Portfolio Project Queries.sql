/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------

-- Standardize Data Format

Select SalesDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SalesDateConverted Date

Update NashvilleHousing
SET SalesDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
-- where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



Update a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1,CHARINDEX (',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX (',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.NashvilleHousing



Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
From PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2


Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant ='N' then 'No'
		else SoldAsVacant
		End
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant =Case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant ='N' then 'No'
		else SoldAsVacant
		End



--------------------------------------------------------------------------------------------------

-- Remove Duplicates



With RowNumCTE as (
Select *, 
	ROW_NUMBER() Over(
	Partition by ParcelID, 
				 PropertyAddress,
				 SalePrice, 
				 SaleDate, 
				 LegalReference
				 Order by 
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
-- order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1
Order By PropertyAddress

Select *
From PortfolioProject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


Alter table PortfolioProject.dbo.NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SalesDate

