Parameter tcWhere

IF !EMPTY(fltrAruanne.arvestus)
	TEXT TO l_params TEXTMERGE NOSHOW 
		{"kpv":"<<DTOC(fltrAruanne.kpv2,1)>>","tyyp":1,"kond":<<fltrAruanne.kond>>,"rekvid":<<gRekv>>}
	ENDTEXT
	WAIT WINDOW 'Re-arvestan ...' nowait
	lError = oDb.readFromModel('aruanned\eelarve\kond_saldoandmik', 'koosta_saldoandmik', 'gUserId,l_params', 'tmpTulemus')
	If !lError
		Messagebox('Viga',0+16, 'Eelarve kondsaldoandmik')
		Set Step On
		Select 0
		Return .F.
	Endif
	WAIT WINDOW 'Arvestan ...tehtud' nowait
ENDIF


TEXT TO lcWhere TEXTMERGE noshow
	coalesce(konto,'') like '<<ALLTRIM(fltrAruanne.konto)>>%'
	and coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.tegev)>>%'
	and coalesce(allikas,'') like '<<ALLTRIM(fltrAruanne.allikas)>>%'
	and coalesce(rahavoog,'') like '<<ALLTRIM(fltrAruanne.rahavoog)>>%'
	and coalesce(tp,'') like '<<ALLTRIM(fltrAruanne.tp)>>%'
	and not EMPTY(deebet + kreedit) 
ENDTEXT

l_subTotals  = ' sum (deebet) OVER()  as dbKokku, sum (kreedit) OVER()  as krKokku '

l_kpv2 = fltrAruanne.kpv2
l_rekv = IIF(fltrAruanne.kond = 1 and gRekv = 63,999, gRekv)

lError = oDb.readFromModel('aruanned\eelarve\kond_saldoandmik', 'kond_saldoandmik_report', 'l_kpv2, l_rekv, fltrAruanne.kond', 'tmpReport', lcWhere,l_subTotals)
If !lError
	Messagebox('Viga',0+16, 'Eelarve kondsaldoandmik')
	Set Step On
	Select 0
	Return .F.
Endif

Select * ;
	from tmpReport ;
	ORDER By konto, tp, tegev, allikas, rahavoog ;
	INTO Cursor saldoaruanne_report1

Use In tmpReport
Select saldoaruanne_report1

