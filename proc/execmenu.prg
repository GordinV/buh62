PARAMETERS tnId
LOCAL lError
SELECT curMenuRemote
LOCATE FOR id = tnId
 
IF FOUND() AND !EMPTY(curMenuRemote.proc)
	lError =EXECSCRIPT(curMenuRemote.proc)
ENDIF
RETURN lError