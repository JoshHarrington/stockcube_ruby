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

const updateNeeded = () => {
	const shopping_list_update_string = document.querySelector('#shopping_list_update')
	shopping_list_update_string.style.display = "block"
	const shopping_list_update_btn = document.querySelector('#shopping_list_update button')
	shopping_list_update_btn.addEventListener("click", function(){reloadPage()})
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

	updateNeeded()
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

	updateNeeded()
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
