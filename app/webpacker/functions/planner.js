import { ready, ajaxRequest, showAlert } from './utils'
import Sortable from 'sortablejs'
import {tns} from 'tiny-slider/src/tiny-slider'
import SVG from '../icons/symbol-defs.svg'
import PNGBin from '../icons/png-icons/bin.png'
import PNGInfoOutline from '../icons/png-icons/information-outline.png'
import PNGFullscreen from '../icons/png-icons/fullscreen.png'
import PNGFullscreenExit from '../icons/png-icons/fullscreen_exit.png'

const plannerRecipeAddData = (id, date) => (
	"recipe_id=" + id + "&planner_date=" + date
)

const plannerRecipeUpdateData = (e) => (
	"recipe_id=" + e.item.id + "&old_date=" + e.item.dataset.parentId + "&new_date=" + e.item.parentNode.id
)


const showWhiskList = () => {
	whisk.queue.push(function() {
		whisk.shoppingList.viewList({
			styles: {
				type: 'modal',
			},
		});
	});
}

const addToWhiskList = (whiskListPortions) => {
	whisk.queue.push(function() {
		whisk.shoppingList.addProductsToList({
			products: whiskListPortions
		})
	});
	ajaxRequest('Add Shopping list', '/stocks/add_shopping_list')
	setTimeout(() => checkForUpdates(function(shoppingList) {
		renderShoppingList(shoppingList)
		showAlert(`Shopping List items added to your <a href="/cupboards">cupboards</a>`)
	}), 2000)
}

const setupAddToWhiskShoppingListButton = (whiskListPortions) => {
	if (document.querySelector('#whisk-add-products')) {
		document.querySelector('#whisk-add-products').addEventListener('click', () => addToWhiskList(whiskListPortions))
	}
	if (document.querySelector('#view-whisk-list')) {
		document.querySelector('#view-whisk-list').removeEventListener('click', showWhiskList)
	}
}

const setupViewWhiskShoppingListButton = () => {
	if (document.querySelector('#view-whisk-list')) {
		document.querySelector('#view-whisk-list').addEventListener('click', showWhiskList)
	}
	if (document.querySelector('#whisk-add-products')) {
		document.querySelector('#whisk-add-products').removeEventListener('click', addToWhiskList)
	}
}


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

const updateShoppingListCheckCount = (shoppingList) => {
	const ShoppingListInner = document.querySelector('.planner_shopping_list--inner')
	const ShoppingListTitleBlock = ShoppingListInner.querySelector('.title_block')
	const ShoppingListTitle = ShoppingListTitleBlock.querySelector('h2')
	if (shoppingList.length === 0 ){
		ShoppingListTitle.innerText = 'Shopping List'
	} else {
		const ShoppingListTitleContent = 'Shopping List (' + shoppingList[0]["stats"]["checked_portions"] + '/' + shoppingList[0]["stats"]["total_portions"] + ')'
		ShoppingListTitle.innerText = ShoppingListTitleContent
	}
}

