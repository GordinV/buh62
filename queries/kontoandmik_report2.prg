Parameter cWhere
If Isdigit(Alltrim(cWhere))
	cWhere = Val(Alltrim(cWhere))
Endif

l_params  = ''
TEXT TO l_params TEXTMERGE noshow
	<<IIF(!EMPTY(fltrAruanne.konto),'Konto=','')>> <<ALLTRIM(fltrAruanne.konto)>> <<IIF(!EMPTY(fltrAruanne.konto),'%','')>>
ENDTEXT

TEXT TO l_params TEXTMERGE NOSHOW additive
	<<IIF(!EMPTY(fltrAruanne.tunnus),IIF(LEN(l_params)> 0 ,', ','') + 'Tunnus=','')>> <<ALLTRIM(fltrAruanne.tunnus)>> <<IIF(!EMPTY(fltrAruanne.tunnus),'%','')>>
ENDTEXT
TEXT TO l_params TEXTMERGE NOSHOW additive
	<<IIF(!EMPTY(fltrAruanne.proj),IIF(LEN(l_params)> 0 ,', ','') + 'Projekt=','')>> <<ALLTRIM(fltrAruanne.proj)>> <<IIF(!EMPTY(fltrAruanne.proj),'%','')>>
ENDTEXT
TEXT TO l_params TEXTMERGE NOSHOW additive
	<<IIF(!EMPTY(fltrAruanne.uritus),IIF(LEN(l_params)> 0 ,', ','') + 'Üritus=','')>> <<ALLTRIM(fltrAruanne.uritus)>> <<IIF(!EMPTY(fltrAruanne.uritus),'%','')>>
ENDTEXT


If !Used('fltrParametid')
	Create Cursor fltrParametid (params m)
	Append Blank
Endif

Replace fltrParametid.params With l_params In fltrParametid



Create Cursor kontoandmik_report1 (Id Int, konto c(20), alg_saldo N(12,2), deebet N(12,2), kreedit N(12,2), lopp_saldo N(12,2),;
	db_kokku N(14,2), kr_kokku N(14,2), selg m Null,;
	kpv d, nimetus c(120), asutus c(120), dok c(120), korr_konto c(20), ;
	kood1 c(20) Null, kood2 c(20) Null, kood3 c(20) Null, kood4 c(20) Null, kood5 c(20) Null, tunnus c(20) Null, Proj c(20) Null, ;
	rekv_id Int, rekv_nimi c(254))
Index On konto Tag konto
Set Order To konto

If Empty(fltrAruanne.kond)
TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
		and rekv_id  = <<gRekv>>
ENDTEXT

Endif


TEXT TO l_params TEXTMERGE noshow
	{
		"tunnus":"<<ALLTRIM(fltrAruanne.tunnus)>>",
		"konto":"<<ALLTRIM(fltrAruanne.konto)>>",
		"proj":"<<ALLTRIM(fltrAruanne.proj)>>",
		"uritus":"<<ALLTRIM(fltrAruanne.uritus)>>",
		"kond":<<fltrAruanne.kond>>
	}
ENDTEXT

lError = oDb.readFromModel('aruanned\raamatupidamine\kontoandmik', 'kontoandmik_report', 'ALLTRIM(fltrAruanne.konto), fltrAruanne.kpv1,fltrAruanne.kpv2, gRekv, l_params ', 'tmpReport')

If !lError
	Messagebox('Viga',0+16, 'Kontoandmik')
	Set Step On
	Exit
Endif

Insert Into kontoandmik_report1 (Id, konto, nimetus, korr_konto, alg_saldo, deebet, kreedit, lopp_saldo,;
	db_kokku, kr_kokku,;
	kpv, asutus, dok, kood1, kood2, kood3, kood4, kood5, Proj, tunnus, rekv_id, rekv_nimi, selg);
	SELECT tmpReport.Number, tmpReport.konto, tmpReport.nimetus, tmpReport.korr_konto, tmpReport.alg_saldo,;
	tmpReport.deebet, tmpReport.kreedit, tmpReport.lopp_saldo, ;
	tmpReport.db_kokku, tmpReport.kr_kokku, tmpReport.kpv,;
	tmpReport.asutus, tmpReport.dok, tmpReport.kood1, tmpReport.kood2, tmpReport.kood3,;
	tmpReport.kood4, tmpReport.kood5, tmpReport.Proj, tmpReport.tunnus,tmpReport.rekv_id, tmpReport.rekv_nimi, tmpReport.selg;
	FROM tmpReport	;
	order By rekv_id, kpv
	
If !lError
	Select 0
	Return .F.
ENDIF

USE IN tmpReport

Select kontoandmik_report1

