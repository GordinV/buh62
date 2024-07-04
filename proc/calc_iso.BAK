Lparameters tnMKId
Local lError

l_test = .f.

lnId = 1
cFail = 'c:\temp\buh60\EDOK\mk_iso.xml'
cFailbak = 'c:\temp\buh60\EDOK\'+Alltrim(Str(gRekv))+'iso'+Sys(2015)+'.bak'

If !Directory(Justpath(cFail))
	Mkdir(Justpath(cFail))
Endif

If File (cFailbak)
	Erase (cFailbak)
Endif
If File(cFail)
	Rename (cFail) To (cFailbak)
Endif



lError = iso(tnMKId)

If Used('tmp_mk')
	Use In tmp_mk
Endif

If Used('tmp_mk1')
	Use In tmp_mk1
Endif

If !File(cFail)
	cFail = ''
Endif

Return cFail

Function iso
	Lparameters tnMKId
	Local lcString, lnSummaKokku, lcIsoKpv, lcPankIban
	If qryRekv.parentid = 119 Or qryRekv.Id = 119
		lcRekvNimetus = 'Narva Linnavalitsuse Kultuuriosakond'
		lcRekvAadress = 'Peetri plats 1, 20308 Narva'
	ELSE
	
		lcRekvNimetus = Alltrim(qryRekv.nimetus)
		* if full name is available, will use it
		IF !EMPTY(qryRekv.muud)
			lcRekvNimetus = Alltrim(qryRekv.muud)
		ENDIF
		
		
		lcRekvAadress = LEFT(Alltrim(qryRekv.aadress),70)
	Endif

TEXT TO lcString NOSHOW
<?xml version="1.0" encoding="UTF-8"?>
<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03 pain.001.001.03.xsd">

ENDTEXT

	If Empty(tnMKId) Or  tnMKId = 0 Or !Used('v_mk')
		tnId = -1
		lError = oDb.readFromModel('raamatupidamine\vmk', 'row', 'tnId, guserid', 'tmp_mk')
		If !lError Or !Used('tmp_mk')
			Set Step On
			Messagebox('Viga',0+16,'maksekorraldus')
			Return .F.
		Endif

		lError = oDb.readFromModel('raamatupidamine\vmk', 'details', 'tnId, guserid', 'tmp_mk1')
		If !lError Or !Used('tmp_mk1')
			Set Step On
			Messagebox('Viga',0+16,'maksekorraldus')
			Return .F.
		Endif


		Select Distinct Id From curMk Where Not Empty(valitud) Into Cursor tmpMkDok

		Select tmpMkDok
		Scan
			tnId = tmpMkDok.Id
			lError = oDb.readFromModel('raamatupidamine\vmk', 'row', 'tnId, guserid', 'qry_mk')
			If !lError Or !Used('qry_mk')
				Set Step On
				Messagebox('Viga',0+16,'maksekorraldus')
				Return .F.
			Endif

			lError = oDb.readFromModel('raamatupidamine\vmk', 'details', 'tnId, guserid', 'qry_mk1')
			If !lError Or !Used('qry_mk1')
				Set Step On
				Messagebox('Viga',0+16,'maksekorraldus')
				Return .F.
			Endif

			Select tmp_mk
			Append From Dbf('qry_Mk')
			Use In qry_mk

			Select tmp_mk1
			Append From Dbf('qry_Mk1')
			Use In qry_Mk1
		Endscan
	Else
		If Used('v_mk')
			Select * From v_mk Into Cursor tmp_mk
			Select * From v_mk1 Into Cursor tmp_mk1
		Else
			Return .F.
		Endif

	Endif

	Select tmp_mk1
	Sum Summa To lnSummaKokku
	Select tmp_mk
	Do Case
		Case tmp_mk.pank = 767
			lcPankIban = 'HABAEE2X'
		Case tmp_mk.pank = 401
			lcPankIban = 'EEUHEE2X'
		Case tmp_mk.pank = 720
			lcPankIban = 'FOREEE2X'
		Case tmp_mk.pank = 728
			lcPankIban = 'NDEAEE2X'
		Otherwise
			lcPankIban = 'HABAEE2X'
	Endcase

	l_koostamise_kpv = Str(Year(DATE()),4) + '-'+;
		IIF(Month(DATE())<10,'0','') + Alltrim(Str(Month(DATE()),2))+'-'+;
		IIF(Day(DATE())<10,'0','')+Alltrim(Str(Day(DATE()),2))


	Select tmp_mk
