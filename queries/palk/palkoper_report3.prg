Parameter tcWhere
if !used('curPalkOper')
	SELECT 0
	return .f.
ENDIF

SELECT comAsutusRemote.regkood as isikukood, curPalkOper.nimetus, sum(curPalkOper.summa) as summa, curPalkOper.isik ;
	FROM curPalkOper INNER JOIN comAsutusRemote ON  comAsutusRemote.id = curPalkOper.isikId;
	GROUP BY curPalkOper.nimetus, curPalkOper.isik, comAsutusRemote.regkood;
	order BY curPalkOper.nimetus, curPalkOper.isik, comAsutusRemote.regkood;
	INTO CURSOR palkoper_report1
	
SELECT palkoper_report1