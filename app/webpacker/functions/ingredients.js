import { ready } from './utils'
import Choices from 'choices.js'

const WatchForAddNewSizeBtnClick = () => {
	const NewSizeBtn = document.querySelector('#new_size_button')
	const ClonedRows = document.querySelectorAll('.cloned_row')

	if (NewSizeBtn) {
		if (ClonedRows.length > 0) {
			const lastClonedRow = ClonedRows[ClonedRows.length - 1]
			lastClonedRowValue = lastClonedRow.querySelector('input[type="number"]').value
			if (lastClonedRowValue !== "" && lastClonedRowValue !== "0" ) {
				NewSizeBtn.addEventListener('click', InsertNewSizeRow, {once: true})
			}
		} else {
			NewSizeBtn.addEventListener('click', InsertNewSizeRow, {once: true})
		}
	}
}

const InsertNewSizeRow = (e) => {
	const NewSizeBtn = e.target
	DisableNewSizeBtn(NewSizeBtn)
	const RowForCloning = document.querySelector('.row_for_cloning')
	const NewSizeButtonRow = document.querySelector('.new_size_button_row')
	if (RowForCloning && NewSizeButtonRow) {
		const CloneRow = RowForCloning.cloneNode(true)

		CloneRow.classList.remove('row_for_cloning')
		CloneRow.classList.add('cloned_row')

		// CloneRow.getAttribute('data-id-start')

		const CloneRowSelect = CloneRow.querySelector('select')
		const choicesSelect = new Choices(CloneRowSelect, {
			classNames: {
				containerOuter: 'choices choices_select'
			}
		})

		CloneRow.style.display = 'flex'
		const SizesUL = RowForCloning.parentNode
		SizesUL.insertBefore(CloneRow, NewSizeButtonRow)
		WatchForInputNumberChange(CloneRow, NewSizeBtn)
	}
}

const DisableNewSizeBtn = (NewSizeBtn) => {
	NewSizeBtn.removeEventListener('click', InsertNewSizeRow, false)
	NewSizeBtn.style.borderColor = "#cccccc"
	NewSizeBtn.style.color = "#888888"
	NewSizeBtn.style.cursor = "not-allowed"
	NewSizeBtn.addEventListener('click', FocusLastClonedInput, false)
}

const WatchForInputNumberChange = (CloneRow, NewSizeBtn) => {
	CloneRow.querySelector('input[type="number"]').addEventListener('change', () => EnableNewSizeBtn(NewSizeBtn), {once: true})
}

const EnableNewSizeBtn = (NewSizeBtn) => {
	NewSizeBtn.addEventListener('click', InsertNewSizeRow, {once: true})
	NewSizeBtn.style.borderColor = "#93dbd7"
	NewSizeBtn.style.color = "black"
	NewSizeBtn.style.cursor = "pointer"
	NewSizeBtn.removeEventListener('click', FocusLastClonedInput, false)
}

const FocusLastClonedInput = () => {
	const ClonedRows = document.querySelectorAll('.cloned_row')
	if (ClonedRows.length > 0) {
		const lastClonedRow = ClonedRows[ClonedRows.length - 1]
		const lastClonedRowInput = lastClonedRow.querySelector('input[type="number"]')
		const lastClonedRowValue = lastClonedRowInput.value
		if (lastClonedRowValue === "" || lastClonedRowValue === "0" ) {
			lastClonedRowInput.focus()
		}
	}
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

const IngredientsFn = () => {
	// DateUpdate()
	WatchForAddNewSizeBtnClick()
}

ready(IngredientsFn)
