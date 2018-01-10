
lcModels = 'c:/avpsoft/buh62/models'
lcModel = 'raamatupidamine/arv'
lcExt = '.xml'
lcFile = lcModels + '/' + lcModel + lcExt

*cFile = "c:/avpsoft/buh62/proc/test/sql.xml"

LOCAL lcXML 
*!*	CREATE CURSOR Customer (Name Char(20), QtyOrders Integer)
*!*	INSERT INTO Customer VALUES ("Fabio Vazquez", 1)
*!*	INSERT INTO Customer VALUES ("Another Customer", 0)

*!*	CURSORTOXML("Customer", "lcXML")
*!*	STRTOFILE(lcXML, "output.xml")
*!*	MODIFY FILE ("output.xml")

*XMLTOCURSOR("output.xml",'tmp',512)
lnModel = XMLTOCURSOR(lcFile,'tmp',512)
brow
*lcJson = STUFF(lcJson, 1, 0, CHR(13))
*!*	lcJson = readFromFile(lcFile)
*!*	IF LEN(lcJson) = 0 
*!*		MESSAGEBOX('No file found',0+48,'Error')
*!*		return
*!*	ENDIF

*WAIT WINDOW 'JSON->' + modelObj.sql

FUNCTION readFromFile()
LPARAMETERS tcFile

IF !FILE(tcFile)
	MESSAGEBOX('No file found -> ' + tcFile)
	RETURN ''
ENDIF

RETURN FILETOSTR(tcFile)

ENDFUNC
