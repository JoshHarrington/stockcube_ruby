import {ready, showAlert, isSelectorValid} from './utils'


const togglePubStatusRowFade = (event) => {
	var publicStatusRow = document.querySelector('#recipe_public_status_row');
	publicStatusRow.classList.toggle('faded_out')
}

const setPublicRowFadeStatus = () => {

	document.querySelectorAll('#recipe_live_status_row input[type="radio"]').forEach((btn) => {
		btn.addEventListener('click', togglePubStatusRowFade)
	})
}

const deletePortion = (event) => {
	event.preventDefault()
	const portionDeleteBtn = event.target
	const portionId = portionDeleteBtn.dataset.portionId
	console.log(portionDeleteBtn, portionId)
	const portionRow = portionDeleteBtn.closest('li')
	if (window.confirm("Sure that you want to delete that ingredient?")) {

		const data = {
			method: 'post',
			body: JSON.stringify({
				"portion_id": portionId
			}),
			headers: {
				'Content-Type': 'application/json',
				'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
			},
			credentials: 'same-origin'
		}

		portionRow.classList.add('hidden')

		fetch("/recipes/portion_delete", data).then((response) => {
			if(response.status === 200){
				return response.json();
			} else {
				window.alert('Something went wrong! Maybe refresh the page and try again')
				portionRow.classList.remove('hidden')
				throw new Error('non-200 response status')
			}
		}).then((jsonResponse) => {
			showAlert("Portion deleted from recipe")
		})

	}
}

const confirmDeleteIngredient = () => {
	document.querySelectorAll('[data-js-action="delete_ingredient"]').forEach((deleteBtn) => {
		deleteBtn.addEventListener('click', deletePortion)
	})
}

const hashFocus = (hash = null) => {
	if (hash !== null || window.location.hash) {
		const hashString = hash !== null ? hash : window.location.hash
		const targetElString = `${hashString} input, ${hashString} textarea`
		if (isSelectorValid(targetElString) && document.querySelector(targetElString)) {
			document.querySelector(targetElString).focus()
		}
	}
}

const publishableParts = {
	title: false,
	steps: false,
	cook_time: false,
	portions: false
}

const humanPublishablePart = {
	title: {
		text: "a title",
		href: "#recipe_title_container"
	},
	steps: {
		text: "some steps",
		href: "#recipe_steps_wrapper"
	},
	cook_time: {
		text: "a cook time",
		href: "#recipe_cook_time_container"
	},
	portions: {
		text: "some ingredients",
		href: "#recipe_ingredients_list"
	}
}

const publishableState = {
	publishable: false
}

const updatePublishableSteps = () => {
	const steps = document.querySelectorAll('#recipe_steps_wrapper textarea')
	publishableParts.steps = false
	for(let i = 0; i < steps.length; i++) {
		if (steps[i].value !== '') {
			publishableParts.steps = true
			break
		}
	}
}

const updatePublishableTitle = () => {
	if (document.querySelector('#recipe_title_container input').value !== '') {
		publishableParts.title = true
	} else {
		publishableParts.title = false
	}
}

const updatePublishableCookTime = () => {
	if (document.querySelector('#recipe_cook_time').value !== '') {
		publishableParts.cook_time = true
	} else {
		publishableParts.cook_time = false
	}
}

const updatePublishablePortions = () => {
	if (document.querySelectorAll('#recipe_ingredients_list .ingredient_row:not(.delete_state)').length !== 0) {
		publishableParts.portions = true
	} else {
		publishableParts.portions = false
	}
}

const updatePublishable = (part = '', first = false) => {
	let partType = null
	switch(part) {
		case part === document.querySelector('#recipe_steps_wrapper'):
			partType = 'title'
		case part === document.querySelector('#recipe_title_container input'):
			partType = 'steps'
		case part === document.querySelector('#recipe_cook_time'):
			partType = 'cook_time'
		case part === document.querySelector('#recipe_ingredients_list .ingredient_row'):
			partType = 'portions'
	}
	const previousPubParts = Object.assign({}, publishableParts)

	switch(partType) {
		case 'title':
			updatePublishableTitle()
		case 'steps':
			updatePublishableSteps()
		case 'cook_time':
			updatePublishableCookTime()
		case 'portions':
			updatePublishablePortions()
		default:
			updatePublishableTitle()
			updatePublishableSteps()
			updatePublishableCookTime()
			updatePublishablePortions()
	}

	if (previousPubParts !== publishableParts || first !== false) {
		updatePublishableState()
	}

}

const outputExplainerLink = (part) => {
	return `<a href="${part["href"]}">${part["text"]}</a>`
}

const nonPublishableExplainerText = () => {
	const partsToAdd = []
	for(var part in publishableParts) {
		if(publishableParts[part] === false) {
			partsToAdd.push(outputExplainerLink(humanPublishablePart[part]))
		}
	}
	if (partsToAdd.length === 1) {
		return partsToAdd[0]
	} else if (partsToAdd.length > 1) {
		return partsToAdd.slice(0, partsToAdd.length - 1).join(', ') + ' and ' + partsToAdd[partsToAdd.length - 1]
	}
}

const updatePublishableState = () => {
	const publishOptions = document.querySelector('#publish_options')
	const publishBtns = publishOptions.querySelector('#publish_options input')
	for(var part in publishableParts) {
		if(publishableParts[part] === false) {
			publishableState.publishable = false
			publishOptions.classList.add('faded_out')
			const alertMessage = 'Recipe is not currently publishable, you need to add ' + nonPublishableExplainerText()
			if (alertMessage !== window.publishableAlertMessage) {
				showAlert(alertMessage, 15000)
				window.publishableAlertMessage = alertMessage
			}
			return false
		}
	}
	if (publishableState.publishable !== true) {
		publishableState.publishable = true
		publishOptions.classList.remove('faded_out')
		const alertMessage = 'Recipe is now publishable!'
		if (alertMessage !== window.publishableAlertMessage) {
			showAlert(alertMessage)
			window.publishableAlertMessage = alertMessage
		}
	}
}


const makePublishableOnChange = () => {
	updatePublishable(null, true)

	const elementsToWatch = document.querySelectorAll('#recipe_steps_wrapper, #recipe_title_container input, #recipe_cook_time, #recipe_ingredients_list .ingredient_row')
	elementsToWatch.forEach((el) => {
		el.addEventListener('change', updatePublishable)
	})
}


const submitClicked = () => {
	document.querySelector('input[type="submit"]').addEventListener('click', scrollAndFocusTitle)
}

var scrollAndFocusTitle = () => {
	if (document.querySelector('#recipe_title').value === "") {
		document.querySelector('#recipe_title_container').scrollIntoView({
			behavior: 'smooth'
		});
		document.querySelector('#recipe_title').focus();
	}
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
		Textarea.classList.add('min-w-full','border', 'border-solid', 'border-gray-600', 'rounded', 'p-2')
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
	if (!!document.querySelector('#recipe_edit')){
		// beforeUnload();
		confirmDeleteIngredient();
		setPublicRowFadeStatus();
		hashFocus();
		makePublishableOnChange();
		submitClicked();
		addNextStep()
		deleteLastStep()
	}
}

ready(recipeFn)

