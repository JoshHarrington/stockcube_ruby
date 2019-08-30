import { ready, ajaxRequest } from './utils'
import Sortable from 'sortablejs'
import {tns} from 'tiny-slider/src/tiny-slider'
import SVG from '../icons/symbol-defs.svg'
import PNGBin from '../icons/png-icons/bin.png'

const plannerRecipeAddData = (e) => (
	"recipe_id=" + e.item.id + "&planner_date=" + e.item.parentNode.id
)

const plannerRecipeUpdateData = (e) => (
	"recipe_id=" + e.item.id + "&old_date=" + e.item.dataset.parentId + "&new_date=" + e.item.parentNode.id
)

const reloadPage = () => {
	location.reload(true)
}

const LoadingNotice = () => {
	const LoadingNotice = document.createElement('div')
	LoadingNotice.classList.add('loading', 'notices')
	LoadingNotice.innerHTML = `<span class="loading-message">Updating...</span>`
	return LoadingNotice
}

const FailureNotice = () => {
	const FailureNotice = document.createElement('div')
	FailureNotice.classList.add('failure', 'notices')
	FailureNotice.innerHTML = `Looks like there was a problem updating your shopping list. Reload the page to get the latest version.`
	return FailureNotice
}

const manageNotices = (leaveOrCreateByType = undefined) => {
	// if leaveOrCreateByType not defined then should clear all notices

	const Notices = document.querySelectorAll('.notices')
	if (Notices.length > 0) {
		for(let i = 0; i < Notices.length; i++) {
			if (!Notices[i].classList.contains(leaveOrCreateByType)) {
				// this notice is not wanted, so remove it
				Notices[i].remove()
			}
		}
	}
	const ShoppingList = document.querySelector('[data-shopping-list]')
	console.log(leaveOrCreateByType, ' :leaveOrCreateByType')
	console.log(leaveOrCreateByType === 'loading', '=== loading')
	console.log(leaveOrCreateByType === 'failure', '=== failure')
	switch (leaveOrCreateByType) {
		case 'loading':
			ShoppingList.appendChild(LoadingNotice())
		case 'failure':
			ShoppingList.appendChild(FailureNotice())
	}


}

function checkForUpdates(onSuccess) {
  setTimeout(() => fetch("/planner/shopping_list").then((response) => {
    if(response.status != 200){
      setTimeout(() => checkForUpdates(onSuccess), 200)
    } else {
      response.json().then(onSuccess)
    }
  }), 400)
}

const renderShoppingList = (shoppingListItems) => {
	const ShoppingList = document.querySelector('[data-shopping-list]')
	const ListBlockContent = document.createElement('div')
	const previousListBlockContent = document.querySelector('[data-shopping-list] .list_block--content')
	ListBlockContent.classList.add('list_block--content', 'pb-1')
	if (shoppingListItems.length === 0 ){
		ListBlockContent.innerHTML = '<p>Add some recipes to planner or add your own custom items!</p>'
	} else {
		shoppingListItems.forEach(function(item) {
			const Ingredient = document.createElement('div')
			Ingredient.classList.add('list_block--item')
			Ingredient.innerHTML = item
			ListBlockContent.appendChild(Ingredient)
		})
	}
	previousListBlockContent.remove()
	ShoppingList.appendChild(ListBlockContent)
}


// const updateShoppingList = (delay = 0, parentIterations = 0, prevState = undefined) => {

// 	if (prevState !== 'failing') {
// 		manageNotices('loading')
// 	}

// 	const shoppingListDelay = window.setTimeout(() => {

// 		let plannerShoppingListItems = window.plannerShoppingListItems

// 		const ShoppingList = document.querySelector('[data-shopping-list]')

// 		const ListBlockContent = document.createElement('div')
// 		ajaxRequest(plannerShoppingListItems, '/planner/shopping_list', 'GET', 'plannerShoppingListItems', parentIterations)

