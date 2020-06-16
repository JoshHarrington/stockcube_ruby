import React, { useState, useEffect } from "react"
import {
	ShoppingListWrapper,
	ShoppingListButton,
	ShoppingListTopBanner,
	PortionWrapper,
	PortionItem,
	ShoppingListBottomBanner
} from "./ShoppingListComponents"
import Icon from "./Icon"
import { switchShoppingListClass } from "../functions/utils"
import * as classNames from "classnames"
import TooltipWrapper from "./TooltipWrapper"

const CupboardPlannerPortion = ({portion, moreThanOnePlannerRecipe}) => (
	<TooltipWrapper
		text={portion.percentInCupboards !== 0 ? `${portion.percentInCupboards}% in your cupboards` : "Not yet in your cupboards"}
		width={64}
		className={classNames("max-w-md flex p-1 w-1/2 sm:w-1/3 non_sortable", {"md:w-1/2 lg:w-1/3": moreThanOnePlannerRecipe}, {"md:w-1/4 lg:w-1/5": !moreThanOnePlannerRecipe})}
	>
		<div className={classNames("flex flex-col w-full items-start rounded", {"bg-primary-100 text-gray-700": portion.percentInCupboards === 0}, {"bg-primary-400": portion.percentInCupboards !== 0})} style={{minHeight: "8rem"}}>
			{portion.percentInCupboards !== 0 &&
				<span className="w-full h-4 bg-primary-100 flex"><span className="bg-primary-600 h-full" style={{width: `${portion.percentInCupboards}%`}}></span></span>
			}
			<span className="p-3 w-full flex-grow flex flex-col justify-between">
				<p className="text-base mb-2">{portion.title}</p>
				{!!portion.freshForTime &&
					<span className="w-full text-sm text-gray-700">Fresh for {portion.freshForTime}</span>
				}
			</span>

		</div>
	</TooltipWrapper>
)

function getLatestPlannerRecipes(updatePlannerRecipes, csrfToken) {

	const data = {
		method: 'post',
		headers: {
			'Content-Type': 'application/json',
			'X-CSRF-Token': csrfToken
		},
		credentials: 'same-origin'
  }


  fetch("/cupboards/planner_recipes", data).then((response) => {
    if(response.status != 200){
      window.alert('Something went wrong! Maybe refresh the page and try again')
    } else {
      return response.json();
    }
  }).then((jsonResponse) => {
    updatePlannerRecipes(jsonResponse.plannerRecipes)
  });

}


const CupboardsIndex = props => {
	const [checkedPortionCount, updateCheckedPortionCount] = useState(props.checkedPortionCount)
  const [totalPortionCount, updateTotalPortionCount] = useState(props.totalPortionCount)
	const [shoppingListPortions, updateShoppingListPortions] = useState(props.shoppingListPortions)
	const [shoppingListShown, toggleShoppingListShow] = useState(false)
	const [plannerRecipes, updatePlannerRecipes] = useState(props.plannerRecipes)

	const {sharePath, csrfToken, mailtoHrefContent, onListPage} = props

	const totalPortionsPositive = !!(totalPortionCount && totalPortionCount !== 0)
  const [toggleButtonShow, updateToggleButtonShow] = useState(totalPortionsPositive)

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
		getLatestPlannerRecipes(updatePlannerRecipes, csrfToken)
	}, [checkedPortionCount, totalPortionCount])

	console.log(plannerRecipes)

	return (
		<main>

			<div className="py-8 border-b border-solid border-gray-500">
				<div className="px-6 flex flex-wrap py-4">
					<h2 className="w-full text-lg mb-2">Planner Recipes</h2>
					<div className="w-full">
						<p className="w-full text-gray-700 flex items-center text-base"><span className="flex w-5 h-5 mr-2"><Icon name="information-outline" /></span> Here are the upcoming recipes from your planner</p>
						<p className="w-full text-gray-700 text-base">Checked off shopping list items will be shown here</p>
					</div>
				</div>
				<div className="flex flex-wrap p-4">
					{plannerRecipes.map((plannerRecipe, index) => {
						const recipe = plannerRecipe.plannerRecipe
						return (
							<div className="flex p-2 flex-grow w-full md:w-1/2 lg:w-1/3" key={index}>
								<div className="w-full rounded content-between flex flex-col border border-solid border-primary-400">

									<div className="flex flex-wrap pt-4 px-2 pb-10">
										<div className="w-full mx-1 mb-4 non_sortable flex items-center">
											<h3>{recipe.title}</h3>
										</div>
										{recipe.portions.map((portion, index) => (
											<CupboardPlannerPortion
												key={index}
												portion={portion}
												moreThanOnePlannerRecipe={plannerRecipes.length > 1}
											/>
										))}
									</div>
								</div>
							</div>
						)
					})}
				</div>
			</div>

			<ShoppingListWrapper shoppingListShown={shoppingListShown}>
				{toggleButtonShow &&
					<ShoppingListButton
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

export default CupboardsIndex
