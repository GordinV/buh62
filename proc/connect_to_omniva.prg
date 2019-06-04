* omniva soap

Parameters td_since
If Empty(td_since)
	td_since = Date(2019,05,29)
Endif

* will open cursors
=check_cursors()


Local loXMLHTTP As "MSXML2.XMLHTTP"
Local cUrl, l_found_xml
Local cMessage



cUrl = Alltrim(config.earved)


cMessage = getBuyInvoiceExportRequest(td_since)

loXMLHTTP = Createobject("MSXML2.XMLHTTP")
l_found_xml = 0

With loXMLHTTP

	.Open("POST", cUrl ,.F.)
	.setRequestHeader('Content-Type', 'text/xml;charset=UTF-8')
	.setRequestHeader('user-agent', 'sampleTest')
	.setRequestHeader('soapAction', '')

	Wait Window 'Oodan omniva... ' Nowait
	.Send(cMessage)
	Wait Window 'Oodan omniva... ok' Nowait

	Insert Into m_memo (url, Header, Request, response) Values (cUrl, 'text/xml;charset=UTF-8', cMessage, .responsetext)
	Wait Window 'Loen vastus...' Nowait
	l_found_xml = parse_response(.responsetext)
	l_found_xml = Iif(Empty(l_found_xml),0,l_found_xml)

	Wait Window 'Loen vastus...' + Alltrim(Str(l_found_xml)) + ' arved' Nowait

Endwith

*!*	If Used('v_xml_arv') And Reccount('v_xml_arv') > 0
*!*		import_invoice()
*!*		Return
*!*	Endif



Return l_found_xml
Endfunc



Function getBuyInvoiceExportRequest
	Parameters l_cince

	Set Date Italian
	If Empty(l_cince)
		l_cince = Datetime()
	Endif
	l_cince = Ttoc(l_cince)

	Set Date German

TEXT TO c_xml TEXTMERGE noshow
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
xmlns:erp="http://e-arvetekeskus.eu/erp">
<soapenv:Header/>
<soapenv:Body>
<erp:BuyInvoiceExportRequest since="<<l_cince>>" authPhrase="<<ALLTRIM(qryRekv.earved)>>">
<erp:state>RECEIVED</erp:state>
<erp:state>VERIFIED</erp:state>
<erp:state>FORPAY</erp:state>
<erp:state>BEING_VERIFIED</erp:state>
<erp:state>DECLINED</erp:state>
<erp:state>PAID</erp:state>
<erp:state>RETURNED_TO_SENDER</erp:state>
</erp:BuyInvoiceExportRequest>
</soapenv:Body>
</soapenv:Envelope>
ENDTEXT
	Return c_xml

Endfunc

Function parse_response
	Parameters l_xml
	Local l_parced_xml, l_invoice_start_line, l_invoice_last_line, l_xml_invoice_count, l_xml_invoice, l_parced_xml_invoices
* cut all text starting from <invoice up to last </invoice
	Create Cursor v_xml (XML m)
	Append Blank
	Replace XML With l_xml In v_xml


* count invoices in xml

	l_xml_invoice_count = Occurs('</Invoice>',v_xml.XML)
	Wait Window 'Leidnud '+ Str(l_xml_invoice_count) + 'arved, loen... ' Nowait

	For l_invoice_id = 1 To l_xml_invoice_count
		l_invoice_start_line = Atc('<Invoice ',v_xml.XML, l_invoice_id)
		l_invoice_last_line = Atc('</Invoice>',v_xml.XML, l_invoice_id)
		If Empty(l_invoice_start_line)
			Exit
		Endif

		l_parced_xml = Substrc(v_xml.XML, l_invoice_start_line, (l_invoice_last_line + Len('</Invoice>')) - l_invoice_start_line)

		parce_invoice(l_parced_xml)
		Wait Window 'Loen '+ Alltrim(Str(l_invoice_id)) + '/'+ Alltrim(Str(l_xml_invoice_count)) + ' '  + Alltrim(v_xml_arv.Number) + ' lõppetatud' Nowait
	Endfor


	Return l_xml_invoice_count
