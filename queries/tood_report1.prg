Parameter tcWhere
if vartype(oDb) <> 'O'
	set classlib to classes\classlib
	oDb = createobject('db')
endif
if !used('fltrTood')
	return .f.
endif
tcisik = '%'+rtrim(ltrim(fltrTood.isik))+'%'
tcTeenus = '%'+rtrim(ltrim(fltrTood.teenus))+'%'
tcAsutus = '%'+rtrim(ltrim(fltrTood.asutus))+'%'
tdKpv1 = iif(empty(fltrTood.kpv1),date(year(date()),month(date()),1),fltrTood.kpv1)
tdKpv2 = iif(empty(fltrTood.kpv2),date(),fltrTood.kpv2)
tnKogus1 = fltrTood.Kogus1
tnKogus2 = iif(empty(fltrTood.Kogus2),999999999,fltrTood.Kogus2)
oDb.use('cur_Tood','Tood_report1')
select tood_report1
&&index on left(upper(asutus),40)+'-'+dtoc(kpv) tag isik
&&set order to isik