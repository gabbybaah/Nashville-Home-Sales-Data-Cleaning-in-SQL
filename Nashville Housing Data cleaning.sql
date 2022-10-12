/*
Cleaning Housing Data in SQL
*/

select *
from Housing.dbo.Housing


--- Date Conversions
select SaleDate, CONVERT(Date, SaleDate)
from Housing.dbo.Housing

Alter Table Housing.dbo.Housing
Add SaleDate_New Date;

Update Housing.dbo.Housing
SET SaleDate_New = CONVERT(Date, SaleDate)


---Populate Property Address Data

select *
from Housing.dbo.Housing
order by ParcelID

select a.parcelID, 
	a.PropertyAddress, 
	b.ParcelID, 
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
from Housing.dbo.Housing a
join Housing.dbo.Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null


Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Housing.dbo.Housing a
join Housing.dbo.Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null


--- Breaking Address into Separate columns (Address, City, State)
select PropertyAddress
from Housing.dbo.Housing

select 
---column name, starting_point, ','=delimiter in column, -1 = minus delimiter)
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
from Housing.dbo.Housing

Alter Table Housing.dbo.Housing
Add Property_Address Nvarchar(255);
Alter Table Housing.dbo.Housing
Add Property_City Nvarchar(255);

Update Housing.dbo.Housing
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
Update Housing.dbo.Housing
SET Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


select OwnerAddress
from Housing.dbo.Housing

select 
---column name, change delimiter to '.' if ',' 3=first position, 2=second, 1 = from back)
	PARSENAME(replace(OwnerAddress,',','.'),3) as OwnerAddress,
	PARSENAME(replace(OwnerAddress,',','.'),2) as OwnerCity,
	PARSENAME(replace(OwnerAddress,',','.'),1) as OwnerSate
from Housing.dbo.Housing


Alter Table Housing.dbo.Housing
Add Owner_Address Nvarchar(255);
Alter Table Housing.dbo.Housing
Add Owner_City Nvarchar(255);
Alter Table Housing.dbo.Housing
Add Owner_Sate Nvarchar(255);


Update Housing.dbo.Housing
SET Owner_Address = PARSENAME(replace(OwnerAddress,',','.'),3)
Update Housing.dbo.Housing
SET Owner_City = PARSENAME(replace(OwnerAddress,',','.'),2)
Update Housing.dbo.Housing
SET Owner_Sate = PARSENAME(replace(OwnerAddress,',','.'),1)

select *
from Housing.dbo.Housing


--- Change Y and N to Yes and No in the "SoldAsVacant" field

Select Distinct(SoldAsVacant)
from Housing.dbo.Housing

select Distinct(SoldAsVacant), count(SoldAsVacant)
from Housing.dbo.Housing
group by SoldAsVacant
Order by 2

select SoldAsVacant,
	CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from Housing.dbo.Housing


Update Housing.dbo.Housing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


--- Cleaning the Duplicates
---Finding the duplicates
With RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
from Housing.dbo.Housing
--order by ParcelID
)
select *
from RowNumCTE
where row_num >1
order by PropertyAddress

---Removing the duplicates
With RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
from Housing.dbo.Housing
--order by ParcelID
)
DELETE
from RowNumCTE
where row_num >1


--- Removing Unused Columns

Select *
from Housing.dbo.Housing

Alter table Housing.dbo.Housing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