Endfunc

Function parce_invoice
	Parameters l_xml_invoice
	Local l_parced_xml, l_invoice_start_line, l_invoice_last_line

	If !Used('v_xml_arv')
		Create Cursor v_xml_arv (Id Int Autoinc, Number c(120), kpv d, tahtpaev d, Summa N(14,2), kbm N(14,2), kbmta N(14,2), asutus c(120), regkood c(20),;
			lisa c(254))
	Endif

	If !Used('v_xml_arv_detail')
		Create Cursor v_xml_arv_detail (Id Int, nimetus c(254), Summa N(14,2), kbm N(14,2), kbm_maar c(20),;
			summa_kokku N(14,2), konto c(20), artikkel c(20), tegev c(20), allikas c(20))
	Endif

	If !Used('v_xml_arv_confirmators')
		Create Cursor v_xml_arv_confirmators (Id Int, isik c(254), kpv c(120), Roll c(120))
	Endif

* <InvoiceInformation>
	l_invoice_start_line = Atc('<InvoiceInformation>',l_xml_invoice)
	l_invoice_last_line = Rat('</InvoiceInformation>',l_xml_invoice )
	l_parced_xml = Substrc(l_xml_invoice, l_invoice_start_line, (l_invoice_last_line + Len('</InvoiceInformation>')) - l_invoice_start_line)

* remove <Type type="DEB"/>
	l_parced_xml = Stuff(l_parced_xml, Atc('<Type type="DEB"/>',l_parced_xml), Len('<Type type="DEB"/>'),'')

* remove <Extension>
	l_parced_xml = '<vfp>' + Stuff(l_parced_xml, Atc('<Extension',l_parced_xml),;
		(Rat('</Extension>',l_parced_xml) - Atc('<Extension',l_parced_xml)) + Len('</Extension>'),'') + '</vfp>'

	Xmltocursor(l_parced_xml,'v_xml_invoice_data',0)

	Select v_xml_arv
	Append Blank
	Try
		Replace v_xml_arv.Number With Iif(Type('v_xml_invoice_data.invoiceNumber') = 'N', Alltrim(Str(v_xml_invoice_data.invoiceNumber)),;
			IIF(Type('v_xml_invoice_data.invoiceNumber') <> 'C','0',v_xml_invoice_data.invoiceNumber)),;
			v_xml_arv.lisa With Left(Alltrim(v_xml_invoice_data.InvoiceContentText),254),;
			v_xml_arv.kpv With v_xml_invoice_data.invoiceDate,;
			v_xml_arv.tahtpaev With v_xml_invoice_data.DueDate In v_xml_arv
	Catch To oErr
		Wait Window "Catch:" + oErr.ErrorNo
		Select v_xml_invoice_data
		BROWSE
		SET STEP ON 
	Finally
	Endtry
	Use In v_xml_invoice_data

* InvoiceItem
* count items
	l_xml_invoice_read_count = Occurs('</InvoiceItem>',l_xml_invoice)

	For l_invoice_rea = 1 To l_xml_invoice_read_count
		l_invoice_rea_start_line = Atc('<InvoiceItem',l_xml_invoice, l_invoice_rea)
		l_invoice_rea_finish_line = Atc('</InvoiceItem>',l_xml_invoice, l_invoice_rea)
		If Empty(l_invoice_rea_start_line)
			Exit
		Endif
		l_parced_row_xml = Substrc(l_xml_invoice, l_invoice_rea_start_line, (l_invoice_rea_finish_line + Len('</InvoiceItem>')) - l_invoice_rea_start_line)


* parcing description
		l_invoice_start_line = Atc('<InvoiceItemGroup',l_parced_row_xml)
		l_invoice_last_line = Rat('</InvoiceItemGroup>',l_parced_row_xml)
		l_parced_xml = Substrc(l_parced_row_xml, l_invoice_start_line, (l_invoice_last_line + Len('</InvoiceItemGroup>')) - l_invoice_start_line)

		Xmltocursor(l_parced_xml,'v_xml_invoice_detail',0)
		Select v_xml_invoice_detail

