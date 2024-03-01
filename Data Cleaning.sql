 /*
 Cleaning Data in SQL Queries
 */

 select *
 from PFP..NashvilleHousing

 ---------------------------------------------------------------------------------------------------------
 -- Standardize Date Format

 select SaleDateConverted, CONVERT(Date, SaleDate)
 from PFP..NashvilleHousing

 update NashvilleHousing
 set SaleDate = CONVERT(Date, SaleDate)

 Alter table NashvilleHousing
 add SaleDateConverted date;

  update NashvilleHousing
 set SaleDateConverted = CONVERT(Date, SaleDate)

 -----------------------------------------------------------------------------------------------------------
 -- Populate Property Address Data

 select *
 from PFP..NashvilleHousing
-- where PropertyAddress is null
order by ParcelID

 select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 from PFP..NashvilleHousing a
 join PFP..NashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null

 update a 
 set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
  from PFP..NashvilleHousing a
 join PFP..NashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null

 ------------------------------------------------------------------------------------------------------------------
 -- Breaking out Address into Individual Columns (Address, City, State)

 select PropertyAddress
 from PFP..NashvilleHousing
-- where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(Propertyaddress , 1, charindex(',', PropertyAddress, -1)) as Address
, SUBSTRING(Propertyaddress, charindex(',', PropertyAddress) + 1 , LEN(propertyaddress)) as Address
 from PFP..NashvilleHousing

 Alter table NashvilleHousing
 add PropertySplitAddres Nvarchar(255);

 update NashvilleHousing
 set PropertySplitAddres = SUBSTRING(Propertyaddress , 1, charindex(',', PropertyAddress, -1))

 Alter table NashvilleHousing
 add PropertySplitCity Nvarchar(255);

 update NashvilleHousing
 set PropertySplitCity = SUBSTRING(Propertyaddress, charindex(',', PropertyAddress) + 1 , LEN(propertyaddress))

 select * 
 from PFP..NashvilleHousing

 select OwnerAddress
 from PFP..NashvilleHousing

 select 
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
 , PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
 , PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
 from PFP..NashvilleHousing

 Alter table NashvilleHousing
 add OwnerSplitAddres Nvarchar(255);

 update NashvilleHousing
 set OwnerSplitAddres = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

 Alter table NashvilleHousing
 add OwnerSplitCity Nvarchar(255);

 update NashvilleHousing
 set OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

 Alter table NashvilleHousing
 add OwnerSplitState Nvarchar(255);

 update NashvilleHousing
 set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

 select *
 from PFP..NashvilleHousing

 -----------------------------------------------------------------------------------------------
 -- Change Y and N to Yes and No in "sold as Vacant" Field

 select distinct(soldasvacant), count(soldasvacant)
 from PFP..NashvilleHousing
 group by SoldAsVacant
 order by 2


 select soldasvacant
 , case when SoldAsVacant = 'Y' then 'Yes'
        when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
 from PFP..NashvilleHousing

 update NashvilleHousing
 set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
        when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

------------------------------------------------------------------------------------------------------

-- Remove Duplicates 
with RownumCTE as(
Select *,
	ROW_NUMBER() over(
	partition by Parcelid, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate, 
				 LegalReference
				 order by uniqueID
				 ) row_num
from PFP..NashvilleHousing
-- order by ParcelID
)

select * 
from RownumCTE
where row_num >1 
Order by PropertyAddress

---------------------------------------------------------------------------------------------

-- Delete Unused columns

select * 
from PFP..NashvilleHousing

alter table PFP..NashvilleHousing
drop column owneraddress, taxdistrict, propertyAddress

alter table PFP..NashvilleHousing
drop column saledate

