
select * FROM org_ORGANIZATION_DEFINITIONS WHERE ORGANIZATION_CODE = 'KB1'


select * from rcv_shipment_headers where receipt_num = 80005562 and ship_to_org_id= 165

select * from RCV_TRANSACTIONS where SHIPMENT_HEADER_ID = 1051232  and TRANSACTION_TYPE = 'DELIVER'   --- ATTRIBUTE5= CHALLAN NO , ATTRIBUTE6= CHALLAN QUANMTITY


--Blanket PO Transaction Summary 
SELECT --ATTRIBUTE5 CHALLAN,
PHA.ATTRIBUTE4 H_DIS,
PHA.ATTRIBUTE13 PROJECT,
PHA.TYPE_LOOKUP_CODE PO_TYPEEE,
(SELECT B.DESCRIPTION FROM FND_FLEX_VALUE_SETS A, FND_FLEX_VALUES_VL B WHERE  A.FLEX_VALUE_SET_ID = B.FLEX_VALUE_SET_ID AND A.FLEX_VALUE_SET_NAME = 'XX_PO_TYPE' AND B.FLEX_VALUE=PHA.ATTRIBUTE1) PO_TYPE,
PLA.LINE_NUM, 
PHA.PO_HEADER_ID,
PLA.PO_LINE_ID,
PLL.LINE_LOCATION_ID,
PHA.ATTRIBUTE1||'/'||PHA.SEGMENT1 PO_NUM,
TO_CHAR (PHA.CREATION_DATE, 'DD-MON-RRRR') PO_CR_DT,
PHA.ATTRIBUTE2 CON_PERSON,
XX_GET_ACCT_FLEX_SEG_DESC (7, PHA.ATTRIBUTE14) PROJECT_NAME,
--PHA.ATTRIBUTE10 TERM_DAYS,
PHA.AUTHORIZATION_STATUS,
TO_CHAR (PHA.APPROVED_DATE, 'DD-MON-RRRR') PO_APP_DT,
PHA.CURRENCY_CODE,
PHA.RATE,
OOD.ORGANIZATION_CODE DESTINITION,
POV.SEGMENT1 SUPPLIER_ID,
POV.VENDOR_ID,
POV.VENDOR_NAME SUPPLIER_NAME,
ADDRESS_LINE1||' '||ADDRESS_LINE2||' '||PVS.CITY SUPPLIER_ADD,
PVS.CITY||'-'||PVS.ZIP CITY_ZIP,
PVS.PHONE SUPP_PHONE,
PVS.TELEX,
PVS.EMAIL_ADDRESS SUPP_EMAIL,
SUBSTR(XX_GET_HR_OPERATING_UNIT(:P_ORG_ID),5,200) ORG_HEADER_NAME,
HRL.ADDRESS_LINE_1||' '||HRL.ADDRESS_LINE_2||' '||HRL.ADDRESS_LINE_3||'  '||HRL.REGION_1||' '||HRL.POSTAL_CODE BCL_F_ADD,
HRL.TELEPHONE_NUMBER_1 PHP_F_PHONE,
HRL.TELEPHONE_NUMBER_2 PHP_F_FAX,
HRL.LOC_INFORMATION13 PHP_F_EMAIL,
MP.ORGANIZATION_ID INVENTORY_ORG,
MP.ORGANIZATION_CODE||' - '||HRL.LOCATION_CODE IO,
XX_P2P_PKG.LC_FROM_PO(PHA.PO_HEADER_ID) LC_NO,
PRA.RELEASE_NUM,
TO_CHAR(PRA.RELEASE_DATE, 'DD-MON-RRRR') RELEASE_DATE, 
PHA.REVISION_NUM,
HRL1.ADDRESS_LINE_1||' '||HRL1.ADDRESS_LINE_2||' '||HRL1.ADDRESS_LINE_3||'  '||HRL1.REGION_1||' '||HRL1.POSTAL_CODE BCL_BILL_ADD,
TO_CHAR (PLL.PROMISED_DATE, 'DD-MON-RRRR') PROMISED_DATE,
DECODE (PDA.REQ_HEADER_REFERENCE_NUM,
               NULL,XX_P2P_PKG.XX_FND_REQUISITION_INFO(PLL.ATTRIBUTE1,:P_ORG_ID,PLL.ATTRIBUTE2,'RNUM'),
               PDA.REQ_HEADER_REFERENCE_NUM) REQUISITION_NO ,
