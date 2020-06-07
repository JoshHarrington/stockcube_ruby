import React, {useState} from "react"
import ShoppingListInternal from "./ShoppingListInternal"
import PlannerRecipeList from "./PlannerRecipeList"
import Carousel from "./Carousel"
import RecipeItem from "./RecipeItem"


function ShoppingListContainer(props) {
  const [checkedPortionCount, updateCheckedPortionCount] = useState(props.checkedPortionCount)
  const [shoppingListShown, toggleShoppingListShow] = useState(false)
  const [totalPortionCount, updateTotalPortionCount] = useState(props.totalPortionCount)
  const [shoppingListComplete, updateShoppingListComplete] = useState(!!(checkedPortionCount === totalPortionCount))
  const [shoppingListPortions, updateShoppingListPortions] = useState(props.shoppingListPortions)
  const {controller, action, sharePath, csrfToken, mailtoHrefContent} = props

  const onListPage = !!(controller === "planner" && action === "list")
  const totalPortionsPositive = !!(totalPortionCount && totalPortionCount !== 0)
  const [toggleButtonShow, updateToggleButtonShow] = useState(!!(totalPortionsPositive && !onListPage))

	const [globalPlannerRecipes, updateGlobalPlannerRecipes] = useState(props.plannerRecipes)

  return (
		<main>
			<PlannerRecipeList recipes={props.recipes} />
			<Carousel>{props.planner.map(plannerDate => {
				return (
					<div key={plannerDate.dateId} className="w-full h-screen-3/5 sm:h-screen-2/5 lg:h-screen-1/4 mx-2 border border-gray-800 border-solid p-2">
						<div className="text-base">{plannerDate.calendarNote}</div>
						{globalPlannerRecipes.map((recipe, index) => (
							<RecipeItem {...recipe} key={index} />
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

export default ShoppingListContainer
