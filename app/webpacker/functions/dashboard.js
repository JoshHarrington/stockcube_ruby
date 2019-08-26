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
	ajaxRequest(plannerShoppingListItems, '/planner/shopping_list', 'GET', 'plannerShoppingListItems')

	const ajaxCheck = (iterations = 0) => {
		let resp = window.plannerShoppingListItems
		let data = plannerShoppingListItems
		let difference = false
		if (resp.length === 0 && resp.length !== data.length) {
			difference = true
		} else if ( resp.filter(x => !data.includes(x)).length !== 0 || data.filter(x => !resp.includes(x)).length !== 0) {
			difference = true
		}
		if (!difference && iterations < 10) {
			// running a check for ajax output
			const checkForplannerShoppingListItems = window.setTimeout(() => {ajaxCheck(iterations + 1)}, .3*1000)
		} else if (difference) {
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

			const LoadingNotices = document.querySelectorAll('.loading-block')
			if (LoadingNotices !== undefined && LoadingNotices !== null) {
				for(let i = 0; i < LoadingNotices.length; i++) {
					LoadingNotices[i].remove()
				}
			}
		} else {

			// shopping list couldn't be updated, setup fallback
			const LoadingNotices = document.querySelectorAll('.notices')
			if (LoadingNotices !== undefined && LoadingNotices !== null) {
				for(let i = 0; i < LoadingNotices.length; i++) {
					LoadingNotices[i].remove()
				}
			}
			const FailureNotice = document.createElement('div')
			FailureNotice.classList.add('fail_notice', 'notices')
			FailureNotice.innerHTML = `Looks like there was a problem updating the shopping list. We'll try again in a moment.`
			ShoppingList.appendChild(FailureNotice)

			const shoppingListExtraDelay = window.setTimeout(() => {
				updateShoppingListWithDelay()
			}, 1.5*1000)

		}
	}

	ajaxCheck()

}

const updateShoppingListWithDelay = () => {
	const ShoppingList = document.querySelector('[data-shopping-list]')
	const LoadingNoticePrev = document.querySelectorAll('.notices')
	if (LoadingNoticePrev.length === 0) {
		const LoadingNoticeNew = document.createElement('div')
		LoadingNoticeNew.classList.add('loading-block', 'notices')
		LoadingNoticeNew.innerHTML = `<span class="loading-notice">Updating...</span>`
		ShoppingList.appendChild(LoadingNoticeNew)
	}

	const shoppingListDelay = window.setTimeout(() => {
		updateShoppingList()
	}, .6*1000)
}


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
