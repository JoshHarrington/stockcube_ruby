$(document).on("turbolinks:load", function() {
	if ($('#recipe_edit').length > 0) {
		// beforeUnload();
		confirmDeleteIngredient();
	}
});

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


// var beforeUnload = function() {
// 	window.onbeforeunload = function(e) {
// 		var dialogText = 'Unsaved changes';
// 		e.returnValue = dialogText;
// 		return dialogText;
// 	};
// }