XX_P2P_PKG.XX_FND_CS_NO_INFO(PHA.PO_HEADER_ID,PHA.ORG_ID) CSS_NO,
TO_CHAR(XX_P2P_PKG.XX_FND_CS_DATE_INFO(PHA.PO_HEADER_ID,PHA.ORG_ID), 'DD-MON-RRRR') CSS_DATE,
PLA.ATTRIBUTE1 BRAND,
PLA.ATTRIBUTE2 ORIGIN,               
MST.ITEM_CODE,
PHA.ATTRIBUTE4 DIS_AMT,
PHA.ATTRIBUTE5 DIS_PER,
PHA.ATTRIBUTE6 CONTACT_PERSON,
PLA.ATTRIBUTE3 SPECIFICATIONS ,
PLA.ITEM_DESCRIPTION,MUOM.UOM_CODE,
SUM(PLL.QUANTITY) PO_QTY,
PLA.UNIT_PRICE PRICE,
NVL((NVL(PLA.ATTRIBUTE11,0)/100*PLA.UNIT_PRICE),0)+NVL(PLA.ATTRIBUTE5,0) DISCOUNT_PRICE,
SUM(PLL.QUANTITY)*PLA.UNIT_PRICE CF_NET_VALUE_SUM,
NVL(PHA.ATTRIBUTE10,0) CARRYING_COST,
(NVL((NVL(PLA.ATTRIBUTE11,0)/100*PLA.UNIT_PRICE),0)+NVL(PLA.ATTRIBUTE5,0))*SUM(PLL.QUANTITY) DISCOUNT_PRICE_SUM,
--PLA.UNIT_PRICE-NVL((NVL(NVL(to_number(PLA.ATTRIBUTE11),0)/100*NVL(PLA.UNIT_PRICE,0),0)+PLA.ATTRIBUTE5),0) UNIT_PRICE,
PLA.ATTRIBUTE5 LINE_DIS,
--PLA.ATTRIBUTE11 LINE_DIS_PER,
XX_P2P_EMP_INFO.XX_P2P_GET_ONLY_EMPN(PHA.CREATION_DATE,PHA.AGENT_ID) CREATOR_DETAILS,
NVL(PHA1.SEGMENT1,'...............') QUOTE_NO,
NVL(PHA1.QUOTE_VENDOR_QUOTE_NUMBER,'...............') SUPPLIER_QUOTE,
NVL(TO_CHAR (PHA1.REPLY_DATE, 'DD-MON-RRRR'),'...............')  REPLY_DATE,
 '(For '||POV.VENDOR_NAME||')' SUPP_ALIAS,
