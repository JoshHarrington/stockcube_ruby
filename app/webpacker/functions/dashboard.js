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

const updateShoppingList = () => {
	let plannerShoppingListItems = window.plannerShoppingListItems

	const ShoppingList = document.querySelector('[data-shopping-list]')

	const ListBlockContent = document.createElement('div')
	const ajaxRequestOutput = ajaxRequest(plannerShoppingListItems, '/planner/shopping_list', 'GET', 'plannerShoppingListItems')

	let iterations = 0
	const ajaxCheck = () => {
		if (window.plannerShoppingListItems === plannerShoppingListItems && iterations < 10) {
			// running a check for ajax output
			++iterations
			const checkForplannerShoppingListItems = window.setTimeout(() => {ajaxCheck()}, .2*1000)
		} else {
			// ajax output is set
			plannerShoppingListItems = window.plannerShoppingListItems
			const previousListBlockContent = document.querySelector('[data-shopping-list] .list_block--content')
			ListBlockContent.classList.add('list_block--content', 'pb-1')
			if (plannerShoppingListItems.length === 0 ){
				ListBlockContent.innerHTML = 'Add some recipes to planner or add your own custom items!'
			} else {
				plannerShoppingListItems.forEach(function(item) {
					const Ingredient = document.createElement('div')
					Ingredient.classList.add('list_block--item')
					Ingredient.innerHTML = item
					ListBlockContent.appendChild(Ingredient)
				})
			}
			previousListBlockContent.remove()
			ShoppingList.appendChild(ListBlockContent)

			const LoadingNotice = document.querySelector('.loading-block')
			LoadingNotice.remove()
		}
	}

	ajaxCheck()

}

const updateShoppingListWithDelay = () => {
	const ShoppingList = document.querySelector('[data-shopping-list]')
	const LoadingBlock = document.createElement('div')
	LoadingBlock.classList.add('loading-block')
	LoadingBlock.innerHTML = `<span class="loading-notice">Updating...</span>`
	ShoppingList.appendChild(LoadingBlock)

	const shoppingListDelay = window.setTimeout(() => {
		updateShoppingList()
	}, .4*1000)
}


window.updateShoppingList = updateShoppingList

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

	updateShoppingListWithDelay()

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

	updateShoppingListWithDelay()
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
