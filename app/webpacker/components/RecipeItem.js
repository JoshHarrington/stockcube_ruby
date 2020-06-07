import React from "react"
import TooltipWrapper from "./TooltipWrapper"
import Icon from "./Icon"

const RecipeItem = props => {

	const {encodedId, title, percentInCupboards, path, stockInfoNote} = props

	return (
		<div className="flex p-2 sortable--item w-1/2 sm:w-1/3 md:w-1/4 lg:w-1/5 xl:w-1/6" id={encodedId}>
			<div className="flex bg-primary-400 pb-4 relative rounded-sm w-full flex-wrap content-start">
				<TooltipWrapper width={48} text={stockInfoNote} className="top-0 left-0 flex-shrink-0 mb-2 bg-primary-100 w-full rounded-t-sm h-4">
					<span className="block h-full rounded-tl-sm bg-primary-600" style={{width: `${percentInCupboards}%`}}></span>
				</TooltipWrapper>
				<div className="flex w-full px-3 justify-between">
					<a href={path}>{title}</a>
					<TooltipWrapper text="Add to planner" width={24}>
						<button
							name="button" type="submit"
							className="p-2 mb-1 ml-2 w-10 h-10 bg-white rounded-sm flex-shrink-0 flex" title="Add this recipe to your planner"
							data-recipe-id={encodedId} data-type="add-to-planner">
							<Icon name="list-add" className="w-full h-full" />
						</button>
					</TooltipWrapper>
				</div>
			</div>
		</div>
	)
}

export default RecipeItem
