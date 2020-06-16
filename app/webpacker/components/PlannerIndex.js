import React, {useState, useEffect} from "react"

import {
	ShoppingListWrapper,
	ShoppingListButton,
	ShoppingListTopBanner,
	ShoppingListBottomBanner,
	PortionWrapper,
	PortionItem
} from "./ShoppingListComponents"
import PlannerRecipeList from "./PlannerRecipeList"
import RecipeItem from "./RecipeItem"
import TooltipWrapper from "./TooltipWrapper"
import Icon from "./Icon"
import { showAlert, switchShoppingListClass } from "../functions/utils"
import Dnd from "./DnDCalendar"

function addRecipeToPlanner(
	encodedId,
	csrfToken,
	updatePlannerRecipes,
	updateSuggestedRecipes,
	updateCheckedPortionCount,
	updateTotalPortionCount,
	updateShoppingListPortions,
	updateToggleButtonShow
) {

	const data = {
		method: 'post',
    body: JSON.stringify({
      "recipe_id": encodedId
    }),
		headers: {
			'Content-Type': 'application/json',
			'X-CSRF-Token': csrfToken
		},
		credentials: 'same-origin'
  }

	showAlert("Adding recipe to your planner")

  fetch("/planner/recipe_add", data).then((response) => {
		if(response.status === 200){
      return response.json();
		} else {
			window.alert('Something went wrong! Maybe refresh the page and try again')
			throw new Error('non-200 response status')
    }
  }).then((jsonResponse) => {
		updatePlannerRecipes(jsonResponse["plannerRecipes"])
		updateSuggestedRecipes(jsonResponse["suggestedRecipes"])
		updateCheckedPortionCount(jsonResponse["checkedPortionCount"])
		updateTotalPortionCount(jsonResponse["totalPortionCount"])
		updateShoppingListPortions(jsonResponse["shoppingListPortions"])

		showAlert("Recipe added to your planner")
  });

}


function recipeDetailsRefresh(
	csrfToken,
	updateSuggestedRecipes,
	updateCheckedPortionCount,
	updateTotalPortionCount,
	updateShoppingListPortions
) {
	const data = {
		method: 'post',
		headers: {
			'Content-Type': 'application/json',
			'X-CSRF-Token': csrfToken
		},
		credentials: 'same-origin'
  }

	showAlert("Updating planner details")

  fetch("/planner", data).then((response) => {
    if(response.status === 200){
      return response.json();
		} else {
			window.alert('Something went wrong! Maybe refresh the page and try again')
			throw new Error('non-200 response status')
    }
  }).then((jsonResponse) => {
		console.log("jsonResponse", jsonResponse)
		updateSuggestedRecipes(jsonResponse.suggestedRecipes)
		updateCheckedPortionCount(jsonResponse.checkedPortionCount)
		updateTotalPortionCount(jsonResponse.totalPortionCount)
		updateShoppingListPortions(jsonResponse.shoppingListPortions)

		showAlert("Planner details updated")
  })
}




