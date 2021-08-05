Parameter tcWhere

IF !EMPTY(fltrAruanne.arvestus)
	l_answer = MESSAGEBOX('Kas re-arvesta kondsaldoandmik ?',4+32+256,'Bilanss')
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

lError = oDb.readFromModel('aruanned\eelarve\pikk_bilanss', 'pikk_bilanss', 'l_kpv2, gRekv, fltrAruanne.kond', 'tmpReport')
If !lError
	Messagebox('Viga',0+16, 'Eelarve kondsaldoandmik')
	Set Step On
	Select 0
	Return .F.
Endif

Select sum(summa) as summa, sum(eelmise_summa) as eelmise_summa, konto, nimetus ;
	from tmpReport ;
	GROUP By konto, nimetus ;	
	ORDER By konto ;
	INTO Cursor bilanss_report1

Use In tmpReport
Select bilanss_report1

