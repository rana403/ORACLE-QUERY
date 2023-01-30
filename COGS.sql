

select * from ORG_ORGANIZATION_DEFINITIONS where ORGANIZATION_CODE = 'KBM'

--==========================================
 -- EBS COGS STATEMENT  FINAL V2  -- 4-APR-2021
--==========================================

SELECT X.PERIOD_CODE,X.LEDGER_ID, X.COMPANY_NAME, X.COMPANY, X.OPERATING_UNIT, X.COST_CENTER,
X.ORGANIZATION_CODE,X.MEJOR_FIN_CAT, X.MAJOR_FIN_CAT_1, X.FIN_CAT,X.ORGANIZATION_ID,--X.TRANSACTION_ID,
X.INVENTORY_ITEM_ID,X.ITEM_CODE,X.Decode_1,X.ITEM_DESC, X.UOM  UOM_ACT, 
DECODE( X.UOM,'KG','MT', X.UOM )  UOM, 
X.EVENT_TYPE_CODE,X.TRANSACTION_TYPE_ID,
X.TRANSACTION_TYPE_NAME,X.ACCOUNT_NAME,X.SUB_ACCOUNT,X.OP_QTY, X.OP_VAL,
SUM(X.RCV_QTY) RCV_QTY, SUM(X.RCV_VAL) RCV_VAL, ABS(SUM(X.ISSUE_QTY)) ISSUE_QTY, ABS(SUM(X.ISSUE_VAL)) ISSUE_VAL, 
ABS(SUM(X.TRANS_QTY)) TRANS_QTY,
--TO_CHAR(DECODE ( X.UOM,'KG',ABS(SUM(X.TRANS_QTY))/1000,ABS(SUM(X.TRANS_QTY)) ),'99999990D99') T_QTY,
(CASE WHEN X.Customer = 'OMSP' THEN TO_CHAR(DECODE ( X.UOM,'KG',ABS(SUM(X.TRANS_QTY))/1000,ABS(SUM(X.TRANS_QTY)) ),'99999990D99')  * - 1 ELSE TO_NUMBER(TO_CHAR(DECODE ( X.UOM,'KG',ABS(SUM(X.TRANS_QTY))/1000,ABS(SUM(X.TRANS_QTY)) ),'99999990D99')) END ) T_QTY,
ABS(SUM(X.TRANS_VAL))/DECODE ( X.UOM,'KG',ABS(SUM(X.ISSUE_QTY))/1000,ABS(SUM(X.ISSUE_QTY)) ) RATE,
--TO_CHAR(ABS(SUM(X.TRANS_QTY)),'99999990D99') t_qty,  TRANS_VAL div ISSUE_QTY
 (CASE when X.Customer = 'OMSP' and EVENT_TYPE_CODE = 'RMA_RECEIPT' then  ABS(SUM(X.ISSUE_VAL)) * - 1
     WHEN X.Customer = 'OMSP' THEN ABS(SUM(X.TRANS_VAL)) * - 1 ELSE ABS(SUM(X.TRANS_VAL)) END ) TRANS_VAL,
