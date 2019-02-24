function clearNotice(all = null){
	if (all != null) {
		$(".alert").animate({
			opacity: 0
		}, 1500);
		document.querySelector('.alert').style.pointerEvents = 'none'
	} else if (document.querySelector('.alert:not(.alert-update_request)') != null) {
		$(".alert:not(.alert-update_request)").animate({
			opacity: 0
		}, 500);
		document.querySelector('.alert:not(.alert-update_request').style.pointerEvents = 'none'
	}
};

$(document).ready(function() {
	if (document.querySelector('.alert') != null) {
		setTimeout(function() {
			clearNotice();
		}, 6000);
		if (!document.cookie.split(';').filter(function(item) {
			return item.trim().indexOf('recipeUpdate=nope') == 0
		}).length) {
			document.querySelector('.alert-update_request').style.display = 'block'
		}
		document.querySelector('#dismiss_no_update').addEventListener("click", function(){
			clearNotice('all');
			noRecipeUpdate();
		});
	}
});

function noRecipeUpdate() {
	document.cookie = "recipeUpdate=nope; max-age=21600"
}
