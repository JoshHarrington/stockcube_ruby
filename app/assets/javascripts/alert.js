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
		var maxIntervalsToRun = standardAlerts.length - 1

		var i = 0;
		console.log(i, standardAlerts[i]);
		var interval = setInterval(function(){
			hideStandardAlerts(standardAlerts, i)
			// need to update the counter inside the timeout else it gets the wrong value
			i++;
			if(i === maxIntervalsToRun) {
				clearInterval(interval);
			}
		}, 4000);

		function hideStandardAlerts(standardAlerts, i){
			console.log(i, standardAlerts[i]);
			hideAlert(standardAlerts[i]);
		}

		var noUpdateBtns = document.querySelectorAll('.dismiss_no_update');
		for (var i = 0; i < noUpdateBtns.length; i++) {
			noUpdateBtns[i].addEventListener('click', function(e) {
				console.log(e.target)
				hideAlert(e.target)
				if (e.target.classList.contains('recipe_no_update_cookie_set')){
					noRecipeUpdate();
				}
			});
		}


		// setTimeout(function() {
		// 	clearNotice();
		// }, 6000);
		// if (!document.cookie.split(';').filter(function(item) {
		// 	return item.trim().indexOf('recipeUpdate=nope') == 0
		// }).length) {
		// 	document.querySelector('.alert-sticky').style.display = 'block'
		// }
		// var noUpdateBtns = document.querySelectorAll('.dismiss_no_update');
		// for (var i = 0; i < noUpdateBtns.length; i++) {
		// 	noUpdateBtns[i].addEventListener('click', function(e) {
		// 		clearNotice('all', e);
		// 		noRecipeUpdate();
		// 	});
		// }
	}
});

function noRecipeUpdate() {
	document.cookie = "recipeUpdate=nope; max-age=21600"
}