X.JE_CATEGORY_NAME,X.Customer,X.ACCOUNTING_CLASS_CODE, SUM(X.DR) DR, SUM(X.CR) CR ,X.ACCOUNTING_CODE
FROM
(
SELECT INV_TRANS.PERIOD_CODE,INV_TRANS.LEDGER_ID, INV_TRANS.COMPANY_NAME, INV_TRANS.COMPANY, INV_TRANS.OPERATING_UNIT, INV_TRANS.COST_CENTER, 
INV_TRANS.ORGANIZATION_CODE,FIN_CAT.MEJOR_FIN_CAT, FIN_CAT.MAJOR_FIN_CAT_1, FIN_CAT.FIN_CAT,INV_TRANS.ORGANIZATION_ID,--INV_TRANS.TRANSACTION_ID,
INV_TRANS.INVENTORY_ITEM_ID,INV_TRANS.ITEM_CODE, INV_TRANS.Decode_1, INV_TRANS.ITEM_DESC, INV_TRANS.UOM, INV_TRANS.EVENT_TYPE_CODE,INV_TRANS.TRANSACTION_TYPE_ID,
CASE WHEN INV_TRANS.TRANSACTION_TYPE_ID=-99 THEN INV_TRANS.EVENT_TYPE_CODE ELSE INV_TRANS.TRANSACTION_TYPE_NAME END TRANSACTION_TYPE_NAME,
INV_TRANS.ACCOUNT_NAME,INV_TRANS.SUB_ACCOUNT,
0 OP_QTY, 0 OP_VAL,
SUM(CASE WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (17,12,44,18,61,1002,1003) THEN INV_TRANS.TRANSACTION_QUANTITY ELSE 0 END) RCV_QTY,
SUM(CASE WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (17,18,1002,1003) THEN INV_TRANS.TRANSACTION_VALUE
WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (44) THEN INV_TRANS.TRANSACTION_VALUE -----INV_TRANS.ACCOUNTED_DR
WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (61) THEN INV_TRANS.ACCOUNTED_DR
WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (12) THEN INV_TRANS.ACCOUNTED_DR
WHEN NVL(INV_TRANS.TRANSACTION_TYPE_ID,11111)=11111 AND EVENT_TYPE_CODE = 'GLCOSTALOC' THEN INV_TRANS.TRANSACTION_VALUE
WHEN NVL(INV_TRANS.TRANSACTION_TYPE_ID,2222)=2222 AND EVENT_TYPE_CODE = 'LC_ADJUST_VALUATION' THEN INV_TRANS.TRANSACTION_VALUE
WHEN INV_TRANS.TRANSACTION_TYPE_ID=-99 THEN INV_TRANS.TRANSACTION_VALUE ELSE 0 END) RCV_VAL,
SUM(CASE WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (32,33,35,36,42,43,15,21,63,62,101,103,104,107,111,120,10008,140,71,200,260,261,52) THEN INV_TRANS.TRANSACTION_QUANTITY ELSE 0 END) ISSUE_QTY,
SUM(CASE WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (32,33,35,36,42,43,21,63,62,101,103,104,107,111,120,10008,140,71,200,260,261,52) THEN INV_TRANS.TRANSACTION_VALUE
WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (15) THEN INV_TRANS.ACCOUNTED_DR ELSE 0 END) ISSUE_VAL,
SUM(NVL(INV_TRANS.TRANSACTION_QUANTITY,0)) TRANS_QTY,
SUM(NVL(INV_TRANS.TRANSACTION_VALUE,0)) TRANS_VAL,
INV_TRANS.JE_CATEGORY_NAME,INV_TRANS.Customer,INV_TRANS.ACCOUNTING_CLASS_CODE,
SUM(INV_TRANS.ACCOUNTED_DR) DR,SUM(INV_TRANS.ACCOUNTED_CR) CR ,INV_TRANS.ACCOUNTING_CODE
FROM
(
SELECT TO_CHAR(TRANSACTION_DATE,'MON-YY') PERIOD_CODE, A.LEDGER_ID, (SELECT DISTINCT BAL_SEG_NAME FROM XX_INV_ORG_VW WHERE LEDGER_ID=A.LEDGER_ID) COMPANY_NAME,
C.ORGANIZATION_CODE,A.ORGANIZATION_ID,
XX_GET_ACCT_FLEX_SEG_DESC (1, F.SEGMENT1) COMPANY,
XX_GET_ACCT_FLEX_SEG_DESC (2, F.SEGMENT2) OPERATING_UNIT,
XX_GET_ACCT_FLEX_SEG_DESC (3, F.SEGMENT3) COST_CENTER,
--(SELECT DISTINCT XX_GET_ACCT_FLEX_SEG_DESC (3, SEGMENT3) COST_CENTER FROM GL_CODE_COMBINATIONS_KFV WHERE CODE_COMBINATION_ID=E.CODE_COMBINATION_ID) COST_CENTER,
A.INVENTORY_ITEM_ID,B.SEGMENT1||'|'||B.SEGMENT2||'|'||B.SEGMENT3||'|'||B.SEGMENT4 ITEM_CODE,
(case when B.SEGMENT1='FG' then '1' when B.SEGMENT1='CP' then '2' when B.SEGMENT1='BP' then '3' when B.SEGMENT1='RM' then '4' when B.SEGMENT1='SP' then '5' when B.SEGMENT1='PS' then '6' when B.SEGMENT1='CV' then '7' else B.SEGMENT1 end) Decode_1,   
(SELECT DESCRIPTION FROM MTL_SYSTEM_ITEMS_B WHERE INVENTORY_ITEM_ID=A.INVENTORY_ITEM_ID AND ORGANIZATION_ID=A.ORGANIZATION_ID) ITEM_DESC,
(SELECT PRIMARY_UOM_CODE FROM MTL_SYSTEM_ITEMS_B WHERE INVENTORY_ITEM_ID=A.INVENTORY_ITEM_ID AND ORGANIZATION_ID=A.ORGANIZATION_ID) UOM,
A.EVENT_CLASS_CODE,A.EVENT_TYPE_CODE, --a.transaction_id,
G.TRANSACTION_TYPE_ID,G.TRANSACTION_TYPE_NAME,
D.JE_CATEGORY_NAME,E.ACCOUNTING_CLASS_CODE,D.AE_HEADER_ID,XX_AP_PKG.GET_ACCOUNT_DESC_FROM_CCID (E.CODE_COMBINATION_ID) ACCOUNT_NAME,
(case when D.JE_CATEGORY_NAME='INTE' then 'Internal'  when D.JE_CATEGORY_NAME='SHIP' then 'External' else D.JE_CATEGORY_NAME end ) Customer,
XX_AP_PKG.GET_SUB_ACCOUNT_DESC_FROM_CCID(TO_NUMBER(E.CODE_COMBINATION_ID)) SUB_ACCOUNT,
TRANSACTION_QUANTITY,TRANSACTION_VALUE,SUM(NVL(E.ACCOUNTED_DR,0))ACCOUNTED_DR,SUM(NVL(E.ACCOUNTED_CR,0))ACCOUNTED_CR ,F.CONCATENATED_SEGMENTS ACCOUNTING_CODE
FROM GMF_XLA_EXTRACT_HEADERS A,MTL_SYSTEM_ITEMS_B B,ORG_ORGANIZATION_DEFINITIONS C,XLA_AE_HEADERS D,XLA_AE_LINES E,GL_CODE_COMBINATIONS_KFV F,MTL_TRANSACTION_TYPES G
WHERE A.INVENTORY_ITEM_ID=B.INVENTORY_ITEM_ID(+) AND A.ORGANIZATION_ID=B.ORGANIZATION_ID(+) AND A.ORGANIZATION_ID=C.ORGANIZATION_ID AND A.TRANSACTION_TYPE_ID=G.TRANSACTION_TYPE_ID(+)
--and a.transaction_id IN (7973373) -- 219226.85
--AND E.ACCOUNTING_CLASS_CODE = 'INVENTORY_VALUATION'
and  (nvl(e.ACCOUNTED_DR, 0) >  0.49  or nvl(e.ACCOUNTED_CR, 0) > 0.49)  
AND A.EVENT_ID=D.EVENT_ID AND D.AE_HEADER_ID=E.AE_HEADER_ID AND E.CODE_COMBINATION_ID=F.CODE_COMBINATION_ID
AND TO_CHAR(TRANSACTION_DATE,'MON-YY')=:P_PERIOD_CODE
AND A.LEDGER_ID=:P_LEDGER_ID AND A.ORGANIZATION_ID=NVL(:P_ORGANIZATION_ID,A.ORGANIZATION_ID) AND A.INVENTORY_ITEM_ID=NVL(:P_INVENTORY_ITEM_ID,A.INVENTORY_ITEM_ID)
group by 
TRANSACTION_DATE, A.LEDGER_ID, A.LEDGER_ID,
C.ORGANIZATION_CODE,A.ORGANIZATION_ID,
F.SEGMENT1, F.SEGMENT2, F.SEGMENT3,
A.INVENTORY_ITEM_ID,B.SEGMENT1||'|'||B.SEGMENT2||'|'||B.SEGMENT3||'|'||B.SEGMENT4,
(case when B.SEGMENT1='FG' then '1' when B.SEGMENT1='CP' then '2' when B.SEGMENT1='BP' then '3' when B.SEGMENT1='RM' then '4' when B.SEGMENT1='SP' then '5' when B.SEGMENT1='PS' then '6' when B.SEGMENT1='CV' then '7' else B.SEGMENT1 end) ,   
A.EVENT_CLASS_CODE,A.EVENT_TYPE_CODE, --a.transaction_id,
G.TRANSACTION_TYPE_ID,G.TRANSACTION_TYPE_NAME,
D.JE_CATEGORY_NAME,E.ACCOUNTING_CLASS_CODE,D.AE_HEADER_ID,XX_AP_PKG.GET_ACCOUNT_DESC_FROM_CCID (E.CODE_COMBINATION_ID) ,
(case when D.JE_CATEGORY_NAME='INTE' then 'Internal'  when D.JE_CATEGORY_NAME='SHIP' then 'External' else D.JE_CATEGORY_NAME end ) ,
XX_AP_PKG.GET_SUB_ACCOUNT_DESC_FROM_CCID(TO_NUMBER(E.CODE_COMBINATION_ID)) ,
TRANSACTION_QUANTITY,TRANSACTION_VALUE,F.CONCATENATED_SEGMENTS 
) INV_TRANS
LEFT OUTER JOIN (SELECT MIC.INVENTORY_ITEM_ID,MIC.ORGANIZATION_ID,MC.SEGMENT1 MEJOR_FIN_CAT,
(case when MC.SEGMENT1 ='FINISHED GOODS' then '1' when MC.SEGMENT1 like '%WASTAGE%' then '2' when MC.SEGMENT1  like '%RAW MATERIALS%' then '3' when MC.SEGMENT1  like '%SPARES%' then '4' when MC.SEGMENT1 like '%LUBRICANTS%' then '5' else MC.SEGMENT1 end) MAJOR_FIN_CAT_1,
MC.SEGMENT1||'|'||MC.SEGMENT2 FIN_CAT
FROM MTL_ITEM_CATEGORIES MIC,MTL_CATEGORIES MC WHERE MIC.CATEGORY_ID=MC.CATEGORY_ID AND STRUCTURE_ID=50408) FIN_CAT
ON FIN_CAT.INVENTORY_ITEM_ID=INV_TRANS.INVENTORY_ITEM_ID AND FIN_CAT.ORGANIZATION_ID=INV_TRANS.ORGANIZATION_ID AND FIN_CAT.MEJOR_FIN_CAT= NVL(:P_MEJOR_FIN_CAT,FIN_CAT.MEJOR_FIN_CAT)
GROUP BY PERIOD_CODE,FIN_CAT.MEJOR_FIN_CAT, FIN_CAT.MAJOR_FIN_CAT_1, FIN_CAT.FIN_CAT,INV_TRANS.LEDGER_ID, INV_TRANS.COMPANY_NAME,INV_TRANS.ORGANIZATION_CODE,INV_TRANS.ORGANIZATION_ID,--INV_TRANS.TRANSACTION_ID,
INV_TRANS.INVENTORY_ITEM_ID,INV_TRANS.ITEM_CODE, INV_TRANS.Decode_1, INV_TRANS.ITEM_DESC, INV_TRANS.UOM,
INV_TRANS.EVENT_TYPE_CODE,INV_TRANS.TRANSACTION_TYPE_NAME,INV_TRANS.ACCOUNT_NAME,INV_TRANS.SUB_ACCOUNT,INV_TRANS.ACCOUNTING_CODE,
INV_TRANS.TRANSACTION_TYPE_ID,INV_TRANS.JE_CATEGORY_NAME,INV_TRANS.Customer,INV_TRANS.ACCOUNTING_CLASS_CODE, COMPANY, OPERATING_UNIT, COST_CENTER
ORDER BY ORGANIZATION_ID,INVENTORY_ITEM_ID--,CASE WHEN TRANSACTION_TYPE_NAME = 'OPENING VALUE' THEN 1 ELSE 2 END ---,ae_header_id
) X
WHERE (ACCOUNT_NAME IN ('Finished Goods','Raw Materials')
OR ACCOUNT_NAME LIKE ('Stores%Spares')
OR ACCOUNT_NAME LIKE ('Fuel%Lubricants')
OR ACCOUNT_NAME LIKE ('Bi Product%Wastage'))
AND ACCOUNTING_CLASS_CODE  IN ( 'INVENTORY_VALUATION', 'COST_VARIANCE')
--AND EVENT_TYPE_CODE='FOB_SHIP_SENDER_SHIP_TP'
AND EVENT_TYPE_CODE IN('SO_ISSUE','FOB_SHIP_SENDER_SHIP_TP', 'COGS_RECOGNITION_ADJ', 'RMA_RECEIPT')
AND X.JE_CATEGORY_NAME = NVL (:P_JE_CATEGORY_NAME, X.JE_CATEGORY_NAME)
AND X.Customer =NVL (:Customer, X.Customer)
and TRANSACTION_TYPE_ID <> 21
AND X.COST_CENTER = NVL(:P_COST_CENTER, X.COST_CENTER)
--AND to_date('01-'||period_code) BETWEEN '01-SEP-18' AND '30-SEP-18'
--and to_char(INV_TRANS.transaction_date,'MON-YY')=:P_PERIOD_CODE
GROUP BY X.Decode_1,X.PERIOD_CODE,X.LEDGER_ID, X.COMPANY_NAME, X.ORGANIZATION_CODE,X.MEJOR_FIN_CAT, X.MAJOR_FIN_CAT_1, X.FIN_CAT,X.ORGANIZATION_ID,--X.TRANSACTION_ID,
X.INVENTORY_ITEM_ID,X.ITEM_CODE, X.ITEM_DESC, X.UOM, X.EVENT_TYPE_CODE,X.TRANSACTION_TYPE_ID,
X.TRANSACTION_TYPE_NAME,X.ACCOUNT_NAME,X.SUB_ACCOUNT,X.OP_QTY, X.OP_VAL,
X.JE_CATEGORY_NAME,X.Customer,X.ACCOUNTING_CLASS_CODE, X.ACCOUNTING_CODE,X.COMPANY, X.OPERATING_UNIT, X.COST_CENTER
order by X.MAJOR_FIN_CAT_1

