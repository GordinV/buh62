Parameter tnIsikid

Local lnResult, leRror
leRror = .T.
If Empty(tnIsikid)
	tnIsikid = 0
Endif
If  .Not. Used('curSource')
	Create Cursor curSource (Id Int, koOd C (20), niMetus C (120))
Endif
If  .Not. Used('curValitud')
	Create Cursor curValitud (Id Int, koOd C (20), niMetus C (120))
Endif
Create Cursor curResult (Id Int, osAkonnaid Int, paLklibid Int)
lnStep = 1
If Used('v_dokprop')
	Use In v_dokprop
Endif

dokPropId = getdokpropId('PALK_OPER', 'libs\libraries\dokprops')

=fnc_load_tootajad();

Do While lnStep > 0
	If !Empty(fltrPalkOper.osakondId)
		Insert Into curResult (osAkonnaid) Values (fltrPalkOper.osakondId)
	Endif

	If  .Not. Empty(tnIsikid)
		Insert Into curResult (osAkonnaid) ;
			SELECT osakondId From comTootajad Where Id = tnIsikid ;
			AND osakondId >= Iif(fltrPalkOper.osakondId > 0,fltrPalkOper.osakondId,0);
			AND osakondId <= Iif(fltrPalkOper.osakondId > 0,fltrPalkOper.osakondId,999999999)


		Insert Into curResult (Id) Values (tnIsikid)
		lnStep = 3
		tnIsikid = 0
	Endif

	Do Case
		Case lnStep=1
			Do geT_osakonna_list
		Case lnStep=2
			Do geT_isiku_list
		Case lnStep=3
			Do geT_kood_list
		Case lnStep>3
			l_success = arVutus()
			lnStep = 0
	Endcase
Enddo

If Used('curSource')
	Use In curSource
Endif
If Used('curvalitud')
	Use In curValitud
Endif
If Used('curResult')
	Use In curResult
Endif
If Used('tmpArvestaMinSots')
	Use In tmpArvestaMinSots
Endif

Return l_success
Endproc
*
Procedure arVutus
	Local leRror
	leRror = .T.


* parameterid
	l_json = ''
	l_lib_ids = ''
	l_isik_ids = ''
	l_osakond_ids = ''

	Select Distinct paLklibid From curResult Where  Not  ;
		EMPTY(curResult.paLklibid) Into Cursor ValPalkLib

	Select ValPalkLib
	Scan
		l_lib_ids = l_lib_ids + Iif(Len(l_lib_ids)> 0,',','') + Alltrim(Str(ValPalkLib.Id))
	Endscan
	Use In 	ValPalkLib

* osakond_ids
	Select Distinct Id From curResult Where  Not Empty(curResult.Id)  ;
		INTO Cursor recalc1

	Select curResult
	Scan For osAkonnaid > 0
		l_osakond_ids = l_osakond_ids + Iif(Len(l_osakond_ids)>0,',','') +  Alltrim(Str(curResult.osAkonnaid))
	Endscan

* isik_ids
	Select recalc1
	Scan
		l_isik_ids = l_isik_ids + Iif(Len(l_isik_ids)>0,',','') +  Alltrim(Str(recalc1.Id))
	Endscan


TEXT TO lcJson TEXTMERGE noshow
				{"osakond_ids":[<<l_osakond_ids>>],
				"isik_ids":[<<l_isik_ids>>],
				"lib_ids":[<<l_lib_ids>>],
				"kpv":<<DTOC(gdKpv,1)>>,
				"kas_kustuta":<<IIF(EMPTY(tmpArvestaMinSots.kustuta),'true','false')>>,
				"kas_arvesta_minsots":<<IIF(EMPTY(tmpArvestaMinSots.arvesta),'true','false')>>,
				"dokprop":<<ALLTRIM(STR(dokPropId))>>
				}