*	Select v_xml_arv_detail
		Insert Into v_xml_arv_detail (Id, nimetus, Summa, summa_kokku, kbm) ;
			VALUES (v_xml_arv.Id, v_xml_invoice_detail.Description, v_xml_invoice_detail.itemsum, ;
			v_xml_invoice_detail.itemTotal, v_xml_invoice_detail.itemTotal - v_xml_invoice_detail.itemsum)
		Use In v_xml_invoice_detail

* kontod

		l_invoice_start_line = Atc('<Accounting',l_parced_row_xml)
		l_invoice_last_line = Rat('</Accounting>',l_parced_row_xml)
		l_parced_xml = Substrc(l_parced_row_xml, l_invoice_start_line, (l_invoice_last_line + Len('</Accounting>')) - l_invoice_start_line)

		If Len(l_parced_xml) > 0

			Xmltocursor(l_parced_xml,'v_xml_invoice_accounting',0)

			Select v_xml_invoice_accounting
			Go Top
			Replace v_xml_arv_detail.konto With Alltrim(Str(v_xml_invoice_accounting.GeneralLedger)) In v_xml_arv_detail

* looking for kood in libs
			Scan
* kas artikkel
				Select comArtikkelRemote
				Locate For Alltrim(kood) = Alltrim(v_xml_invoice_accounting.CostObjective)
				If Found()
					Replace v_xml_arv_detail.artikkel With Alltrim(v_xml_invoice_accounting.CostObjective) In v_xml_arv_detail
					Continue
				Endif

* kas tegev
				Select comTegevRemote
				Locate For Alltrim(kood) = Alltrim(v_xml_invoice_accounting.CostObjective)
				If Found()
					Replace v_xml_arv_detail.tegev With Alltrim(v_xml_invoice_accounting.CostObjective) In v_xml_arv_detail
					Continue
				Endif

* kas allikas
				Select comAllikasRemote
				Locate For Alltrim(kood) = Alltrim(v_xml_invoice_accounting.CostObjective)
				If Found()
					Replace v_xml_arv_detail.allikas With Alltrim(v_xml_invoice_accounting.CostObjective) In v_xml_arv_detail
					Continue
				Endif

			Endscan

* subtotals
			Select Sum(Summa) As Summa, Sum(summa_kokku) As summa_kokku, Sum(kbm) As kbm ;
				FROM v_xml_arv_detail ;
				WHERE Id = v_xml_arv.Id ;
				INTO Cursor tmp_subtotals

			Update 	v_xml_arv Set  kbmta = tmp_subtotals.summa_kokku - tmp_subtotals.Summa, ;
				kbm = tmp_subtotals.kbm, ;
				summa = tmp_subtotals.Summa ;
				WHERE Id = v_xml_arv.Id

			Use In tmp_subtotals

			Use In v_xml_invoice_accounting
		Endif

		Select v_xml_arv_detail



	Endfor


* InvoiceParties
	l_invoice_start_line = Atc('<InvoiceParties>',l_xml_invoice)
	l_invoice_last_line = Rat('</InvoiceParties>',l_xml_invoice )
	l_parced_xml = Substrc(l_xml_invoice, l_invoice_start_line, (l_invoice_last_line + Len('</InvoiceParties>')) - l_invoice_start_line)
	Xmltocursor(l_parced_xml,'v_xml_invoice_parties',0)
	Select v_xml_invoice_parties
	Locate For Alltrim(Str(v_xml_invoice_parties.regnumber)) <> Alltrim(qryRekv.regkood)

	Replace v_xml_arv.asutus With v_xml_invoice_parties.Name, regkood With Alltrim(Str(v_xml_invoice_parties.regnumber)) In v_xml_arv
	Use In v_xml_invoice_parties


