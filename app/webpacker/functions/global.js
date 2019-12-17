import Choices from 'choices.js'
import { ready, ajaxRequest } from './utils'

const globalFn = () => {
	if (window["user_signed_in?"]) {
		ajaxRequest('Update Stock', '/recipes/update_matches');
	}
	const selectEl = document.querySelectorAll('select.choices--basis')
	if (selectEl){
		selectEl.forEach((select) => {
			const prompt = select.querySelector('option[value=""]')
			if (prompt !== null) {
				prompt.setAttribute('disabled', true)
			}

			const choicesSelect = new Choices(select, {
				classNames: {
					containerOuter: 'choices choices_select'
				}
			})
		})
		onSearchShowIngredientInputSwitch()
	}
	catchDataConfirmAttrs()
}


const onSearchShowIngredientInputSwitch = () => {
	if (document.body.classList.contains('stocks_controller','custom_new_page')) {
		if (document.querySelector('select#stock_ingredient_id') !== null) {
			document.querySelector('select#stock_ingredient_id').addEventListener('search', setupIngredientInputSwitch, false)
		}
	}
}


const setupIngredientInputSwitch = () => {
	document.querySelector('select#stock_ingredient_id').removeEventListener('search', setupIngredientInputSwitch, false)
	window.setTimeout(() => {
		const customIngredientButton = document.querySelector('#add_custom_ingredient')
		customIngredientButton.style.display = "inline-block"
		customIngredientButton.addEventListener('click', () => {
			switchIngredientInput()
		})
	}, 600)
}


const switchIngredientInput = () => {
	const IngredientNameInput = document.createElement('input')
	IngredientNameInput.setAttribute('id', 'stock_ingredient_id')
	IngredientNameInput.setAttribute('name', 'stock[ingredient_id]')
	IngredientNameInput.setAttribute('placeholder', 'Your own ingredient')
	IngredientNameInput.style.width = "100%"
	IngredientNameInput.style.height = "3.6rem"
	IngredientNameInput.style.padding = ".5rem .7rem"

	const stockIngredientIdSelect = document.querySelector('select#stock_ingredient_id')
	const choicesStockIngredientSelect = stockIngredientIdSelect.closest('.choices.choices_select')
	const stockIngredientLabel = document.querySelector('label[for="stock_ingredient_id"]')
	const stockIngredientSelectParent = stockIngredientLabel.closest('.item_form--content_row')

	stockIngredientLabel.innerHTML = '<strike>Pick an ingredient</strike> <span>Add a new ingredient<span>'

	insertIngredientInput(stockIngredientSelectParent, IngredientNameInput, choicesStockIngredientSelect)
	deleteIngredientChoicesSelect(choicesStockIngredientSelect, stockIngredientIdSelect)

}

const insertIngredientInput = (stockIngredientSelectParent, IngredientNameInput, choicesStockIngredientSelect) => {
	if (document.querySelector('input#stock_ingredient_id') === null) {
		stockIngredientSelectParent.insertBefore(IngredientNameInput, choicesStockIngredientSelect)
	} else {
		ingredientInputInserted = true
	}
}

const deleteIngredientChoicesSelect = (choicesStockIngredientSelect, stockIngredientIdSelect) => {
	if (document.querySelector('select#stock_ingredient_id') !== null) {
		choicesStockIngredientSelect.remove()
		stockIngredientIdSelect.remove()

		const customIngredientButton = document.querySelector('#add_custom_ingredient')
		customIngredientButton.removeEventListener('click', () => {switchIngredientInput()})
		customIngredientButton.remove()
	}
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
