Parameter cWhere

l_cursor = 'curAmetid'
l_output_cursor = 'ametid_report1'

SELECT (l_cursor)
lcTag = TAG()

IF !USED(l_cursor)
	SELECT 0
	RETURN .f.
ENDIF

* new sql query
TEXT TO sqlWhere TEXTMERGE noshow
	fix_text(ameti_kood::text) like '%<<ltrim(rtrim(fltrAmetid.kood))>>%'
	and fix_text(amet::text) like '%<<ltrim(rtrim(fltrAmetid.amet))>>%'
	and fix_text(osakond::text) ilike '%<<ltrim(rtrim(fltrAmetid.Osakond))>>%'
	and ameti_klassif::text ilike '%<<ltrim(rtrim(fltrAmetid.ameti_klassif))>>%'	
	and kogus >= <<fltrAmetid.kogus1>> 
	and kogus <= <<fltrAmetid.kogus2>>
	and coalesce(vaba,0) >= <<fltrAmetid.vaba1>> 
	and coalesce(vaba,0) <= <<fltrAmetid.vaba2>>
	and palgamaar >= <<fltrAmetid.Maar1>>
	and palgamaar <= <<fltrAmetid.maar2>>
	and (valid >= '<<DTOC(date(year(fltrAmetid.valid),MONTH(fltrAmetid.valid),DAY(fltrAmetid.valid)),1)>>'::date  or valid is null)	
ENDTEXT

	lError = oDb.readFromModel('libs\libraries\amet','curAmetid', 'gRekv, guserid', 'tmpAmetid' , sqlWhere)
	IF !lError OR !USED('tmpAmetid' )
		SET STEP on
		return
	ENDIF

*
TEXT TO lcSql TEXTMERGE noshow
	SELECT * from tmpAmetid ORDER BY <<IIF(EMPTY(lcTag),'id',lcTag)>> into CURSOR <<l_output_cursor>>
ENDTEXT

&lcSql

IF !USED(l_output_cursor)
	SELECT 0
	RETURN .f.
ENDIF
SELECT (l_output_cursor)