NVL(PHA.ATTRIBUTE15,0) VAT,
RT.DELIVER_QTY,
PL.QUANTITY_REJECTED REJECTED_QTY,
--RT.REJECTED_QTY,
RT.RETURN_QTY,
RT.RECEIPT_NO,
RT.RECEIPT_DATE,
RT.RECEIPT_QTY,
RT.CHALLAN_QUANTITY,
TO_CHAR(:P_F_PO_DT,'DD-MON-RRRR') FROM_DATE,
TO_CHAR(:P_T_PO_DT,'DD-MON-RRRR') TO_DATEE,
XX_ONT_GET_ENAME(:P_USER) PRINTED_BY 
--  case  when PHA.ATTRIBUTE15 is null then  'VAT Included' else PHA.ATTRIBUTE15  end vat
  FROM PO_HEADERS_ALL PHA,
       PO_HEADERS_ALL PHA1,
       PO_LINES_ALL PLA,
       MTL_UNITS_OF_MEASURE_TL MUOM,
       PO_LINE_LOCATIONS_ALL PLL,
       AP_SUPPLIERS POV,
       AP_SUPPLIER_SITES_ALL PVS,
       HR_LOCATIONS_ALL HRL,
       HR_LOCATIONS_ALL HRL1,
       ORG_ORGANIZATION_DEFINITIONS OOD,
       PO_RELEASES_ALL PRA,
       (SELECT  REQ_HEADER_REFERENCE_NUM, LINE_LOCATION_ID
                   FROM XX_PO_DISTRIBUTIONS_V
                   WHERE PO_HEADER_ID=:P_PO_NO
                   GROUP BY REQ_HEADER_REFERENCE_NUM, LINE_LOCATION_ID) PDA,
       (SELECT ORGANIZATION_ID,INVENTORY_ITEM_ID, DESCRIPTION,
                        (SEGMENT1 || '-' || SEGMENT2 || '-' || SEGMENT3|| '-' || SEGMENT4
                        ) ITEM_CODE
                   FROM MTL_SYSTEM_ITEMS_B) MST,
                   MTL_PARAMETERS MP,
                   ( SELECT DISTINCT  WRT.ORGANIZATION_ID,WRT.PO_HEADER_ID,WRT.PO_LINE_ID,WRT.LINE_LOCATION_ID,SUM(WRT.RECEIPT_QTY) RECEIPT_QTY,  SUM(WRT.ACCEPTED_QTY) ACCEPTED_QTY, SUM(WRT.CHALLAN_QUANTITY_RT) CHALLAN_QUANTITY,
                        (NVL(SUM( WRT.RETURN_QTY),0)+NVL(SUM(WRT.DLV_RETURN_QTY),0)) RETURN_QTY,(SUM(WRT.DELIVER_QTY)-NVL(SUM(WRT.DLV_RETURN_QTY),0)) DELIVER_QTY,WRT.RECEIPT_NO,TO_CHAR(WRT.RECEIPT_DATE, 'DD-MON-YYYY') RECEIPT_DATE--,LISTAGG(RECEIPT_NO,',') within group  (ORDER BY RECEIPT_NO) GRN_NO 
                        FROM INV_RCV_TRANSACTIONS_P2P_VW WRT
                        WHERE TRANSACTION_TYPE='RECEIVE'
                        GROUP BY WRT.PO_HEADER_ID,WRT.PO_LINE_ID,WRT.LINE_LOCATION_ID,WRT.RECEIPT_NO, WRT.ORGANIZATION_ID,TO_CHAR(WRT.RECEIPT_DATE, 'DD-MON-YYYY')) RT,
                        PO_LINE_LOCATIONS PL
 WHERE PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
   AND PHA.VENDOR_ID = POV.VENDOR_ID
   AND PHA.VENDOR_SITE_ID = PVS.VENDOR_SITE_ID
   AND POV.VENDOR_ID = PVS.VENDOR_ID
   AND PHA.TYPE_LOOKUP_CODE IN ('BLANKET')
   AND NVL (UPPER (PHA.AUTHORIZATION_STATUS), 'INCOMPLETE') = 'APPROVED'
   AND PHA.APPROVED_FLAG = 'Y'
   AND PLA.PO_HEADER_ID = PLL.PO_HEADER_ID
   AND PLA.PO_LINE_ID = PLL.PO_LINE_ID
   AND PLA.ITEM_ID = MST.INVENTORY_ITEM_ID
   AND HRL.LOCATION_ID = PLL.SHIP_TO_LOCATION_ID
   AND HRL1.LOCATION_ID = PHA.BILL_TO_LOCATION_ID
   AND PDA.LINE_LOCATION_ID(+) = PLL.LINE_LOCATION_ID
   AND PHA1.PO_HEADER_ID(+) = PHA.FROM_HEADER_ID
   AND PLL.PO_RELEASE_ID = PRA.PO_RELEASE_ID(+)
   AND PLL.LINE_LOCATION_ID = RT.LINE_LOCATION_ID(+)
   AND UPPER(PLL.SHIPMENT_TYPE)<>'PRICE BREAK'
   AND PLA.UNIT_MEAS_LOOKUP_CODE=MUOM.UNIT_OF_MEASURE(+)
   AND NVL(PHA.CANCEL_FLAG,'N')='N'
   AND NVL(PLA.CANCEL_FLAG,'N')='N' 
   AND NVL(PLL.CANCEL_FLAG,'N')='N'
   AND PLL.APPROVED_FLAG = 'Y'
   AND NVL(PRA.APPROVED_FLAG,'Y')='Y'
   AND NVL(PRA.AUTHORIZATION_STATUS,'APPROVED')='APPROVED'
   AND NVL(PRA.CANCEL_FLAG,'N')='N'
   AND PLL.SHIP_TO_ORGANIZATION_ID=MST.ORGANIZATION_ID
   AND PLA.PO_HEADER_ID=RT.PO_HEADER_ID(+)
    AND PHA.PO_HEADER_ID=PL.PO_HEADER_ID(+)---
 AND PLA.PO_LINE_ID=PL.PO_LINE_ID(+)---
 AND RT.PO_HEADER_ID=PL.PO_HEADER_ID(+)---
 AND RT.PO_LINE_ID=PL.PO_LINE_ID(+)---
-- AND RT.LINE_LOCATION_ID=PL.LINE_LOCATION_ID---
 AND PDA.LINE_LOCATION_ID=PL.LINE_LOCATION_ID(+)---
   AND PLA.PO_LINE_ID=RT.PO_LINE_ID(+)
  AND UPPER(NVL(PLA.ATTRIBUTE_CATEGORY,0)) NOT IN ('Branding')
 AND UPPER(NVL(PHA.ATTRIBUTE_CATEGORY,0)) NOT IN ('Branding_Info','Shipping_Info')
   AND PHA.ORG_ID = :P_ORG_ID
   AND PHA.PO_HEADER_ID BETWEEN NVL(:P_PO_NO, PHA.PO_HEADER_ID) AND NVL(:P_PO_TO, PHA.PO_HEADER_ID)
    AND NVL2(:P_PO_NO,PHA.PO_HEADER_ID,-1) BETWEEN NVL(:P_PO_NO,-1) AND NVL(:P_PO_TO,-1) 
  --  AND TRUNC(pha.creation_date) BETWEEN NVL(:P_F_PO_DT,TRUNC(pha.creation_date)) AND NVL(:P_T_PO_DT,TRUNC(pha.creation_date))
  AND (:P_F_PO_DT IS NULL OR TRUNC(PHA.CREATION_DATE) BETWEEN :P_F_PO_DT AND :P_T_PO_DT) 
       AND PLA.ITEM_ID=NVL(:P_ITEM_ID,PLA.ITEM_ID)
       AND POV.VENDOR_ID = NVL(:P_SUPP,POV.VENDOR_ID)
   AND OOD.ORGANIZATION_ID = PLL.SHIP_TO_ORGANIZATION_ID  
   AND MP.ORGANIZATION_ID=PLL.SHIP_TO_ORGANIZATION_ID
   AND RT.ORGANIZATION_ID(+)=PLL.SHIP_TO_ORGANIZATION_ID
 --  AND DECODE (pha.type_lookup_code, 'BLANKET', pra.release_num, 900) =  NVL (:p_release, 900)
   AND PHA.ATTRIBUTE1=NVL(:P_PO_TYPE,PHA.ATTRIBUTE1)
   AND  PLL.SHIP_TO_ORGANIZATION_ID=NVL(:P_INV_ORG,PLL.SHIP_TO_ORGANIZATION_ID)
