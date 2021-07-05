Parameter tcWhere

IF !EMPTY(fltrAruanne.arvestus)
	l_answer = MESSAGEBOX('Kas re-arvesta kondsaldoandmik ?',4+32+256,'Pikk tulem')
	IF l_answer = 6
				
		TEXT TO l_params TEXTMERGE NOSHOW 
			{"kpv":"<<DTOC(fltrAruanne.kpv2,1)>>","tyyp":1}
		ENDTEXT
		WAIT WINDOW 'Arvestan ...' nowait
		lError = oDb.readFromModel('aruanned\eelarve\kond_saldoandmik', 'koosta_saldoandmik', 'gUserId,l_params', 'tmpTulemus')
		If !lError
			Messagebox('Viga',0+16, 'Eelarve kondsaldoandmik')
			Set Step On
			Select 0
			Return .F.
		Endif
		WAIT WINDOW 'Arvestan ...tehtud' nowait
	ENDIF
	
ENDIF


l_kpv2 = fltrAruanne.kpv2

lError = oDb.readFromModel('aruanned\eelarve\tulem', 'tulem', 'l_kpv2, gRekv, fltrAruanne.kond', 'bilanss_report1')
If !lError
	Messagebox('Viga',0+16, 'Pikk tulem')
	Set Step On
	Select 0
	Return .F.
Endif

Select bilanss_report1

