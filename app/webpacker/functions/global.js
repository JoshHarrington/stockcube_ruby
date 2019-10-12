import Choices from 'choices.js'
import { ready, ajaxRequest } from './utils'

const globalFn = () => {
	ajaxRequest('Update Stock', '/recipes/update_matches');
	const selectEl = document.querySelectorAll('select.choices--basis')
	if (selectEl){
		selectEl.forEach(function(select){
			const choicesSelect = new Choices(select, {
				classNames: {
					containerOuter: 'choices choices_select'
				}
			})
		})
	}
	catchDataConfirmAttrs()
}

const catchDataConfirmAttrs = () => {
	const ConfirmActions = document.querySelectorAll('*[data-confirm]')
	if (ConfirmActions.length > 0) {
		ConfirmActions.forEach((action) => {
			const actionMessage = action.getAttribute('data-confirm')
			action.addEventListener('click', (e) => {
				const confirmResult = confirm(actionMessage);
				if (!confirmResult) {
					e.preventDefault()
				}
			})
		})
	}
}


ready(globalFn)