--==========================================
 -- EBS COGS STATEMENT  FINAL V1  -- 1-APR-2021-MAR-2021
--==========================================

SELECT X.PERIOD_CODE,X.LEDGER_ID, X.COMPANY_NAME, X.COMPANY, X.OPERATING_UNIT, X.COST_CENTER,
X.ORGANIZATION_CODE,X.MEJOR_FIN_CAT, X.MAJOR_FIN_CAT_1, X.FIN_CAT,X.ORGANIZATION_ID,--X.TRANSACTION_ID,
X.INVENTORY_ITEM_ID,X.ITEM_CODE,X.Decode_1,X.ITEM_DESC, X.UOM  UOM_ACT, 
DECODE( X.UOM,'KG','MT', X.UOM )  UOM, 
X.EVENT_TYPE_CODE,X.TRANSACTION_TYPE_ID,
X.TRANSACTION_TYPE_NAME,X.ACCOUNT_NAME,X.SUB_ACCOUNT,X.OP_QTY, X.OP_VAL,
SUM(X.RCV_QTY) RCV_QTY, SUM(X.RCV_VAL) RCV_VAL, ABS(SUM(X.ISSUE_QTY)) ISSUE_QTY, 
(CASE   WHEN X.TRANSACTION_TYPE_ID =  62 THEN SUM(X.CR)  
WHEN X.TRANSACTION_TYPE_ID =  33 THEN SUM(X.CR)
ELSE ABS(SUM(X.ISSUE_VAL)) END) ISSUE_VAL, 
--(CASE WHEN )
ABS(SUM(X.TRANS_QTY)) TRANS_QTY,
--TO_CHAR(DECODE ( X.UOM,'KG',ABS(SUM(X.TRANS_QTY))/1000,ABS(SUM(X.TRANS_QTY)) ),'99999990D99') T_QTY,
(CASE WHEN X.Customer = 'OMSP' THEN TO_CHAR(DECODE ( X.UOM,'KG',ABS(SUM(X.TRANS_QTY))/1000,ABS(SUM(X.TRANS_QTY)) ),'99999990D99')  * - 1 ELSE TO_NUMBER(TO_CHAR(DECODE ( X.UOM,'KG',ABS(SUM(X.TRANS_QTY))/1000,ABS(SUM(X.TRANS_QTY)) ),'99999990D99')) END ) T_QTY,
ABS(SUM(X.TRANS_VAL))/DECODE ( X.UOM,'KG',ABS(SUM(X.ISSUE_QTY))/1000,ABS(SUM(X.ISSUE_QTY)) ) RATE,
--TO_CHAR(ABS(SUM(X.TRANS_QTY)),'99999990D99') t_qty,  TRANS_VAL div ISSUE_QTY
 (CASE when X.Customer = 'OMSP' and EVENT_TYPE_CODE = 'RMA_RECEIPT' then  ABS(SUM(X.ISSUE_VAL)) * - 1
     WHEN X.Customer = 'OMSP' THEN ABS(SUM(X.TRANS_VAL)) * - 1 
     WHEN X.TRANSACTION_TYPE_ID =  62 THEN SUM(X.CR)  -- ADDED 1-APR-2021
     WHEN X.TRANSACTION_TYPE_ID =  33 THEN SUM(X.CR)
     ELSE ABS(SUM(X.TRANS_VAL)) 
     END ) TRANS_VAL,
