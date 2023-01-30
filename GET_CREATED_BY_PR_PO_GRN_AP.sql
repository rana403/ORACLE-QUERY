
my_package 

xx_inv_pkg

xx_p2p_pkg.xx_fnd_emp_name_uid: varchar2

select * from INL_ALLOCATIONS

select * from org_organization_definitions where ORGANIZATION_CODE = 'KSH'

GET WHO CREATE PR
==============

SELECT ORG_ID, SEGMENT1 REQUISITION_NO,  XX_GET_EMP_NAME_FROM_USER_ID (CREATED_BY) CREATED_BY  FROM PO_REQUISITION_HEADERS_ALL
WHERE ORG_ID=81
AND SEGMENT1= 10002412


--GET WHO CREATE PO
--==============

SELECT ORG_ID, SEGMENT1 PO_NUMBER, XX_GET_EMP_NAME_FROM_USER_ID (CREATED_BY) CREATED_BY FROM PO_HEADERS_ALL 
WHERE SEGMENT1= 40000003
AND ORG_ID=81

--GET WHO CREATE GRN
--==============

SELECT RECEIPT_NUM,  XX_GET_EMP_NAME_FROM_USER_ID (CREATED_BY) CREATED_BY FROM RCV_SHIPMENT_HEADERS WHERE SHIP_TO_ORG_ID = 145 AND RECEIPT_NUM = '80000502'

--GET WHO CREATE GRN
--==============

SELECT ORG_ID, INVOICE_NUM, XX_GET_EMP_NAME_FROM_USER_ID (CREATED_BY) CREATED_BY
 FROM AP_INVOICES_ALL
 WHERE INVOICE_NUM =  '04-SEP-2018'
 AND ORG_ID=104


--GET WHO CREATE MOVE ORDER
--========================

SELECT REQUEST_NUMBER ,TRANSACTION_TYPE_NAME,  XX_GET_EMP_NAME_FROM_USER_ID (CREATED_BY) CREATED_BY
 FROM MTL_TXN_REQUEST_HEADERS_V
 WHERE REQUEST_NUMBER =  'MO-KSA-0034894'
 
 




XX_GET_EMP_NAME_FROM_USER_ID   FUNCTIONS
================================
/*CREATE OR REPLACE FUNCTION APPS.XX_GET_EMP_NAME_FROM_USER_ID (P_USER_ID IN NUMBER)
      RETURN VARCHAR2
   IS
      V_RESULT   VARCHAR2 (128);

      CURSOR P_CURSOR
      IS
         SELECT NVL (
                --      DECODE (EMP.FIRST_NAME, NULL, NULL, EMP.FIRST_NAME)
                   DECODE (EMP.MIDDLE_NAMES, NULL, NULL, ' ' || EMP.MIDDLE_NAMES)
                   || DECODE (EMP.LAST_NAME, NULL, NULL, ' ' || EMP.LAST_NAME)
                   ||' ('||DECODE (EMP.FIRST_NAME, NULL, NULL, EMP.FIRST_NAME)||')',
                   USER_NAME)
           FROM FND_USER USR, PER_ALL_PEOPLE_F EMP
          WHERE     USR.EMPLOYEE_ID = EMP.PERSON_ID(+)
                AND EMP.EFFECTIVE_END_DATE(+) > SYSDATE
                AND USR.USER_ID = P_USER_ID;
   BEGIN
      OPEN P_CURSOR;

      FETCH P_CURSOR INTO V_RESULT;

      CLOSE P_CURSOR;

      RETURN V_RESULT;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;
/
*/