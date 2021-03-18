Parameter tnLepingId, tdKpv, tnPreliminary
Local l_test

If Empty(tdKpv)
	tdKpv = Date()
Endif


* period
TEXT TO l_where NOSHOW textmerge
	aasta = <<YEAR(tdkpv)>>
	and kuu = <<MONTH(tdkpv)>>
ENDTEXT


lError = oDb.readFromModel('ou\aasta', 'selectAsLibs', 'gRekv', 'tmp_period', l_where )
If !lError Or !Used('tmp_period')
	Messagebox('Viga',0+16, 'Period')
	Set Step On
	Return .T.
Endif

If Reccount('tmp_period') > 0 And !Empty(tmp_period.kinni)
	Messagebox('Period on kinni',0+16,'Kontrol')
	Return .F.
Endif

If Used('tmp_period')
	Use In tmp_period
Endif


l_test = .F.
If (l_test)
	gcProgNimi = 'EELARVE'
	Create Cursor curkey (versia c(20))
	Insert Into curkey (versia) Values ('EELARVE')

	Set Classlib To classes\Classlib
	gVersia = 'PG'
	oDb = Createobject('db')

	gRekv = 63
	guserid = 70
	tnId = 0

	gnHandle = SQLConnect('test_server', 'temp','12345')
	gnHandleAsync = gnHandle

	If gnHandle < 0
		Messagebox('Connection error',0+48,'Error')
		Return .T.
	Endif
	tdKpv = Date()
	tnLepingId = 1438054

	If !Used('comAsutusRemote')
		lError = oDb.readFromModel('libs\libraries\asutused', 'selectAsLibs', 'gRekv, guserid', 'comAsutusRemote')

	Endif
	If !Used('comnomRemote')
		lError = oDb.readFromModel('libs\libraries\nomenclature', 'selectAsLibs', 'gRekv, guserid', 'comnomRemote')

	Endif
	If !Used('qryRekv')
		lError = oDb.readFromModel('ou\rekv', 'row', 'gRekv, guserid', 'qryRekv')

	Endif
Endif


If !Empty(tdKpv)
	ldArvKpv = tdKpv
Else
	ldArvKpv = Date()
Endif

Local lnResult

With oDb

	If Empty(tnLepingId)
		tnLepingId = 0
	Endif

	If  .Not. Used('curSource')
		Create Cursor curSource (Id Int, koOd c (20), niMetus c (120))
	Endif
	If  .Not. Used('curValitud')
		Create Cursor curValitud (Id Int, koOd c (20), niMetus c (120))
	Endif
	Create Cursor curResult (Id Int, teEnused N (1), lePingud N (1), objekted N(1))

	Create Cursor curMotteNimekiri (teenus c(20), arverida i, uhis i, objektid i, nomid i, kpv d)

	If Empty(tnPreliminary)
		If Used('v_dokprop')
			Use In v_dokprop
		Endif
		If (l_test)
			nId = 0
		Else
			Set Procedure To Proc\getdokpropId Additive

			nId = getdokpropId('ARV', 'libs\libraries\dokprops')
		Endif

		If !Used ('V_DOKPROP')
			tnId = nId
			lError = oDb.readFromModel('libs\libraries\dokprops', 'row', 'tnId, guserid', 'v_dokprop')
		Endif
	Endif

	lnStep = 1
	Do While lnStep>0
		If  .Not. Empty(tnLepingId)
			Insert Into curResult (Id, lePingud) Values (tnLepingId, 1)

			tnId = tnLepingId
			If !Used('v_leping1') Or Reccount('v_leping1') = 0 Or Empty(v_leping1.Id)
				lError = oDb.readFromModel('raamatupidamine\leping', 'row', 'tnId, guserid', 'v_leping1')
			Endif

			If !Used('v_leping2')
				lError = oDb.readFromModel('raamatupidamine\leping', 'details', 'tnId, guserid', 'v_leping2')
			Endif

			Select v_leping2
			Scan
				Insert Into curResult (Id, teEnused) Values (v_leping2.nomid, 1)
			Endscan
			lnStep = 4
			tnLepingId = 0
			Select curResult
		Endif
		Do Case
			Case lnStep=1
				Do geT_nom_list
			Case lnStep=2
				Do geT_objektide_list

			Case lnStep=3
				Do geT_lepingu_list
			Case lnStep>3
				Do arVutus
		Endcase
	Enddo
	If Used('v_arv')
		Use In v_arv
	Endif
	If Used('v_arvread')
		Use In v_arvread
	Endif
	If Used('curSource')
		Use In curSource
	Endif
	If Used('curvalitud')
		Use In curValitud
	Endif
	If Used('curResult')
		Use In curResult
	Endif
