Lparameters tnMKId
Local lError

lnId = 1
cFail = 'c:\temp\buh60\EDOK\mk_iso.xml'
cFailbak = 'c:\temp\buh60\EDOK\'+Alltrim(Str(grekv))+'iso'+Sys(2015)+'.bak'

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

IF USED('tmp_mk')
	USE IN tmp_mk
ENDIF

IF USED('tmp_mk1')
	USE IN tmp_mk1
ENDIF

If !File(cFail)
	cFail = ''
Endif

Return cFail

Function iso
	LPARAMETERS tnMKId
	Local lcString, lnSummaKokku, lcIsoKpv, lcPankIban, lcRekvNimetus
	IF qryRekv.parentId = 119 OR qryRekv.id = 119
		lcRekvNimetus = 'Narva Linnavalitsuse Kultuuriosakond'
		lcRekvAadress = 'Peetri plats 1, 20308 Narva'
	ELSE 
		lcRekvNimetus = ALLTRIM(qryRekv.nimetus)
		lcRekvAadress = ALLTRIM(qryRekv.aadress)
	ENDIF
	
TEXT TO lcString NOSHOW
	<?xml version="1.0" encoding="UTF-8"?>
	<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03 pain.001.001.03.xsd">

ENDTEXT

	If Empty(tnMKId) or  tnMKId = 0 OR !USED('v_mk')
		Select Distinct Id From curMk WHERE NOT EMPTY(valitud) Into Cursor tmpMkDok
			tnId = -1
			lError = oDb.readFromModel('raamatupidamine\vmk', 'row', 'tnId, guserid', 'tmp_mk')
			IF !lError OR !USED('tmp_mk')
				SET STEP ON 
				MESSAGEBOX('Viga',0+16,'maksekorraldus')
				RETURN .f.
			ENDIF
			
			lError = oDb.readFromModel('raamatupidamine\vmk', 'details', 'tnId, guserid', 'tmp_mk1')
			IF !lError OR !USED('tmp_mk1')
				SET STEP ON 
				MESSAGEBOX('Viga',0+16,'maksekorraldus')
				RETURN .f.
			ENDIF

		Select tmpMkDok
		Scan
			tnId = tmpMkDok.Id
			lError = oDb.readFromModel('raamatupidamine\vmk', 'row', 'tnId, guserid', 'qry_mk')
			IF !lError OR !USED('qry_mk')
				SET STEP ON 
				MESSAGEBOX('Viga',0+16,'maksekorraldus')
				RETURN .f.
			ENDIF
			
			lError = oDb.readFromModel('raamatupidamine\vmk', 'details', 'tnId, guserid', 'qry_mk1')
			IF !lError OR !USED('qry_mk1')
				SET STEP ON 
				MESSAGEBOX('Viga',0+16,'maksekorraldus')
				RETURN .f.
			ENDIF

			Select tmp_mk
			Append From Dbf('qry_Mk')
			USE IN qry_mk

			Select tmp_mk1			
			Append From Dbf('qry_Mk1')
			Use In qry_Mk1
		ENDSCAN
	ELSE
		IF USED('v_mk') 
			SELECT * from v_mk INTO CURSOR tmp_mk
			SELECT * from v_mk1 INTO CURSOR tmp_mk1
		ELSE
			RETURN .f.
		ENDIF
		
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
	
		lcIsoKpv = Str(Year(DATE()),4) + '-'+;
			IIF(Month(DATE())<10,'0','') + Alltrim(Str(Month(DATE()),2))+'-'+;
			IIF(Day(DATE())<10,'0','')+Alltrim(Str(Day(DATE()),2))

	SELECT tmp_mk
	TEXT TO lcString ADDITIVE TEXTMERGE NOSHOW
	 
		<CstmrCdtTrfInitn>
			<GrpHdr>
				<MsgId><<ALLTRIM(STR(tmp_mk.Id))>></MsgId>
				<CreDtTm><<lcIsoKpv>>T08:00:00</CreDtTm>
				<NbOfTxs><<Alltrim(Str(Reccount('tmp_mk1')))>></NbOfTxs>
				<CtrlSum><<Alltrim(Str(lnSummaKokku,14,2))>></CtrlSum>
				<InitgPty><Nm><<Alltrim(lcRekvNimetus)>></Nm></InitgPty>
			</GrpHdr>
			
	ENDTEXT
	
	SCAN FOR !EMPTY(rekvId)
		WAIT WINDOW 'Eksport: ' + ALLTRIM(tmp_mk.number) nowait
		lcIsoKpv = Str(Year(tmp_mk.kpv),4) + '-'+;
			IIF(Month(tmp_mk.kpv)<10,'0','') + Alltrim(Str(Month(tmp_mk.kpv),2))+'-'+;
			IIF(Day(tmp_mk.kpv)<10,'0','')+Alltrim(Str(Day(tmp_mk.kpv),2))

		TEXT TO lcString ADDITIVE TEXTMERGE noshow
				
			<PmtInf>		
				<PmtInfId><<ALLTRIM(tmp_mk.number)>></PmtInfId>
				<PmtMtd>TRF</PmtMtd>
				<BtchBookg>true</BtchBookg>
				<NbOfTxs><<Alltrim(Str(Reccount('tmp_mk1')))>></NbOfTxs>
				<CtrlSum><<Alltrim(Str(lnSummaKokku,14,2))>></CtrlSum>			
				<PmtTpInf><SvcLvl><Cd>SEPA</Cd></SvcLvl></PmtTpInf>
				<ReqdExctnDt><<lcIsoKpv>></ReqdExctnDt>
				<Dbtr>
					<Nm><<Alltrim(lcRekvNimetus)>></Nm>
					<PstlAdr>
						<Ctry>EE</Ctry>
						<AdrLine><<Alltrim(lcRekvAadress)>></AdrLine>
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
				
		ENDTEXT

		Select tmp_mk1
		Scan For parent_id = tmp_mk.Id

			TEXT TO lcString ADDITIVE TEXTMERGE NOSHOW
			 				
					<CdtTrfTxInf>				
						<PmtId>
							<InstrId><<ALLTRIM(tmp_mk.number)>></InstrId>
					</PmtId>
						<Amt><InstdAmt Ccy="EUR"><<Alltrim(Str(tmp_mk1.Summa,14,2))>></InstdAmt></Amt>
						<Cdtr>
							<Nm><<convert_to_utf(Alltrim(tmp_mk1.asutus))>></Nm>
							<PstlAdr><Ctry>EE</Ctry><AdrLine><<convert_to_utf(Alltrim(tmp_mk1.aadress))>></AdrLine></PstlAdr>
						</Cdtr>
						<CdtrAcct><Id><IBAN><<Alltrim(tmp_mk1.aa)>></IBAN></Id></CdtrAcct>
						<RmtInf>	
							<<IIF(!Empty(tmp_mk.selg),'<Ustrd>'+convert_to_utf(Alltrim(tmp_mk.selg))+'</Ustrd>','')>>
							<<IIF(!Empty(tmp_mk.viitenr),'<Strd><CdtrRefInf><Tp><CdOrPrtry><Cd>SCOR</Cd></CdOrPrtry></Tp><Ref>'+Alltrim(tmp_mk.viitenr)+'</Ref></CdtrRefInf></Strd>','')>>
						</RmtInf>
					</CdtTrfTxInf>
					
			ENDTEXT
		ENDSCAN
		TEXT TO lcString ADDITIVE TEXTMERGE NOSHOW 
			</PmtInf>
		ENDTEXT
				
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
	USE IN tmpMk
*	Copy Memo tmpMk.iso To (cFail)
	Return File(cFail)
Endfunc


Function TEST
	grekv = 1
	cFail = 'c:\temp\buh60\EDOK\mk_iso.xml'
	cFailbak = 'c:\temp\buh60\EDOK\'+Alltrim(Str(grekv))+'iso'+Sys(2015)+'.bak'

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
	Insert Into tmp_mk (rekvid, aaid, kpv, maksepaev, Number, selg, viitenr, omaArve );
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
