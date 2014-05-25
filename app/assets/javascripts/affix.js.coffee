(exports ? this).handleResize = ->
	sideBarNavWidth = $('#sidebar').width() - parseInt($('#options').css('paddingLeft')) - parseInt($('#options').css('paddingRight'))
	$('#options').css('width', sideBarNavWidth);

handleResize()
$(window).resize ->
	handleResize()