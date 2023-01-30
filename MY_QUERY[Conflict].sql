SELECT * FROM HR_OPERATING_UNITS

-- DETAILS (TO FIEND OUT ALL INCOMPLETE, INPROCESS, APPROVED REQUISITION OF KOBIR GROUP)

SELECT   
        prha.org_id,    
        prha.segment1 req_num,
        prla.ITEM_DESCRIPTION,   
        pah.creation_date,
        prha.approved_date,
        prha.created_by,
        prha.authorization_status Approval_status,
        papf.full_name hr_full_name,
        papf.employee_number emp_no
    FROM po.po_action_history pah,
        po.po_requisition_headers_all prha,
        po.po_requisition_lines_all prla,
        applsys.fnd_user fu,
        hr.per_all_people_f papf,
        hr.per_all_assignments_f paaf,
        hr.per_jobs pj
   WHERE object_id = prha.requisition_header_id
     AND prha.requisition_header_id = prla.requisition_header_id
     AND pah.employee_id = fu.employee_id
     AND fu.employee_id = papf.person_id
     AND papf.person_id = paaf.person_id
     AND paaf.job_id = pj.job_id
     AND paaf.primary_flag = 'Y'
     AND SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date
     AND SYSDATE BETWEEN paaf.effective_start_date AND paaf.effective_end_date
     AND pah.object_type_code = 'REQUISITION'
   -- AND prha.authorization_status = 'APPROVED'   
   -- AND pah.creation_date BETWEEN  '01-JAN-2017'  and '30-AUG-2017'
   --  AND papf.full_name =  'Md. Reaz Uddin, KG-3004'     
ORDER BY pah.creation_date desc;



--SUMMARY---(TO FIEND OUT ALL INCOMPLETE, INPROCESS, APPROVED REQUISITION OF KOBIR GROUP)

SELECT   
        prha.org_id, 
        prha.segment1 req_num,    
        pah.creation_date,
        prha.approved_date,
        prha.authorization_status Approval_status,
        papf.full_name hr_full_name,
        papf.employee_number emp_no,
        pj.NAME job
    FROM po.po_action_history pah,
        po.po_requisition_headers_all prha,
        applsys.fnd_user fu,
        hr.per_all_people_f papf,
        hr.per_all_assignments_f paaf,
        hr.per_jobs pj
   WHERE object_id = prha.requisition_header_id
     AND pah.employee_id = fu.employee_id
     AND fu.employee_id = papf.person_id
     AND papf.person_id = paaf.person_id
     AND paaf.job_id = pj.job_id
     AND paaf.primary_flag = 'Y'
     AND SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date
     AND SYSDATE BETWEEN paaf.effective_start_date AND paaf.effective_end_date
     AND pah.object_type_code = 'REQUISITION'
    --AND prha.authorization_status = 'APPROVED'
    AND pah.creation_date BETWEEN  '01-JAN-2017'  and '30-AUG-2017'
     --AND papf.full_name =  'Md. Reaz Uddin, KG-3004'  
   -- AND papf.full_name like '%KOKAN%'    
ORDER BY pah.creation_date desc;



--========================================================== FIEND PO AND ORG in  ====================================================================

-- FIEND PO AND  INVENTORY ORG 

SELECT poh.po_header_id,poh.ORG_ID,APPS.XX_GET_HR_OPERATING_UNIT (poh.ORG_ID) OU_Name,poh.SEGMENT1 PO_NUMBER, poh.PO_HEADER_ID,pod.DESTINATION_ORGANIZATION_ID INV_ID,ood.ORGANIZATION_CODE INV_NAME
FROM   po_headers_all poh, po_lines_all pol,po_distributions_all pod, PO_LINE_LOCATIONS_ALL PLL, org_organization_definitions ood --, org_organization_definitions ood
WHERE  poh.po_header_id = pol.po_header_id
AND    poh.po_header_id = pod.po_header_id
AND    poh.po_header_id = pll.po_header_id
AND    pol.po_line_id = pll.po_line_id
AND    ood.organization_id = pll.ship_to_organization_id 
AND    pol.po_header_id = pod.po_header_id
AND    pol.po_line_id = pod.po_line_id 
AND     poh.ORG_ID = 103
--AND    poh.org_id = ood.OPERATING_UNIT 
AND    poh.segment1 = '40000021'  --'40000120'




--Find Name through KG-ID
select * from per_all_people_f
where FULL_NAME like '%KG-4079%';

