import {ready, showAlert} from './utils'

var togglePublicRowFade = function() {
	var publicStatusRow = $('#recipe_public_status_row');
	var publicStatusBtns = $('#recipe_public_status_row input');
	$('#recipe_live_status_row input[type="radio"]').click(function(e){
		if (e.target == $('#live_radio_1')[0]) {
			publicStatusRow.removeClass('faded_out');
			publicStatusBtns.prop('disabled', false);
		} else {
			publicStatusRow.addClass('faded_out');
			publicStatusBtns.prop('disabled', true);
		}
	})
}

var confirmDeleteIngredient = function(){
	$('.ingredient_row label').click(function (e) {
		console.log('label clicked');
		var deleteStateClass = 'delete_state';
		var $this = $(this);
		var el = e.target;
		var ingredientRow = el.parentNode;
		if (ingredientRow.classList) {
			ingredientRow.classList.add(deleteStateClass);
		} else {
			ingredientRow.className += ' ' + deleteStateClass;
		}
		window.setTimeout(function(){confirmFunc($this, ingredientRow, deleteStateClass)},12);
	});
}

var confirmFunc = function($this, ingredientRow, deleteStateClass){
	if (window.confirm("Sure that you want to delete that ingredient?")) {
		if (ingredientRow.classList) {
			ingredientRow.classList.add('slide_up');
		} else {
			ingredientRow.className += ' slide_up';
		}
	} else {
		if (ingredientRow.classList) {
			ingredientRow.classList.remove(deleteStateClass);
		} else {
			ingredientRow.className = ingredientRow.className.replace(deleteStateClass, '');
		}
		$this.siblings('input[type="checkbox"]').prop('checked', false);
	}
}

var hashFocus = function() {
	if(window.location.hash) {
		hash = window.location.hash;
		targetElString = hash + ' input, ' + hash + ' textarea';
		document.querySelectorAll(targetElString)[0].focus();
	}
}

var makePublishableOnChange = function() {
	var publishOptions = $('#publish_options');
	var publishBtns = $('#publish_options input');
	$('#recipe_description, #recipe_title_container input, #recipe_cook_time, #recipe_ingredients_list .ingredient_row').change(function(){
		if(!($('#recipe_description').val() == '' || $('#recipe_title_container input').val() == '' || $('#recipe_cook_time').val() == '' || $('#recipe_ingredients_list .ingredient_row:not(".delete_state")').length == 0)) {
			console.log('Y: recipe can be saved');
			publishOptions.removeClass('faded_out');
			publishBtns.prop('disabled', false);
		} else {
			publishOptions.addClass('faded_out')
			publishBtns.prop('disabled', true);
		}
	})
}


var submitClicked = function(){
	$('input[type="submit"]').click(function(){
		if($('#recipe_title').val() == ''){
			scrollAndFocusTitle();
		}
	});
}

var scrollAndFocusTitle = function(){
	document.querySelector('#recipe_title_container').scrollIntoView({
		behavior: 'smooth'
	});
	document.querySelector('#recipe_title').focus();
}


// var beforeUnload = function() {
// 	window.onbeforeunload = function(e) {
// 		var dialogText = 'Unsaved changes';
// 		e.returnValue = dialogText;
// 		return dialogText;
// 	};
// }

const stepListener = (e) => {
	const el = e.target.parentNode
	if (el.previousElementSibling === null || (el.previousElementSibling !== null && el.previousElementSibling.querySelector('textarea') && el.previousElementSibling.querySelector('textarea').value !== '' )){

		const newStep = document.createElement('li')

		const Textarea = document.createElement('textarea')
		Textarea.setAttribute('name', 'new_recipe_steps[]')
		Textarea.setAttribute('rows', '2')
		Textarea.style.minHeight = '70px'
		Textarea.style.minWidth = '100%'
		Textarea.setAttribute('placeholder', 'The next step to make this meal')

		newStep.appendChild(Textarea)

		if (el.parentElement.className === 'ol') {
			el.parentNode.insertBefore(newStep, el)
		} else {
			el.parentElement.parentElement.querySelector('ol.ol').insertBefore(newStep, el)
		}

		newStep.querySelector('textarea').focus()
	} else if (el.previousElementSibling.classList.contains('hidden') || el.previousElementSibling.style.display === 'none') {
		el.previousElementSibling.classList.remove('hidden')
		el.previousElementSibling.style.display = 'list-item'
	} else {
		e.preventDefault()
		console.log(el.previousElementSibling != null , "el.previousElementSibling != null ")
		console.log(el.previousElementSibling.querySelector('textarea') , "el.previousElementSibling.querySelector('textarea') ")
		console.log(el.previousElementSibling.querySelector('textarea').value !== '' , "el.previousElementSibling.querySelector('textarea').value !== '' ")
		showAlert('Make sure you\'ve filled in the previous step before moving on!')
	}
	const deleteLastStepEl = document.querySelector('.delete_last_step')
	if (deleteLastStepEl && deleteLastStepEl.style.display === 'none'){
		deleteLastStepEl.style.display = 'block'
	}
}

const addNextStep = () => {
	const addNewStep = document.querySelector('.add_next_step')
	if (addNewStep){
		addNewStep.addEventListener('click', stepListener)
	}
}

const deleteLastStepFn = (e) => {
	const el = e.target.parentNode
	const numOfShownLis = el.parentNode.querySelectorAll('li:not(.hidden)').length
	const lastLi = el.parentNode.querySelectorAll('li:not(.hidden)')[numOfShownLis - 1]
	if (lastLi !== null && numOfShownLis > 1) {
		lastLi.style.display = 'none'
		lastLi.classList.add('hidden')
		if (lastLi.querySelector('textarea') && lastLi.querySelector('textarea').value !== ''){
			lastLi.querySelector('textarea').innerText = ''
		}
		if (numOfShownLis === 2) {
			e.target.style.display = 'none'
		}
	} else {
		showAlert('You need at least one recipe step')
	}
}

const deleteLastStep = () => {
	const deleteLastStepEl = document.querySelector('.delete_last_step')
	if (deleteLastStepEl){
		deleteLastStepEl.addEventListener('click', deleteLastStepFn)
	}
}

const recipeFn = () => {
	if (document.querySelector('#recipe_edit')){
		// beforeUnload();
		confirmDeleteIngredient();
		togglePublicRowFade();
		hashFocus();
		makePublishableOnChange();
		submitClicked();
		addNextStep()
		deleteLastStep()
	}
}

ready(recipeFn)

