import { ready, ajaxRequest, showAlert, isMobileDevice } from './utils'
import Sortable from 'sortablejs'
import Choices from 'choices.js'
import {tns} from 'tiny-slider/src/tiny-slider'
import SVG from '../icons/symbol-defs.svg'
import PNGBin from '../icons/png-icons/bin.png'
import PNGInfoOutline from '../icons/png-icons/information-outline.png'
import PNGFullscreen from '../icons/png-icons/fullscreen.png'
import PNGFullscreenExit from '../icons/png-icons/fullscreen_exit.png'

const plannerRecipeAddData = (recipeId, date = null) => {
	if (date && date != null) {
		return "recipe_id=" + recipeId + "&planner_date=" + date
	} else {
		return "recipe_id=" + recipeId
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
			if (portion["checked"] === true){
				RecipePortionLi.classList.add('portion_checked')
			}
			let RecipePortionLiTag

			if (portion["portion_type"] == "individual") {
				RecipePortionLi.classList.add('individual_portion')
			} else {
				RecipePortionLi.classList.add('combi_portion')
			}

			RecipePortionLiTag = '<h6 class="mb-3 portion_recipe_tag">' + portion["portion_note"] + '</h6>'


			let InStockNote = ''

			if (portion["in_stock"] !== 0){
				InStockNote = `<span style="width: 100%;
				font-size: 1.1rem;
				color: #656565;">${portion["in_stock"]}% already in stock</span>`
			}
			const RecipePortionLiP = '<p class="h3 portion_ingredient_name"><input type="checkbox" id="planner_shopping_list_portions_add_'+ portion["shopping_list_portion_id"] + '" class="fancy_checkbox" ' + (portion["checked"] === true && 'checked') + '> ' + '<label for="planner_shopping_list_portions_add_'+ portion["shopping_list_portion_id"] + '" class="fancy_checkbox_label" style="flex-wrap:wrap"><span>' + portion["portion_description"] + '</span>' + InStockNote +'</label></p>'

			const ChildPortionsUl = document.createElement('ul')
			if (portion["portion_type"] == "combi" && portion["child_portions"] !== null) {

				portion["child_portions"].forEach((childPortion) => {
					const ChildPortionLi = document.createElement('li')
					ChildPortionLi.setAttribute('id', childPortion["shopping_list_portion_id"])
					ChildPortionLi.classList.add('shopping_list_portion_child','mb-3', 'individual_portion')

					if (childPortion["checked"] === true){
						ChildPortionLi.classList.add('portion_checked')
					}

					const ChildPortionRecipeTag = '<h6 class="mb-2 portion_recipe_tag faded">' + childPortion["recipe_title"] + '</h6>'

					let ChildInStockNote = ''

					if (childPortion["in_stock"] !== 0){
						ChildInStockNote = `<span style="width: 100%;
						font-size: 1.1rem;
						color: #656565;">${childPortion["in_stock"]}% already in stock</span>`
					}
					const ChildPortionLiP = '<p class="h3 portion_ingredient_name"><input type="checkbox" id="planner_shopping_list_portions_add_'+ childPortion["shopping_list_portion_id"] + '" class="fancy_checkbox" ' + (childPortion["checked"] === true && 'checked') + '> ' + '<label for="planner_shopping_list_portions_add_'+ childPortion["shopping_list_portion_id"] + '" class="fancy_checkbox_label" style="flex-wrap:wrap"><span>' + childPortion["portion_description"]+ '</span>' + ChildInStockNote +'</label></p>'

					const ChildPortionSizeHidden = '<input type="hidden" name="planner_shopping_list_portions_amount'+ childPortion["shopping_list_portion_id"] +'" value="'+ childPortion["portion_amount"] +'" />'
					const ChildPortionDateHidden = '<input type="hidden" name="planner_shopping_list_portions_date_'+ childPortion["shopping_list_portion_id"] +'" value="' + childPortion["portion_date"] + '" />'


					ChildPortionLi.innerHTML = ChildPortionRecipeTag + ChildPortionLiP + ChildPortionSizeHidden + ChildPortionDateHidden
					ChildPortionsUl.appendChild(ChildPortionLi)
				})
			}

			// const RecipePortionLiSizeRow = '<div class="shopping_list_portion-size_row"><input type="number" name="planner_shopping_list_portions_amount'+ portion["shopping_list_portion_id"] +'" value="'+ portion["portion_amount"] +'" /><select name="planner_shopping_list_portions_unit_'+ portion["shopping_list_portion_id"] +'" class="choices--basis pretty_form--row--pretty_select">'+
			// UnitList.map((u) => {
			// 	if (u["id"] === portion["portion_unit"]) {
			// 		return `<option selected value="${u["id"]}">${u["name"]}</option>`
			// 	}
			// 	return `<option value="${u["id"]}">${u["name"]}</option>`
			// })
			// +'</select></div>'
			/// Remove min for amount until able to manage it properly
			// min="'+ portion["portion_amount"] +'"

			const RecipePortionSizeHidden = '<input type="hidden" name="planner_shopping_list_portions_amount'+ portion["shopping_list_portion_id"] +'" value="'+ portion["portion_amount"] +'" />'


			const RecipePortionLiDateRow = '<div class="shopping_list_portion-date_row"><p class="shopping_list_portion-date_row-tag h6">Use by date:</p><input type="date" min="' + portion["min_date"] + '" name="planner_shopping_list_portions_date_'+ portion["shopping_list_portion_id"] +'" value="' + portion["portion_date"] + '" placeholder="' + portion["portion_date"] + '" /></div><hr />'
			const RecipePortionDateHidden = '<input type="hidden" name="planner_shopping_list_portions_date_'+ portion["shopping_list_portion_id"] +'" value="' + portion["portion_date"] + '" />'

			const FreshForRow = '<p style="width: 100%;margin-top: 0.7rem;font-size: 1.1rem;color: gray;">Fresh for '+ portion['fresh_for'] +' days</p></div><hr />'


			let RecipePortionLiContentsPartial = RecipePortionLiTag + RecipePortionLiP + RecipePortionSizeHidden + RecipePortionDateHidden


			if (ChildPortionsUl.hasChildNodes()) {
				RecipePortionLi.innerHTML = RecipePortionLiContentsPartial
				RecipePortionLi.appendChild(ChildPortionsUl)
				const HR = document.createElement('hr')
				RecipePortionLi.appendChild(HR)
			} else {
				RecipePortionLi.innerHTML = RecipePortionLiContentsPartial + FreshForRow
			}


			ListTopUl.appendChild(RecipePortionLi)

		})

		if (ShoppingList) {
			if (shoppingList[0]["stats"]["checked_portions"] === shoppingList[0]["stats"]["total_portions"]) {
				hideShoppingList()
				updateButtonFractionSpan()
			} else if (animated) {
				if (isMobileDevice() === false) {
					showShoppingList()
				}
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
	if (selectEl.length > 0){
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
		if (portionLi.classList.contains('individual_portion')) {
			portionType = 'individual_portion'
		} else {
			portionType = 'combi_portion'
		}

		console.log('unitSelect', unitSelect)
		const unitSelect = portionLi.querySelector('select')
		let unitId = unitSelect ? unitSelect.value : null


		console.log('amountInput', amountInput)
		const amountInput = portionLi.querySelector('input[name*="planner_shopping_list_portions_amount"]')
		let amount = amountInput.value


		console.log('dateInput', dateInput)
		const dateInput = portionLi.querySelector('input[name*="planner_shopping_list_portions_date_"]')
		let date = dateInput.value

		const portionData = {	"shopping_list_portion_id": portionId,
													"portion_type": portionType,
													"amount": amount,
													"unit_id": unitId,
													"date": date }

		if (genId !== null) {
			portionData.gen_id = genId
		}

		if (unitSelect) {
			unitSelect.addEventListener("change", (e) => {
				unitId = e.target.value
				portionData.unit_id = unitId
				updatePortionData(portionData)
			})
		}
		if (portionLi.querySelector('input[type="number"][name*="planner_shopping_list_portions_amount"]')) {
			amountInput.addEventListener("change", (e) => {
				amount = e.target.value
				portionData.amount = amount
				updatePortionData(portionData)
			})
		}
		if (portionLi.querySelector('input[type="date"][name*="planner_shopping_list_portions_date_"]')) {
			dateInput.addEventListener("change", (e) => {
				date = e.target.value
				portionData.date = date
				updatePortionData(portionData)
			})
		}
	})
}

