$(document).on("turbolinks:load", function() {
	if ($('#recipe_edit').length > 0) {
		// beforeUnload();
		confirmDeleteIngredient();
		togglePublicRowFade();
		hashFocus();
		makePublishableOnChange();
	}
});

var togglePublicRowFade = function() {
	var publicStatusRow = $('#recipe_public_status_row');
	var publicStatusBtns = $('#recipe_public_status_row input');
	$('#recipe_live_status_row input[type="radio"]').click(function(e){
		if (e.target == $('#live_radio_1')[0]) {
			publicStatusRow.removeClass('faded_out');
			publicStatusBtns.prop('disabled', false);
		} else {
			publicStatusRow.addClass('faded_out');
			publicStatusBtns.prop('disabled', true);
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

var hashFocus = function() {
	if(window.location.hash) {
		hash = window.location.hash;
		targetElString = hash + ' input, ' + hash + ' textarea';
		document.querySelectorAll(targetElString)[0].focus();
	}
}

var makePublishableOnChange = function() {
	var publishOptions = $('#publish_options');
	var publishBtns = $('#publish_options input');
	$('#recipe_description, #recipe_title_container input, #recipe_cook_time, #recipe_ingredients_list .ingredient_row').change(function(){
		if(!($('#recipe_description').val() == '' || $('#recipe_title_container input').val() == '' || $('#recipe_cook_time').val() == '' || $('#recipe_ingredients_list .ingredient_row:not(".delete_state")').length == 0)) {
			console.log('Y: recipe can be saved');
			publishOptions.removeClass('faded_out');
			publishBtns.prop('disabled', false);
		} else {
			publishOptions.addClass('faded_out')
			publishBtns.prop('disabled', true);
		}
	})
}


// var beforeUnload = function() {
// 	window.onbeforeunload = function(e) {
// 		var dialogText = 'Unsaved changes';
// 		e.returnValue = dialogText;
// 		return dialogText;
// 	};
// }