--============================================================================ 


 
-----list all Purchase Requisition without a Purchase Order that means  a PR has not been autocreated to PO.  
 
 select   
  prh.segment1 "PR NUM",   
  trunc(prh.creation_date) "CREATED ON",   
  trunc(prl.creation_date) "Line Creation Date" ,  
  prl.line_num "Seq #",   
  msi.segment1 "Item Num",   
  prl.item_description "Description",   
  prl.quantity "Qty",   
  trunc(prl.need_by_date) "Required By",   
  ppf1.full_name "REQUESTOR",   
  ppf2.agent_name "BUYER"   
  from   
  po.po_requisition_headers_all prh,  
  po.po_requisition_lines_all prl,   
  apps.per_people_f ppf1,   
  (select distinct agent_id,agent_name from apps.po_agents_v ) ppf2,   
  po.po_req_distributions_all prd,   
  inv.mtl_system_items_b msi,   
  po.po_line_locations_all pll,   
  po.po_lines_all pl,   
  po.po_headers_all ph  
  WHERE   
  prh.requisition_header_id = prl.requisition_header_id   
  and prl.requisition_line_id = prd.requisition_line_id   
  and ppf1.person_id = prh.preparer_id   
  and prh.creation_date between ppf1.effective_start_date and ppf1.effective_end_date   
  and ppf2.agent_id(+) = msi.buyer_id   
  and msi.inventory_item_id = prl.item_id   
  and msi.organization_id = prl.destination_organization_id   
  and pll.line_location_id(+) = prl.line_location_id   
  and pll.po_header_id = ph.po_header_id(+)   
  AND PLL.PO_LINE_ID = PL.PO_LINE_ID(+)   
  AND PRH.AUTHORIZATION_STATUS = 'APPROVED'   
  AND PLL.LINE_LOCATION_ID IS NULL   
  AND PRL.CLOSED_CODE IS NULL   
  AND NVL(PRL.CANCEL_FLAG,'N') <> 'Y'  
  ORDER BY 1,2  
  




--==========================================================
-- Process for fiend requisition amd PO and Inventoy org  item details
--==========================================================


  
  --========================================
  -- INCOMPLETE QUERY 26-aug-2017
  --==========================================
  SELECT * FROM po_requisition_headers_all 
where segment1 = '10000204';

    
    select * FROM PO_REQUISITION_HEADERS_ALL
    WHERE REQUISITION_HEADER_ID = '17001'
    
        select * FROM PO_REQUISITION_LINES_ALL
    WHERE REQUISITION_HEADER_ID = '17001'
    
    
    SELECT * FROM PO_HEADERS_ALL
    WHERE segment1 = '40000021'
    --AND ORG_ID = '103'
 --   

SELECT prh.requisition_header_id,
        pha.po_header_id,
        prh.segment1 requisition_num, 
        pha.segment1 po_no,
        (select name from hr_all_organization_units where organization_id=prl.DESTINATION_ORGANIZATION_ID) dest_org_name,         
       to_char(prh.creation_date,'DD-MON-RRRR HH12:MI:SS PM') creation_dt,
       to_char(prh.APPROVED_DATE,'DD-MON-RRRR HH12:MI:SS PM')  APPROVED_DATE,         
        pla.quantity po_qty,
       prh.attribute15 Priority,
       prl.reference_num move_order_no,
       prh.preparer_id,
       prl.TO_PERSON_ID,
       ppf.full_name,
       prh.attribute1 BUDGET_NO,
       prl.item_id,
       to_char(trunc(prl.NEED_BY_DATE),'DD-MON-RRRR') NEED_BY_DATE,
       paaf.job_id,
       pj.NAME,
       pj.job_definition_id,
      -- pjd.segment1 department,
       HRO.ORGANIZATION_CODE ORG_CODE,
       PRH.TYPE_LOOKUP_CODE REQ_TYPE,
     --  substr(XX_GET_HR_OPERATING_UNIT(:p_org_id),5) ORG_HEADER_NAME,  --new
      -- XX_com_pkg.get_hr_operating_unit(:p_org_id) Org_header_name,   --old
      -- XX_COM_PKG.GET_UNIT_address(:p_org_id) org_header_address,     --old
       PRL.DESTINATION_SUBINVENTORY WAREHOUSE,
       --xx_inv_org_name_fn(prl.destination_organization_id) dest_loc,      --old
        --xx_inv_org_name_fn(prl.source_organization_id) source_loc,        --old
