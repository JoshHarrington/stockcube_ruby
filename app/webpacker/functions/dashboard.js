import { ready } from './utils'
import Sortable from 'sortablejs'
import {tns} from 'tiny-slider/src/tiny-slider'

const recipeToPlannerMove = (e) => {
	if (e.dataset && e.dataset.plannerId) {
		return "recipe_id=" + e.item.id + "&planner_date=" + e.item.parentNode.id + "&planner_id" + e.item.dataset.plannerId
	} else {
		return "recipe_id=" + e.item.id + "&planner_date=" + e.item.parentNode.id
	}
}

let nextInterval = null
let prevInterval = null

let slider

const startSliderScroll = (direction) => {
	if (slider) {
		if (direction === 'next') {
			console.log('startSliderScroll, next')
			nextInterval = setInterval(function(){
				slider.goTo(direction)
			}, 400);
		} else if (direction === 'prev') {
			console.log('startSliderScroll, prev')
			prevInterval = setInterval(function(){
				slider.goTo(direction)
			}, 400);
		}
	}
}

const stopSliderScroll = (direction) => {
	if (slider) {
		if (direction === 'next') {
			console.log(stopSliderScroll, 'next')
			clearInterval(nextInterval)
		} else if (direction === 'prev') {
			console.log(stopSliderScroll, 'prev')
			clearInterval(prevInterval)
		}
	}
}

const arrowDrag = (e) => {

	const prevButton = document.querySelector('#prev_button')
	const nextButton = document.querySelector('#next_button')

	prevButton.addEventListener("dragover", function() {
		console.log('dragover prev button')
		startSliderScroll('prev')
	})
	prevButton.addEventListener("dragleave", function() {
		console.log('dragleave prev button')
		stopSliderScroll('prev')
	})

	nextButton.addEventListener("dragover", function(event) {
		console.log('dragover next button', event)
		startSliderScroll('next')
	})
	nextButton.addEventListener("dragleave", function(event) {
		console.log('dragleave next button', event)
		stopSliderScroll('next')
	})
}

const clearArrowEvents = () => {
	const prevButton = document.querySelector('#prev_button')
	const nextButton = document.querySelector('#next_button')

	prevButton.removeEventListener("dragover", function() {
		console.log('dragover prev button')
		startSliderScroll('prev')
	})

	prevButton.removeEventListener("dragleave", function() {
		console.log('dragleave prev button')
		stopSliderScroll('prev')
	})

	nextButton.removeEventListener("dragover", function(event) {
		console.log('dragover next button', event)
		startSliderScroll('next')
	})

	nextButton.removeEventListener("dragleave", function(event) {
		console.log('dragleave next button', event)
		stopSliderScroll('next')
	})
}

const ajaxRequest = (data, path) => {
	const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
	const request = new XMLHttpRequest()
	request.open('POST', path, true)
	request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8')
	request.setRequestHeader('X-CSRF-Token', csrfToken)
	request.send(data)
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
		// onMove: function(e) {
		// 	arrowDrag(e)
		// },
		onEnd: function(e) {
			ajaxRequest(recipeToPlannerMove(e), '/planner/recipe_add')
		// 	recipeDrag(e)
		// 	clearArrowEvents(e)
		}
	})
	plannerBlocks.forEach(function(dayBlock){
		new Sortable.create(dayBlock, {
			group: {
				name: 'recipe-sharing',
				pull: true,
				put: true
			},
			// onMove: function(e) {
			// 	arrowDrag(e)
			// },
			// onEnd: function(e) {
			// // 	recipeDrag(e)
			// // 	clearArrowEvents(e)
			// 	ajaxRequest(recipeToPlannerMove(e), '/planner/recipe_add')
			// }
		})
	})
  slider = tns({
    container: '[data-planner]',
    items: 4,
		slideBy: 1,
		mouseDrag: true,
		startIndex: 1,
		loop: false,
		gutter: 10,
		edgePadding: 40,
		arrowKeys: true,
		swipeAngle: false
	});

}

ready(dashboardFn)
