Parameter tcWhere
* TSD 2021 lisa 1
*SET STEP ON
Local lcString, l_parent, l_sm
l_sm = 0


tdKpv1 = fltrAruanne.kpv1
tdKpv2 = fltrAruanne.kpv2
tnKond = Iif(!Empty(fltrAruanne.kond),Null,1)



Create Cursor v_mvt(isikukood c(11), Summa N(14,4), mvt N(14,4), tm N(14,4), tki N(14,4), pm N(14,4), tululiik c(2))
Index On isikukood Tag kood
Set Order To kood

Create Cursor tsd_report (isikukood c(20) null, nimi c(254) null, v1020 c(20) null, v1030 N(14,2) Null , v1040 N(14,2) Null,;
	v1050 c(100) DEFAULT '', v1060 N(14,2) Null , v1070 N(14,2) Null , v1080 N(14,2) Null, v1090 N(14,2) Null , ;
	v1100 N(14,2) Null, v1110 N(14,2) Null ,	v1120 N(14,2) Null , v1130 N(14,2) Null , v1140 N(14,2) Null , ;
	v1150 c(20),	v1160 N(14,2) Null , v1160_610 N(14,2) Null, v1160_620 N(14,2) Null, v1160_630 N(14,2) Null, v1160_640 N(14,2) Null,;
	v1170 N(14,2) Null , v1200 N(14,2) Null , v1210 N(14,2) Null, v1220 N(14,2) Null ,;
	v1230 N(14,2) Null , v1240 N(14,2) Null , v1250 N(14,2) Null, lisa c(10),;
	v1300 c(20) null, v1310 c(254) NULL , v1320 c(20) null, v1330 n(14,2) null, v1340 i null, v1350 i null, v1360 c(254) null,;
	v1370 n(14,2) null, v1380 n(14,2) null, v1390 n(14,2) null, v1400 n(14,2) NULL, v1410 n(14,2) null, v1420 n(14,2) null,;
	v1430 n(14,2) null, v1440 n(14,2) null, v1450 n(14,2) null, v1460 c(20) null, v1470 n(14,2) null, v1480 n(14,2) null,;
	v1500 n(14,2) null, v1510 n(14,2) null, v1520 n(14,2) null, v1530 n(14,2) NULL, v1540 n(14,2) null, v1550 n(14,2) null )
	

TEXT TO lcWhere TEXTMERGE noshow
		isikukood is not null
ENDTEXT

IF !EMPTY(fltrAruanne.asutusid)
	SELECT comTootajadLeping
	LOCATE FOR id = fltrAruanne.asutusid
	IF FOUND()
		TEXT TO lcWhere TEXTMERGE NOSHOW additive
				and isikukood = '<<ALLTRIM(comTootajadLeping.isikukood)>>'
		ENDTEXT
		
	ENDIF
ENDIF

	
lError = oDb.readFromModel('aruanned\palk\tsd_lisa1', 'tsd_lisa1', 'tdKpv1,tdKpv2, gRekv,tnKond', 'tmpReport',lcWhere)
If !lError
	Messagebox('Viga',0+16, 'TSD')
	Set Step On
	Select 0
	Return .F.
ENDIF

Select isikukood, isik, Sum(Summa) As Summa, Sum(puhkused) As puhkused, Sum(haigused) As haigused, Sum(tm) As tm, Sum(sm) As sm, Sum(tki) As tki, Sum(tka) As tka,;
	sum(pm) As pm, Sum(tulubaas) As tulubaas, tululiik, '' as riik, sm_arv, tk_arv, ;
	max(v1040) As v1040, Sum(puhkus) As puhkus, Max(lopp) As lopp, Max(tmpReport.arv_min_sots) As arv_min_sots, ;
	max(tmpReport.min_sots_alus) As min_sots_alus;
	FROM tmpReport ;
	WHERE (!Isnull(tmpReport.tululiik) And  tmpReport.tululiik <> '') ;
	GROUP By isikukood, isik, tululiik, riik, sm_arv, tk_arv ;
	INTO Cursor curTSD_

SELECT * from curTsd_ ORDER By isikukood, tululiik, summa DESC INTO CURSOR curTSD
USE IN curTsd_
		

* calender days
lnPaevadKuus = Day(Gomonth(Date(Year(tdKpv2), Month(tdKpv2), 1)  ,1) - 1)


l_last_isikukood = ''

Select curTSD

Scan
* 1090


	If l_last_isikukood <> curTSD.isikukood
		l_last_isikukood = curTSD.isikukood
		l_used_1090 = .F.
		l_used_mvt = .F.

	Endif

	l_sm = curTSD.sm 
	
	Select Sum(tmpReport.sm) As sm, Max(minsots)As minsots, Max(minpalk) As minpalk, Sum(tmpReport.Summa) As Summa, ;
		sum((tmpReport.Summa - tmpReport.puhkused - tmpReport.haigused) * tmpReport.sm_arv) As sm_alus_summa, Max(lopp) As lopp ;
		From tmpReport ;
		Where isikukood = curTSD.isikukood ;
		 Into Cursor tmpMaksud


	l_1090 = 0
	
	If !Isnull(curTSD.arv_min_sots) AND !EMPTY(curTSD.arv_min_sots) And l_used_1090 = .F. ;
		and Alltrim(curTSD.tululiik) <> ('17') ;
		and Alltrim(curTSD.tululiik) <> ('16') ;
		and Alltrim(curTSD.tululiik) <> ('24') ;
		and Alltrim(curTSD.tululiik) <> ('55') 
	
		l_1090 = curTSD.min_sots_alus
		* kui sm vaiksem kui sots maks min palgast, siis kasutame min.sots