X.JE_CATEGORY_NAME,X.Customer,X.ACCOUNTING_CLASS_CODE, SUM(X.DR) DR, SUM(X.CR) CR ,X.ACCOUNTING_CODE
FROM
(
SELECT INV_TRANS.PERIOD_CODE,INV_TRANS.LEDGER_ID, INV_TRANS.COMPANY_NAME, INV_TRANS.COMPANY, INV_TRANS.OPERATING_UNIT, INV_TRANS.COST_CENTER, 
INV_TRANS.ORGANIZATION_CODE,FIN_CAT.MEJOR_FIN_CAT, FIN_CAT.MAJOR_FIN_CAT_1, FIN_CAT.FIN_CAT,INV_TRANS.ORGANIZATION_ID,--INV_TRANS.TRANSACTION_ID,
INV_TRANS.INVENTORY_ITEM_ID,INV_TRANS.ITEM_CODE, INV_TRANS.Decode_1, INV_TRANS.ITEM_DESC, INV_TRANS.UOM, INV_TRANS.EVENT_TYPE_CODE,INV_TRANS.TRANSACTION_TYPE_ID,
CASE WHEN INV_TRANS.TRANSACTION_TYPE_ID=-99 THEN INV_TRANS.EVENT_TYPE_CODE ELSE INV_TRANS.TRANSACTION_TYPE_NAME END TRANSACTION_TYPE_NAME,
INV_TRANS.ACCOUNT_NAME,INV_TRANS.SUB_ACCOUNT,
0 OP_QTY, 0 OP_VAL,
SUM(CASE WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (17,12,44,18,61,1002,1003) THEN INV_TRANS.TRANSACTION_QUANTITY ELSE 0 END) RCV_QTY,
SUM(CASE WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (17,18,1002,1003) THEN INV_TRANS.TRANSACTION_VALUE
WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (44) THEN INV_TRANS.TRANSACTION_VALUE -----INV_TRANS.ACCOUNTED_DR
WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (61) THEN INV_TRANS.ACCOUNTED_DR
WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (12) THEN INV_TRANS.ACCOUNTED_DR
WHEN NVL(INV_TRANS.TRANSACTION_TYPE_ID,11111)=11111 AND EVENT_TYPE_CODE = 'GLCOSTALOC' THEN INV_TRANS.TRANSACTION_VALUE
WHEN NVL(INV_TRANS.TRANSACTION_TYPE_ID,2222)=2222 AND EVENT_TYPE_CODE = 'LC_ADJUST_VALUATION' THEN INV_TRANS.TRANSACTION_VALUE
WHEN INV_TRANS.TRANSACTION_TYPE_ID=-99 THEN INV_TRANS.TRANSACTION_VALUE ELSE 0 END) RCV_VAL,
SUM(CASE WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (32,33,35,36,42,43,15,21,63,62,101,103,104,107,111,120,10008,140,71,200,260,261,52) THEN INV_TRANS.TRANSACTION_QUANTITY ELSE 0 END) ISSUE_QTY,
SUM(CASE WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (32,33,35,36,42,43,21,63,62,101,103,104,107,111,120,10008,140,71,200,260,261,52) THEN INV_TRANS.TRANSACTION_VALUE
WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (15) THEN INV_TRANS.ACCOUNTED_DR ELSE 0 END) ISSUE_VAL,
SUM(NVL(INV_TRANS.TRANSACTION_QUANTITY,0)) TRANS_QTY,
SUM(NVL(INV_TRANS.TRANSACTION_VALUE,0)) TRANS_VAL,
INV_TRANS.JE_CATEGORY_NAME,INV_TRANS.Customer,INV_TRANS.ACCOUNTING_CLASS_CODE,
SUM(INV_TRANS.ACCOUNTED_DR) DR,SUM(INV_TRANS.ACCOUNTED_CR) CR ,INV_TRANS.ACCOUNTING_CODE
FROM
(
SELECT a.transaction_id,TO_CHAR(TRANSACTION_DATE,'MON-YY') PERIOD_CODE, A.LEDGER_ID, (SELECT DISTINCT BAL_SEG_NAME FROM XX_INV_ORG_VW WHERE LEDGER_ID=A.LEDGER_ID) COMPANY_NAME,
C.ORGANIZATION_CODE,A.ORGANIZATION_ID,
XX_GET_ACCT_FLEX_SEG_DESC (1, F.SEGMENT1) COMPANY,
XX_GET_ACCT_FLEX_SEG_DESC (2, F.SEGMENT2) OPERATING_UNIT,
XX_GET_ACCT_FLEX_SEG_DESC (3, F.SEGMENT3) COST_CENTER,
--(SELECT DISTINCT XX_GET_ACCT_FLEX_SEG_DESC (3, SEGMENT3) COST_CENTER FROM GL_CODE_COMBINATIONS_KFV WHERE CODE_COMBINATION_ID=E.CODE_COMBINATION_ID) COST_CENTER,
A.INVENTORY_ITEM_ID,B.SEGMENT1||'|'||B.SEGMENT2||'|'||B.SEGMENT3||'|'||B.SEGMENT4 ITEM_CODE,
(case when B.SEGMENT1='FG' then '1' when B.SEGMENT1='CP' then '2' when B.SEGMENT1='BP' then '3' when B.SEGMENT1='RM' then '4' when B.SEGMENT1='SP' then '5' when B.SEGMENT1='PS' then '6' when B.SEGMENT1='CV' then '7' else B.SEGMENT1 end) Decode_1,   
(SELECT DESCRIPTION FROM MTL_SYSTEM_ITEMS_B WHERE INVENTORY_ITEM_ID=A.INVENTORY_ITEM_ID AND ORGANIZATION_ID=A.ORGANIZATION_ID) ITEM_DESC,
(SELECT PRIMARY_UOM_CODE FROM MTL_SYSTEM_ITEMS_B WHERE INVENTORY_ITEM_ID=A.INVENTORY_ITEM_ID AND ORGANIZATION_ID=A.ORGANIZATION_ID) UOM,
A.EVENT_CLASS_CODE,A.EVENT_TYPE_CODE, --a.transaction_id,
G.TRANSACTION_TYPE_ID,G.TRANSACTION_TYPE_NAME,
D.JE_CATEGORY_NAME,E.ACCOUNTING_CLASS_CODE,D.AE_HEADER_ID,XX_AP_PKG.GET_ACCOUNT_DESC_FROM_CCID (E.CODE_COMBINATION_ID) ACCOUNT_NAME,
(case when D.JE_CATEGORY_NAME='INTE' then 'Internal'  when D.JE_CATEGORY_NAME='SHIP' then 'External' else D.JE_CATEGORY_NAME end ) Customer,
XX_AP_PKG.GET_SUB_ACCOUNT_DESC_FROM_CCID(TO_NUMBER(E.CODE_COMBINATION_ID)) SUB_ACCOUNT,
TRANSACTION_QUANTITY,A.TRANSACTION_VALUE,
E.ACCOUNTED_DR,E.ACCOUNTED_CR,F.CONCATENATED_SEGMENTS ACCOUNTING_CODE
FROM GMF_XLA_EXTRACT_HEADERS A,MTL_SYSTEM_ITEMS_B B,ORG_ORGANIZATION_DEFINITIONS C,XLA_AE_HEADERS D,XLA_AE_LINES E,GL_CODE_COMBINATIONS_KFV F,MTL_TRANSACTION_TYPES G
WHERE A.INVENTORY_ITEM_ID=B.INVENTORY_ITEM_ID(+) AND A.ORGANIZATION_ID=B.ORGANIZATION_ID(+) AND A.ORGANIZATION_ID=C.ORGANIZATION_ID AND A.TRANSACTION_TYPE_ID=G.TRANSACTION_TYPE_ID(+)
and a.transaction_id IN (7973373) -- 9979753    7835068    219226.85
--AND E.ACCOUNTING_CLASS_CODE = 'INVENTORY_VALUATION'
and  (nvl(e.ACCOUNTED_DR, 0) >  0.49  or nvl(e.ACCOUNTED_CR, 0) > 0.49)  -- sales qty 75881.38 
AND A.EVENT_ID=D.EVENT_ID AND D.AE_HEADER_ID=E.AE_HEADER_ID AND E.CODE_COMBINATION_ID=F.CODE_COMBINATION_ID
AND TO_CHAR(TRANSACTION_DATE,'MON-YY')=:P_PERIOD_CODE
AND A.LEDGER_ID=:P_LEDGER_ID AND A.ORGANIZATION_ID=NVL(:P_ORGANIZATION_ID,A.ORGANIZATION_ID) AND A.INVENTORY_ITEM_ID=NVL(:P_INVENTORY_ITEM_ID,A.INVENTORY_ITEM_ID)
) INV_TRANS
LEFT OUTER JOIN (SELECT MIC.INVENTORY_ITEM_ID,MIC.ORGANIZATION_ID,MC.SEGMENT1 MEJOR_FIN_CAT,
(case when MC.SEGMENT1 ='FINISHED GOODS' then '1' when MC.SEGMENT1 like '%WASTAGE%' then '2' when MC.SEGMENT1  like '%RAW MATERIALS%' then '3' when MC.SEGMENT1  like '%SPARES%' then '4' when MC.SEGMENT1 like '%LUBRICANTS%' then '5' else MC.SEGMENT1 end) MAJOR_FIN_CAT_1,
MC.SEGMENT1||'|'||MC.SEGMENT2 FIN_CAT
FROM MTL_ITEM_CATEGORIES MIC,MTL_CATEGORIES MC WHERE MIC.CATEGORY_ID=MC.CATEGORY_ID AND STRUCTURE_ID=50408) FIN_CAT
ON FIN_CAT.INVENTORY_ITEM_ID=INV_TRANS.INVENTORY_ITEM_ID AND FIN_CAT.ORGANIZATION_ID=INV_TRANS.ORGANIZATION_ID AND FIN_CAT.MEJOR_FIN_CAT= NVL(:P_MEJOR_FIN_CAT,FIN_CAT.MEJOR_FIN_CAT)
GROUP BY PERIOD_CODE,FIN_CAT.MEJOR_FIN_CAT, FIN_CAT.MAJOR_FIN_CAT_1, FIN_CAT.FIN_CAT,INV_TRANS.LEDGER_ID, INV_TRANS.COMPANY_NAME,INV_TRANS.ORGANIZATION_CODE,INV_TRANS.ORGANIZATION_ID,--INV_TRANS.TRANSACTION_ID,
INV_TRANS.INVENTORY_ITEM_ID,INV_TRANS.ITEM_CODE, INV_TRANS.Decode_1, INV_TRANS.ITEM_DESC, INV_TRANS.UOM,
INV_TRANS.EVENT_TYPE_CODE,INV_TRANS.TRANSACTION_TYPE_NAME,INV_TRANS.ACCOUNT_NAME,INV_TRANS.SUB_ACCOUNT,INV_TRANS.ACCOUNTING_CODE,
INV_TRANS.TRANSACTION_TYPE_ID,INV_TRANS.JE_CATEGORY_NAME,INV_TRANS.Customer,INV_TRANS.ACCOUNTING_CLASS_CODE, COMPANY, OPERATING_UNIT, COST_CENTER
ORDER BY ORGANIZATION_ID,INVENTORY_ITEM_ID--,CASE WHEN TRANSACTION_TYPE_NAME = 'OPENING VALUE' THEN 1 ELSE 2 END ---,ae_header_id
) X
WHERE (ACCOUNT_NAME IN ('Finished Goods','Raw Materials')
OR ACCOUNT_NAME LIKE ('Stores%Spares')
OR ACCOUNT_NAME LIKE ('Fuel%Lubricants')
OR ACCOUNT_NAME LIKE ('Bi Product%Wastage'))
AND ACCOUNTING_CLASS_CODE  IN ( 'INVENTORY_VALUATION', 'COST_VARIANCE')
--AND EVENT_TYPE_CODE='FOB_SHIP_SENDER_SHIP_TP'
AND EVENT_TYPE_CODE IN('SO_ISSUE','FOB_SHIP_SENDER_SHIP_TP', 'COGS_RECOGNITION_ADJ', 'RMA_RECEIPT')
AND X.JE_CATEGORY_NAME = NVL (:P_JE_CATEGORY_NAME, X.JE_CATEGORY_NAME)
AND X.Customer =NVL (:Customer, X.Customer)
and TRANSACTION_TYPE_ID <> 21
AND X.COST_CENTER = NVL(:P_COST_CENTER, X.COST_CENTER)
--AND to_date('01-'||period_code) BETWEEN '01-SEP-18' AND '30-SEP-18'
--and to_char(INV_TRANS.transaction_date,'MON-YY')=:P_PERIOD_CODE
GROUP BY X.Decode_1,X.PERIOD_CODE,X.LEDGER_ID, X.COMPANY_NAME, X.ORGANIZATION_CODE,X.MEJOR_FIN_CAT, X.MAJOR_FIN_CAT_1, X.FIN_CAT,X.ORGANIZATION_ID,--X.TRANSACTION_ID,
X.INVENTORY_ITEM_ID,X.ITEM_CODE, X.ITEM_DESC, X.UOM, X.EVENT_TYPE_CODE,X.TRANSACTION_TYPE_ID,
X.TRANSACTION_TYPE_NAME,X.ACCOUNT_NAME,X.SUB_ACCOUNT,X.OP_QTY, X.OP_VAL,
X.JE_CATEGORY_NAME,X.Customer,X.ACCOUNTING_CLASS_CODE, X.ACCOUNTING_CODE,X.COMPANY, X.OPERATING_UNIT, X.COST_CENTER
order by X.MAJOR_FIN_CAT_1