--        substr(GET_ORGANIZATION_NAME(prl.org_id),5) REQ_ORG_NAME,     --old
--    GET_UNIT_ADDRESS(prl.org_id) REQ_ORG_ADDRESS,     --old
          (select location_code from hr_locations_all where location_id=prl.DELIVER_TO_LOCATION_ID) dest_location,
    TO_CHAR (TRUNC (prh.APPROVED_DATE),'DD-MON-RRRR') APPROVED_DATE,
       NVL(PRL.CANCEL_FLAG,'N') CANCEL_FLAG, 
       DECODE(PRL.CLOSED_CODE,NULL,'N','Y') CLOSED_FLAG,
       HRL.DESCRIPTION LOC,
       PRL.JUSTIFICATION 
  FROM po_requisition_headers_all prh,
       po_requisition_lines_all prl,
       mtl_units_of_measure_tl muom,
       per_people_f ppf,
       per_all_assignments_f paaf,
       per_jobs pj,
       per_job_definitions pjd,
       ORG_ORGANIZATION_DEFINITIONS HRO,
       HR_LOCATIONS_ALL HRL,
      HR_LOCATIONS_ALL HRL1,
       (SELECT organization_id,inventory_item_id, description,
                        (segment1 || '.' || segment2 || '.' || segment3
                        ) item_code
                   FROM mtl_system_items_b) mst,
        hr_operating_units HOU,
        po_headers_all pha,
        po_lines_all pla,   
        po_distributions_all pda,  
        po_req_distributions_all prda          
 WHERE pha.po_header_id = pda.po_header_id   
    AND pda.req_distribution_id = prda.distribution_id   
    AND prda.requisition_line_id = prl.requisition_line_id  
    AND prh.requisition_header_id = prl.requisition_header_id
    AND pla.po_line_id=pda.po_line_id
    AND SYSDATE BETWEEN paaf.effective_start_date AND paaf.effective_end_date
    AND SYSDATE BETWEEN ppf.effective_start_date AND ppf.effective_end_date
    AND prh.preparer_id = ppf.person_id
    AND prh.preparer_id = paaf.person_id
    AND HRL.LOCATION_ID=prl.DELIVER_TO_LOCATION_ID
    AND HRL1.LOCATION_ID=PAAF.LOCATION_ID
    AND ppf.person_id = paaf.person_id
    AND paaf.job_id(+) = pj.job_id
    AND pj.job_definition_id(+) = pjd.job_definition_id
    AND NVL(PRL.MODIFIED_BY_AGENT_FLAG,'N')<>'Y'
    AND PRL.unit_meas_lookup_code=MUOM.UNIT_OF_MEASURE(+)
    AND HRO.OPERATING_UNIT=HOU.ORGANIZATION_ID 
    AND prl.item_id = mst.inventory_item_id
    AND PRL.DESTINATION_ORGANIZATION_ID=MST.ORGANIZATION_ID  
    AND prl.DESTINATION_ORGANIZATION_ID=hro.ORGANIZATION_ID
 --  AND PHA.ORG_ID = '104' 
  AND PRH.segment1 = '10000001'  --'10000027'--'10000204'
   -- AND pha.segment1 = '40000021'    --'40000187'
    
--=========================================================================================
--TO GET THE RESPONSIBILITY OF A USER: KG-4079
--==========================================================================================

SELECT distinct u.user_id, u.user_name user_name,
r.responsibility_name responsiblity,
a.application_name application
FROM fnd_user u,
fnd_user_resp_groups g,
fnd_application_tl a,
fnd_responsibility_tl r
WHERE g.user_id(+) = u.user_id
AND g.responsibility_application_id = a.application_id
AND a.application_id = r.application_id
AND g.responsibility_id = r.responsibility_id
AND u.user_name ='KG-4079'
order by 1;



--===========================================================
-- Get Request Group associate with Responsibility Name
--===========================================================
SELECT responsibility_name responsibility, request_group_name,
frg.description
FROM fnd_request_groups frg, fnd_responsibility_vl frv
WHERE frv.request_group_id = frg.request_group_id
ORDER BY responsibility_name


--=================================================
--Gets Form personalization listing
--==================================================

SELECT ffft.user_function_name UserFormName, ffcr.SEQUENCE,
ffcr.description, ffcr.rule_type, ffcr.enabled, ffcr.trigger_event,
ffcr.trigger_object, ffcr.condition, ffcr.fire_in_enter_query
FROM fnd_form_custom_rules ffcr, fnd_form_functions_vl ffft
WHERE ffcr.ID = ffft.function_id
ORDER BY 1;

--========================================================
--Query to view the patch level status of all modules
--========================================================

SELECT a.application_name,
DECODE (b.status, 'I', 'Installed', 'S', 'Shared', 'N/A') status,
patch_level
FROM apps.fnd_application_vl a, apps.fnd_product_installations b
WHERE a.application_id = b.application_id;

--========================================================

 --SQL to view all request who have attached to a responsibility
--========================================================

 SELECT responsibility_name , frg.request_group_name,
fcpv.user_concurrent_program_name, fcpv.description
FROM fnd_request_groups frg,
fnd_request_group_units frgu,
fnd_concurrent_programs_vl fcpv,
fnd_responsibility_vl frv
WHERE frgu.request_unit_type = 'P'
AND frgu.request_group_id = frg.request_group_id
AND frgu.request_unit_id = fcpv.concurrent_program_id
AND frv.request_group_id = frg.request_group_id
--AND frg.request_group_name like '%%'--'%XX%'    --'%PUR%' , All Reports, 'AX General Ledger', 'AX Inventory Supervisor', 'OM Concurrent Programs'
ORDER BY responsibility_name;


--==========================================================

--==========================================================

 Query 9: SQL to view all types of request Application wise
