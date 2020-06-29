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
import { showAlert, switchShoppingListClass, addRecipeToPlanner } from "../functions/utils"
import Dnd from "./DnDCalendar"


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

	const [tooltipsHidden, toggleTooltipsHidden] = useState(false)

	const [currentlyDraggedItem, updateCurrentlyDraggedItem] = useState(null)

	const [shoppingListLoading, updateShoppingListLoading] = useState(false)

	const [draggingOver, updateDraggingOver] = useState(false)
	const [draggedOverElement, updateDraggedOverElement] = useState(null)

	const [showModal, setShowModal] = useState(false)

	const [modalContent, updateModalContent] = useState(null)

  return (
		<main>
			{showModal ? (
        <>
          <div className="justify-center items-center flex overflow-x-hidden overflow-y-auto fixed inset-0 z-50 outline-none focus:outline-none">
            <div className="relative w-auto my-6 mx-auto max-w-3xl z-50">
              {/*content*/}
              <div className="border-0 rounded-lg shadow-lg relative flex flex-col w-full bg-white outline-none focus:outline-none">
                {/*header*/}
                <div className="flex items-start justify-between p-5 border-b border-solid border-gray-300 rounded-t">
                  <h3 className="text-3xl font-semibold">
                    Modal Title
                  </h3>
                  <button
                    className="p-1 ml-auto bg-transparent border-0 text-black opacity-5 float-right text-3xl leading-none font-semibold outline-none focus:outline-none"
                    onClick={() => setShowModal(false)}
                  >
                    <span className="bg-transparent text-black opacity-5 h-6 w-6 text-2xl block outline-none focus:outline-none">
                      ×
                    </span>
                  </button>
                </div>
                {/*body*/}
                <div className="relative p-6 flex-auto">
                  <p className="my-4 text-gray-600 text-lg leading-relaxed">
                    {modalContent}
                  </p>
                </div>
                {/*footer*/}
                <div className="flex items-center justify-end p-6 border-t border-solid border-gray-300 rounded-b">
                  <button
                    className="text-red-500 background-transparent font-bold uppercase px-6 py-2 text-sm outline-none focus:outline-none mr-1 mb-1"
                    type="button"
                    style={{ transition: "all .15s ease" }}
                    onClick={() => setShowModal(false)}
                  >
                    Close
                  </button>
                  <button
                    className="bg-green-500 text-white active:bg-green-600 font-bold uppercase text-sm px-6 py-3 rounded shadow hover:shadow-lg outline-none focus:outline-none mr-1 mb-1"
                    type="button"
                    style={{ transition: "all .15s ease" }}
                    onClick={() => setShowModal(false)}
                  >
                    Save Changes
                  </button>
                </div>
              </div>
            </div>
						<div className="opacity-25 fixed inset-0 z-40 bg-black" onClick={() => setShowModal(false)}></div>
          </div>
        </>
      ) : null}
			<PlannerRecipeList>
				{suggestedRecipes.map((recipe, index) => {
					const {encodedId, title, percentInCupboards, path, stockInfoNote} = recipe
						return (
							<RecipeItem key={index} encodedId={encodedId}
								onDragStart={() => {
									toggleTooltipsHidden(true)
									updateCurrentlyDraggedItem({encodedId, title})
								}}
								onDragEnd={() => {
									toggleTooltipsHidden(false)
									updateCurrentlyDraggedItem(null)
								}} title={title} draggable={true}>
								<TooltipWrapper width={48} text={stockInfoNote} className="top-0 left-0 flex-shrink-0 mb-2 bg-primary-100 w-full rounded-t-sm h-4 cursor-default" hidden={tooltipsHidden}>
									<span className="block h-full rounded-tl-sm bg-primary-600" style={{width: `${percentInCupboards}%`}}></span>
								</TooltipWrapper>
								<TooltipWrapper hidden={tooltipsHidden} text="Drag and drop recipe onto planner" width={48} className="flex flex-col w-full px-3 pb-4 justify-between relative h-full">
									<div className="flex justify-between">
										<p className="mb-5 cursor-move text-base leading-snug">{title}</p>
										<button
											name="button" type="submit"
											className="p-2 mb-1 ml-3 w-10 h-10 bg-white rounded-sm flex-shrink-0 flex" title="Add this recipe to your planner"
											data-recipe-id={encodedId} data-type="add-to-planner"
											onMouseEnter={()=>toggleTooltipsHidden(true)}
											onMouseLeave={()=>toggleTooltipsHidden(false)}
											onClick={() => addRecipeToPlanner(
												encodedId,
												csrfToken,
												updatePlannerRecipes,
												updateSuggestedRecipes,
												updateCheckedPortionCount,
												updateTotalPortionCount,
												updateShoppingListPortions,
												null,
												updateShoppingListLoading
											)}>
											<Icon name="list-add" className="w-full h-full" />
										</button>
									</div>
									<a
										href={path}
										onMouseEnter={()=>toggleTooltipsHidden(true)}
										onMouseLeave={()=>toggleTooltipsHidden(false)}
										className="text-sm text-gray-800 flex items-center hover:underline hover:text-black focus:underline focus:text-black"
										draggable={false}
									>View full recipe<Icon name="navigate_next" className="ml-1 w-6 h-6"/></a>
									</TooltipWrapper>
							</RecipeItem>
						)
					})}
			</PlannerRecipeList>
			<div
				className="h-screen px-6 mt-3"
				data-dragging-over={draggingOver}
				onDragEnter={(e)=>{
					updateDraggedOverElement(e.target)
					updateDraggingOver(true)
				}}
				onDragLeave={(e)=>{
					if (e.target === draggedOverElement) {
						updateDraggingOver(false)
					}
				}}
			>
				<Dnd
					updatePlannerRecipes={updatePlannerRecipes}
					updateSuggestedRecipes={updateSuggestedRecipes}
					updateCheckedPortionCount={updateCheckedPortionCount}
					updateTotalPortionCount={updateTotalPortionCount}
					updateShoppingListPortions={updateShoppingListPortions}
					csrfToken={csrfToken}
					events={events}
					updateEvents={updateEvents}
					currentlyDraggedItem={currentlyDraggedItem}
					updateShoppingListLoading={updateShoppingListLoading}
				/>
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
					shoppingListLoading={shoppingListLoading}
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
									shoppingListPortions={shoppingListPortions}
									updateShoppingListPortions={updateShoppingListPortions}
									updateShoppingListComplete={updateShoppingListComplete}
									updateCheckedPortionCount={updateCheckedPortionCount}
									updateTotalPortionCount={updateTotalPortionCount}
									updateShoppingListLoading={updateShoppingListLoading}
									setShowModal={setShowModal}
									updateModalContent={updateModalContent}
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

