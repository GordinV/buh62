Parameter tcWhere
If !Used('fltrPalkJaak')
	Return .F.
Endif

lcOsakond = ''
If !Empty(fltrPalkJaak.osakond)
	Select comTunnusRemote
	Locate For Alltrim(Upper(kood)) = Alltrim(Upper(fltrPalkJaak.osakond))
	If Found()
		lcOsakond = Ltrim(Rtrim(comTunnusRemote.nimetus))
	Endif

Endif

tdKpv1 = Date(fltrPalkJaak.aasta1, fltrPalkJaak.kuu1, 1)
tdKpv2 = Gomonth(Date(fltrPalkJaak.aasta2, fltrPalkJaak.kuu2, 1),1) - 1

Create Cursor palkJaak_report1 (isikid Int, isik c(254), isikukood c(20), period c(30) Default Dtoc(tdKpv1)+".a. - "+Dtoc(tdKpv2)+".a.",;
	arv Y, tasu Y, tulumaks Y,  tki Y, muud Y, sots Y, tka Y, jaak Y, kinni Y, kKinni Y, pm Y, tunnus c(254) Default lcOsakond )
Index On Left(Upper(isik),40) Tag isik
Set Order To isik

Select palkJaak_report1

TEXT TO lcSqlWhere TEXTMERGE noshow
		isik ilike '%<<+Rtrim(Ltrim(fltrPalkJaak.nimetus))>>%'
		and osakond ilike '%<<Rtrim(Ltrim(lcOsakond))>>%'
		and kuu >= <<fltrPalkJaak.kuu1>>
		and kuu <= <<fltrPalkJaak.kuu2>>
		and aasta >= <<fltrPalkJaak.aasta1>>
		and aasta <= <<fltrPalkJaak.aasta2>>
		and rekvid = <<gRekv>>
ENDTEXT

lError = oDb.readFromModel('palk\palk_jaak', 'printPalkJaak', 'gRekv, guserid', 'tmpPalkOper', lcSqlWhere)

Insert Into palkJaak_report1 (isikid, isik, isikukood, ;
	arv, tasu, tulumaks,  tki, muud, sots, tka, jaak, kinni, kkinni, pm);
	SELECT isikid, isik, isikukood, SUM(arv), sum(tasu), sum(tm), sum(tki), sum(muud), sum(sm), sum(tka), sum(jaak), sum(kinni),sum(kinni + muud), sum(pm);
	from tmpPalkOper ;
	group by isikid, isik, isikukood ;
	order by isikukood

Use In tmpPalkOper
Select palkJaak_report1
