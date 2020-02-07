import { ready, ajaxRequest, showAlert, isMobileDevice } from './utils'
import Sortable from 'sortablejs'
import Choices from 'choices.js'
import {tns} from 'tiny-slider/src/tiny-slider'
import SVG from '../icons/symbol-defs.svg'
import PNGBin from '../icons/png-icons/bin.png'
import PNGInfoOutline from '../icons/png-icons/information-outline.png'
import PNGFullscreen from '../icons/png-icons/fullscreen.png'
import PNGFullscreenExit from '../icons/png-icons/fullscreen_exit.png'

const plannerRecipeAddData = (id, date = null) => {
	if (date && date != null) {
		return "recipe_id=" + id + "&planner_date=" + date
	} else {
		return "recipe_id=" + id
	}
}

const plannerRecipeUpdateData = (e) => (
	"recipe_id=" + e.item.id + "&old_date=" + e.item.dataset.parentId + "&new_date=" + e.item.parentNode.id
)

function checkForUpdates(onSuccess) {
	let data = {}
	if (window.location.pathname.includes('/list/')){
		data = {
			method: 'post',
			body: JSON.stringify({gen_id: window.location.pathname.replace('/list/','')}),
			headers: {
				'Content-Type': 'application/json',
				'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
			},
			credentials: 'same-origin'
		}
	}
  setTimeout(() => fetch("/planner/shopping_list", data).then((response) => {
    if(response.status != 200){
      setTimeout(() => checkForUpdates(onSuccess), 200)
    } else {
      response.json().then(onSuccess)
    }
  }), 400)
}

const updateButtonFractionSpan = (fraction) => {
	const ButtonFractionSpan = document.querySelector('#button__shopping_list_fraction')
	if (ButtonFractionSpan) {
		if (fraction != null) {
			ButtonFractionSpan.style.display = 'block'
			ButtonFractionSpan.innerText = fraction

		} else {
			ButtonFractionSpan.style.display = 'none'
		}
	}
}

const updateShoppingListCheckCount = (shoppingList) => {
	const ShoppingListInner = document.querySelector('.planner_shopping_list--inner')
	const ShoppingListTitleBlock = ShoppingListInner.querySelector('.title_block')
	const ShoppingListTitle = ShoppingListTitleBlock.querySelector('h2')

	if (shoppingList.length === 0 ){
		ShoppingListTitle.innerText = 'Shopping List'
		updateButtonFractionSpan()
	} else {
		const ShoppingListTitleContent = 'Shopping List (' + shoppingList[0]["stats"]["checked_portions"] + '/' + shoppingList[0]["stats"]["total_portions"] + ')'
		ShoppingListTitle.innerText = ShoppingListTitleContent
		updateButtonFractionSpan(shoppingList[0]["stats"]["checked_portions"] + '/' + shoppingList[0]["stats"]["total_portions"])
	}
}

