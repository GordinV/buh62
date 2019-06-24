Local loXMLHTTP As "MSXML2.XMLHTTP"
Local cUrl, l_found_xml
Local cMessage

check_cursors()

cUrl = Alltrim(config.earved)
*SET STEP ON 

*cMessage = getKontoplanExportRequest()
cMessage = getTunnusExportRequest()

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
*	l_found_xml = parse_response(.responsetext)
*	l_found_xml = Iif(Empty(l_found_xml),0,l_found_xml)

*	Wait Window 'Loen vastus...' + Alltrim(Str(l_found_xml)) + ' libraries' Nowait

Endwith

	SELECT m_memo
	brow

Return l_found_xml

*ENDFUNC

FUNCTION getTunnusExportRequest
TEXT TO c_xml TEXTMERGE noshow
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:erp="http://e-arvetekeskus.eu/erp">
<soapenv:Header/>
<soapenv:Body>
<erp:DimensionRegistryRequest format="AXAPTA" replace="YES" authPhrase="<<ALLTRIM(qryRekv.earved)>>>

ENDTEXT

TEXT TO c_xml ADDITIVE TEXTMERGE noshow

<Dimensioonid>
<Tunnusid>

ENDTEXT

SELECT comTunnusRemote
SCAN

TEXT TO c_xml ADDITIVE TEXTMERGE noshow

<Tunnus>
<Num><<LEFT(ALLTRIM(comTunnusRemote.kood),15)>></Num>
<Description><<LEFT(ALLTRIM(comTunnusRemote.nimetus),70)>></Description>
</Tunnus>

ENDTEXT
ENDSCAN

TEXT TO c_xml ADDITIVE TEXTMERGE noshow

</Tunnusid>
</Dimensioonid>
</erp:DimensionRegistryRequest>
</soapenv:Body>
</soapenv:Envelope>

ENDTEXT
	Return c_xml



ENDFUNC


FUNCTION getKontoplanExportRequest

TEXT TO c_xml TEXTMERGE noshow
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:erp="http://e-arvetekeskus.eu/erp">
<soapenv:Header/>
<soapenv:Body>
<erp:AccountPlanRequest format="AXAPTA" replace="YES" authPhrase="<<ALLTRIM(qryRekv.earved)>>>

ENDTEXT

TEXT TO c_xml ADDITIVE TEXTMERGE noshow

<Kontoplaanid>

ENDTEXT

SELECT comKontodRemote
SCAN

TEXT TO c_xml ADDITIVE TEXTMERGE noshow

<Kontoplaan>
<AccountNum><<LEFT(ALLTRIM(comKontodRemote.kood),15)>></AccountNum>
<AccountName><<LEFT(ALLTRIM(comKontodRemote.nimetus),70)>></AccountName>
</Kontoplaan>

ENDTEXT
ENDSCAN

TEXT TO c_xml ADDITIVE TEXTMERGE noshow

</Kontoplaanid>
</erp:AccountPlanRequest>
</soapenv:Body>
</soapenv:Envelope>

ENDTEXT
	Return c_xml


ENDFUNC

Function check_cursors

	Create Cursor m_memo (url c(120), Header c(120), Request m, response m, Timestamp T Default Datetime())

	If !Used('qryRekv')
		Create Cursor qryRekv (earved c(254), regkood c(20))
		Insert Into qryRekv  (earved, regkood) Values ('106549:elbevswsackajyafdoupavfwewuiafbeeiqatgvyqcqdqxairz','75008427')
	Endif



	If !Used('config')
		Create Cursor config (earved c(254))
		Insert Into config (earved) Values ('https://finance.omniva.eu/finance/erp/')
	ENDIF
	
IF !USED('comkontodRemote')
		Create Cursor comKontodremote (kood c(20), nimetus c(254))
		Insert Into comkontodRemote  (kood, nimetus) Values ('10010001','Arvelduskontod pankades')

ENDIF

IF !USED('comtunnusRemote')
		Create Cursor comtunnusRemote (kood c(20), nimetus c(254))
		Insert Into comtunnusRemote  (kood, nimetus) Values ('EEL','Kohalik eelarve')
ENDIF

	
	

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
		Insert Into comAsutusRemote  (Id, regkood, nimetus,tp) Values (1, '11047855','DATEL VIRU OÜ','800599')
		Insert Into comAsutusRemote  (Id, regkood, nimetus,tp) Values (2, '10972649','test','800599')
	Endif

	If !Used('comNomRemote')
		Create Cursor comNomRemote (Id Int, kood c(20), nimetus c(254))
		Insert Into comNomRemote  (Id, kood, nimetus) Values (1, 'tark','Tarkvara tootmine Põhivara moduule parandamine')
	Endif

Endfunc


