import { ready } from './utils'
import Sortable from 'sortablejs'
import {tns} from 'tiny-slider/src/tiny-slider'

const recipeDrag = (e) => {
	console.log(e.item.id, e.item.parentNode)
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
		onMove: function(e) {
			arrowDrag(e)
		},
		onEnd: function(e) {
			recipeDrag(e)
			clearArrowEvents(e)
		}
	})
	plannerBlocks.forEach(function(dayBlock){
		new Sortable.create(dayBlock, {
			group: {
				name: 'recipe-sharing',
				pull: true,
				put: true
			},
			onMove: function(e) {
				arrowDrag(e)
			},
			onEnd: function(e) {
				recipeDrag(e)
				clearArrowEvents(e)
			}
		})
	})
  slider = tns({
    container: '[data-planner]',
    items: 4,
		slideBy: 1,
		// mouseDrag: true,
		loop: false,
		gutter: 10,
		edgePadding: 40,
		arrowKeys: true,
		swipeAngle: false
	});

}

ready(dashboardFn)