*!*			IF curTSD.sm < curTSD.arv_min_sots  AND curTSD.sm > 0 
*!*				* vana
*!*				l_sm = curTSD.arv_min_sots

*!*			ELSE
*!*				* uus lisa SM
*!*				l_sm = curTSD.sm + curTSD.arv_min_sots
*!*			ENDIF
			* uus lisa SM
		l_sm = curTSD.sm + curTSD.arv_min_sots
		
		
		l_used_1090 = .T.
	Endif

* Veerg 1040 täidetakse ainult koodidega 10, 11, 12 ja 13 väljamakse juuhul. Meie struktuuris kasutatakse enamasti 10 kood. Väljamaksetel koodidega 16, 17, 24, 33 jne veerg 1040 ei täideta. Näiteks Narva Kultuurimaja Rugodiv Turaeva Liudmila ik 47001043728 – kaks väljamakse koodi 10 ja 24. Mõlemal koodil on täidetud veerg 1040.
	ln_tululiik = Val(Alltrim(curTSD.tululiik))

	l_v1040 = Iif(curTSD.v1040 > 1, 1, Round(curTSD.v1040,2))
	If ln_tululiik > 13
*			curTSD.v1040 = 0
		l_v1040 = 0
	Endif


	l_mvt = 0
* mvt
	lcAlias = Alias()
	If  l_used_mvt = .F.
		l_mvt = calcMVT(curTSD.isikukood)
		l_used_mvt  = .T.
	Endif

	Select v_mvt
	Locate For Alltrim(isikukood) =  Alltrim(curTSD.isikukood) And Alltrim(tululiik) = Alltrim(curTSD.tululiik)
	l_mvt = v_mvt.mvt
	l_tm = v_mvt.tm

	Select (lcAlias)


* 1200, 1210, 1220
	Select Sum((curTSD.Summa) *  curTSD.sm_arv) As Summa, Sum(tmpReport.sm) As sm, Sum(tmpReport.tm) As tm, Sum(tmpReport.tki) As tki, ;
		sum(tmpReport.tka) As tka, Sum(tmpReport.pm) As pm ;
		FROM tmpReport ;
		Where tmpReport.liik = 1 And isikukood = curTSD.isikukood Into Cursor tmpMaksud

	Insert Into tsd_report (isikukood, nimi, v1020, v1030, v1040, v1050, ;
		v1060, v1070, v1080, v1090, ;
		v1100, v1110, v1120, v1130, v1140, ;
		v1150, v1160, v1160_610, v1160_620, v1160_630,v1160_640,	;
		v1170 , lisa ) ;
		values (curTSD.isikukood, curTSD.isik, curTSD.tululiik, (curTSD.Summa) , l_v1040, '',;
		(curTSD.Summa) * curTSD.sm_arv, 0,0, l_1090,;
		(l_sm ), curTSD.pm,(curTSD.Summa) * curTSD.tk_arv,curTSD.tki, curTSD.tka, ;
		'610', l_mvt, l_mvt,0,0,0, ;
		l_tm, '1a')

Endscan

* koormus mitte rohkem kui 1
Update tsd_report Set v1040 = 1 Where v1040 > 1

* lisame isikud, kellel arvestused puuduvad, aga koormus on
Select * From tmpReport Where isikukood Not In ;
	(Select Distinct isikukood From tsd_report ;
	WHERE (!Empty(v1040) Or ;
	v1020 In ('10','17'))) ;
	INTO Cursor qryKoormusLisa

Select qryKoormusLisa
Scan
	Insert Into tsd_report (isikukood, nimi, v1020, v1040, v1090, v1100, lisa) ;
		VALUES (qryKoormusLisa.isikukood,  qryKoormusLisa.isik,'10',qryKoormusLisa.v1040, qryKoormusLisa.min_sots_alus,qryKoormusLisa.arv_min_sots, '1a' )
Endscan


If Used('tmpReport')
	Use In tmpReport
Endif

If Used('qryKoormusLisa')
	Use In qryKoormusLisa
Endif


* Lisa 1b 

TEXT TO lcWhere TEXTMERGE noshow
		c_1300 is not null
ENDTEXT

IF !EMPTY(fltrAruanne.asutusid)
TEXT TO lcWhere TEXTMERGE NOSHOW 
		c_1300 = '<<ALLTRIM(comTootajadLeping.isikukood)>>'
ENDTEXT
ENDIF


lError = oDb.readFromModel('aruanned\palk\tsd_lisa1b', 'tsd_lisa1b', 'tdKpv1,tdKpv2, gRekv,tnKond', 'tsd_1b_report', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'TSD')
	Set Step On
	Select 0
	Return .F.
