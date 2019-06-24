* omniva soap

Parameters td_since
If Empty(td_since)
	td_since = Date(2019,06,18)
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
<erp:state>VERIFIED</erp:state>
</erp:BuyInvoiceExportRequest>
</soapenv:Body>
</soapenv:Envelope>
ENDTEXT
*!*	<erp:state>RECEIVED</erp:state>
*!*	<erp:state>VERIFIED</erp:state>
*!*	<erp:state>FORPAY</erp:state>
*!*	<erp:state>BEING_VERIFIED</erp:state>
*!*	<erp:state>DECLINED</erp:state>
*!*	<erp:state>PAID</erp:state>
*!*	<erp:state>RETURNED_TO_SENDER</erp:state>


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
		Wait Window 'Loen '+ Alltrim(Str(l_invoice_id)) + '/'+ Alltrim(Str(l_xml_invoice_count)) + ' '  + Alltrim(v_xml_arv.Number) + ' l�ppetatud' Nowait
	Endfor


	Return l_xml_invoice_count
Endfunc

Function parce_invoice
	Parameters l_xml_invoice
	Local l_parced_xml, l_invoice_start_line, l_invoice_last_line

	If !Used('v_xml_arv')
		Create Cursor v_xml_arv (Id Int Autoinc, Number c(120), kpv d, tahtpaev d, Summa N(14,2), kbm N(14,2), kbmta N(14,2), asutus c(120), regkood c(20),;
			lisa c(254), viitenr c(20), korr_konto c(20), arve c(20))
	Endif
	If !Used('v_xml_arv_detail')
		Create Cursor v_xml_arv_detail (Id Int, nimetus c(254), Summa N(14,2), kbm N(14,2), kbm_maar c(20),;
			summa_kokku N(14,2), konto c(20), artikkel c(20), tegev c(20), allikas c(20), kogus N(12,4))
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

	CREATE CURSOR v_xml_invoice_data (invoiceNumber c(20), invoiceDate d, paymentreferencenumber c(20), DueDate d, ContractNumber c(254), accountNUmber c(20))
	Xmltocursor(l_parced_xml,'v_xml_invoice_data',8192)
	
	Select v_xml_arv
	Append Blank
	Try
		Replace v_xml_arv.Number With v_xml_invoice_data.invoiceNumber,;
			v_xml_arv.kpv With v_xml_invoice_data.invoiceDate,;
			v_xml_arv.viitenr with v_xml_invoice_data.paymentreferencenumber,;
			v_xml_arv.lisa WITH v_xml_invoice_data.ContractNumber,;
			v_xml_arv.tahtpaev With v_xml_invoice_data.DueDate In v_xml_arv
	Catch To oErr
		Wait Window "Catch:" + oErr.ErrorNo
		Select v_xml_invoice_data
		Browse
		Set Step On
	Finally
	Endtry
	Use In v_xml_invoice_data
	
	* arve nr.
	
	l_parced_xml = substr(l_xml_invoice, Atc('<SellerParty',l_xml_invoice),;
	(Rat('</SellerParty>',l_xml_invoice) - Atc('<SellerParty',l_xml_invoice) + Len('</SellerParty>'))) 
		
	
	l_parced_xml = '<vfp>'+substr(l_parced_xml, Atc('<AccountInfo',l_parced_xml),;
	(Rat('</AccountInfo>',l_parced_xml) - Atc('<AccountInfo',l_parced_xml) + Len('</AccountInfo>'))) + '</vfp>' 
		
	CREATE CURSOR v_xml_invoice_bank_data (AccountNumber c(20), IBAN c(20), BankName c(20))
	Xmltocursor(l_parced_xml,'v_xml_invoice_bank_data',8192)

	replace v_xml_arv.arve WITH v_xml_invoice_bank_data.AccountNumber IN v_xml_arv

	

* InvoiceItem
* count items
*	l_xml_invoice_read_count = Occurs('</InvoiceItem>',l_xml_invoice)
	l_xml_invoice_read_count = Occurs('</ItemEntry>',l_xml_invoice)

	For l_invoice_rea = 1 To l_xml_invoice_read_count
		l_invoice_rea_start_line = Atc('<ItemEntry',l_xml_invoice, l_invoice_rea)
		l_invoice_rea_finish_line = Atc('</ItemEntry>',l_xml_invoice, l_invoice_rea)
		If Empty(l_invoice_rea_start_line)
			Exit
		Endif
		l_parced_row_xml = Substrc(l_xml_invoice, l_invoice_rea_start_line, (l_invoice_rea_finish_line + Len('</ItemEntry>')) - l_invoice_rea_start_line)

