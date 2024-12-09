Parameter tnIsikid, is_tasu

Local lnResult, leRror, l_error
leRror = .T.
l_dokprop = 0

IF EMPTY(gdkpv)
	gdkpv = DATE()
ENDIF

* period
TEXT TO l_where NOSHOW textmerge
	aasta = <<YEAR(gdkpv)>>
	and kuu = <<MONTH(gdkpv)>>	
ENDTEXT


lError = oDb.readFromModel('ou\aasta', 'selectAsLibs', 'gRekv', 'tmp_period', l_where )
If !lError OR !USED('tmp_period')
	Messagebox('Viga',0+16, 'Period')
	Set Step On
	Return .t.
ENDIF

IF RECCOUNT('tmp_period') > 0 and !EMPTY(tmp_period.kinni)
	MESSAGEBOX('Period on kinni',0+16,'Kontrol')
	RETURN .f.
ENDIF

IF USED('tmp_period')
	USE IN tmp_period
ENDIF


If  Used('curSource')
	USE IN 'curSource'
ENDIF

Create Cursor curSource (Id Int, koOd C (20), niMetus C (120))

If  Used('curValitud')
	USE IN curValitud
ENDIF

Create Cursor curValitud (Id Int, koOd C (20), niMetus C (120))

IF USED('curResult')
	USE IN curResult 
ENDIF
Create Cursor curResult (Id Int, osAkonnaid Int, paLklibid Int, lepingid int)

IF USED('curOsakonnad')
	USE IN curOsakonnad 
ENDIF

CREATE CURSOR curOsakonnad (osAkonnaid Int)

lnStep = 1
If Used('v_dokprop')
	Use In v_dokprop
ENDIF

if EMPTY(l_dokprop) 
	SET PROCEDURE TO proc/getdokpropId additive
	l_dokprop = getdokpropId('PALK_OPER', 'libs\libraries\dokprops')
ENDIF

l_error = fnc_load_tootajad()
if EMPTY(l_error) OR !USED('qryTootajad') OR RECCOUNT('qryTootajad') = 0
	MESSAGEBOX('Tekkis viga',0+16,'Tццtajate nimekirja')
	RETURN .f.
ENDIF

l_success = .f.

Do While lnStep>0
	If  .Not. Empty(tnIsikid)
		Insert Into curResult (osAkonnaid) ;
			SELECT OSAKONDID From qryTootajad Where Id = tnIsikid
			 
		Insert Into curResult (Id) Values (tnIsikid) 
		
		* kui on osakonna filter
		IF !EMPTY(fltrPalkOper.osakondId) 
			INSERT INTO curOsakonnad (osAkonnaid) VALUES (fltrPalkOper.osakondId)
		ENDIF
		
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
RETURN l_success
Endproc
*
function arVutus
	Local leRror, lcOsakonnad
	leRror = .T.

* parameterid
	l_json = ''
	l_lib_ids = ''
	l_isik_ids = ''
	l_osakond_ids = ''

* lib_ids
	Select Distinct paLklibid As Id From curResult Where  Not  ;
		EMPTY(curResult.paLklibid) Into Cursor ValPalkLib

	Select ValPalkLib
	SCAN FOR !ISNULL(ValPalkLib.Id) AND ValPalkLib.Id > 0
		l_lib_ids = l_lib_ids + Iif(Len(l_lib_ids)> 0,',','') + Alltrim(Str(ValPalkLib.Id))
	Endscan
	Use In 	ValPalkLib


		Select Distinct Id From curResult Where  Not Empty(curResult.Id)  ;
			INTO Cursor recalc1

* osakond_ids
	IF USED('curOsakonnad') AND RECCOUNT('curOsakonnad') > 0 
		SELECT curOsakonnad
		Scan FOR !ISNULL(osAkonnaid) AND osAkonnaid > 0	
			l_osakond_ids = l_osakond_ids + Iif(Len(l_osakond_ids)>0,',','') +  Alltrim(Str(curOsakonnad.osAkonnaid))
		Endscan
	else

		Select curResult
		Scan FOR !ISNULL(osAkonnaid) AND osAkonnaid > 0	
			l_osakond_ids = l_osakond_ids + Iif(Len(l_osakond_ids)>0,',','') +  Alltrim(Str(curResult.osAkonnaid))
		Endscan

	ENDif;