SELECT fa.application_short_name,
fcpv.user_concurrent_program_name,
description,
DECODE (fcpv.execution_method_code,
‘B’, ‘Request Set Stage Function’,
‘Q’, ‘SQL*Plus’,
‘H’, ‘Host’,
‘L’, ‘SQL*Loader’,
‘A’, ‘Spawned’,
‘I’, ‘PL/SQL Stored Procedure’,
‘P’, ‘Oracle Reports’,
‘S’, ‘Immediate’,
fcpv.execution_method_code
) exe_method,
output_file_type, program_type, printer_name,
minimum_width,
minimum_length, concurrent_program_name,
concurrent_program_id
FROM fnd_concurrent_programs_vl fcpv, fnd_application fa
WHERE fcpv.application_id = fa.application_id
ORDER BY description

--============================================

SELECT DISTINCT rha.segment1,pha.segment1
FROM po_requisition_headers_all rha,po_requisition_lines_all rla,
po_req_distributions_all rda,po_distributions_all pda,po_headers_all pha
WHERE 1=1
AND rha.requisition_header_id=rla.requisition_header_id
AND rla.requisition_line_id=rda.requisition_line_id
AND rda.distribution_id=pda.req_distribution_id
AND pda.po_header_id=pha.po_header_id
--AND pha.segment1=:P_PO_NUMBER;


--==============================================================
--Queries to know Responsibility for Concurrent Program and Request Set
--=============================================================

SELECT Responsibility_Name,
Responsibility_Key,
User_Concurrent_Program_Name
FROM fnd_responsibility_tl a,
fnd_responsibility c,
fnd_request_group_units d,
fnd_concurrent_programs_tl b
WHERE a.responsibility_id = c.responsibility_id
AND c.request_group_id = d.request_group_id
AND b.concurrent_program_id = d.request_unit_id
--AND b.User_Concurrent_Program_Name like ‘Give User Concurrent Program Name’

--=========================================================

SELECT 
POH.PO_HEADER_ID,XX_GET_HR_OPERATING_UNIT(POH.ORG_ID) OPERATING_UNIT,POH.ORG_ID, POH.SEGMENT1,POH.CREATION_DATE,POH.APPROVED_DATE,
POL.ITEM_DESCRIPTION,
POL.UNIT_MEAS_LOOKUP_CODE
FROM PO_HEADERS_ALL POH,PO_LINES_ALL POL
WHERE POH.PO_HEADER_ID = POL.PO_HEADER_ID
AND POH.ORG_ID = nvl(:P_ORG_ID,POH.ORG_ID)
AND POH.SEGMENT1 = nvl(:P_SEGMENT1,POH.SEGMENT1)



 
 /* =============================
 Planned  Requisition For UAT Date:12-DEC-2017 By Sohel Hossain
 ===============================*/