* InvoiceConfirmation
	l_confirmation_count = 	Occurs('eakConfirmation',l_xml_invoice)
	If !Empty(l_confirmation_count)
		For l_confirmation_id = 1 To l_confirmation_count
			l_invoice_start_line = Atc('<Extension extensionId="eakConfirmation">',l_xml_invoice,l_confirmation_id)
			l_invoice_last_line = Atc('</Extension>',Right(l_xml_invoice,Len(l_xml_invoice) - l_invoice_start_line))
			l_confirmator_xml =  '<vfp>'+Substrc(l_xml_invoice, l_invoice_start_line, (l_invoice_last_line + Len('</Extension>'))) +'</vfp>'

			If !Empty(l_invoice_start_line)
				Xmltocursor(l_confirmator_xml,'v_xml_invoice_confirmator',0)
				If Used('v_xml_invoice_confirmator')
					Insert Into v_xml_arv_confirmators (Id, isik, Roll) ;
						VALUES (v_xml_arv.Id, v_xml_invoice_confirmator.InformationContent, 'Kinnitaja')

					If Type('v_xml_invoice_confirmator.InformationName') = 'T'
						Replace v_xml_arv_confirmators.kpv With Ttoc(v_xml_invoice_confirmator.InformationName) In v_xml_arv_confirmators
					Endif

					Use In v_xml_invoice_confirmator
				Endif
			Endif

		Endfor
	Endif

* InvoiceCreator
	l_createtor_count = 	Occurs('eakConfirmCreator',l_xml_invoice)
	If !Empty(l_confirmation_count)
		For l_confirmation_id = 1 To l_confirmation_count
			l_invoice_start_line = Atc('<Extension extensionId="eakConfirmCreator">',l_xml_invoice,l_confirmation_id)
			l_invoice_last_line = Atc('</Extension>',Right(l_xml_invoice,Len(l_xml_invoice) - l_invoice_start_line))
			l_confirmator_xml =  '<vfp>'+Substrc(l_xml_invoice, l_invoice_start_line, (l_invoice_last_line + Len('</Extension>'))) +'</vfp>'

			If !Empty(l_invoice_start_line)
				Xmltocursor(l_confirmator_xml,'v_xml_invoice_confirmator',0)
				If Used('v_xml_invoice_confirmator')
					Insert Into v_xml_arv_confirmators (Id, isik, Roll) ;
						VALUES (v_xml_arv.Id, v_xml_invoice_confirmator.InformationContent, 'Koostaja')

					If Type('v_xml_invoice_confirmator.InformationName') = 'T'
						Replace v_xml_arv_confirmators.kpv With Ttoc(v_xml_invoice_confirmator.InformationName) In v_xml_arv_confirmators
					Endif

					Use In v_xml_invoice_confirmator
				Endif
			Endif

		Endfor
	Endif

	Return .T.
Endfunc


Function check_cursors

	If !Used('m_memo')
		Create Cursor m_memo (url c(120), Header c(120), Request m, response m, Timestamp T Default Datetime())
	Endif

	If !Used('qryRekv')
		Create Cursor qryRekv (earved c(254), regkood c(20))
		Insert Into qryRekv  (earved, regkood) Values ('106549:elbevswsackajyafdoupavfwewuiafbeeiqatgvyqcqdqxairz','75008427')
	Endif


	If !Used('config')
		Create Cursor config (earved c(254))
		Insert Into config (earved) Values ('https://finance.omniva.eu/finance/erp/')
	Endif

	If !Used('comArtikkelRemote')
		Create Cursor comArtikkelRemote (kood c(20))
		Insert Into comArtikkelRemote  (kood) Values ('5514')
	Endif

	If !Used('comTegevRemote')
		Create Cursor comTegevRemote (kood c(20))
		Insert Into comTegevRemote  (kood) Values ('01112')
	Endif

	If !Used('comAllikasRemote')
		Create Cursor comAllikasRemote (kood c(20))
		Insert Into comAllikasRemote  (kood) Values ('LE-P')
	Endif

	If !Used('comAsutusRemote')
		Create Cursor comAsutusRemote (Id Int, regkood c(20), nimetus c(254), tp c(20))
		Insert Into comAsutusRemote  (Id, regkood, nimetus,tp) Values (1, '11047855','DATEL VIRU OÜ','800599')
	Endif

	If !Used('comNomRemote')
		Create Cursor comNomRemote (Id Int, kood c(20), nimetus c(254))
		Insert Into comNomRemote  (Id, kood, nimetus) Values (1, 'tark','Tarkvara tootmine Põhivara moduule parandamine')
	Endif