GROUP BY
PHA.ATTRIBUTE4,
PHA.TYPE_LOOKUP_CODE,
PLA.LINE_NUM, 
PL.QUANTITY_REJECTED,
PHA.PO_HEADER_ID,
PHA.ATTRIBUTE1,
PHA.ATTRIBUTE1||'/'||PHA.SEGMENT1,
PLL.LINE_LOCATION_ID,
PLA.ATTRIBUTE5,
PLA.ATTRIBUTE11,
MP.ORGANIZATION_ID ,
TO_CHAR (PHA.CREATION_DATE, 'DD-MON-RRRR'),
PHA.ATTRIBUTE2,
XX_GET_ACCT_FLEX_SEG_DESC (7, PHA.ATTRIBUTE14),
PHA.ATTRIBUTE4,
OOD.ORGANIZATION_CODE,
PHA.ATTRIBUTE3,
PHA.AUTHORIZATION_STATUS,
TO_CHAR (PHA.APPROVED_DATE, 'DD-MON-RRRR'),
PHA.CURRENCY_CODE,
PHA.RATE,
PHA.ATTRIBUTE6,
NVL(PHA.ATTRIBUTE10,0),
PHA.ATTRIBUTE12,
PLA.PO_LINE_ID,
PHA.ATTRIBUTE11,
POV.SEGMENT1,
POV.VENDOR_ID,
POV.VENDOR_NAME,
ADDRESS_LINE1||' '||ADDRESS_LINE2||' '||PVS.CITY,
PVS.CITY||'-'||PVS.ZIP,
PVS.PHONE,
PVS.TELEX,
MP.ORGANIZATION_CODE||' - '||HRL.LOCATION_CODE,
PVS.EMAIL_ADDRESS,
--xx_com_pkg.get_hr_operating_unit(:p_org_id),
HRL.ADDRESS_LINE_1||' '||HRL.ADDRESS_LINE_2||' '||HRL.ADDRESS_LINE_3||'  '||HRL.REGION_1||' '||HRL.POSTAL_CODE,
HRL.TELEPHONE_NUMBER_1,
HRL.TELEPHONE_NUMBER_2,
HRL.LOC_INFORMATION13,
XX_P2P_PKG.LC_DT_FROM_PO(PHA.PO_HEADER_ID),
PRA.RELEASE_NUM,
TO_CHAR (PLL.PROMISED_DATE, 'DD-MON-RRRR'),
DECODE (PDA.REQ_HEADER_REFERENCE_NUM,
               NULL,XX_P2P_PKG.XX_FND_REQUISITION_INFO(PLL.ATTRIBUTE1,:P_ORG_ID,PLL.ATTRIBUTE2,'RNUM'),
               PDA.REQ_HEADER_REFERENCE_NUM) ,
XX_P2P_PKG.XX_FND_CS_NO_INFO(PHA.PO_HEADER_ID,PHA.ORG_ID),
TO_CHAR(XX_P2P_PKG.XX_FND_CS_DATE_INFO(PHA.PO_HEADER_ID,PHA.ORG_ID), 'DD-MON-RRRR'),
MST.ITEM_CODE,
PLA.ATTRIBUTE1,
PLA.ATTRIBUTE2,
PLA.ATTRIBUTE3  ,
PLA.ITEM_DESCRIPTION,MUOM.UOM_CODE,
PLA.UNIT_PRICE,
XX_P2P_EMP_INFO.XX_P2P_GET_ONLY_EMPN(PHA.CREATION_DATE,PHA.AGENT_ID) ,
NVL(PHA1.SEGMENT1,'...............'),
NVL(PHA1.QUOTE_VENDOR_QUOTE_NUMBER,'...............'),
NVL(TO_CHAR (PHA1.REPLY_DATE, 'DD-MON-RRRR'),'...............'),
 '(For '||POV.VENDOR_NAME||')',
