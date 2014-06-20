# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

return if window.hash_array == undefined

#Initialisers
$(document).ready ->
	# syntax highlight the code. 
	# On callback highlight altered lines with diff colouring
	prettyPrint(highlightLines)
	setButtonStates(hash_array.indexOf(window.currentHash))

#Event bindings
$(document).keydown (e) ->
	if e.keyCode is 37
		back()
	else if e.keyCode is 39
		forward()

$('.code-block').on "mousewheel", (e, delta, deltaX, deltaY) ->
	if deltaY is 0
		if deltaX < 0
			back()
		else if deltaX > 0
			forward()

		if deltaX != 0
			e.preventDefault()

$('#back').click ->
	back()

$('#forward').click ->
	forward()

#Utility functions
highlightLines = ->
	for i in [0..file_versions.length - 1]
		hash = file_versions[i][0]
		if file_versions[i+1]
			f1 = file_versions[i+1][1].file_contents.split("\n")
		else
			f1 = ""
		f2 = file_versions[i][1].file_contents.split("\n")
		sm = new difflib.SequenceMatcher(f1,f2)
		lineArray = $('#' + hash + ' ol').children().toArray()
		for group in sm.get_opcodes()
			if group[0] == "equal"
				# DO NOTHING
			else if group[0] == "insert"
				for line in [group[2]+1..group[4]]
					$(lineArray[line-1]).addClass("addition")
			else if group[0] == "replace"
				for line in [group[2]..group[4]]
					$(lineArray[line-1]).addClass("change")
			else if group[0] == "delete"
				$(lineArray[group[4]]).addClass("deletion")

back = ->
	changeCommit -1

forward = ->
	changeCommit 1

window.jumpTo = (nextHash) ->
	nextIndex = hash_array.indexOf(nextHash)
	currentHash = window.currentHash
	if nextHash
		$('#' + currentHash).toggleClass("hidden")
		$('#' + nextHash).toggleClass("hidden")
		window.currentHash = nextHash
	setButtonStates(nextIndex)

setButtonStates = (currentIndex) ->
	#enable all buttons
	$('.changeButtons').removeClass("disabled")

	#disable buttons if action not available
	if currentIndex <= 0
		$('#back').addClass("disabled")
	if currentIndex >= (hash_array.length - 1)
		$('#forward').addClass("disabled")


changeCommit = (next) ->
	currentHash = window.currentHash
	currentIndex = hash_array.indexOf(window.currentHash)
	nextIndex = currentIndex + next
	nextHash = hash_array[nextIndex]
	if nextHash != undefined
		jumpTo(nextHash)

if window.location.hash
	jumpTo(window.location.hash.substring(1))
else
	jumpTo(hash_array[hash_array.length - 1])