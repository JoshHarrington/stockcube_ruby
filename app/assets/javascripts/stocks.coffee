# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$ ->
	if (!Modernizr.input.list)
		$('html').removeClass('input-list-supported').addClass('input-list-not-supported')
		# 	to do:
		# 	when ingredient select blur check whether ingredient is volume / mass / other
		# 	show a unit selection tailored to ingredient type
		# else
		# 	when ingredient input list blur check whether ingredient is volume / mass / other
		# 	show a unit selection tailored to ingredient type
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
	if $('#stock-form[method="post"]')
		do ->
			empty = false
			$('#stock-form input').each ->
				if $(this).val() == ''
					empty = true
				return
			if empty
				$('input[type="submit"]').attr 'disabled', 'disabled'
		$('#stock-form input').on 'keyup blur', (e) ->
			empty = false
			$('#stock-form input').each ->
				if $(this).val() == ''
					empty = true
				return
			if empty
				$('input[type="submit"]').attr 'disabled', 'disabled'
				$(this).siblings('.message-special').removeAttr 'hidden'
			else
				$('input[type="submit"]').removeAttr 'disabled'
		$('#stock-form input').on 'keyup blur', (e) ->
			if $(this).val() != ''
				$(this).siblings('.message-special').attr 'hidden', 'hidden'

return