NVL(PHA.ATTRIBUTE15,0),
PHA.ATTRIBUTE13,
PHA.ATTRIBUTE4,
PHA.ATTRIBUTE5,
PHA.ATTRIBUTE6,
--PHA.ATTRIBUTE15,
TO_CHAR(PRA.RELEASE_DATE, 'DD-MON-RRRR'), 
PLA.UNIT_PRICE-NVL((NVL(NVL(PLA.ATTRIBUTE11,0)/100*NVL(PLA.UNIT_PRICE,0),0)+PLA.ATTRIBUTE5),0),
NVL((NVL(PLA.ATTRIBUTE11,0)/100*PLA.UNIT_PRICE),0)+NVL(PLA.ATTRIBUTE5,0)*(PLL.QUANTITY),
PHA.REVISION_NUM,
PLA.UNIT_PRICE,
(HRL1.ADDRESS_LINE_1||' '||HRL1.ADDRESS_LINE_2||' '||HRL1.ADDRESS_LINE_3||'  '||HRL1.REGION_1||' '||HRL1.POSTAL_CODE),
RT.DELIVER_QTY,
RT.RETURN_QTY,
RT.RECEIPT_NO,
RT.RECEIPT_DATE,
RT.RECEIPT_QTY,
RT.CHALLAN_QUANTITY,
XX_ONT_GET_ENAME(:P_USER)  
UNION ALL
SELECT
PHA.ATTRIBUTE4 H_DIS,
PHA.ATTRIBUTE13 PROJECT,
PHA.TYPE_LOOKUP_CODE PO_TYPEEE,
(SELECT B.DESCRIPTION FROM FND_FLEX_VALUE_SETS A, FND_FLEX_VALUES_VL B WHERE  A.FLEX_VALUE_SET_ID = B.FLEX_VALUE_SET_ID AND A.FLEX_VALUE_SET_NAME = 'XX_PO_TYPE' AND B.FLEX_VALUE=PHA.ATTRIBUTE1) PO_TYPE,
PLA.LINE_NUM,
PHA.PO_HEADER_ID,
PLA.PO_LINE_ID,
PL.LINE_LOCATION_ID,
PHA.ATTRIBUTE1||'/'||PHA.SEGMENT1 PO_NUM,
TO_CHAR (PHA.CREATION_DATE, 'DD-MON-RRRR') PO_CR_DT,
PHA.ATTRIBUTE2 CON_PERSON,
XX_GET_ACCT_FLEX_SEG_DESC (7, PHA.ATTRIBUTE14) PROJECT_NAME,
PHA.AUTHORIZATION_STATUS,
--PHA.ATTRIBUTE10 TERM_DAYS,
TO_CHAR (PHA.APPROVED_DATE, 'DD-MON-RRRR') PO_APP_DT,
PHA.CURRENCY_CODE,
PHA.RATE,
NULL DESTINITION,
POV.SEGMENT1 SUPPLIER_ID,
POV.VENDOR_ID,
POV.VENDOR_NAME SUPPLIER_NAME,
ADDRESS_LINE1||' '||ADDRESS_LINE2||' '||PVS.CITY SUPPLIER_ADD,
PVS.CITY||'-'||PVS.ZIP CITY_ZIP,
PVS.PHONE SUPP_PHONE,
PVS.TELEX,
PVS.EMAIL_ADDRESS SUPP_EMAIL,
SUBSTR(XX_GET_HR_OPERATING_UNIT(:P_ORG_ID),5,200) ORG_HEADER_NAME,
HRL.ADDRESS_LINE_1||' '||HRL.ADDRESS_LINE_2||' '||HRL.ADDRESS_LINE_3||'  '||HRL.REGION_1||' '||HRL.POSTAL_CODE BCL_F_ADD,
HRL.TELEPHONE_NUMBER_1 PHP_F_PHONE,
HRL.TELEPHONE_NUMBER_2 PHP_F_FAX,
HRL.LOC_INFORMATION13 PHP_F_EMAIL,
MP.ORGANIZATION_ID INVENTORY_ORG,
MP.ORGANIZATION_CODE IO,
--(select organization_code from mtl_parameters where ORGANIZATION_ID=pll.ship_to_organization_id) IO,
TO_CHAR(NULL) LC_NO,
TO_NUMBER(NULL) RELEASE_NUM,
--to_char(pra.RELEASE_DATE, 'DD-MON-RRRR') rel_dt,
NULL,
PHA.REVISION_NUM,
HRL1.ADDRESS_LINE_1||' '||HRL1.ADDRESS_LINE_2||' '||HRL1.ADDRESS_LINE_3||'  '||HRL1.REGION_1||' '||HRL1.POSTAL_CODE BCL_BILL_ADD,
TO_CHAR (PLL.PROMISED_DATE, 'DD-MON-RRRR') PROMISED_DATE,
XX_P2P_PKG.XX_FND_REQUISITION_INFO(PLL.ATTRIBUTE1,:P_ORG_ID,PLL.ATTRIBUTE2,'RNUM'),
XX_P2P_PKG.XX_FND_CS_NO_INFO(PHA.PO_HEADER_ID,PHA.ORG_ID) CSS_NO,
TO_CHAR(XX_P2P_PKG.XX_FND_CS_DATE_INFO(PHA.PO_HEADER_ID,PHA.ORG_ID), 'DD-MON-RRRR') CSS_DATE,
MST.ITEM_CODE,
PHA.ATTRIBUTE4 DIS_AMT,
PHA.ATTRIBUTE5 DIS_PER,
PHA.ATTRIBUTE6 CONTACT_PERSON,
PLA.ATTRIBUTE1 BRAND,
PLA.ATTRIBUTE2 ORIGIN,
PLA.ATTRIBUTE3 SPECIFICATIONS ,
PLA.ITEM_DESCRIPTION,
MUOM.UOM_CODE,
SUM(PLL.QUANTITY) PO_QTY,
PLA.UNIT_PRICE,
NVL((NVL(PLA.ATTRIBUTE11,0)/100*PLA.UNIT_PRICE),0)+NVL(PLA.ATTRIBUTE5,0) DISCOUNT_PRICE,
SUM(PLL.QUANTITY)*PLA.UNIT_PRICE CF_NET_VALUE_SUM,
NVL(PHA.ATTRIBUTE10,0) CARRYING_COST,
(NVL((NVL(PLA.ATTRIBUTE11,0)/100*PLA.UNIT_PRICE),0)+NVL(PLA.ATTRIBUTE5,0))*SUM(PLL.QUANTITY) DISCOUNT_PRICE_SUM,
--PLA.UNIT_PRICE-(NVL(PLA.ATTRIBUTE11,0)/100*PLA.UNIT_PRICE)-NVL(PLA.ATTRIBUTE5,0) UNIT_PRICE,
PLA.ATTRIBUTE5 LINE_DIS,
XX_P2P_EMP_INFO.XX_P2P_GET_ONLY_EMPN(PHA.CREATION_DATE,PHA.AGENT_ID) CREATOR_DETAILS,
NVL(PHA1.SEGMENT1,'...............') QUOTE_NO,
NVL(PHA1.QUOTE_VENDOR_QUOTE_NUMBER,'...............') SUPPLIER_QUOTE,
NVL(TO_CHAR (PHA1.REPLY_DATE, 'DD-MON-RRRR'),'...............')  REPLY_DATE,
 '(For '||POV.VENDOR_NAME||')' SUPP_ALIAS,
