Lparameters tnId
Local lError
Set Textmerge On

* Kalle 15.02.2023
select id, IIF(LEFT(regkood,8) = '75024260' OR regkood = '75024260-18510139', '75024260',  regkood) as regkood, nimetus, aadress, email, tel  FROM comAsutusRemote a INTO CURSOR qryAsutused
   
* pay_to_name andmed
lError = oDb.readFromModel('ou\rekv', 'pay_to_name', 'gRekv, guserid', 'v_pay_to_name')



If !Empty(tnId)
	If !Used('curArved')
		l_where = "id = " + Str(tnId)
		lError = oDb.readFromModel('raamatupidamine\arv', 'curArved', 'gRekv, guserid', 'curArved',l_where)
	Endif

	Select a.*,;
		IIF(a.liik = 0,Iif(!Isnull(qryRekv.muud),qryRekv.muud,qryRekv.nimetus), Alltrim(a.asutus) )  As muuja,;
		IIF(a.liik = 1 ,Iif(!Isnull(qryRekv.muud),qryRekv.muud,qryRekv.nimetus),Alltrim(a.asutus) ) As ostja,;
		IIF(a.liik = 1, LEFT(qryRekv.regkood,15),LEFT(Alltrim(asutus.regkood),15)) As ostja_regkood,;
		IIF(a.liik = 1, qryRekv.aadress,asutus.aadress) As ostja_aadress,;
		IIF(a.liik = 1, qryRekv.email,Alltrim(asutus.email)) As ostja_email,;
		IIF(a.liik = 0, LEFT(qryRekv.regkood,15),LEFT(Alltrim(asutus.regkood),15)) As muuja_regkood,;
		IIF(a.liik = 0, qryRekv.aadress, Alltrim(asutus.aadress)) As muuja_aadress,;
		IIF(a.liik = 0 , qryRekv.email , Alltrim(asutus.email)) As muuja_email,;
		IIF(a.liik = 0, qryRekv.tel, Alltrim(asutus.tel)) As muuja_tel,;
		a.markused As muud, a.aa As arve ;
		from curArved a;
		inner Join qryAsutused asutus On asutus.Id = curArved.asutusId;
		Where a.Id = tnId ;
		INTO Cursor qryeArved

Else
	If Used('curArved')
		Select a.*,;
			IIF(a.liik = 0,Iif(!Isnull(qryRekv.muud),qryRekv.muud,qryRekv.nimetus), Alltrim(a.asutus) )  As muuja,;
			IIF(a.liik = 1 ,Iif(!Isnull(qryRekv.muud),qryRekv.muud,qryRekv.nimetus),Alltrim(a.asutus) ) As ostja,;
			IIF(a.liik = 0, LEFT(qryRekv.regkood,15),LEFT(Alltrim(a.regkood),15)) As muuja_regkood,;
			IIF(a.liik = 1, LEFT(qryRekv.regkood,15),LEFT(Alltrim(a.regkood),15)) As ostja_regkood,;
			IIF(a.liik = 1, qryRekv.aadress,asutus.aadress) As ostja_aadress,;
			IIF(a.liik = 1, qryRekv.email,Alltrim(asutus.email)) As ostja_email,;
			IIF(a.liik = 0, qryRekv.aadress, Alltrim(asutus.aadress)) As muuja_aadress,;
			IIF(a.liik = 0 , qryRekv.email , Alltrim(asutus.email)) As muuja_email,;
			IIF(a.liik = 0, qryRekv.tel, Alltrim(asutus.tel)) As muuja_tel,;
			a.markused As muud, a.aa As arve;
			From curArved a;
			inner Join qryAsutused asutus On asutus.Id = a.asutusId;
			Where !Empty(valitud);
			INTO Cursor qryeArved
	Endif

Endif


l_xml=execute()

IF USED('qryAsutused')
	USE IN qryAsutused
ENDIF
	
Return l_xml


Function execute
	Local laAddress[3]

	lcKpv = Str(Year(Date()),4) + '-'+;
		IIF(Month(Date())<10,'0','') + Alltrim(Str(Month(Date()),2))+'-'+;
		IIF(Day(Date())<10,'0','')+Alltrim(Str(Day(Date()),2))

l_id = qryeArved.id
TEXT TO lcFileString NOSHOW
<?xml version="1.0" encoding="UTF-8"?>
<E_Invoice>
<Header>
<Date><<lcKpv>></Date>
<FileId><<l_id>></FileId>
<AppId>EARVE</AppId>
<Version>1.1</Version>
</Header>

