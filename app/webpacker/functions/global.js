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
}

ready(globalFn)