NVL(PHA.ATTRIBUTE15,0) VAT,
RT.DELIVER_QTY,
PL.QUANTITY_REJECTED REJECTED_QTY,
--RT.REJECTED_QTY,
RT.RETURN_QTY,
RT.RECEIPT_NO,
RT.RECEIPT_DATE,
RT.RECEIPT_QTY,
RT.CHALLAN_QUANTITY,
TO_CHAR(:P_F_PO_DT,'DD-MON-RRRR') FROM_DATE,
TO_CHAR(:P_T_PO_DT,'DD-MON-RRRR') TO_DATEE,
--  case  when PHA.ATTRIBUTE15 is null then  'VAT Included' else PHA.ATTRIBUTE15  end vat
XX_ONT_GET_ENAME(:P_USER) PRINTED_BY 
  FROM PO_HEADERS_ALL PHA,
       PO_HEADERS_ALL PHA1,
       PO_LINES_ALL PLA,
       MTL_UNITS_OF_MEASURE_TL MUOM,
       PO_LINE_LOCATIONS_ALL PLL,
       AP_SUPPLIERS POV,
       AP_SUPPLIER_SITES_ALL PVS,
       HR_LOCATIONS_ALL HRL,
       HR_LOCATIONS_ALL HRL1, 
       (SELECT INVENTORY_ITEM_ID,
                        (SEGMENT1 || '-' || SEGMENT2 || '-' || SEGMENT3|| '-' || SEGMENT4
                        ) ITEM_CODE
                   FROM MTL_SYSTEM_ITEMS_B
                   GROUP BY INVENTORY_ITEM_ID,
                        (SEGMENT1 || '-' || SEGMENT2 || '-' || SEGMENT3|| '-' || SEGMENT4
                        )) MST,
                        MTL_PARAMETERS MP,
                   (SELECT DISTINCT  WRT.ORGANIZATION_ID,WRT.PO_HEADER_ID,WRT.PO_LINE_ID,SUM(WRT.RECEIPT_QTY) RECEIPT_QTY,  SUM(WRT.ACCEPTED_QTY) ACCEPTED_QTY, SUM(WRT.CHALLAN_QUANTITY_RT) CHALLAN_QUANTITY,WRT.CHALLAN_NUMBER_RT,
                        (NVL(SUM( WRT.RETURN_QTY),0)+NVL(SUM(WRT.DLV_RETURN_QTY),0)) RETURN_QTY,(SUM(WRT.DELIVER_QTY)-NVL(SUM(WRT.DLV_RETURN_QTY),0)) DELIVER_QTY,WRT.RECEIPT_NO,TO_CHAR(WRT.RECEIPT_DATE, 'DD-MON-YYYY') RECEIPT_DATE--,LISTAGG(RECEIPT_NO,',') within group  (ORDER BY RECEIPT_NO) GRN_NO 
                        FROM INV_RCV_TRANSACTIONS_P2P_VW WRT
                        WHERE TRANSACTION_TYPE='RECEIVE'
                        GROUP BY WRT.PO_HEADER_ID,WRT.PO_LINE_ID,WRT.RECEIPT_NO, WRT.ORGANIZATION_ID,WRT.CHALLAN_NUMBER_RT,TO_CHAR(WRT.RECEIPT_DATE, 'DD-MON-YYYY')) RT,
                        PO_LINE_LOCATIONS PL
 WHERE PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
   AND PHA.VENDOR_ID = POV.VENDOR_ID
   AND PHA.VENDOR_SITE_ID = PVS.VENDOR_SITE_ID
   AND POV.VENDOR_ID = PVS.VENDOR_ID
   AND PHA.TYPE_LOOKUP_CODE IN ('BLANKET')
   AND NVL (UPPER (PHA.AUTHORIZATION_STATUS), 'INCOMPLETE') = 'APPROVED'
   AND PHA.APPROVED_FLAG = 'Y'
   AND PLA.ITEM_ID = MST.INVENTORY_ITEM_ID
   AND HRL.LOCATION_ID = PLL.SHIP_TO_LOCATION_ID
   AND HRL1.LOCATION_ID = PHA.BILL_TO_LOCATION_ID 
   AND PHA1.PO_HEADER_ID(+) = PHA.FROM_HEADER_ID
   AND PLA.UNIT_MEAS_LOOKUP_CODE=MUOM.UNIT_OF_MEASURE(+)
   AND NVL(PHA.CANCEL_FLAG,'N')='N'
   AND NVL(PLA.CANCEL_FLAG,'N')='N'
   AND UPPER(PLL.SHIPMENT_TYPE)='PRICE BREAK'
     AND PLA.PO_HEADER_ID=RT.PO_HEADER_ID(+)
   AND PLA.PO_LINE_ID=RT.PO_LINE_ID(+)
      AND RT.ORGANIZATION_ID(+)=PLL.SHIP_TO_ORGANIZATION_ID
       AND PHA.PO_HEADER_ID=PL.PO_HEADER_ID(+)---
 AND PLA.PO_LINE_ID=PL.PO_LINE_ID(+)---
 AND RT.PO_HEADER_ID=PL.PO_HEADER_ID(+)---
 AND RT.PO_LINE_ID=PL.PO_LINE_ID(+)---
