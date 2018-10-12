PARAMETER tcProc, tnLineno, lcError, lcMessage, lcCode
LOCAL lcAlias, lnRecno, lcFile, lnFiles, lcVersia, lnError
SET STEP ON 

lcError = IIF(EMPTY(lcError), STR(ERROR()), lcError)
lcMessage = IIF(EMPTY(lcMessage) or ISNULL(lcmessage), MESSAGE(), lcMessage)
lcCode = IIF(EMPTY(lcCode), MESSAGE(1), lcMessage)
tnLineno = IIF(EMPTY(tnLineno), 0, tnLineno)
lnError = 0
IF EMPTY(tcProc)
	tcProc = ''
ENDIF
IF EMPTY(tnLineno)
	tnLineno = 0
ENDIF
lcAlias = ALIAS()
lcRecno = ALLTRIM(STR(RECNO()))
IF  .NOT. USED('vigad')
	CREATE CURSOR vigad (viGa M)
ENDIF
SELECT vigad
IF RECCOUNT()<1
	APPEND BLANK
ENDIF
If VARTYPE (gcProgNimi)= 'C' and file (gcProgNimi)
	lcFile = gcProgNimi	
else
	lcFile = 'BUH50'
endif
lnFiles = ADIR(apRop, lcFile)
IF lnFiles>0
	lcVersia = lcFile+DTOC(apRop(1,3))+apRop(1,4)
ELSE
	lcVersia = ''
ENDIF
IF VARTYPE(lcError) = 'N'
	lcError = ALLTRIM(STR(lcError))
ENDIF

REPLACE viGa WITH 'ERROR NR.:'+lcError+';'+' MESS:'+lcMessage+';'+ ;
	' CODE:'+lcCode+';'+' PROC:'+tcProc+';'+' LINE:'+STR(tnLineno)+ ;
	';'+' ALIAS:'+lcAlias+' recno: '+lcRecno+';'+' VERSIA:'+lcVersia+ ;
	';'+' KPV:'+TTOC(DATETIME())+';'+CHR(13) IN vigad
IF FILE('buh50viga.log')
	lnFiles = ADIR(apRop, 'buh50viga.log')
	IF lnFiles > 0 AND aProp(1,2)/1024 > 1024
		ERASE buh50viga.log
		COPY MEMO vigad.viGa TO buh50viga.log
	else
		COPY MEMO vigad.viGa TO buh50viga.log ADDITIVE
	ENDIF		
ELSE
	COPY MEMO vigad.viGa TO buh50viga.log
ENDIF
IF  .NOT. EMPTY(lcAlias) .AND. USED(lcAlias)
	SELECT (lcAlias)
ENDIF
IF AT('Viga',lcmessage) > 0
	MESSAGEBOX(lcmessage,0,'Viga')
ENDIF



lnError = AERROR(erR)
IF lnError>0 .AND. erR(1,1)=1526 .AND. gVersia<>'VFP'
	odB.coNnect()
ENDIF
Set console off
ENDPROC
*
