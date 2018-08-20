Parameter tnIsikid, is_tasu

Local lnResult, leRror
leRror = .T.
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
ENDIF
dokPropId = getdokpropId('PALK_OPER', 'libs\libraries\dokprops')

=fnc_load_tootajad();

l_success = .f.

Do While lnStep>0
	If  .Not. Empty(tnIsikid)
		Insert Into curResult (osAkonnaid) ;
			SELECT OSAKONDID From comTootajad Where Id = tnIsikid ;
			AND OSAKONDID >= Iif(fltrPalkOper.OSAKONDID > 0,fltrPalkOper.OSAKONDID,0);
			AND OSAKONDID <= Iif(fltrPalkOper.OSAKONDID > 0,fltrPalkOper.OSAKONDID,999999999)

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
* sql proc
	task = 'palk.gen_palkoper'
	leRror = odB.readFromModel('palk\palk_oper', 'executeTask', 'guserid,lcJson,task', 'qryResult')
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
	Endif
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