* parcing description
		l_invoice_start_line = Atc('<ItemEntry',l_parced_row_xml)
		l_invoice_last_line = Rat('</ItemEntry>',l_parced_row_xml)
		l_parced_xml = '<vfp>' + Substrc(l_parced_row_xml, l_invoice_start_line, (l_invoice_last_line + Len('</ItemEntry>')) - l_invoice_start_line) + '</vfp>'

		
		CREATE CURSOR 	v_xml_invoice_detail (itemsum n(12,2),itemtotal n(12,2), itemamount n(12,4), ;
			Description c(254) )
			
		Xmltocursor(l_parced_xml,'v_xml_invoice_detail',8192)
		Select v_xml_invoice_detail

*	Select v_xml_arv_detail
		l_itemsum = 0
		If Type('v_xml_invoice_detail.itemsum') = 'C' Or Type('v_xml_invoice_detail.itemsum') = 'N'
			l_itemsum = Iif(Type('v_xml_invoice_detail.itemsum') = 'C',Val(v_xml_invoice_detail.itemsum),v_xml_invoice_detail.itemsum)
		Endif

		l_itemtotal = 0
		If 	Type('v_xml_invoice_detail.itemtotal') = 'C' Or Type('v_xml_invoice_detail.itemtotal') = 'N'
			l_itemtotal = Iif(Type('v_xml_invoice_detail.itemtotal') = 'C',Val(v_xml_invoice_detail.itemtotal),v_xml_invoice_detail.itemtotal)
		Endif
*!*			IF v_xml_invoice_detail.Description $ 'kaup2'
*!*				SET STEP ON
*!*			ENDIF

		l_itemAmount = 1
		If 	Type('v_xml_invoice_detail.itemamount') = 'C' Or Type('v_xml_invoice_detail.itemamount') = 'N'
			l_itemAmount = Iif(Type('v_xml_invoice_detail.itemamount') = 'C',Val(v_xml_invoice_detail.itemamount),v_xml_invoice_detail.itemamount)
		Endif

		Insert Into v_xml_arv_detail (Id, nimetus, Summa, summa_kokku, kbm, kogus) ;
			VALUES (v_xml_arv.Id, v_xml_invoice_detail.Description, l_itemsum, ;
			l_itemtotal, l_itemtotal - l_itemsum, l_itemAmount)
		Use In v_xml_invoice_detail

		l_invoice_start_line = Atc('<VAT>',l_parced_row_xml)
		l_invoice_last_line = Rat('</VAT>',l_parced_row_xml)
		l_parced_xml = '<vfp>' + Substrc(l_parced_row_xml, l_invoice_start_line, (l_invoice_last_line + Len('</VAT>')) - l_invoice_start_line) + '</vfp>'

		If Len(l_parced_xml) > 0

			CREATE CURSOR v_xml_vat (vatrate c(20), SumBeforeVAT n(12,2),vatsum n(12,2))
			Xmltocursor(l_parced_xml,'v_xml_vat',8192)

			Select v_xml_vat
			Go Top
			If Type('v_xml_vat.vatrate') <> 'U' AND Type('v_xml_vat.vatrate') <> 'L'
*!*					If Empty(v_xml_vat.vatrate)
*!*						l_vatrate = '0'
*!*						l_vatsum = 0
*!*					Else
*!*						l_vatrate = Iif(Type('v_xml_vat.vatrate') = 'C',v_xml_vat.vatrate, Alltrim(Str(v_xml_vat.vatrate)))
*!*						l_vatsum = Iif(Type('v_xml_vat.SumBeforeVAT') = 'C', Val(v_xml_vat.SumBeforeVAT),v_xml_vat.SumBeforeVAT)
*!*					Endif


				Replace v_xml_arv_detail.kbm_maar With v_xml_vat.vatrate,;
					summa With v_xml_vat.SumBeforeVAT,;
					kbm With v_xml_vat.vatsum  In v_xml_arv_detail
			Endif
		Endif

* korr konto
*!*	<ItemReserve extensionId="eakInvoiceItemId">
*!*	            <InformationContent>97044028</InformationContent>
*!*	          </ItemReserve>
*!*	          <ItemReserve extensionId="eakOppositeAccount">
*!*	            <InformationContent>201000</InformationContent>
*!*	</ItemReserve>
		l_invoice_start_line = Atc('<ItemReserve extensionId="eakOppositeAccount">',l_parced_row_xml)
		l_invoice_last_line = Rat('</ItemReserve>',l_parced_row_xml)
		l_parced_xml = Substrc(l_parced_row_xml, l_invoice_start_line, (l_invoice_last_line + Len('</ItemReserve>')) - l_invoice_start_line) 
		l_invoice_last_line = atc('<ItemReserve extensionId="eakVatCode">',l_parced_xml) - 1
		IF l_invoice_last_line > 0 
			l_parced_xml = '<vfp>' + Substrc(l_parced_xml, 1,l_invoice_last_line - 1) + '</vfp>'
		ENDIF
		
		If Len(l_parced_xml) > 0
			CREATE CURSOR v_xml_korrkonto (InformationContent c(20))
			Xmltocursor(l_parced_xml,'v_xml_korrkonto',8192)
			replace v_xml_arv.korr_konto WITH v_xml_korrkonto.InformationContent IN v_xml_arv
			USE IN v_xml_korrkonto
		ENDIF
		

