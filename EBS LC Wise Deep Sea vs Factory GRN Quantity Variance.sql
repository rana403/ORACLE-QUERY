-- EBS LC Wise Deep Sea vs Factory GRN Quantity Variance
-- PARAMETER LC_ID: 10052
SELECT
--RSL.MMT_TRANSACTION_ID,
--RSH.SHIPMENT_NUM IOT_NO,
--RSH.CREATION_DATE IOT_DATE,
(SELECT OPERATING_UNIT_NAME FROM WBI_INV_ORG_DETAIL WHERE INV_ORGANIZATION_ID=RSH.ORGANIZATION_ID) COMPANY_NAME,
RSH.ORGANIZATION_ID FROM_ORG,
(SELECT INV_ORGANIZATION_CODE||'-'||INVENTORY_ORGANIZATION_NAME FROM WBI_INV_ORG_DETAIL WHERE INV_ORGANIZATION_ID=RSH.ORGANIZATION_ID) FROM_ORG_NAME,
(SELECT INV_ORG_ADDRESS FROM WBI_INV_ORG_DETAIL WHERE INV_ORGANIZATION_ID=RSH.ORGANIZATION_ID) FROM_ORG_ADDRESS,
RSH.SHIP_TO_ORG_ID TO_ORG,
(SELECT INV_ORGANIZATION_CODE||'-'||INVENTORY_ORGANIZATION_NAME FROM WBI_INV_ORG_DETAIL WHERE INV_ORGANIZATION_ID=RSH.SHIP_TO_ORG_ID) TO_ORG_NAME,
(SELECT INV_ORG_ADDRESS FROM WBI_INV_ORG_DETAIL WHERE INV_ORGANIZATION_ID=RSH.SHIP_TO_ORG_ID) TO_ORG_ADDRESS,
RSL.LINE_NUM,
RSL.ITEM_ID,
WXMD.ITEM_CODE,
RSL.ITEM_DESCRIPTION,
SUM(RSL.QUANTITY_SHIPPED) IOT_QUANTITY,
GET_DPSEA_QTY_FROM_LC( (SELECT DISTINCT ATTRIBUTE3 FROM MTL_MATERIAL_TRANSACTIONS WHERE ATTRIBUTE_CATEGORY = 'LC Number' and ATTRIBUTE3 =NVL(:P_LC_ID,ATTRIBUTE3 ))) DEEP_SEA_QTY,
RSL.UNIT_OF_MEASURE UOM,
--RSH.RECEIPT_NUM GRN_NO,
SUM(RSL.QUANTITY_RECEIVED) RECEIVED_QTY,
DECODE(RSL.SHIPMENT_LINE_STATUS_CODE,'EXPECTED','INTRANSIT',RSL.SHIPMENT_LINE_STATUS_CODE) STATUS,
--(SELECT DISTINCT ATTRIBUTE1 FROM MTL_MATERIAL_TRANSACTIONS WHERE  TRANSACTION_ID = RSL.MMT_TRANSACTION_ID) VEHICLE_NO,
--(SELECT DISTINCT LC_NUMBER  FROM XX_LC_DETAILS WHERE LC_ID = (SELECT DISTINCT ATTRIBUTE3 FROM MTL_MATERIAL_TRANSACTIONS WHERE ATTRIBUTE_CATEGORY = 'LC Number' and ATTRIBUTE3 =NVL(:P_LC_ID,ATTRIBUTE3 ))) LC_NO,
--(SELECT DISTINCT ATTRIBUTE4 FROM MTL_MATERIAL_TRANSACTIONS WHERE ATTRIBUTE_CATEGORY = 'LC Number' AND TRANSACTION_ID = RSL.MMT_TRANSACTION_ID) NO_OF_PCS,
XX_INV_PKG.XXGET_ENAME (TO_CHAR (RSH.CREATED_BY)) PREPARED_BY,
XX_INV_PKG.XXGET_ENAME (TO_CHAR (:P_USER)) USER_NAME,
:P_TRANSFER_DATE_FROM PDATE_FROM,
:P_TRANSFER_DATE_TO PDATE_TO
FROM 
RCV_SHIPMENT_HEADERS RSH, 
RCV_SHIPMENT_LINES RSL,
WBI_XXKBGITEM_MT_D WXMD
WHERE 
RSH.SHIPMENT_NUM IS NOT NULL
AND RECEIPT_SOURCE_CODE = 'INVENTORY'
--------------------------------------------------------------------------
AND RSH.SHIPMENT_HEADER_ID=RSL.SHIPMENT_HEADER_ID
--------------------------------------------------------------------------
AND WXMD.ORGANIZATION_ID=RSH.ORGANIZATION_ID
AND WXMD.ORGANIZATION_ID=RSL.FROM_ORGANIZATION_ID
AND WXMD.INVENTORY_ITEM_ID=RSL.ITEM_ID
--------------------------------------------------------------------------
AND RSH.SHIPMENT_NUM=NVL(:P_IOT_NO,RSH.SHIPMENT_NUM)
AND TO_DATE(RSH.CREATION_DATE) BETWEEN NVL(:P_TRANSFER_DATE_FROM,TO_DATE(RSH.CREATION_DATE))  AND NVL(:P_TRANSFER_DATE_TO,TO_DATE(RSH.CREATION_DATE))
AND RSH.ORGANIZATION_ID=NVL(:P_FROM_IO,RSH.ORGANIZATION_ID)
AND RSH.SHIP_TO_ORG_ID=NVL(:P_TO_IO,RSH.SHIP_TO_ORG_ID)
AND WXMD.ITEM_CODE=NVL(:P_ITEM_CODE,WXMD.ITEM_CODE)
AND RSL.SHIPMENT_LINE_STATUS_CODE=NVL(:P_STATUS,RSL.SHIPMENT_LINE_STATUS_CODE)
AND (SELECT DISTINCT LC_ID  FROM XX_LC_DETAILS WHERE LC_ID = (SELECT DISTINCT ATTRIBUTE3 FROM MTL_MATERIAL_TRANSACTIONS WHERE ATTRIBUTE_CATEGORY = 'LC Number' AND TRANSACTION_ID = RSL.MMT_TRANSACTION_ID)) =NVL(:P_LC_ID, (SELECT DISTINCT LC_ID  FROM XX_LC_DETAILS WHERE LC_ID = (SELECT DISTINCT ATTRIBUTE3 FROM MTL_MATERIAL_TRANSACTIONS WHERE ATTRIBUTE_CATEGORY = 'LC Number' AND TRANSACTION_ID = RSL.MMT_TRANSACTION_ID)) )  -- is not null
--and RSH.CREATION_DATE between '01-JUL-2020' and '31-JUL-2020'
GROUP BY 
RSH.ORGANIZATION_ID ,
RSH.SHIP_TO_ORG_ID,
RSL.UNIT_OF_MEASURE ,
RSL.LINE_NUM,
RSL.ITEM_ID,
WXMD.ITEM_CODE,
RSH.CREATED_BY,
RSL.SHIPMENT_LINE_STATUS_CODE,
--RSH.CREATION_DATE ,
--RSL.MMT_TRANSACTION_ID,
RSL.ITEM_DESCRIPTION

