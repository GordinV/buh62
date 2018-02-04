Set proc to classes\json
local nRecno,i,oObj, cRetVal
	if alias()==''
		return ''
	endif
	oObj = newObject('myObj')
	for i=1 to fcount()
		oObj.set(Field(i),eval(Field(i)))
	next
	cRetVal = json_encode(oObj)
	if not empty(json_getErrorMsg())
		cRetVal = 'ERROR:'+json_getErrorMsg()
	endif
return cRetVal

function json_getErrorMsg()
return _json.cError


function json_decode(cJson)
Set proc to classes\json
local retval
	if vartype(_json)<>'O'
		public _json
		_json = newobject('json')
	endif
	retval = _json.decode(cJson)
	if not empty(_json.cError)
		return null
	endif
return retval

function json_encode(xExpr)
Set proc to classes\json
	if vartype(_json)<>'O'
		public _json
		_json = newobject('json')
	endif
return _json.encode(@xExpr)