Endif

SELECT tsd_1b_report

SCAN
	Insert Into tsd_report (v1300, v1310, v1320, v1330, v1340,; 
		v1350, v1360, v1370, v1380, v1390,;
		 v1400, v1410, v1420, v1430, v1440,;
		 v1450, v1460, v1470, v1480,;
		 v1500, v1510, v1520,v1530, v1540, v1550,;  
		 lisa) ;
		VALUES (tsd_1b_report.c_1300, tsd_1b_report.c_1310, tsd_1b_report.c_1320, tsd_1b_report.c_1330, tsd_1b_report.c_1340,;
		 tsd_1b_report.c_1350, tsd_1b_report.c_1360, tsd_1b_report.c_1370, tsd_1b_report.c_1380, tsd_1b_report.c_1390,;
		tsd_1b_report.c_1400, tsd_1b_report.c_1410, tsd_1b_report.c_1420, tsd_1b_report.c_1430, tsd_1b_report.c_1440,;
        tsd_1b_report.c_1450, tsd_1b_report.c_1460, tsd_1b_report.c_1470, tsd_1b_report.c_1480,;
        tsd_1b_report.c_1500, tsd_1b_report.c_1510, tsd_1b_report.c_1520, tsd_1b_report.c_1530, tsd_1b_report.c_1540, tsd_1b_report.c_1550,;        		 
		  '1b' )
ENDSCAN


select tsd_report 
RETURN 

Function calcMVT
	Lparameters tcIsikukood
	Local l_found_miinus, lMVT, l_miinus_tululiik, l_miinus_mvt
	lMVT = 0
	l_found_miinus = .F.
	l_miinus_tululiik = ''
	l_miinus_mvt = 0

	lcAlias = Alias()
	Select tululiik, Sum(curTSD.Summa) As Summa, Sum(curTSD.tulubaas) As mvt, Sum(curTSD.tm) As tm, Sum(curTSD.pm) As pm, Sum(curTSD.tki) As tki ;
		From curTSD Where curTSD.isikukood = tcIsikukood Group By tululiik Into Cursor tmp
	If Used('tmp') And Reccount('tmp') > 0
		lMVT = tmp.mvt
	Endif

	If Used('v_mvt')
		Select tmp
		Scan
			If (tmp.mvt < 0)
				l_found_miinus = .T.
			Endif

			Insert Into v_mvt (isikukood, Summa, mvt, tm, pm, tki, tululiik) Values (tcIsikukood, tmp.Summa, tmp.mvt, tmp.tm, tmp.pm, tmp.tki, tmp.tululiik)
		Endscan
		If (l_found_miinus)
* parandame
			Do While l_found_miinus
				l_found_miinus = updateMiinusMVT(tcIsikukood)
			Enddo

		Endif

	Endif
	Use In tmp
	Select(lcAlias)
	Return lMVT
Endfunc


Function updateMiinusMVT
	Lparameters tcIsikukood
	If !Used('v_mvt')
		Return .F.
	Endif

	Select tululiik, Summa As Summa,  Min(mvt) As mvt, (tm) As tm, (tki) As tki, (pm) As pm From v_mvt ;
		WHERE Alltrim(isikukood) = Alltrim(tcIsikukood) And mvt < 0 Group By tululiik, tm, Summa, tki, pm Into Cursor t_mvt_min

	Select tululiik, (Summa) As Summa, (pm) As pm, (tki) As tki,  Max(mvt) As mvt, tm From v_mvt ;
		WHERE Alltrim(isikukood) = Alltrim(tcIsikukood) And mvt > 0 Group By tululiik, tm, Summa, tki, pm Into Cursor t_mvt_max
	If Reccount('t_mvt_min') =0 Or Reccount('t_mvt_max') = 0
		Return .F.
	Endif
* nullime miinus
	l_tm = calc_tm(t_mvt_min.Summa, 0, t_mvt_min.tki, t_mvt_min.pm)

	Update v_mvt Set mvt = 0, tm = l_tm Where Alltrim(isikukood) = Alltrim(tcIsikukood) And Alltrim(tululiik) = Alltrim(t_mvt_min.tululiik)
* parandame pluus
* arvestame tm
	l_tm = calc_tm(t_mvt_max.Summa, (t_mvt_max.mvt + t_mvt_min.mvt), t_mvt_max.tki, t_mvt_max.pm)
	Update v_mvt Set mvt = (t_mvt_max.mvt + t_mvt_min.mvt), tm = l_tm Where Alltrim(isikukood) = Alltrim(tcIsikukood) And Alltrim(tululiik) = Alltrim(t_mvt_max.tululiik)

	Use In t_mvt_max
	Use In t_mvt_min
	Select 	v_mvt
	Return .T.

Endfunc


Function calc_tm
	Lparameters tnSumma, tnMvt, tnTki, tnPm
	Local l_tm
	l_tm = 0

	l_tm = Round((tnSumma - tnMvt - tnTki - tnPm) * 0.20,2)
	Return l_tm
Endfunc
