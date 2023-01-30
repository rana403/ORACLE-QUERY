MONITORING_QUERY
--=============================

--PURCHASE MONITORING
--===================================================================================
 -- PO APPROVED BUT NOT GRN   -- IF  ADD THIS CONDITION THEN PARTIAL GRN WILL NOT SHOW ( and  pll.quantity_received  =  0 )
 --=================================================================== 0 =============
 
 select * from PO_HEADERS_ALL where segment1 = 40000010 -- and org_id= 81
 
 SELECT * FROM PO_HEADERS_ALL WHERE PO_HEADER_ID= 220012  --- 482281
 
 select * from PO_LINES_ALL WHERE PO_HEADER_ID=220012 -- 482281
 
 SELECT   pha.org_id , hou.NAME, ood.organization_code, ood.organization_name,
            pha.po_header_id, pha.segment1, PHA.CLOSED_CODE , pha.ATTRIBUTE1, TRUNC (pha.approved_date) po_approved_date,
            pla.item_id, ksiv.concatenated_segments, pla.item_description,
            m2.segment1 item_category, pll.need_by_date,
            aps.segment1 vendor_number, aps.vendor_name,
            pll.quantity quantity, pll.quantity_received quantity_received,
            pll.quantity_rejected quantity_rejected,
            pll.quantity_cancelled quantity_cancelled,
            (  pll.quantity
             - NVL (pll.quantity_received, 0)
             - NVL (pll.quantity_rejected, 0)
             - NVL (pll.quantity_cancelled, 0)
            ) quantity_backordered,
            pha.authorization_status,
            (pll.quantity * pla.unit_price) po_amount
       FROM po_headers_all pha,
            ap_suppliers aps,
            po_lines_all pla,
            po_line_locations_all pll,
            hr_operating_units hou,
            apps.org_organization_definitions ood,
            mtl_categories m2,
            mtl_system_items_kfv ksiv
      WHERE pha.vendor_id = aps.vendor_id
        AND pha.po_header_id = pla.po_header_id
        AND pla.po_line_id = pll.po_line_id
        AND pla.po_header_id = pll.po_header_id
        AND pha.org_id = hou.organization_id
        AND ood.operating_unit = hou.organization_id
        AND pll.ship_to_organization_id = ood.organization_id
        AND m2.category_id = pla.category_id
        AND ksiv.inventory_item_id = pla.item_id
        AND ksiv.organization_id = ood.organization_id
        AND PLL.Quantity > NVL(pll.quantity_received,0)+NVL(pll.quantity_cancelled,0)
        AND  pha.authorization_status = 'APPROVED' 
        --AND PHA.CLOSED_CODE   IN ( 'CLOSED')
        --AND PHA.CLOSED_CODE  NOT IN ( 'CLOSED', 'FINALLY CLOSED')
       and pha.ATTRIBUTE1  IN ( 'SIS','IL','INL','LFA','L','IFA')
       and  pll.quantity_received  < pll.quantity
      --  AND   pll.quantity_received  <> '0'
       --  and  pll.quantity_received  =  0
        AND pha.org_id = :P_OU_NAME
       AND (:P_POAPPROVE_FROM_DT IS NULL OR TRUNC(pha.approved_date) BETWEEN :P_POAPPROVE_FROM_DT AND :P_POAPPROVE_TO_DT) 
      --and pha.po_header_id= 112004
     --AND pha.segment1 ='40000043'  
   ORDER BY pha.segment1  --aps.vendor_name, pla.item_description;


--INVENTORY  MONITORING
--=============================================================
--GRN DATE IS CHANGED OR NOT FROM USER FOR POWER
--=====================================
SELECT * FROM ORG_ORGANIZATION_DEFINITIONS WHERE ORGANIZATION_CODE = 'KPM'

SELECT * FROM rcv_shipment_headers RSH WHERE RSH.RECEIPT_NUM= 80000288 and RSH.SHIP_TO_ORG_ID = 160

SELECT * FROM RCV_SHIPMENT_LINES RSL WHERE RSL.SHIPMENT_HEADER_ID = 1006171 and RSL.TO_ORGANIZATION_ID= 160