TEXT TO lcString ADDITIVE TEXTMERGE NOSHOW

<CstmrCdtTrfInitn>
<GrpHdr>
<MsgId><<ALLTRIM(STR(tmp_mk.Id))>></MsgId>
<CreDtTm><<l_koostamise_kpv>>T08:00:00</CreDtTm>
<NbOfTxs><<RECCOUNT('tmp_mk1')>></NbOfTxs>
<CtrlSum><<Alltrim(Str(lnSummaKokku,14,2))>></CtrlSum>
<InitgPty><Nm><<Alltrim(lcRekvNimetus)>></Nm></InitgPty>
</GrpHdr>

ENDTEXT

	Scan For !Empty(rekvId)
		Wait Window 'Eksport: ' + Alltrim(tmp_mk.Number) Nowait
		lcIsoKpv = Str(Year(tmp_mk.maksepaev),4) + '-'+;
			IIF(Month(tmp_mk.maksepaev)<10,'0','') + Alltrim(Str(Month(tmp_mk.maksepaev),2))+'-'+;
			IIF(Day(tmp_mk.maksepaev)<10,'0','')+Alltrim(Str(Day(tmp_mk.maksepaev),2))

	SELECT tmp_mk1
	SUM summa TO l_mk_summa FOR parent_id = tmp_mk.Id
		Select tmp_mk1
		Scan For parent_id = tmp_mk.Id


TEXT TO lcString ADDITIVE TEXTMERGE noshow

<PmtInf>
<PmtInfId><<ALLTRIM(tmp_mk.number)>></PmtInfId>
<PmtMtd>TRF</PmtMtd>
<BtchBookg>false</BtchBookg>
<NbOfTxs>1</NbOfTxs>
<CtrlSum><<Alltrim(Str(tmp_mk1.summa ,14,2))>></CtrlSum>
<PmtTpInf><SvcLvl><Cd>SEPA</Cd></SvcLvl></PmtTpInf>
<ReqdExctnDt><<lcIsoKpv>></ReqdExctnDt>
<Dbtr>
<Nm><<Alltrim(convert_to_utf(lcRekvNimetus))>></Nm>
<PstlAdr>
<Ctry>EE</Ctry>
<AdrLine><<LEFT(Alltrim(convert_to_utf(lcRekvAadress)),70)>></AdrLine>
</PstlAdr>
</Dbtr>
<DbtrAcct>
<Id><IBAN><<Alltrim(IIF(ISNULL(tmp_mk.omaArve),'',tmp_mk.omaArve))>></IBAN></Id>
<Ccy>EUR</Ccy>
</DbtrAcct>
<DbtrAgt>
<FinInstnId>
<BIC><<lcPankIban>></BIC>
</FinInstnId>
</DbtrAgt>
<ChrgBr>SLEV</ChrgBr>
<CdtTrfTxInf>
<PmtId>
<InstrId><<ALLTRIM(tmp_mk.number)>></InstrId>
<EndToEndId><<ALLTRIM(STR(tmp_mk1.id))>></EndToEndId>
</PmtId>
<Amt><InstdAmt Ccy="EUR"><<Alltrim(Str(tmp_mk1.Summa,14,2))>></InstdAmt></Amt>
<Cdtr>
<Nm><<convert_to_utf(Alltrim(tmp_mk1.asutus))>></Nm>
<PstlAdr><Ctry>EE</Ctry><AdrLine><<LEFT(convert_to_utf(Alltrim(tmp_mk1.aadress)),70)>></AdrLine></PstlAdr>
</Cdtr>
<CdtrAcct><Id><IBAN><<Alltrim(tmp_mk1.aa)>></IBAN></Id></CdtrAcct>
<RmtInf>
<<IIF(!Empty(tmp_mk.selg),'<Ustrd>'+convert_to_utf(Alltrim(tmp_mk.selg))+'</Ustrd>','')>>
<<IIF(!Empty(tmp_mk.viitenr),'<Strd><CdtrRefInf><Tp><CdOrPrtry><Cd>SCOR</Cd></CdOrPrtry></Tp><Ref>'+Alltrim(tmp_mk.viitenr)+'</Ref></CdtrRefInf></Strd>','')>>
</RmtInf>
</CdtTrfTxInf>
</PmtInf>

