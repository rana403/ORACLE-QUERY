
--===================================
--GRN CREATED BUT NOT INVOICES
--===================================
SELECT 
distinct PHA.org_id,
SUBSTR(XX_GET_HR_OPERATING_UNIT (PHA.ORG_ID),5) OPERATING_UNIT,
--XX_INV_PKG.XXGET_ORG_LOCATION (PHA.ORG_ID) ORG_ADDRESS,
--RT.ORGANIZATION_ID INV_ORG,
INVORG_NAME_FROM_ID (RT.ORGANIZATION_ID) INV_ORG_NAME,
     pha.ATTRIBUTE1 PO_TYPE,
      PHA.SEGMENT1 PO_NUMBER,
 TO_CHAR(TRUNC( PHA.APPROVED_DATE),'DD-MON-RRRR') PO_APPROVED_DATE,
          RH.RECEIPT_NUM GRN_NUMBER, 
  TO_CHAR(TRUNC( RT.CREATION_DATE),'DD-MON-RRRR') GRN_DATE,
       ASP.VENDOR_NAME,
      -- ASP.SEGMENT1 VENDOR_NO,
       --PHA.APPROVED_DATE  PO_APPROVED_DATE,
           PLA.ITEM_DESCRIPTION,
 --    (PLA.UNIT_PRICE* PLA.QUANTITY) PO_AMOUNT,
            NULL INVOICE_NUM,
            NULL INVOICE_DATE,
            NULL GL_DATE,
            NULL INVOICE_AMOUNT,
            NULL INV_VOUCHER_NO,
            NULL INV_CREATED_BY,
          NULL DIST_GL_CODE,
          NULL PAYMENT_VOUCHER,
          NULL PAY_CREATE_DATE,
          NULL PAYMENT_TYPE,
          NULL PAYMENT_STATUS,
          NULL PAY_AMOUNT,
         XX_ONT_GET_ENAME(:P_USER) PRINTED_BY 
 from PO_HEADERS_ALL PHA, PO_LINES_ALL PLA, PO_LINE_LOCATIONS_ALL PLL,PO_DISTRIBUTIONS_ALL PDA, AP_SUPPLIERS ASP,
 RCV_TRANSACTIONS RT,RCV_SHIPMENT_LINES RL, RCV_SHIPMENT_HEADERS RH
 WHERE PHA.PO_HEADER_ID =PLA.PO_HEADER_ID
 and PHA.po_header_id = PLA.po_header_id
 and PLA.po_line_id= pll.po_line_id
 and PHA.po_header_id= pll.po_header_id
 and PHA.PO_HEADER_ID= PLA.PO_HEADER_ID
 AND PLA.PO_LINE_ID= PDA.PO_LINE_ID
 AND PLA.QUANTITY <> 0
 AND PHA.PO_HEADER_ID= RT.PO_HEADER_ID
 AND PLA.PO_LINE_ID= RT.PO_LINE_ID
 AND PDA.GL_CANCELLED_DATE is NULL
 AND RT.TRANSACTION_TYPE= 'DELIVER'
    AND PDA.PO_DISTRIBUTION_ID NOT IN
      (SELECT PO_DISTRIBUTION_ID FROM PO_DISTRIBUTIONS_ALL PDA
       WHERE PO_DISTRIBUTION_ID IN (SELECT DISTINCT  PO_DISTRIBUTION_ID FROM AP_INVOICE_DISTRIBUTIONS_ALL))
 AND RH.SHIPMENT_HEADER_ID= RT.SHIPMENT_HEADER_ID
 AND RH.SHIPMENT_HEADER_ID= RL.SHIPMENT_HEADER_ID
 AND RL.SHIPMENT_LINE_ID= RT.SHIPMENT_LINE_ID
 AND ASP.VENDOR_ID= PHA.VENDOR_ID
   AND (:P_ORG_ID IS NULL OR PHA.ORG_ID = :P_ORG_ID)
  AND (:P_GRN_FROM_DT IS NULL OR TRUNC(RT.CREATION_DATE) BETWEEN :P_GRN_FROM_DT AND :P_GRN_TO_DT) 
  AND (:P_PO_NO IS NULL OR PHA.segment1 = :P_PO_NO) 
  AND (:P_GRN_NO IS NULL OR rh.receipt_num = :P_GRN_NO) 
  ORDER BY INV_ORG_NAME ,GRN_NUMBER ASC -- RT.ORGANIZATION_ID 
  
  --=========================================================================








select * from org_organization_definitions where ORGANIZATION_CODE='KBD'

SELECT * FROM RCV_SHIPMENT_HEADERS RSH where RSH.SHIPMENT_HEADER_ID= 984298 AND SHIP_TO_ORG_ID = 166

select * from rcv_shipment_lines where  SHIPMENT_HEADER_ID= 984298 AND TO_ORGANIZATION_ID = 166

select * from rcv_transactions where SHIPMENT_HEADER_ID= 984298 AND ORGANIZATION_ID = 166

===========================================================================================

UPDATE RCV_SHIPMENT_HEADERS
SET LAST_UPDATE_DATE=TO_DATE('10/31/2018 06:18:34 PM', 'MM/DD/YYYY HH12:MI:SS PM'), 
CREATION_DATE=TO_DATE('10/31/2018 06:18:34 PM', 'MM/DD/YYYY HH12:MI:SS PM') 
WHERE 1=1
AND SHIPMENT_HEADER_ID= '988451'
AND SHIP_TO_ORG_ID = 160

 
SELECT * FROM RCV_SHIPMENT_LINES RSL where RSL.SHIPMENT_HEADER_ID= '440274' AND RSL.TO_ORGANIZATION_ID = 166

UPDATE  RCV_SHIPMENT_LINES
SET LAST_UPDATE_DATE=TO_DATE('9/9/2018 06:18:34 PM', 'MM/DD/YYYY HH12:MI:SS PM'), 
CREATION_DATE=TO_DATE('9/9/2018 06:18:34 PM', 'MM/DD/YYYY HH12:MI:SS PM')
WHERE 1=1
AND SHIPMENT_HEADER_ID= '440274'
AND TO_ORGANIZATION_ID = 166
    
SELECT * FROM  RCV_TRANSACTIONS WHERE SHIPMENT_HEADER_ID = '440274' AND ORGANIZATION_ID = 166 
    
UPDATE  RCV_TRANSACTIONS
SET LAST_UPDATE_DATE= TO_DATE('9/9/2018 06:18:34 PM', 'MM/DD/YYYY HH12:MI:SS PM'), 
CREATION_DATE=TO_DATE('9/9/2018 06:18:34 PM', 'MM/DD/YYYY HH12:MI:SS PM'), 
PROGRAM_UPDATE_DATE=TO_DATE('9/9/2018 06:18:34 PM', 'MM/DD/YYYY HH12:MI:SS PM'), 
TRANSACTION_DATE=TO_DATE('9/9/2018 06:18:34 PM', 'MM/DD/YYYY HH12:MI:SS PM'), 
CURRENCY_CONVERSION_DATE =TO_DATE('9/9/2018 06:18:34 PM', 'MM/DD/YYYY HH12:MI:SS PM')
WHERE 1=1
AND SHIPMENT_HEADER_ID= '451492'
AND ORGANIZATION_ID = 166

commit;

