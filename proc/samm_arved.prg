Parameter tnLepingId, tdKpv, tnPreliminary
Local l_test

l_test = .F.
If (l_test)
	gcProgNimi = 'EELARVE'
	Create Cursor curkey (versia c(20))
	Insert Into curkey (versia) Values ('EELARVE')

	Set Classlib To classes\Classlib
	gVersia = 'PG'
	oDb = Createobject('db')

	gRekv = 1
	guserid = 1
	tnId = 0

	gnHandle = SQLConnect('localPg', 'vlad','123')
	gnHandleAsync = gnHandle

	If gnHandle < 0
		Messagebox('Connection error',0+48,'Error')
		Return .T.
	Endif
	tdKpv = Date()
	tnLepingId = 297264

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
*	ldArvKpv = Gomonth(Date(Year(Date()),Month(Date()),1),1)-1
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
		Set Procedure To Proc\getdokpropId Additive
		nId = getdokpropId('ARV', 'libs\libraries\dokprops')


		If !Used ('V_DOKPROP')
			tnId = nId
			lError = oDb.readFromModel('libs\libraries\dokprops', 'row', 'tnId, guserid', 'v_dokprop')
		Endif
	Endif

	lnStep = 1
	Do While lnStep>0
		If  .Not. Empty(tnLepingId)
			Insert Into curResult (Id, lePingud) Values (tnLepingId, 1)
			If !Used('v_leping2')
				lError = oDb.readFromModel('raamatupidamine\leping', 'row', 'tnLepingId, guserid', 'v_leping1')
				lError = oDb.readFromModel('raamatupidamine\leping', 'details', 'tnLepingId, guserid', 'v_leping2')
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
			lError = saVe_arve()
			If Empty(lError)
				Exit
			Endif
		Endif
		If !Empty(tnPreliminary) And v_arv.Summa > 0
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
	If Empty(tnPreliminary)
		lnMaxDay = Day(Gomonth(Date(Year(Date()),Month(Date()),1),1)-1)
		Select v_arv
		If !Empty(v_leping1.doklausid)
			lnPaev = Iif( lnMaxDay < v_leping1.doklausid, lnMaxDay, v_leping1.doklausid)
		Else
			lnPaev = 15
		Endif
		If Empty(v_leping1.doklausid) Or v_leping1.doklausid >= 30
			lnPaev = lnMaxDay
		Endif

		ldKpv = Date(Year(Date()), Month(Date()), lnPaev)
		If Date() > ldKpv
			ldKpv = Gomonth(ldKpv,1)
		Endif
		lnDokPropId = v_dokprop.Id
		ldKpv = ldArvKpv + Iif(!Used('v_config_') Or Empty(v_config_.tahtpaev),lnPaev,v_config_.tahtpaev)

	Endif

	lcObjekt = ''
	If !Empty(v_leping1.objektid)

		If !Used('comObjektRemote')
			lError = oDb.readFromModel('libs\libraries\objekt', 'selectAsLibs', 'gRekv, guserid', 'comObjektRemote')

		Endif


		Select comObjektRemote
		Locate For Id = v_leping1.objektid
		lcObjekt = comObjektRemote.koOd
	Endif
*SET STEP ON
*!*		If !Used('v_config_')
*!*			tnUserId = 0
*!*			oDb.Use('v_config_')
*!*		Endif

	Select v_arv
	If Reccount('v_arv') = 0
		Append Blank
	Endif


	Replace v_arv.doklausid With lnDokPropId,;
		kpv With ldArvKpv,;
		asutusId With v_leping1.asutusId,;
		liSa With v_leping1.number,;		
		taHtaeg With ldKpv,;
		objekt With lcObjekt,;
		muud With v_leping1.selgitus In v_arv

*!*		Insert Into v_arv (reKvid, Userid, doklausid, Number, kpv, asutusId, liSa, taHtaeg, objekt, muud) Values ;
*!*			(gRekv, guserid, lnDokPropId, Alltrim(Str(lnDok)), ldArvKpv, v_leping1.asutusId, ;
*!*			IIF(Upper(gcProgNimi) = 'ARVELDUSED.EXE','Viitenumber:'+fncViitenumber(Iif(v_config_.toolbar3 = 1,v_leping1.Id,0),;
*!*			IIF(v_config_.toolbar3=2,v_leping1.asutusId,0),0),v_leping1.Number), ldKpv, lcObjekt,v_leping1.selgitus )

