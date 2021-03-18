l_str_test_1 = 'DRIVER=PostgreSQL Unicode;DATABASE=narvalv;server=213.184.47.198;PORT=5436;MaxVarcharSize=254;uid=vlad;pwd=Vlad490710'
l_str_new = 'DRIVER=PostgreSQL Unicode;DATABASE=db;server=80.235.127.119;PORT=5438;MaxVarcharSize=254;uid=vlad;pwd=Vlad490710'

l_conect_test1 =  SQLStringConnect(l_str_test_1)
l_conect_new =  SQLStringConnect(l_str_new)

If l_conect_test1 < 1 OR l_conect_new < 0 
	Messagebox('Viga, uhendus')
	Set Step On
	Return
Endif

SET STEP ON 
* get artikkels from test

TEXT TO l_sql
select * from (
                  SELECT *, (properties::JSONB ->> 'valid')::DATE AS valid
                  FROM libs.library
                  WHERE library.library = 'TULUDEALLIKAD'
              ) qry
where valid is not null
and kood = '3201'
ENDTEXT

l_result = SQLEXEC(l_conect_test1 , l_sql, 'tmpArt')
IF l_result < 0 
	SET STEP ON 
	RETURN	
ENDIF

* check for valid

SELECT tmpArt
brow

* update valid 
SELECT tmpArt
WAIT WINDOW tmpArt.kood NOWAIT 
SCAN
	TEXT TO l_sql TEXTMERGE noshow
		UPDATE libs.library SET properties = properties::jsonb || '{"valid":"2020-12-31"}'::jsonb
		where id = <<tmpArt.id>>
		and  library.library = 'TULUDEALLIKAD'		
	ENDTEXT
	l_result = SQLEXEC(l_conect_new , l_sql)
	IF l_result < 0 
		SET STEP ON 
		_cliptext = l_sql
	ENDIF
	WAIT WINDOW tmpArt.kood + ' ok' TIMEOUT 1
	
ENDSCAN


 = sqldisconnect(l_conect_test1 )
= sqldisconnect(l_conect_new )