ENDTEXT


	Select recalc1
	Scan
		Select coMasutusremote
		Locate For Id=recalc1.Id
		If Found()
			cnImi = Rtrim(coMasutusremote.niMetus)
		Else
			cnImi = ''
		Endif
		tnId = recalc1.Id
		If  .Not. Used('v_palk_kaart')
			.Use('v_palk_kaart')
		Else
			.dbReq('v_palk_kaart',gnHandle,'v_palk_kaart')
		Endif
		Select v_Palk_kaart
		Index On (liIk*Iif(v_Palk_kaart.liIk=2 .And. v_Palk_kaart.maKs = 1, 10, 1)) Tag liIk For Status=1 And liIk = 6
		Set Order To liIk
		.opEntransaction()
		Select v_Palk_kaart
		Scan For v_Palk_kaart.Status=1
			Select ValPalkLib
			Locate For ValPalkLib.paLklibid=v_Palk_kaart.liBid
			If Found()
				leRror = edIt_oper(recalc1.Id)
				If Empty(leRror)
					Exit
				Endif
			Endif
		Endscan
		If leRror=.T.
			.coMmit()
		Else
			.Rollback()
			Messagebox('Viga', 'Kontrol')
		Endif
		If leRror=.F.
			Exit
		Endif

	Endscan
	lnStep = 0
Endwith
Endproc
*
Procedure edIt_oper
	Parameter tnId
	tnId = recalc1.Id
	tnId = v_Palk_kaart.liBid
	If Empty(gdKpv) .Or. Empty(gnKuu) .Or. Empty(gnAasta)
		Do Form period
	Endif

	leRror = odB.Exec("gen_palkoper ",Str(v_Palk_kaart.lepingId)+","+Str(v_Palk_kaart.liBid)+;
		","+Str(v_dokprop.Id)+", DATE("+;
		STR(Year(gdKpv),4)+","+Str(Month(gdKpv),2)+","+Str(Day(gdKpv),2)+")"+","+'0','qryOper')

	Return leRror
Endproc
*

Procedure geT_osakonna_list
	If Used('query1')
		Use In query1
	Endif
	tcKood = '%%'
	tcNimetus = '%%'
	odB.Use('curOsakonnad','qryOsakonnad')
	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Append From Dbf('qryOsakonnad')
	Use In qrYosakonnad
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '1', Iif(coNfig.keEl=2, 'Osakonnad',  ;
		'������'), Iif(coNfig.keEl=2, 'Valitud osakonnad', '��������� ������')
	If nrEsult=1
		Select Distinct Id From curValitud Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (osAkonnaid) Values (query1.Id)
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
Procedure geT_isiku_list
	If Used('query1')
		Use In query1
	Endif
	If Used('qryTootajad')
		Use In qryTootajad
	Endif
	If Used('tooleping')
		Use In toOleping
	Endif
	If Used('asutus')
		Use In asUtus
	Endif
	tcIsik = '%%'
	odB.Use('comTootajad','qryTootajad')
	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Select koOd, niMetus, Id From qryTootajad Where osakondId In(Select  ;
		osAkonnaid From curResult) Into Cursor query1
	Select curSource
	Append From Dbf('query1')
	Use In query1
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '2', Iif(coNfig.keEl=2, 'Isikud',  ;
		'���������'), Iif(coNfig.keEl=2, 'Valitud isikud', '��������� ���������')
	If nrEsult=1
		Select Distinct Id From curValitud Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (Id) Values (query1.Id)
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
Procedure geT_kood_list
	If Used('query1')
		Use In query1
	Endif
	tcKood = '%%'
	tcNimetus = '%%'
	TCTULULIIK = '%%'
	tnStatus = 0
	odB.Use('curPalkLib','qryPalkLib')
	Delete From qrYpalklib Where liIk<>6
	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Append From Dbf('qryPalkLib')
	Use In qrYpalklib
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '3', Iif(coNfig.keEl=2,  ;
		'Palgastruktuur', '���������� � ���������'), Iif(coNfig.keEl=2,  ;
		'Valitud ', '�������� '), .f.
	If nrEsult=1
		Select Distinct Id From curValitud Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (paLklibid) Values (query1.Id)
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


Function fnc_load_tootajad
	tcIsik = '%'
	tnOsakondid1 = 0
	tnOsakondid2 = 999999999
	lcSqlWhere = ''
	lcAlias = 'curTootajad'
* parameters

TEXT TO lcSqlWhere textmerge	noshow
	nimetus ilike ?tcIsik
	and (osakondid >= ?tnOsakondid1 or osakondid is null)
	and (osakondId <= ?tnOsakondid2 or osakondid is null)
	and (algab <= ?gdKpv or algab is null)
	and (lopp >= ?gdKpv or lopp is null)
ENDTEXT

	leRror = odB.readFromModel('palk\tootaja', 'curTootajad', 'gRekv, guserid', 'qryTootajad', lcSqlWhere)

Endfunc