*		SET STEP ON

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

			Replace kogus With kogus * lnKoef,;
				v_arvread.kbmta With hind * kogus,;
				v_arvread.kbm With (v_arvread.kbmta - v_arvread.soodus) * v_arvread.kbmaar,;
				v_arvread.Summa With (v_arvread.kbmta - v_arvread.soodus) + v_arvread.kbm In v_arvread
		Endscan
	Endif


	Sum (v_arvread.kbmta-v_arvread.soodus) To lnKbmta
	Sum kbm To lnKbm
	Sum Summa To lnSumma
	Replace v_arv.kbmta With frOund(lnKbmta), v_arv.kbm With frOund(lnKbm),  ;
		v_arv.Summa With frOund(lnSumma), jaAk With frOund(lnSumma) In v_arv
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

			Select v_arv
			lcJson = '{"id":' + Alltrim(Str(Id)) + ',"data": '+ oDb.getJson(lcJson) + '}'
			lError = oDb.readFromModel('raamatupidamine\arv', 'saveDoc', 'lcJson,gUserid,gRekv', 'v_arv')

			If !lError
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

	If !Used('v_leping2')
		lError = oDb.readFromModel('raamatupidamine\leping', 'row', 'tnLepingId, guserid', 'v_leping1')
		lError = oDb.readFromModel('raamatupidamine\leping', 'details', 'tnLepingId, guserid', 'v_leping2')
	Endif


	Select v_leping2
	If Used('qryLeping2')
		Use In qryLeping2
	Endif

	Set Procedure To Proc\frOund Additive
	Set Procedure To Proc\viimane_paev Additive

	Set Classlib To classes\Classlib Additive
	oFormula = Createobj('classlib.formula')

	With oFormula
		.Requery()
		.kpv = ldArvKpv
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
				lnKogus = v_leping2.kogus
				lnHind = v_leping2.hind
				.puhasta()
				lnAlg = 0
				lnLopp = 0

				If Empty(.objektid) And !Empty(v_leping1.objektid)
					.objektid = comObjektRemote.Id
				Endif
				.lepingid = v_leping1.Id
				.arvId = 0

				.hind = lnHind
				.kogus = lnKogus
				.valuuta = 'EUR'
				.kuurs = 1
				.asutusId = 0
				.kpv = v_arv.kpv
				If !Isnull(v_leping2.foRmula) And !Empty(v_leping2.foRmula)

					lcFormulaTais = Alltrim(v_leping2.foRmula)
					lcFormulaKogus = ''
					lcFormulaHind = ''
					lnKogusFormula = Atc('KOGUS:', Upper(Alltrim(v_leping2.foRmula)))
					lnHindFormula = Atc('HIND:', Upper(Alltrim(v_leping2.foRmula)))
					If lnKogusFormula > 0 Or lnHindFormula > 0
						If lnKogusFormula > lnHindFormula
							lnAlg = lnHindFormula
							lnLopp = lnKogusFormula
							lcFormulaKogus = Alltrim(Substr(lcFormulaTais,lnLopp+6))
							lcFormulaHind = Alltrim(Substr(lcFormulaTais,lnAlg+5,lnLopp-lnAlg - 5))

						Else
							lnAlg = lnKogusFormula
							lnLopp = lnHindFormula
							lcFormulaHind = Alltrim(Substr(lcFormulaTais,lnLopp+5))
							lcFormulaKogus = Alltrim(Substr(lcFormulaTais,lnAlg+6,lnLopp-lnAlg - 6))
						Endif
					Else
						lcFormula = lcFormulaTais
					Endif
*					With Thisform.formULA1
					If lnAlg + lnLopp > 0
* meil on hind ja / voi kogus osad
* esimine loeme hinna osa

						If !Empty(lcFormulaHind)
*								SET STEP ON
							=Kaivitaformula(oFormula,lcFormulaHind)
							.lcHind = .returnvalue
						Else
							.lcHind = '1'
						Endif
* kogus
						If !Empty(lcFormulaKogus)
							=Kaivitaformula(oFormula,lcFormulaKogus)
							.lcKogus = .returnvalue
							If Empty(.lcKogus)
								.lcKogus = '0'
							Endif

						Else
							.lcKogus = '1'
						Endif

						.returnvalue  = .lcHind +'*' + .lcKogus
					Else
						=Kaivitaformula(oFormula,lcFormulaTais)
					Endif

*		Replace Arv With .ReturnValue  In curExpr
					lnHind = 0
