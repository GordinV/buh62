Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
ENDIF

Create cursor kontoandmik_report1 (id int, konto c(20), alg_saldo n(12,2), deebet n(12,2), kreedit n(12,2), lopp_saldo n(12,2),;
	db_kokku n(14,2), kr_kokku n(14,2), selg m null,;
	kpv d, nimetus c(120), asutus c(120), dok c(120), korr_konto c(20), ;
	kood1 c(20) null, kood2 c(20) null, kood3 c(20) null, kood4 c(20) null, kood5 c(20) null, tunnus c(20) null, proj c(20) null, ;
	rekv_id int, rekv_nimi c(254))
Index on Konto tag Konto
Set order to Konto

SELECT * from comKontodRemote WHERE kood LIKE ALLTRIM(fltrAruanne.konto) + '%' ORDER BY kood INTO CURSOR qryKontod

IF EMPTY(fltrAruanne.kond)
	TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
		and rekv_id  = <<gRekv>>
	ENDTEXT
	
ENDIF

SELECT qryKontod
SCAN
		lError = oDb.readFromModel('aruanned\raamatupidamine\kontoandmik', 'kontoandmik_report', 'alltrim(qryKontod.kood), fltrAruanne.kpv1,fltrAruanne.kpv2, gRekv, ALLTRIM(fltrAruanne.tunnus)', 'tmpReport')	
		IF !lError
			MESSAGEBOX('Viga',0+16, 'Kontoandmik')
			SET STEP ON 
			exit
		ENDIF	
*!*			SELECT tmpReport
*!*			scan	
		Insert into kontoandmik_report1 (id, konto, nimetus, korr_konto, alg_saldo, deebet, kreedit, lopp_saldo,;
			db_kokku, kr_kokku,;
			kpv, asutus, dok, kood1, kood2, kood3, kood4, kood5, proj, tunnus, rekv_id, rekv_nimi, selg);
			SELECT tmpReport.number, qryKontod.kood, tmpReport.nimetus, tmpReport.konto, tmpReport.alg_saldo,;
				tmpReport.deebet, tmpReport.kreedit, tmpReport.lopp_saldo, ;
				tmpReport.db_kokku, tmpReport.kr_kokku, tmpReport.kpv,;
				tmpReport.asutus, tmpReport.dok, tmpReport.kood1, tmpReport.kood2, tmpReport.kood3,;
				tmpReport.kood4, tmpReport.kood5, tmpReport.proj, tmpReport.tunnus,tmpReport.rekv_id, tmpReport.rekv_nimi, tmpReport.selg;
				FROM tmpReport	;
				order by rekv_id, kpv
*		ENDSCAN
			
ENDSCAN
IF !lError
	SELECT 0
	RETURN .f.
ENDIF

SELECT kontoandmik_report1

