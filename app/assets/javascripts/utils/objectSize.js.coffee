window.Object.size = (obj) ->
	size = 0
	key = undefined
	for key of obj
		size++  if obj.hasOwnProperty(key)
	size