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
import { switchShoppingListClass, showAlert } from "../functions/utils"
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
				<span className="w-full h-4 bg-primary-100 flex rounded-t overflow-hidden"><span className="bg-primary-600 h-full" style={{width: `${portion.percentInCupboards}%`}}></span></span>
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
		} else if(response.status === 202) {
			showAlert(`Cupboard name not updated`)
		} else {
			window.alert('Something went wrong! Maybe refresh the page and try again')
			throw new Error('non-200 response status')
    }
  }).then((jsonResponse) => {
		updateCupboardContents(jsonResponse.cupboardContents)

		showAlert(`Cupboard name updated to: "${jsonResponse.cupboardLocation}"`)
  });
}


const CupboardsIndex = props => {
	const [checkedPortionCount, updateCheckedPortionCount] = useState(props.checkedPortionCount)
  const [totalPortionCount, updateTotalPortionCount] = useState(props.totalPortionCount)
	const [shoppingListPortions, updateShoppingListPortions] = useState(props.shoppingListPortions)
	const [shoppingListShown, toggleShoppingListShow] = useState(false)
	const [plannerRecipes, updatePlannerRecipes] = useState(props.plannerRecipes)
	const [cupboardContents, updateCupboardContents] = useState(props.cupboardContents)

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


	return (
		<main>

			{plannerRecipes.filter(pr => pr.active).length > 0 &&
				<div className="py-8 border-b border-solid border-gray-500">
					<div className="px-6 flex flex-wrap py-4">
						<h2 className="w-full text-lg mb-2">Planner Recipes</h2>
						<div className="w-full">
							<p className="w-full text-gray-700 flex items-center text-base"><span className="flex w-5 h-5 mr-2"><Icon name="information-outline" /></span> Here are the upcoming recipes from your planner</p>
							<p className="w-full text-gray-700 text-base">Checked off shopping list items will be shown here</p>
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
											<a href={s.href} className="flex flex-wrap w-full items-start rounded p-3 border border-solid border-primary-400 bg-primary-400 hover:bg-primary-300 focus:bg-primary-300">
												<p className="text-base">{s.title}</p>
											</a>

										</div>
									))}
								</div>
							</div>
						)
					})}
				</div>
			</div>

			{/* <div className="mb-4 py-6">
				<div className="px-6 flex justify-center items-center flex-col py-4 text-center">
					<h2 className="text-2xl mb-4">Your Cupboards</h2>
					<button className="js-modal font-sans text-base border border-primary-400 border-solid text-black no-underline rounded
					hover:bg-primary-100 focus:bg-primary-100 p-2 bg-white"
						data-modal-content-id="demo"
						data-modal-title="Quick demo on how to add ingredients"
						data-modal-close-img="<%= png_icon_path('close') %>">How to use</button>
					<%= link_to "How to use", cupboards_demo_path,
							class: "no-js-modal-link text-base border border-primary-400 border-solid text-black no-underline rounded
											hover:bg-primary-100 focus:bg-primary-100 p-2 inline-block"
						%>
				</div>
				<div id="cupboard-list" className="flex flex-wrap p-4">
					<% user_cupboards(current_user).each do |cupboard| %>
						<div className="flex p-2 flex-grow w-full md:w-1/2">
							<div className="cupboard w-full rounded content-between flex flex-col border border-solid border-primary-400 relative"
									style="min-height: 8rem;"
									data-name="cupboard"
									id="<%= cupboard_id_hashids.encode(cupboard.id) %>">
								<div className="flex flex-wrap pt-4 px-2 pb-10"
									data-name="cupboard-sortable"
									data-cupboard-users="<%= cupboard_users_hashids.encode(cupboard.cupboard_users.map(&:user_id).sort!) %>"
									data-cupboard-id="<%= cupboard_id_hashids.encode(cupboard.id) %>">
									<% if cupboard.cupboard_users.length > 1 %>
										<div className="list_block--title_note">SHARED CUPBOARD</div>
									<% end %>
									<div className="w-full mx-1 mb-4 non_sortable flex items-center">
										<h3 className="w-full">
											<%= hidden_field_tag "cupboard_id", cupboard.id %>
											<%= text_field_tag "cupboard_location_#{cupboard.id}", cupboard.location,
											{
												readonly: cupboard.cupboard_users.where(owner: true).first.user != current_user,
												title: cupboard.cupboard_users.where(owner: true).first.user != current_user ? "Only the owner can edit a cupboard's name" : nil,
												class: "w-full transition-all ease duration-300 text-xl border-b border-solid border-primary-300 hover:bg-primary-50 py-1 hover:pl-2 focus:bg-primary-200 focus:pl-2 focus:border-primary-500"
											} %>
										</h3>
										<% if cupboard_stocks_selection_in_date(cupboard).length == 0 && cupboards.length > 1 && cupboard.cupboard_users.where(owner: true).first.user == current_user %>
											<span className="border border-solid border-primary-400 hover:bg-primary-100 rounded flex w-10 h-10 p-2 ml-2"
												data-name="delete-cupboard-btn">
												<%= icomoon('bin') %>
											</span>
										<% end %>
									</div>
									<% if cupboard.stocks.first %>
										<% cupboard_stocks_selection_in_date(cupboard).each do |stock| %>
											<% out_of_date_sentence = 'out of date' + (stock.use_by_date > Time.zone.now ? ' in ' : ' ') + (distance_of_time_in_words(Time.zone.now, stock.use_by_date)) + (stock.use_by_date <= Time.zone.now ? ' ago': '') %>
											<div
												className="sortable max-w-lg flex p-1 w-1/2 sm:w-1/3
												<% if user_cupboards(current_user).length > 1 %>
													md:w-1/2 lg:w-1/3 xl:w-1/4
												<% else %>
													md:w-1/4 lg:w-1/5 xl:w-1/6
												<% end %>"
												data-sortable
												style="min-height: 8rem;"
												id="<%= stock.id %>">
												<%= link_to ((cupboard.communal == false || stock.users.length == 0 || stock.users.map(&:id).include?(current_user[:id])) ? edit_stock_path(stock.id) : ''),
														class: "flex flex-wrap w-full items-start rounded p-3 border border-solid border-primary-400 bg-primary-400 hover:bg-primary-300 focus:bg-primary-300 list_block--item_show#{date_warning_class(stock)} stock_#{stock.id} #{(cupboard.communal == false || stock.users.length == 0 || stock.users.map(&:id).include?(current_user[:id])) ? '' : 'list_block--item-disabled'}",
														data: {
															cupboard_id: "#{cupboard.id}",
															stock_id:"#{stock.id}",
															name: "stock"
														}, title: "#{stock.ingredient.name} - #{out_of_date_sentence}" do %>
													<span className="flex justify-between w-full">
														<span className="mr-2">
															<p className="text-base" data-name="stock-description"><%= serving_description(stock) %></p>
															<% if cupboard.communal && stock.users.length > 0 %>
															<p className="text-xs text-gray-800 mt-2">Owner - <%= stock.users.first.name%></p>
															<% end %>
														</span>
														<span className="ml-auto bg-white hover:bg-primary-100 rounded border-0 flex w-10 h-10 p-2 flex-shrink-0"
																	id="<%= delete_stock_hashids.encode(stock.id) %>"
																	data-name="delete-stock-btn">
															<%= icomoon('bin') %>
														</span>
													</span>
													<span className="w-full mt-auto text-sm text-gray-700">Fresh for <%= distance_of_time_in_words(Time.zone.now, stock.use_by_date) + (stock.use_by_date <= Time.zone.now ? ' ago': '')%></span>
												<% end %>
											</div>
										<% end %>
									<% end %>
									<div className="order-3 non_sortable max-w-lg flex p-1 w-1/2 sm:w-1/3
											<% if user_cupboards(current_user).length > 1%>
												md:w-1/2 lg:w-1/3 xl:w-1/4
											<% else %>
												md:w-1/4 lg:w-1/5 xl:w-1/6
											<% end %>" style="min-height: 8rem;">
										<div className=" flex flex-col w-full bg-white rounded p-2 border border-solid border-primary-400">
											<%= link_to "Add typical ingredients", stocks_new_path(:cupboard_id => cupboard_id_hashids.encode(cupboard.id)), class: "m-1 rounded p-3 relative border border-solid border-primary-400 bg-primary-400 hover:bg-primary-300 focus:bg-primary-300 non_sortable" %>
											<%= link_to "Add other ingredient", stocks_custom_new_path(:cupboard_id => cupboard_id_hashids.encode(cupboard.id)), class: "m-1 rounded p-3 relative border border-solid border-primary-400 hover:bg-primary-100 focus:bg-primary-100 non_sortable" %>
										</div>
									</div>
								</div>
								<div className="w-full mt-auto flex justify-center">
									<% if cupboard.users.select{|u| u != current_user}.length < 1 %>
										<%= link_to "Add people to this cupboard", cupboard_share_path(cupboard_sharing_hashids.encode(cupboard.id)),
												class: "w-full text-center px-4 py-5 bg-primary-200 border-t border-solid border-primary-400 text-base" %>
									<% else %>
										<%= link_to cupboard_share_path(cupboard_sharing_hashids.encode(cupboard.id)),
												class: "w-full border-t border-solid border-primary-400 flex",
												title: "Sharing settings" do %>
											<div className="w-full p-3 flex items-center hover:bg-primary-50">
												<p className="text-base mr-3">
													<span>Cupboard shared with: </span>
													<span>
														<%= cupboard.cupboard_users.select{|cu|cu.user != current_user}.map{|cu|cu.user.name}.to_sentence %>
													</span>
												</p>
											</div>
											<span className="text-4xl p-2 w-20 bg-primary-300 text-center hover:bg-primary-400">+</span>
										<% end %>
									<% end %>
								</div>
							</div>
						</div>
					<% end %>
				</div>
				<div className="w-full px-4">
					<div className="w-full md:w-1/2 px-2">
						<%= link_to cupboards_new_path,
								class: "w-full bg-primary-100 block p-4 h-48 flex items-center justify-center rounded" do %>
						<span>Add a new cupboard</span>
						<% end %>
					</div>
				</div>
			</div> */}



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
