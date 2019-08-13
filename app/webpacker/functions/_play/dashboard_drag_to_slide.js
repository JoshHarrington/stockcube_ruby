
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