SELECT prh.requisition_header_id,
        prh.segment1 requisition_num, 
        note_to_agent,
        prh.requisition_header_id header_id,
        prh.creation_date CR_DT, 
        prl.line_num,
        prh.DESCRIPTION PR_DESC, 
        prh.ATTRIBUTE_CATEGORY,
        prh.ATTRIBUTE1 Start_date,
         prh.ATTRIBUTE2 End_date,
       to_char(prh.creation_date,'DD-MON-RRRR HH12:MI:SS PM') creation_dt,
       to_char(prh.APPROVED_DATE,'DD-MON-RRRR HH12:MI:SS PM')  APPROVED_DATE,
       prl.ATTRIBUTE1 Brand, 
       prl.ATTRIBUTE2 Origin,
       prl.ATTRIBUTE9 Department,
       prh.attribute15 Priority,
       prl.reference_num move_order_no,
      (select mtrl.quantity from mtl_txn_request_lines mtrl,mtl_txn_request_headers mtrh where mtrh.header_id=mtrl.header_id and mtrl.inventory_item_id=prl.item_id and mtrh.request_number=prl.reference_num ) move_order_qty,
      (select b.description from fnd_flex_value_sets a, fnd_flex_values_vl b where  a.flex_value_set_id = b.flex_value_set_id and a.flex_value_set_name = 'XX_PROJECT' and b.flex_value=prh.attribute1) Project_Name,
       nvl(prh.authorization_status,'INCOMPLETE') req_status,
       prl.SUGGESTED_BUYER_ID,
       prh.preparer_id,
       prl.TO_PERSON_ID,
       ppf.full_name,
       prh.attribute1 BUDGET_NO,
       prl.item_id,
       mst.item_code,
       mst.description,
       prl.QUANTITY Unit,
       XX_30_DAYS_CONSUM_FN(NVL(PRH.APPROVED_DATE,prh.creation_date),PRL.ITEM_ID,DESTINATION_ORGANIZATION_ID) CONSUM_QTY,
       xx_pend_req_qty_fn(PRL.PO_LINE_ID) PENDING_QTY,
       xx_last_po_info_fn(4,PRL.ITEM_ID,PRH.ORG_ID,prh.creation_date) LPO,
       xx_last_po_info_fn(1,PRL.ITEM_ID,PRH.ORG_ID,prh.creation_date) LPD,
        xx_last_po_info_fn(2,PRL.ITEM_ID,PRH.ORG_ID,prh.creation_date) LPR,
         xx_last_po_info_fn(3,PRL.ITEM_ID,PRH.ORG_ID,prh.creation_date) LP_SUPP,
       MUOM.UOM_CODE UOM,
       HRL1.LOCATION_CODE,
       to_char(trunc(prl.NEED_BY_DATE),'DD-MON-RRRR') NEED_BY_DATE,
       paaf.job_id,
       pj.NAME,
       pj.job_definition_id,
       (SELECT USE_AREA FROM XXKSRM_INV_USE_AREA_V IUA WHERE IUA.USE_AREA_ID=prL.ATTRIBUTE3) Use_of_Area,
       prl.NOTE_TO_RECEIVER,
       prl.DESTINATION_ORGANIZATION_ID,
       HRO.ORGANIZATION_CODE ORG_CODE,
       PRH.TYPE_LOOKUP_CODE REQ_TYPE,
       substr(XX_GET_HR_OPERATING_UNIT(:p_org_id),5) ORG_HEADER_NAME,
       PRL.DESTINATION_SUBINVENTORY WAREHOUSE,
    (select name from hr_all_organization_units where organization_id=prl.DESTINATION_ORGANIZATION_ID)||' - '||HRO.ORGANIZATION_CODE dest_org_name   ,    
          (select location_code from hr_locations_all where location_id=prl.DELIVER_TO_LOCATION_ID) dest_location,
    TO_CHAR (TRUNC (prh.APPROVED_DATE),'DD-MON-RRRR') APPROVED_DATE,
       NVL(PRL.CANCEL_FLAG,'N') CANCEL_FLAG, 
       DECODE(PRL.CLOSED_CODE,NULL,'N','Y') CLOSED_FLAG,
       HRL.DESCRIPTION LOC,
       PRL.JUSTIFICATION 
  FROM po_requisition_headers_all prh,
       po_requisition_lines_all prl,
       mtl_units_of_measure_tl muom,
       per_people_f ppf,
       per_all_assignments_f paaf,
       per_jobs pj,
       per_job_definitions pjd,
       ORG_ORGANIZATION_DEFINITIONS HRO,
       HR_LOCATIONS_ALL HRL,
      HR_LOCATIONS_ALL HRL1,
       (SELECT organization_id,inventory_item_id, description,
                        (segment1 || '.' || segment2 || '.' || segment3 || '.' || segment4
                        ) item_code
                   FROM mtl_system_items_b) mst,
        hr_operating_units HOU           
 WHERE prh.requisition_header_id = prl.requisition_header_id
   AND SYSDATE BETWEEN paaf.effective_start_date AND paaf.effective_end_date
   AND SYSDATE BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND prh.preparer_id = ppf.person_id
   AND prh.preparer_id = paaf.person_id
  AND HRL.LOCATION_ID=DELIVER_TO_LOCATION_ID
  AND HRL1.LOCATION_ID=PAAF.LOCATION_ID
   AND ppf.person_id = paaf.person_id
   AND paaf.job_id(+) = pj.job_id
   AND pj.job_definition_id(+) = pjd.job_definition_id
   AND NVL(PRL.MODIFIED_BY_AGENT_FLAG,'N')<>'Y'
  AND PRL.unit_meas_lookup_code=MUOM.UNIT_OF_MEASURE(+)
  AND HRO.OPERATING_UNIT=HOU.ORGANIZATION_ID 
   AND prl.item_id = mst.inventory_item_id
   AND PRL.DESTINATION_ORGANIZATION_ID=MST.ORGANIZATION_ID  
   and prl.DESTINATION_ORGANIZATION_ID=hro.ORGANIZATION_ID
 AND prh.ORG_ID = nvl(:p_ORG_ID,prh.org_id)
 AND NVL2(:P_REQ_NO,prh.requisition_header_id,-1) between NVL(:P_REQ_NO,-1) and NVL(:P_REQ_NO_T,-1) 
 AND nvl(PRL.ATTRIBUTE9,'x')=nvl(:P_DEPT,nvl(PRL.ATTRIBUTE9,'x'))
  AND PRH.TYPE_LOOKUP_CODE=NVL(:P_TYPE,PRH.TYPE_LOOKUP_CODE) 
   AND PRH.AUTHORIZATION_STATUS= NVL(:P_STATUS,PRH.AUTHORIZATION_STATUS)
   AND PRH.ATTRIBUTE_CATEGORY ='Planned Requisition'
   AND prh.authorization_status ='INCOMPLETE'
ORDER BY PRL.REQUISITION_LINE_ID

/*
=============================================================================
Planned Purchase requisition Summery For UAT Date:12-DEC-2017 By Sohel Hossain
==============================================================================
*/