-- AND RT.LINE_LOCATION_ID=PL.LINE_LOCATION_ID---
    AND UPPER(NVL(PLA.ATTRIBUTE_CATEGORY,0)) NOT IN ('Branding')
 AND UPPER(NVL(PHA.ATTRIBUTE_CATEGORY,0)) NOT IN ('Branding_Info','Shipping_Info')
   AND PHA.ORG_ID = :P_ORG_ID
      AND PHA.PO_HEADER_ID BETWEEN NVL(:P_PO_NO, PHA.PO_HEADER_ID) AND NVL(:P_PO_TO, PHA.PO_HEADER_ID)
    AND NVL2(:P_PO_NO,PHA.PO_HEADER_ID,-1) BETWEEN NVL(:P_PO_NO,-1) AND NVL(:P_PO_TO,-1) 
  --  AND TRUNC(pha.creation_date) BETWEEN NVL(:P_F_PO_DT,TRUNC(pha.creation_date)) AND NVL(:P_T_PO_DT,TRUNC(pha.creation_date))
  AND (:P_F_PO_DT IS NULL OR TRUNC(PHA.CREATION_DATE) BETWEEN :P_F_PO_DT AND :P_T_PO_DT) 
       AND PLA.ITEM_ID=NVL(:P_ITEM_ID,PLA.ITEM_ID)
        AND POV.VENDOR_ID = NVL(:P_SUPP,POV.VENDOR_ID)
  AND PLA.PO_LINE_ID=PLL.PO_LINE_ID
   AND PHA.PO_HEADER_ID = :P_PO_NO
   --AND 1=nvl2(:p_release,900,1)
   AND MP.ORGANIZATION_ID=PLL.SHIP_TO_ORGANIZATION_ID
   AND :P_RELEASE IS NULL
   AND PHA.ATTRIBUTE1=NVL(:P_PO_TYPE,PHA.ATTRIBUTE1)
      AND  PLL.SHIP_TO_ORGANIZATION_ID=NVL(:P_INV_ORG,PLL.SHIP_TO_ORGANIZATION_ID)