Endwith
Endproc
*
Procedure arVutus
	Local lError
	If !Empty(tnPreliminary)
* koostame pre-arvestus
		Create Cursor prearve_report1 (kpv d, objekt c(20), asutus c(254), koOd c(20), niMetus c(254), hind N(14,2),;
			kogus N(14,4), kbmta N(14,2), kbm N(14,2), Summa N(14,2), muud m, kuurs N(14,4), valuuta c(20))
	Endif

	Select Distinct Id From curResult Where lePingud=1 Into Cursor recalc1
	Select recalc1
	Scan
		lError = edIt_arve(recalc1.Id)

		If lError=.T. And v_arv.Summa > 0 And Empty(tnPreliminary)
			Wait Window 'Salvestan arve number:'+Alltrim(v_arv.Number) Nowait

			lError = saVe_arve(recalc1.Id)
			If Empty(lError)
				Exit
			Endif
		Endif

		If !Empty(lError) And !Empty(tnPreliminary) And v_arv.Summa > 0
			Wait Window 'Salvestan aruanne..' Nowait
			Select comAsutusRemote
			Locate For Id = v_arv.asutusId
			Select v_arvread
			Scan
				Insert Into  prearve_report1 (kpv , objekt, asutus, koOd, niMetus, hind,kogus, kbmta , kbm , Summa , muud) Values ;
					(v_arv.kpv, v_arv.objekt, comAsutusRemote.niMetus,v_arvread.koOd, v_arvread.niMetus,  v_arvread.hind, v_arvread.kogus, ;
					v_arvread.kbmta,v_arvread.kbm, v_arvread.Summa, v_arvread.muud)
			Endscan
		Endif

	Endscan
	If Empty(lError)
		Messagebox('Viga', 'Kontrol')
	Endif
	lnStep = 0
Endproc
*
Function edIt_arve
	Parameter tnId

	ldArvKpv = tdKpv
	Select comAsutusRemote
	Locate For Id = v_leping1.asutusId
	Wait Window 'Arvestan '+Alltrim(comAsutusRemote.niMetus) Nowait

	If  !Isnull(v_leping1.taHtaeg) .And. ;
			(Year(v_leping1.taHtaeg) <> Year(ldArvKpv) .Or. Month(v_leping1.taHtaeg) <> Month(ldArvKpv)) .And. ;
			v_leping1.taHtaeg < ldArvKpv

		Wait Window 'Leping nr.:'+v_leping1.Number + ' vдlja sest lepingu tдhtaeg on lхpetatud' Nowait
		Return .F.
	Endif

	tnId = 0
	lError = oDb.readFromModel('raamatupidamine\arv', 'row', 'tnId, guserid', 'v_arv')
	lError = oDb.readFromModel('raamatupidamine\arv', 'details', 'tnId, guserid', 'v_arvread')
	If !lError Or !Used('v_arv') Or !Used('v_arvread')
		Messagebox('Viga arve laadimisel',0+16,'Error')
		Return .F.
	Endif

	lnDok = 0
	lcNumber = ''
	lnPaev = 1
	ldKpv = Date()
	lnDokPropId = 0