const renderShoppingList = (shoppingList) => {

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
	const shopOnlineBlock = document.querySelector('.shop_online_block')

	if (shoppingList.length === 0 ){
		ShoppingListTitle.innerText = 'Shopping List'
		shopOnlineBlock.innerHTML = `<button id="view-whisk-list" class="list_block--collection--action">Open online shopping list</button>`
		if (ShoppingList) {
			hideShoppingList()
		}
		ListTopUl.innerHTML = '<p>Shopping List is currently empty, move some recipes to <a href="/planner">your planner</a> to get items added to this list</p>'
		setupViewWhiskShoppingListButton()
		if (ShoppingListTitleNote !== null) {
			ShoppingListTitleNote.style.display = 'none'
		}
		if (ShoppingListTitleFullscreenBtn !== null) {
			ShoppingListTitleFullscreenBtn.style.display = 'none'
		}
	} else {
		const GenId = shoppingList[2]["gen_id"]
		const whiskShoppingListPortions = []
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

			RecipePortionLiTag = '<h6 class="mb-2">' + portion["portion_note"] + '</h6>'
			const RecipePortionLiP = '<p><label><input type="checkbox" ' + (portion["checked"] === "true" && 'checked') + '> ' + portion["portion_description"] + '</label></p><hr />'
			// <h5>Use by date:</h5><p><input type="date" value="' + portion["max_date"] + '" min="' + portion["min_date"] + '"></p>
			RecipePortionLi.innerHTML = RecipePortionLiTag + RecipePortionLiP
			ListTopUl.appendChild(RecipePortionLi)

			whiskShoppingListPortions.push(portion["portion_description"])

		})

		if (ShoppingList) {
			if (shoppingList[0]["stats"]["checked_portions"] === shoppingList[0]["stats"]["total_portions"]) {
				hideShoppingList()
			} else {
				showShoppingList()
			}
		}

		shopOnlineBlock.innerHTML = `<button id="whisk-add-products" class="list_block--collection--action">Add to online shopping list</button>`
		setupAddToWhiskShoppingListButton(whiskShoppingListPortions)
	}
	OldShoppingListContent.remove()
	ShoppingListInner.appendChild(ListTopUl)
	if (ShoppingList) {
		ShoppingList.appendChild(ShoppingListInner)
	} else {
		document.querySelector('main').prepend(ShoppingListInner)
	}
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
		toggleBtn.addEventListener("click", function(){
			html.classList.toggle('shopping_list_open')
		})
	}
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
			// const date = portionLi.querySelector('input[type="date"]').value

			const portionData = "shopping_list_portion_id=" + portionId + "&portion_type=" + portionType + (genId !== null ? "&gen_id=" + genId : "")
			portionLi.classList.toggle('portion_checked')
			if (portionCheckbox.checked) {
				ajaxRequest(portionData, '/stocks/add_portion')
			} else {
				ajaxRequest(portionData, '/stocks/remove_portion')
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
	  renderShoppingList(shoppingList)
	})

}

const updatePlannerRecipe = (e) => {
	ajaxRequest(plannerRecipeUpdateData(e), '/planner/recipe_update')

	const parentId = e.item.parentNode.id
	e.item.setAttribute('data-parent-id', parentId)

	checkForUpdates(function(shoppingList) {
	  renderShoppingList(shoppingList)
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
			renderShoppingList(shoppingList)
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

		const plannerRecipeDeleteButtons = document.querySelectorAll('.tiny-slide .list_block--item button.delete')

		plannerRecipeDeleteButtons.forEach(function(deleteBtn){
			deleteBtn.addEventListener("click", function(){deletePlannerRecipe(deleteBtn)})
		})

	}
	if (document.body.classList.contains('recipes_controller') && document.body.classList.contains('index_page')) {
		const recipeAddToPlannerButtons = document.querySelectorAll('.list_block--action_row .add_recipe_to_planner')
		recipeAddToPlannerButtons.forEach(function(addBtn){
			const recipeId = addBtn.getAttribute('data-recipe-id')
			const date = addBtn.getAttribute('data-date')
			addBtn.addEventListener("click", function(){
				ajaxRequest(plannerRecipeAddData(recipeId, date), '/planner/recipe_add')
				addBtn.style.display = 'none'
				checkForUpdates(function(shoppingList) {
					renderShoppingList(shoppingList)
				})
				showAlert(`Recipe added to your <a href="/planner">planner</a><br />Your shopping list is now updating`)
			})
		})
	}
	if (document.body.classList.contains('recipes_controller') && document.body.classList.contains('show_page')) {
		if (document.querySelector('#add_recipe_to_planner')) {
			const recipeAddToPlannerButton = document.querySelector('#add_recipe_to_planner')
			const recipeId = recipeAddToPlannerButton.getAttribute('data-recipe-id')
			const date = recipeAddToPlannerButton.getAttribute('data-date')
			recipeAddToPlannerButton.addEventListener("click", function(){
				ajaxRequest(plannerRecipeAddData(recipeId, date), '/planner/recipe_add')
				recipeAddToPlannerButton.style.display = 'none'
				checkForUpdates(function(shoppingList) {
					renderShoppingList(shoppingList)
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
		setupViewWhiskShoppingListButton()
	}

}

ready(plannerFn)