GROUP BY
PHA.ATTRIBUTE4,
PHA.TYPE_LOOKUP_CODE, 
PLA.LINE_NUM,
PL.QUANTITY_REJECTED,
PHA.PO_HEADER_ID,
PHA.ATTRIBUTE1,
PHA.ATTRIBUTE1||'/'||PHA.SEGMENT1,
PL.LINE_LOCATION_ID,
TO_CHAR (PHA.CREATION_DATE, 'DD-MON-RRRR'),
PHA.ATTRIBUTE2,
XX_GET_ACCT_FLEX_SEG_DESC (7, PHA.ATTRIBUTE14),
PHA.ATTRIBUTE4,
PHA.ATTRIBUTE3,
TO_CHAR (PHA.APPROVED_DATE, 'DD-MON-RRRR'),
PHA.CURRENCY_CODE,
PHA.RATE,
NVL(PHA.ATTRIBUTE10,0),
PHA.ATTRIBUTE12,
PHA.ATTRIBUTE11,
POV.SEGMENT1,
POV.VENDOR_ID,
POV.VENDOR_NAME,
ADDRESS_LINE1||' '||ADDRESS_LINE2||' '||PVS.CITY,
PVS.CITY||'-'||PVS.ZIP,
PVS.PHONE,
PVS.TELEX,
MP.ORGANIZATION_ID ,
PVS.EMAIL_ADDRESS,
XX_GET_HR_OPERATING_UNIT(:P_ORG_ID) ,
HRL.ADDRESS_LINE_1||' '||HRL.ADDRESS_LINE_2||' '||HRL.ADDRESS_LINE_3||'  '||HRL.REGION_1||' '||HRL.POSTAL_CODE,
MP.ORGANIZATION_CODE,
HRL.TELEPHONE_NUMBER_1,
HRL.TELEPHONE_NUMBER_2,
HRL.LOC_INFORMATION13,
PHA.AUTHORIZATION_STATUS,
TO_CHAR(NULL),
PLA.PO_LINE_ID,
PLA.ATTRIBUTE5,
PLA.UNIT_PRICE,
NVL((NVL(PLA.ATTRIBUTE11,0)/100*PLA.UNIT_PRICE),0)+NVL(PLA.ATTRIBUTE5,0),
TO_CHAR(NULL),
TO_CHAR (PLL.PROMISED_DATE, 'DD-MON-RRRR'),
XX_P2P_PKG.XX_FND_REQUISITION_INFO(PLL.ATTRIBUTE1,:P_ORG_ID,PLL.ATTRIBUTE2,'RNUM'),
XX_P2P_PKG.XX_FND_CS_NO_INFO(PHA.PO_HEADER_ID,PHA.ORG_ID),
TO_CHAR(XX_P2P_PKG.XX_FND_CS_DATE_INFO(PHA.PO_HEADER_ID,PHA.ORG_ID), 'DD-MON-RRRR'),
MST.ITEM_CODE,
PHA.ATTRIBUTE4,
PHA.ATTRIBUTE5,
PHA.ATTRIBUTE6,
PLA.ATTRIBUTE1,
PLA.ATTRIBUTE2,
PLA.NOTE_TO_VENDOR ,
PLA.ITEM_DESCRIPTION,MUOM.UOM_CODE,
PLA.UNIT_PRICE-(NVL(PLA.ATTRIBUTE11,0)/100*PLA.UNIT_PRICE)-NVL(PLA.ATTRIBUTE5,0),
XX_P2P_EMP_INFO.XX_P2P_GET_ONLY_EMPN(PHA.CREATION_DATE,PHA.AGENT_ID) ,
NVL(PHA1.SEGMENT1,'...............'),
NVL(PHA1.QUOTE_VENDOR_QUOTE_NUMBER,'...............'),
NVL(TO_CHAR (PHA1.REPLY_DATE, 'DD-MON-RRRR'),'...............'),
 '(For '||POV.VENDOR_NAME||')',
NVL(PHA.ATTRIBUTE15,0),
PHA.ATTRIBUTE13, 
--PHA.ATTRIBUTE15,
--to_char(pra.RELEASE_DATE, 'DD-MON-RRRR'),
NULL, 
PHA.REVISION_NUM,
PLA.ATTRIBUTE3,
(HRL1.ADDRESS_LINE_1||' '||HRL1.ADDRESS_LINE_2||' '||HRL1.ADDRESS_LINE_3||'  '||HRL1.REGION_1||' '||HRL1.POSTAL_CODE) ,
RT.DELIVER_QTY,
--RT.REJECTED_QTY,
RT.RETURN_QTY,
RT.RECEIPT_NO,
RT.RECEIPT_DATE,
RT.RECEIPT_QTY,
RT.CHALLAN_QUANTITY,
XX_ONT_GET_ENAME(:P_USER)  
ORDER BY RECEIPT_NO