ENDTEXT

	Select qryeArved
	Scan

		lcKpv = Str(Year(qryeArved.kpv),4) + '-'+;
			IIF(Month(qryeArved.kpv)<10,'0','') + Alltrim(Str(Month(qryeArved.kpv),2))+'-'+;
			IIF(Day(qryeArved.kpv)<10,'0','')+Alltrim(Str(Day(qryeArved.kpv),2))

		lcTKpv = ''
		If !Empty(qryeArved.tahtaeg)
			lcTKpv = Str(Year(qryeArved.tahtaeg),4) + '-'+;
				IIF(Month(qryeArved.tahtaeg)<10,'0','') + Alltrim(Str(Month(qryeArved.tahtaeg),2))+'-'+;
				IIF(Day(qryeArved.tahtaeg)<10,'0','')+Alltrim(Str(Day(qryeArved.tahtaeg),2))
		Endif

		laAddress = getAddress(qryeArved.aadress)
		lcCity = getAddress(qryeArved.aadress, 3)
		lcPost = getAddress(qryeArved.aadress, 1)
		la_muuja_Address = getAddress(qryeArved.muuja_aadress)
		lc_muuja_City = getAddress(qryeArved.muuja_aadress, 3)
		lc_muuja_Post = getAddress(qryeArved.muuja_aadress, 1)
		la_ostja_Address = getAddress(qryeArved.ostja_aadress)
		lc_ostja_City = getAddress(qryeArved.ostja_aadress, 3)
		lc_ostja_Post = getAddress(qryeArved.ostja_aadress, 1)


TEXT TO lcFileString ADDITIVE NOSHOW

<Invoice invoiceId="<<Alltrim(convert_to_utf(qryeArved.Number))>>" regNumber="<<Alltrim(IIF(LEFT(qryeArved.regkood,8)='75024260','75024260',ALLTRIM(qryeArved.regkood)))>>">
<InvoiceParties>
<SellerParty>
<Name><<Alltrim(convert_to_utf(qryeArved.muuja))>></Name>
<RegNumber><<Alltrim(qryeArved.muuja_regkood)>></RegNumber>
<ContactData>
<PhoneNumber><<ALLTRIM(qryeArved.muuja_tel)>></PhoneNumber>

ENDTEXT

IF !EMPTY(qryeArved.muuja_email)
TEXT TO lcFileString ADDITIVE NOSHOW textmerge
<E-mailAddress><<ALLTRIM(qryeArved.muuja_email)>></E-mailAddress>

ENDTEXT

ENDIF

TEXT TO lcFileString ADDITIVE NOSHOW textmerge
<LegalAddress>
<PostalAddress1><<Alltrim(convert_to_utf(lc_muuja_Post))>></PostalAddress1>
<City><<ALLTRIM(convert_to_utf(lc_muuja_City))>></City>
</LegalAddress>
</ContactData>
</SellerParty>
<BuyerParty>
<Name><<Alltrim(convert_to_utf(qryeArved.ostja))>></Name>
<RegNumber><<Alltrim(qryeArved.ostja_regkood)>></RegNumber>
<ContactData>

ENDTEXT
IF !EMPTY(qryeArved.ostja_email)
TEXT TO lcFileString ADDITIVE NOSHOW textmerge
<E-mailAddress><<ALLTRIM(qryeArved.ostja_email)>></E-mailAddress>

ENDTEXT
ENDIF

TEXT TO lcFileString ADDITIVE NOSHOW textmerge
<LegalAddress>
<PostalAddress1><<Alltrim(convert_to_utf(la_ostja_Address))>></PostalAddress1>
<City><<ALLTRIM(convert_to_utf(lc_ostja_City))>></City>
</LegalAddress>
</ContactData>
</BuyerParty>
</InvoiceParties>
<InvoiceInformation>
<Type type="DEB"/>
<ContractNumber><<ALLTRIM(convert_to_utf(ALLTRIM(qryeArved.lisa)))>></ContractNumber>
<DocumentName>Arve</DocumentName>
<InvoiceNumber><<Alltrim(convert_to_utf(qryeArved.Number))>></InvoiceNumber>
ENDTEXT

		If !Isnull(qryeArved.muud) And !Empty(qryeArved.muud)