SELECT prh.requisition_header_id,
        prh.segment1 requisition_num, 
        note_to_agent,
        prh.requisition_header_id header_id,
        prh.creation_date CR_DT, 
        prl.line_num,
        prh.DESCRIPTION PR_DESC, 
        prh.ATTRIBUTE1 Start_date,
        prh.ATTRIBUTE2 End_date,
     -- NVL(XX_PO_FROM_REQ.GET_PO_FRM_REQ_DIST( :P_ORG_ID,prh.requisition_header_id,prl.line_num),
     -- XX_PO_FROM_REQ.GET_PO_FRM_REQ_SHIP( :P_ORG_ID,prh.requisition_header_id,prl.line_num)) PO_NAME,
       to_char(prh.creation_date,'DD-MON-RRRR HH12:MI:SS PM') creation_dt,
       to_char(prh.APPROVED_DATE,'DD-MON-RRRR HH12:MI:SS PM')  APPROVED_DATE,
       prl.ATTRIBUTE1 Brand, 
       prl.ATTRIBUTE2 Origin,
       ppg.segment2 Department,
       prh.attribute15 Priority,
       prl.reference_num move_order_no,
      (select mtrl.quantity from mtl_txn_request_lines mtrl,mtl_txn_request_headers mtrh where mtrh.header_id=mtrl.header_id and mtrl.inventory_item_id=prl.item_id and mtrh.request_number=prl.reference_num ) move_order_qty,
      (select b.description from fnd_flex_value_sets a, fnd_flex_values_vl b where  a.flex_value_set_id = b.flex_value_set_id and a.flex_value_set_name = 'XX_PROJECT' and b.flex_value=prh.attribute1) Project_Name,
       nvl(prh.authorization_status,'INCOMPLETE') req_status,
       prl.SUGGESTED_BUYER_ID,
       prh.preparer_id,
       prl.TO_PERSON_ID,
       ppf.full_name,
       prh.attribute1 BUDGET_NO,
       prl.item_id,
       mst.item_code,
       mst.description,
       prl.QUANTITY Unit,
       XX_30_DAYS_CONSUM_FN(NVL(PRH.APPROVED_DATE,prh.creation_date),PRL.ITEM_ID,DESTINATION_ORGANIZATION_ID) CONSUM_QTY,
       xx_pend_req_qty_fn(PRL.PO_LINE_ID) PENDING_QTY,
       xx_last_po_info_fn(4,PRL.ITEM_ID,PRH.ORG_ID,prh.creation_date) LPO,
       xx_last_po_info_fn(1,PRL.ITEM_ID,PRH.ORG_ID,prh.creation_date) LPD,
        xx_last_po_info_fn(2,PRL.ITEM_ID,PRH.ORG_ID,prh.creation_date) LPR,
         xx_last_po_info_fn(3,PRL.ITEM_ID,PRH.ORG_ID,prh.creation_date) LP_SUPP,
       MUOM.UOM_CODE UOM,
       HRL1.LOCATION_CODE,
       to_char(trunc(prl.NEED_BY_DATE),'DD-MON-RRRR') NEED_BY_DATE,
       paaf.job_id,
       pj.NAME,
       pj.job_definition_id,
      -- pjd.segment1 department,
       (SELECT USE_AREA FROM XXKSRM_INV_USE_AREA_V IUA WHERE IUA.USE_AREA_ID=prL.ATTRIBUTE3) Use_of_Area,
       prl.NOTE_TO_RECEIVER,
       prl.DESTINATION_ORGANIZATION_ID,
       HRO.ORGANIZATION_CODE ORG_CODE,
       PRH.TYPE_LOOKUP_CODE REQ_TYPE,
       substr(XX_GET_HR_OPERATING_UNIT(:p_org_id),5) ORG_HEADER_NAME,
      -- XX_com_pkg.get_hr_operating_unit(:p_org_id) Org_header_name,
      -- XX_COM_PKG.GET_UNIT_address(:p_org_id) org_header_address,
       PRL.DESTINATION_SUBINVENTORY WAREHOUSE,
       --xx_inv_org_name_fn(prl.destination_organization_id) dest_loc,
        --xx_inv_org_name_fn(prl.source_organization_id) source_loc,
