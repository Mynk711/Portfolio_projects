select *
from [Nashville Housing Data for Data Cleaning]..Nashville_housing

-- Manage the dates
select SaleDate, convert(date, Saledate) as New_Date
from [Nashville Housing Data for Data Cleaning]..Nashville_housing

alter table Nashville_housing
add newsaledate date;
update Nashville_housing
set newsaledate = convert(date, SaleDate)
------------------------------------------------------------------------------------------------------------

-- Manage the property address data
select PropertyAddress
from [Nashville Housing Data for Data Cleaning]..Nashville_housing
where PropertyAddress is NULL

select  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress) as Updated_address
from [Nashville Housing Data for Data Cleaning]..Nashville_housing a
join [Nashville Housing Data for Data Cleaning]..Nashville_housing b
	on a.ParcelID = b. ParcelID
	and a.[UniqueID ]  <> b.[UniqueID ]
where a.PropertyAddress is NULL

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
from [Nashville Housing Data for Data Cleaning]..Nashville_housing a
join [Nashville Housing Data for Data Cleaning]..Nashville_housing b
	on a.ParcelID = b. ParcelID
	and a.[UniqueID ]  <> b.[UniqueID ]
where a.PropertyAddress is NULL

------------------------------------------------------------------------------------------------------------

-- Breaking the Property address in terms of state, city, address

select PropertyAddress
from [Nashville Housing Data for Data Cleaning]..Nashville_housing

select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,  len(PropertyAddress)) as City
from [Nashville Housing Data for Data Cleaning]..Nashville_housing

-- Adding the two columns in the table

alter table Nashville_housing
add PropertyAdressSplit nvarchar(255);

update Nashville_housing
set PropertyAdressSplit = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table Nashville_housing
add PropertyCity nvarchar(255);

update Nashville_housing
set PropertyCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,  len(PropertyAddress))

--Breaking the Owner address in terms of state, city, address

select OwnerAddress, parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2), parsename(replace(OwnerAddress, ',', '.'), 1)
from [Nashville Housing Data for Data Cleaning]..Nashville_housing

alter table Nashville_housing
add OwnerAddressSplit nvarchar(255);

update Nashville_housing
set OwnerAddressSplit = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table Nashville_housing
add OwnerAddressCity nvarchar(255);

update Nashville_housing
set OwnerAddressCity= parsename(replace(OwnerAddress, ',', '.'), 2)

alter table Nashville_housing
add OwnerAddressState nvarchar(255);

update Nashville_housing
set OwnerAddressState= parsename(replace(OwnerAddress, ',', '.'), 1)




------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in SoldAsVacant column

select distinct(SoldAsVacant) , count(SoldAsVacant) as total
from [Nashville Housing Data for Data Cleaning]..Nashville_housing
group by SoldAsVacant
order by total

select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 END
from [Nashville Housing Data for Data Cleaning]..Nashville_housing

update Nashville_housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						END

----------------------------------------------------------------------------------------------------------

-- Remove duplicates from the dataset

with row_num_cte 
as
(
select *, ROW_NUMBER() over ( partition by ParcelID,
										   PropertyAddress,
										   SaleDate,
										   SalePrice,
										   LegalReference
							  order by UniqueID
							  ) as row_num
from [Nashville Housing Data for Data Cleaning]..Nashville_housing
)
select *
--delete
from row_num_cte
where row_num >1

------------------------------------------------------------------------------------------------------

-- Deleting the unused columns

select *
from [Nashville Housing Data for Data Cleaning]..Nashville_housing

alter table Nashville_housing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate






