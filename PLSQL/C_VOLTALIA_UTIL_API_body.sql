create or replace PACKAGE BODY C_VOLTALIA_UTIL_API AS

pkg_MAXVALUE_ NUMBER := 1000000000;

PROCEDURE Copy_Supplier (
    source_supplier_        varchar2,
    source_company_         varchar2,
    destination_            varchar2
) IS

    company_                varchar2(50);
    supplier_               varchar2(50);

    comp_ varchar2(20);
    sup_  varchar2(20);
    way_  varchar2(50);
    addr_id_                varchar(50);
    flag_ number;
    
    info_                   varchar2(4000);
    objid_                  varchar2(200);
    objversion_             varchar2(200);
    
    invoice_attr_           varchar2(32000);
    payment_attr_           varchar2(32000);
    pay_way_attr_           varchar2(32000);
    payment_address_attr_   varchar2(32000);
    
    cursor get_invoice_info is
        select * 
        from IDENTITY_INVOICE_INFO
        where company=source_company_ and identity like source_supplier_ and party_type='Supplier';
        
    cursor get_identity_pay_info is
        select * 
        from IDENTITY_PAY_INFO
        where identity = supplier_ and company = company_ and party_type='Supplier';
    
    cursor get_pay_way is
        select * 
        from PAYMENT_WAY_PER_IDENTITY
        where identity = supplier_ and company = company_ and party_type='Supplier';
        
    Cursor get_pay_address is
        select * 
        from PAYMENT_ADDRESS
        where identity = supplier_ and company = company_ and party_type='Supplier';
    
    Cursor get_new_companies is
        select *
        from company
        where company like destination_||'%' and company not like substr(destination_,1,3)||'000'
        and   company <> company_
        order by company;
    
    Cursor check_ident_inv_inf is
        select 1 
        from IDENTITY_INVOICE_INFO
        where identity = sup_ and company = comp_ and party_type='Supplier';
    
    Cursor check_ident_pay_info is
        select 1
        from IDENTITY_PAY_INFO
        where identity = sup_ and company = comp_ and party_type='Supplier';
    
    Cursor check_PAY_WAY_PER_IDENT is
        select 1
        from PAYMENT_WAY_PER_IDENTITY
        where identity = sup_ and company = comp_ and way_id=way_ and party_type='Supplier';
    
    Cursor check_Pay_Address is
        select 1 
        from PAYMENT_ADDRESS
        where identity = sup_ and company = comp_ and way_id=way_ and address_id=addr_id_ and party_type='Supplier';
    
    Begin
    
        IFSAPP.Language_SYS.Set_Language('en'); -- This requires logged in user to have privileges to Language_SYS.Set_Language
--                dbms_output.put_line(source_company_ || ' - ' || destination_);
        
        for recinfo_ in get_invoice_info loop
            
            company_ := recinfo_.company;
            supplier_ := recinfo_.identity;
--dbms_output.put_line('Supplier: ' || supplier_);        
            for rec_ in get_new_companies loop
            --INVOICE TAB
            
                Client_SYS.Clear_Attr(invoice_attr_);
                Client_SYS.Add_To_Attr('COMPANY',                   rec_.company,invoice_attr_);
                Client_SYS.Add_To_Attr('PARTY_TYPE',                recinfo_.party_type,invoice_attr_);
                Client_SYS.Add_To_Attr('IDENTITY_TYPE',             recinfo_.identity_type,invoice_attr_);
                Client_SYS.Add_To_Attr('GROUP_ID',                  recinfo_.group_id,invoice_attr_);
                Client_SYS.Add_To_Attr('DEF_CURRENCY',              recinfo_.def_currency,invoice_attr_);
                Client_SYS.Add_To_Attr('PAY_TERM_ID',               recinfo_.pay_term_id,invoice_attr_);
                Client_SYS.Add_To_Attr('AUTOMATIC_PAY_AUTH_FLAG',   recinfo_.automatic_pay_auth_flag,invoice_attr_);
                Client_SYS.Add_To_Attr('DEF_AUTHORIZER',            recinfo_.def_authorizer,invoice_attr_);
                Client_SYS.Add_To_Attr('DEF_PRELIMINARY_CODE',      recinfo_.def_preliminary_code,invoice_attr_);
                Client_SYS.Add_To_Attr('INVOICE_RECIPIENT',         recinfo_.invoice_recipient,invoice_attr_);
                Client_SYS.Add_To_Attr('INVOICING_SUPPLIER',        recinfo_.invoicing_supplier,invoice_attr_);
                Client_SYS.Add_To_Attr('NCF_REFERENCE_CHECK',       recinfo_.ncf_reference_check,invoice_attr_);
                Client_SYS.Add_To_Attr('IDENTITY',                  recinfo_.identity,invoice_attr_);
                Client_SYS.Add_To_Attr('TAX_REGIME',                recinfo_.tax_regime,invoice_attr_);
                Client_SYS.Add_To_Attr('LIABILITY_TYPE',            recinfo_.liability_type,invoice_attr_);
                Client_SYS.Add_To_Attr('REPORT_AND_WITHHOLD',       recinfo_.report_and_withhold,invoice_attr_);
                Client_SYS.Add_To_Attr('AUTO_CREATION_TAX_LINES',   recinfo_.auto_creation_tax_lines,invoice_attr_);
                Client_SYS.Add_To_Attr('PRINT_TAX_CODE_TEXT',       recinfo_.print_tax_code_text,invoice_attr_);
                Client_SYS.Add_To_Attr('MATCHING_LEVEL',            recinfo_.matching_level,invoice_attr_);
                Client_SYS.Add_To_Attr('AUTOMATIC_INVOICE',         recinfo_.automatic_invoice,invoice_attr_);
                Client_SYS.Add_To_Attr('ALLOW_QUANTITY_DIFF',       recinfo_.allow_quantity_diff,invoice_attr_);
                Client_SYS.Add_To_Attr('PO_REF_REC_REF_VAL_METHOD', recinfo_.po_ref_rec_ref_val_method,invoice_attr_);
                Client_SYS.Add_To_Attr('ALLOW_TOLERANCE',           recinfo_.allow_tolerance,invoice_attr_);
                Client_SYS.Add_To_Attr('CREATE_TOLERANCE_POSTING',  recinfo_.create_tolerance_posting,invoice_attr_);
                Client_SYS.Add_To_Attr('DEF_VAT_CODE',              recinfo_.def_vat_code,invoice_attr_);
                Client_SYS.Add_To_Attr('AUTO_CREATION_TAX_LINES',   recinfo_.auto_creation_tax_lines,invoice_attr_);
            
                
                sup_ := recinfo_.identity;
                comp_ := rec_.company;
                flag_ :=0;
                
                
                open check_ident_inv_inf;
                fetch check_ident_inv_inf into flag_;
                close check_ident_inv_inf;
                if flag_<>1 Then
                    IFSAPP.IDENTITY_INVOICE_INFO_API.NEW__( info_ , objid_ , objversion_ , invoice_attr_ , 'DO' );
                end if;
--                commit;
            --INVOICE TAB
            
                for recpay_ in get_identity_pay_info loop
                    --PAYMENT TAB

                    Client_SYS.Clear_Attr(payment_attr_);
                    Client_SYS.Add_To_Attr('COMPANY',                   rec_.company,payment_attr_);
                    Client_SYS.Add_To_Attr('IDENTITY',                  recpay_.identity,payment_attr_);
                    Client_SYS.Add_To_Attr('PARTY_TYPE',                recpay_.party_type,payment_attr_);
                    Client_SYS.Add_To_Attr('INTEREST_TEMPLATE',         recpay_.interest_template,payment_attr_);
                    Client_SYS.Add_To_Attr('PAYMENT_ADVICE',            recpay_.payment_advice,payment_attr_);
                    Client_SYS.Add_To_Attr('PRIORITY',                  recpay_.priority,payment_attr_);
                    Client_SYS.Add_To_Attr('TEMPLATE_ID',               recpay_.template_id,payment_attr_);
                    Client_SYS.Add_To_Attr('NETTING_ALLOWED',           recpay_.netting_allowed,payment_attr_);
                    Client_SYS.Add_To_Attr('BLOCKED_FOR_PAYMENT',       recpay_.blocked_for_payment,payment_attr_);
                    Client_SYS.Add_To_Attr('OUTPUT_MEDIA',              recpay_.output_media,payment_attr_);
                    Client_SYS.Add_To_Attr('CHECK_RECIPIENT',           recpay_.check_recipient,payment_attr_);
                    Client_SYS.Add_To_Attr('IS_ONE_INV_PER_PAY_DB',     recpay_.is_one_inv_per_pay_db,payment_attr_);
                    Client_SYS.Add_To_Attr('DEFAULT_PAYMENT_METHOD',    recpay_.default_payment_method,payment_attr_);
                    Client_SYS.Add_To_Attr('COMM_ID',                   recpay_.comm_id,payment_attr_);
    
                    flag_ :=0;
                    
                    open check_ident_pay_info;
                    fetch check_ident_pay_info into flag_;
                    close check_ident_pay_info;
                    if flag_<>1 Then        
                        IFSAPP.IDENTITY_PAY_INFO_API.NEW__( info_ , objid_ , objversion_ , payment_attr_ , 'DO' );
                    end if;
--                    commit;
                end loop;
                    
                for recpw_ in get_pay_way loop
                    --Payment Method

                    Client_SYS.Clear_Attr(pay_way_attr_);
                    Client_SYS.Add_To_Attr('COMPANY',                 rec_.company,pay_way_attr_);
                    Client_SYS.Add_To_Attr('IDENTITY',                recpw_.identity,pay_way_attr_);
                    Client_SYS.Add_To_Attr('PARTY_TYPE',              recpw_.party_type,pay_way_attr_);
                    Client_SYS.Add_To_Attr('PARTY_TYPE_DB',           recpw_.party_type_db,pay_way_attr_);
                    Client_SYS.Add_To_Attr('WAY_ID',                  recpw_.way_id,pay_way_attr_);
                    Client_SYS.Add_To_Attr('DEFAULT_PAYMENT_WAY',     recpw_.default_payment_way,pay_way_attr_);

                    flag_ :=0;
                    way_ := recpw_.way_id;
                    
                    open check_PAY_WAY_PER_IDENT;
                    fetch check_PAY_WAY_PER_IDENT into flag_;
                    close check_PAY_WAY_PER_IDENT;
                    if flag_<>1 Then                              
                        IFSAPP.PAYMENT_WAY_PER_IDENTITY_API.NEW__( info_ , objid_ , objversion_ , pay_way_attr_ , 'DO' );
                    end if;
                end loop;