* arvestame tahtpaev
	If Empty(tnPreliminary)
		lnMaxDay = Day(Gomonth(Date(Year(Date()),Month(Date()),1),1)-1)
		Select v_arv
		If !Isnull(v_leping1.doklausid) And !Empty(v_leping1.doklausid)
			lnPaev = Iif( lnMaxDay < v_leping1.doklausid, lnMaxDay, v_leping1.doklausid)
		Else
			lnPaev = 15
		Endif
		If Isnull(v_leping1.doklausid) Or Empty(v_leping1.doklausid) Or v_leping1.doklausid >= 30
			lnPaev = lnMaxDay
		Endif

		ldKpv = Date(Year(Date()), Month(Date()), lnPaev)
		If Date() > ldKpv
			ldKpv = Gomonth(ldKpv,1)
		Endif
		lnDokPropId = v_dokprop.Id
		ldKpv = ldArvKpv + Iif(Isnull(qryRekv.tahtpaev) Or Empty(qryRekv.tahtpaev),lnPaev,qryRekv.tahtpaev)

	Endif

	lcObjekt = ''
	If !Isnull(v_leping1.objektid) And !Empty(v_leping1.objektid)

		If !Used('comObjektRemote')
			lError = oDb.readFromModel('libs\libraries\objekt', 'selectAsLibs', 'gRekv, guserid', 'comObjektRemote')

		Endif


		Select comObjektRemote
		Locate For Id = v_leping1.objektid
		lcObjekt = comObjektRemote.koOd
	Endif

	Select v_arv
	If Reccount('v_arv') = 0
		Append Blank
	Endif


	Replace v_arv.doklausid With lnDokPropId,;
		kpv With ldArvKpv,;
		asutusId With v_leping1.asutusId,;
		liSa With v_leping1.Number,;
		taHtaeg With ldKpv,;
		objekt With lcObjekt In v_arv


	=fnc_addfromleping(v_leping1.Id)

	ldAlgKpv = Date(Year(ldArvKpv),Month(ldArvKpv),1)

	lnKoef = 1
	If 	Not Isnull(v_leping1.taHtaeg) .And. ;
			YEAR(v_leping1.taHtaeg) = Year(ldArvKpv) And  Month(v_leping1.taHtaeg) = Month(ldArvKpv) And;
			v_leping1.taHtaeg < ldArvKpv

		ldArvKpv = v_leping1.taHtaeg
	Endif
	If Day(ldAlgKpv) > 1 Or Day(ldArvKpv) < viimane_paev(Year(ldArvKpv),Month(ldArvKpv))
		lnKoef = (Day(ldArvKpv) - Day(ldAlgKpv)) / 	viimane_paev(Year(ldArvKpv),Month(ldArvKpv))
	Endif
	ldLKpv1 = v_leping1.kpv
	ldLKpv2 = Iif(Isnull(v_leping1.taHtaeg) Or Empty(v_leping1.taHtaeg),Gomonth(ldArvKpv,12),v_leping1.taHtaeg)
	If ldArvKpv > ldLKpv1 And ldArvKpv < ldLKpv2
		lnKoef = 1
	Endif


*	Do queries\add_from_leping

	Select v_arvread
	Delete From v_arvread Where nomid Not In (Select Id From curResult Where teEnused = 1) Or Summa = 0
	If lnKoef < 1
		Scan
			lnVat = Iif(!ISNULL(v_arvread.km) and Isdigit(v_arvread.km),Val(v_arvread.km),0) / 100
			Replace kogus With kogus * lnKoef,;
				v_arvread.kbmta With hind * kogus,;
				v_arvread.kbm With (v_arvread.kbmta - v_arvread.soodus) * lnVat,;
				v_arvread.Summa With (v_arvread.kbmta - v_arvread.soodus) + v_arvread.kbm In v_arvread
		Endscan
	Endif


	Sum (v_arvread.kbmta-v_arvread.soodus) To lnKbmta
	Sum kbm To lnKbm
	Sum Summa To lnSumma
	Replace v_arv.kbmta With lnKbmta, v_arv.kbm With lnKbm,  ;
		v_arv.Summa With lnSumma, jaAk With lnSumma In v_arv

	If Reccount('v_arvread') > 0
		Return .T.
	Else
		Return .F.
	Endif