* kontod
		l_invoice_start_line = Atc('<Accounting',l_parced_row_xml)
		l_invoice_last_line = Rat('</Accounting>',l_parced_row_xml)
		l_parced_xml = Substrc(l_parced_row_xml, l_invoice_start_line, (l_invoice_last_line + Len('</Accounting>')) - l_invoice_start_line)

		If Len(l_parced_xml) > 0

			Xmltocursor(l_parced_xml,'v_xml_invoice_accounting',0)

			Select v_xml_invoice_accounting
			Go Top
			If Type('v_xml_invoice_accounting.GeneralLedger') <> 'U'
				Replace v_xml_arv_detail.konto With Alltrim(Str(v_xml_invoice_accounting.GeneralLedger)) In v_xml_arv_detail
			Endif


* looking for kood in libs
			Scan
				If Type('v_xml_invoice_accounting.CostObjective') <> 'U'
					l_kood = Iif(Type('v_xml_invoice_accounting.CostObjective') = 'N',Str(v_xml_invoice_accounting.CostObjective),v_xml_invoice_accounting.CostObjective)
* kas artikkel
					Select comEelarveremote
					Locate For Alltrim(kood) = Alltrim(l_kood)
					If Found()
						Replace v_xml_arv_detail.artikkel With l_kood In v_xml_arv_detail
						Continue
					Endif

* kas tegev
					Select comTegevRemote
					Locate For Alltrim(kood) = Alltrim(l_kood)
					If Found()
						Replace v_xml_arv_detail.tegev With l_kood In v_xml_arv_detail
						Continue
					Endif

* kas allikas
					Select comAllikadRemote
					Locate For Alltrim(kood) = Alltrim(l_kood)
					If Found()
						Replace v_xml_arv_detail.allikas With Alltrim(l_kood) In v_xml_arv_detail
						Continue
					Endif
				Endif

			Endscan

* subtotals

			Select Sum(Summa) As Summa, Sum(summa_kokku) As summa_kokku, Sum(kbm) As kbm ;
				FROM v_xml_arv_detail ;
				WHERE Id = v_xml_arv.Id ;
				INTO Cursor tmp_subtotals

			Replace	v_xml_arv.kbmta With tmp_subtotals.Summa, ;
				v_xml_arv.kbm With tmp_subtotals.kbm, ;
				v_xml_arv.Summa With tmp_subtotals.summa_kokku In v_xml_arv

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

	Create Cursor m_memo (url c(120), Header c(120), Request m, response m, Timestamp T Default Datetime())

	If !Used('qryRekv')
		Create Cursor qryRekv (earved c(254), regkood c(20))
		Insert Into qryRekv  (earved, regkood) Values ('106549:elbevswsackajyafdoupavfwewuiafbeeiqatgvyqcqdqxairz','75008427')
	Endif


	If !Used('config')
		Create Cursor config (earved c(254))
		Insert Into config (earved) Values ('https://finance.omniva.eu/finance/erp/')
	Endif

	If !Used('comEelarveremote')
		Create Cursor comEelarveremote (kood c(20))
		Insert Into comEelarveremote  (kood) Values ('5514')
	Endif

	If !Used('comTegevRemote')
		Create Cursor comTegevRemote (kood c(20))
		Insert Into comTegevRemote  (kood) Values ('01112')
	Endif

	If !Used('comAllikadRemote')
		Create Cursor comAllikadRemote (kood c(20))
		Insert Into comAllikadRemote  (kood) Values ('LE-P')
	Endif

	If !Used('comAsutusRemote')
		Create Cursor comAsutusRemote (Id Int, regkood c(20), nimetus c(254), tp c(20))
		Insert Into comAsutusRemote  (Id, regkood, nimetus,tp) Values (1, '11047855','DATEL VIRU O�','800599')
		Insert Into comAsutusRemote  (Id, regkood, nimetus,tp) Values (2, '10972649','test','800599')
	Endif

	If !Used('comNomRemote')
		Create Cursor comNomRemote (Id Int, kood c(20), nimetus c(254))
		Insert Into comNomRemote  (Id, kood, nimetus) Values (1, 'tark','Tarkvara tootmine P�hivara moduule parandamine')
	Endif

Endfunc
