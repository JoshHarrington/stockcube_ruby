

var tours = {1: new Tour({
	name: 'tour1',
	storage: false,
	container: '#inner-wrap',
	backdropContainer: '#inner-wrap',
	backdrop: true,
	steps: [{
		title: "Your Cupboards",
		content: "This is your cupboards page where you can see all the stock that you've current got in your kitchen and cupboards you've setup",
		orphan: true,
	},
	{
		element: ".cupboard.list_block[data-index='1']",
		title: "One of your cupboards",
		content: "Here's one of your cupboards, where you can check what's in that cupboard and edit the stock contained in that cupboard",
		placement: "bottom",
	},{
		element: ".cupboard.list_block[data-index='1'] .list_block--item.list_block--item_new",
		title: "Adding stock",
		content: "This is one way of adding stock to your cupboard",
		placement: "bottom",
		redirect: true
	},{
		title: "Your Recipes",
		content: "These are the recipes you have available",
		path: "/recipes?tour=1#step3",
		element: ".list_block--collection.list_block--collection__tight ",
		placement: "top",
	}],
	onHide: function() {
		$('.tour-backdrop').remove();
	},
	onNext: function(tour) {
		var nextStep = parseInt(tour.getCurrentStep()) + 1
		if (tour._options.steps.length > nextStep ) {
			tour.goTo(nextStep)
		} else {
			tour.end()
		}
	},
	onPrev: function(tour) {
		if (parseInt(tour.getCurrentStep()) != 0) {
			var prevStep = parseInt(tour.getCurrentStep()) - 1
			tour.goTo(prevStep)
		} else {
			tour.end()
		}
	}

})}


var tour = function(tourNumber, stepNumber) {
	tours[tourNumber].init()
	tours[tourNumber].goTo(stepNumber)
}

$(document).on("turbolinks:load", function() {
	if (window.location.search.includes('tour')) {
		var stepNumber = window.location.hash.slice(-1);
		var tourNumber = window.location.search.slice(-1);
		tour(tourNumber, stepNumber);
		$('body').on('click', '.tour-backdrop', function(){
			tours[tourNumber].end();
		});
	}
});



/// Pause function:
//	On backdrop click, end tour and add button on side of page to allow user to restart tour
//	?? Also allow tour to be cancel from side button ??