const renderShoppingList = (shoppingList, animated = false) => {

	const ShoppingList = document.querySelector('.planner_shopping_list--wrapper')

	const ShoppingListInner = document.querySelector('.planner_shopping_list--inner')
	const ShoppingListTitleBlock = ShoppingListInner.querySelector('.title_block')
	const ShoppingListTitle = ShoppingListTitleBlock.querySelector('h2')
	// const ShoppingListExpandBtn = ShoppingListTitleBlock.querySelector('.planner_shopping_list--fullscreen_btn')
	const ListTopUl = document.createElement('ul')
	ListTopUl.classList.add('planner_sl-recipe_list')
	let ShoppingListTitleNote = ShoppingListTitleBlock.querySelector('p.item_form--content_item_note')
	let ShoppingListTitleFullscreenBtn = ShoppingListTitleBlock.querySelector('a.planner_shopping_list--fullscreen_btn')

	const OldShoppingListContent = ShoppingListInner.querySelector('ul')

	if (shoppingList.length === 0 ){
		ShoppingListTitle.innerText = 'Shopping List'
		if (ShoppingList) {
			hideShoppingList()
		}
		updateButtonFractionSpan()
		ListTopUl.innerHTML = '<p>Shopping List is currently empty, move some recipes to <a href="/planner">your planner</a> to get items added to this list</p>'
		if (ShoppingListTitleNote !== null) {
			ShoppingListTitleNote.style.display = 'none'
		}
		if (ShoppingListTitleFullscreenBtn !== null) {
			ShoppingListTitleFullscreenBtn.style.display = 'none'
		}
	} else {
		const GenId = shoppingList[2]["gen_id"]
		const UnitList = shoppingList[3]["unit_list"]
		const ShoppingListTitleContent = 'Shopping List (' + shoppingList[0]["stats"]["checked_portions"] + '/' + shoppingList[0]["stats"]["total_portions"] + ')'
		ShoppingListTitle.innerText = ShoppingListTitleContent

		if (ShoppingListTitleNote !== null) {
			ShoppingListTitleNote.style.display = 'block'
		} else {
			ShoppingListTitleNote = document.createElement('p')
			ShoppingListTitleNote.classList.add('h6','item_form--content_item_note')
			ShoppingListTitleNote.innerHTML = `<svg class="icomoon-icon icon-information-outline"><use xlink:href="${SVG}#icon-information-outline"></use></svg><img class="icon-png" src="${PNGInfoOutline}"/> Checking off items adds them to <a href="/cupboards">your cupboard</a> automatically (once checked they'll disappear from the list in 24 hours)`
			ShoppingListTitleBlock.appendChild(ShoppingListTitleNote)
		}

		if (ShoppingListTitleFullscreenBtn !== null) {
			ShoppingListTitleFullscreenBtn.style.display = 'block'
		} else {
			ShoppingListTitleFullscreenBtn = document.createElement('a')
			ShoppingListTitleFullscreenBtn.classList.add('planner_shopping_list--fullscreen_btn')
			if (document.body.classList.contains('planner_controller') && document.body.classList.contains('list_page')) {
				ShoppingListTitleFullscreenBtn.setAttribute('title', 'Close shopping list share page')
				ShoppingListTitleFullscreenBtn.setAttribute('href', `/planner`)
				ShoppingListTitleFullscreenBtn.innerHTML = `<svg class="icomoon-icon icon-fullscreen_exit"><use xlink:href="${SVG}#icon-fullscreen_exit"></use></svg><img class="icon-png" src="${PNGFullscreenExit}"/>`
				ShoppingListTitleBlock.appendChild(ShoppingListTitleFullscreenBtn)
			} else {
				ShoppingListTitleFullscreenBtn.setAttribute('title', 'View and share shopping list')
				ShoppingListTitleFullscreenBtn.setAttribute('href', `/list/${GenId}`)
				ShoppingListTitleFullscreenBtn.innerHTML = `<svg class="icomoon-icon icon-fullscreen"><use xlink:href="${SVG}#icon-fullscreen"></use></svg><img class="icon-png" src="${PNGFullscreen}"/>`
				ShoppingListTitleBlock.appendChild(ShoppingListTitleFullscreenBtn)
			}
		}

		shoppingList[1]["portions"].forEach(function(portion) {
			const RecipePortionLi = document.createElement('li')
			RecipePortionLi.setAttribute('id', portion["shopping_list_portion_id"])
			RecipePortionLi.classList.add('shopping_list_portion')
			if (portion["checked"] === "true"){
				RecipePortionLi.classList.add('portion_checked')
			}
			let RecipePortionLiTag
			if (portion["portion_type"] == "combi") {
				RecipePortionLi.classList.add('combi_portion')
			} else if (portion["portion_type"] == "individual") {
				RecipePortionLi.classList.add('individual_portion')
			} else {
				RecipePortionLi.classList.add('wrapper_portion')
			}

			RecipePortionLiTag = '<h6 class="mb-3 portion_recipe_tag">' + portion["portion_note"] + '</h6>'


			const RecipePortionLiP = '<p class="h3 portion_ingredient_name"><input type="checkbox" id="planner_shopping_list_portions_add_'+ portion["shopping_list_portion_id"] + '" class="fancy_checkbox" ' + (portion["checked"] === "true" && 'checked') + '> ' + '<label for="planner_shopping_list_portions_add_'+ portion["shopping_list_portion_id"] + '" class="fancy_checkbox_label">' + portion["ingredient_name"] +'</label></p>'

			const RecipePortionLiSizeRow = '<div class="shopping_list_portion-size_row"><input type="number" name="planner_shopping_list_portions_amount'+ portion["shopping_list_portion_id"] +'" value="'+ portion["portion_amount"] +'" /><select name="planner_shopping_list_portions_unit_'+ portion["shopping_list_portion_id"] +'" class="choices--basis pretty_form--row--pretty_select">'+
			UnitList.map((u) => {
				if (u["id"] === portion["portion_unit"]) {
					return `<option selected value="${u["id"]}">${u["name"]}</option>`
				}
				return `<option value="${u["id"]}">${u["name"]}</option>`
			})
			+'</select></div>'
			/// Remove min for amount until able to manage it properly
			// min="'+ portion["portion_amount"] +'"

			const RecipePortionLiDateRow = '<div class="shopping_list_portion-date_row"><p class="shopping_list_portion-date_row-tag h6">Use by date:</p><input type="date" min="' + portion["min_date"] + '" name="planner_shopping_list_portions_date_'+ portion["shopping_list_portion_id"] +'" value="' + portion["portion_date"] + '" placeholder="' + portion["portion_date"] + '" /></div><hr />'

			RecipePortionLi.innerHTML = RecipePortionLiTag + RecipePortionLiP + RecipePortionLiSizeRow + RecipePortionLiDateRow

			ListTopUl.appendChild(RecipePortionLi)

		})

		if (ShoppingList) {
			if (shoppingList[0]["stats"]["checked_portions"] === shoppingList[0]["stats"]["total_portions"]) {
				hideShoppingList()
				updateButtonFractionSpan()
			} else if (animated) {
				showShoppingList()
			}
		}

	}
	OldShoppingListContent.remove()
	ShoppingListInner.appendChild(ListTopUl)
	if (ShoppingList) {
		ShoppingList.appendChild(ShoppingListInner)
	} else {
		document.querySelector('main').prepend(ShoppingListInner)
	}

	const selectEl = document.querySelectorAll('.planner_sl-recipe_list select.choices--basis')
	if (selectEl){
		selectEl.forEach(function(select){
			const choicesSelect = new Choices(select, {
				classNames: {
					containerOuter: 'choices choices_select choices_slim'
				},
				itemSelectText: 'Select'
			})
		})
	}

	setupPortionUpdateWatch()
	setupShoppingListCheckingOff()
}


