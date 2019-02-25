function hideAlert(el) {

	if (el.classList.contains('alert_wrapper')) {
		el.classList.add('alert_hide')
	} else {
		hideAlert(el.parentNode)
	}
}

$(document).ready(function() {
	if (document.querySelector('.alert') != null) {


		var standardAlerts = document.querySelectorAll('.alert:not(.alert-sticky)');
		var maxIntervalsToRun = standardAlerts.length

		var counter = 0;
		var interval = setInterval(function(){
			hideAlert(standardAlerts[counter]);
			counter++;
			if(counter === maxIntervalsToRun) {
				clearInterval(interval);
			}
		}, 4000);

		var noUpdateBtns = document.querySelectorAll('.dismiss_no_update');
		for (var i = 0; i < noUpdateBtns.length; i++) {
			noUpdateBtns[i].addEventListener('click', function(e) {
				hideAlert(e.target)
				if (e.target.classList.contains('recipe_no_update_cookie_set')){
					noRecipeUpdate();
				}
			});
		}
	}
});

function noRecipeUpdate() {
	document.cookie = "recipeUpdate=nope; max-age=21600"
}