--==========================================
-- EBS COGS STATEMENT  FINAL   -- 22-MAR-2021
--==========================================

SELECT X.PERIOD_CODE,X.LEDGER_ID, X.COMPANY_NAME, X.COMPANY, X.OPERATING_UNIT, X.COST_CENTER,
X.ORGANIZATION_CODE,X.MEJOR_FIN_CAT, X.MAJOR_FIN_CAT_1, X.FIN_CAT,X.ORGANIZATION_ID,--X.TRANSACTION_ID,
X.INVENTORY_ITEM_ID,X.ITEM_CODE,X.Decode_1,X.ITEM_DESC, X.UOM  UOM_ACT, 
DECODE( X.UOM,'KG','MT', X.UOM )  UOM, 
X.EVENT_TYPE_CODE,X.TRANSACTION_TYPE_ID,
X.TRANSACTION_TYPE_NAME,X.ACCOUNT_NAME,X.SUB_ACCOUNT,X.OP_QTY, X.OP_VAL,
SUM(X.RCV_QTY) RCV_QTY, SUM(X.RCV_VAL) RCV_VAL, ABS(SUM(X.ISSUE_QTY)) ISSUE_QTY, ABS(SUM(X.ISSUE_VAL)) ISSUE_VAL, 
ABS(SUM(X.TRANS_QTY)) TRANS_QTY,
--TO_CHAR(DECODE ( X.UOM,'KG',ABS(SUM(X.TRANS_QTY))/1000,ABS(SUM(X.TRANS_QTY)) ),'99999990D99') T_QTY,
(CASE WHEN X.Customer = 'OMSP' THEN TO_CHAR(DECODE ( X.UOM,'KG',ABS(SUM(X.TRANS_QTY))/1000,ABS(SUM(X.TRANS_QTY)) ),'99999990D99')  * - 1 ELSE TO_NUMBER(TO_CHAR(DECODE ( X.UOM,'KG',ABS(SUM(X.TRANS_QTY))/1000,ABS(SUM(X.TRANS_QTY)) ),'99999990D99')) END ) T_QTY,
ABS(SUM(X.TRANS_VAL))/DECODE ( X.UOM,'KG',ABS(SUM(X.ISSUE_QTY))/1000,ABS(SUM(X.ISSUE_QTY)) ) RATE,
--TO_CHAR(ABS(SUM(X.TRANS_QTY)),'99999990D99') t_qty,  TRANS_VAL div ISSUE_QTY
 (CASE when X.Customer = 'OMSP' and EVENT_TYPE_CODE = 'RMA_RECEIPT' then  ABS(SUM(X.ISSUE_VAL)) * - 1
     WHEN X.Customer = 'OMSP' THEN ABS(SUM(X.TRANS_VAL)) * - 1 ELSE ABS(SUM(X.TRANS_VAL)) END ) TRANS_VAL,
