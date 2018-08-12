Parameter cWhere
IF !USED('curArved')
	SELECT 0
	RETURN .f.
ENDIF

SELECT * from curArved INTO CURSOR arve_report2

SELECT arve_report2
index on id tag id
index on number tag number additive
index on kpv tag kpv additive
index on left(upper(asutus),40) tag asutus additive
index on summa tag summa additive
index on tasud tag tasud additive
index on tahtaeg tag tahtaeg additive
set order to kpv

IF USED('curArved')
	SELECT curArved
	lcTag = TAG()
	select arve_report2

	IF !EMPTY(lcTag) AND lcTag <> 'JAAK'
		set order to (lcTag)
	endif
endif