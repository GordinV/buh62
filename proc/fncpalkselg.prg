LPARAMETERS tnLepingId, tnLibId, tdKpv,tcPref
LOCAL lcString, lcTimestamp, lnError
lcTimestamp = left(tcPref+alltrim(str(tnLepingId))+alltrim(str(tnLibId))+alltrim(DTOC(tdKpv,1)),20)
lcString =  "select muud, volg1 as tm, tasun1 as tulubaas, volg2 as sm, volg4 as tki, volg5 as pm, volg6 as tka from tmp_viivis where dateasint(dkpv) = "+DTOC(tdKpv,1) +" and rekvid = "+STR(gRekv)+" and ALLTRIM(timestamp) = '"+lcTimestamp+"'"
lnError = SQLEXEC(gnHandle,lcString,'tmpPalkSelg')
IF lnError > 0 AND USED('tmpPalkSelg')
	RETURN 'tmpPalkSelg'
ENDIF
RETURN ''
 