--                commit;
                
                for recpa_ in get_pay_address loop
                    -- Payment Address

                    Client_SYS.Clear_Attr(payment_address_attr_);
                    Client_SYS.Add_To_Attr('COMPANY',                 rec_.company,payment_address_attr_);
                    Client_SYS.Add_To_Attr('IDENTITY',                recpa_.identity,payment_address_attr_);
                    Client_SYS.Add_To_Attr('PARTY_TYPE',              recpa_.party_type,payment_address_attr_);
                    Client_SYS.Add_To_Attr('WAY_ID',                  recpa_.way_id,payment_address_attr_);
                    Client_SYS.Add_To_Attr('ADDRESS_ID',              recpa_.address_id,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DESCRIPTION',             recpa_.description,payment_address_attr_);
                    Client_SYS.Add_To_Attr('ACCOUNT',                 recpa_.account,payment_address_attr_);
                    Client_SYS.Add_To_Attr('BIC_CODE',                recpa_.bic_code,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DEFAULT_ADDRESS',         recpa_.default_address,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA1',                   recpa_.data1,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA2',                   recpa_.data2,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA3',                   recpa_.data3,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA4',                   recpa_.data4,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA5',                   recpa_.data5,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA6',                   recpa_.data6,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA7',                   recpa_.data7,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA8',                   recpa_.data8,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA9',                   recpa_.data9,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA10',                  recpa_.data10,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA11',                  recpa_.data11,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA12',                  recpa_.data12,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA13',                  recpa_.data13,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA14',                  recpa_.data14,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA15',                  recpa_.data15,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA16',                  recpa_.data16,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA17',                  recpa_.data17,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA18',                  recpa_.data18,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA19',                  recpa_.data19,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA20',                  recpa_.data20,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA21',                  recpa_.data21,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA22',                  recpa_.data22,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA23',                  recpa_.data23,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA24',                  recpa_.data24,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA25',                  recpa_.data25,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA26',                  recpa_.data26,payment_address_attr_);
                    Client_SYS.Add_To_Attr('BLOCKED_FOR_USE',         recpa_.blocked_for_use,payment_address_attr_);
                    
                    flag_ :=0;
                    way_ := recpa_.way_id;
                    addr_id_ := recpa_.address_id;
                    
                    open check_Pay_Address;
                    fetch check_Pay_Address into flag_;
                    close check_Pay_Address;
                    if flag_<>1 Then                                            
                        IFSAPP.PAYMENT_ADDRESS_API.NEW__( info_ , objid_ , objversion_ , payment_address_attr_ , 'DO' );   
                    end if;
                end loop;
--                commit;
            end loop;
        end loop;
--        commit;
--    end loop;
    End Copy_Supplier;


PROCEDURE Copy_Iban (
    source_supplier_        varchar2,
    source_company_         varchar2,
    source_way_id_          varchar2,
    source_address_id_      varchar2,
    destination_            varchar2,
    disable_existing_       varchar2
) IS

    comp_ varchar2(20);
    sup_ varchar2(20);
    flag_ number;
    p30_ VARCHAR2(32000) := NULL;
    p31_ VARCHAR2(32000) := NULL;
    p32_ VARCHAR2(32000) := NULL;
    p33_ VARCHAR2(32000);
    p34_ VARCHAR2(10);
    
    info_                   varchar2(4000);
    objid_                  varchar2(200);
    objversion_             varchar2(200);
    
    disable_attr_           varchar2(32000);
    payment_address_attr_   varchar2(32000);

    cursor get_invoice_info is
        select * 
        from IDENTITY_INVOICE_INFO
        where company=source_company_ and identity=source_supplier_;

    Cursor get_pay_address is
        select * 
        from PAYMENT_ADDRESS
        where identity = source_supplier_ and company = source_company_ and address_id = source_address_id_ and way_id = source_way_id_;

    Cursor get_new_companies is
        select *
        from company
        where company like destination_||'%' and company not like substr(destination_,1,3)||'000'
        and   company <> source_company_
        order by company;

    Cursor check_Pay_Address is
        select 1 
        from PAYMENT_ADDRESS
        where identity = sup_ and company = comp_ and address_id = source_address_id_ and way_id = source_way_id_;

    Cursor get_Pay_Address_destination is
        select *
        from PAYMENT_ADDRESS
        where identity = sup_ and company = comp_ and way_id = source_way_id_;
    
    Cursor get_pay_way is
    select * 
    from PAYMENT_WAY_PER_IDENTITY
    where identity = source_supplier_ and company =source_company_ and way_id = source_way_id_;

    Cursor check_PAY_WAY_PER_IDENT is
    select 1
    from PAYMENT_WAY_PER_IDENTITY
    where identity = sup_ and company = comp_ and way_id = source_way_id_;
    
    Begin
        IFSAPP.Language_SYS.Set_Language('en'); -- This requires logged in user to have privileges to Language_SYS.Set_Language
        
        for recinfo_ in get_invoice_info loop
            for rec_ in get_new_companies loop

                sup_ := recinfo_.identity;
                comp_ := rec_.company;
                flag_ :=0;

                for recpa_ in get_pay_address loop
                    -- Payment Address

                    flag_ :=0;
                    
                    open check_PAY_WAY_PER_IDENT;
                    fetch check_PAY_WAY_PER_IDENT into flag_;
                    close check_PAY_WAY_PER_IDENT;
                    if flag_<>1 Then 
                    
                        for recw_ in  get_pay_way loop                        
                            p30_ := NULL;
                            p31_ := NULL;
                            p32_:= NULL;
                            p33_ := 'COMPANY'||chr(31)||comp_||chr(30)||'IDENTITY'||chr(31)||sup_||chr(30)||'PARTY_TYPE'||chr(31)||recw_.PARTY_TYPE||chr(30)||'PARTY_TYPE_DB'||chr(31)||recw_.PARTY_TYPE_DB||chr(30)||'WAY_ID'||chr(31)||recw_.WAY_ID||chr(30)||'DEFAULT_PAYMENT_WAY'||chr(31)||recw_.DEFAULT_PAYMENT_WAY||chr(30);
                            p34_ := 'DO';
                            IFSAPP.PAYMENT_WAY_PER_IDENTITY_API.NEW__( p30_, p31_, p32_, p33_, p34_ );    
                        end loop;
                    end if;


                    Client_SYS.Clear_Attr(payment_address_attr_);
                    Client_SYS.Add_To_Attr('COMPANY',                 rec_.company,payment_address_attr_);
                    Client_SYS.Add_To_Attr('IDENTITY',                recpa_.identity,payment_address_attr_);
                    Client_SYS.Add_To_Attr('PARTY_TYPE',              recpa_.party_type,payment_address_attr_);
                    Client_SYS.Add_To_Attr('WAY_ID',                  recpa_.way_id,payment_address_attr_);
                    Client_SYS.Add_To_Attr('ADDRESS_ID',              recpa_.address_id,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DESCRIPTION',             recpa_.description,payment_address_attr_);
                    Client_SYS.Add_To_Attr('ACCOUNT',                 recpa_.account,payment_address_attr_);
                    Client_SYS.Add_To_Attr('BIC_CODE',                recpa_.bic_code,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DEFAULT_ADDRESS',         recpa_.default_address,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA1',                   recpa_.data1,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA2',                   recpa_.data2,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA3',                   recpa_.data3,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA4',                   recpa_.data4,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA5',                   recpa_.data5,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA6',                   recpa_.data6,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA7',                   recpa_.data7,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA8',                   recpa_.data8,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA9',                   recpa_.data9,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA10',                  recpa_.data10,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA11',                  recpa_.data11,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA12',                  recpa_.data12,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA13',                  recpa_.data13,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA14',                  recpa_.data14,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA15',                  recpa_.data15,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA16',                  recpa_.data16,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA17',                  recpa_.data17,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA18',                  recpa_.data18,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA19',                  recpa_.data19,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA20',                  recpa_.data20,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA21',                  recpa_.data21,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA22',                  recpa_.data22,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA23',                  recpa_.data23,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA24',                  recpa_.data24,payment_address_attr_);
                    Client_SYS.Add_To_Attr('DATA25',                  recpa_.data25,payment_address_attr_);
                    Client_SYS.Add_To_Attr('BLOCKED_FOR_USE',         recpa_.blocked_for_use,payment_address_attr_);
                    
                    flag_ :=0;
                    
                    open check_Pay_Address;
                    fetch check_Pay_Address into flag_;
                    close check_Pay_Address;
                    if flag_<>1 Then                
                       if (disable_existing_ = 'TRUE') then
                       
                         for recdisable_ in get_Pay_Address_destination loop
                         
                            Client_SYS.Clear_Attr(disable_attr_);
                            Client_SYS.Add_To_Attr('BLOCKED_FOR_USE','TRUE',disable_attr_);
                            
                            IFSAPP.PAYMENT_ADDRESS_API.MODIFY__ ( info_, recdisable_.objid, recdisable_.objversion, disable_attr_, 'DO' );
                         
                         end loop;
                       
                       end if;
                    
                    
                       IFSAPP.PAYMENT_ADDRESS_API.NEW__( info_ , objid_ , objversion_ , payment_address_attr_ , 'DO' );   
                    end if;
                    
                end loop;

            end loop;
        end loop;

    End Copy_Iban;

    PROCEDURE Synchronize_User (
       user_     varchar2
    ) IS
    
      comp_             varchar2(10);
      comp2_            varchar2(10);
      flag_             number;
      def_              number;
      company_          varchar2(10);
      site_             varchar2(20);
      group_            varchar2(20);
      
      info_             varchar2(4000);
      attr_             varchar2(32000);
      objid_            varchar2(200);
      objversion_       varchar2(200);

      Cursor get_countries IS
          select distinct substr(company,1,3) country
          from user_finance where userid=user_;

      Cursor get_companies is
          select * 
          from COMPANY_FINANCE
          where company like comp_||'%' and company not like comp_||'000'
          order by company;

      Cursor get_user_company is
          select 1 
          from USER_FINANCE
          where userid=user_ and company=company_;

      Cursor get_user_site is
          select 1
          from USER_ALLOWED_SITE
          where userid=user_ and contract=site_;

      Cursor get_company_site is
          select contract 
          from COMPANY_SITE
          where company=company_;

      Cursor get_group is
          select user_group
          from USER_GROUP_MEMBER_FINANCE
          where userid=user_
          and   rownum=1;

      Cursor get_user_group is
          select 1 
          from USER_GROUP_MEMBER_FINANCE
          where userid=user_ and company=company_ and user_group=group_;

      Cursor get_auth_Class is
          select 1
          from GEN_LED_USER
          where company=company_ and userid=user_ and auth_class='MAX';
    
    BEGIN
      
      for reccountry_ in get_countries loop
        
        comp_ := reccountry_.country;
        open get_group;
        fetch get_group into group_;
        close get_group;

        for rec_ in get_companies loop
            -- COMPANIES
            company_:=rec_.company;
            flag_:=0;
            open get_user_company;
            fetch get_user_company into flag_;
            close get_user_company;
            if flag_<>1 then

                Client_SYS.Clear_Attr(attr_); 
                Client_SYS.Add_To_Attr('COMPANY',rec_.company,attr_);
                Client_SYS.Add_To_Attr('USERID',user_,attr_);
                Client_SYS.Add_To_Attr('DEFAULT_COMPANY','FALSE',attr_);            
                USER_FINANCE_API.NEW__( info_ , objid_ , objversion_ , attr_ , 'DO' );

            end if;
      
            -- SITES
            for recsite_ in get_company_site loop
              
              site_ := recsite_.contract;
            
              flag_:=0;
              open get_user_site;
              fetch get_user_site into flag_;
              close get_user_site;
              if flag_<>1 then
                  Client_SYS.Clear_Attr(attr_); 
                  Client_SYS.Add_To_Attr('USERID',user_,attr_);
                  Client_SYS.Add_To_Attr('CONTRACT',recsite_.contract,attr_);
                  Client_SYS.Add_To_Attr('USER_SITE_TYPE_DB','NOT DEFAULT_SITE',attr_);
                  USER_ALLOWED_SITE_API.NEW__( info_ ,objid_ , objversion_ , attr_ , 'DO' );
              end if;
            
            end loop;
            
            -- User Group
            flag_:=0;
            open get_user_group;
            fetch get_user_group into flag_;
            close get_user_group;
            if flag_<>1 then
              
                  Client_SYS.Clear_Attr(attr_); 
                  Client_SYS.Add_To_Attr('COMPANY',rec_.company,attr_);
                  Client_SYS.Add_To_Attr('USER_GROUP',group_,attr_);
                  Client_SYS.Add_To_Attr('USERID',user_,attr_);
                  Client_SYS.Add_To_Attr('DEFAULT_GROUP','Yes',attr_);

                  USER_GROUP_MEMBER_FINANCE_API.NEW__( info_ , objid_ , objversion_ , attr_ , 'DO' );
            end if;

            
            -- Authority Class
            flag_:=0;
            open get_auth_Class;
            fetch get_auth_Class into flag_;
            close get_auth_Class;
            if flag_<>1 then
                Client_SYS.Clear_Attr(attr_); 
                Client_SYS.Add_To_Attr('COMPANY',rec_.company,attr_);
                Client_SYS.Add_To_Attr('USERID',user_,attr_);
                Client_SYS.Add_To_Attr('AUTH_CLASS','MAX',attr_);
                GEN_LED_USER_API.NEW__( info_ , objid_ , objversion_ , attr_ , 'DO' );

                Row_Level_Security_Util_API.Rebuild_Access_Info (rec_.company);
            end if;

        end loop;
        
      end loop;
       
    END Synchronize_User;


    PROCEDURE Synchronize_Company (
       company_     varchar2
    ) IS
    
      comp_             varchar2(10);
      comp2_            varchar2(10);
      flag_             number;
      def_              number;
      user_             varchar2(50);
      site_             varchar2(20);
      group_            varchar2(20);
      first_company_    varchar2(20);
      
      info_             varchar2(4000);
      attr_             varchar2(32000);
      objid_            varchar2(200);
      objversion_       varchar2(200);

      Cursor get_first_company IS
          select company from company_finance
          where company like substr(company_,1,3)||'%' and company not like substr(company_,1,3)||'000'
          and   rownum=1
          order by company;

      Cursor get_users IS
          select userid 
          from   user_finance
          where  company = first_company_;

      Cursor get_countries IS
          select distinct substr(company,1,3) country
          from user_finance where userid=user_;

      Cursor get_user_company is
          select 1 
          from USER_FINANCE
          where userid=user_ and company=company_;

      Cursor get_user_site is
          select 1
          from USER_ALLOWED_SITE
          where userid=user_ and contract=site_;

      Cursor get_company_site is
          select contract 
          from COMPANY_SITE
          where company=company_;

      Cursor get_group is
          select user_group
          from USER_GROUP_MEMBER_FINANCE
          where userid=user_
          and   rownum=1;

      Cursor get_user_group is
          select 1 
          from USER_GROUP_MEMBER_FINANCE
          where userid=user_ and company=company_ and user_group=group_;

      Cursor get_auth_Class is
          select 1
          from GEN_LED_USER
          where company=company_ and userid=user_ and auth_class='MAX';
    
    BEGIN
      
      open get_first_company;
      fetch get_first_company into first_company_;
      close get_first_company;
      
      for recusers_ in get_users loop
        
        user_ := recusers_.userid;
--dbms_output.put_line('User: ' || user_);
        
        open get_group;
        fetch get_group into group_;
        close get_group;

            -- COMPANIES
            flag_:=0;
            open get_user_company;
            fetch get_user_company into flag_;
            close get_user_company;
            if flag_<>1 then

                Client_SYS.Clear_Attr(attr_); 
                Client_SYS.Add_To_Attr('COMPANY',company_,attr_);
                Client_SYS.Add_To_Attr('USERID',user_,attr_);
                Client_SYS.Add_To_Attr('DEFAULT_COMPANY','FALSE',attr_);            
                USER_FINANCE_API.NEW__( info_ , objid_ , objversion_ , attr_ , 'DO' );

            end if;
      
            -- SITES
            for recsite_ in get_company_site loop
              
              site_ := recsite_.contract;
              
              flag_:=0;
              open get_user_site;
              fetch get_user_site into flag_;
              close get_user_site;
              if flag_<>1 then
                  Client_SYS.Clear_Attr(attr_); 
                  Client_SYS.Add_To_Attr('USERID',user_,attr_);
                  Client_SYS.Add_To_Attr('CONTRACT',recsite_.contract,attr_);
                  Client_SYS.Add_To_Attr('USER_SITE_TYPE_DB','NOT DEFAULT_SITE',attr_);
                  USER_ALLOWED_SITE_API.NEW__( info_ ,objid_ , objversion_ , attr_ , 'DO' );
              end if;
            
            end loop;
            
            -- User Group
            flag_:=0;
            open get_user_group;
            fetch get_user_group into flag_;
            close get_user_group;
            if flag_<>1 then
              
                  Client_SYS.Clear_Attr(attr_); 
                  Client_SYS.Add_To_Attr('COMPANY',company_,attr_);
                  Client_SYS.Add_To_Attr('USER_GROUP',group_,attr_);
                  Client_SYS.Add_To_Attr('USERID',user_,attr_);
                  Client_SYS.Add_To_Attr('DEFAULT_GROUP','Yes',attr_);

                  USER_GROUP_MEMBER_FINANCE_API.NEW__( info_ , objid_ , objversion_ , attr_ , 'DO' );
            end if;

            
            -- Authority Class
            flag_:=0;
            open get_auth_Class;
            fetch get_auth_Class into flag_;
            close get_auth_Class;
            if flag_<>1 then
                Client_SYS.Clear_Attr(attr_); 
                Client_SYS.Add_To_Attr('COMPANY',company_,attr_);
                Client_SYS.Add_To_Attr('USERID',user_,attr_);
                Client_SYS.Add_To_Attr('AUTH_CLASS','MAX',attr_);
                GEN_LED_USER_API.NEW__( info_ , objid_ , objversion_ , attr_ , 'DO' );

                Row_Level_Security_Util_API.Rebuild_Access_Info (company_);
            end if;

      end loop;
       
    END Synchronize_Company;
    
    PROCEDURE Vlt_Close_Grp_Period ( 
    company_in IN VARCHAR2, -- like 'company_in%
    accounting_year_in IN INTEGER, 
    accounting_period_in IN INTEGER, --if zero then it must close all the year periods
    user_group_AC_in IN VARCHAR2, 
    user_group_AP_in IN VARCHAR2, 
    user_group_AR_in IN VARCHAR2, 
    user_group_EX_in IN VARCHAR2, 
    user_group_TR_in IN VARCHAR2)
    IS
       -- p0 -> __lsResult
       p0_ VARCHAR2(32000) := '';
       -- p1 -> __sObjid
       p1_ VARCHAR2(32000);
       -- p2 -> __lsObjversion
       p2_ VARCHAR2(32000);
       -- p3 -> __lsAttr
       p3_ VARCHAR2(32000) := 'PERIOD_STATUS_INT'||chr(31)||'Closed'||chr(30);
       -- p4 -> __sAction
       p4_ VARCHAR2(32000) := 'DO';
    
       BEGIN 
          
       FOR rec IN ( SELECT * FROM USER_GROUP_PERIOD 
                    WHERE ACCOUNTING_YEAR = accounting_year_in  
                    AND COMPANY like company_in || '%'
                    ) 
       LOOP 
        p0_ := '';
        p1_ := rec.objid;
        p2_ := rec.objversion;
        p3_ := 'PERIOD_STATUS_INT'||chr(31)||'Closed'||chr(30);
        p4_ := 'DO';
        
            IF rec.ACCOUNTING_PERIOD = accounting_period_in OR NVL(accounting_period_in,0)=0 THEN
                IF rec.USER_GROUP IN (user_group_AC_in, user_group_AP_in, user_group_AR_in, user_group_EX_in, user_group_TR_in)  THEN 
                    --DBMS_OUTPUT.put_line ('---> ' || rec.COMPANY || ' ' || rec.accounting_year || ' ' || rec.accounting_period || ' ' || rec.USER_GROUP);
                    IFSAPP.User_Group_Period_API.Close_Period(p1_ , p2_ );
                    IFSAPP.USER_GROUP_PERIOD_API.MODIFY__( p0_ , p1_ , p2_ , p3_ , p4_ );
                    
                END IF;
            END IF;
            
       END LOOP; 
       EXCEPTION
        WHEN OTHERS THEN
       raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
    END Vlt_Close_Grp_Period;

    PROCEDURE Vlt_Close_Period ( 
    company_in IN VARCHAR2, -- like 'company_in%
    accounting_year_in IN INTEGER,
    accounting_period_in IN INTEGER --if zero then it must close all the year periods
    )
    IS
       -- p0 -> __lsResult
       p0_ VARCHAR2(32000) := '';
       -- p1 -> __sObjid
       p1_ VARCHAR2(32000);
       -- p2 -> __lsObjversion
       p2_ VARCHAR2(32000);
       -- p3 -> __lsAttr
       p3_ VARCHAR2(32000) := 'PERIOD_STATUS_INT'||chr(31)||'Closed'||chr(30);
       -- p4 -> __sAction
       p4_ VARCHAR2(32000) := 'DO';
    
       BEGIN 
          
       FOR rec IN ( SELECT * FROM ACCOUNTING_PERIOD 
                    WHERE ACCOUNTING_YEAR = accounting_year_in 
                    AND COMPANY like company_in || '%'
                    ) 
       LOOP
        p0_ := '';
        p1_ := rec.objid;
        p2_ := rec.objversion;
        p3_ := 'PERIOD_STATUS_INT'||chr(31)||'Closed'||chr(30);
        p4_ := 'DO';
        
        IF rec.ACCOUNTING_PERIOD = accounting_period_in OR NVL(accounting_period_in,0)=0 THEN
            --DBMS_OUTPUT.put_line ('---> ' || rec.COMPANY || ' ' || rec.accounting_year || ' ' || rec.accounting_period);
            IFSAPP.ACCOUNTING_PERIOD_API.CLOSE_PERIOD(p1_ , p2_ );
            IFSAPP.ACCOUNTING_PERIOD_API.MODIFY__( p0_ , p1_ , p2_ , p3_ , p4_ );
        END IF;
       END LOOP; 
       EXCEPTION
        WHEN OTHERS THEN
       raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
    END Vlt_Close_Period;

PROCEDURE VltCloseAccountPeriods(inObjkey_ IN VARCHAR2, inUserId IN VARCHAR2)
IS

    GRP_SEL		           VARCHAR2(10);
      
    COMPANY_            VARCHAR2(20);
    ACCOUNTING_YEAR_    NUMBER;
    ACCOUNTING_PERIOD_  NUMBER;       
    USER_GROUP_AC_      VARCHAR2(10);
    USER_GROUP_AP_      VARCHAR2(10);
    USER_GROUP_AR_      VARCHAR2(10);
    USER_GROUP_EX_      VARCHAR2(10);
    USER_GROUP_TR_      VARCHAR2(10);
    USER_GROUP_ALL_     VARCHAR2(10);
    EXECUTED_BY_        VARCHAR2(30);
    EXECUTED_DATE_      DATE;
    
    USER_GROUP_AC_PAR   VARCHAR2(2);
    USER_GROUP_AP_PAR   VARCHAR2(2);
    USER_GROUP_AR_PAR   VARCHAR2(2);
    USER_GROUP_EX_PAR   VARCHAR2(2);
    USER_GROUP_TR_PAR   VARCHAR2(2);
    
    
    CURSOR get_line IS
    SELECT 
        CF$_COMPANY,
        CF$_ACCOUNTING_YEAR,
        CF$_ACCOUNTING_PERIOD,
        CF$_USER_GROUP_CB_AC,
        CF$_USER_GROUP_CB_AP,
        CF$_USER_GROUP_CB_AR,
        CF$_USER_GROUP_CB_EX,
        CF$_USER_GROUP_CB_TR,
        CF$_USER_GRP_CB_ALL,
        CF$_EXECUTED_BY,
        CF$_EXECUTED_DATE
    FROM vlt_close_periods_clv
    WHERE objkey=inObjkey_;
    
    BEGIN
    
    OPEN get_line;
    FETCH get_line INTO 
        COMPANY_,
        ACCOUNTING_YEAR_,
        ACCOUNTING_PERIOD_,
        USER_GROUP_AC_,
        USER_GROUP_AP_,
        USER_GROUP_AR_,
        USER_GROUP_EX_,
        USER_GROUP_TR_,
        USER_GROUP_ALL_,
        EXECUTED_BY_,
        EXECUTED_DATE_;
    CLOSE get_line;
    
    IF (USER_GROUP_AC_ = 'True') THEN
        USER_GROUP_AC_PAR := 'AC';
    ELSE
        USER_GROUP_AC_PAR := '';
    END IF;
    
    IF (USER_GROUP_AP_ = 'True') THEN
        USER_GROUP_AP_PAR := 'AP';
    ELSE
        USER_GROUP_AP_PAR := '';
    END IF;
    
    IF (USER_GROUP_AR_ = 'True') THEN
        USER_GROUP_AR_PAR := 'AR';
    ELSE
        USER_GROUP_AR_PAR := '';
    END IF;
    
    IF (USER_GROUP_EX_ = 'True') THEN
        USER_GROUP_EX_PAR := 'EX';
    ELSE
        USER_GROUP_EX_PAR := '';
    END IF;
    
    IF (USER_GROUP_TR_ = 'True') THEN
        USER_GROUP_TR_PAR := 'TR';
    ELSE
        USER_GROUP_TR_PAR := '';
    END IF;
    
    GRP_SEL := USER_GROUP_AC_PAR || USER_GROUP_AP_PAR || USER_GROUP_AR_PAR || USER_GROUP_EX_PAR || USER_GROUP_TR_PAR;
    
    IF	(LENGTH(NVL(COMPANY_,''))=0) THEN
        error_sys.Record_General('Error:  ','Incorrect Company.');
    END IF;
    
    IF	(NVL(ACCOUNTING_YEAR_,0)=0) THEN
        error_sys.Record_General('Error:  ','Incorrect Year.');
    END IF;
    
    IF	(NVL(ACCOUNTING_PERIOD_,-1) NOT IN (0,1,2,3,4,5,6,7,8,9,10,11,12,13)) THEN
        error_sys.Record_General('Error:  ','Incorrect Period.');
    END IF;
    
    IF (LENGTH(NVL(EXECUTED_BY_,'')) > 0 ) THEN
        error_sys.Record_General('Error:  ','Close already executed by ' || EXECUTED_BY_ || ' on ' || TO_CHAR(EXECUTED_DATE_, 'YYYY-MM-DD HH24:MI:SS') );
    ELSIF ((LENGTH(GRP_SEL) > 0) AND (USER_GROUP_ALL_ = 'True')) THEN 
        error_sys.Record_General('Error:  ','Invalid selection. ' || 'ALL=' || USER_GROUP_ALL_ || ' GRP_SEL=' || GRP_SEL);
    ELSIF ((LENGTH(GRP_SEL) = 0) AND (USER_GROUP_ALL_ = 'False')) THEN 
        error_sys.Record_General('Error:  ','Nothing to do. ' || 'ALL=' || USER_GROUP_ALL_ || ' GRP_SEL=' || GRP_SEL);
    ELSIF (USER_GROUP_ALL_ = 'True') THEN
        C_VOLTALIA_UTIL_API.Vlt_Close_Period (COMPANY_, ACCOUNTING_YEAR_, ACCOUNTING_PERIOD_);
        --DBMS_OUTPUT.put_line ('COMPANY_= ' || COMPANY_|| ' ACCOUNTING_YEAR_= ' || ACCOUNTING_YEAR_ || ' ACCOUNTING_PERIOD_ = ' || ACCOUNTING_PERIOD_);
        UPDATE VLT_CLOSE_PERIODS_CLT SET CF$_EXECUTED_BY=inUserId, CF$_EXECUTED_DATE=SYSDATE WHERE ROWKEY=inObjkey_;
    ELSIF ((LENGTH(GRP_SEL) > 0)) THEN
        C_VOLTALIA_UTIL_API.Vlt_Close_Grp_Period(COMPANY_,ACCOUNTING_YEAR_,ACCOUNTING_PERIOD_,
            USER_GROUP_AC_PAR,
            USER_GROUP_AP_PAR,
            USER_GROUP_AR_PAR,
            USER_GROUP_EX_PAR,
            USER_GROUP_TR_PAR
            );
        --DBMS_OUTPUT.put_line ('COMPANY_= ' || COMPANY_|| ' ACCOUNTING_YEAR_= ' || ACCOUNTING_YEAR_ || ' ACCOUNTING_PERIOD_ = ' || ACCOUNTING_PERIOD_ || ' USER_GROUP_ALL_=' || USER_GROUP_ALL_ || ' GRP_SEL=' || GRP_SEL);
        UPDATE VLT_CLOSE_PERIODS_CLT SET CF$_EXECUTED_BY=inUserId, CF$_EXECUTED_DATE=SYSDATE WHERE ROWKEY=inObjkey_;
    ELSE
        error_sys.Record_General('Error:  ','Something went wrong. ' || 'ALL=' || USER_GROUP_ALL_ || ' GRP_SEL=' || GRP_SEL || ' USER_GROUP_ALL_=' || USER_GROUP_ALL_);
    END IF;

END VltCloseAccountPeriods;

--Extract permissions
FUNCTION Vlt_CheckDupSupplierName(inSupplierName IN VARCHAR2)  
RETURN VARCHAR2 
IS 
    retValue1 VARCHAR2(100) := '';
    retSuppCode VARCHAR2(10) := '';

    cleanInSupplierName VARCHAR2(100)   := UPPER(NVL(REPLACE(inSupplierName,chr(32),''),''));

BEGIN
--test incoming supplier NAME with the existing NAMEs on the database
IF LENGTH(cleanInSupplierName) > 0 THEN
    SELECT 
    si.supplier_id, si.name into retSuppCode, retValue1
    FROM    supplier_info si
    WHERE INSTR(UPPER(REPLACE(si.name,chr(32),'')),cleanInSupplierName) > 0
    AND LENGTH(REPLACE(si.name,chr(32),'')) >0
    AND ROWNUM = 1
    ;
END IF;

RETURN 'ID=' || retSuppCode || '; DUP=' || retValue1;

END;

FUNCTION Vlt_CheckDupSupplierAddress(inSupplierAddress IN VARCHAR2)  
RETURN VARCHAR2 
IS 
    retValue1 VARCHAR2(100) := '';
    retSuppCode VARCHAR2(10) := '';

    cleanInSupplierAddress VARCHAR2(100):= UPPER(NVL(REPLACE(REPLACE(inSupplierAddress,chr(46),''),chr(32),''),''));

BEGIN

IF (LENGTH(cleanInSupplierAddress) > 0) THEN
    SELECT sia.supplier_id, sia.address into retSuppCode,retValue1
    FROM  supplier_info_address sia
    WHERE INSTR(UPPER(REPLACE(REPLACE(sia.address,chr(46),''),chr(32),'')),cleanInSupplierAddress) > 0
    AND ROWNUM = 1
    ;
END IF;

RETURN 'ID=' || retSuppCode || '; DUP=' || retValue1;

END;

FUNCTION Vlt_CheckDupSupplierVAT(inVATFreeVATCode IN VARCHAR2)  
RETURN VARCHAR2 
IS 
    retValue1 VARCHAR2(100) := '';
    retSuppCode VARCHAR2(10) := '';

    cleanInVATFreeVATCode VARCHAR2(100) := UPPER(NVL(REPLACE(inVATFreeVATCode,chr(32),''),''));


BEGIN
--test incoming VAT CODE with the existing ASSOCIATION NO on the database
IF (LENGTH(cleanInVATFreeVATCode) > 0) THEN
    SELECT 
    si.supplier_id,si.association_no into retSuppCode,retValue1
    FROM    supplier_info si
    WHERE INSTR(UPPER(REPLACE(si.association_no,chr(32),'')),cleanInVATFreeVATCode) > 0
    AND LENGTH(si.association_no) >0
    AND ROWNUM = 1
    ;
END IF;

RETURN 'ID=' || retSuppCode || '; DUP=' || retValue1;

END;

FUNCTION Vlt_CheckDupSupplierAssNo(inAssociation_no IN VARCHAR2)  
RETURN VARCHAR2 
IS 
    retValue1 VARCHAR2(100) := '';
    retSuppCode VARCHAR2(10) := '';

    cleanInAssociation_no VARCHAR2(100) := UPPER(NVL(REPLACE(inAssociation_no,chr(32),''),''));

BEGIN
--test incoming ASSOCIATION NO with the existing ones on the database
IF ((LENGTH(retValue1) = 0) AND (LENGTH(cleanInAssociation_no) > 0)) THEN
    SELECT 
    si.supplier_id,si.association_no into retSuppCode,retValue1
    FROM    supplier_info si
    WHERE INSTR(UPPER(REPLACE(si.association_no,chr(32),'')),cleanInAssociation_no) > 0
    AND LENGTH(si.association_no) >0
    AND ROWNUM = 1
    ;
END IF;
RETURN 'ID=' || retSuppCode || '; DUP=' || retValue1;
END;

--DROP TABLE vlt_ifs_log;
--CREATE TABLE vlt_ifs_log (log_id      NUMBER        GENERATED BY DEFAULT ON NULL AS IDENTITY, logObject VARCHAR2(30), loguser VARCHAR2(128) DEFAULT USER, ts TIMESTAMP DEFAULT SYSDATE, msg VARCHAR2(4000));

--DROP TABLE vlt_ifs_log_status;
--CREATE TABLE vlt_ifs_log_status (logObject VARCHAR2(30), isActivated VARCHAR2(5) default 'FALSE');

PROCEDURE vlt_ifs_log_enable(inObject VARCHAR2) IS
BEGIN
  DELETE FROM vlt_ifs_log_status WHERE logObject = UPPER(inObject);
  INSERT INTO vlt_ifs_log_status (isActivated,logObject) VALUES ('TRUE',UPPER(inObject));
  COMMIT;
END vlt_ifs_log_enable;

PROCEDURE vlt_ifs_log_disable(inObject VARCHAR2) IS
BEGIN
  DELETE FROM vlt_ifs_log_status WHERE logObject = UPPER(inObject);
  INSERT INTO vlt_ifs_log_status (isActivated,logObject) VALUES ('FALSE',UPPER(inObject));
  COMMIT;
END vlt_ifs_log_disable;

FUNCTION Vlt_Check_ifs_log_for_object(inObject VARCHAR2) RETURN VARCHAR2
IS
    retVAL vlt_ifs_log_status.isActivated%TYPE;
BEGIN
    SELECT UPPER(isActivated) INTO retVAL 
    FROM vlt_ifs_log_status
    WHERE logObject = UPPER(inObject);
    RETURN retVAL;
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        retVAL := 'NOOBJ';
        RETURN retVAL;
    
END Vlt_Check_ifs_log_for_object;

PROCEDURE vlt_log_ifs (msg IN VARCHAR2, inObject VARCHAR2, startClean INTEGER) IS
PRAGMA AUTONOMOUS_TRANSACTION; 
BEGIN
    CASE Vlt_Check_ifs_log_for_object(inObject)
        WHEN 'TRUE' THEN
            IF startClean = 1 THEN
                DELETE FROM vlt_ifs_log WHERE 1=1;
            END IF;
            INSERT INTO vlt_ifs_log (logObject,msg) VALUES (UPPER(inObject), SUBSTR(vlt_log_ifs.msg, 1, 4000));
            COMMIT;
        WHEN 'FALSE' THEN
            NULL;
        ELSE RAISE NO_DATA_FOUND;
    END CASE;
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         INSERT INTO vlt_ifs_log (logObject,msg) VALUES (UPPER(inObject), 'Invalid Object to Log' );
         COMMIT;
    
END vlt_log_ifs;

--CALL vlt_ifs_log_enable('Vlt_GetModelByObjkey');

FUNCTION Vlt_GetModelByObjkey(inObjkey VARCHAR2) RETURN VARCHAR2
IS
    retVAL VLT_AUTH_STRUCTURE_MODEL_CLV.cf$_model_id%TYPE;
BEGIN
    vlt_log_ifs('start proc','Vlt_GetModelByObjkey',0);
    SELECT cf$_model_id INTO retVAL FROM VLT_AUTH_STRUCTURE_MODEL_CLV where objid=inObjkey ;
    RETURN retVAL;
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        retVAL := 'NOTFOUND';
        RETURN retVAL;
    
END Vlt_GetModelByObjkey;

--CALL vlt_ifs_log_enable('vlt_GetRuleID');
/*
FUNCTION vlt_GetRuleID(inTemplateID VARCHAR2) RETURN VARCHAR2
IS
    retVAL VARCHAR2(20);
    seed_ VARCHAR2(20) := inTemplateID;
BEGIN
    vlt_log_ifs('start proc','vlt_GetRuleID',0);
SELECT seed_ || LPAD((NVL(x.lastNum,0)+1),2,'0') into retVAL from
(
    SELECT  MAX(substr(APPROVAL_RULE,9,length(APPROVAL_RULE))*1) as lastNum
    FROM pur_approval_rule PUR_APPROVAL_RULE 
    WHERE APPROVAL_RULE LIKE seed_ || '%')  x
;
    
    IF retVAL IS NULL THEN
        retVAL := seed_ || '01';
    END IF;
 
    RETURN retVAL;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            retVAL := seed_ || '01';
            RETURN retVAL;
        
END vlt_GetRuleID;
*/

FUNCTION vlt_GetRuleID(inTemplateID VARCHAR2) RETURN VARCHAR2
IS
    retVAL VARCHAR2(20);
    seed_ VARCHAR2(20) := inTemplateID;
    hex_ VARCHAR2(2);
    dec_ NUMBER;
    
BEGIN
    vlt_log_ifs('start proc','vlt_GetRuleID',0);
SELECT seed_ || LPAD(TRIM(TO_CHAR((NVL(x.lastNum,0)+1),'XXXXXXXXX')),2,'0') into retVAL from
(
    SELECT  TO_NUMBER(MAX(substr(APPROVAL_RULE,9,length(APPROVAL_RULE))*1),'XXXXXXXX') as lastNum
    FROM pur_approval_rule PUR_APPROVAL_RULE 
    WHERE APPROVAL_RULE LIKE seed_ || '%')  x
;
    
    IF retVAL IS NULL THEN
        retVAL := seed_ || '01';
    END IF;
 
    RETURN retVAL;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            retVAL := seed_ || '01';
            RETURN retVAL;
        
END vlt_GetRuleID;

--CALL vlt_ifs_log_enable('vlt_GetModelMin');

FUNCTION vlt_GetModelMin(inModelID VARCHAR2, inLevel NUMBER) RETURN NUMBER
IS
    retVAL NUMBER;

BEGIN
    vlt_log_ifs('start proc','vlt_GetModelMin',0);
    SELECT cf$_min_amount INTO retVAL
    FROM VLT_AUTH_STRUCTURE_MODEL_CLV 
    WHERE cf$_model_id=inModelID
    AND cf$_level_db=inLevel
    ;

    RETURN retVAL;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            retVAL := -1;
            RETURN retVAL;
        
END vlt_GetModelMin;

--CALL vlt_ifs_log_enable('vlt_GetModelMax');

FUNCTION vlt_GetModelMax(inModelID VARCHAR2, inLevel NUMBER) RETURN NUMBER
IS
    retVAL NUMBER;

BEGIN
    vlt_log_ifs('start proc','vlt_GetModelMax',0);
    SELECT NVL(cf$_max_amount,pkg_MAXVALUE_) INTO retVAL
    FROM VLT_AUTH_STRUCTURE_MODEL_CLV 
    WHERE cf$_model_id=inModelID
    AND cf$_level_db=inLevel
    ;

    RETURN retVAL;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            retVAL := -1;
            RETURN retVAL;
        
END vlt_GetModelMax;

--CALL vlt_ifs_log_enable('vlt_GetSite');

FUNCTION vlt_GetSite(inCompany VARCHAR2) RETURN VARCHAR2
IS
    retVAL VARCHAR2(20);

BEGIN
    vlt_log_ifs('start proc','vlt_GetModelMax',0);
    RETURN SUBSTR(inCompany,1,2) || SUBSTR(inCompany,4,3);
            
END vlt_GetSite;

--CALL vlt_ifs_log_enable('vlt_GetPriority');

FUNCTION vlt_GetPriority(inProject_Category VARCHAR2) RETURN NUMBER
IS
    retVAL NUMBER;
    border_ NUMBER := 100000;

BEGIN
    vlt_log_ifs('start proc','vlt_GetPriority',0);
    IF inProject_Category IS NOT NULL THEN 
        SELECT MAX(TEMP_PRIORITY) INTO retVAL FROM PUR_APPROVAL_RULE 
        WHERE TEMP_PRIORITY >= border_ ;
    ELSE
        SELECT MAX(TEMP_PRIORITY) INTO retVAL FROM PUR_APPROVAL_RULE 
        WHERE TEMP_PRIORITY < border_ ;
    END IF;

    IF retVAL IS NULL THEN
        retVAL := 0;
    END IF;

    RETURN retVAL+1;
            
END vlt_GetPriority;

--CALL vlt_ifs_log_enable('vlt_CheckExistingPOAuthRule');

FUNCTION vlt_CheckExistingPOAuthRule(inCompany VARCHAR2, inMinAmount NUMBER,inMaxAmount NUMBER,inTemplate_ID VARCHAR2, inSite VARCHAR2) 
RETURN VARCHAR2
IS
    retVAL_ pur_approval_rule_tab.approval_rule%TYPE;

BEGIN
    vlt_log_ifs('start proc','vlt_CheckExistingPOAuthRule',0);

    SELECT approval_rule INTO retVAL_ 
         FROM pur_approval_rule_tab
         WHERE template_id=inTemplate_ID
         AND NVL(min_amount,0)=inMinAmount
         AND NVL(max_amount,pkg_MAXVALUE_)=inMaxAmount
         AND company=inCompany
         AND contract=inSite
         ;

    IF retVAL_ IS NULL THEN
        retVAL_ := 'NONE';
    END IF;

vlt_log_ifs('retVAL_=' || retVAL_,'vlt_CheckExistingPOAuthRule',0);

    RETURN retVAL_;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        retVAL_ := 'NONE';
vlt_log_ifs('retVALEX_=' || retVAL_,'vlt_CheckExistingPOAuthRule',0);
        RETURN retVAL_;
        
END vlt_CheckExistingPOAuthRule;

--CALL vlt_ifs_log_enable('Vlt_CreatePOAuthRuleCat1Tab');

PROCEDURE Vlt_CreatePOAuthRuleCat1Tab(inApprovalRule VARCHAR2, inCompany VARCHAR2, inCategory_DB VARCHAR2) 
IS 
    code_g_                 CODE_G.code_g%type;
    info_                   varchar2(4000) := '';
    objid_                  varchar2(200) := '';
    objversion_             varchar2(200) := '';
    row_attr_               varchar2(32000) := '';
BEGIN
    vlt_log_ifs('start proc','Vlt_CreatePOAuthRuleCat1Tab',0);
    
SELECT code_g INTO code_g_ FROM CODE_G WHERE objkey=inCategory_DB;    

    Client_SYS.Clear_Attr(row_attr_);
    Client_SYS.Add_To_Attr('APPROVAL_RULE'              ,inApprovalRule,row_attr_);
    Client_SYS.Add_To_Attr('COMPANY'                    ,inCompany,row_attr_);
    Client_SYS.Add_To_Attr('CATEGORY1_ID'               ,code_g_,row_attr_);
    
    vlt_log_ifs('row_attr_=' || row_attr_,'Vlt_CreatePOAuthRuleCat1Tab',0);
    
    PUR_ORD_RULE_PROJ_CAT1_API.NEW__( info_ , objid_ , objversion_ , row_attr_ , 'DO' );
    COMMIT;
   
END Vlt_CreatePOAuthRuleCat1Tab;

--CALL vlt_ifs_log_enable('Vlt_CreatePOAuthRuleProjTab');

PROCEDURE Vlt_CreatePOAuthRuleProjTab(inApprovalRule VARCHAR2, inCompany VARCHAR2, inProject_DB VARCHAR2) 
IS 
    project_id_             PROJECT.project_id%type;
    info_                   varchar2(4000) := '';
    objid_                  varchar2(200) := '';
    objversion_             varchar2(200) := '';
    row_attr_               varchar2(32000) := '';
BEGIN
    vlt_log_ifs('start proc','Vlt_CreatePOAuthRuleProjTab',0);
    
SELECT PROJECT_ID INTO project_id_ FROM PROJECT WHERE objkey=inProject_DB;    

    Client_SYS.Clear_Attr(row_attr_);
    Client_SYS.Add_To_Attr('APPROVAL_RULE'              ,inApprovalRule,row_attr_);
    Client_SYS.Add_To_Attr('COMPANY'                    ,inCompany,row_attr_);
    Client_SYS.Add_To_Attr('PROJECT_ID'                 ,project_id_,row_attr_);

    vlt_log_ifs('row_attr_=' || row_attr_,'Vlt_CreatePOAuthRuleProjTab',0);

    PUR_ORD_RULE_PROJECT_API.NEW__( info_ , objid_ , objversion_ , row_attr_ , 'DO' );
    COMMIT;
        
END Vlt_CreatePOAuthRuleProjTab;


--CALL vlt_ifs_log_enable('Vlt_CreatePOAuthRule');

PROCEDURE Vlt_CreatePOAuthRule(inROWKEY VARCHAR2,inCompany VARCHAR2,inApproval_Rule VARCHAR2, inMinAmount NUMBER,inMaxAmount NUMBER,inTemplate_ID VARCHAR2, inSite VARCHAR2, 
inProject_Category_db VARCHAR2, inProject_db VARCHAR2) 
IS     
    info_                   varchar2(4000) := '';
    objid_                  varchar2(200) := '';
    objversion_             varchar2(200) := '';
    row_attr_               varchar2(32000) := '';
    check_existent_         varchar2(10) := '';
    priority_               PUR_APPROVAL_RULE.temp_priority%TYPE;
    isRegardlessCat_        PUR_APPROVAL_RULE.apply_to_proj_cat1%type;
    isRegardlessProj_       PUR_APPROVAL_RULE.apply_to_proj_id%type;
    
BEGIN
    vlt_log_ifs('start proc','Vlt_CreatePOAuthRule',0);
    priority_ :=  vlt_GetPriority(inProject_Category_db);
    vlt_log_ifs('Vlt_CreatePOAuthRule.priority_=' || priority_,'Vlt_CreatePOAuthRule',0);

    check_existent_ := vlt_CheckExistingPOAuthRule(inCompany, inMinAmount, inMaxAmount, inTemplate_ID, inSite);
    
    IF check_existent_ = 'NONE' THEN
        vlt_log_ifs('inCompany=' || inCompany,'Vlt_CreatePOAuthRule',0);
        vlt_log_ifs('inApproval_Rule=' || inApproval_Rule,'Vlt_CreatePOAuthRule',0);
        vlt_log_ifs('priority_=' || priority_,'Vlt_CreatePOAuthRule',0);
        vlt_log_ifs('inMinAmount=' || inMinAmount,'Vlt_CreatePOAuthRule',0);
        vlt_log_ifs('inMaxAmount=' || inMaxAmount,'Vlt_CreatePOAuthRule',0);
        vlt_log_ifs('inTemplate_ID=' || inTemplate_ID,'Vlt_CreatePOAuthRule',0);
        vlt_log_ifs('inSite=' || inSite,'Vlt_CreatePOAuthRule',0);
  
        IF inProject_Category_db IS NOT NULL THEN
            isRegardlessCat_ := 'False';
            isRegardlessProj_ := 'True';
        ELSIF inProject_db IS NOT NULL THEN 
            isRegardlessCat_ := 'True';
            isRegardlessProj_ := 'False';
        END IF;
        
        Client_SYS.Clear_Attr(row_attr_);
        Client_SYS.Add_To_Attr('APPROVAL_RULE'               ,inApproval_Rule,row_attr_);
        Client_SYS.Add_To_Attr('TEMP_PRIORITY'               ,priority_,row_attr_);
        Client_SYS.Add_To_Attr('MIN_AMOUNT'                  ,inMinAmount,row_attr_);
        Client_SYS.Add_To_Attr('MAX_AMOUNT'                  ,inMaxAmount,row_attr_);
        Client_SYS.Add_To_Attr('COMPANY'                     ,inCompany,row_attr_);
        Client_SYS.Add_To_Attr('TEMPLATE_ID'                 ,inTemplate_ID,row_attr_);
        Client_SYS.Add_To_Attr('CONTRACT'                    ,inSite,row_attr_);
        Client_SYS.Add_To_Attr('ALLOW_CHANGES_TO_PO'         ,'No Changes Allowed',row_attr_);
        Client_SYS.Add_To_Attr('USE_AMOUNTS_INCL_TAX'        ,'False',row_attr_);
        Client_SYS.Add_To_Attr('INCL_ALL_STEPS_IN_AUTH'      ,'True',row_attr_);
        Client_SYS.Add_To_Attr('USE_DELTA_FOR_PO_CO'         ,'False',row_attr_);
        Client_SYS.Add_To_Attr('VALID_ORIGINAL_AUTH'         ,'True',row_attr_);
        Client_SYS.Add_To_Attr('VALID_CHG_ORD_AUTH'          ,'True',row_attr_);
        Client_SYS.Add_To_Attr('INCL_CHARGES_IN_PO_AUTH'     ,'False',row_attr_);
        Client_SYS.Add_To_Attr('APPLY_TO_BUYERS'             ,'True',row_attr_);
        Client_SYS.Add_To_Attr('APPLY_TO_SUPPLIERS'          ,'True',row_attr_);
        Client_SYS.Add_To_Attr('APPLY_TO_SUPP_STAT_GROUPS'   ,'True',row_attr_);
        Client_SYS.Add_To_Attr('APPLY_TO_COORDINATORS'       ,'True',row_attr_);
        Client_SYS.Add_To_Attr('APPLY_TO_NON_PROJECT'        ,'True',row_attr_);
        Client_SYS.Add_To_Attr('APPLY_TO_PROJ_CAT1'          ,isRegardlessCat_,row_attr_);
        Client_SYS.Add_To_Attr('APPLY_TO_PROJ_CAT2'          ,'True',row_attr_);
        Client_SYS.Add_To_Attr('APPLY_TO_PROJ_ID'            ,isRegardlessProj_,row_attr_);
        Client_SYS.Add_To_Attr('NOTE_TEXT'                   ,'',row_attr_);
        
        vlt_log_ifs('row_attr_=' || row_attr_,'Vlt_CreatePOAuthRule',0);
        
        PUR_APPROVAL_RULE_API.NEW__( info_ , objid_ , objversion_ , row_attr_ , 'DO' );
        COMMIT;
    
        --insert Project category tab or project tab
        IF inProject_Category_db IS NOT NULL THEN
           Vlt_CreatePOAuthRuleCat1Tab(inApproval_Rule, inCompany, inProject_Category_db);
        ELSIF inProject_db IS NOT NULL THEN 
           Vlt_CreatePOAuthRuleProjTab(inApproval_Rule, inCompany, inProject_db);
        END IF;
    ELSE
        --add Project category tab or project tab to existent approval rule
        IF inProject_Category_db IS NOT NULL THEN
           Vlt_CreatePOAuthRuleCat1Tab(check_existent_, inCompany, inProject_Category_db);
        ELSIF inProject_db IS NOT NULL THEN 
           Vlt_CreatePOAuthRuleProjTab(check_existent_, inCompany, inProject_db);
        END IF;
    END IF;
        
END Vlt_CreatePOAuthRule;

--CALL vlt_ifs_log_enable('Vlt_CreatePOAuthRuleGeneralTab');

PROCEDURE Vlt_CreatePOAuthRuleGeneralTab(inROWKEY VARCHAR2) 
IS 
    auth_Struct_Tool_   VLT_AUTH_STRUCTURE_TOOL_CLV%ROWTYPE;
    approval_Rule_      PUR_APPROVAL_RULE.approval_rule%TYPE;
    priority_           PUR_APPROVAL_RULE.temp_priority%TYPE;
    minAmount_          PUR_APPROVAL_RULE.min_amount%TYPE;
    maxAmount_          PUR_APPROVAL_RULE.max_amount%TYPE;
    site_               PUR_APPROVAL_RULE.contract%TYPE;
       
BEGIN
    vlt_log_ifs('start proc','Vlt_CreatePOAuthRuleGeneralTab',0);
    SELECT * INTO auth_Struct_Tool_
    FROM VLT_AUTH_STRUCTURE_TOOL_CLV 
    WHERE objkey = inROWKEY;   
   
   --set inSite
        site_ := vlt_GetSite(auth_Struct_Tool_.CF$_COMPANY);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.site_=' || site_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   
    IF auth_Struct_Tool_.cf$_template1 IS NOT NULL THEN
   
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.cf$_template1=' || auth_Struct_Tool_.cf$_template1,'Vlt_CreatePOAuthRuleGeneralTab',0);
   
   --set inMinAmount
        minAmount_ := vlt_GetModelMin(auth_Struct_Tool_.cf$_model, 1);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.minAmount_=' || minAmount_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --set inMaxAmount
        maxAmount_ := vlt_GetModelMax(auth_Struct_Tool_.cf$_model, 1);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.maxAmount_=' || maxAmount_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --set inApproval_Rule
        approval_Rule_ := vlt_GetRuleID(auth_Struct_Tool_.cf$_template1);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.approval_Rule_=' || approval_Rule_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --insert Rule
        Vlt_CreatePOAuthRule(inROWKEY, auth_Struct_Tool_.cf$_company, approval_Rule_, minAmount_, maxAmount_, 
        auth_Struct_Tool_.cf$_template1, site_, auth_Struct_Tool_.cf$_project_category_db, auth_Struct_Tool_.cf$_project_db ); 
    END IF;
   
    IF auth_Struct_Tool_.cf$_template2 IS NOT NULL THEN
   
   vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.cf$_template2=' || auth_Struct_Tool_.cf$_template2,'Vlt_CreatePOAuthRuleGeneralTab',0);
   
   --set inMinAmount
        minAmount_ := vlt_GetModelMin(auth_Struct_Tool_.cf$_model, 2);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.minAmount_=' || minAmount_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --set inMaxAmount
        maxAmount_ := vlt_GetModelMax(auth_Struct_Tool_.cf$_model, 2);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.maxAmount_=' || maxAmount_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --set inApproval_Rule
        approval_Rule_ := vlt_GetRuleID(auth_Struct_Tool_.cf$_template2);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.approval_Rule_=' || approval_Rule_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --insert Rule
        Vlt_CreatePOAuthRule(inROWKEY, auth_Struct_Tool_.cf$_company, approval_Rule_, minAmount_, maxAmount_, 
        auth_Struct_Tool_.cf$_template2, site_, auth_Struct_Tool_.cf$_project_category_db, auth_Struct_Tool_.cf$_project_db ); 
    END IF;
   
    IF auth_Struct_Tool_.cf$_template3 IS NOT NULL THEN
   
   vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.cf$_template3=' || auth_Struct_Tool_.cf$_template3,'Vlt_CreatePOAuthRuleGeneralTab',0);
   
   --set inMinAmount
        minAmount_ := vlt_GetModelMin(auth_Struct_Tool_.cf$_model, 3);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.minAmount_=' || minAmount_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --set inMaxAmount
        maxAmount_ := vlt_GetModelMax(auth_Struct_Tool_.cf$_model, 3);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.maxAmount_=' || maxAmount_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --set inApproval_Rule
        approval_Rule_ := vlt_GetRuleID(auth_Struct_Tool_.cf$_template3);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.approval_Rule_=' || approval_Rule_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --insert Rule
        Vlt_CreatePOAuthRule(inROWKEY, auth_Struct_Tool_.cf$_company, approval_Rule_, minAmount_, maxAmount_, 
        auth_Struct_Tool_.cf$_template3, site_, auth_Struct_Tool_.cf$_project_category_db, auth_Struct_Tool_.cf$_project_db ); 
    END IF;
   
   IF auth_Struct_Tool_.cf$_template4 IS NOT NULL THEN
   
   vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.cf$_template4=' || auth_Struct_Tool_.cf$_template4,'Vlt_CreatePOAuthRuleGeneralTab',0);
   
   --set inMinAmount
        minAmount_ := vlt_GetModelMin(auth_Struct_Tool_.cf$_model, 4);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.minAmount_=' || minAmount_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --set inMaxAmount
        maxAmount_ := vlt_GetModelMax(auth_Struct_Tool_.cf$_model, 4);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.maxAmount_=' || maxAmount_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --set inApproval_Rule
        approval_Rule_ := vlt_GetRuleID(auth_Struct_Tool_.cf$_template4);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.approval_Rule_=' || approval_Rule_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --insert Rule
        Vlt_CreatePOAuthRule(inROWKEY, auth_Struct_Tool_.cf$_company, approval_Rule_, minAmount_, maxAmount_, 
        auth_Struct_Tool_.cf$_template4, site_, auth_Struct_Tool_.cf$_project_category_db, auth_Struct_Tool_.cf$_project_db ); 
   END IF;
   
   IF auth_Struct_Tool_.cf$_template5 IS NOT NULL THEN
   
   vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.cf$_template5=' || auth_Struct_Tool_.cf$_template5,'Vlt_CreatePOAuthRuleGeneralTab',0);
   
   --set inMinAmount
        minAmount_ := vlt_GetModelMin(auth_Struct_Tool_.cf$_model, 5);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.minAmount_=' || minAmount_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --set inMaxAmount
        maxAmount_ := vlt_GetModelMax(auth_Struct_Tool_.cf$_model, 5);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.maxAmount_=' || maxAmount_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --set inApproval_Rule
        approval_Rule_ := vlt_GetRuleID(auth_Struct_Tool_.cf$_template5);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.approval_Rule_=' || approval_Rule_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --insert Rule
        Vlt_CreatePOAuthRule(inROWKEY, auth_Struct_Tool_.cf$_company, approval_Rule_, minAmount_, maxAmount_, 
        auth_Struct_Tool_.cf$_template5, site_, auth_Struct_Tool_.cf$_project_category_db, auth_Struct_Tool_.cf$_project_db ); 
   END IF;
   
   IF auth_Struct_Tool_.cf$_template6 IS NOT NULL THEN
   
   vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.cf$_template6=' || auth_Struct_Tool_.cf$_template6,'Vlt_CreatePOAuthRuleGeneralTab',0);
   
   --set inMinAmount
        minAmount_ := vlt_GetModelMin(auth_Struct_Tool_.cf$_model, 6);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.minAmount_=' || minAmount_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --set inMaxAmount
        maxAmount_ := vlt_GetModelMax(auth_Struct_Tool_.cf$_model, 6);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.maxAmount_=' || maxAmount_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --set inApproval_Rule
        approval_Rule_ := vlt_GetRuleID(auth_Struct_Tool_.cf$_template6);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.approval_Rule_=' || approval_Rule_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --insert Rule
        Vlt_CreatePOAuthRule(inROWKEY, auth_Struct_Tool_.cf$_company, approval_Rule_, minAmount_, maxAmount_, 
        auth_Struct_Tool_.cf$_template6, site_, auth_Struct_Tool_.cf$_project_category_db, auth_Struct_Tool_.cf$_project_db ); 
   END IF;
   
   IF auth_Struct_Tool_.cf$_template7 IS NOT NULL THEN
   
   vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.cf$_template7=' || auth_Struct_Tool_.cf$_template7,'Vlt_CreatePOAuthRuleGeneralTab',0);
   
   --set inMinAmount
        minAmount_ := vlt_GetModelMin(auth_Struct_Tool_.cf$_model, 7);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.minAmount_=' || minAmount_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --set inMaxAmount
        maxAmount_ := vlt_GetModelMax(auth_Struct_Tool_.cf$_model, 7);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.maxAmount_=' || maxAmount_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --set inApproval_Rule
        approval_Rule_ := vlt_GetRuleID(auth_Struct_Tool_.cf$_template7);
        vlt_log_ifs('Vlt_CreatePOAuthRuleGeneralTab.approval_Rule_=' || approval_Rule_,'Vlt_CreatePOAuthRuleGeneralTab',0);
   --insert Rule
        Vlt_CreatePOAuthRule(inROWKEY, auth_Struct_Tool_.cf$_company, approval_Rule_, minAmount_, maxAmount_, 
        auth_Struct_Tool_.cf$_template7, site_, auth_Struct_Tool_.cf$_project_category_db, auth_Struct_Tool_.cf$_project_db ); 
   END IF;
   
END Vlt_CreatePOAuthRuleGeneralTab;

--CALL vlt_ifs_log_enable('vlt_GetTemplateID');

FUNCTION vlt_GetTemplateID(inCompany VARCHAR2) RETURN VARCHAR2
IS
    retVAL VARCHAR2(20);
    var_rows NUMBER;
BEGIN
    vlt_log_ifs('start proc','vlt_GetTemplateID',0);
    SELECT SUBSTR(inCompany,1,2) || SUBSTR(inCompany,4,3) || LPAD((NVL(x.nextNum,0)+1),3,'0') into retVAL from
    (
        SELECT  MAX(substr(template_id,7,length(template_id))*1) as nextNum
        FROM PUR_APPROVAL_TEMPL_LINE 
        WHERE company=inCompany)  x
    ;
    RETURN retVAL;
    
    IF retVAL IS NULL THEN
        retVAL := inCompany || '001';
    END IF;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        retVAL := inCompany || '001';
        RETURN retVAL;
        
END vlt_GetTemplateID;

--CALL vlt_ifs_log_enable('Vlt_GetCompanyByObjkey');

FUNCTION Vlt_GetCompanyByObjkey(inObjkey VARCHAR2) RETURN VARCHAR2
IS
    retVAL company.company%TYPE;
BEGIN
    vlt_log_ifs('start proc','Vlt_GetCompanyByObjkey',0);
    SELECT cmp.company INTO retVAL FROM company cmp WHERE cmp.objkey=inObjkey;
    RETURN retVAL;
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        retVAL := 'NOTFOUND';
        RETURN retVAL;
    
END Vlt_GetCompanyByObjkey;

--CALL vlt_ifs_log_enable('Vlt_GetPersonByObjkey');

FUNCTION Vlt_GetPersonByObjkey(inObjkey VARCHAR2) RETURN VARCHAR2
IS
    retVAL person_info.person_id%TYPE;
BEGIN
    vlt_log_ifs('start proc','Vlt_GetPersonByObjkey',0);
    SELECT pi.person_id INTO retVAL FROM person_info pi WHERE pi.objkey=inObjkey;
    RETURN retVAL;
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        retVAL := 'NOTFOUND';
        RETURN retVAL;
    
END Vlt_GetPersonByObjkey;

FUNCTION vlt_GetLevel10(inCompany IN VARCHAR2, inUser1 IN VARCHAR2) RETURN VARCHAR2
IS
    retVal1_ pur_approval_templ_line.template_id%TYPE;
BEGIN
    SELECT APL.TEMPLATE_ID INTO retVal1_
    FROM PUR_APPROVAL_TEMPL_LINE APL
    WHERE APL.COMPANY = inCompany
    AND APL.approval_level_db='INDIVIDUAL'
    AND APL.AUTHORIZATION_ROLE_TYPE_DB='AUTHORIZER'
    AND apl.authorize_id = inUser1
    --AND apl.line_no = 10
    AND apl.route = 10
    AND ROWNUM = 1
    ORDER BY company,template_id,line_no,authorize_id
    ;     
    RETURN retVal1_;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            retVal1_ := 'NOTFOUND';
            RETURN retVal1_;
    
END vlt_GetLevel10;

FUNCTION vlt_GetLevel20(inCompany IN VARCHAR2, inUser1 IN VARCHAR2, inUser2 IN VARCHAR2)  RETURN VARCHAR2
IS
    retVal1_ pur_approval_templ_line.template_id%TYPE;
BEGIN
        SELECT APL2.TEMPLATE_ID INTO retVal1_
        FROM PUR_APPROVAL_TEMPL_LINE APL1, PUR_APPROVAL_TEMPL_LINE APL2
        WHERE APL1.COMPANY = inCompany
        AND APL1.approval_level_db='INDIVIDUAL'
        AND APL1.AUTHORIZATION_ROLE_TYPE_DB='AUTHORIZER'
        AND APL1.authorize_id = inUser1
        AND APL2.COMPANY = APL1.COMPANY 
        AND APL2.approval_level_db = APL1.approval_level_db
        AND APL2.AUTHORIZATION_ROLE_TYPE_DB = APL1.AUTHORIZATION_ROLE_TYPE_DB
        AND APL2.authorize_id = inUser2
        --AND apl2.line_no = 20
        AND apl2.route = 20
        AND APL2.TEMPLATE_ID = apl1.template_id
        AND ROWNUM = 1
        ;
        RETURN retVal1_;
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                retVal1_ := 'NOTFOUND';
                RETURN retVal1_;
        
END vlt_GetLevel20;

--CALL vlt_ifs_log_enable('Vlt_GetApprovalTemplate');

FUNCTION Vlt_GetApprovalTemplate(inCompany VARCHAR2, inUser1 VARCHAR2, inUser2 VARCHAR2) RETURN VARCHAR2
IS
    retVal1_ VARCHAR2(10) := '';
    retVal2_ VARCHAR2(10) := '';
    retVal3_ VARCHAR2(10) := '';
    
BEGIN
    vlt_log_ifs('start proc','Vlt_GetApprovalTemplate',0);
    
    retVal1_ := vlt_GetLevel10(inCompany, inUser1);
    
    IF inUser2 <> 'NOTFOUND' THEN
        retVal2_ := vlt_GetLevel20(inCompany, inUser1, inUser2);
        IF retVal2_ = 'NOTFOUND' THEN
            retVal2_ := vlt_GetLevel20(inCompany, inUser2, inUser1);
        END IF;
    END IF;
    
    IF inUser2 <> 'NOTFOUND' THEN
        RETURN retVal2_;
    ELSIF inUser1 <> 'NOTFOUND' THEN
        RETURN retVal1_;
    END IF;
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        retVal3_ := 'NOTFOUND';
        RETURN retVal3_;
        
END Vlt_GetApprovalTemplate;


--CALL vlt_ifs_log_enable('Vlt_CreateApprovalTemplate');

PROCEDURE Vlt_CreateApprovalTemplate(inLevel INTEGER, inCompany VARCHAR2, inUser1 VARCHAR2, inUser2 VARCHAR2) 
IS 
    approval_Templ_Line_1 PUR_APPROVAL_TEMPL_LINE%ROWTYPE;
    approval_Templ_Line_2 PUR_APPROVAL_TEMPL_LINE%ROWTYPE;
    
    user1_ person_info.person_id%TYPE := '';
    user2_ person_info.person_id%TYPE := '';
    info_                   varchar2(4000) := '';
    objid_                  varchar2(200) := '';
    objversion_             varchar2(200) := '';
    invoice_attr_cab_       varchar2(32000) := '';
    invoice_attr_line_u1_      varchar2(32000) := '';
    invoice_attr_line_u2_      varchar2(32000) := '';
BEGIN
    vlt_log_ifs('start proc','Vlt_CreateApprovalTemplate',0);
    Client_SYS.Clear_Attr(invoice_attr_cab_);

    IF inUser1 <> 'NOTFOUND' THEN
        
        approval_templ_line_1.COMPANY := inCompany;
        approval_templ_line_1.TEMPLATE_ID := vlt_GetTemplateID(inCompany);
        approval_templ_line_1.LINE_NO := 10;
        approval_templ_line_1.AUTHORIZE_ID := inUser1;
        approval_templ_line_1.ROUTE := 10;
        approval_templ_line_1.APPROVAL_LEVEL := 'Individual';
        approval_templ_line_1.APPROVAL_LEVEL_DB := 'INDIVIDUAL';
        approval_templ_line_1.AUTHORIZE_GROUP_ID := NULL;
        approval_templ_line_1.POS_CODE := NULL;
        approval_templ_line_1.PROJECT_ROLE_ID := NULL;
        approval_templ_line_1.TARGET_DAYS := NULL;
        approval_templ_line_1.AUTHORIZATION_ROLE_TYPE := 'Authorizer';
        approval_templ_line_1.AUTHORIZATION_ROLE_TYPE_DB := 'AUTHORIZER';
            
        Client_SYS.Clear_Attr(invoice_attr_line_u1_);
        Client_SYS.Add_To_Attr('COMPANY',                   approval_templ_line_1.COMPANY,invoice_attr_line_u1_);
        Client_SYS.Add_To_Attr('TEMPLATE_ID',               approval_templ_line_1.TEMPLATE_ID,invoice_attr_line_u1_);
        Client_SYS.Add_To_Attr('LINE_NO',                   approval_templ_line_1.LINE_NO,invoice_attr_line_u1_);
        Client_SYS.Add_To_Attr('AUTHORIZE_ID',              approval_templ_line_1.AUTHORIZE_ID,invoice_attr_line_u1_);
        Client_SYS.Add_To_Attr('ROUTE',                     approval_templ_line_1.ROUTE,invoice_attr_line_u1_);
        Client_SYS.Add_To_Attr('APPROVAL_LEVEL',            approval_templ_line_1.APPROVAL_LEVEL,invoice_attr_line_u1_);
        Client_SYS.Add_To_Attr('APPROVAL_LEVEL_DB',         approval_templ_line_1.APPROVAL_LEVEL_DB,invoice_attr_line_u1_);
        Client_SYS.Add_To_Attr('AUTHORIZE_GROUP_ID',        approval_templ_line_1.AUTHORIZE_GROUP_ID,invoice_attr_line_u1_);
        Client_SYS.Add_To_Attr('POS_CODE',                  approval_templ_line_1.POS_CODE,invoice_attr_line_u1_);
        Client_SYS.Add_To_Attr('PROJECT_ROLE_ID',           approval_templ_line_1.PROJECT_ROLE_ID,invoice_attr_line_u1_);
        Client_SYS.Add_To_Attr('TARGET_DAYS',               approval_templ_line_1.TARGET_DAYS,invoice_attr_line_u1_);
        Client_SYS.Add_To_Attr('AUTHORIZATION_ROLE_TYPE',   approval_templ_line_1.AUTHORIZATION_ROLE_TYPE,invoice_attr_line_u1_);
        Client_SYS.Add_To_Attr('AUTHORIZATION_ROLE_TYPE_DB',approval_templ_line_1.AUTHORIZATION_ROLE_TYPE_DB,invoice_attr_line_u1_);
        vlt_log_ifs('invoice_attr_line_u1_=' || invoice_attr_line_u1_,'Vlt_CreateApprovalTemplate',0);
        
    END IF;    
    
    IF inUser2 <> 'NOTFOUND' THEN
        approval_templ_line_2.COMPANY := inCompany;
        approval_templ_line_2.TEMPLATE_ID := vlt_GetTemplateID(inCompany);
        approval_templ_line_2.LINE_NO := 20;
        approval_templ_line_2.AUTHORIZE_ID := inUser2;
        approval_templ_line_2.ROUTE := 20;
        approval_templ_line_2.APPROVAL_LEVEL := 'Individual';
        approval_templ_line_2.APPROVAL_LEVEL_DB := 'INDIVIDUAL';
        approval_templ_line_2.AUTHORIZE_GROUP_ID := NULL;
        approval_templ_line_2.POS_CODE := NULL;
        approval_templ_line_2.PROJECT_ROLE_ID := NULL;
        approval_templ_line_2.TARGET_DAYS := NULL;
        approval_templ_line_2.AUTHORIZATION_ROLE_TYPE := 'Authorizer';
        approval_templ_line_2.AUTHORIZATION_ROLE_TYPE_DB := 'AUTHORIZER';
        
        
        Client_SYS.Clear_Attr(invoice_attr_line_u2_);
        Client_SYS.Add_To_Attr('COMPANY',                   approval_templ_line_2.COMPANY,invoice_attr_line_u2_);
        Client_SYS.Add_To_Attr('TEMPLATE_ID',               approval_templ_line_2.TEMPLATE_ID,invoice_attr_line_u2_);
        Client_SYS.Add_To_Attr('LINE_NO',                   approval_templ_line_2.LINE_NO,invoice_attr_line_u2_);
        Client_SYS.Add_To_Attr('AUTHORIZE_ID',              approval_templ_line_2.AUTHORIZE_ID,invoice_attr_line_u2_);
        Client_SYS.Add_To_Attr('ROUTE',                     approval_templ_line_2.ROUTE,invoice_attr_line_u2_);
        Client_SYS.Add_To_Attr('APPROVAL_LEVEL',            approval_templ_line_2.APPROVAL_LEVEL,invoice_attr_line_u2_);
        Client_SYS.Add_To_Attr('APPROVAL_LEVEL_DB',         approval_templ_line_2.APPROVAL_LEVEL_DB,invoice_attr_line_u2_);
        Client_SYS.Add_To_Attr('AUTHORIZE_GROUP_ID',        approval_templ_line_2.AUTHORIZE_GROUP_ID,invoice_attr_line_u2_);
        Client_SYS.Add_To_Attr('POS_CODE',                  approval_templ_line_2.POS_CODE,invoice_attr_line_u2_);
        Client_SYS.Add_To_Attr('PROJECT_ROLE_ID',           approval_templ_line_2.PROJECT_ROLE_ID,invoice_attr_line_u2_);
        Client_SYS.Add_To_Attr('TARGET_DAYS',               approval_templ_line_2.TARGET_DAYS,invoice_attr_line_u2_);
        Client_SYS.Add_To_Attr('AUTHORIZATION_ROLE_TYPE',   approval_templ_line_2.AUTHORIZATION_ROLE_TYPE,invoice_attr_line_u2_);
        Client_SYS.Add_To_Attr('AUTHORIZATION_ROLE_TYPE_DB',approval_templ_line_2.AUTHORIZATION_ROLE_TYPE_DB,invoice_attr_line_u2_);
        vlt_log_ifs('invoice_attr_line_u2_=' || invoice_attr_line_u2_,'Vlt_CreateApprovalTemplate',0);
    
    END IF;    



    IF inUser1 <> 'NOTFOUND' THEN
      --Regista cabecalho
        Client_SYS.Add_To_Attr('COMPANY',                   approval_templ_line_1.COMPANY,invoice_attr_cab_);
        Client_SYS.Add_To_Attr('TEMPLATE_ID',               approval_templ_line_1.TEMPLATE_ID,invoice_attr_cab_);
        IF inUser2 <> 'NOTFOUND' THEN
            Client_SYS.Add_To_Attr('DESCRIPTION',           approval_templ_line_2.LINE_NO,invoice_attr_cab_);
        ELSE
            Client_SYS.Add_To_Attr('DESCRIPTION',           approval_templ_line_1.LINE_NO,invoice_attr_cab_);
        END IF;
        vlt_log_ifs('invoice_attr_cab_=' || invoice_attr_cab_,'Vlt_CreateApprovalTemplate',0);
        
        info_  := '';
        objid_  := '';
        objversion_  := '';    
        PUR_APPROVAL_TEMPL_API.NEW__( info_ , objid_ , objversion_ , invoice_attr_cab_ , 'DO' );
        COMMIT;
        
    --Regista Linha u1
        info_  := '';
        objid_  := '';
        objversion_  := '';    
        PUR_APPROVAL_TEMPL_LINE_API.NEW__( info_ , objid_ , objversion_ , invoice_attr_line_u1_ , 'DO' );
        COMMIT;
    
    END IF;
    
    IF inUser2 <> 'NOTFOUND' THEN
    --Regista Linha u2
        info_  := '';
        objid_  := '';
        objversion_  := '';  
        PUR_APPROVAL_TEMPL_LINE_API.NEW__( info_ , objid_ , objversion_ , invoice_attr_line_u2_ , 'DO' );
        COMMIT;
    END IF;
    
END Vlt_CreateApprovalTemplate;


--CALL vlt_ifs_log_enable('Vlt_SetApprovalTemplate');

PROCEDURE Vlt_SetApprovalTemplate(inROWKEY VARCHAR2, inUserId IN VARCHAR2) 
IS 
    auth_Struct_Tool_ VLT_AUTH_STRUCTURE_TOOL_CLT%ROWTYPE;
    company_ company.company%TYPE;
    user1_ person_info.person_id%TYPE := '';
    user2_ person_info.person_id%TYPE := '';
    template_Level_1_ pur_approval_templ_line.template_id%TYPE;
    template_Level_2_ pur_approval_templ_line.template_id%TYPE;
    template_Level_3_ pur_approval_templ_line.template_id%TYPE;
    template_Level_4_ pur_approval_templ_line.template_id%TYPE;
    template_Level_5_ pur_approval_templ_line.template_id%TYPE;
    template_Level_6_ pur_approval_templ_line.template_id%TYPE;
    template_Level_7_ pur_approval_templ_line.template_id%TYPE;
    
BEGIN
    vlt_log_ifs('start proc','Vlt_SetApprovalTemplate',0);
    SELECT * INTO auth_Struct_Tool_
    FROM VLT_AUTH_STRUCTURE_TOOL_CLT 
    WHERE rowkey = inROWKEY; 
      
    company_ := Vlt_GetCompanyByObjkey(auth_Struct_Tool_.cf$_company);
  
    ---LEVEL 1 --- BEGIN -----
    user1_ := Vlt_GetPersonByObjkey(auth_Struct_Tool_.CF$_LEVEL1_USER1);
    vlt_log_ifs('CF$_LEVEL1_USER1=' || user1_,'Vlt_SetApprovalTemplate',0);
    user2_ := Vlt_GetPersonByObjkey(auth_Struct_Tool_.CF$_LEVEL1_USER2);
    vlt_log_ifs('CF$_LEVEL1_USER2=' || user2_,'Vlt_SetApprovalTemplate',0);
          
    IF user1_ <> 'NOTFOUND' THEN
        template_Level_1_ := Vlt_GetApprovalTemplate(company_, user1_, user2_);
        vlt_log_ifs('template_Level_1_=' || template_Level_1_,'Vlt_SetApprovalTemplate',0);
        IF template_Level_1_ = 'NOTFOUND' THEN
            --DBMS_OUTPUT.put_line ('vou criar level 1'); 
            vlt_log_ifs ('vou criar level 1','Vlt_SetApprovalTemplate',0); 
            Vlt_CreateApprovalTemplate (1,company_,user1_,user2_);
        END IF;
        template_Level_1_ := Vlt_GetApprovalTemplate(company_, user1_, user2_);
        UPDATE VLT_AUTH_STRUCTURE_TOOL_CLT SET cf$_template1 = template_Level_1_ WHERE rowkey = inROWKEY;
        COMMIT;
    END IF;
      ---LEVEL 1 --- END -----
      
      ---LEVEL 2 --- BEGIN -----
    user1_ := Vlt_GetPersonByObjkey(auth_Struct_Tool_.CF$_LEVEL2_USER1);
    vlt_log_ifs('CF$_LEVEL2_USER1=' || user1_,'Vlt_SetApprovalTemplate',0);
    user2_ := Vlt_GetPersonByObjkey(auth_Struct_Tool_.CF$_LEVEL2_USER2);
    vlt_log_ifs('CF$_LEVEL2_USER2=' || user2_,'Vlt_SetApprovalTemplate',0);
          
    IF user1_ <> 'NOTFOUND' THEN
        template_Level_2_ := Vlt_GetApprovalTemplate(company_, user1_, user2_);
        vlt_log_ifs('template_Level_2_=' || template_Level_2_,'Vlt_SetApprovalTemplate',0);
        IF template_Level_2_ = 'NOTFOUND' THEN
            --DBMS_OUTPUT.put_line ('vou criar level 2'); 
            vlt_log_ifs ('vou criar level 2','Vlt_SetApprovalTemplate',0); 
            Vlt_CreateApprovalTemplate (2,company_,user1_,user2_);
        END IF;
        template_Level_2_ := Vlt_GetApprovalTemplate(company_, user1_, user2_);
        UPDATE VLT_AUTH_STRUCTURE_TOOL_CLT SET cf$_template2 = template_Level_2_ WHERE rowkey = inROWKEY;
        COMMIT;
    END IF;
      ---LEVEL 2 --- END -----
      
      ---LEVEL 3 --- BEGIN -----      
    user1_ := Vlt_GetPersonByObjkey(auth_Struct_Tool_.CF$_LEVEL3_USER1);
    vlt_log_ifs('CF$_LEVEL3_USER1=' || user1_,'Vlt_SetApprovalTemplate',0);
    user2_ := Vlt_GetPersonByObjkey(auth_Struct_Tool_.CF$_LEVEL3_USER2);
    vlt_log_ifs('CF$_LEVEL3_USER2=' || user2_,'Vlt_SetApprovalTemplate',0);
          
    IF user1_ <> 'NOTFOUND' THEN
        template_Level_3_ := Vlt_GetApprovalTemplate(company_, user1_, user2_);
        vlt_log_ifs('template_Level_3_=' || template_Level_3_,'Vlt_SetApprovalTemplate',0);
        IF template_Level_3_ = 'NOTFOUND' THEN
            --DBMS_OUTPUT.put_line ('vou criar level 3'); 
            vlt_log_ifs ('vou criar level 3','Vlt_SetApprovalTemplate',0); 
            Vlt_CreateApprovalTemplate (3,company_,user1_,user2_);
        END IF;
        template_Level_3_ := Vlt_GetApprovalTemplate(company_, user1_, user2_);
        UPDATE VLT_AUTH_STRUCTURE_TOOL_CLT SET cf$_template3 = template_Level_3_ WHERE rowkey = inROWKEY;
        COMMIT;
    END IF;
      ---LEVEL 3 --- END -----

      ---LEVEL 4 --- BEGIN -----      
    user1_ := Vlt_GetPersonByObjkey(auth_Struct_Tool_.CF$_LEVEL4_USER1);
    vlt_log_ifs('CF$_LEVEL4_USER1=' || user1_,'Vlt_SetApprovalTemplate',0);
    user2_ := Vlt_GetPersonByObjkey(auth_Struct_Tool_.CF$_LEVEL4_USER2);
    vlt_log_ifs('CF$_LEVEL4_USER2=' || user2_,'Vlt_SetApprovalTemplate',0);
          
    IF user1_ <> 'NOTFOUND' THEN
        template_Level_4_ := Vlt_GetApprovalTemplate(company_, user1_, user2_);
        vlt_log_ifs('template_Level_4_=' || template_Level_4_,'Vlt_SetApprovalTemplate',0);
        IF template_Level_4_ = 'NOTFOUND' THEN
            --DBMS_OUTPUT.put_line ('vou criar level 4'); 
            vlt_log_ifs ('vou criar level 4','Vlt_SetApprovalTemplate',0); 
            Vlt_CreateApprovalTemplate (4,company_,user1_,user2_);
        END IF;
        template_Level_4_ := Vlt_GetApprovalTemplate(company_, user1_, user2_);
        UPDATE VLT_AUTH_STRUCTURE_TOOL_CLT SET cf$_template4 = template_Level_4_ WHERE rowkey = inROWKEY;
        COMMIT;
    END IF;
      ---LEVEL 4 --- END -----

      ---LEVEL 5 --- BEGIN -----      
    user1_ := Vlt_GetPersonByObjkey(auth_Struct_Tool_.CF$_LEVEL5_USER1);
    vlt_log_ifs('CF$_LEVEL5_USER1=' || user1_,'Vlt_SetApprovalTemplate',0);
    user2_ := Vlt_GetPersonByObjkey(auth_Struct_Tool_.CF$_LEVEL5_USER2);
    vlt_log_ifs('CF$_LEVEL5_USER2=' || user2_,'Vlt_SetApprovalTemplate',0);
          
    IF user1_ <> 'NOTFOUND' THEN
        template_Level_5_ := Vlt_GetApprovalTemplate(company_, user1_, user2_);
        vlt_log_ifs('template_Level_5_=' || template_Level_5_,'Vlt_SetApprovalTemplate',0);
        IF template_Level_5_ = 'NOTFOUND' THEN
            --DBMS_OUTPUT.put_line ('vou criar level 5'); 
            vlt_log_ifs ('vou criar level 5','Vlt_SetApprovalTemplate',0); 
            Vlt_CreateApprovalTemplate (5,company_,user1_,user2_);
        END IF;
        template_Level_5_ := Vlt_GetApprovalTemplate(company_, user1_, user2_);
        UPDATE VLT_AUTH_STRUCTURE_TOOL_CLT SET cf$_template5 = template_Level_5_ WHERE rowkey = inROWKEY;
        COMMIT;
    END IF;
      ---LEVEL 5 --- END -----
      
      ---LEVEL 6 --- BEGIN -----      
    user1_ := Vlt_GetPersonByObjkey(auth_Struct_Tool_.CF$_LEVEL6_USER1);
    vlt_log_ifs('CF$_LEVEL6_USER1=' || user1_,'Vlt_SetApprovalTemplate',0);
    user2_ := Vlt_GetPersonByObjkey(auth_Struct_Tool_.CF$_LEVEL6_USER2);
    vlt_log_ifs('CF$_LEVEL6_USER2=' || user2_,'Vlt_SetApprovalTemplate',0);
          
    IF user1_ <> 'NOTFOUND' THEN
        template_Level_6_ := Vlt_GetApprovalTemplate(company_, user1_, user2_);
        vlt_log_ifs('template_Level_6_=' || template_Level_6_,'Vlt_SetApprovalTemplate',0);
        IF template_Level_6_ = 'NOTFOUND' THEN
            --DBMS_OUTPUT.put_line ('vou criar level 6'); 
            vlt_log_ifs ('vou criar level 6','Vlt_SetApprovalTemplate',0); 
            Vlt_CreateApprovalTemplate (6,company_,user1_,user2_);
        END IF;
        template_Level_6_ := Vlt_GetApprovalTemplate(company_, user1_, user2_);
        UPDATE VLT_AUTH_STRUCTURE_TOOL_CLT SET cf$_template6 = template_Level_6_ WHERE rowkey = inROWKEY;
        COMMIT;
    END IF;
      ---LEVEL 6 --- END -----
      
      ---LEVEL 7 --- BEGIN -----      
    user1_ := Vlt_GetPersonByObjkey(auth_Struct_Tool_.CF$_LEVEL7_USER1);
    vlt_log_ifs('CF$_LEVEL7_USER1=' || user1_,'Vlt_SetApprovalTemplate',0);
    user2_ := Vlt_GetPersonByObjkey(auth_Struct_Tool_.CF$_LEVEL7_USER2);
    vlt_log_ifs('CF$_LEVEL7_USER2=' || user2_,'Vlt_SetApprovalTemplate',0);
          
    IF user1_ <> 'NOTFOUND' THEN
        template_Level_7_ := Vlt_GetApprovalTemplate(company_, user1_, user2_);
        vlt_log_ifs('template_Level_7_=' || template_Level_7_,'Vlt_SetApprovalTemplate',0);
        IF template_Level_7_ = 'NOTFOUND' THEN
            --DBMS_OUTPUT.put_line ('vou criar level 7'); 
            vlt_log_ifs ('vou criar level 7','Vlt_SetApprovalTemplate',0); 
            Vlt_CreateApprovalTemplate (7,company_,user1_,user2_);
        END IF;
        template_Level_7_ := Vlt_GetApprovalTemplate(company_, user1_, user2_);
        UPDATE VLT_AUTH_STRUCTURE_TOOL_CLT SET cf$_template7 = template_Level_7_ WHERE rowkey = inROWKEY;
        COMMIT;
    END IF;
      ---LEVEL 7 --- END -----
    --Lets now create the rules
    Vlt_CreatePOAuthRuleGeneralTab(inROWKEY);
    UPDATE VLT_AUTH_STRUCTURE_TOOL_CLT SET CF$_EXECUTED='TRUE', CF$_EXECUTED_BY=inUserId, CF$_EXECUTED_DATE=SYSDATE WHERE ROWKEY=inROWKEY;
    
END Vlt_SetApprovalTemplate;

FUNCTION vlt_Get_Model_Num_Authorizers (inModel_ID VARCHAR2, inLevel NUMBER) 
RETURN NUMBER 
IS
    retVal_ NUMBER;
BEGIN
 --vlt_log_ifs ('inModel_ID=' || inModel_ID,'VLT_GET_MODEL_NUM_AUTHORIZERS',1);

    SELECT m.CF$_MIN_AUTHORIZERS_DB*1
    INTO retVal_
    FROM VLT_AUTH_STRUCTURE_MODEL_CLV m
    WHERE m.CF$_MODEL_ID = vlt_GetModelByObjkey(inModel_ID)
    AND m.CF$_LEVEL_DB = inLevel;

    RETURN retVal_;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            retVal_ := 0;
            RETURN retVal_;

END vlt_Get_Model_Num_Authorizers; 

FUNCTION vlt_Check_Model_BL (inModel_ID VARCHAR2, inBL_ID VARCHAR2) 
RETURN NUMBER 
IS
    retVal_ NUMBER;
BEGIN
--vlt_log_ifs ('inModel_ID=' || inModel_ID,'vlt_Check_Model_BL',0);
--vlt_log_ifs ('inBL_ID=' || inBL_ID,'vlt_Check_Model_BL',0);
    CASE inBL_ID
        WHEN 'ASIF' THEN
            SELECT COUNT(*) INTO retVal_
            FROM VLT_AUTH_STRUCTURE_MODEL_CLV
            WHERE CF$_MODEL_ID = inModel_ID
            AND CF$_ASIF_DB = 'TRUE';
        WHEN 'COE' THEN
            SELECT COUNT(*) INTO retVal_
            FROM VLT_AUTH_STRUCTURE_MODEL_CLV
            WHERE CF$_MODEL_ID = inModel_ID
            AND CF$_COE_DB = 'TRUE';
        WHEN 'COMMON' THEN
            SELECT COUNT(*) INTO retVal_
            FROM VLT_AUTH_STRUCTURE_MODEL_CLV
            WHERE CF$_MODEL_ID = inModel_ID
            AND CF$_COMMON_DB = 'TRUE';
        WHEN 'DEV' THEN
            SELECT COUNT(*) INTO retVal_
            FROM VLT_AUTH_STRUCTURE_MODEL_CLV
            WHERE CF$_MODEL_ID = inModel_ID
            AND CF$_DEV_DB = 'TRUE';
        WHEN 'EPC' THEN
            SELECT COUNT(*) INTO retVal_
            FROM VLT_AUTH_STRUCTURE_MODEL_CLV
            WHERE CF$_MODEL_ID = inModel_ID
            AND CF$_EPC_DB = 'TRUE';
        WHEN 'ETD' THEN
            SELECT COUNT(*) INTO retVal_
            FROM VLT_AUTH_STRUCTURE_MODEL_CLV
            WHERE CF$_MODEL_ID = inModel_ID
            AND CF$_ETD_DB = 'TRUE';
        WHEN 'HQ' THEN
            SELECT COUNT(*) INTO retVal_
            FROM VLT_AUTH_STRUCTURE_MODEL_CLV
            WHERE CF$_MODEL_ID = inModel_ID
            AND CF$_HQ_DB = 'TRUE';
        WHEN 'IPP' THEN
            SELECT COUNT(*) INTO retVal_
            FROM VLT_AUTH_STRUCTURE_MODEL_CLV
            WHERE CF$_MODEL_ID = inModel_ID
            AND CF$_IPP_DB = 'TRUE';
        WHEN 'O&M' THEN
            SELECT COUNT(*) INTO retVal_
            FROM VLT_AUTH_STRUCTURE_MODEL_CLV
            WHERE CF$_MODEL_ID = inModel_ID
            AND CF$_OM_DB = 'TRUE';
        WHEN 'PWR_RET' THEN
            SELECT COUNT(*) INTO retVal_
            FROM VLT_AUTH_STRUCTURE_MODEL_CLV
            WHERE CF$_MODEL_ID = inModel_ID
            AND CF$_PWR_RET_DB = 'TRUE';
        WHEN 'TEECOM' THEN
            SELECT COUNT(*) INTO retVal_
            FROM VLT_AUTH_STRUCTURE_MODEL_CLV
            WHERE CF$_MODEL_ID = inModel_ID
            AND CF$_TEECOM_DB = 'TRUE';
        ELSE
            retVal_ := 0;
    END CASE;
    RETURN retVal_;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            retVal_ := 0;
            RETURN retVal_;
END vlt_Check_Model_BL;

FUNCTION vlt_Get_CategoryByObjkey (inObjkey VARCHAR2) 
RETURN VARCHAR2 
IS
    retVal_ code_g.code_g%TYPE;
BEGIN

--vlt_log_ifs ('inObjkey=' || inObjkey,'vlt_Get_CategoryByObjkey',1);
    SELECT code_g INTO retVal_ 
    FROM CODE_G 
    WHERE objkey=inObjkey;
    
    RETURN retVal_;
END vlt_Get_CategoryByObjkey;

FUNCTION vlt_Get_ProjectCat1ByObjkey (inObjkey VARCHAR2) 
RETURN VARCHAR2 
IS
    retVal_ project.category1_id%TYPE;
BEGIN
    SELECT category1_id INTO retVal_ 
    FROM project 
    WHERE objkey=inObjkey;
    
    RETURN retVal_;
END vlt_Get_ProjectCat1ByObjkey;

FUNCTION vlt_Get_CategoryDescByCode (inCode VARCHAR2) 
RETURN VARCHAR2 
IS
    retVal_ code_g.description%TYPE;
BEGIN
    SELECT MAX(description) INTO retVal_ 
    FROM code_g 
    WHERE code_g=inCode;
    
    RETURN retVal_;
END vlt_Get_CategoryDescByCode;

FUNCTION vlt_CheckProjectCompany (inProjectObjkey VARCHAR2, inCompanyObjkey VARCHAR2) 
RETURN NUMBER 
IS
    company_in_ project.company%TYPE;
    company_ project.company%TYPE;
    retVal_ NUMBER;
BEGIN
 --vlt_log_ifs ('inProject_ID=' || inProject_ID,'vlt_CheckProjectCompany',1);
 --vlt_log_ifs ('inCompanyID=' || inCompanyID,'vlt_CheckProjectCompany',1);
 
    company_in_ := vlt_getcompanybyobjkey(inCompanyObjkey);
 
    SELECT p.COMPANY
    INTO company_
    FROM project p
    WHERE p.objkey = inProjectObjkey
    ;

    IF (company_ = company_in_) THEN
        retVal_ := 1;
    ELSE
        retVal_ := 0;
    END IF;
    
    RETURN retVal_;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            retVal_ := 0;
            RETURN retVal_;

END vlt_CheckProjectCompany; 


FUNCTION vlt_Get_Start_Supplier_ID(inCountry VARCHAR2) RETURN NUMBER
IS
    retVal_ NUMBER;
BEGIN
    SELECT (((SUBSTR(Supplier_id,3,LENGTH(Supplier_id)))*1)+1) into retVal_
    from (select country_db, Country, supplier_id, rank() over ( partition by SUBSTR(Supplier_id, 1, 3) 
    order by Supplier_id desc) rank from SUPPLIER_INFO_GENERAL) 
    where rank <= 1 
    and SUBSTR(Supplier_id,3,1) IN ('1')
    and SUBSTR(Supplier_id,1,2) = inCountry
    order by country_db, Supplier_id
    ;
RETURN retVal_;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            retVal_ := 1;
            RETURN retVal_;
END vlt_Get_Start_Supplier_ID;

PROCEDURE vlt_Get_New_Supplier_ID
IS
   TYPE countryIDArrayType_ IS VARRAY(100) OF IC_SUPPLIER_FILE_TAB.IDENTITY%TYPE; 
   TYPE ic_row_noArrayType_ IS VARRAY(100) OF IC_SUPPLIER_FILE_TAB.IC_ROW_NO%TYPE; 
   
   countryIDArray_ countryIDArrayType_ := countryIDArrayType_(); --initialize to empty
   ic_row_noArray_ ic_row_noArrayType_ := ic_row_noArrayType_(); --initialize to empty
   currCountryDb_ IC_SUPPLIER_FILE_TAB.COUNTRY_DB%TYPE; 
   lastCountryDb_ IC_SUPPLIER_FILE_TAB.COUNTRY_DB%TYPE := 'XX'; 
   counter_ INTEGER :=0;
   lastID_ NUMBER;
   total_ INTEGER;
   
   CURSOR c_suppliers_to_create is 
    SELECT sft.country_db, sft.ic_row_no
    FROM IC_SUPPLIER_FILE_TAB sft
    ORDER BY sft.country_db;
   
   BEGIN 
    FOR n IN c_suppliers_to_create 
    LOOP 
        counter_ := counter_ + 1;
        currCountryDb_ := n.country_db;
        countryIDArray_.extend;
        ic_row_noArray_.extend;
        IF currCountryDb_ <> lastCountryDb_ THEN
            lastID_ := vlt_Get_Start_Supplier_ID(n.country_db);
            ic_row_noArray_.extend;
            IF lastID_ <> 1 THEN 
                countryIDArray_(counter_)  := currCountryDb_ || lastID_;
            ELSE
                countryIDArray_(counter_)  := currCountryDb_ || '10001';
            END IF;
            ic_row_noArray_(counter_) := n.ic_row_no;
            lastCountryDb_ := currCountryDb_;
        ELSE
            IF lastID_ <> 1 THEN 
                lastID_ := lastID_ + 1;
                countryIDArray_(counter_)  := currCountryDb_ || lastID_;
            ELSE
                countryIDArray_(counter_)  := currCountryDb_ || '10001';
            END iF;
            ic_row_noArray_(counter_) := n.ic_row_no;
        END IF;

        --dbms_output.put_line(counter_ || '->' || countryIDArray_(counter_));  
        --dbms_output.put_line('ic_row_no('||n.ic_row_no ||'):'||countryIDArray_(n.ic_row_no));  
    END LOOP; 
    
    total_ := countryIDArray_.count; 
    FOR i in 1 .. total_ LOOP 
        UPDATE IC_SUPPLIER_FILE_TAB SET identity = countryIDArray_(i) WHERE ic_row_no = ic_row_noArray_(i);
        --dbms_output.put_line('Country ID: ' || countryIDArray_(i)); 
    END LOOP;
    
EXCEPTION
WHEN OTHERS THEN
   raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
END vlt_Get_New_Supplier_ID;

END C_VOLTALIA_UTIL_API;