--====================================================================





-- XXKSRM Inter Org Transfer Summary
SELECT
RSH.SHIPMENT_NUM IOT_NO,
RSH.CREATION_DATE IOT_DATE,
(SELECT OPERATING_UNIT_NAME FROM WBI_INV_ORG_DETAIL WHERE INV_ORGANIZATION_ID=RSH.ORGANIZATION_ID) COMPANY_NAME,
RSH.ORGANIZATION_ID FROM_ORG,
(SELECT INV_ORGANIZATION_CODE||'-'||INVENTORY_ORGANIZATION_NAME FROM WBI_INV_ORG_DETAIL WHERE INV_ORGANIZATION_ID=RSH.ORGANIZATION_ID) FROM_ORG_NAME,
(SELECT INV_ORG_ADDRESS FROM WBI_INV_ORG_DETAIL WHERE INV_ORGANIZATION_ID=RSH.ORGANIZATION_ID) FROM_ORG_ADDRESS,
RSH.SHIP_TO_ORG_ID TO_ORG,
(SELECT INV_ORGANIZATION_CODE||'-'||INVENTORY_ORGANIZATION_NAME FROM WBI_INV_ORG_DETAIL WHERE INV_ORGANIZATION_ID=RSH.SHIP_TO_ORG_ID) TO_ORG_NAME,
(SELECT INV_ORG_ADDRESS FROM WBI_INV_ORG_DETAIL WHERE INV_ORGANIZATION_ID=RSH.SHIP_TO_ORG_ID) TO_ORG_ADDRESS,
RSL.LINE_NUM,
RSL.ITEM_ID,
WXMD.ITEM_CODE,
RSL.ITEM_DESCRIPTION,
RSL.QUANTITY_SHIPPED IOT_QUANTITY,
GET_DPSEA_QTY_FROM_LC( (SELECT DISTINCT ATTRIBUTE3 FROM MTL_MATERIAL_TRANSACTIONS WHERE ATTRIBUTE_CATEGORY = 'LC Number' and ATTRIBUTE3 =:P_LC_ID AND TRANSACTION_ID = RSL.MMT_TRANSACTION_ID)) DEEP_SEA_QTY,
RSL.UNIT_OF_MEASURE UOM,
RSH.RECEIPT_NUM GRN_NO,
RSL.QUANTITY_RECEIVED RECEIVED_QTY,
DECODE(RSL.SHIPMENT_LINE_STATUS_CODE,'EXPECTED','INTRANSIT',RSL.SHIPMENT_LINE_STATUS_CODE) STATUS,
(SELECT DISTINCT ATTRIBUTE1 FROM MTL_MATERIAL_TRANSACTIONS WHERE  TRANSACTION_ID = RSL.MMT_TRANSACTION_ID) VEHICLE_NO,
(SELECT DISTINCT LC_NUMBER  FROM XX_LC_DETAILS WHERE LC_ID = (SELECT DISTINCT ATTRIBUTE3 FROM MTL_MATERIAL_TRANSACTIONS WHERE ATTRIBUTE_CATEGORY = 'LC Number' AND TRANSACTION_ID = RSL.MMT_TRANSACTION_ID)) LC_NO,
(SELECT DISTINCT ATTRIBUTE4 FROM MTL_MATERIAL_TRANSACTIONS WHERE ATTRIBUTE_CATEGORY = 'LC Number' AND TRANSACTION_ID = RSL.MMT_TRANSACTION_ID) NO_OF_PCS,
XX_INV_PKG.XXGET_ENAME (TO_CHAR (RSH.CREATED_BY)) PREPARED_BY,
XX_INV_PKG.XXGET_ENAME (TO_CHAR (:P_USER)) USER_NAME,
:P_TRANSFER_DATE_FROM PDATE_FROM,
:P_TRANSFER_DATE_TO PDATE_TO
FROM 
RCV_SHIPMENT_HEADERS RSH, 
RCV_SHIPMENT_LINES RSL,
WBI_XXKBGITEM_MT_D WXMD
WHERE 
RSH.SHIPMENT_NUM IS NOT NULL
AND RECEIPT_SOURCE_CODE = 'INVENTORY'
--------------------------------------------------------------------------
AND RSH.SHIPMENT_HEADER_ID=RSL.SHIPMENT_HEADER_ID
--------------------------------------------------------------------------
AND WXMD.ORGANIZATION_ID=RSH.ORGANIZATION_ID
AND WXMD.ORGANIZATION_ID=RSL.FROM_ORGANIZATION_ID
AND WXMD.INVENTORY_ITEM_ID=RSL.ITEM_ID
--------------------------------------------------------------------------
AND RSH.SHIPMENT_NUM=NVL(:P_IOT_NO,RSH.SHIPMENT_NUM)
AND TO_DATE(RSH.CREATION_DATE) BETWEEN NVL(:P_TRANSFER_DATE_FROM,TO_DATE(RSH.CREATION_DATE))  AND NVL(:P_TRANSFER_DATE_TO,TO_DATE(RSH.CREATION_DATE))
AND RSH.ORGANIZATION_ID=NVL(:P_FROM_IO,RSH.ORGANIZATION_ID)
AND RSH.SHIP_TO_ORG_ID=NVL(:P_TO_IO,RSH.SHIP_TO_ORG_ID)
AND WXMD.ITEM_CODE=NVL(:P_ITEM_CODE,WXMD.ITEM_CODE)
AND RSL.SHIPMENT_LINE_STATUS_CODE=NVL(:P_STATUS,RSL.SHIPMENT_LINE_STATUS_CODE)
AND (SELECT DISTINCT LC_ID  FROM XX_LC_DETAILS WHERE LC_ID = (SELECT DISTINCT ATTRIBUTE3 FROM MTL_MATERIAL_TRANSACTIONS WHERE ATTRIBUTE_CATEGORY = 'LC Number' AND TRANSACTION_ID = RSL.MMT_TRANSACTION_ID)) = :P_LC_ID  -- is not null



SELECT GRN_NUMBER FROM LC

select 