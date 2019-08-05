import { ready } from './utils'
import Sortable from 'sortablejs'

const dashboardFn = () => {
	const recipeList = document.querySelector('[data-recipe-list]')
	const planner = document.querySelectorAll('[data-planner] .list_block')
	new Sortable.create(recipeList, {
		group: {
			name: 'recipe-sharing',
			pull: 'clone',
			put: false,
		},
		sort: false
	})
	planner.forEach(function(dayBlock, i){
		new Sortable.create(dayBlock, {
			group: {
				name: 'recipe-sharing',
				pull: true,
				put: true
			}
		})

	});
}

ready(dashboardFn)
