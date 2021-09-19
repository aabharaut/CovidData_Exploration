/*
Data set cleaning using SQL with SQL queries

*/

select * 
from Portfolioproject.dbo.NashvilleHousing

select SaleDate
from Portfolioproject.dbo.NashvilleHousing  --date format as datetime

--Change date format or standardize it
select SaleDate, CONVERT(Date,SaleDate) as DateColumn
from Portfolioproject.dbo.NashvilleHousing

update NashvilleHousing 
set SaleDate=CONVERT(Date,SaleDate)  --not updating the column

Alter table NashvilleHousing
Add SaleDateConverted Date

update NashvilleHousing 
set SaleDateConverted=CONVERT(Date,SaleDate)

select SaleDateConverted
from Portfolioproject.dbo.NashvilleHousing  --worked with alter

--Populate the missing/Null Address 

select PropertyAddress
from Portfolioproject.dbo.NashvilleHousing
--where LandUse like '%VACANT%'

select *
from Portfolioproject.dbo.NashvilleHousing
where PropertyAddress is null   -- checked why its null and resp. values

select *
from Portfolioproject.dbo.NashvilleHousing
order by ParcelID   -- observed many times same parcelID has same address

--here two same parcel ID has same address, we can populate this is future
-- Populate the null address using parcel ID and Unique ID as matching criteria

select N1.ParcelID,N1.PropertyAddress,N2.ParcelID,N2.PropertyAddress, isnull(N1.PropertyAddress,N2.PropertyAddress)
from Portfolioproject.dbo.NashvilleHousing N1
join Portfolioproject.dbo.NashvilleHousing N2
on N1.ParcelID=N2.ParcelID and N1.[UniqueID ] <> N2.[UniqueID ]
where N1.PropertyAddress is null
-- using self join on parcel id, address will be populated for null property address

update N1   --use alias with Update while performing join
set PropertyAddress= isnull(N1.PropertyAddress,N2.PropertyAddress)
from Portfolioproject.dbo.NashvilleHousing N1
join Portfolioproject.dbo.NashvilleHousing N2
on N1.ParcelID=N2.ParcelID and N1.[UniqueID ] <> N2.[UniqueID ]
where N1.PropertyAddress is null

--update N1   --use alias with Update while performing join
--set PropertyAddress= isnull(N1.PropertyAddress,'No address')
--from Portfolioproject.dbo.NashvilleHousing N1
--join Portfolioproject.dbo.NashvilleHousing N2
--on N1.ParcelID=N2.ParcelID and N1.[UniqueID ] <> N2.[UniqueID ]
--where N1.PropertyAddress is null 

select *
from Portfolioproject.dbo.NashvilleHousing
where PropertyAddress is not null

--Address, number, street, city (separate)

select PropertyAddress
from Portfolioproject.dbo.NashvilleHousing

select PropertyAddress,
CHARINDEX(' ',PropertyAddress) as New  --search for given character and provide its position
from Portfolioproject.dbo.NashvilleHousing

select 
substring(PropertyAddress,1, Charindex(',',PropertyAddress)-1) as Address,
substring(PropertyAddress, Charindex(',',PropertyAddress) + 1, LEN(PropertyAddress)) as PropertyCity
from Portfolioproject.dbo.NashvilleHousing

--Add separated address and city into the table

Alter table NashvilleHousing
Add Address nvarchar(255)

update NashvilleHousing 
set Address=substring(PropertyAddress,1, Charindex(',',PropertyAddress)-1)

Alter table NashvilleHousing
Add Propertycity nvarchar(255)

update NashvilleHousing 
set PropertyCity=substring(PropertyAddress, Charindex(',',PropertyAddress) + 1, LEN(PropertyAddress))

select *
from Portfolioproject.dbo.NashvilleHousing  -- new columns at the end

--Owner address split using parsename
select OwnerAddress
from Portfolioproject.dbo.NashvilleHousing 

--it works backward and with period (.)
select 
PARSENAME(replace(OwnerAddress,',','.'),1) as OwnersplitState, -- first from backward
PARSENAME(replace(OwnerAddress,',','.'),2) as OwnersplitCity,
PARSENAME(replace(OwnerAddress,',','.'),3) as OwnersplitAddress
from Portfolioproject.dbo.NashvilleHousing 
--where OwnerAddress is not null

Alter table NashvilleHousing
Add OwnersplitState nvarchar(255)

update NashvilleHousing 
set OwnersplitState=PARSENAME(replace(OwnerAddress,',','.'),1)

Alter table NashvilleHousing
Add OwnersplitCity nvarchar(255)

update NashvilleHousing 
set OwnersplitCity=PARSENAME(replace(OwnerAddress,',','.'),2)

Alter table NashvilleHousing
Add OwnersplitAddress nvarchar(255)

update NashvilleHousing 
set OwnersplitAddress=PARSENAME(replace(OwnerAddress,',','.'),3)

select *
from Portfolioproject.dbo.NashvilleHousing


--Changing fiels from Y and N to Yes and No

select Distinct(SoldAsVacant), count(SoldAsVacant)
from Portfolioproject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

--using case statements
select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end
from Portfolioproject.dbo.NashvilleHousing
--where SoldAsVacant='Y'

update NashvilleHousing
set SoldAsVacant= case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end


---Remove Duplicates using rownumber (can be also done using rank)
--https://www.sqlshack.com/sql-partition-by-clause-overview/ 
-- Rownumber() over (partition by ) order by 

with RowNumCTE as(
select *,
	ROW_NUMBER() 
	over(partition by 
	ParcelID,
	PropertyAddress, 
	SalePrice,SaleDate, 
	LegalReference order by UniqueID) as row_num  --logic is to find rows with same unique id and if row count is more than 1 then 
	--its duplicate and to eliminate those use CTE
from Portfolioproject.dbo.NashvilleHousing
)
select * from RowNumCTE
where row_num>1

--delete duplicate with CTE
with RowNumCTE as(
select *,
	ROW_NUMBER() 
	over(partition by 
	ParcelID,
	PropertyAddress, 
	SalePrice,SaleDate, 
	LegalReference order by UniqueID) as row_num  --logic is to find rows with same unique id and if row count is more than 1 then 
	--its duplicate and to eliminate those use CTE
from Portfolioproject.dbo.NashvilleHousing
)
delete from RowNumCTE
where row_num>1


--Delete unused columns
select *
from Portfolioproject.dbo.NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, Saledate


--rank function returns a unique rank for distinct row within the partition
--select *, rank() over(order by UniqueID) as Rank_num
--from Portfolioproject.dbo.NashvilleHousing


--row_number gives continuous numbers, while rank and dense_rank give the same rank for duplicates, 
--but the next number in rank is as per continuous order so you will see a jump but in dense_rank doesn't have any gap in rankings.