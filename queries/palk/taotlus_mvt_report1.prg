Parameter cWhere

Select T.*, a.regkood As isikukood, a.nimetus, l.osakond, l.amet From v_taotlus_mvt T,;
	v_asutus a, comToolepingTaotlusMvt l;
	WHERE l.Id = v_taotlus_mvt.lepingid ;
	Into Cursor taotlus_mvt_report1

Select taotlus_mvt_report1