X.JE_CATEGORY_NAME,X.Customer,X.ACCOUNTING_CLASS_CODE, SUM(X.DR) DR, SUM(X.CR) CR ,X.ACCOUNTING_CODE
FROM
(
SELECT INV_TRANS.PERIOD_CODE,INV_TRANS.LEDGER_ID, INV_TRANS.COMPANY_NAME, INV_TRANS.COMPANY, INV_TRANS.OPERATING_UNIT, INV_TRANS.COST_CENTER, 
INV_TRANS.ORGANIZATION_CODE,FIN_CAT.MEJOR_FIN_CAT, FIN_CAT.MAJOR_FIN_CAT_1, FIN_CAT.FIN_CAT,INV_TRANS.ORGANIZATION_ID,--INV_TRANS.TRANSACTION_ID,
INV_TRANS.INVENTORY_ITEM_ID,INV_TRANS.ITEM_CODE, INV_TRANS.Decode_1, INV_TRANS.ITEM_DESC, INV_TRANS.UOM, INV_TRANS.EVENT_TYPE_CODE,INV_TRANS.TRANSACTION_TYPE_ID,
CASE WHEN INV_TRANS.TRANSACTION_TYPE_ID=-99 THEN INV_TRANS.EVENT_TYPE_CODE ELSE INV_TRANS.TRANSACTION_TYPE_NAME END TRANSACTION_TYPE_NAME,
INV_TRANS.ACCOUNT_NAME,INV_TRANS.SUB_ACCOUNT,
0 OP_QTY, 0 OP_VAL,
SUM(CASE WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (17,12,44,18,61,1002,1003) THEN INV_TRANS.TRANSACTION_QUANTITY ELSE 0 END) RCV_QTY,
SUM(CASE WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (17,18,1002,1003) THEN INV_TRANS.TRANSACTION_VALUE
WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (44) THEN INV_TRANS.TRANSACTION_VALUE -----INV_TRANS.ACCOUNTED_DR
WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (61) THEN INV_TRANS.ACCOUNTED_DR
WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (12) THEN INV_TRANS.ACCOUNTED_DR
WHEN NVL(INV_TRANS.TRANSACTION_TYPE_ID,11111)=11111 AND EVENT_TYPE_CODE = 'GLCOSTALOC' THEN INV_TRANS.TRANSACTION_VALUE
WHEN NVL(INV_TRANS.TRANSACTION_TYPE_ID,2222)=2222 AND EVENT_TYPE_CODE = 'LC_ADJUST_VALUATION' THEN INV_TRANS.TRANSACTION_VALUE
WHEN INV_TRANS.TRANSACTION_TYPE_ID=-99 THEN INV_TRANS.TRANSACTION_VALUE ELSE 0 END) RCV_VAL,
SUM(CASE WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (32,33,35,36,42,43,15,21,63,62,101,103,104,107,111,120,10008,140,71,200,260,261,52) THEN INV_TRANS.TRANSACTION_QUANTITY ELSE 0 END) ISSUE_QTY,
SUM(CASE WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (32,33,35,36,42,43,21,63,62,101,103,104,107,111,120,10008,140,71,200,260,261,52) THEN INV_TRANS.TRANSACTION_VALUE
WHEN INV_TRANS.TRANSACTION_TYPE_ID IN (15) THEN INV_TRANS.ACCOUNTED_DR ELSE 0 END) ISSUE_VAL,
SUM(NVL(INV_TRANS.TRANSACTION_QUANTITY,0)) TRANS_QTY,
SUM(NVL(INV_TRANS.TRANSACTION_VALUE,0)) TRANS_VAL,
INV_TRANS.JE_CATEGORY_NAME,INV_TRANS.Customer,INV_TRANS.ACCOUNTING_CLASS_CODE,
SUM(INV_TRANS.ACCOUNTED_DR) DR,SUM(INV_TRANS.ACCOUNTED_CR) CR ,INV_TRANS.ACCOUNTING_CODE
FROM
(
SELECT TO_CHAR(TRANSACTION_DATE,'MON-YY') PERIOD_CODE, A.LEDGER_ID, (SELECT DISTINCT BAL_SEG_NAME FROM XX_INV_ORG_VW WHERE LEDGER_ID=A.LEDGER_ID) COMPANY_NAME,
C.ORGANIZATION_CODE,A.ORGANIZATION_ID,
XX_GET_ACCT_FLEX_SEG_DESC (1, F.SEGMENT1) COMPANY,
XX_GET_ACCT_FLEX_SEG_DESC (2, F.SEGMENT2) OPERATING_UNIT,
XX_GET_ACCT_FLEX_SEG_DESC (3, F.SEGMENT3) COST_CENTER,
--(SELECT DISTINCT XX_GET_ACCT_FLEX_SEG_DESC (3, SEGMENT3) COST_CENTER FROM GL_CODE_COMBINATIONS_KFV WHERE CODE_COMBINATION_ID=E.CODE_COMBINATION_ID) COST_CENTER,
A.INVENTORY_ITEM_ID,B.SEGMENT1||'|'||B.SEGMENT2||'|'||B.SEGMENT3||'|'||B.SEGMENT4 ITEM_CODE,
(case when B.SEGMENT1='FG' then '1' when B.SEGMENT1='CP' then '2' when B.SEGMENT1='BP' then '3' when B.SEGMENT1='RM' then '4' when B.SEGMENT1='SP' then '5' when B.SEGMENT1='PS' then '6' when B.SEGMENT1='CV' then '7' else B.SEGMENT1 end) Decode_1,   
(SELECT DESCRIPTION FROM MTL_SYSTEM_ITEMS_B WHERE INVENTORY_ITEM_ID=A.INVENTORY_ITEM_ID AND ORGANIZATION_ID=A.ORGANIZATION_ID) ITEM_DESC,
(SELECT PRIMARY_UOM_CODE FROM MTL_SYSTEM_ITEMS_B WHERE INVENTORY_ITEM_ID=A.INVENTORY_ITEM_ID AND ORGANIZATION_ID=A.ORGANIZATION_ID) UOM,
A.EVENT_CLASS_CODE,A.EVENT_TYPE_CODE, --a.transaction_id,
G.TRANSACTION_TYPE_ID,G.TRANSACTION_TYPE_NAME,
D.JE_CATEGORY_NAME,E.ACCOUNTING_CLASS_CODE,D.AE_HEADER_ID,XX_AP_PKG.GET_ACCOUNT_DESC_FROM_CCID (E.CODE_COMBINATION_ID) ACCOUNT_NAME,
(case when D.JE_CATEGORY_NAME='INTE' then 'Internal'  when D.JE_CATEGORY_NAME='SHIP' then 'External' else D.JE_CATEGORY_NAME end ) Customer,
XX_AP_PKG.GET_SUB_ACCOUNT_DESC_FROM_CCID(TO_NUMBER(E.CODE_COMBINATION_ID)) SUB_ACCOUNT,
TRANSACTION_QUANTITY,TRANSACTION_VALUE,E.ACCOUNTED_DR,E.ACCOUNTED_CR,F.CONCATENATED_SEGMENTS ACCOUNTING_CODE
FROM GMF_XLA_EXTRACT_HEADERS A,MTL_SYSTEM_ITEMS_B B,ORG_ORGANIZATION_DEFINITIONS C,XLA_AE_HEADERS D,XLA_AE_LINES E,GL_CODE_COMBINATIONS_KFV F,MTL_TRANSACTION_TYPES G
WHERE A.INVENTORY_ITEM_ID=B.INVENTORY_ITEM_ID(+) AND A.ORGANIZATION_ID=B.ORGANIZATION_ID(+) AND A.ORGANIZATION_ID=C.ORGANIZATION_ID AND A.TRANSACTION_TYPE_ID=G.TRANSACTION_TYPE_ID(+)
--and a.transaction_id IN (6376559) -- 219226.85
--AND E.ACCOUNTING_CLASS_CODE = 'INVENTORY_VALUATION'
and  (nvl(e.ACCOUNTED_DR, 0) >  0.49  or nvl(e.ACCOUNTED_CR, 0) > 0.49)  
AND A.EVENT_ID=D.EVENT_ID AND D.AE_HEADER_ID=E.AE_HEADER_ID AND E.CODE_COMBINATION_ID=F.CODE_COMBINATION_ID
AND TO_CHAR(TRANSACTION_DATE,'MON-YY')=:P_PERIOD_CODE
AND A.LEDGER_ID=:P_LEDGER_ID AND A.ORGANIZATION_ID=NVL(:P_ORGANIZATION_ID,A.ORGANIZATION_ID) AND A.INVENTORY_ITEM_ID=NVL(:P_INVENTORY_ITEM_ID,A.INVENTORY_ITEM_ID)
) INV_TRANS
LEFT OUTER JOIN (SELECT MIC.INVENTORY_ITEM_ID,MIC.ORGANIZATION_ID,MC.SEGMENT1 MEJOR_FIN_CAT,
(case when MC.SEGMENT1 ='FINISHED GOODS' then '1' when MC.SEGMENT1 like '%WASTAGE%' then '2' when MC.SEGMENT1  like '%RAW MATERIALS%' then '3' when MC.SEGMENT1  like '%SPARES%' then '4' when MC.SEGMENT1 like '%LUBRICANTS%' then '5' else MC.SEGMENT1 end) MAJOR_FIN_CAT_1,
MC.SEGMENT1||'|'||MC.SEGMENT2 FIN_CAT
FROM MTL_ITEM_CATEGORIES MIC,MTL_CATEGORIES MC WHERE MIC.CATEGORY_ID=MC.CATEGORY_ID AND STRUCTURE_ID=50408) FIN_CAT
ON FIN_CAT.INVENTORY_ITEM_ID=INV_TRANS.INVENTORY_ITEM_ID AND FIN_CAT.ORGANIZATION_ID=INV_TRANS.ORGANIZATION_ID AND FIN_CAT.MEJOR_FIN_CAT= NVL(:P_MEJOR_FIN_CAT,FIN_CAT.MEJOR_FIN_CAT)
GROUP BY PERIOD_CODE,FIN_CAT.MEJOR_FIN_CAT, FIN_CAT.MAJOR_FIN_CAT_1, FIN_CAT.FIN_CAT,INV_TRANS.LEDGER_ID, INV_TRANS.COMPANY_NAME,INV_TRANS.ORGANIZATION_CODE,INV_TRANS.ORGANIZATION_ID,--INV_TRANS.TRANSACTION_ID,
INV_TRANS.INVENTORY_ITEM_ID,INV_TRANS.ITEM_CODE, INV_TRANS.Decode_1, INV_TRANS.ITEM_DESC, INV_TRANS.UOM,
INV_TRANS.EVENT_TYPE_CODE,INV_TRANS.TRANSACTION_TYPE_NAME,INV_TRANS.ACCOUNT_NAME,INV_TRANS.SUB_ACCOUNT,INV_TRANS.ACCOUNTING_CODE,
INV_TRANS.TRANSACTION_TYPE_ID,INV_TRANS.JE_CATEGORY_NAME,INV_TRANS.Customer,INV_TRANS.ACCOUNTING_CLASS_CODE, COMPANY, OPERATING_UNIT, COST_CENTER
ORDER BY ORGANIZATION_ID,INVENTORY_ITEM_ID--,CASE WHEN TRANSACTION_TYPE_NAME = 'OPENING VALUE' THEN 1 ELSE 2 END ---,ae_header_id
) X
WHERE (ACCOUNT_NAME IN ('Finished Goods','Raw Materials')
OR ACCOUNT_NAME LIKE ('Stores%Spares')
OR ACCOUNT_NAME LIKE ('Fuel%Lubricants')
OR ACCOUNT_NAME LIKE ('Bi Product%Wastage'))
AND ACCOUNTING_CLASS_CODE  IN ( 'INVENTORY_VALUATION', 'COST_VARIANCE')
--AND EVENT_TYPE_CODE='FOB_SHIP_SENDER_SHIP_TP'
AND EVENT_TYPE_CODE IN('SO_ISSUE','FOB_SHIP_SENDER_SHIP_TP', 'COGS_RECOGNITION_ADJ', 'RMA_RECEIPT')
AND X.JE_CATEGORY_NAME = NVL (:P_JE_CATEGORY_NAME, X.JE_CATEGORY_NAME)
AND X.Customer =NVL (:Customer, X.Customer)
and TRANSACTION_TYPE_ID <> 21
AND X.COST_CENTER = NVL(:P_COST_CENTER, X.COST_CENTER)
--AND to_date('01-'||period_code) BETWEEN '01-SEP-18' AND '30-SEP-18'
--and to_char(INV_TRANS.transaction_date,'MON-YY')=:P_PERIOD_CODE
GROUP BY X.Decode_1,X.PERIOD_CODE,X.LEDGER_ID, X.COMPANY_NAME, X.ORGANIZATION_CODE,X.MEJOR_FIN_CAT, X.MAJOR_FIN_CAT_1, X.FIN_CAT,X.ORGANIZATION_ID,--X.TRANSACTION_ID,
X.INVENTORY_ITEM_ID,X.ITEM_CODE, X.ITEM_DESC, X.UOM, X.EVENT_TYPE_CODE,X.TRANSACTION_TYPE_ID,
X.TRANSACTION_TYPE_NAME,X.ACCOUNT_NAME,X.SUB_ACCOUNT,X.OP_QTY, X.OP_VAL,
X.JE_CATEGORY_NAME,X.Customer,X.ACCOUNTING_CLASS_CODE, X.ACCOUNTING_CODE,X.COMPANY, X.OPERATING_UNIT, X.COST_CENTER
order by X.MAJOR_FIN_CAT_1