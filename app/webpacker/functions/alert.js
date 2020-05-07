// function hideAlert(el) {
// 	if (el.classList.contains('alert_wrapper')) {
// 		el.classList.add('alert_hide')
// 	} else {
// 		hideAlert(el.parentNode)
// 	}
// }

// function showAlert(el) {
// 	if (el.classList.contains('alert_wrapper')) {
// 		el.classList.remove('alert_hide')
// 	} else {
// 		showAlert(el.parentNode)
// 	}
// }

// $(document).ready(function() {
// 	if (document.querySelector('.alert') != null) {

// 		var standardAlerts = document.querySelectorAll('.alert:not(.alert-sticky)');

// 		if (standardAlerts.length) {
// 			var maxIntervalsToRun = standardAlerts.length
// 			var counter = 0;
// 			var interval = setInterval(function(){
// 				hideAlert(standardAlerts[counter]);
// 				counter++;
// 				if(counter === maxIntervalsToRun) {
// 					clearInterval(interval);
// 				}
// 			}, 6000);
// 		}

// 		var noUpdateBtns = document.querySelectorAll('.dismiss_no_update');
// 		for (var i = 0; i < noUpdateBtns.length; i++) {
// 			noUpdateBtns[i].addEventListener('click', function(e) {
// 				hideAlert(e.target)
// 				noRecipeUpdate(e.target)
// 			});
// 		}

// 		if (!document.cookie.split(';').filter(function(item) {
// 			return item.trim().indexOf('recipeUpdate=') === 0
// 		}).length) {
// 			var recipeAlerts = document.querySelectorAll('.alert-sticky_recipe');
// 			for (var i = 0; i < recipeAlerts.length; i++) {
// 				showAlert(recipeAlerts[i])
// 			}
// 		}
// 	}
// });

// function noRecipeUpdate(el) {
// 	if (el.classList.contains('alert-sticky_recipe')) {
// 		document.cookie = "recipeUpdate=nope; max-age=21600;path=/"
// 	} else {
// 		noRecipeUpdate(el.parentNode)
// 	}
// }