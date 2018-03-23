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
			changeMonth: true
			changeYear: true
		previousDate = undefined
		$('input[type="date"]').focus ->
			previousDate = $(this).val()
			return
		$('input[type="date"]').blur ->
			newDate = $(this).val()
			if !moment(newDate, 'yy-mm-dd', true).isValid()
				$(this).val previousDate
				console.log 'Error'
			return
		$('input[type="date"]').on 'keyup', (e) ->
			if e.keyCode == 13
				$(this).trigger('focusout')
				return false
			return
	else
		$('html').addClass('input-type-date-supported')
return