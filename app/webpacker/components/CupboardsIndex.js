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
import {
	switchShoppingListClass,
	showAlert,
	hidePlannerPortion,
	addStockToCupboards
} from "../functions/utils"
import * as classNames from "classnames"
import TooltipWrapper from "./TooltipWrapper"
import Select from 'react-select'

const CupboardPlannerPortion = ({portion, moreThanOnePlannerRecipe}) => (
	<TooltipWrapper
		text={portion.percentInCupboards !== 0 ? `${portion.percentInCupboards}% in your cupboards` : "Not yet in your cupboards"}
		width={64}
		className={classNames("max-w-md flex p-1 w-1/2 sm:w-1/3 non_sortable", {"md:w-1/2 lg:w-1/3": moreThanOnePlannerRecipe}, {"md:w-1/4 lg:w-1/5": !moreThanOnePlannerRecipe})}
	>
		<div className={classNames("flex flex-col w-full items-start rounded", {"bg-primary-100 text-gray-700": portion.percentInCupboards === 0}, {"bg-primary-400": portion.percentInCupboards !== 0})} style={{minHeight: "8rem"}}>
			{portion.percentInCupboards !== 0 &&
				<span className="w-full h-4 bg-primary-100 flex rounded-t overflow-hidden"><span className="bg-primary-600 h-full" style={{width: `${portion.percentInCupboards}%`}}></span></span>
			}
			<span className="p-3 w-full flex-grow flex flex-col justify-between">
				<p className="text-base mb-2">{portion.title}</p>
				{!!portion.freshForTime &&
					<span className="w-full text-sm text-gray-700">{portion.fresh ? `Fresh for ${portion.freshForTime}` : "Check freshness before use"}</span>
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

function updateCupboardName(name, encodedId, csrfToken, updateCupboardContents) {

	const data = {
		method: 'post',
    body: JSON.stringify({
			"cupboard_location": name,
			"cupboard_id": encodedId
    }),
		headers: {
			'Content-Type': 'application/json',
			'X-CSRF-Token': csrfToken
		},
		credentials: 'same-origin'
  }

  fetch("/cupboards/name_update", data).then((response) => {
		if(response.status === 200){
      return response.json();
		} else if(response.status !== 202) {
			window.alert('Something went wrong! Maybe refresh the page and try again')
			throw new Error('non-200 response status')
    }
  }).then((jsonResponse) => {
		updateCupboardContents(jsonResponse.cupboardContents)

		showAlert(`Cupboard name updated to: "${jsonResponse.cupboardLocation}"`)
  });
}

function deleteStock(encodedId, updateCupboardContents, csrfToken){
	const data = {
		method: 'post',
		body: JSON.stringify({
			"encoded_id": encodedId
    }),
		headers: {
			'Content-Type': 'application/json',
			'X-CSRF-Token': csrfToken
		},
		credentials: 'same-origin'
	}

	fetch("/stock/delete", data).then((response) => {
		if(response.status === 200){
      return response.json();
		} else {
			window.alert('Something went wrong! Maybe refresh the page and try again')
			throw new Error('non-200 response status')
    }
  }).then((jsonResponse) => {
		updateCupboardContents(jsonResponse.cupboardContents)

		showAlert(`"${jsonResponse.stockDescription}" deleted`)
  });
}


const CupboardsIndex = props => {
	const [checkedPortionCount, updateCheckedPortionCount] = useState(props.checkedPortionCount)
  const [totalPortionCount, updateTotalPortionCount] = useState(props.totalPortionCount)
	const [shoppingListPortions, updateShoppingListPortions] = useState(props.shoppingListPortions)
	const [shoppingListShown, toggleShoppingListShow] = useState(false)
	const [plannerRecipes, updatePlannerRecipes] = useState(props.plannerRecipes)
	const [cupboardContents, updateCupboardContents] = useState(props.cupboardContents)

	const {sharePath, csrfToken, mailtoHrefContent, onListPage, newCupboardHref} = props

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
		// getLatestPlannerRecipes(updatePlannerRecipes, csrfToken)
	}, [checkedPortionCount, totalPortionCount])

	const [shoppingListLoading, updateShoppingListLoading] = useState(false)

	const [showModal, setShowModal] = useState(false)

	const [selectedPortion, updateSelectedPortion] = useState(null)
	const [newStockToAdd, updateNewStockToAdd] = useState(null)

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
                  <h3 className="text-2xl">
										Do you already have {selectedPortion.ingredientName}?
                  </h3>
                  <button
                    className="p-1 ml-auto bg-transparent border-0 text-black opacity-5 float-right text-3xl leading-none font-semibold outline-none focus:outline-none"
                    onClick={() => setShowModal(false)}
                  >
										<Icon name="close" className="bg-transparent ml-3 text-black opacity-5 h-6 w-6 text-2xl block outline-none focus:outline-none" />
                  </button>
                </div>
                {/*body*/}
                <div className="relative p-6 flex-auto">
									<div className="flex flex-wrap">
										<h5 className="text-xl w-full">If yes, add it to your cupboards:</h5>
										<div className="flex justify-between mt-8 w-full">
											<input
												type="number"
												className="w-1/2 mr-2 border border-solid border-gray-400 rounded px-2 text-base"
												placeholder="1"
												min={0.01}
												defaultValue={selectedPortion.defaultAmount}
												onChange={(e) => updateNewStockToAdd({...newStockToAdd, amount: e.target.value})}/>
											<Select
												options={selectedPortion.units}
												className="w-1/2 text-base"
												onChange={(target) => updateNewStockToAdd({...newStockToAdd, unitId: target.value})}
												theme={theme => ({
													...theme,
													borderRadius: '.25rem'
												})}
												defaultValue={{
													value: selectedPortion.defaultUnitId,
													label: selectedPortion.defaultUnitName
												}}
												/>
										</div>
									</div>
                </div>
                {/*footer*/}
                <div className="flex flex-col items-center justify-center p-6 rounded-b">
									<button
										className="bg-primary-700 text-white active:bg-primary-800 text-lg py-3 px-4 rounded shadow hover:shadow-lg outline-none focus:outline-none mr-2"
										onClick={() => {
											addStockToCupboards({
												csrfToken,
												newStockToAdd,
												portion: selectedPortion,
												updateCheckedPortionCount,
												updateTotalPortionCount,
												updateShoppingListPortions,
												updateCupboardContents,
												setShowModal
											})
										}}
									>Add to cupboards</button>
									<button
										className="text-gray-800 background-transparent font-bold p-2 text-base outline-none focus:outline-none hover:underline focus:underline mt-3"
										type="button"
										onClick={() => {
											setShowModal(false)
											hidePlannerPortion({
												portionEncodedId: selectedPortion.encodedId,
												portionType: selectedPortion.type,
												csrfToken,
												updateCheckedPortionCount,
												updateTotalPortionCount,
												updateShoppingListPortions
											})
										}}
									>
										Skip, just remove from list
									</button>
                </div>
              </div>
            </div>
						<div className="opacity-25 fixed inset-0 z-40 bg-black" onClick={() => setShowModal(false)}></div>
          </div>
        </>
      ) : null}
			{plannerRecipes.filter(pr => pr.active).length > 0 &&
				<div className="py-8 border-b border-solid border-gray-500">
					<div className="px-6 flex flex-wrap py-4">
						<h2 className="w-full text-lg mb-2">Planner Recipes</h2>
						<div className="w-full">
							<p className="w-full text-gray-700 flex items-center text-base"><span className="flex w-5 h-5 mr-2"><Icon name="information-outline" /></span> Here are the upcoming recipes from your planner</p>
						</div>
					</div>
					<div className="flex flex-wrap p-4">
						{plannerRecipes.filter(pr => pr.active).map((plannerRecipe, index) => {
							const recipe = plannerRecipe.plannerRecipe
							return (
								<div className="flex p-2 flex-grow w-full md:w-1/2 lg:w-1/3" key={index}>
									<div className="w-full rounded content-between flex flex-col border border-solid border-primary-400">

										<div className="flex flex-wrap pt-4 px-2 pb-10">
											<div className="w-full mx-1 mb-4 non_sortable flex items-center">
												<h3><a className="text-primary-700 hover:underline focus:underline" href={plannerRecipe.recipeHref}>{recipe.title} ({plannerRecipe.humanDate})</a></h3>
											</div>
											{recipe.portions.length > 0 ?
												recipe.portions.map((portion, index) => (
												<CupboardPlannerPortion
													key={index}
													portion={portion}
													moreThanOnePlannerRecipe={plannerRecipes.length > 1}
												/>
											))
											: <p className="mx-1 w-full text-gray-600">No portions in the shopping list for this recipe</p>}
										</div>
									</div>
								</div>
							)
						})}
					</div>
				</div>
			}

			<div className="mb-4 py-6">
				<div className="px-6 flex justify-center items-center flex-col py-4 text-center">
					<h2 className="text-2xl mb-4">Your Cupboards</h2>
				</div>
				<div id="cupboard-list" className="flex flex-wrap p-4">
					{cupboardContents.map((c, index) => {
						return (
							<div key={index} className="flex p-2 flex-grow w-full md:w-1/2">
								<div className="w-full rounded content-between flex flex-col border border-solid border-primary-400 relative"
									style={{minHeight: "8rem"}}
									data-name="cupboard"
									id={c.id}>
									<div className="flex flex-wrap pt-4 px-2 pb-10">

										<div className="w-full mx-1 mb-4 flex items-center">
											<h3 className="w-full">
												<input
													type="text"
													defaultValue={c.title}
													className="w-full transition-all ease duration-300 text-xl border-b border-solid border-primary-300 hover:bg-primary-50 py-1 hover:pl-2 focus:bg-primary-200 focus:pl-2 focus:border-primary-500"
													onBlur={(e) => updateCupboardName(e.target.value, c.id, csrfToken, updateCupboardContents)}
													/>
												</h3>
										</div>
										{c.stock.map(s => (
											<div
											key={s.id}
											className={classNames("max-w-lg flex p-1 w-1/2 sm:w-1/3", {"md:w-1/2 lg:w-1/3 xl:w-1/4": cupboardContents.length > 1}, {"md:w-1/4 lg:w-1/5 xl:w-1/6": cupboardContents.length === 1})}
											style={{minHeight: "8rem"}}
											id={s.id}
											>
												<a href={s.href} className="flex w-full items-start rounded p-3 border border-solid border-primary-400 bg-primary-400 hover:bg-primary-300 focus:bg-primary-300 justify-between">
													<div className="flex flex-col h-full">
														<p className="text-base mb-2">{s.title}</p>
														<span className="w-full mt-auto text-sm text-gray-700">{s.fresh ? `Fresh for ${s.freshForTime}`: "Check freshness before use" }</span>
													</div>
													<button
														className="p-1 mb-1 ml-2 w-6 h-6 bg-white rounded-sm flex-shrink-0 flex focus:shadow-outline"
														onClick={(e) => {
															e.preventDefault()
															deleteStock(s.encodedIdForDelete, updateCupboardContents, csrfToken)
														}}
													><Icon name="close" className="w-full h-full" /></button>

												</a>

											</div>
										))}
										<div className={classNames("order-3 non_sortable max-w-lg flex p-1 w-1/2 sm:w-1/3", {"md:w-1/2 lg:w-1/3 xl:w-1/4": cupboardContents.length > 1}, {"md:w-1/4 lg:w-1/5 xl:w-1/6": cupboardContents.length === 1})}>
											<div className="flex flex-col w-full bg-white rounded p-2 border border-solid border-primary-400">
												<a className="m-1 rounded p-3 relative border border-solid border-primary-400 bg-primary-400 hover:bg-primary-300 focus:bg-primary-300" href={c.newStockHref}>Add typical ingredients</a>
												<a className="m-1 rounded p-3 relative border border-solid border-primary-400 hover:bg-primary-100 focus:bg-primary-100" href={c.customNewStockHref}>Add other ingredient</a>
											</div>
										</div>
									</div>
									<div className="w-full mt-auto flex justify-center">
										{ !!c.users ?
											<a
												href={c.sharingPath}
												className="w-full border-t border-solid border-primary-400 flex"
											>
												<div className="w-full p-3 flex items-center hover:bg-primary-50">
													<p className="text-base mr-3">
														<span>Cupboard shared with: </span>
														<span>
															{c.users}
														</span>
													</p>
												</div>
												<span className="text-4xl p-2 w-20 bg-primary-300 text-center hover:bg-primary-400">+</span>
											</a> :
											<a
												href={c.sharingPath}
												className="w-full text-center px-4 py-5 bg-primary-200 border-t border-solid border-primary-400 text-base"
											>Add people to this cupboard</a>
										}
									</div>
								</div>
							</div>
						)
					})}
				</div>
				<div className="w-full px-4">
					<div className="w-full md:w-1/2 px-2">
						<a className="w-full bg-primary-100 block p-4 h-48 flex items-center justify-center rounded" href={newCupboardHref}>
							<span>Add a new cupboard</span>
						</a>
					</div>
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
									shoppingListLoading={shoppingListLoading}
									updateShoppingListLoading={updateShoppingListLoading}
									setShowModal={setShowModal}
									updateSelectedPortion={updateSelectedPortion}
									updateNewStockToAdd={updateNewStockToAdd}
									updatePlannerRecipes={updatePlannerRecipes}
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
