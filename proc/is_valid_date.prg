LPARAMETERS l_kpv


IF !EMPTY(l_kpv) AND (year(l_kpv) > year(date())+1 or year(l_kpv) < year(date())- 1)
	messagebox(iif (config.keel = 1, 'Îøèáêà â äàòå','Viga kuupäevas'),'Kontrol')
	return .f. 
endif
