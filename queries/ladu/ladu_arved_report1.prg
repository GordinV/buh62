Parameter cWhere
If !Used('curLaduArved')
	Select 0
	Return .F.
Endif

Select * From curLaduArved order BY kpv, ladu, kood  Into Cursor arve_report2