ENDTEXT
		Endscan
		lnId = lnId + 1
	Endscan
TEXT TO lcString ADDITIVE TEXTMERGE NOSHOW

</CstmrCdtTrfInitn>
</Document>
ENDTEXT

	Create Cursor tmpMk (iso m)
	Append Blank

	Replace tmpMk.iso With lcString  Additive In tmpMk

	lcString = Alltrim(tmpMk.iso)

	Strtofile(lcString, cFail, 4)
	Use In tmpMk
*	Copy Memo tmpMk.iso To (cFail)
	Return File(cFail)
Endfunc


Function TEST
	gRekv = 1
	cFail = 'c:\temp\buh60\EDOK\mk_iso.xml'
	cFailbak = 'c:\temp\buh60\EDOK\'+Alltrim(Str(gRekv))+'iso'+Sys(2015)+'.bak'

	If !Used('repositpg')
		Use repositpg In 0
	Endif

	Select repositpg
	Locate For objekt = 'tmp_mk'

	Restore From Memo repositpg.prop1 Additive
	Create Cursor 'tmp_mk' From Array aObjekt
	Release aObjekt


	Select repositpg
	Locate For objekt = 'tmp_mk1'

	Restore From Memo repositpg.prop1 Additive
	Create Cursor 'tmp_mk1' From Array aObjekt
	Release aObjekt

	Select tmp_mk
	Insert Into tmp_mk (rekvId, aaid, kpv, maksepaev, Number, selg, viitenr, omaArve );
		VALUES (1, 99999, Date(), Date()+1, 'test0001', 'test iso', '1223','EE1234')

TEXT TO lcAddr noshow
	Ouna talu 117,
	Kudruküla
ENDTEXT

	Select tmp_mk1
	Insert Into tmp_mk1 (Summa, aa, pank, kood, asutus, aadress, valuuta, kuurs) ;
		VALUES (100, '1234567890', '767', 'kood', 'Asutus',lcAddr, 'EUR', 1)

	Use In repositpg

	Select 0


	Create Cursor qryRekv (nimetus c(254), aadress m)
	Insert Into qryRekv (nimetus, aadress) Values ('Test asutus',lcAddr)

Endfunc


*!*	FUNCTION convert_to_utf
*!*	LPARAMETERS tcSona
*!*	LOCAL lcReturnSona
*!*	lcReturnSona = ''

*!*	IF ISNULL(tcSona)
*!*		RETURN lcReturnSona
*!*	endif

*!*	FOR i = 0 TO LEN(tcSona)
*!*		lcTaht = SUBSTR(tcSona,i,1)
*!*		?lcTaht
*!*		DO CASE
*!*			CASE lcTaht = 'ü'
*!*				lcTaht = '&#252;'
*!*			CASE lcTaht = 'Ü'
*!*				lcTaht = '&#220;'
*!*			CASE lcTaht = 'õ'
*!*				lcTaht = '&#245;'
*!*			CASE lcTaht = 'Õ'
*!*				lcTaht = '&#213;'
*!*			CASE lcTaht = 'ä'
*!*				lcTaht = '&#228;'
*!*			CASE lcTaht = 'Ä'
*!*				lcTaht = '&#196;'
*!*			CASE lcTaht = 'ö'
*!*				lcTaht = '&#246;'
*!*			CASE lcTaht = 'Ö'
*!*				lcTaht = '&#214;'
*!*			CASE lcTaht = 'è'
*!*				lcTaht = '&#269;'
*!*			CASE lcTaht = 'È'
*!*				lcTaht = '&#268;'
*!*			CASE lcTaht = 'þ'
*!*				lcTaht = '&#382;'
*!*			CASE lcTaht = 'Þ'
*!*				lcTaht = '&#381;'
*!*			CASE lcTaht = 'ð'
*!*				lcTaht = '&#353;'
*!*			CASE lcTaht = 'Ð'
*!*				lcTaht = '&#352;'
*!*			CASE lcTaht = '&'
*!*				lcTaht = '&#038;'
*!*		ENDCASE
*!*		lcReturnSona = lcReturnSona + lcTaht
*!*	ENDFOR

*!*	RETURN lcReturnSona
*!*	END funct
