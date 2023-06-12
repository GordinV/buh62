Parameters tnId
Local loXMLHTTP As "MSXML2.XMLHTTP"
Local cUrl, l_tulemus
Local cMessage

*cUrl = 'https://finance.omniva.eu/finance/erp/'
cUrl = Alltrim(config.earved)
*l_secret = '106549:elbevswsackajyafdoupavfwewuiafbeeiqatgvyqcqdqxairz'
l_secret = ALLTRIM(qryRekv.earved)

* will open cursors
*=check_cursors()
Create Cursor m_memo (url c(120), Header c(120), Request m, response m, Timestamp T Default Datetime())


cMessage = get_xml()

loXMLHTTP = Createobject("MSXML2.XMLHTTP")

With loXMLHTTP

	.Open("POST", cUrl ,.F.)
	.setRequestHeader('Content-Type', 'text/xml;charset=UTF-8')
	.setRequestHeader('user-agent', 'sampleTest')
	.setRequestHeader('soapAction', '')

	Wait Window 'Oodan omniva... ' Nowait
		
		.Send(cMessage)
		Select m_memo
*		MODIFY MEMO m_memo.response 
	
	
	Wait Window 'Oodan omniva... ok' Nowait

	Insert Into m_memo (url, Header, Request, response) Values (cUrl, 'text/xml;charset=UTF-8', cMessage, .responsetext)
	Wait Window 'Loen vastus...' Nowait
	
	IF ATC('Ok', loXMLHTTP.responsetext) > 0
		l_tulemus = .t.
	ENDIF
	
	

Endwith

IF EMPTY(l_tulemus)
	l_answer = MESSAGEBOX('Tekkis viga, kas näida päring?',4+32+256,'E-arved')
	IF l_answer = 6
		_cliptext = cMessage
		Select m_memo
		MODIFY MEMO m_memo.response 
		RETURN .f.
*		Brow	
	ENDIF
ELSE
	MESSAGEBOX('Arve saadetud!',0+48,'E-arved')
ENDIF

Return .t.
Endfunc


Function get_xml
	Local l_xml, l_xml_arve


TEXT TO l_xml TEXTMERGE noshow

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:erp="http://e-arvetekeskus.eu/erp">
<soapenv:Header/>
<soapenv:Body>
<erp:EInvoiceRequest authPhrase="<<l_secret>>">
ENDTEXT

l_xml_arve = calc_earved(tnId)
* remove row <?xml version="1.0" encoding="UTF-8"?>

l_xml_arve =  STUFFC(l_xml_arve, ATC(l_xml_arve, '<?xml version="1.0" encoding="UTF-8"?>'), LEN('<?xml version="1.0" encoding="UTF-8"?>'), '')


l_xml = l_xml + l_xml_arve

TEXT TO l_xml TEXTMERGE NOSHOW additive

</erp:EInvoiceRequest>
</soapenv:Body>
</soapenv:Envelope>
ENDTEXT

	Return l_xml
ENDFUNC