Endfunc

*!*	FUNCTION getNomIdByNimetus
*!*	PARAMETERS tcNimetus
*!*	LOCAL l_id

*!*	SELECT comNomRemote
*!*	LOCATE FOR ALLTRIM(UPPER(nimetus)) = ALLTRIM(UPPER(tcNimetus))
*!*	IF found()
*!*		l_id = comNomRemote.id
*!*	ELSE
*!*		* save noms
*!*		INSERT INTO comNomRemote (id, kood, nimetus) VALUES (2,'',tcNimetus)
*!*		l_id = comNomRemote.id
*!*	ENDIF
*!*	RETURN l_id

*!*	endfunc

*!*	(ALLTRIM(UPPER(v_xml_arv_detail.nimetus)))



*!*	Function import_invoice
*!*		If Type('Odb') = 'U'
*!*			Set Classlib To classes\Classlib
*!*			oDb = Createobject('db')
*!*			oDb.login = 'temp'
*!*			oDb.Pass = '12345'
*!*			gnHandle = SQLConnect('test_server','temp','12345')
*!*			gRekv = 63
*!*			gUserId = 70
*!*		Endif

*!*	* load model

*!*		tnId = -1
*!*		l_error = oDb.readFromModel('raamatupidamine\arv', 'row', 'tnId, guserid', 'v_arv')
*!*		If !l_error Or !Used('v_arv')
*!*			Set Step On
*!*			Return .F.
*!*		Endif

*!*		l_error = oDb.readFromModel('raamatupidamine\arv', 'details', 'tnId, guserid', 'v_arvread')
*!*		If !l_error Or !Used('v_arvread')
*!*			Set Step On
*!*			Return .F.
*!*		Endif
*!*		Select v_xml_arv
*!*		Scan
*!*			Wait Window 'Importeerin arve nr. ' + Alltrim(v_xml_arv.Number) Timeout 1

*!*	* asutusId
*!*			Select comAsutusRemote
*!*			Locate For Alltrim(regkood) = Alltrim(v_xml_arv.regkood)

*!*			If !Found()
*!*				Messagebox('Asutus:' + Alltrim(v_xml_arv.asutus) + ',' + Alltrim(v_xml_arv.regkood) + ' ei leidnud',0+64,'e-Arve import')
*!*			Else
*!*				Select v_arv
*!*				Insert Into v_arv (rekvid, userid, Number, liik, kpv, asutusid, Summa, kbmta, kbm, tahtaeg, lisa) ;
*!*					VALUES (gRekv, gUserId, v_xml_arv.Number, 1, v_xml_arv.kpv, comAsutusRemote.Id, v_xml_arv.Summa, ;
*!*					v_xml_arv.Summa-v_xml_arv.kbm, v_xml_arv.kbm, v_xml_arv.tahtpaev, v_xml_arv.lisa)
*!*					
*!*					
*!*				* details
*!*				SELECT 	v_xml_arv_detail
*!*				SCAN FOR id = v_xml_arv.id
*!*					* seach for noms
*!*					l_nom_id = getNomIdByNimetus(ALLTRIM(UPPER(v_xml_arv_detail.nimetus)))
*!*					
*!*					INSERT INTO v_arvread (nomid, kogus, hind, summa, kbmta, kbm, nimetus, konto, tp, kood1, kood2, kood5) ;
*!*						VALUES (l_nom_id, 1, v_xml_arv_detail.summa, v_xml_arv_detail.summa, v_xml_arv_detail.summa,0,v_xml_arv_detail.nimetus,;
*!*						 v_xml_arv_detail.konto,;
*!*						comAsutusRemote.tp, v_xml_arv_detail.tegev, v_xml_arv_detail.allikas, v_xml_arv_detail.artikkel)
*!*				ENDSCAN
*!*							

*!*			Endif



*!*	*NOWAIT
*!*		Endscan

*!*		=SQLDISCONNECT(gnHandle)

*!*		Select v_arv
*!*		Brow

*!*	Endfunc
