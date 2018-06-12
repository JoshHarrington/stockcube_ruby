var listBlockEdit = function(page) {

	if (page == 'cupboard') {
		$('.list_block--title input').change(function(){
			var $list_block_inputs = $(this).closest('.list_block').find('.list_block--title input');
			$.ajax({
				type: "POST",
				url: "/" + page + "s/autosave",
				data: $list_block_inputs.serializeArray(),
				dataType: "script"
			});
		});
	}
	$('body').click(function(e){
		if( !($(e.target).closest('.list_block').length > 0) ) {
			$('.list_block.edit_mode').removeClass('edit_mode');
		}
	});

	$('.edit_list_block_button').click(function(e){
		e.preventDefault();
		var $list_block = $(this).closest('.list_block');
		$('.list_block.edit_mode').removeClass('edit_mode');
		$list_block.toggleClass('edit_mode');
		$list_block_checkboxes = $(this).closest('.list_block').find('input[type="checkbox"]');
		$list_block_checkboxes.change(function(){
			if ($(this).closest('.list_block').find('input[type="checkbox"]:checked').length > 0) {
				$list_block.addClass('delete_mode');
			} else {
				$list_block.removeClass('delete_mode');
			}
		});
	});

	$('.close_without_edit_list_block_button').click(function(e){
		var $list_block = $(this).closest('.list_block');
		var $list_block_checkbox_inputs = $(this).closest('.list_block').find('input[type="checkbox"]:checked');
		$list_block_checkbox_inputs.prop('checked', false);
		$list_block_checkbox_inputs.removeAttr('checked');
		$list_block.removeClass('edit_mode delete_mode');
	});

	if (page == 'cupboard') {
		$('.delete_list_block_button').click(function(){
			var $list_block = $(this).closest('.list_block');
			var $delete_list_block_values = $(this).find('input').serialize();
			var confirmed = confirm("Are you sure you want to delete this cupboard?\nThere's no going back!");
			if (confirmed == true) {
				$($list_block).attr('hidden', true);
				$.ajax({
					type: "POST",
					url: "/" + page + "s/autosave",
					data: $delete_list_block_values,
					dataType: "script"
				});
			}
		});
	}

	$('.finish_editing_list_block_button').click(function(e){
		var $list_block = $(this).closest('.list_block');
		var $list_block_checkbox_inputs = $(this).closest('.list_block').find('input[type="checkbox"]:checked');

		var dataString = '';
		$list_block_checkbox_inputs.each(function(i){
			var item_id = $(this).attr('id');
			var item_val = $(this).val();
			$('label[for="'+ item_id +'"]').attr('hidden', 'hidden');
			$('.'+ item_id).attr('hidden', 'hidden');
			var list_block = $('.'+ item_id).closest('.list_block');
			if ((page == 'cupboard') && !($(list_block).hasClass('empty')) && (!($(list_block).find('.list_block--item_show:not([hidden])').length > 0))){
				$('.'+ item_id).closest('.list_block').addClass('empty');
			}
			dataString += ((dataString != '') ? '&' : '') + ((page == 'cupboard') ? 'stock_id[]=' : 'recipe_id[]=') + item_val;
		});

		var shopping_list_id = $list_block.data('shopping-list');
		dataString += ((page == 'shopping_list') ? ('&shopping_list_id=' + shopping_list_id) : '');

		console.log(dataString);
		$list_block.removeClass('edit_mode delete_mode');

		if (dataString != '') {
			$.ajax({
				type: "POST",
				url: "/" + page + "s/autosave",
				data: dataString,
				dataType: "script"
			});
		}
	});

}

$(document).on("turbolinks:load", function() {
	if (($('#cupboard-list').length > 0) || ($('#shopping_list_recipe--list').length > 0)) {
		var page = '';
		if ($('#cupboard-list').length > 0) {
			page = 'cupboard';
		} else if ($('#shopping_list_recipe--list').length > 0) {
			page = 'shopping_list';
		}
		listBlockEdit(page);
	}
});
