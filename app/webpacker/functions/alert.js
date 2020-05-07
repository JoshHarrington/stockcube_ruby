import { ready } from "./utils"

const hideAlert = (el) => {
	const wrapper = el.closest('.alert_wrapper')
	wrapper.classList.add('alert_hide')
}

const showAlert = (el) => {
	const wrapper = el.closest('.alert_wrapper')
	wrapper.classList.remove('alert_hide')
}

const noRecipeUpdate = (el) => {
	const StickyAlert = el.closest('.alert-sticky_recipe')
	if (StickyAlert) {
		document.cookie = "recipeUpdate=nope; max-age=21600;path=/"
	}
}

const alertFn = () => {

	if (!!document.querySelector('.alert')) {

		const standardAlerts = document.querySelectorAll('.alert:not(.alert-sticky)');

		if (standardAlerts.length) {

			standardAlerts.forEach((alert, i) => {
				const interval = setInterval(() => {
					hideAlert(alert)
					if (i === standardAlerts.length - 1) {
						clearInterval(interval)
					}
				}, 6000)
			})

			// var maxIntervalsToRun = standardAlerts.length
			// var counter = 0;
			// var interval = setInterval(function(){
			// 	hideAlert(standardAlerts[counter]);
			// 	counter++;
			// 	if(counter === maxIntervalsToRun) {
			// 		clearInterval(interval);
			// 	}
			// }, 6000);
		}

		const noUpdateBtns = document.querySelectorAll('.dismiss_no_update');
		if (noUpdateBtns.length) {
			noUpdateBtns.forEach((btn) => {
				btn.addEventListener('click', (e) => {
					hideAlert(e.target)
					noRecipeUpdate(e.target)
				})
			})
		}

		if (!document.cookie.split(';').filter(function(item) {
			return item.trim().indexOf('recipeUpdate=') === 0
		}).length) {
			const recipeAlerts = document.querySelectorAll('.alert-sticky_recipe');
			if (recipeAlerts.length) {
				recipeAlerts.forEach((alert) => {
					showAlert(alert)
				})
			}
		}
	}
}

ready(alertFn)


