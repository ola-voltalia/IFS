-- Context: tbwPaymentAddresses

DECLARE
   -- p0 -> __lsResult
   p0_ VARCHAR2(32000) := '';

   -- p1 -> __sObjid
   p1_ VARCHAR2(32000) := 'AAAaGbAAGAAAl0mAAQ';

   -- p2 -> __lsObjversion
   p2_ VARCHAR2(32000) := '1';

   -- p3 -> __sAction
   p3_ VARCHAR2(32000) := 'CHECK';
   
   supp_ varchar2(20);
   addr_ varchar2(50);
   cp_ varchar2(20);
   
cursor get_payment_address is
    select * 
    from PAYMENT_ADDRESS
    where identity=supp_ and address_id=addr_ and company like cp_ and company <> 'FRA001';

BEGIN
  
    supp_ := 'ITA001';
    addr_ := '1';
    cp_ := 'FRA%';
    
    for rec_ in get_payment_address loop
    
        p0_ := '';
        p1_ := rec_.objid;
        p2_ := rec_.objversion;
        PAYMENT_ADDRESS_API.REMOVE__( p0_ , p1_ , p2_ , 'CHECK' );
        
        p0_ := NULL;
        p1_ := rec_.objid;
        p2_ := rec_.objversion;
        PAYMENT_ADDRESS_API.REMOVE__( p0_ , p1_ , p2_ , 'DO' );
        
        Payment_Address_API.Only_One_Default_Address__( rec_.company , rec_.identity , rec_.party_type_db , rec_.way_id );
        
        commit;
    end loop;

END;