TEXT TO lcFileString ADDITIVE NOSHOW

	<InvoiceContentText><<ALLTRIM(convert_to_utf(ALLTRIM(qryeArved.muud)))>></InvoiceContentText>
ENDTEXT
		Endif
TEXT TO lcFileString ADDITIVE NOSHOW
<InvoiceDate><<lcKpv>></InvoiceDate>
<DueDate><<lcTKpv>></DueDate>
<InvoiceDeliverer>
<ContactName><<ALLTRIM(v_account.ametnik)>></ContactName>
</InvoiceDeliverer>
ENDTEXT

TEXT TO lcFileString ADDITIVE NOSHOW
		</InvoiceInformation>
		<InvoiceSumGroup>
		<InvoiceSum><<Alltrim(Str((qryeArved.Summa - qryeArved.kbm),14,2))>></InvoiceSum>
ENDTEXT


		tnId = qryeArved.Id
		lError = oDb.readFromModel('raamatupidamine\arv', 'details', 'tnId, guserid', 'tmpeArveDet')
		Select tmpeArveDet

		Select Iif(ISNULL(km) OR Empty(km) Or km = '-', '0',km) As vatRate,;
			sum(kbm) As vatSum,  Sum(Summa) As Summa ;
			from tmpeArveDet ;
			group By km;
			INTO Cursor qryeArvedVat

		Select Iif(ISNULL(km) OR Empty(km) Or km = '-', '0',km) As vatRate, ;
			kbm As vat_summa,;
			alltrim(nimetus) + ' ' + Alltrim(Iif(Isnull(muud),'',muud)) As Description, uhik As ItemUnit,;
			kogus As ItemAmount, hind As ItemPrice, (Summa - kbm) As ItemSum, kbm As vatSum, Summa As ItemTotal;
			from tmpeArveDet ;
			into Cursor qryeArvedDet


* koguneme kaibemaksu summad
		Select qryeArvedVat
		Scan
TEXT TO lcFileString ADDITIVE NOSHOW

<VAT>
<VATRate><<Alltrim((IIF(qryeArvedVat.vatRate = '.NULL.','0',qryeArvedVat.vatRate)))>></VATRate>
<VATSum><<Alltrim(Str(qryeArvedVat.vatSum,14,2))>></VATSum>
</VAT>

ENDTEXT

		Endscan

TEXT TO lcFileString ADDITIVE NOSHOW

<TotalSum><<Alltrim(Str(qryeArved.Summa,14,2))>></TotalSum>
<Currency>EUR</Currency>
</InvoiceSumGroup>

ENDTEXT




*!*	<E-mailAddress><<ALLTRIM(v_account.email)>></E-mailAddress>



		If Used('qryeArvedDet')
			lcFileString= lcFileString  + create_details()
		Endif

l_tahtaeg = ALLTRIM(STR(YEAR(qryeArved.tahtaeg))) + '-' + ; 
	IIF(MONTH(qryeArved.tahtaeg) < 10, '0','') + ALLTRIM(STR(MONTH(qryeArved.tahtaeg))) + '-' + ;
	IIF(DAY(qryeArved.tahtaeg) < 10, '0','') + ALLTRIM(STR(DAY(qryeArved.tahtaeg)))
	
l_raha_saaja = ALLTRIM(convert_to_utf(qryeArved.muuja))
* Sotsiaal tookestus 
IF TYPE('qryeArved.raha_saaja') = 'C' AND !EMPTY(qryeArved.raha_saaja)
	l_raha_saaja = ALLTRIM(convert_to_utf(qryeArved.raha_saaja))
ENDIF

IF  USED('v_pay_to_name')
	* vaatame kas arve aa omab ule asutusel
	SELECT v_pay_to_name
	LOCATE FOR arve = ALLTRIM(qryeArved.arve)
	IF FOUND()
		l_raha_saaja  = ALLTRIM(convert_to_utf(v_pay_to_name.pay_to_name))
	ENDIF	
ENDIF



