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
	const ShoppingList = document.querySelector('#planner_shopping_list')

	const ListTopUl = document.createElement('ul')

	const OldShoppingListContent = document.querySelector('#planner_shopping_list > ul')

	if (shoppingListItems.length === 0 ){
		hideShoppingList()
		ListTopUl.innerHTML = '<p>Shopping List is currently empty, move some recipes to your planner to get items added to this list</p>'
	} else {
		shoppingListItems.forEach(function(planner_recipe) {
			const ListRecipeLi = document.createElement('li')
			const ListRecipeTitle = document.createElement('h3')
			ListRecipeTitle.innerHTML = planner_recipe[0]["planner_recipe_description"]
			ListRecipeLi.appendChild(ListRecipeTitle)
			const RecipePortionUl = document.createElement('ul')
			RecipePortionUl.classList.add('planner_sl-recipe_list')
			planner_recipe.forEach(function(portion) {
				const RecipePortionLi = document.createElement('li')
				RecipePortionLi.innerHTML = '<p><label><input type="checkbox" name="planner_shopping_list_portions['+ portion["shopping_list_portion_id"] +'][add]" id="planner_shopping_list_portions_id_add" value="'+ portion["shopping_list_portion_id"] +'"> ' + portion["portion_description"] + '</label></p><h5>Use by date:</h5><p><input type="date" name="planner_shopping_list_portions['+ portion["shopping_list_portion_id"] +'][date]" id="planner_shopping_list_portions_id_date" value="2019-09-15" min="2019-09-01"></p><hr />'
				RecipePortionUl.appendChild(RecipePortionLi)
			})
			ListRecipeLi.appendChild(RecipePortionUl)
			ListTopUl.appendChild(ListRecipeLi)
		})

		showShoppingList()
	}
	OldShoppingListContent.remove()
	ShoppingList.appendChild(ListTopUl)
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
	const toggleBtn = document.querySelector('#planner_shopping_list .list_toggle')
	toggleBtn.addEventListener("click", function(){
		html.classList.toggle('shopping_list_open')
	})
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

	setupShoppingListButton()

}

ready(dashboardFn)
