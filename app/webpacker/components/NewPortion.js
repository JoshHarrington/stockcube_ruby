import React, { useState, useEffect } from 'react'
import Select from 'react-select'
import CreatableSelect from 'react-select/creatable'
import classNames from 'classnames'


function validateNumberField({value, updateValidStateFn, updateValidationMessage}) {
	if (value === '' || value <= 0) {
		updateValidStateFn(false)
		updateValidationMessage("Make sure that the amount is more than 0")
	} else {
		updateValidStateFn(true)
		updateValidationMessage(null)
	}
}

function sendNewPortionRequest({recipeId, selectedIngredient, amount, selectedUnit, csrfToken}) {
	const data = {
		method: 'post',
    body: JSON.stringify({
			recipeId,
			ingredient: selectedIngredient.value,
			amount,
			unit: selectedUnit.value
    }),
		headers: {
			'Content-Type': 'application/json',
			'X-CSRF-Token': csrfToken
		},
		credentials: 'same-origin'
	}

	console.log(recipeId, selectedIngredient.value, amount, selectedUnit.value)

  // fetch("/portion/new_recipe_portion", data).then((response) => {
	// 	if(response.status === 200){
  //     return response.json();
	// 	} else if(response.status !== 202) {
	// 		window.alert('Something went wrong! Maybe refresh the page and try again')
	// 		throw new Error('non-200 response status')
  //   }
  // }).then((jsonResponse) => {
	// 	window.location.href = `/recipes/${recipeId}/edit`
	// 	showAlert(`Cupboard name updated to: "${jsonResponse.cupboardLocation}"`)
  // });
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
		if (selectedUnit !== null) {
			updateUnitValidState(true)
		}
	}, [selectedUnit])

	useEffect(() => {
		if (selectedIngredient !== null) {
			updateIngredientValidState(true)
		}
	}, [selectedIngredient])

	const unitsFormatted = units.map(u => {
		const titleizedName = [...u.name].map((w, i) => i === 0 ? w[0].toUpperCase() : w).join('')
		return {value: u.name, label: titleizedName}
	})

	const ingredientsFormatted = ingredients.map(i => {
		return {value: i.id, label: i.name}
	})

	return (
		<div className="standard-wrapper">
			<h1 className="bg-primary-300 px-5 py-6 text-2xl">Adding an ingredient to "{recipeName}"</h1>
			<div className="bg-primary-50 p-5">

				<h2 className="mb-2 text-xl">Pick your Ingredient</h2>
				<CreatableSelect
					className="text-base"
					value={selectedIngredient}
					isClearable
					onChange={updateSelectedIngredient}
					options={ingredientsFormatted}
					onBlur={() => {
						if (selectedIngredient === null) {
							updateIngredientValidState(false)
						} else {
							updateIngredientValidState(true)
						}
					}}
				/>
				{ingredientValidState === false && <p className="text-red-600 mt-2 text-base">Make sure you've selected an ingredient</p>}
				<h2 className="mb-2 mt-4 text-xl">Set the amount</h2>
				<div className="flex flex-wrap md:flex-no-wrap mb-4">
					<div className="flex flex-wrap w-full md:w-1/2 md:mr-3 mb-3">
						<input
							type="number"
							className="w-full md:mb-0 text-base p-4 rounded border border-solid border-gray-400" placeholder="4" min={0}
							onChange={(e) => {
								setAmount(e.target.value)
								validateNumberField({value: e.target.value, updateValidStateFn: updateAmountValidState, updateValidationMessage: updateAmountValidationMessage})
							}}
							value={amount}
							/>
						{amountValidState === false && <p className="text-red-600 mt-2 text-base w-full mb-4">{amountValidationMessage}</p>}
					</div>

					<div className="w-full md:w-1/2">
						<Select
							className="w-full text-base"
							onChange={updateSelectedUnit}
							value={selectedUnit}
							options={unitsFormatted}
						/>
						{unitValidState === false && <p className="text-red-600 mt-2 text-base w-full mb-4">Make sure you've selected a unit</p>}
					</div>

				</div>

				<button
					disabled={formValidState === false}
					onClick={(e) => {
						e.preventDefault()
						if (formValidState !== true) {
							updateFormValidState(false)
							updateIngredientValidState(false)
							updateAmountValidState(false)
							updateUnitValidState(false)
						} else {
							sendNewPortionRequest({recipeId, selectedIngredient, amount, selectedUnit, csrfToken})
						}
					}}
					className={classNames("bg-white border border-solid border-primary-500 text-base p-4 rounded", {"cursor-not-allowed": formValidState === false})}
				>Save</button>
			</div>
		</div>
	)
}

export default NewPortion