Endfunc
*
Function coNvert_muud
	Parameter tcString
	Local cuUsvar, lnKogus, lnHind, llKogus, lcUhik
	cuUsvar = ''
	lcUhik = ''
	lnHind = v_leping2.hind
	llKogus = v_leping2.kogus
	Select coMnomremote
	Locate For Id=v_leping2.nomid
	If Found()
		lcUhik = coMnomremote.uhIk
	Endif
	If Len(tcString)>1
		nkOgus = Occurs('?', tcString)
		For i = 1 To nkOgus
			lnStart = Atc('?', tcString, 1)
			If lnStart>0
				lnKogus = 4
				cvAr = Substr(tcString, lnStart+1, lnKogus)
				Do Case
					Case Upper(Left(cvAr, 3))='KUU'
						cuUsvar = Ltrim(Rtrim(Str(Month(ldArvKpv), 2)+'/'+ ;
							STR(Year(ldArvKpv), 4)+' a.'))
						lnKogus = 4
					Case Upper(Left(cvAr, 4))='HIND'
						cuUsvar = Ltrim(Rtrim(Str(lnHind, 12, 2)))
						lnKogus = 5
					Case Upper(Left(cvAr, 4))='KOGU'
						cuUsvar = Ltrim(Rtrim(Str(llKogus, 12, 3)))
						lnKogus = 6
					Case Upper(Left(cvAr, 4))='SUMM'
						cuUsvar = Ltrim(Rtrim(Str(lnSumma, 12, 2)))
						lnKogus = 6
					Case Upper(Left(cvAr, 4))='UHIK'
						cuUsvar = Rtrim(lcUhik)
						lnKogus = 5
					Case Upper(Left(cvAr, 4))='FORM'
						cuUsvar = reAdformula(v_leping2.foRmula, ;
							queryLeping.Id,1)
						lnKogus = 7
				Endcase
				If  .Not. Empty(cvAr)
					If Empty(cuUsvar)
						cuUsvar = ''
					Endif
					tcString = Stuff(tcString, lnStart, lnKogus, cuUsvar)
				Endif
			Endif
		Endfor
	Endif
	Return tcString
Endfunc
*
Function saVe_arve
	Lparameters l_leping_id
	Local lError
	lError = .T.


	Select v_arv

	If v_arv.Summa > 0

		With oDb
			Wait Window 'Salvestan arve nr.:'+Alltrim(v_arv.Number) Nowait
* 'raamatupidamine\arv'

			Select v_arvread
			Go Top
			lcJson = '"gridData":['+ oDb.getJson() + ']'

			Select v_leping1.Id As leping_id, * From v_arv Into Cursor qryArv
			Select  qryArv
			lcJson = '{"id":' + Alltrim(Str(Id)) + ',"data": '+ oDb.getJson(lcJson) + '}'
			lError = oDb.readFromModel('raamatupidamine\arv', 'saveDoc', 'lcJson,gUserid,gRekv', 'v_arv')

			If !lError Or !Used('v_arv') Or Empty(v_arv.Id)
				Messagebox('Viga arve salvestamisel',0+16,'Error')
				Return .F.
			Endif

			Wait Window 'Salvestan arve nr.:'+Alltrim(v_arv.Number) + '..salvestatud ' Nowait
			If  Used('v_dokprop') And v_dokprop.registr > 0
				Wait Window 'Konteerimine arve nr.:'+Alltrim(v_arv.Number) Nowait
				tnId = v_arv.Id

				lError = oDb.readFromModel('raamatupidamine\arv', 'generateJournal', 'guserid, tnId', 'qryArvLausend')

				If !lError
					Messagebox('Viga arve konteerimisel',0+16,'Error')
					Return .F.
				Endif

			Endif
			If lError
				Wait Window 'Arve nr.:'+Alltrim(v_arv.Number) +' salvestatud' Nowait
			Endif

		Endwith
	Endif

	Return lError
