Local  lnResult, lError
lError = .t.
If vartype(odb) <> 'O'
	Set classlib to classes\classlib
	odb = createobject('db')
Endif
If !used('curSource')
	Create cursor curSource (id int, kood c(20), nimetus c(120))
Endif
If !used('curValitud')
	Create cursor curValitud (id int, kood c(20), nimetus c(120))
Endif
Create cursor curResult (Id int, OsakonnaId int, palklibId int)
lnStep = 1
If used ('v_dokprop')
	Use in v_dokprop
Endif
tnId = getdokpropId('PALK')
If !used ('v_dokprop')
	odb.use ('v_dokprop','v_dokprop')
Endif
Do while lnStep > 0
	Do case
		Case lnStep = 1
			Do get_osakonna_list
		Case lnStep = 2
			Do get_isiku_list
		Case lnStep = 3
			Do get_kood_list
		Case lnStep > 3
			Do arvutus
	Endcase
Enddo
If used('curSource')
	Use in curSource
Endif
If used('curvalitud')
	Use in curValitud
Endif
If used('curResult')
	Use in curResult
Endif


Procedure arvutus
	Local lError
	lError = .t.
	With odb
		If !used ('qryTulumaks')
			.use ('qryTulumaks')
		Endif
		Select distinc palklibId from curResult where !empty(curResult.palklibId) into cursor ValPalkLib
		Select distinc id from curResult where !empty(curResult.id) into cursor recalc1
		.opentransaction()
		Select recalc1
		Scan
			Select comAsutusRemote
			Locate for id = recalc1.id
			If found ()
				cNimi = rtrim(comAsutusRemote.nimetus)
			Else
				cNimi = ''
			Endif
			tnId = recalc1.id
			If !used ('v_palk_kaart')
				.use ('v_palk_kaart')
			Else
				.dbreq('v_palk_kaart', gnHandle,'v_palk_kaart')
			Endif
			Select v_palk_kaart
			Update v_palk_kaart set liik = 2 where liik = 7 and asutusest = 0
			Update v_palk_kaart set liik = 2 where liik = 8
			Index on (liik*IIF (v_palk_kaart.liik = 2 and v_palk_kaart.maks = 1,10,1))  tag liik for status = 1
			Set order to liik
			If reccount ('qryTulumaks') > 0
				Select distinc lepingId from v_palk_kaart into cursor qryLep
				Scan
					Select qryTulumaks
					Scan
						Select v_palk_kaart
						Append blank
						Replace libId with qryTulumaks.id,;
							liik with 4,;
							status with 1,;
							lepingId with qryLep.lepingId in v_palk_kaart
					Endscan
				Endscan
			Endif
			Select v_palk_kaart
			Scan  for v_palk_kaart.status = 1
				Select ValPalkLib
				Locate for ValPalkLib.palklibId = v_palk_kaart.libId
				If found ()
					If used ('v_palkjournal')
						Use in v_palkjournal
					Endif
					If used ('v_palkjournal1')
						Use in v_palkjournal1
					Endif
					.use ('v_journal', 'v_palkjournal',gnHandle, .t.)
					.use ('v_journal1', 'v_palkjournal1',gnHandle, .t.)
					lError=edit_oper(recalc1.Id)
					If lError = .t. and v_palk_oper.summa <> 0
						lError=save_oper()
					Endif
					If lError = .t.
						Do queries\recalc_palk_saldo
					Endif
					If lError = .f.
						If config.debug = 1
							Set step on
						Endif
						Exit
					Endif
				Endif
			Endscan

			If lError = .f.
				Exit
			Endif
		Endscan
		If lError = .t.
			.commit()
		Else
			.rollback()
			If config.debug = 1
				Set step on
			Endif
			Messagebox('Viga','Kontrol')
		Endif
		lnStep = 0
	Endwith
Endproc

Function save_lausend
	Local lError
	lError = .t.
*!*	If used ('curKey') and 'EELARVE' $ curkey.versia 
*!*	 	if !lausendKontrol('v_palkjournal1')
*!*			messagebox (iif(config.keel = 1,'������: ������������ ���������� ���������������',;
*!*				'Viga: eba�igus klassifikaatori kombinatsioon'),'Kontrol')
*!*			return .f.
*!*		endif
*!*	endif


	Select v_palkjournal
	If reccount ('v_palkjournal') > 0
		lError = odb.cursorupdate('v_palkjournal', 'v_journal')
		If lError = .t.
			tnId = v_palkjournal.id
			Select v_palkjournal1
			Update v_palkjournal1 set;
				parentId = tnId
			lError = odb.cursorupdate('v_palkjournal1', 'v_journal1')
			If lError = .t.
				Replace v_palk_oper.journalid with v_palkjournal.id in v_palk_oper
				lError = odb.cursorupdate('v_palk_oper', 'v_palk_oper')
			Endif
		Endif
	Endif
	Return lError

