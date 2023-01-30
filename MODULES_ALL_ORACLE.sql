SELECT fa.application_id           "Application ID",
       fat.application_name        "Application Name",
       fa.application_short_name   "Application Short Name",
       fa.basepath                 "Basepath"
  FROM fnd_application     fa,
       fnd_application_tl  fat
 WHERE fa.application_id = fat.application_id
   AND fat.language      = USERENV('LANG')
   AND fat.application_name IN ( 'Payables','Receivables', 'Order Management', 'Cash Management', 'Purchasing', 'Inventory','Landed Cost Management','Oracle Landed Cost Management', 'General Ledger','Assets')  -- <change it>
 ORDER BY fat.application_name
 
 --=======================================
 
--BELOW SCRIPT WILL HELP YOU TO GET THE INVENTORY ORG TO BUSINESS GROUP DETAILS WITH LEGAL ENTITY, OPERATING UNIT, LEDGER, PERIOD DETAILS, INVENTORY VALIDATION ORG AND PURCHASE VALIDATION ORG FOR THE OPERATING UNIT
--
--THIS SCRIPT IS IN THE CONTEXT OF ORACLE R12

--==========================================

select mp.organization_code org_code,
       org.organization_id org_id,
       org.name org_name,
       hl.location_id,
       hl.location_code,
       hl.address_line_1,
       hl.address_line_2,
       hl.address_line_3,
       hl.town_or_city,
       hl.country,
       hl.postal_code,
       ou.organization_id ou_id,
       ou.name OU,
       le.legal_entity_id le_id,
       le.name LE,
       gl.ledger_id,
       gl.name primary_ledger,
       gl.currency_code,
       bg.name bg,
       (select organization_code
          from apps.mtl_parameters
         where organization_id =
               (select parameter_value
                  from apps.OE_SYS_PARAMETERS_ALL
                 where parameter_code = 'MASTER_ORGANIZATION_ID'
                   and org_id = ou.organization_id)) IVO,
       (select organization_code
          from apps.mtl_parameters
         where organization_id =
               (select inventory_organization_id
                  from AP.FINANCIALS_SYSTEM_PARAMS_ALL#
                 where org_id = ou.organization_id)) PVO,
       (select period_name || ' : ' || open_flag
          from apps.ORG_ACCT_PERIODS
         where period_start_date <= trunc(sysdate)
           and schedule_close_date >= trunc(sysdate)
           and organization_id = mp.organization_id) inv_period,
       (select period_name || ' : ' || show_status
          from apps.GL_PERIOD_STATUSES_V
         where start_date <= trunc(sysdate)
           and end_date >= trunc(sysdate)
           and ledger_id = gl.ledger_id
           and application_id = 101) gl_ledger_period,
       (select period_name || ' : ' || show_status
          from apps.GL_PERIOD_STATUSES_V
         where start_date <= trunc(sysdate)
           and end_date >= trunc(sysdate)
           and ledger_id = gl.ledger_id
           and application_id = 200) AP_period,
       (select period_name || ' : ' || show_status
          from apps.GL_PERIOD_STATUSES_V
         where start_date <= trunc(sysdate)
           and end_date >= trunc(sysdate)
           and ledger_id = gl.ledger_id
           and application_id = 222) AR_period,
       (select period_name || ' : ' || show_status
          from apps.GL_PERIOD_STATUSES_V
         where start_date <= trunc(sysdate)
           and end_date >= trunc(sysdate)
           and ledger_id = gl.ledger_id
           and application_id = 201) PO_period
  from apps.XLE_ENTITY_PROFILES         le,
       apps.HR_ALL_ORGANIZATION_UNITS   ou,
       apps.HR_ALL_ORGANIZATION_UNITS   org,
       apps.HR_ALL_ORGANIZATION_UNITS   bg,
       apps.mtl_parameters              mp,
       apps.GL_LEDGERS                  gl,
       apps.HR_ORGANIZATION_INFORMATION ouinfo,
       apps.HR_ORGANIZATION_INFORMATION orginfo,
       apps.hr_locations                hl
 where mp.organization_id = org.organization_id
   and org.organization_id = orginfo.organization_id
   and org.location_id = hl.location_id
   and orginfo.org_information_context = 'Accounting Information'
   and orginfo.org_information3 = ou.organization_id
   and orginfo.org_information1 = gl.ledger_id
   and orginfo.org_information2 = le.legal_entity_id
   and ou.organization_id = ouinfo.organization_id
   and ouinfo.org_information_context = 'Operating Unit Information'
   and ouinfo.org_information2 = le.legal_entity_id
   and ouinfo.org_information3 = gl.ledger_id
   and bg.organization_id = ou.business_group_id
 --  and mp.organization_code in ('V1')