Endfunc

Procedure geT_nom_list
	If Used('query1')
		Use In query1
	Endif

TEXT TO lcWhere TEXTMERGE noshow
		id IN (
		  SELECT l2.nomid
		  FROM docs.leping2 l2
		    INNER JOIN docs.leping1 l1 ON l1.id = l2.parentid
		  WHERE l1.rekvid = <<gRekv>>
		  and l2.status = 1
ENDTEXT

	lError = oDb.readFromModel('libs\libraries\nomenclature', 'selectAsLibs', 'gRekv, guserid', 'qryNoms', lcWhere)

	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Select Distinct qryNoms.koOd, qryNoms.niMetus, qryNoms.Id From  qryNoms Order By Nomenklatuur.koOd Into Cursor qrySelectedNoms
	Use In qryNoms

	Append From Dbf('qrySelectedNoms')
	Use In qrySelectedNoms

	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	If Empty(ldArvKpv)
		ldArvKpv = Date()
	Endif
	Do Form Forms\samm  To nrEsult With '1', Iif(coNfig.keEl=2, 'Teenused',  ;
		'Услуги'), Iif(coNfig.keEl=2, 'Valitud teenused', 'Выбранные услуги'), ldArvKpv
	If nrEsult=1
		ldArvKpv = gdKpv


		Select Distinct Id From curValitud Where  Not Id In(Select Id From  ;
			curResult Where teEnused=1) Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (Id, teEnused) Values (query1.Id, 1)
		Endscan
		Use In query1
		Select curValitud
		Zap
	Endif
	If nrEsult=0
		lnStep = 0
	Else
		lnStep = lnStep+nrEsult
	Endif
Endproc
*
Procedure geT_lepingu_list


	lError = oDb.readFromModel('raamatupidamine\leping', 'wizlepingud', 'gRekv, guserid', 'qryLepingud')

	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Select Distinct koOd, niMetus, Id From qryLepingud ;
		Where nomid In (Select Id From curResult Where curResult.teEnused=1) ;
		AND objektid In (Select Id From curResult Where curResult.objekted=1) ;
		AND taHtaeg > gdKpv;
		Into Cursor query1

	Use In qryLepingud

	Select curSource
	Append From Dbf('query1')
	Use In query1

	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	If Empty(ldArvKpv)
		ldArvKpv = Date()
	Endif

	Do Form Forms\samm To nrEsult With '2', Iif(coNfig.keEl=2, 'Lepingud',  ;
		'Договора'), Iif(coNfig.keEl=2, 'Valitud lepingud', 'Выбранные договора') , ldArvKpv
	If nrEsult=1
		If !Empty(gdKpv)
			ldArvKpv = gdKpv
		Endif

		Select Distinct Id From curValitud Where  Not Id In(Select Id From  ;
			curResult Where lePingud=1) Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (Id, lePingud) Values (query1.Id, 1)
		Endscan
		Use In query1
	Endif
	If nrEsult=0
		lnStep = 0
	Else
		lnStep = lnStep+nrEsult
	Endif
	Return
Endproc
*

Function fnc_addfromleping
	Lparameters tnId
	Local oFormula
	lnKSumma = 	0
	lnKSummaKbm = 0
	lnKSummaKokku = 0
	tnId = tnLepingId
	If !Used('v_leping2')
		lError = oDb.readFromModel('raamatupidamine\leping', 'row', 'tnId, guserid', 'v_leping1')
		lError = oDb.readFromModel('raamatupidamine\leping', 'details', 'tnId, guserid', 'v_leping2')
	Endif


	Select v_leping2
	If Used('qryLeping2')
		Use In qryLeping2
	Endif

	Set Procedure To Proc\frOund Additive
	Set Procedure To Proc\viimane_paev Additive

	Select v_leping2
	lnrecno = Recno()
	Scan For v_leping2.Status = 1
		Select curResult
		Locate For Id = v_leping2.nomid And teEnused = 1
		If Found()
			Wait Window 'Arvestan leping nr.:'+Alltrim(v_leping1.Number)+Alltrim(Str(Recno('v_leping2')))+'/'+Alltrim(Str(Reccount('v_leping2'))) Nowait

			lnKogus = 0
			lnSumma = 0
			lnSummaKokku = 0
			lcSelg = ''
			lnSoodus = 0
			lnKbm = 0
			lnKogus = Iif(Empty(v_leping2.kogus),1,v_leping2.kogus)
			lnHind = Iif(Empty(v_leping2.hind),1,v_leping2.hind)
			lnAlg = 0
			lnLopp = 0
			l_kbm_maar = 0.20 * Iif (Empty (qryRekv.kbmkood),0,1)
			lnSumma  = lnHind * lnKogus

* soodus
			If !Isnull(v_leping2.soodus) And !Empty(v_leping2.soodus) And;
					!Empty(v_leping2.soodusalg) And  !Empty(v_leping2.sooduslopp) And;
					ldArvKpv >= v_leping2.soodusalg And ldArvKpv <= v_leping2.sooduslopp
				lnSoodus = v_leping2.soodus
				lnSumma = (lnHind - lnSoodus ) * lnKogus
			Else
				lnSoodus = 0
			Endif
			lnSummaKokku = lnSumma

			If !Isnull(v_leping2.kbm) And !Empty(v_leping2.kbm)
* ei siseldab kbm
				lnKbm = l_kbm_maar * lnSumma
				lnSummaKokku = lnSumma + lnKbm

			Else
				lnSumma = lnSummaKokku / (1 + l_kbm_maar)
				lnKbm = lnSummaKokku - lnSumma

			ENDIF
		Endif
		Select coMnomremote
		Locate For Id = v_leping2.nomid
		IF FOUND() AND (ISNULL(coMnomremote.vat) OR EMPTY(coMnomremote.vat) OR coMnomremote.vat = '.NULL.')
			* remove kbm summa because rate is 0 
			lnSummaKokku  = lnSumma
			lnKbm = 0
		ENDIF
		
		Select comAsutusRemote
		Locate For Id = v_leping1.asutusId

		Insert Into v_arvread (nomid, hind, kogus, Summa, soodus, kbm, kood1, kood2, kood3, kood5, konto, tp);
			values (v_leping2.nomid, lnHind, lnKogus, lnSumma, lnSoodus, lnKbm, coMnomremote.tegev,coMnomremote.allikas, coMnomremote.rahavoog,;
			coMnomremote.artikkel, coMnomremote.konto, comAsutusRemote.tp )
	Endscan
	Select v_arvread
	Sum (v_arvread.kbmta - v_arvread.soodus) To lnKbmta
	Sum kbm To lnKbm
	Sum Summa To lnSumma
	Replace v_arv.kbmta With lnKbmta,;
		v_arv.kbm With lnKbm,;
		v_arv.Summa With lnSumma In v_arv

Endfunc


Function coNvert_muud
	Parameter tcString
	Local cuUsvar, lnKogus, cvAr
	Private lnKogus, lnSumma, lnHind
	cvAr = ''
	lnKogus = 0
	cuUsvar = ''
	lnKogus = 0
	lnHind = v_arvread.hind
	llKogus = v_arvread.kogus
	lnSumma = v_arvread.Summa
	lcUhik = Rtrim(v_arvread.uhIk)

	If Len(tcString) > 1
		nkOgus = Occurs('?',tcString)
		For i = 1 To nkOgus
			lnStart = Atc('?',tcString, 1)
			If lnStart > 0
				lnKogus = 4
				cvAr = Substr (tcString,lnStart+1,lnKogus)
				Do Case
					Case Upper(Left (cvAr,3)) = 'KUU'
						cuUsvar = Str(Month(ldArvKpv),2)+'/'+Str(Year(ldArvKpv),4)+' a.'
						lnKogus = 4
					Case Upper(Left (cvAr,4)) = 'HIND'
						cuUsvar = Str (lnHind,12,2)
						lnKogus = 5
					Case Upper(Left (cvAr,4)) = 'KOGU'
						cuUsvar = Str (llKogus,12,3)
						lnKogus = 6
					Case Upper(Left (cvAr,4)) = 'SUMM'
						cuUsvar = Str (lnSumma,12,2)
						lnKogus = 6
					Case Upper(Left (cvAr,4)) = 'UHIK'
						cuUsvar = Rtrim(lcUhik)
						lnKogus = 5
					Case Upper(Left (cvAr,4)) = 'FORM'
						cuUsvar = reAdformula(queryLeping.foRmula, queryLeping.Id,1)
						lnKogus = 7
				Endcase
				If !Empty (cvAr)
					If Empty (cuUsvar)
						cuUsvar = ''
					Endif
					tcString = Stuff (tcString, lnStart, lnKogus, cuUsvar)
				Endif

			Endif
		Endfor
	Endif
	Return tcString

Procedure geT_objektide_list
	If Used('query1')
		Use In query1
	Endif

TEXT TO lcWhere TEXTMERGE noshow
		id IN (SELECT l1.objektid
             FROM docs.leping1 l1
             where l1.rekvid = <<gRekv>>
             )
ENDTEXT
	lError = oDb.readFromModel('libs\libraries\objekt', 'selectAsLibs', 'gRekv, guserid', 'qryObjects')

	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Append From Dbf('qryObjects')
	Insert Into curSource (koOd, niMetus, Id) Values ('ILMA','Ilma objektita',0)
	Use In qryObjects

	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '2', Iif(coNfig.keEl=2, 'Teenused',  ;
		'Услуги'), Iif(coNfig.keEl=2, 'Valitud teenused', 'Выбранные услуги') , ldArvKpv
	If nrEsult=1

		If !Empty(gdKpv)
			ldArvKpv = gdKpv
		Endif

		Select Distinct Id From curValitud Where  Not Id In(Select Id From  ;
			curResult Where objekted=1) Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (Id, objekted) Values (query1.Id, 1)
		Endscan
		Use In query1
		Select curValitud
		Zap
	Endif
	If nrEsult=0
		lnStep = 0
	Else
		lnStep = lnStep+nrEsult
	Endif
Endproc


Function Kaivitaformula
	Lparameters loFormula, lcFormula
	loFormula.foRmula = lcFormula
	nOccurs = Occurs ('?',lcFormula)
	For i = 1 To nOccurs
		With loFormula
			If Empty(.returnvalue)
				.returnvalue = .foRmula
			Endif
			.loemakro()
			.koOd = Substr (.returnvalue,.Start1+1,.Start2 - .Start1)
			Wait Window 'Oodake, arvestan:'+.koOd Nowait
			.nomid = v_leping2.nomid

			Select coMnomremote
			Locate For koOd = .koOd
			If Found() And coMnomremote.Id <> .nomid
				.nomid = coMnomremote.Id
				Select v_leping2
				lnrecno = Recno('v_leping2')
				Locate For v_leping2.nomid = .nomid
				If Found()
					.hind = v_leping2.hind
				Else
					.hind = coMnomremote.hind
				Endif
				Select v_leping2
				Go lnrecno
			Endif

			lcSumma = .loekood()
			tcString = .koodivahetus()
		Endwith
	Endfor
Endfunc