Select GET_ORG_CODE_FROM_ID(RSH.SHIP_TO_ORG_ID) ORG_CODE, RSH.RECEIPT_NUM,
mtt.INVENTORY_ITEM_ID,
 XXGET_ITEM_DESCRIPTION(mtt.INVENTORY_ITEM_ID, mtt.ORGANIZATION_ID) ITEM_DESC,
 mtt.transaction_id, RSH.SHIPMENT_HEADER_ID,
 TO_CHAR(TRUNC(RSH.CREATION_DATE),'DD-MON-RRRR') GRN_CREATION_DATE,
TO_CHAR(TRUNC(RT.TRANSACTION_DATE),'DD-MON-RRRR') GRN_TRANSACTION_DATE,
TO_CHAR(TRUNC(MTT.TRANSACTION_DATE) ,'DD-MON-RRRR') MTL_TRASNT_DATE
 from mtl_material_transactions mtt , rcv_shipment_headers rsh , rcv_shipment_lines rsl,rcv_transactions rt
where rsh.SHIPMENT_HEADER_ID=rsl.SHIPMENT_HEADER_ID
and rsl.SHIPMENT_HEADER_ID=rt.SHIPMENT_HEADER_ID
and rsl.SHIPMENT_LINE_ID=rt.SHIPMENT_LINE_ID
and rt.transaction_id=mtt.RCV_TRANSACTION_ID
and rt.transaction_type='DELIVER'
--and mtt.INVENTORY_ITEM_ID in (243,244)
--and RSH.RECEIPT_NUM= 80000288
AND TO_CHAR(MTT.TRANSACTION_DATE,'MON-YY') = :P_PERIOD
AND RSH.SHIP_TO_ORG_ID = 121
--AND TO_CHAR(TRUNC(RT.TRANSACTION_DATE),'DD-MON-RRRR') <> TO_CHAR(TRUNC(MTT.TRANSACTION_DATE) ,'DD-MON-RRRR')    --- GETTING MISMATCH
order by RSH.RECEIPT_NUM DESC

--====================================================
-- PENDING PR QUERY:  TO GET PR APPROVED  But  not PO===    
--=====================================================

SELECT    (SUBSTR(XX_GET_HR_OPERATING_UNIT(PRH.ORG_ID),5)) OU, 
 PRH.AUTHORIZATION_STATUS,
PRH.REQUISITION_HEADER_ID REQ_HEADER_ID,
PRL.REQUISITION_LINE_ID REQ_LINE_ID,
   (PRH.SEGMENT1) "PR NUMBER",
    TO_CHAR(TRUNC(prh.APPROVED_DATE),'DD-MON-RRRR') "PR Approved Date",
   PRL.CLOSED_CODE,
 PRL.QUANTITY, PRL.QUANTITY_DELIVERED,
 INVORG_NAME_FROM_ID (PRL.DESTINATION_ORGANIZATION_ID) ORG_NAME,
  (SELECT NAME FROM HR_ALL_ORGANIZATION_UNITS WHERE ORGANIZATION_ID=PRL.DESTINATION_ORGANIZATION_ID) DEST_ORG_NAME ,
 MY_PACKAGE.GET_DEPARTMENT_FRM_USERKG(PRL.TO_PERSON_ID) USER_DEPT,
 MY_PACKAGE.GET_DEPT_FROM_EMP_ID(PRL.TO_PERSON_ID) USER_NAME,