const showShoppingList = () => {
	const html = document.querySelector('html')
	if (!html.classList.contains('shopping_list_open')) {
		html.classList.add('shopping_list_open')
	}
}

const hideShoppingList = () => {
	const html = document.querySelector('html')
	if (html.classList.contains('shopping_list_open')) {
		html.classList.remove('shopping_list_open')
	}
}

const setupShoppingListButton = () => {
	const html = document.querySelector('html')
	const toggleBtn = document.querySelector('.planner_shopping_list--wrapper .list_toggle')
	if (toggleBtn) {
		toggleBtn.style.display = 'flex'
		toggleBtn.addEventListener("click", function(){
			html.classList.toggle('shopping_list_open')
		})
	}
}

const updatePortionData = (portionData) => {
	ajaxRequest(JSON.stringify(portionData), '/planner/update_portion', 0, 'application/json')
}

const setupPortionUpdateWatch = () => {
	let genId = null
	if (window.location.pathname.includes('/list/')){
		genId = window.location.pathname.replace('/list/','')
	}

	const shoppingListPortions = document.querySelectorAll('.planner_shopping_list--inner .planner_sl-recipe_list li')
	shoppingListPortions.forEach(function(portionLi){
		const portionId = portionLi.getAttribute('id')

		let portionType
		if (portionLi.classList.contains('combi_portion')) {
			portionType = 'combi_portion'
		} else if (portionLi.classList.contains('individual_portion')) {
			portionType = 'individual_portion'
		} else {
			portionType = 'wrapper_portion'
		}

		const unitSelect = portionLi.querySelector('select')
		let unitId = unitSelect.value

		const amountField = portionLi.querySelector('input[type="number"]')
		let amount = amountField.value

		const dateField = portionLi.querySelector('input[type="date"]')
		let date = dateField.value

		const portionData = {	"shopping_list_portion_id": portionId,
													"portion_type": portionType,
													"amount": amount,
													"unit_id": unitId,
													"date": date }

		if (genId !== null) {
			portionData.gen_id = genId
		}

		unitSelect.addEventListener("change", (e) => {
			unitId = e.target.value
			portionData.unit_id = unitId
			updatePortionData(portionData)
		})
		amountField.addEventListener("change", (e) => {
			amount = e.target.value
			portionData.amount = amount
			updatePortionData(portionData)
		})
		dateField.addEventListener("change", (e) => {
			date = e.target.value
			portionData.date = date
			updatePortionData(portionData)
		})
	})
}