TEXT TO lcFileString ADDITIVE NOSHOW
<PaymentInfo>
<Currency>EUR</Currency>
<PaymentRefId><<IIF(ISNULL(qryeArved.viitenr),'',ALLTRIM(qryeArved.viitenr))>></PaymentRefId>
<PaymentDescription>Arve <<convert_to_utf(qryeArved.Number)>></PaymentDescription>
<Payable>YES</Payable>
<PayDueDate><<l_tahtaeg>></PayDueDate> 
<PaymentTotalSum><<Alltrim(Str(qryeArved.Summa,14,2))>></PaymentTotalSum>
<PayerName><<Alltrim(convert_to_utf(qryeArved.ostja)) >></PayerName>
<PaymentId><<ALLTRIM(convert_to_utf(qryeArved.number))>></PaymentId>
<PayToAccount><<ALLTRIM(qryeArved.arve)>></PayToAccount>
<PayToName><<l_raha_saaja>></PayToName>
</PaymentInfo>
</Invoice>

ENDTEXT

	Endscan
	Select qryeArved
	Sum Summa To lnTotalSumma

TEXT TO lcFileString ADDITIVE NOSHOW

<Footer>
<TotalNumberInvoices><<Alltrim(Str(Reccount('qryeArved')))>></TotalNumberInvoices>
<TotalAmount><<Alltrim(Str(lnTotalSumma,14,2))>></TotalAmount>
</Footer>
</E_Invoice>
ENDTEXT

*!*		Strtofile(lcFileString, cFail, 4)
*!*		Return File(cFail)
	Return lcFileString

Endfunc

Function create_details
	Local lcString, lnSummaKokku, lcIsoKpv, lcPankIban, lcTKpv, lcKpv
	lcString = ''


TEXT TO lcString ADDITIVE NOSHOW

<InvoiceItem>
<InvoiceItemGroup>

ENDTEXT

	Select qryeArvedDet
	Scan
TEXT TO lcString ADDITIVE NOSHOW

<ItemEntry>
<Description><<Alltrim(convert_to_utf(ALLTRIM(qryeArvedDet.Description)))>></Description>
<ItemDetailInfo>
<ItemUnit><<Alltrim(qryeArvedDet.ItemUnit)>></ItemUnit>
<ItemAmount><<Alltrim(Str(qryeArvedDet.ItemAmount,14,4))>></ItemAmount>
<ItemPrice><<Alltrim(Str(qryeArvedDet.itemPrice,14,2))>></ItemPrice>
</ItemDetailInfo>
<ItemSum><<Alltrim(Str(qryeArvedDet.itemSum,14,2))>></ItemSum>
<VAT>
<SumBeforeVAT><<Alltrim(Str(qryeArvedDet.ItemSum, 14,2))>></SumBeforeVAT>
<VATRate><<IIF(qryeArvedDet.vatRate = '.NULL.','0', qryeArvedDet.vatRate)>></VATRate>
<VATSum><<Alltrim(Str(qryeArvedDet.vatSum,14,2))>></VATSum>
<Currency>EUR</Currency>
</VAT>
<ItemTotal><<Alltrim(Str(qryeArvedDet.itemTotal,14,2))>></ItemTotal>
</ItemEntry>
ENDTEXT

	Endscan

TEXT TO lcString ADDITIVE NOSHOW

</InvoiceItemGroup>
</InvoiceItem>

ENDTEXT

	Return lcString
Endfunc


Function getAddress(tcAadress, Index)

	Local lcString, laAddress[10], returnAadress[3], lcIndex, lcLinn
	lcIndex = ''
	lcLinn = ''

	Select qryCities

	nRows = Alines(laAddress, Strtran(tcAadress,",",Chr(13)))

	For i = 1 To nRows
		If Len(Alltrim(laAddress[i]))  = 5 And Isdigit(Alltrim(laAddress[i]))
			lcIndex = laAddress[i]
		Endif

		Select nimetus From qryCities Where Upper(Alltrim(nimetus)) = Upper(Alltrim(laAddress[i])) Into Cursor qryTmp

		If Reccount('qryTmp') > 0
			lcLinn = laAddress[i]
		Endif
		Use In qryTmp
	Endfor

	lcPost = ''
	For i = 1 To nRows
		If Alltrim(laAddress[i]) <> Alltrim(lcIndex) And Alltrim(Upper(laAddress[i])) <> Alltrim(Upper(lcLinn))
			lcPost = lcPost + Iif(i > 1, ', ','') + laAddress[i]
		Endif
	Endfor

	If Empty(lcLinn)
		lcLinn = laAddress[nRows]
	Endif

	returnAadress[1] = lcPost
	returnAadress[2] = lcIndex
	returnAadress[3] = lcLinn

	If Empty(Index)
		Index = 1
	Endif

	Return returnAadress[index]
Endfunc