Procedure edit_oper
	Parameter tnId
	odb.Use('v_palk_oper','v_palk_oper',.t.)
	tnId = recalc1.id
	tnId = v_palk_kaart.libId
	If empty (gdKpv) or empty (gnKuu) or empty (gnAasta)
		Do form period
	Endif
	If used ('qryPalkLib')
		Use in qryPalkLib
	Endif
	odb.use ('v_palk_lib','qryPalkLib')
	Select v_palk_oper
	Append blank
	Replace rekvId with gRekv,;
		v_palk_oper.lepingId with v_palk_kaart.lepingId,;
		v_palk_oper.libId with v_palk_kaart.libId,;
		v_palk_oper.doklausId with v_dokprop.id,;
		kpv with gdKpv in v_palk_oper
	If v_palk_kaart.liik <> 6
		lError =f_check_twins()
	Endif
	Do case
		Case v_palk_kaart.liik = 1
			If !empty (cNimi)
				Wait window [Arvestan:]+cNimi+space(1)+'arvestused' nowait
			Endif
			Do queries\item_arvestamine
		Case v_palk_kaart.liik = 2
			If !empty (cNimi)
				Wait window [Arvestan:]+cNimi+space(1)+'kinnipidamised' nowait
			Endif
			Do queries\item_kinnipidamine
		Case v_palk_kaart.liik = 20
			If !empty (cNimi)
				Wait window [Arvestan:]+cNimi+space(1)+'kinnipidamised' nowait
			Endif
			Do queries\item_kinnipidamine
		Case v_palk_kaart.liik = 7
			If !empty (cNimi)
				Wait window [Arvestan:]+cNimi+space(1)+'muud arvestused' nowait
			Endif
			If v_palk_kaart.asutusest > 0
&& ��������� � �����������
				Do queries\calc_muudarvestus
			Endif
		Case v_palk_kaart.liik = 3
			If !empty (cNimi)
				Wait window [Arvestan:]+cNimi+space(1)+'muud arvestused' nowait
			Endif
			Do queries\calc_muudarvestus
		Case v_palk_kaart.liik = 4
			If !empty (cNimi)
				Wait window [Arvestan:]+cNimi+space(1)+'tulumaks' nowait
			Endif
			Select qryTulumaks
			Locate for qryPalkLib.parentId = qryTulumaks.id
			If found ()
				Do queries\calc_tulumaks
			Endif
		Case v_palk_kaart.liik = 5
			If !empty (cNimi)
				Wait window [Arvestan:]+cNimi+space(1)+'sotsmaks' nowait
			Endif
			Do queries\calc_sotsmaks
		Case v_palk_kaart.liik = 6
			If !empty (cNimi)
				Wait window [Arvestan:]+cNimi+space(1)+'valja maksed' nowait
			Endif
			Do queries\calc_tasu
	Endcase
	=lausend()
Endproc

Procedure save_oper
	Select v_palk_oper
	lresult = odb.cursorupdate ('v_palk_oper')
	tnId = v_palk_oper.id
	If lresult = .t.
		lresult = save_lausend()
	Endif
	Return lresult
Endproc

Procedure lausend
	If !empty(v_dokprop.proc_)
		cProc = 'do queries\'+v_dokprop.proc_
		&cProc
	Endif
Endproc

Procedure get_osakonna_list
	If used('query1')
		Use in query1
	Endif
	tcKood = '%%'
	tcNimetus = '%%'
	odb.use('curOsakonnad','qryOsakonnad')
	Select curSource
	If reccount('curSource') > 0
		Zap
	Endif
	Append from dbf('qryOsakonnad')
	Use in qryOsakonnad
	Select curValitud
	If reccount('curvalitud') > 0
		Zap
	Endif
	Do form forms\samm with '1', iif(config.keel = 2,'Osakonnad','������'),iif(config.keel = 2,;
		'Valitud osakonnad','��������� ������') to nResult
	If nResult = 1
		Select distinc id from curValitud  into cursor query1
		Select query1
		Scan
			Insert into curResult (OsakonnaId);
				values (query1.id)
		Endscan
		Use in query1
		Select curValitud
		Zap
	Endif
	If nResult = 0
		lnStep = 0
	Else
		lnStep = lnStep + nResult
	Endif
Endproc

Procedure get_isiku_list
	If used('query1')
		Use in query1
	Endif
	If used ('qryTootajad')
		Use in qryTootajad
	Endif
	If used ('tooleping')
		Use in tooleping
	Endif
	If used ('asutus')
		Use in asutus
	Endif
	tcIsik = '%%'
	odb.use('comTootajad', 'qryTootajad')
	Select curSource
	If reccount('curSource') > 0
		Zap
	Endif
	Select kood, nimetus, id from qryTootajad where OsakondId in (select OsakonnaId from curResult) ;
		into cursor query1
	Select curSource
	Append from dbf('query1')
	Use in query1
	Select curValitud
	If reccount('curvalitud') > 0
		Zap
	Endif
	Do form forms\samm with '2', iif(config.keel = 2,'Isikud','���������'),;
		iif(config.keel = 2,'Valitud isikud','��������� ���������') to nResult
	If nResult = 1
		Select distinc id from curValitud into cursor query1
		Select query1
		Scan
			Insert into curResult (id);
				values (query1.id)
		Endscan
		Use in query1
	Endif
	If nResult = 0
		lnStep = 0
	Else
		lnStep = lnStep + nResult
	Endif
	Return

Procedure get_kood_list
	If used('query1')
		Use in query1
	Endif
	tcKood = '%%'
	tcNimetus = '%%'
	odb.use('curPalkLib','qryPalkLib')
	Select curSource
	If reccount('curSource') > 0
		Zap
	Endif
	Append from dbf('qryPalkLib')
	Use in qryPalkLib
	Select curValitud
	If reccount('curvalitud') > 0
		Zap
	Endif
	Do form forms\samm with '3', iif(config.keel = 2,'Palgastruktuur','���������� � ���������'),iif(config.keel = 2,;
		'Valitud ','�������� ') to nResult
	If nResult = 1
		Select distinc id from curValitud  into cursor query1
		Select query1
		Scan
			Insert into curResult (palklibId);
				values (query1.id)
		Endscan
		Use in query1
		Select curValitud
		Zap
	Endif
	If nResult = 0
		lnStep = 0
	Else
		lnStep = lnStep + nResult
	Endif
Endproc
