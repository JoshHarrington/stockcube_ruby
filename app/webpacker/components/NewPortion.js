import React, { useState, useEffect } from 'react'
import Select from 'react-select'
import CreatableSelect from 'react-select/creatable'
import classNames from 'classnames'
import Icon from './Icon'
import { showAlert } from '../functions/utils'


function validateNumberField({value, updateValidStateFn, updateValidationMessage}) {
	if (value === '' || value <= 0) {
		updateValidStateFn(false)
		updateValidationMessage("Make sure that the amount is more than 0")
	} else {
		updateValidStateFn(true)
		updateValidationMessage(null)
	}
}

function validateSelectField({value, updateValidStateFn}) {
	if (value === null) {
		updateValidStateFn(false)
	} else {
		updateValidStateFn(true)
	}
}


function sendNewPortionRequest({
	recipeId,
	selectedIngredient,
	amount,
	selectedUnit,
	csrfToken,
	updateFormValidState,
	setSubmitText
}) {
	const data = {
		method: 'post',
    body: JSON.stringify({
			recipeId,
			ingredient: selectedIngredient.value,
			amount,
			unitId: selectedUnit.value,
			isNewIngredient: selectedIngredient.hasOwnProperty('__isNew__')
    }),
		headers: {
			'Content-Type': 'application/json',
			'X-CSRF-Token': csrfToken
		},
		credentials: 'same-origin'
	}

	if (selectedIngredient.hasOwnProperty('__isNew__')) {
		showAlert("Creating a new ingredient and adding your recipe portion now, this might take a minute")
	} else {
		showAlert("Adding your stock now")
	}

  fetch("/portions/new_recipe_portion", data).then((response) => {
		if(response.status === 200){
      return response.json();
		} else {
			showAlert('Something went wrong! Please try again')
			updateFormValidState(true)
			setSubmitText('Save')
			throw new Error('non-200 response status')
    }
  }).then(() => {
		window.location.href = `/recipes/${recipeId}/edit`
  });
}

function submitClick({
	selectedIngredient,
	amount,
	selectedUnit,
	updateFormValidState,
	updateIngredientValidState,
	updateAmountValidState,
	updateAmountValidationMessage,
	updateUnitValidState
}) {
	if (selectedIngredient === null || amount === '' || selectedUnit === null) {
		updateFormValidState(false)
	}

	validateSelectField({value: selectedIngredient, updateValidStateFn: updateIngredientValidState})
	validateSelectField({value: selectedUnit, updateValidStateFn: updateUnitValidState})
	validateNumberField({value: amount, updateValidStateFn: updateAmountValidState, updateValidationMessage: updateAmountValidationMessage})
}

