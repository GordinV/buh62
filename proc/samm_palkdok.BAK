Parameter tnIsikid
Local lnResult, leRror
lnkassaOrder = 0
lnKassaSumma = 0
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

Do While lnStep>0
	If  .Not. Empty(tnIsikid)
		Insert Into curResult (osAkonnaid) ;
			SELECT OSAKONDID From qryTootajad Where Id = tnIsikid
			 
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
	Select Distinct paLklibid From curResult Where  Not  ;
		EMPTY(curResult.paLklibid) Into Cursor ValPalkLib

	Select Distinct Id From curResult Where  Not Empty(curResult.Id)  ;
		INTO Cursor qryIsikud
	Select recalc1
* isik_ids
	Select qryIsikud
	l_isik_ids = ''
	Scan
		l_isik_ids = l_isik_ids + Iif(Len(l_isik_ids)>0,',','') +  Alltrim(Str(qryIsikud.Id))
	Endscan
	Use In qryIsikud

*osAkonnaid
	Select Distinct osAkonnaid As Id From curResult Where  Not Empty(curResult.osAkonnaid)  ;
		INTO Cursor qryOsakonnad
	Select 	qryOsakonnad
	l_osak_ids = ''
	Scan
		l_osak_ids = l_osak_ids + Iif(Len(l_osak_ids)>0,',','') +  Alltrim(Str(qryOsakonnad.Id))
	Endscan
	Use In qryOsakonnad

* paLklibid
	Select Distinct paLklibid As Id From curResult Where  Not Empty(curResult.paLklibid)  ;
		INTO Cursor qryLibs

	Select qryLibs
	l_lib_ids = ''
	Scan
		l_lib_ids = l_lib_ids + Iif(Len(l_lib_ids)>0,',','') +  Alltrim(Str(qryLibs.Id))
	Endscan
	Use In qryLibs

TEXT TO lcJson TEXTMERGE noshow
		{"isik_ids":[<<l_isik_ids>>],
		"osakond_ids":[<<l_osak_ids>>],
		"lib_ids":[<<l_lib_ids>>],"kpv":<<DTOC(gdKpv,1)>>}
ENDTEXT
* sql proc
	task = 'palk.gen_palk_dok'
	_cliptext = lcJson
	leRror = odB.readFromModel('palk\palk_oper', 'executeTask', 'guserid,lcJson,task', 'qryResult')
	lnStep = 0
	If leRror And qryResult.result > 0
		Messagebox('Kogu valmistatud dokumendid: '+Alltrim(Str(qryResult.result)),0+48,'Tulemus')
	Endif

	Return leRror
Endproc


Procedure geT_osakonna_list
	If !Used('comOsakondRemote')
		leRror = odB.readFromModel('libs\libraries\osakond', 'selectAsLibs', 'gRekv, guserid', 'comOsakondRemote')
	Endif

	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Append From Dbf('comOsakondRemote')

	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '1', Iif(config.keel=2, 'Osakonnad',  ;
		'Отделы'), Iif(config.keel=2, 'Valitud osakonnad', 'Выбранные отделы')
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
	If !Used('comTootajadRemote')
		leRror = odB.readFromModel('palk\tootaja', 'selectAsLibs', 'gRekv, guserid', 'comTootajadRemote')

		If 	!leRror And Used('comTootajadRemote') And Reccount('comTootajadRemote') > 0
			Messagebox('Tццtajate nimekirja laadimine ebaхnnestus',0 + 48,'Error')
			Return .F.
		Endif

	Endif


	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif


	Select Distinct isikukood As koOd, niMetus, Id From comTootajadRemote Where osakondId In(Select  ;
		osAkonnaid From curResult) Into Cursor query1

	Select curSource
	Append From Dbf('query1')
	Use In query1
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '2', Iif(config.keel=2, 'Isikud',  ;
		'Работники'), Iif(config.keel=2, 'Valitud isikud', 'Выбранные работники')
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

	lcWhere = 'liik = 6'
	leRror = odB.readFromModel('libs\libraries\palk_lib', 'selectAsLibs', 'gRekv, guserid', 'qryPalkLib',lcWhere)


	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif
	Append From Dbf('qryPalkLib')

	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '3', Iif(config.keel=2,  ;
		'Palgastruktuur', 'Начисления и удержания'), Iif(config.keel=2,  ;
		'Valitud ', 'Выбранно ')
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