const setupShoppingListCheckingOff = () => {
	let genId = null
	if (window.location.pathname.includes('/list/')){
		genId = window.location.pathname.replace('/list/','')
	}
	const shoppingListPortionsChecks = document.querySelectorAll('.planner_shopping_list--inner .planner_sl-recipe_list li input[type="checkbox"]')
	shoppingListPortionsChecks.forEach(function(portionCheckbox){
		portionCheckbox.addEventListener("change", function(){
			const portionLi = portionCheckbox.closest('li')
			const portionId = portionLi.getAttribute('id')

			let portionType = ''
			if (portionLi.classList.contains('combi_portion')) {
				portionType = 'combi_portion'
			} else if (portionLi.classList.contains('individual_portion')) {
				portionType = 'individual_portion'
			} else {
				portionType = 'wrapper_portion'
			}

			const portionData = "shopping_list_portion_id=" + portionId + "&portion_type=" + portionType + (genId !== null ? "&gen_id=" + genId : "")
			portionLi.classList.toggle('portion_checked')
			if (portionCheckbox.checked) {
				ajaxRequest(portionData, '/stock/add_portion')
			} else {
				ajaxRequest(portionData, '/stock/remove_portion')
			}
			checkForUpdates(function(shoppingList) {
				updateShoppingListCheckCount(shoppingList)
			})
		})
	})
}


const addPlannerRecipe = (e) => {
	ajaxRequest(plannerRecipeAddData(e.item.id, e.item.parentNode.id), '/planner/recipe_add')

	const deleteBtn = document.createElement('button')
	deleteBtn.innerHTML = `<svg class="icomoon-icon icon-bin"><use xlink:href="${SVG}#icon-bin"></use></svg><img class="icon-png" src="${PNGBin}" />`
	deleteBtn.classList.add('delete', 'list_block--item--action', 'list_block--item--action--btn')

	const parentId = e.item.parentNode.id
	e.item.setAttribute('data-parent-id', parentId)

	e.item.appendChild(deleteBtn)
	deleteBtn.addEventListener("click", function(){deletePlannerRecipe(deleteBtn)})

	checkForUpdates(function(shoppingList) {
	  renderShoppingList(shoppingList, true)
	})

}

const updatePlannerRecipe = (e) => {
	ajaxRequest(plannerRecipeUpdateData(e), '/planner/recipe_update')

	const parentId = e.item.parentNode.id
	e.item.setAttribute('data-parent-id', parentId)

	checkForUpdates(function(shoppingList) {
	  renderShoppingList(shoppingList, true)
	})
}

const deletePlannerRecipe = (deleteBtn) => {
	const buttonParent = deleteBtn.parentNode
	const dateId = buttonParent.dataset.parentId
	const recipeId = buttonParent.id
	const deleteString = "recipe_id=" + recipeId + "&date=" + dateId
	if (window.confirm("Deleting this recipe will remove it from your planner, all your associated stock will stay in your cupboards")) {
		ajaxRequest(deleteString, '/planner/recipe_delete')

		const recipeList = document.querySelector('[data-recipe-list]')
		const recipeAllLink = recipeList.querySelector('a.list_block--item.list_block--item_new')
		deleteBtn.remove()
		recipeList.insertBefore(buttonParent, recipeAllLink)

		checkForUpdates(function(shoppingList) {
			renderShoppingList(shoppingList, true)
		})
	}
}

