var shoppingList = function() {
		$('#shopping_list_shop_mode_form input[type="checkbox"]').change(function(){
			var $checked_shopping_list_items = $(this).closest('#shopping_list_shop_mode_form').find('input[type="checkbox"]:checked');
			var checked_items = [];
			$checked_shopping_list_items.each(function(){
				checked_items.push((checked_items.length > 0 ? '&' : '') + "shopping_list_portion_ids[" + $(this).data('id') + "]=true");
			});
			var empty;
			if (checked_items.length == 0) {
				empty = true;
			} else {
				empty = false;
			}
			$.ajax({
				type: "POST",
				url: "/shopping_lists/autosave_checked_items",
				data: (empty ? "shopping_list_portion_ids['empty']" : checked_items.join('')),
				dataType: "script"
			});
		});
}

$(document).on("turbolinks:load", function() {
	if ($('#shopping_list_shop_mode_form').length > 0) {
		shoppingList();
	}
});


var shoppingListShow = function() {
	$('#archive_current_shopping_list').on('click', function(){
		return confirm('Are you sure you want to delete this shopping list?')
	});
}

$(document).on("turbolinks:load", function() {
	if ($('#shopping_list_show').length > 0) {
		shoppingListShow();
	}
});