-- to_char(trunc(prh.creation_date) "CREATED ON",
-- trunc(prl.creation_date) "Line Creation Date" ,
--msi.segment1 "Item Num",
PRL.ITEM_DESCRIPTION "Description",
prl.quantity "Qty",
prl.attribute2 ORIGIN,prl.
attribute3 use_of_area, 
(to_date(SYSDATE, 'dd-mm-yy') - to_date(prh.APPROVED_DATE, 'dd-mm-yy')) Lead_time,
PPF1.FULL_NAME "PREPARER"
--XXKG_COM_PKG.GET_DEPT_NAME (prh.PREPARER_ID) Department
--ppf2.agent_name "BUYER"
FROM
PO.PO_REQUISITION_HEADERS_ALL PRH,
PO.PO_REQUISITION_LINES_ALL PRL,
APPS.PER_PEOPLE_F PPF1,
(SELECT DISTINCT AGENT_ID,AGENT_NAME FROM APPS.PO_AGENTS_V ) PPF2,
PO.PO_REQ_DISTRIBUTIONS_ALL PRD,
INV.MTL_SYSTEM_ITEMS_B MSI,
PO.PO_LINE_LOCATIONS_ALL PLL,
PO.PO_LINES_ALL PL,
PO.PO_HEADERS_ALL PH
WHERE
PRH.REQUISITION_HEADER_ID = PRL.REQUISITION_HEADER_ID
AND PRL.REQUISITION_LINE_ID = PRD.REQUISITION_LINE_ID
AND PPF1.PERSON_ID = PRH.PREPARER_ID
AND PRH.CREATION_DATE BETWEEN PPF1.EFFECTIVE_START_DATE AND PPF1.EFFECTIVE_END_DATE AND PPF2.AGENT_ID(+) = MSI.BUYER_ID
AND MSI.INVENTORY_ITEM_ID = PRL.ITEM_ID
AND MSI.ORGANIZATION_ID = PRL.DESTINATION_ORGANIZATION_ID
AND PLL.LINE_LOCATION_ID(+) = PRL.LINE_LOCATION_ID
AND PLL.PO_HEADER_ID = PH.PO_HEADER_ID(+)
AND PLL.PO_LINE_ID = PL.PO_LINE_ID(+)
AND PRH.AUTHORIZATION_STATUS = 'APPROVED'
AND PLL.LINE_LOCATION_ID IS NULL
AND PRL.CLOSED_CODE IS NULL
--AND PRL.MODIFIED_BY_AGENT_FLAG is not  null     --- MODIFIED GLAG Y line no need to cancel 
AND NVL(PRL.CANCEL_FLAG,'N') <> 'Y'
AND PRH.TYPE_LOOKUP_CODE <> 'INTERNAL'         
--AND PRH.APPROVED_DATE  BETWEEN '01-JAN-21' AND  '31-AUG-21'
--AND PRH.ORG_ID =  :P_OU  
AND (:P_PRAPPROVE_FROM_DT IS NULL OR TRUNC(PRH.APPROVED_DATE) BETWEEN :P_PRAPPROVE_FROM_DT AND :P_PRAPPROVE_TO_DT) 
--AND   MY_PACKAGE.GET_DEPARTMENT_FRM_USERKG(PRL.TO_PERSON_ID) = 'Store'
--and prh.segment1 = '10000034' -- 'Incomplete'
--AND  INVORG_NAME_FROM_ID (PRL.DESTINATION_ORGANIZATION_ID) = 'KSA'
ORDER BY  PRH.SEGMENT1  --1,2



--===============================================
--  PENDING MOVE ORDER (MO APPROVED BUT NOT TRANSACTED) V1
--===============================================

SELECT  C.MEANING , (SELECT DISTINCT GET_OU_NAME_FROM_ID(OPERATING_UNIT)  FROM ORG_ORGANIZATION_DEFINITIONS WHERE ORGANIZATION_ID= A.ORGANIZATION_ID ) OU,
GET_ORG_CODE_FROM_ID(A.ORGANIZATION_ID) ORG_CODE, A.TRANSACTION_TYPE_NAME,A.REQUEST_NUMBER MO_NUMBER, 
 (D.SEGMENT1 || '|' || D.SEGMENT2 || '|' || D.SEGMENT3||'|' || D.SEGMENT4)    ITEM_CODE,
 XXGET_ITEM_DESCRIPTION(B.INVENTORY_ITEM_ID,A.ORGANIZATION_ID) ITEM_DESC, B.UOM_CODE,
--XX_INV_PKG.XXGET_EMP_DEPT(A.CREATED_BY) DEPARTMENT,
(SELECT DISTINCT  USE_AREA FROM XXKSRM_INV_USE_AREA_V WHERE USE_AREA_ID= B.ATTRIBUTE2 ) USEOFAREA,
A.CREATION_DATE MO_DATE, B.STATUS_DATE,XX_GET_EMP_NAME_FROM_USER_ID (A.CREATED_BY) CREATED_BY,  C.MEANING MO_STATUS_LINE,B.QUANTITY MO_QTY,B.QUANTITY_DELIVERED ISSUE_QTY  
FROM MTL_TXN_REQUEST_HEADERS_V A, MTL_TXN_REQUEST_LINES_V B , MFG_LOOKUPS C, MTL_SYSTEM_ITEMS_B D
WHERE B.REQUEST_NUMBER = A.REQUEST_NUMBER
       AND B.HEADER_ID = A.HEADER_ID
       AND B.ORGANIZATION_ID = A.ORGANIZATION_ID
              AND B.ORGANIZATION_ID = D.ORGANIZATION_ID
           AND B.INVENTORY_ITEM_ID = D.INVENTORY_ITEM_ID
--AND A.HEADER_STATUS_NAME = 'Approved'
AND A.REQUEST_NUMBER LIKE 'MO%' 
--AND A.REQUEST_NUMBER IN ( 'MO-KSM-0114776', 'MO-KSM-0097896')
       AND B.LINE_STATUS = C.LOOKUP_CODE
       AND C.LOOKUP_TYPE = 'MTL_TXN_REQUEST_STATUS'
       AND TRUNC(A.CREATION_DATE)  BETWEEN '01-JUN-2022' and '30-JUN-2022'
              -- AND TRUNC(A.CREATION_DATE)  BETWEEN '01-AUG-2018' and '31-DEC-2021'
      AND  C.MEANING  = 'Approved' 
      -- AND TO_CHAR(A.CREATION_DATE) = :P_PERIOD
      -- AND A.REQUEST_NUMBER = 'MO-KOM-0002809'
      
      

SELECT * FROM MTL_MATERIAL_TRANSACTIONS WHERE  TRANSACTION_ID IN (686499,
686503)

SELECT * FROM RCV_SHIPMENT_HEADERS WHERE SHIPMENT_HEADER_ID = 137029 --SHIP_TO_ORG_ID, ORGANIZATION_ID

SELECT * FROM RCV_TRANSACTIONS WHERE TRANSACTION_ID in (192035,192036)

SELECT * FROM OE_ORDER_HEADERS_ALL WHERE HEADER_ID=3001

SELECT * FROM MFG_LOOKUPS WHERE 
LOOKUP_TYPE = 'MTL_TXN_REQUEST_STATUS'


--==================================================================RECONCILIATION INVENTORY===============================================

--==========================================
-- 1.  SELECT PENDING DATA FOR FEBRUARY-2022
--==========================================
SELECT * FROM RCV_TRANSACTIONS_INTERFACE WHERE TRUNC(CREATION_DATE) between '01-FEB-2022' and '28-FEB-2022' 

----============================================================================
--2. IF GET ANY DELIVERY STATUS , "INVENTORY "
--GO TO THE TRANSACTION STATUS SUMMARY FORM THEN SELECTORG--> GO TO TRANSACTION DETAILS TAB--> PROVIDE THE DATE RANGE THE FIND THE DATA --> 
--DELETE THE DATA FROM THE FORM --> SAVE THE FORM  
----===========================================================================
SELECT * FROM RCV_TRANSACTIONS_INTERFACE WHERE TRUNC(CREATION_DATE) between '01-FEB-2022' and '28-FEB-2022' 
and DESTINATION_TYPE_CODE = 'INVENTORY'


--==========================================
-- 3. ERROR IF INTERFACE TABLE BACKUP FOR FEBRUARY-2022
--==========================================
select *  from RCV_TRANSACTIONS_FEB_2022 

CREATE TABLE RCV_TRANSACTIONS_FEB_2022 AS 
SELECT * FROM RCV_TRANSACTIONS_INTERFACE WHERE TRUNC(CREATION_DATE) between '01-FEB-2022' and '28-FEB-2022' 


--==========================================
-- 4. DELETE DATE FROM INTERFACE TABLE  FOR FEBRUARY-2022
--==========================================
delete from RCV_TRANSACTIONS_INTERFACE WHERE TRUNC(CREATION_DATE) between '01-FEB-2022' and '28-FEB-2022' 


SELECT *
FROM RCV_TRANSACTIONS_INTERFACE
WHERE TO_ORGANIZATION_ID =121
AND TRANSACTION_DATE <= '&EndPeriodDate'
AND DESTINATION_TYPE_CODE = 'INVENTORY';


