Parameter tnIsikid

Local lnResult, leRror
lnkassaOrder = 0
lnKassaSumma = 0
leRror = .T.

If Empty(gdkpv)
	gdkpv = Date()
Endif

* period
TEXT TO l_where NOSHOW textmerge
	aasta = <<YEAR(gdkpv)>>
	and kuu = <<MONTH(gdkpv)>>
ENDTEXT

leRror = oDb.readFromModel('ou\aasta', 'selectAsLibs', 'gRekv', 'tmp_period', l_where )
If !leRror Or !Used('tmp_period')
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
l_success = .f.	

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
		OTHERWISE 
			l_success = .f.	
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
_cliptext = lcJson
* sql proc
	task = 'palk.gen_palk_dok'
	leRror = oDb.readFromModel('palk\palk_oper', 'executeTask', 'guserid,lcJson,task', 'qryResult')
	Do Form taitmine_raport With 'qryResult' 

	lnStep = 0

	Return leRror
Endproc


Procedure geT_osakonna_list
	If !Used('comOsakondRemote')
		leRror = oDb.readFromModel('libs\libraries\osakond', 'selectAsLibs', 'gRekv, guserid', 'comOsakondRemote')
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
	tcIsik = '%'
	tnOsakondid1 = 0
	tnOsakondid2 = 999999999
	lcSqlWhere = ''
* parameters

TEXT TO lcSqlWhere textmerge	noshow
	nimetus ilike ?tcIsik
	and (osakondid >= ?tnOsakondid1 or osakondid is null)
	and (osakondId <= ?tnOsakondid2 or osakondid is null)
	and (algab <= ?gdKpv or algab is null)
	and (lopp >= ?gdKpv or lopp is null)
		order by nimetus

ENDTEXT

	leRror = oDb.readFromModel('palk\tootaja', 'curTootajad', 'gRekv, guserid', 'qryTootajad', lcSqlWhere )

	If 	!leRror And Used('qryTootajad') And Reccount('qryTootajad') > 0
		Messagebox('Tццtajate nimekirja laadimine ebaхnnestus',0 + 48,'Error')
		Return .F.
	Endif


	Select curSource
	If Reccount('curSource')>0
		Zap
	Endif


	Select Distinct isikukood As koOd, niMetus, Id From qryTootajad Where OSAKONDID In(Select  ;
		osAkonnaid From curResult) ;
		ORDER BY niMetus ;
		Into Cursor query1

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
	leRror = oDb.readFromModel('libs\libraries\palk_lib', 'selectAsLibs', 'gRekv, guserid', 'qryPalkLib',lcWhere)


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
