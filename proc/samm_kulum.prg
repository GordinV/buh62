Parameters tnPvKaartId


* period
TEXT TO l_where NOSHOW textmerge
	aasta = <<YEAR(curKulumiarv.kpv)>>
	and kuu = <<MONTH(curKulumiarv.kpv)>>	
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


Local  lnResult
If !Used('curSource')
	Create Cursor curSource (Id Int, kood c(20), nimetus c(120))
Endif
If !Used('curValitud')
	Create Cursor curValitud (Id Int, kood c(20), nimetus c(120))
Endif
Create Cursor curResult (Id Int, gruppId Int, nomId Int)
lnStep = 1

If !Empty(tnPvKaartId)
	Insert Into  curResult (Id) Values (tnPvKaartId)
	lnStep = 3
ENDIF

Do While lnStep > 0
	Do Case
		Case lnStep = 1
			Do get_grupp_list
		Case lnStep = 2
			Do get_pvkaart_list
		Case lnStep > 2
			Do arvutus
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


Procedure arvutus
	Local lError
	If !Used('curKulumiarv')
		Return .F.
	Endif

	Select Distinc Id From curResult Where !Empty(curResult.Id) Into Cursor recalc1
	Select recalc1
	lcParams = ''
	Scan
		lcParams = lcParams + Iif(Len(lcParams) > 0,',','') + Alltrim(Str(recalc1.Id))
	Endscan

	If !Empty(lcParams)
TEXT TO lcParams TEXTMERGE noshow
		{"ids":[<<lcParams>>], "kpv":"<<DTOC(curKulumiarv.kpv,1)>>","nomid":<<curKulumiarv.nomid>>,"doklausid":<<curKulumiarv.doklausid>>}
ENDTEXT
		* sql proc
		task = 'docs.sp_samm_kulum'
		lError = odB.readFromModel('libs\libraries\pv_kaart', 'executeTask', 'guserid,lcParams,task', 'qryResult')

		If !lError OR !USED('qryResult')
			Messagebox('Arvestuse viga',0+16,'Kontrol')
			Set Step On
		Else
			Messagebox('Kokku arvestatud:' + Alltrim(Str(qryResult.result)),0+48,'Tulemus')
			Use In qryResult
		Endif
	Endif

	lnStep = 0
	Return lError
Endproc

Procedure get_grupp_list
	If Used('query1')
		Use In query1
	Endif

	lError = odB.readFromModel('libs\libraries\pv_grupp', 'curPvgruppid', 'gRekv, gUserid', 'qryPvGruppid')

	Select curSource
	If Reccount('curSource') > 0
		Zap
	Endif
	Append From Dbf('qryPvGruppid')
	Use In qryPvGruppid
	Select curValitud
	If Reccount('curvalitud') > 0
		Zap
	ENDIF
	gdKpv = curKulumiarv.kpv
	Do Form Forms\samm With '1', Iif(config.keel = 2,'Pхhivara gruppid','Группы основных средств'),Iif(config.keel = 2,;
		'Valitud gruppid','Выбранные группы'), curKulumiarv.kpv To nResult
	If nResult = 1
		Select Distinc Id From curValitud  Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (gruppId);
				values (query1.Id)
		Endscan
		Use In query1
		Select curValitud
		Zap
	Endif
	If nResult = 0
		lnStep = 0
	Else
		lnStep = lnStep + nResult
	Endif
	Select curResult
Endproc

Procedure get_pvkaart_list
	l_grupp_ids = ''

	Select curResult
	Scan For !Empty(gruppId)
		l_grupp_ids = l_grupp_ids + Iif(Len(ALLTRIM(l_grupp_ids)) > 0,',','') + Alltrim(Str(curResult.gruppId))
	Endscan


TEXT TO lcWhere TEXTMERGE noshow
		 soetkpv <= '<<DTOC(GOMONTH(curKulumiarv.kpv,1) -1,1)>>'
		 and status = 1		 
ENDTEXT

	If Len(l_grupp_ids) > 0
TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
			and gruppid in (<<l_grupp_ids>>)
ENDTEXT
	Endif
	lSelg = null
	lError = odB.readFromModel('libs\libraries\pv_kaart', 'curPohivara', 'gRekv,guserid,lSelg', 'qryPohivara',lcWhere)

	Select curSource
	If Reccount('curSource') > 0
		Zap
	Endif
	Select curResult
	Select Distinct kood, nimetus, Id From qryPohivara;
		into Cursor query1
	Select curSource
	Append From Dbf('query1')
	Use In query1

	Select curValitud
	If Reccount('curvalitud') > 0
		Zap
	Endif

	Do Form Forms\samm With '2', Iif(config.keel = 2,'Inv. kaardid','Инвентарные карты'),;
		iif(config.keel = 2,'Valitud gruppid','Выбранные группы') To nResult

	If nResult = 1
		Select Distinc Id From curValitud Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (Id);
				values (query1.Id)
		Endscan
		Use In query1
	Endif
	If nResult = 0
		lnStep = 0
	Else
		lnStep = lnStep + nResult
	Endif
	Return

Procedure get_nom_list
	If Used('query1')
		Use In query1
	Endif
	Select Distinct kood, nimetus, Id From comNomRemote Where DOK = 'KULUM' Into Cursor qryKulum
	Select curSource
	If Reccount('curSource') > 0
		Zap
	Endif
	Append From Dbf('qryKulum')
	Use In qryKulum
	Select curValitud
	If Reccount('curvalitud') > 0
		Zap
	Endif
	If Reccount ('curSource') > 1
		Do Form Forms\samm With '1', Iif(config.keel = 2,'Pхhivara gruppid','Группы основных средств'),Iif(config.keel = 2,;
			'Valitud gruppid','Выбранные группы') To nResult
	Else
		Select curValitud
		Append Blank
		Replace kood With curSource.kood,;
			nimetus With curSource.nimetus,;
			id  With curSource.Id In curValitud
	Endif
	If nResult = 1
		Select Distinc Id From curValitud  Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (nomId);
				values (query1.Id)
		Endscan
		Use In query1
		Select curValitud
		Zap
	Endif
	If nResult = 0
		lnStep = 0
	Else
		lnStep = lnStep + nResult
	Endif
Endproc