// 		const ajaxCheck = (iterations = parentIterations) => {
// 			let resp = window.plannerShoppingListItems
// 			let data = plannerShoppingListItems
// 			let difference = false
// 			if (resp.length === 0 && resp.length !== data.length) {
// 				difference = true
// 			} else if ( resp.filter(x => !data.includes(x)).length !== 0 || data.filter(x => !resp.includes(x)).length !== 0) {
// 				difference = true
// 			}
// 			if (difference) {
// 				console.log('iterations: ', iterations, 'success branch')
// 				// ajax output is set
// 				plannerShoppingListItems = window.plannerShoppingListItems
// 				const previousListBlockContent = document.querySelector('[data-shopping-list] .list_block--content')
// 				ListBlockContent.classList.add('list_block--content', 'pb-1')
// 				if (plannerShoppingListItems.length === 0 ){
// 					ListBlockContent.innerHTML = '<p>Add some recipes to planner or add your own custom items!</p>'
// 				} else {
// 					plannerShoppingListItems.forEach(function(item) {
// 						const Ingredient = document.createElement('div')
// 						Ingredient.classList.add('list_block--item')
// 						Ingredient.innerHTML = item
// 						ListBlockContent.appendChild(Ingredient)
// 					})
// 				}
// 				previousListBlockContent.remove()
// 				ShoppingList.appendChild(ListBlockContent)

// 				manageNotices()

// 			} else if (!difference && iterations < 15) {
// 				console.log('iterations: ', iterations, 'failing branch, less than 10 iterations')

// 				// running a check for ajax output
// 				manageNotices('loading')
// 				const checkForplannerShoppingListItems = window.setTimeout(() => {ajaxCheck(iterations + 1)}, .4*1000)
// 			} else {
// 				console.log('iterations: ', iterations, 'failing branch, less than 20 iterations')

// 				// shopping list couldn't be updated, setup fallback

// 				manageNotices('failure')

// 				// updateShoppingList(10, 0, 'failing')
// 			}
// 		}

// 		ajaxCheck()

// 	}, delay*1000)

// }


// window.updateShoppingList = updateShoppingList

const addPlannerRecipe = (e) => {
	ajaxRequest(plannerRecipeAddData(e), '/planner/recipe_add')

	const deleteBtn = document.createElement('button')
	deleteBtn.innerHTML = `<svg class="icomoon-icon icon-bin"><use xlink:href="${SVG}#icon-bin"></use></svg><img class="icon-png" src="${PNGBin}"></button>`
	deleteBtn.classList.add('delete', 'list_block--item--action', 'list_block--item--action--btn')

	const trackingBar = document.createElement('span')
	trackingBar.classList.add('list_block--item--tracking_bar')
	trackingBar.setAttribute('title', 'Refresh page to see percentage of recipe in stock')

	const parentId = e.item.parentNode.id
	e.item.setAttribute('data-parent-id', parentId)
	e.item.classList.add('list_block--item--with-bar')

	e.item.prepend(trackingBar)
	e.item.appendChild(deleteBtn)
	deleteBtn.addEventListener("click", function(){deletePlannerRecipe(deleteBtn)})

// 	updateShoppingList(.6)
	checkForUpdates(function(shoppingListItems) {
	  renderShoppingList(shoppingListItems)
	})

}

const updatePlannerRecipe = (e) => {
	ajaxRequest(plannerRecipeUpdateData(e), '/planner/recipe_update')

	const parentId = e.item.parentNode.id
	e.item.setAttribute('data-parent-id', parentId)
}

const deletePlannerRecipe = (deleteBtn) => {
	const buttonParent = deleteBtn.parentNode
	const dateId = buttonParent.dataset.parentId
	const recipeId = buttonParent.id
	const deleteString = "recipe_id=" + recipeId + "&date=" + dateId
	ajaxRequest(deleteString, '/planner/recipe_delete')

	buttonParent.style.display = 'none'

// 	updateShoppingList(.6)
	checkForUpdates(function(shoppingListItems) {
	  renderShoppingList(shoppingListItems)
	})
}

const dashboardFn = () => {
	const recipeList = document.querySelector('[data-recipe-list]')
	const plannerBlocks = document.querySelectorAll('[data-planner] .tiny-drop')
	new Sortable.create(recipeList, {
		group: {
			name: 'recipe-sharing',
			pull: 'clone',
			put: false,
		},
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
  const slider = tns({
    container: '[data-planner]',
    items: 1,
		slideBy: 1,
		mouseDrag: true,
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

	const plannerRecipeDeleteButtons = document.querySelectorAll('.tiny-slide .list_block--item button.delete')

	plannerRecipeDeleteButtons.forEach(function(deleteBtn){
		deleteBtn.addEventListener("click", function(){deletePlannerRecipe(deleteBtn)})
	})

}

ready(dashboardFn)