const setupShoppingListCheckingOff = () => {
	let genId = null
	if (window.location.pathname.includes('/list/')){
		genId = window.location.pathname.replace('/list/','')
	}
	const shoppingListPortionsChecks = document.querySelectorAll('.planner_shopping_list--inner .planner_sl-recipe_list li input[type="checkbox"]')
	shoppingListPortionsChecks.forEach((portionCheckbox) => {

		portionCheckbox.addEventListener("change", function(){
			const portionLi = portionCheckbox.closest('li')
			const portionId = portionLi.getAttribute('id')

			let portionType = ''
			console.log("portionLi", portionLi)
			if (portionLi.classList.contains('individual_portion')) {
				portionType = 'individual_portion'
			} else {
				portionType = 'combi_portion'
			}

			const portionData = "shopping_list_portion_id=" + portionId + "&portion_type=" + portionType + (genId !== null ? "&gen_id=" + genId : "")
			portionLi.classList.toggle('portion_checked')


			if (portionType == 'combi_portion') {
				portionLi.querySelectorAll('li').forEach((childPortion) => {
					if (portionCheckbox.checked) {
						childPortion.classList.add('portion_checked')
						childPortion.querySelector('input[type="checkbox"]').checked = true
					} else {
						childPortion.classList.remove('portion_checked')
						childPortion.querySelector('input[type="checkbox"]').checked = false
					}
				})
			}

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

const newPlannerRecipeComponent = (jsonResponse) => {

	const plannerId = jsonResponse["planner_id"]
	const recipeId = jsonResponse["recipe_id"]
	const recipeHref = jsonResponse["recipe_href"]
	const recipeTitle = jsonResponse["recipe_title"]
	const percentInCupboards = jsonResponse["percent_in_cupboards"]

	const component = document.createElement('div')
	component.classList.add('list_block--item', 'list_block--item--with-bar', 'sortable--item')
	component.setAttribute('data-parent-id', plannerId)
	component.id = recipeId

	const trackingBar = document.createElement('span')
	trackingBar.classList.add('list_block--item--tracking_bar')

	const trackingBarFill = document.createElement('span')
	trackingBarFill.classList.add('list_block--item--tracking_bar-percent')
	trackingBarFill.style.width = percentInCupboards

	trackingBar.appendChild(trackingBarFill)
	component.appendChild(trackingBar)

	const recipeLink = document.createElement('a')

	recipeLink.innerText = recipeTitle
	recipeLink.setAttribute('href', recipeHref)

	component.appendChild(recipeLink)

	const deleteBtn = document.createElement('button')
	deleteBtn.innerHTML = `<svg class="icomoon-icon icon-bin"><use xlink:href="${SVG}#icon-bin"></use></svg><img class="icon-png" src="${PNGBin}" />`
	deleteBtn.classList.add('delete', 'list_block--item--action', 'list_block--item--action--btn')

	component.appendChild(deleteBtn)

	deleteBtn.addEventListener("click", () => deletePlannerRecipe(deleteBtn))

	return component
}

const addPlannerRecipe = (el, recipeId, date = null) => {


	/// if date comes in, then the recipe has been placed in the planner
	/// no response back from the backend is needed (except maybe if there was an error)

	const dataBody = {recipe_id: recipeId}
	if (date != null) {
		dataBody.planner_date = date
	}
	const data = {
		method: 'post',
		body: JSON.stringify(dataBody),
		headers: {
			'Content-Type': 'application/json',
			'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
		},
		credentials: 'same-origin'
	}

	fetch("planner/recipe_add", data).then((response) => {
		if(response.status != 200){
			window.alert('Something went wrong! Maybe refresh the page and try again')
		} else {
			return response.json();
		}
	}).then((jsonResponse) => {
		if (date === null) {
			const plannerId = jsonResponse["planner_id"]
			const plannerBlock = document.getElementById(plannerId)

			plannerBlock.appendChild(
				newPlannerRecipeComponent(jsonResponse)
			)
			if (window.slider) {
				const tnsSlideId = plannerBlock.parentNode.id
				const TrimmedTnsSlideId = tnsSlideId.replace(/tns1-item/g,'')
				window.slider.goTo(TrimmedTnsSlideId)
			}
		}
		showAlert(`${jsonResponse["recipe_title"]} has been added to your planner, shopping list is updating`, 20000)
	});


	if (date !== null) {
		if (el.querySelector('button[data-type="add-to-planner"]')) {
			el.querySelector('button[data-type="add-to-planner"]').remove()
		}

		const deleteBtn = document.createElement('button')
		deleteBtn.innerHTML = `<svg class="icomoon-icon icon-bin"><use xlink:href="${SVG}#icon-bin"></use></svg><img class="icon-png" src="${PNGBin}" />`
		deleteBtn.classList.add('delete', 'list_block--item--action', 'list_block--item--action--btn')

		const parentId = el.parentNode.id
		el.setAttribute('data-parent-id', parentId)

		el.appendChild(deleteBtn)
		deleteBtn.addEventListener("click", () => deletePlannerRecipe(deleteBtn))
	} else {
		el.remove()
	}

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
	const ingredientsInStock = buttonParent.dataset.ingredientsInStock
	const recipeId = buttonParent.id
	const deleteString = "recipe_id=" + recipeId + "&date=" + dateId


	if ((ingredientsInStock != 0 && window.confirm("Deleting this recipe will remove it from your planner, all your associated stock will stay in your cupboards") || ingredientsInStock == 0)) {
		ajaxRequest(deleteString, '/planner/recipe_delete')

		const recipeList = document.querySelector('[data-recipe-list]')
		const recipeAllLink = recipeList.querySelector('a.list_block--item.list_block--item_new')
		deleteBtn.remove()

		const addBtn = document.createElement('button')
		addBtn.innerHTML = `<svg class="icomoon-icon icon-list-add"><use xlink:href="${SVG}#icon-list-add"></use></svg>`
		addBtn.classList.add('list_block--item--action', 'list_block--item--action--btn', 'svg-btn')
		addBtn.style.cssText = "padding: 0.4em; min-width: 2em; margin: .4rem 0 .4rem .6rem"
		addBtn.setAttribute('data-type', 'add-to-planner')

		buttonParent.appendChild(addBtn)
		addBtn.addEventListener('click', () => addPlannerRecipe(buttonParent, recipeId))

		recipeList.insertBefore(buttonParent, recipeAllLink)

		checkForUpdates(function(shoppingList) {
			renderShoppingList(shoppingList, true)
		})
	}
}

const toggleDragAreaClass = (Planner, type) => {
	if (type && type === "add") {
		Planner.classList.add('show-drag-areas')
	} else if (type && type === "remove") {
		Planner.classList.remove('show-drag-areas')
	}
}

window.sortableObjects = []
const updatePlannerSliderSortable = (slides) => {
	const Planner = document.querySelector('[data-planner]')
	if (window.sortableObjects.length > 0) {
		for (let i = 0; i < window.sortableObjects.length; i++) {
			window.sortableObjects[i].destroy()
		}
		window.sortableObjects = []
	}
	for (let i = 0; i < slides.length; i++) {
		const slide = slides[i].querySelector('.tiny-contents')
		const sortable = new Sortable.create(slide, {
			group: {
				name: 'recipe-sharing',
				pull: true,
				put: true
			},
			fallbackOnBody: true,
			swapThreshold: 0.8,
			filter: '.no-drag',
			direction: 'horizontal',
			sort: false,
			animation: 50,
			ghostClass: 'tiny-drop-ghost',
			onStart: function() {
				toggleDragAreaClass(Planner, "add")
			},
			onEnd: function(e) {
				toggleDragAreaClass(Planner, "remove")
				updatePlannerRecipe(e)
			}
		})
		window.sortableObjects.push(sortable)
	}
}

const getCurrentSlideItems = (sliderInfo) => {
	let slideIndex = sliderInfo.index
	let slideItemsEnd = slideIndex + sliderInfo.items
	let slideItems = sliderInfo.slideItems
	return Array.from(slideItems).slice(slideIndex,slideItemsEnd)
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
			speed: 600,
			axis: 'horizontal',
			arrowKeys: true,
			swipeAngle: false,
			prevButton: '.tiny-control--prev',
			nextButton: '.tiny-control--next',
			mode: 'carousel',
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

		window.slider = slider


		const recipeList = document.querySelector('[data-recipe-list]')
		const Planner = document.querySelector('[data-planner]')

		if (isMobileDevice() === false) {
			new Sortable.create(recipeList, {
				group: {
					name: 'recipe-sharing',
					put: false,
				},
				filter: '.non_sortable',
				sort: false,
				animation: 50,
				direction: 'vertical',
				onStart: function(e){
					toggleDragAreaClass(Planner, "add")
				},
				onEnd: function(e) {
					toggleDragAreaClass(Planner, "remove")
					if (e.item.parentNode.classList.contains('tiny-contents')){
						addPlannerRecipe(e.item, e.item.id, e.item.parentNode.id)
					}
				}
			})

			updatePlannerSliderSortable(getCurrentSlideItems(slider.getInfo()))
			slider.events.on('indexChanged', () => {
				updatePlannerSliderSortable(getCurrentSlideItems(slider.getInfo()))
			})

		}

		const plannerRecipeDeleteButtons = document.querySelectorAll('.tiny-slide .list_block--item button.delete')

		plannerRecipeDeleteButtons.forEach(function(deleteBtn){
			deleteBtn.addEventListener("click", function(){deletePlannerRecipe(deleteBtn)})
		})

		const plannerAddRecipeButtons = document.querySelectorAll('[data-type="add-to-planner"]')
		plannerAddRecipeButtons.forEach((addBtn) => {
			const recipeId = addBtn.getAttribute('data-recipe-id')
			addBtn.addEventListener("click", function(){
				addPlannerRecipe(addBtn.parentNode, recipeId)
			})
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