*					SET STEP ON
					.hind = lnHind
					.kogus = v_leping2.kogus
					lnHind = Iif(Empty(.hind),1,.hind)
					lnKogus = Iif(Empty(.kogus),1,.kogus)
					lcSelg = .selg

					Do Case
						Case !Empty(.lcHind) And Empty(.lcKogus)
							.hind = Evaluate(.lcHind)
							lnHind = .hind
							.kogus = v_leping2.kogus
							lnKogus = .kogus
						Case !Empty(.lcKogus) And Empty(.lcHind)
							.kogus = Evaluate(.lcKogus)
							.hind = v_leping2.hind
						Case !Empty(.lcKogus) And !Empty(.lcHind)
							.hind = Evaluate(.lcHind)
							.kogus = Evaluate(.lcKogus)
						Otherwise
							.hind = Evaluate(.returnvalue)

							.kogus = 1
							lnSumma = .hind *.kogus
					Endcase
					If !Empty(.returnvalue)
						lnHind = .hind
						lnKogus = .kogus
					Endif

*!*						IF RECNO('v_leping2') <> lnrecno
*!*							SELECT v_leping2
*!*							GO lnrecno
*!*						ENDIF

					.nomid = v_leping2.nomid
					If !Isnull(v_leping2.soodus) And !Empty(v_leping2.soodus) And;
							!Empty(v_leping2.soodusalg) And  !Empty(v_leping2.sooduslopp) And;
							ldArvKpv >= v_leping2.soodusalg And ldArvKpv <= v_leping2.sooduslopp
						.soodus = v_leping2.soodus
					Else
						.soodus = 0
					Endif
					lnSumma = lnHind * lnKogus - .soodus
					If Empty(v_leping2.kbm)
* ei siseldab kbm
						.Summa = lnSumma
						.summakokku = 0
					Else
						.Summa = 0
						.summakokku = lnSumma
					Endif
				Else
*puudub formula
					If !Isnull(v_leping2.soodus) And !Empty(v_leping2.soodus) And;
							!Empty(v_leping2.soodusalg) And  !Empty(v_leping2.sooduslopp) And;
							ldArvKpv >= v_leping2.soodusalg And ldArvKpv <= v_leping2.sooduslopp
						.soodus = v_leping2.soodus
					Endif

					If !Empty(v_leping2.Summa)
						lnSumma = Round(v_leping2.Summa ,2)
*							lnSumma = Round(v_leping2.Summa * v_leping2.kuurs,2)
						If Empty(v_leping2.kbm)
* ei siseldab kbm
							.Summa = lnSumma
							.summakokku = 0
						Else
							.Summa = 0
							.summakokku = lnSumma
						Endif
					Else
						lnSumma = (v_leping2.hind - .soodus) * v_leping2.kogus
						If Empty(v_leping2.kbm)
* ei siseldab kbm
							.Summa = lnSumma
							.summakokku = 0
						Else
							.Summa = 0
							.summakokku = lnSumma
						Endif
					Endif

				Endif
				If Empty(.nomid)
					.nomid = v_leping2.nomid
				Endif

				.arvestakbm()
				.arvestakbmsumma()

				Select coMnomremote
				If coMnomremote.Id <> v_leping2.nomid
					Locate For coMnomremote.Id = v_leping2.nomid And coMnomremote.tyyp = 1
				Endif

				.hind = Round(.hind,4)
				.kbmsumma = Round(.kbmsumma,2)
				.Summa = Round(.Summa,2)
				.soodus = Round(.soodus,2)
				.summakokku = Round(.summakokku,2)

				If Empty(lcSelg) And !Empty(v_leping2.muud)
					lcSelg = coNvert_muud (Iif (Isnull(v_leping2.muud),Space(1),v_leping2.muud))
				Endif

				Insert Into v_arvread (nomid, koOd, niMetus, kogus, hind, soodus, kbm, Summa, kbmta, konto, kood1, kood2, kood3,;
					kood5, valuuta, kuurs, Proj, muud, km);
					values (v_leping2.nomid, coMnomremote.koOd, coMnomremote.niMetus, .kogus, .hind,.soodus, .kbmsumma, .summakokku, .Summa, ;
					coMnomremote.konto, coMnomremote.tegev,;
					coMnomremote.allikas, coMnomremote.rahavoog, coMnomremote.artikkel, ;
					'EUR', 1,	 coMnomremote.Proj, lcSelg,coMnomremote.vat)

			Endif

		Endscan
	Endwith
	Select v_arvread
	Sum (v_arvread.kbmta - v_arvread.soodus) To lnKbmta
	Sum kbm To lnKbm
	Sum Summa To lnSumma
	Replace v_arv.kbmta With frOund(lnKbmta),;
		v_arv.kbm With frOund(lnKbm),;
		v_arv.Summa With frOund(lnSumma) In v_arv

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
