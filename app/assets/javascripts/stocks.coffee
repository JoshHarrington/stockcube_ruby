# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$ ->
	if (!Modernizr.input.list)
		$('html').removeClass('input-list-supported').addClass('input-list-not-supported')
	if (!Modernizr.inputtypes.date)
		$('html').addClass('input-type-date-not-supported')
		$('input[type="date"]').datepicker 
			dateFormat: 'yy-mm-dd'
			minDate: new Date()
	else
		$('html').addClass('input-type-date-supported')
return