function PlannerIndex(props) {
  const [checkedPortionCount, updateCheckedPortionCount] = useState(props.checkedPortionCount)
  const [totalPortionCount, updateTotalPortionCount] = useState(props.totalPortionCount)
  const [shoppingListPortions, updateShoppingListPortions] = useState(props.shoppingListPortions)
  const {sharePath, csrfToken, mailtoHrefContent, onListPage} = props

  const totalPortionsPositive = !!(totalPortionCount && totalPortionCount !== 0)

	const [plannerRecipes, updatePlannerRecipes] = useState(props.plannerRecipes)
	const [suggestedRecipes, updateSuggestedRecipes] = useState(props.suggestedRecipes)

  const [toggleButtonShow, updateToggleButtonShow] = useState(totalPortionsPositive)
	const [shoppingListShown, toggleShoppingListShow] = useState(false)
	// const [shoppingListLoaded, toggleShoppingListLoaded] = useState(false)

	useEffect(() => {
		if (!!totalPortionCount && totalPortionCount > 0) {
			toggleShoppingListShow(true)
			switchShoppingListClass(true)
			updateToggleButtonShow(true)
		} else {
			toggleShoppingListShow(false)
			switchShoppingListClass(false)
			updateToggleButtonShow(false)
		}
	}, [totalPortionCount])

	const [shoppingListComplete, updateShoppingListComplete] = useState(!!(checkedPortionCount === totalPortionCount))
	useEffect(() => {
		if (checkedPortionCount === totalPortionCount) {
			updateShoppingListComplete(true)
		} else {
			updateShoppingListComplete(false)
		}
	}, [checkedPortionCount, totalPortionCount])

	const eventsSetup = plannerRecipes.map(recipe => (
		{
			id: recipe.encodedId,
			title: recipe.plannerRecipe.title,
			start: new Date(recipe.date),
			end: new Date(recipe.date),
			allDay: true
		}
	))
	const [events, updateEvents] = useState(eventsSetup)

  useEffect(() => {
		updateEvents(
      plannerRecipes.map(recipe => (
        {
          id: recipe.encodedId,
          title: recipe.plannerRecipe.title,
          start: new Date(recipe.date),
          end: new Date(recipe.date),
          allDay: true
        }
      ))
    )
	}, [plannerRecipes])

  return (
		<main>
			<PlannerRecipeList>
				{suggestedRecipes.map((recipe, index) => {
						const {encodedId, title, percentInCupboards, path, stockInfoNote} = recipe
						return (
							<RecipeItem key={index} encodedId={encodedId}>
								<TooltipWrapper width={48} text={stockInfoNote} className="top-0 left-0 flex-shrink-0 mb-2 bg-primary-100 w-full rounded-t-sm h-4">
									<span className="block h-full rounded-tl-sm bg-primary-600" style={{width: `${percentInCupboards}%`}}></span>
								</TooltipWrapper>
								<div className="flex w-full px-3 justify-between">
									<a href={path}>{title}</a>
									<TooltipWrapper text="Add to planner" width={24}>
										<button
											name="button" type="submit"
											className="p-2 mb-1 ml-2 w-10 h-10 bg-white rounded-sm flex-shrink-0 flex" title="Add this recipe to your planner"
											data-recipe-id={encodedId} data-type="add-to-planner"
											onClick={() => addRecipeToPlanner(
												encodedId,
												csrfToken,
												updatePlannerRecipes,
												updateSuggestedRecipes,
												updateCheckedPortionCount,
												updateTotalPortionCount,
												updateShoppingListPortions,
												updateToggleButtonShow
											)}>
											<Icon name="list-add" className="w-full h-full" />
										</button>
									</TooltipWrapper>
								</div>
							</RecipeItem>
						)
					})}
			</PlannerRecipeList>
			<div className="h-screen px-6 mt-3">
				<Dnd
					updatePlannerRecipes={updatePlannerRecipes}
					updateSuggestedRecipes={updateSuggestedRecipes}
					updateCheckedPortionCount={updateCheckedPortionCount}
					updateTotalPortionCount={updateTotalPortionCount}
					updateShoppingListPortions={updateShoppingListPortions}
					csrfToken={csrfToken}
					events={events}
					updateEvents={updateEvents}
				/>
			</div>
			<ShoppingListWrapper shoppingListShown={shoppingListShown}>
				{toggleButtonShow &&
					<ShoppingListButton
						switchShoppingListClass={switchShoppingListClass}
						shoppingListShown={shoppingListShown}
						toggleShoppingListShow={toggleShoppingListShow}
						checkedPortionCount={checkedPortionCount}
						totalPortionCount={totalPortionCount}
					/>
				}
				<ShoppingListTopBanner
					totalPortionsPositive={totalPortionsPositive}
					checkedPortionCount={checkedPortionCount}
					totalPortionCount={totalPortionCount}
					sharePath={sharePath}
					mailtoHrefContent={mailtoHrefContent}
					onListPage={onListPage}
				/>
				<PortionWrapper shoppingListComplete={shoppingListComplete}>
					{/* {!shoppingListLoaded && <div className="h-screen relative bg-white">Loading...</div>} */}
					{!totalPortionsPositive && <p>Shopping List is currently empty, move some recipes to <a href="/planner" className="underline">your planner</a> to get items added to this list</p>}
					{!!(totalPortionsPositive && !shoppingListComplete) &&
						<>
							{shoppingListPortions.map((portion, index) => (
								<PortionItem
									key={index}
									checked={portion.checked}
									portion={portion}
									csrfToken={csrfToken}
									updateShoppingListPortions={updateShoppingListPortions}
									updateShoppingListComplete={updateShoppingListComplete}
									updateCheckedPortionCount={updateCheckedPortionCount}
									updateTotalPortionCount={updateTotalPortionCount}
								/>
							))}
							{checkedPortionCount > 0 &&
								<li className="order-2 text-base pt-6 border-0 border-t border-solid border-gray-300 text-gray-600 mb-6">
									Items added to cupboards:
								</li>
							}
						</>
					}
					{!!(totalPortionsPositive && shoppingListComplete) &&
						<p><Icon name="checkmark" className="mr-3 h-8 w-8 text-green-500"/>Shopping list complete</p>
					}
				</PortionWrapper>
				{!!(totalPortionsPositive && !onListPage && !!mailtoHrefContent) &&
					<ShoppingListBottomBanner mailtoHrefContent={mailtoHrefContent} />
				}
			</ShoppingListWrapper>
    </main>
  )
}

export default PlannerIndex