--        substr(GET_ORGANIZATION_NAME(prl.org_id),5) REQ_ORG_NAME,
--    GET_UNIT_ADDRESS(prl.org_id) REQ_ORG_ADDRESS,
    (select name from hr_all_organization_units where organization_id=prl.DESTINATION_ORGANIZATION_ID)||' - '||HRO.ORGANIZATION_CODE dest_org_name   ,    
          (select location_code from hr_locations_all where location_id=prl.DELIVER_TO_LOCATION_ID) dest_location,
    TO_CHAR (TRUNC (prh.APPROVED_DATE),'DD-MON-RRRR') APPROVED_DATE,
       NVL(PRL.CANCEL_FLAG,'N') CANCEL_FLAG, 
       DECODE(PRL.CLOSED_CODE,NULL,'N','Y') CLOSED_FLAG,
       HRL.DESCRIPTION LOC,
       PRL.JUSTIFICATION 
  FROM po_requisition_headers_all prh,
       po_requisition_lines_all prl,
       mtl_units_of_measure_tl muom,
       per_people_f ppf,
       per_all_assignments_f paaf,
       pay_people_groups ppg,
       per_jobs pj,
       per_job_definitions pjd,
              PER_all_positions pp,
       PER_position_definitions pd,
       ORG_ORGANIZATION_DEFINITIONS HRO,
       HR_LOCATIONS_ALL HRL,
      HR_LOCATIONS_ALL HRL1,
       (SELECT organization_id,inventory_item_id, description,
                        (segment1 || '.' || segment2 || '.' || segment3|| '.' || segment4
                        ) item_code
                   FROM mtl_system_items_b) mst,
        hr_operating_units HOU           
 WHERE prh.requisition_header_id = prl.requisition_header_id
   AND SYSDATE BETWEEN paaf.effective_start_date AND paaf.effective_end_date
   AND SYSDATE BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND prh.preparer_id = ppf.person_id
   AND prh.preparer_id = paaf.person_id
  AND HRL.LOCATION_ID=DELIVER_TO_LOCATION_ID
  AND HRL1.LOCATION_ID=PAAF.LOCATION_ID
   AND ppf.person_id = paaf.person_id
   AND paaf.job_id(+) = pj.job_id
   AND ppg.people_group_id(+) = paaf.people_group_id
   AND pj.job_definition_id(+) = pjd.job_definition_id
   AND pp.position_id=paaf.position_id
   AND pp.POSITION_DEFINITION_ID=pd.POSITION_DEFINITION_ID
   AND NVL(PRL.MODIFIED_BY_AGENT_FLAG,'N')<>'Y'
  AND PRL.unit_meas_lookup_code=MUOM.UNIT_OF_MEASURE(+)
  AND HRO.OPERATING_UNIT=HOU.ORGANIZATION_ID 
   AND prl.item_id = mst.inventory_item_id
   AND PRL.DESTINATION_ORGANIZATION_ID=MST.ORGANIZATION_ID  
   and prl.DESTINATION_ORGANIZATION_ID=hro.ORGANIZATION_ID
 AND prh.ORG_ID = nvl(:p_ORG_ID,prh.org_id)
 AND NVL2(:P_REQ_NO,prh.requisition_header_id,-1) between NVL(:P_REQ_NO,-1) and NVL(:P_REQ_NO_T,-1) 
  --AND MST.item_code BETWEEN NVL(:P_ITEM_From,MST.item_code) AND NVL(:P_ITEM_To,MST.item_code)
 --AND nvl(PRL.ATTRIBUTE9,'x')=nvl(:P_DEPT,nvl(PRL.ATTRIBUTE9,'x'))
  AND nvl(pd.segment2,'x')=nvl(:p_dept,nvl(pd.segment2,'x'))
  AND PRH.TYPE_LOOKUP_CODE=NVL(:P_TYPE,PRH.TYPE_LOOKUP_CODE) 
   AND PRH.AUTHORIZATION_STATUS= NVL(:P_STATUS,PRH.AUTHORIZATION_STATUS)
  -- AND TRUNC(prh.creation_date) BETWEEN  nvl(FND_DATE.CANONICAL_TO_DATE(:P_F_PR_DT),TRUNC(prh.creation_date))
--AND NVL(FND_DATE.CANONICAL_TO_DATE(:P_T_PR_DT),TRUNC(prh.creation_date)) 
AND TRUNC(PRH.CREATION_DATE) BETWEEN NVL(:P_F_PR_DT,TRUNC(PRH.CREATION_DATE)) AND NVL(:P_T_PR_DT,TRUNC(PRH.CREATION_DATE))
 --AND PRH.TYPE_LOOKUP_CODE='PURCHASE'
   --AND NVL(UPPER(PRH.ATTRIBUTE_CATEGORY),0) NOT IN ('SHIPPING INFORMATION')
   --AND NVL(UPPER(PRL.ATTRIBUTE_CATEGORY),0) NOT IN ('BRANDING')
   AND PRH.ATTRIBUTE_CATEGORY ='Planned Requisition'
   AND prh.authorization_status ='INCOMPLETE'
ORDER BY PRL.REQUISITION_LINE_ID


--==========================SPEND ANALYSIS REPORT ==================================


