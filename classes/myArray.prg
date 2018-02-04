define class myArray as custom
	nSize = 0
	dimension array[1]

	function add(xExpr)
		this.nSize = this.nSize + 1
		dimension this.array[this.nSize]
		this.array[this.nSize] = xExpr
	return

	function get(n)
	return this.array[n]

	function getsize()
	return this.nSize

enddefine