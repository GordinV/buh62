* omniva soap

Parameters td_since
IF EMPTY(td_since)
	td_since = DATE(2019,04,01)
ENDIF


If !Used('m_memo')
	Create Cursor m_memo (url c(120), Header c(120), Request m, response m, Timestamp T Default Datetime())
Endif

IF !USED('qryRekv')
	CREATE CURSOR qryRekv (earved c(254), regkood c(20))
	INSERT INTO qryRekv  (earved, regkood) VALUES ('106549:elbevswsackajyafdoupavfwewuiafbeeiqatgvyqcqdqxairz','75008427')
ENDIF


Local loXMLHTTP As "MSXML2.XMLHTTP"
Local cUrl, l_found_xml
Local cMessage

cUrl = ALLTRIM(config.earved)
cMessage = getBuyInvoiceExportRequest(td_since)

loXMLHTTP = Createobject("MSXML2.XMLHTTP")
l_found_xml = 0

With loXMLHTTP

	.Open("POST", cUrl ,.F.)
	.setRequestHeader('Content-Type', 'text/xml;charset=UTF-8')
	.setRequestHeader('user-agent', 'sampleTest')
	.setRequestHeader('soapAction', '')

	WAIT WINDOW 'Oodan omniva... ' nowait
	.Send(cMessage)
	WAIT WINDOW 'Oodan omniva... ok' nowait
	
	Insert Into m_memo (url, Header, Request, response) Values (cUrl, 'text/xml;charset=UTF-8', cMessage, .responsetext)
	WAIT WINDOW 'Loen vastus...' nowait
	l_found_xml = parse_response(.responsetext)
	l_found_xml = IIF(EMPTY(l_found_xml),0,l_found_xml)
	
	WAIT WINDOW 'Loen vastus...' + ALLTRIM(STR(l_found_xml)) + ' arved' nowait

ENDWITH

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

	l_invoice_start_line = Atc('<Invoice ',v_xml.XML)
	l_invoice_last_line = Rat('</Invoice>',v_xml.XML )
	l_parced_xml_invoices = Substrc(v_xml.XML, l_invoice_start_line, (l_invoice_last_line + Len('</Invoice>')) - l_invoice_start_line)

* count invoices in xml

	l_xml_invoice_count = Occurs('</Invoice>',v_xml.XML)
	Wait Window 'Leidnud '+ Str(l_xml_invoice_count) + 'arved, loen... ' NOWAIT

	For l_invoice_id = 1 To l_xml_invoice_count
		l_invoice_start_line = Atc('<Invoice ',l_parced_xml_invoices, l_invoice_id)
		l_invoice_last_line = Atc('</Invoice>',l_parced_xml_invoices, l_invoice_id)
		If Empty(l_invoice_start_line)
			Exit
		Endif

		l_parced_xml = Substrc(l_parced_xml_invoices, l_invoice_start_line, (l_invoice_last_line + Len('</Invoice>')) - l_invoice_start_line)

		parce_invoice(l_parced_xml)
		Wait Window 'Loen '+ Alltrim(Str(l_invoice_id)) + '/'+ Alltrim(Str(l_xml_invoice_count)) + ' '  + Alltrim(v_xml_arv.Number) + ' lõppetatud' NOWAIT 
	Endfor


*XMLTOCURSOR(l_parced_xml,'v_xml_responce',0)
*BROWSE

	Return l_xml_invoice_count
Endfunc

Function parce_invoice
	Parameters l_xml_invoice
	Local l_parced_xml, l_invoice_start_line, l_invoice_last_line

	If !Used('v_xml_arv')
		Create Cursor v_xml_arv (Id Int Autoinc, Number c(120), kpv d, Summa N(14,2), asutus c(120), regkood c(20))
	Endif

	If !Used('v_xml_arv_confirmators')
		Create Cursor v_xml_arv_confirmators (Id Int, isik c(254), kpv c(120), roll c(120))
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
	
	 TRY
		Replace v_xml_arv.Number With Iif(Type('v_xml_invoice_data.invoiceNumber') = 'N', Alltrim(Str(v_xml_invoice_data.invoiceNumber)),;
			IIF(TYPE('v_xml_invoice_data.invoiceNumber') <> 'C','0',v_xml_invoice_data.invoiceNumber)),;
			v_xml_arv.kpv With v_xml_invoice_data.invoiceDate In v_xml_arv
      CATCH TO oErr
         WAIT window "Catch:" + oErr.ErrorNo
      	SELECT v_xml_invoice_data
      	brow
      FINALLY
      ENDTRY	
	Use In v_xml_invoice_data

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
					Insert Into v_xml_arv_confirmators (Id, isik, roll) ;
						VALUES (v_xml_arv.Id, v_xml_invoice_confirmator.InformationContent, 'Kinnitaja')
						
					IF Type('v_xml_invoice_confirmator.InformationName') = 'T'
						replace v_xml_arv_confirmators.kpv with TTOC(v_xml_invoice_confirmator.InformationName) IN v_xml_arv_confirmators				
					ENDIF

					Use In v_xml_invoice_confirmator
				Endif
			Endif

		Endfor
	ENDIF
	
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
					Insert Into v_xml_arv_confirmators (Id, isik, roll) ;
						VALUES (v_xml_arv.Id, v_xml_invoice_confirmator.InformationContent, 'Koostaja')

					IF Type('v_xml_invoice_confirmator.InformationName') = 'T'
						replace v_xml_arv_confirmators.kpv with TTOC(v_xml_invoice_confirmator.InformationName) IN v_xml_arv_confirmators				
					ENDIF

					Use In v_xml_invoice_confirmator
				Endif
			Endif

		Endfor
	Endif

	Return .T.
Endfunc




