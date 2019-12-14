import { ready } from './utils'

const IngredientsFn = () => {
	// DateUpdate()
}

const DateUpdate = () => {
	const ShowButtons = document.querySelectorAll('#show_next_form')
	if (ShowButtons.length > 0) {
		ShowButtons.forEach((button) => {
			button.addEventListener('click', (e) => {
				if (button.parentElement.nextElementSibling.matches('form')) {
					button.parentElement.nextElementSibling.style.display = 'block'
				}
			})
		})
	}
}

ready(IngredientsFn)
