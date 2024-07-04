Parameter tcWhere
If !Used('fltrPalkJaak')
	Return .F.
Endif

tcProj = ALLTRIM(fltrPalkJaak.proj)+'%'
IF EMPTY(ALLTRIM(fltrPalkJaak.proj))
	tcProj = null
ENDIF


tdKpv1 = Date(fltrPalkJaak.aasta1, fltrPalkJaak.kuu1, 1)
tdKpv2 = Gomonth(Date(fltrPalkJaak.aasta2, fltrPalkJaak.kuu2, 1),1) - 1

Create Cursor palkJaak_report1 (isikid Int, isik c(254), isikukood c(20), period c(30) Default Dtoc(tdKpv1)+".a. - "+Dtoc(tdKpv2)+".a.",;
	arv n(12,2), tasu n(12,2), tulumaks n(12,2),  tki n(12,2), muud n(12,2), sots n(12,2), tka n(12,2), jaak n(12,2), kinni n(12,2), kKinni n(12,2), pm n(12,2), tunnus c(254) , osakonna_nimetus c(254), osakond c(20) )
Index On Left(Upper(isik),40) Tag isik
Set Order To isik

Select palkJaak_report1

TEXT TO lcSqlWhere TEXTMERGE noshow
		isik ilike '%<<+Rtrim(Ltrim(fltrPalkJaak.nimetus))>>%'
		and osakond ilike '%<<Rtrim(Ltrim(fltrPalkJaak.osakond))>>%'
		and kuu >= <<fltrPalkJaak.kuu1>>
		and kuu <= <<fltrPalkJaak.kuu2>>
		and aasta >= <<fltrPalkJaak.aasta1>>
		and aasta <= <<fltrPalkJaak.aasta2>>
		and rekvid = <<gRekv>>
		and status <= <<IIF(EMPTY(fltrPalkJaak.status),2,1)>>
ENDTEXT
SET STEP ON 
lError = oDb.readFromModel('palk\palk_jaak', 'printPalkJaak', 'gRekv, guserid,tcProj', 'tmpPalkOper', lcSqlWhere)
SELECT tmpPalkOper 
brow

Insert Into palkJaak_report1 (isikid, isik, isikukood, ;
	arv, tasu, tulumaks,  tki, muud, sots, tka, jaak, kinni, kkinni, pm, osakond, osakonna_nimetus);
	SELECT isikid, isik, isikukood, SUM(arv), sum(tasu), sum(tm), sum(tki), sum(muud), sum(sm), sum(tka), sum(jaak), ;
		sum(kinni),sum(kinni + muud + tasu + tki + pm + tm), sum(pm),;
		osakond, osakonna_nimetus ;
	from tmpPalkOper ;
	group by isikid, isik, isikukood, osakond, osakonna_nimetus ;
	order by isikukood

Use In tmpPalkOper
Select palkJaak_report1
