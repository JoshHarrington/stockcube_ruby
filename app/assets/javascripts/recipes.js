$(document).on("turbolinks:load", function() {
	if ($('#recipe_edit').length > 0) {
		// beforeUnload();
		confirmDeleteIngredient();
		togglePublicRowFade();
		hashCheck();
	}
});

var togglePublicRowFade = function() {
	$('#recipe_live_status_row input[type="radio"]').click(function(e){
		if (e.target == $('#live_radio_1')[0]) {
			$('#recipe_public_status_row').removeClass('faded_out');
		} else {
			$('#recipe_public_status_row').addClass('faded_out');

		}
	})
}

var confirmDeleteIngredient = function(){
	$('.ingredient_row label').click(function (e) {
		console.log('label clicked');
		var deleteStateClass = 'delete_state';
		var $this = $(this);
		var el = e.target;
		var ingredientRow = el.parentNode;
		if (ingredientRow.classList) {
			ingredientRow.classList.add(deleteStateClass);
		} else {
			ingredientRow.className += ' ' + deleteStateClass;
		}
		window.setTimeout(function(){confirmFunc($this, ingredientRow, deleteStateClass)},12);
	});
}

var confirmFunc = function($this, ingredientRow, deleteStateClass){
	if (window.confirm("Sure that you want to delete that ingredient?")) {
		if (ingredientRow.classList) {
			ingredientRow.classList.add('slide_up');
		} else {
			ingredientRow.className += ' slide_up';
		}
	} else {
		if (ingredientRow.classList) {
			ingredientRow.classList.remove(deleteStateClass);
		} else {
			ingredientRow.className = ingredientRow.className.replace(deleteStateClass, '');
		}
		$this.siblings('input[type="checkbox"]').prop('checked', false);
	}
}

var hashCheck = function() {
	if(window.location.hash) {
		hash = window.location.hash;
		targetElString = hash + ' input, ' + hash + ' textarea';
		document.querySelectorAll(targetElString)[0].focus();
	}
}


// var beforeUnload = function() {
// 	window.onbeforeunload = function(e) {
// 		var dialogText = 'Unsaved changes';
// 		e.returnValue = dialogText;
// 		return dialogText;
// 	};
// }

