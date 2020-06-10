import React, {useState} from "react"
import ShoppingListInternal from "./ShoppingListInternal"
import PlannerRecipeList from "./PlannerRecipeList"
import Carousel from "./Carousel"
import RecipeItem from "./RecipeItem"
import TooltipWrapper from "./TooltipWrapper"
import Icon from "./Icon"
import { showAlert } from "../functions/utils"

function addRecipeToPlanner(
	encodedId,
	csrfToken,
	updateGlobalPlannerRecipes,
	updateSuggestedRecipes,
	updateCheckedPortionCount,
	updateTotalPortionCount,
	updateShoppingListPortions
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
		updateGlobalPlannerRecipes(jsonResponse["plannerRecipesByDate"])
		updateSuggestedRecipes(jsonResponse["suggestedRecipes"])
		updateCheckedPortionCount(jsonResponse["checkedPortionCount"])
		updateTotalPortionCount(jsonResponse["totalPortionCount"])
		updateShoppingListPortions(jsonResponse["shoppingListPortions"])
		showAlert("Recipe added to your planner")
  });

}

function deleteRecipeFromPlanner(
	plannerRecipeId,
	csrfToken,
	updateGlobalPlannerRecipes,
	updateSuggestedRecipes,
	updateCheckedPortionCount,
	updateTotalPortionCount,
	updateShoppingListPortions
) {
	const data = {
		method: 'post',
    body: JSON.stringify({
      "planner_recipe_id": plannerRecipeId
    }),
		headers: {
			'Content-Type': 'application/json',
			'X-CSRF-Token': csrfToken
		},
		credentials: 'same-origin'
  }

	showAlert("Removing recipe from your planner")

  fetch("/planner/recipe_delete", data).then((response) => {
    if(response.status === 200){
      return response.json();
		} else {
			window.alert('Something went wrong! Maybe refresh the page and try again')
			throw new Error('non-200 response status')
    }
  }).then((jsonResponse) => {
		updateGlobalPlannerRecipes(jsonResponse["plannerRecipesByDate"])
		updateSuggestedRecipes(jsonResponse["suggestedRecipes"])
		updateCheckedPortionCount(jsonResponse["checkedPortionCount"])
		updateTotalPortionCount(jsonResponse["totalPortionCount"])
		updateShoppingListPortions(jsonResponse["shoppingListPortions"])
		showAlert("Recipe removed from your planner")
  });
}

function PlannerIndex(props) {
  const [checkedPortionCount, updateCheckedPortionCount] = useState(props.checkedPortionCount)
  const [shoppingListShown, toggleShoppingListShow] = useState(false)
  const [totalPortionCount, updateTotalPortionCount] = useState(props.totalPortionCount)
  const [shoppingListComplete, updateShoppingListComplete] = useState(!!(checkedPortionCount === totalPortionCount))
  const [shoppingListPortions, updateShoppingListPortions] = useState(props.shoppingListPortions)
  const {controller, action, sharePath, csrfToken, mailtoHrefContent} = props

  const onListPage = !!(controller === "planner" && action === "list")
  const totalPortionsPositive = !!(totalPortionCount && totalPortionCount !== 0)
  const [toggleButtonShow, updateToggleButtonShow] = useState(!!(totalPortionsPositive && !onListPage))

	const [globalPlannerRecipes, updateGlobalPlannerRecipes] = useState(props.plannerRecipesByDate)
	const [suggestedRecipes, updateSuggestedRecipes] = useState(props.suggestedRecipes)

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
												props.csrfToken,
												updateGlobalPlannerRecipes,
												updateSuggestedRecipes,
												updateCheckedPortionCount,
												updateTotalPortionCount,
												updateShoppingListPortions
											)}>
											<Icon name="list-add" className="w-full h-full" />
										</button>
									</TooltipWrapper>
								</div>
							</RecipeItem>
						)
					})}
			</PlannerRecipeList>
			<Carousel>{props.planner.map(plannerDate => {
				return (
					<div key={plannerDate.dateId} className="w-full h-screen-3/5 sm:h-screen-2/5 lg:h-screen-1/4 mx-2 border border-gray-800 border-solid p-3">
						<div className="text-base mb-2">{plannerDate.calendarNote}</div>
						{globalPlannerRecipes.filter(recipeGroup => recipeGroup.date === plannerDate.dateId).length === 1 &&
							globalPlannerRecipes.filter(recipeGroup => recipeGroup.date === plannerDate.dateId)[0].plannerRecipes.map((recipe, index) => (
								<RecipeItem encodedId={recipe.encodedId} key={index} width="full">
									<TooltipWrapper position="bottom" width={48} text={recipe.stockInfoNote} className="top-0 left-0 flex-shrink-0 mb-2 bg-primary-100 w-full rounded-t-sm h-4">
										<span className="block h-full rounded-tl-sm bg-primary-600" style={{width: `${recipe.percentInCupboards}%`}}></span>
									</TooltipWrapper>
									<div className="flex w-full px-3 justify-between">
										<a href={recipe.path}>{recipe.title}</a>
										<TooltipWrapper text="Remove from planner" width={32}>
											<button
												name="button" type="submit"
												className="p-2 mb-1 ml-2 w-10 h-10 bg-white rounded-sm flex-shrink-0 flex" title="Remove this recipe from your planner"
												data-recipe-id={recipe.encodedId} data-type="add-to-planner"
												onClick={() => deleteRecipeFromPlanner(
													recipe.plannerRecipeId,
													props.csrfToken,
													updateGlobalPlannerRecipes,
													updateSuggestedRecipes,
													updateCheckedPortionCount,
													updateTotalPortionCount,
													updateShoppingListPortions
												)}
											>
												<Icon name="bin" className="w-full h-full" />
											</button>
										</TooltipWrapper>
									</div>
								</RecipeItem>
							))}
					</div>
					)
				}
			)}</Carousel>
			<ShoppingListInternal
				checkedPortionCount={checkedPortionCount}
				updateCheckedPortionCount={updateCheckedPortionCount}

				shoppingListShown={shoppingListShown}
				toggleShoppingListShow={toggleShoppingListShow}

				totalPortionCount={totalPortionCount}
				updateTotalPortionCount={updateTotalPortionCount}

				shoppingListComplete={shoppingListComplete}
				updateShoppingListComplete={updateShoppingListComplete}

				shoppingListPortions={shoppingListPortions}
				updateShoppingListPortions={updateShoppingListPortions}

				toggleButtonShow={toggleButtonShow}
				updateToggleButtonShow={updateToggleButtonShow}

				totalPortionsPositive={totalPortionsPositive}
				onListPage={onListPage}
				sharePath={sharePath}
				mailtoHrefContent={mailtoHrefContent}
				csrfToken={csrfToken}
			/>
    </main>
  )
}

export default PlannerIndex