* isik_ids
	Select recalc1
	SCAN FOR !ISNULL(recalc1.Id) 
		l_isik_ids = l_isik_ids + Iif(Len(l_isik_ids)>0,',','') +  Alltrim(Str(recalc1.Id))
	Endscan

TEXT TO lcJson TEXTMERGE noshow
				{"osakond_ids":[<<l_osakond_ids>>],
				"isik_ids":[<<l_isik_ids>>],
				"lib_ids":[<<l_lib_ids>>],
				"kpv":<<DTOC(gdKpv,1)>>,
				"kas_kustuta":<<IIF(!EMPTY(tmpArvestaMinSots.kustuta) and !is_tasu ,'true','false')>>,
				"kas_arvesta_minsots":<<IIF(!EMPTY(tmpArvestaMinSots.arvesta),'true','false')>>,
				"dokprop":<<ALLTRIM(STR(l_dokprop))>>
				}
ENDTEXT
* sql proc
*_cliptext = lcJson 
	task = 'palk.gen_palkoper'
	leRror = odB.readFromModel('palk\palk_oper', 'executeTask', 'guserid,lcJson,task', 'qryResult')
	Do Form taitmine_raport With 'qryResult' 
	
	Return leRror
ENDFUNC

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
	=fnc_load_tootajad()

	Select curSource
	If Reccount('curSource')>0
		Zap
	ENDIF
	
	
	Select isikukood As koOd, niMetus, Id From qryTootajad Where OSAKONDID In(Select  ;
		osAkonnaid From curResult) Into Cursor query1
	Select curSource
	Append From Dbf('query1')
	Use In query1
	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '2', Iif(coNfig.keEl=2, 'Isikud',  ;
		'Работники'), Iif(coNfig.keEl=2, 'Valitud isikud', 'Выбранные работники'), gdKpv, IIF(is_tasu,0,1)
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
	ENDIF
	IF !is_tasu 
		lcWhere = 'liik <> 6'
	ELSE
		lcWhere = 'liik = 6'
	ENDIF
	
	TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
	and (valid >= '<<DTOC(date(year(gdKpv),MONTH(gdKpv),DAY(gdKpv)),1)>>'::date  or valid is null)
	endtext	
	
	
	leRror = odB.readFromModel('libs\libraries\palk_lib', 'curPalklib', 'gRekv, guserid', 'qryPalkLib', lcWhere)

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
		'Palgastruktuur', 'Начисления и удержания'), Iif(coNfig.keEl=2,  ;
		'Valitud ', 'Выбранно '), gdKpv, IIF(is_tasu,0,1)


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
	lcSqlWhere = ''
* parameters

TEXT TO lcSqlWhere textmerge	noshow
	(algab <= ?gdKpv or algab is null)
	and (lopp >= ?gdKpv or lopp is null)
	order by nimetus
ENDTEXT
IF USED('qryTootajad')
	USE IN qryTootajad
ENDIF


	leRror = odB.readFromModel('palk\tootaja', 'curTootajad', 'gRekv, guserid', 'qryTootajad', lcSqlWhere)
	IF lError AND !USED('qryTootajad')
		lError = .f.
	ENDIF
	
	RETURN leRror
Endfunc


Procedure geT_osakonna_list
	If Used('query1')
		Use In query1
	Endif
	leRror = odB.readFromModel('libs\libraries\osakond', 'curOsakonnad', 'gRekv, guserid', 'qryOsakonnad')

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
		'Отделы'), Iif(coNfig.keEl=2, 'Valitud osakonnad', 'Выбранные отделы'), gdKpv, IIF(is_tasu,0,1)
	If nrEsult=1
		Select Distinct Id From curValitud Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (osAkonnaid) Values (query1.Id)
			INSERT INTO curOsakonnad  (osAkonnaid) Values (query1.Id)
		Endscan
		Use In query1
		Select curValitud
		ZAP
		lnStep = lnStep+nrEsult
	ELSE
		lnStep = 0	
	Endif
Endproc
