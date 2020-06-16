import React from "react"
import Icon from "./Icon"
import RecipeItem from "./RecipeItem"
import TooltipWrapper from "./TooltipWrapper"


function PlannerRecipeList({children}) {
	return (
		<div className="p-6">
			<div className="flex flex-wrap border border-solid border-primary-600 rounded-sm relative ">
				<div className="flex content-start pt-4 px-2 pb-6 w-full flex-wrap" data-recipe-list>
					<div className="w-full flex flex-col flex-shrink-0 items-start px-2 mb-4" data-sortable={false}>
						<h3 className="mb-2">Recipes to add to your planner</h3>
						<p className="flex text-gray-600 text-base items-center">
							<Icon name="information-outline" className="w-5 h-5 mr-2" />
							Add to your planner to build your meal plan and shopping list</p>
					</div>
					{children}
				</div>
			</div>
		</div>
	)
}

export default PlannerRecipeList