SELECT ORGANIZATION_NAME,ITEM_GROUP,ITEM_SUB_GROUP,ITEM_CODE,ITEM_DESC,PO_PRICE,DELIVER_QTY,to_char(TRANS_DATE) Delivery_date, (PO_PRICE * DELIVER_QTY) Total_Value,
(PO_PRICE * DELIVER_QTY)/100 "Percent"
FROM APPS.WBI_INV_RCV_TRANSACTIONS_FAC
WHERE ORGANIZATION_NAME='KSPL Deep Sea'
 --AND TRUNC(TRANS_DATE) BETWEEN nvl(FND_DATE.CANONICAL_TO_DATE(:P_F_PR_DT),TRUNC(TRANS_DATE)) AND NVL(FND_DATE.CANONICAL_TO_DATE(:P_T_PR_DT),TRUNC(TRANS_DATE))
 AND TRUNC(TRANS_DATE) BETWEEN NVL(:P_F_PR_DT,TRUNC(TRANS_DATE)) AND NVL(:P_T_PR_DT,TRUNC(TRANS_DATE)) 
--and ITEM_SUB_GROUP='500'



SELECT ITEM_GROUP,ITEM_SUB_GROUP,ITEM_CODE,ITEM_DESC, sum(PO_PRICE * DELIVER_QTY) Total_Value
FROM APPS.WBI_INV_RCV_TRANSACTIONS_FAC
 --AND TRUNC(TRANS_DATE) BETWEEN nvl(FND_DATE.CANONICAL_TO_DATE(:P_F_PR_DT),TRUNC(TRANS_DATE)) AND NVL(FND_DATE.CANONICAL_TO_DATE(:P_T_PR_DT),TRUNC(TRANS_DATE))
 WHERE  TRUNC(TRANS_DATE) BETWEEN NVL(:P_F_PR_DT,TRUNC(TRANS_DATE)) AND NVL(:P_T_PR_DT,TRUNC(TRANS_DATE)) 
 GROUP BY ITEM_GROUP,ITEM_SUB_GROUP,ITEM_CODE,ITEM_DESC
--and ITEM_SUB_GROUP='500'




select ITEM_GROUP,ITEM_SUB_GROUP,ITEM_CODE,ITEM_DESC,sum(DELIVER_QTY) Total_Item ,sum(PO_PRICE * DELIVER_QTY) amount, (sum(PO_PRICE * DELIVER_QTY)/sum(DELIVER_QTY)) Agerage
from APPS.WBI_INV_RCV_TRANSACTIONS_FAC
WHERE TRANSACTION_TYPE= 'DELIVER'
--AND ITEM_DESC= 'BATTERY FOR DIGITAL CALCULATOR'
--AND RECEIPT_DATE between '01-sep-2017' AND '30-sep-2017'
--AND  ITEM_DESC= 'BALL BEARING 6205'
group by ITEM_GROUP,ITEM_SUB_GROUP,ITEM_CODE,ITEM_DESC

--===================================================

SELECT * from APPS.WBI_INV_RCV_TRANSACTIONS_FAC
WHERE  TRANSACTION_TYPE= 'DELIVER'
--AND ITEM_DESC= 'BALL BEARING 6205'
AND  ITEM_DESC='KSRM 500 W 12 MM'


select ITEM_GROUP,ITEM_SUB_GROUP,ITEM_CODE,ITEM_DESC,sum(DELIVER_QTY) Total_Item ,sum(PO_PRICE * DELIVER_QTY) amount, (sum(PO_PRICE * DELIVER_QTY)/sum(DELIVER_QTY)) Average
from APPS.WBI_INV_RCV_TRANSACTIONS_FAC
WHERE TRANSACTION_TYPE= 'DELIVER'
AND  DELIVER_QTY > 0
--AND ITEM_DESC= 'BATTERY FOR DIGITAL CALCULATOR'
--AND RECEIPT_DATE between '01-sep-2017' AND '30-sep-2017'
--AND  ITEM_DESC= 'BALL BEARING 6205'
AND ITEM_CODE='SP|STEL|MPLT|017319'
group by ITEM_GROUP,ITEM_SUB_GROUP,ITEM_CODE,ITEM_DESC

SELECT (amount/ SUM(NVL(amount,0)))*100 FROM(
select ITEM_GROUP,ITEM_SUB_GROUP,ITEM_CODE,ITEM_DESC,sum(DELIVER_QTY) Total_Item ,sum(PO_PRICE * DELIVER_QTY) amount, (sum(PO_PRICE * DELIVER_QTY)/sum(DELIVER_QTY)) Average
from APPS.WBI_INV_RCV_TRANSACTIONS_FAC
WHERE TRANSACTION_TYPE= 'DELIVER'
AND  DELIVER_QTY > 0
AND PO_NO >0
--AND ITEM_DESC= 'BATTERY FOR DIGITAL CALCULATOR'
--AND RECEIPT_DATE between '01-sep-2017' AND '30-sep-2017'
--AND  ITEM_DESC='KSRM 500 W 12 MM' --'BALL BEARING 6205'
--AND ITEM_CODE='SP|STEL|MPLT|017319'
group by ITEM_GROUP,ITEM_SUB_GROUP,ITEM_CODE,ITEM_DESC)
Group by item_group
