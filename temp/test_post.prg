SET STEP ON 
DRIVELLOC="http://localhost:3000/login"

*!* HTTP REQUEST
LOREQUEST=''
LCHTTP=''
LOREQUEST = CREATEOBJECT('MSXML2.XMLHTTP.6.0')
LOREQUEST.OPEN("POST", DRIVELLOC, .T.)
LOREQUEST.SEND(.NULL.)
DO WHILE LOREQUEST.READYSTATE # 4
	DOEVENTS
ENDDO
LCHTTP = LOREQUEST.RESPONSETEXT
release LOREQUEST
wait window LCHTTP nowait

* <!DOCTYPE html><html><head><link rel="stylesheet" href="/stylesheets/style.css"><script type="text/javascript" src="/vendor/react.development.js"></script><script type="text/javascript" src="/vendor/react-dom.development.js"></script><script type="text/javascript" src="/vendor/browser.min.js"></script></head><body><div id="kasutaja"></div></body><h1>No user</h1><h2><p>?????????No user</p></h2></html>