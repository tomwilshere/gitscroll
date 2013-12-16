# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#Initialisers
$(document).ready ->
	# hljs.initHighlightingOnLoad()
	prettyPrint(highlightLines)
	setButtonStates(hash_array.indexOf(window.currentHash))
	createTimeline()

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
	if additions_array != undefined
		for commitAdditions, i in additions_array
			hash = hash_array[i]
			lineArray = $('#' + hash + ' ol').children().toArray()
			if commitAdditions
				for addition in commitAdditions
					location = addition.location
					length = addition.length
					if length > 0
						for line in [location..location + length - 1]
							$(lineArray[line - 1]).addClass("addition")
					else if length == 0
						$(lineArray[location-1]).addClass("change")
					else
						$(lineArray[location-2]).addClass("deletion")
		$('.code-block').removeClass("loading",2000)

back = ->
	changeCommit -1

forward = ->
	changeCommit 1

jumpTo = (nextHash, fireTimelineEvent) ->
	console.log "fireTimelineEvent " + fireTimelineEvent
	nextIndex = hash_array.indexOf(nextHash)
	currentHash = window.currentHash
	if nextHash
		$('#' + currentHash).toggleClass("hidden")
		$('#' + nextHash).toggleClass("hidden")
		window.currentHash = nextHash
		console.log "jumpTo " + window.currentHash
		if fireTimelineEvent
			clickTimelineMarker(nextHash)
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
	jumpTo(nextHash, true)

createTimeline = ->
	createStoryJS({
		type: 'timeline',
		width: 'auto',
		height: '220',
		source: timeline_object,
		embed_id: 'timeline'
	})
	$('.marker').click (disable) ->
		if !disable
			jumpTo(this.className.split(" ")[1])

clickTimelineMarker = (hash) ->
	console.log "clickTimelineMarker" + hash
	$('.marker.' + hash).click(true)