const plannerFn = () => {
	if (document.body.classList.contains('planner_controller') && document.body.classList.contains('index_page')) {
		const slider = tns({
			container: '[data-planner]',
			items: 1,
			slideBy: 1,
			startIndex: 1,
			loop: false,
			gutter: 10,
			edgePadding: 40,
			arrowKeys: true,
			swipeAngle: false,
			controlsContainer: '.tiny-controls',
			nav: false,
			responsive: {
				420: {
					items: 1
				},
				640: {
					items: 2
				},
				900: {
					items: 3
				},
				1200: {
					items: 4
				}
			}
		});

		const recipeList = document.querySelector('[data-recipe-list]')
		const plannerBlocks = document.querySelectorAll('[data-planner] .tiny-slide:not(.yesterday) .tiny-drop')
		if (isMobileDevice() === false) {
			new Sortable.create(recipeList, {
				group: {
					name: 'recipe-sharing',
					put: false,
				},
				filter: '.non_sortable',
				sort: false,
				onEnd: function(e) {
					if (e.item.parentNode.classList.contains('tiny-drop')){
						addPlannerRecipe(e)
					}
				}
			})
			plannerBlocks.forEach(function(dayBlock){
				new Sortable.create(dayBlock, {
					group: {
						name: 'recipe-sharing',
						pull: true,
						put: true
					},
					onEnd: function(e) {
						updatePlannerRecipe(e)
					}
				})
			})
		}

		const plannerRecipeDeleteButtons = document.querySelectorAll('.tiny-slide .list_block--item button.delete')

		plannerRecipeDeleteButtons.forEach(function(deleteBtn){
			deleteBtn.addEventListener("click", function(){deletePlannerRecipe(deleteBtn)})
		})

	}
	if (document.body.classList.contains('recipes_controller') && document.body.classList.contains('index_page')) {
		const recipeAddToPlannerButtons = document.querySelectorAll('.list_block--action_row .add_recipe_to_planner')
		recipeAddToPlannerButtons.forEach(function(addBtn){
			const recipeId = addBtn.getAttribute('data-recipe-id')
			addBtn.addEventListener("click", function(){
				ajaxRequest(plannerRecipeAddData(recipeId), '/planner/recipe_add')
				addBtn.style.display = 'none'
				checkForUpdates(function(shoppingList) {
					renderShoppingList(shoppingList, true)
				})
				showAlert(`Recipe added to your <a href="/planner">planner</a><br />Your shopping list is now updating`)
			})
		})
	}
	if (document.body.classList.contains('recipes_controller') && document.body.classList.contains('show_page')) {
		if (document.querySelector('#add_recipe_to_planner')) {
			const recipeAddToPlannerButton = document.querySelector('#add_recipe_to_planner')
			const recipeId = recipeAddToPlannerButton.getAttribute('data-recipe-id')
			recipeAddToPlannerButton.addEventListener("click", function(){
				ajaxRequest(plannerRecipeAddData(recipeId), '/planner/recipe_add')
				recipeAddToPlannerButton.style.display = 'none'
				checkForUpdates(function(shoppingList) {
					renderShoppingList(shoppingList, true)
				})
				showAlert(`Recipe added to your <a href="/planner">planner</a><br />Your shopping list is now updating`)
			})
		}
	}


	if (document.querySelector('.planner_shopping_list--inner')) {
		if(document.querySelector('.planner_shopping_list--wrapper .list_toggle')) {
			setupShoppingListButton()
		}
		checkForUpdates(function(shoppingList) {
			renderShoppingList(shoppingList)
		})
	}

	if (document.body.classList.contains('planner_controller') && document.body.classList.contains('list_page')) {

	}

}

ready(plannerFn)