const NewPortion = ({recipeId, recipeName, ingredients, units, csrfToken}) => {
	const [selectedIngredient, updateSelectedIngredient] = useState(null)
	const [selectedUnit, updateSelectedUnit] = useState(null)
	const [ingredientValidState, updateIngredientValidState] = useState(null)
	const [amountValidState, updateAmountValidState] = useState(null)
	const [amountValidationMessage, updateAmountValidationMessage] = useState("Make sure you've entered an amount")
	const [unitValidState, updateUnitValidState] = useState(null)

	const [formValidState, updateFormValidState] = useState(null)

	const [amount, setAmount] = useState('')

	useEffect(() => {
		if (ingredientValidState === false || amountValidState === false || unitValidState === false) {
			updateFormValidState(false)
		}
		if (ingredientValidState === true && amountValidState === true && unitValidState === true) {
			updateFormValidState(true)
		}
	}, [ingredientValidState, amountValidState, unitValidState])

	useEffect(() => {
		if (selectedIngredient !== null) {
			validateSelectField({value: selectedIngredient, updateValidStateFn: updateIngredientValidState})
		}
	}, [selectedIngredient])

	useEffect(() => {
		if (amount !== '') {
			validateNumberField({value: amount, updateValidStateFn: updateAmountValidState, updateValidationMessage: updateAmountValidationMessage})
		}
	}, [amount])

	useEffect(() => {
		if (selectedUnit !== null) {
			validateSelectField({value: selectedUnit, updateValidStateFn: updateUnitValidState})
		}
	}, [selectedUnit])

	const unitsFormatted = units.map(u => {
		const titleizedName = [...u.name].map((w, i) => i === 0 ? w[0].toUpperCase() : w).join('')
		return {value: u.id, label: titleizedName}
	})

	const ingredientsFormatted = ingredients.map(i => {
		return {value: i.id, label: i.name}
	})

	const [ingredientsSelectFocused, updateIngredientsSelectFocused] = useState(false)
	const [unitsSelectFocused, updateUnitsSelectFocused] = useState(false)

	const [submitText, setSubmitText] = useState('Save')

	return (
		<div className="standard-wrapper mt-16 mb-40">
			<a href={`/recipes/${recipeId}/edit`} className="flex mb-4 items-center hover:underline text-gray-600 hover:text-gray-800 transition duration-300"><Icon name="arrow_back" className="w-8 h-8 mr-2" />Back to recipe</a>
			<h1 className="bg-primary-300 px-6 py-6 text-2xl">Adding an ingredient to "{recipeName}"</h1>
			<div className="bg-primary-50 pt-6 px-6 pb-8">

				<h2 className="mb-1 text-xl">Pick your recipe ingredient</h2>
				<p className="mb-3 text-gray-700 text-base">... or create a new ingredient</p>
				<CreatableSelect
					className={classNames("w-full text-base", {"z-20": ingredientsSelectFocused})}
					value={selectedIngredient}
					placeholder="Select ingredient"
					isClearable
					onChange={updateSelectedIngredient}
					options={ingredientsFormatted}
					onBlur={() => {
						validateSelectField({value: selectedIngredient, updateValidStateFn: updateIngredientValidState})
						updateIngredientsSelectFocused(false)
					}}
					onFocus={() => {updateIngredientsSelectFocused(true)}}
				/>
				{ingredientValidState === false && <p className="text-red-600 mt-2 text-base">Make sure you've selected an ingredient</p>}
				<h2 className="mb-2 mt-4 text-xl">Set the amount</h2>
				<div className="flex flex-wrap md:flex-no-wrap mb-4">
					<div className="flex flex-wrap w-full md:w-1/2 md:mr-3 mb-3">
						<input
							type="number"
							className="w-full md:mb-0 text-base p-4 rounded-md border border-solid border-gray-400 h-16" placeholder="4" min={0}
							onChange={(e) => {
								setAmount(e.target.value)
							}}
							onBlur={() => {
								validateNumberField({value: amount, updateValidStateFn: updateAmountValidState, updateValidationMessage: updateAmountValidationMessage})
							}}
							value={amount}
						/>
						{amountValidState === false && <p className="text-red-600 mt-2 text-base w-full mb-4">{amountValidationMessage}</p>}
					</div>

					<div className="w-full md:w-1/2">
						<Select
							className={classNames("w-full text-base", {"z-20": unitsSelectFocused})}
							placeholder="Select unit"
							onChange={updateSelectedUnit}
							value={selectedUnit}
							options={unitsFormatted}
							onBlur={() => {
								validateSelectField({value: selectedUnit, updateValidStateFn: updateUnitValidState})
								updateUnitsSelectFocused(false)
							}}
							onFocus={() => {updateUnitsSelectFocused(true)}}
						/>
						{unitValidState === false && <p className="text-red-600 mt-2 text-base w-full mb-4">Make sure you've selected a unit</p>}
					</div>

				</div>

				<button
					disabled={formValidState === false}
					onClick={(e) => {
						e.preventDefault()
						if (formValidState !== true) {
							submitClick({
								selectedIngredient,
								amount,
								selectedUnit,
								updateFormValidState,
								updateIngredientValidState,
								updateAmountValidState,
								updateAmountValidationMessage,
								updateUnitValidState
							})
						} else {
							sendNewPortionRequest({
								recipeId,
								selectedIngredient,
								amount,
								selectedUnit,
								csrfToken,
								updateFormValidState,
								setSubmitText
							})
							updateFormValidState(false)
							setSubmitText('Saving...')
						}
					}}
					className={classNames("bg-white border border-solid border-primary-500 text-lg pt-4 pb-5 px-6 rounded", {"cursor-not-allowed opacity-50": formValidState === false})}
				>{submitText}</button>
			</div>
		</div>
	)
}

export default NewPortion
