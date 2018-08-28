var cupboard = function() {

	$( '.cupboard.list_block:not(.shared)' ).sortable({
		connectWith: '.cupboard.list_block:not(.shared)',
		placeholder: 'list_block--item_placeholder',
		items: '.list_block--item_show',
		cancel: '.empty-card'
	}).disableSelection();

	$( '.cupboard.list_block' ).on( 'sortstart', function() {
		$( '.cupboard.list_block' ).addClass('hide_add');
	});

	$( '.cupboard.list_block' ).on( 'sortstop', function(e, ui) {
		$( '.cupboard.list_block' ).removeClass('hide_add');
		var moved_item = ui.item;
		var new_cupboard_id = moved_item.parent().data('id');
		var old_cupboard_id = moved_item.data('cupboard-id');
		var stock_id = moved_item.data('stock-id');
		var data = "stock_id=" + stock_id + "&cupboard_id=" + new_cupboard_id + "&old_cupboard_id=" + old_cupboard_id;
		if (new_cupboard_id !== old_cupboard_id) {
			$('#stock_' + stock_id).appendTo(moved_item.parent());
			$('label[for="stock_' + stock_id + '"]').appendTo(moved_item.parent());
			if (moved_item.parent().hasClass('empty')) {
				moved_item.parent().removeClass('empty all-out-of-date');
			}
			if ($('.cupboard.list_block[data-id="'+ old_cupboard_id +'"] .list_block--item:not(.list_block--item_new)').length == 0) {
				$('.cupboard.list_block[data-id="'+ old_cupboard_id +'"]').addClass('empty');
			}
			$.ajax({
				type: "POST",
				url: "/cupboards/autosave_sorting",
				data: data,
				dataType: "script"
			});
			moved_item.data('cupboard-id', new_cupboard_id);
		}
	});

}

var moreIngredients = function(){
	var numBricksShown = localStorage.getItem('num-bricks-shown');
	if(numBricksShown != null) {
		$('.list_block--collection__bricks--fancy_radio_group .fancy_radio_button__label.show').last().nextAll('label').slice(0, numBricksShown).removeClass('hide').addClass('show');
		numBricksShownCount = numBricksShown;
	} else {
		localStorage.setItem('num-bricks-shown', 0)
	}


	$('#show_more_ingredients').click(function(){
		$(this).parent().next('.list_block--collection__bricks--group_split').removeClass('hide');
		$('.list_block--collection__bricks--fancy_radio_group .fancy_radio_button__label.show').last().nextAll('label').slice(0, 8).removeClass('hide').addClass('show');
		if($('.list_block--collection__bricks--fancy_radio_group .fancy_radio_button__label.hide').length == 0) {
			$('.show_more_ingredients').prop('hidden', true);
		}
		numBricksShownCount = parseInt(numBricksShownCount) + 8;
		localStorage.setItem('num-bricks-shown', numBricksShownCount);
	});

}

var numBricksShownCount = 0;

var ingredientsShow = function(){
	$('.list_block--collection__bricks-form_group, #searching_with_stock_plus').prop('hidden', false);
	$('#searching_with_stock, #search_with_ingredients').prop('hidden', true);
	recipeResultsToggleProgressBar();
}
var ingredientsHide = function(){
	$('.list_block--collection__bricks-form_group, #searching_with_stock_plus').prop('hidden', true);
	$('#searching_with_stock, #search_with_ingredients').prop('hidden', false);
	recipeResultsToggleProgressBar();
}

var recipeResultsToggleProgressBar = function(){
	$('#recipe_results').toggleClass('mini_progress');
}

var showIngredientsForSearch = function(){
	$('#search_with_ingredients').click(function(){
		ingredientsShow();
		localStorage.setItem('ingredient-search-open', 1);
	});
	if (localStorage.getItem('ingredient-search-open') == 1){
		ingredientsShow();
	}
}

var hideIngredients = function(){
	$('#hide_ingredients').click(function(){
		localStorage.setItem('ingredient-search-open', 0);
		localStorage.setItem('num-bricks-shown', 0);
		ingredientsHide();
		$('.list_block--collection__bricks--fancy_radio_group label:nth-child(16)').nextAll('label').removeClass('show').addClass('hide');
		$('.list_block--collection__bricks--fancy_radio_group input:checked').prop('checked', false);
	});
}


$(document).on("turbolinks:load", function() {
	if ($('#cupboard-list').length > 0) {
		cupboard();
		moreIngredients();
		showIngredientsForSearch();
		hideIngredients();
	}
});

var cupboardEdit = function() {
	window.onbeforeunload = function(e) {
		var dialogText = 'Unsaved changes';
		e.returnValue = dialogText;
		return dialogText;
	};
}

