var cupboard = function() {

	$('.list_block--title input').change(function(){
		var $cupboard_block_inputs = $(this).closest('.list_block').find('.list_block--title input');
		$.ajax({
			type: "POST",
			url: "/cupboards/autosave",
			data: $cupboard_block_inputs.serializeArray(),
			dataType: "script"
		});
	});
	$('body').click(function(e){
		if( !($(e.target).closest('.list_block').length > 0) ) {
			$('.list_block.edit_mode').removeClass('edit_mode');
		}
	});

	$('.edit_cupboard_button').click(function(e){
		e.preventDefault();
		var $cupboard_block = $(this).closest('.list_block');
		$('.list_block.edit_mode').removeClass('edit_mode');
		$cupboard_block.toggleClass('edit_mode');
		$cupboard_checkboxes = $(this).closest('.list_block').find('input[type="checkbox"]');
		$cupboard_checkboxes.change(function(){
			if ($(this).closest('.list_block').find('input[type="checkbox"]:checked').length > 0) {
				$cupboard_block.addClass('delete_mode');
			} else {
				$cupboard_block.removeClass('delete_mode');
			}
		});
	});

	$('.close_without_edit_cupboard_button').click(function(e){
		var $cupboard_block = $(this).closest('.list_block');
		var $cupboard_block_checkbox_inputs = $(this).closest('.list_block').find('input[type="checkbox"]:checked');
		$cupboard_block_checkbox_inputs.prop('checked', false);
		$cupboard_block_checkbox_inputs.removeAttr('checked');
		$cupboard_block.removeClass('edit_mode delete_mode');
	});

	$('.delete_cupboard_button').click(function(){
		var $cupboard_block = $(this).closest('.list_block');
		var $delete_cupboard_values = $(this).find('input').serialize();
		var confirmed = confirm("Are you sure you want to delete this cupboard?\nThere's no going back!");
		if (confirmed == true) {
			$($cupboard_block).attr('hidden', true);
			$.ajax({
				type: "POST",
				url: "/cupboards/autosave",
				data: $delete_cupboard_values,
				dataType: "script"
			});
		}
	});

	$('.finish_editing_cupboard_button').click(function(e){
		var $cupboard_block = $(this).closest('.list_block');
		var $cupboard_block_checkbox_inputs = $(this).closest('.list_block').find('input[type="checkbox"]:checked');
		$cupboard_block_checkbox_inputs.each(function(i){
			var stock_edit_id = $(this).attr('id');
			$('label[for="'+ stock_edit_id +'"]').attr('hidden', 'hidden');
			$('.'+ stock_edit_id).attr('hidden', 'hidden');
			var list_block = $('.'+ stock_edit_id).closest('.list_block');
			if (!($(list_block).hasClass('empty')) && (!($(list_block).find('.list_block--item_show:not([hidden])').length > 0))){
				$('.'+ stock_edit_id).closest('.list_block').addClass('empty');
			}
		})
		$cupboard_block.removeClass('edit_mode delete_mode');
		$cupboard_block_checkbox_values = $cupboard_block_checkbox_inputs.serializeArray();

		if ($cupboard_block_checkbox_values.length > 0) {
			$.ajax({
				type: "POST",
				url: "/cupboards/autosave",
				data: $cupboard_block_checkbox_values,
				dataType: "script"
			});
		}
	});

}

$(document).on("turbolinks:load", function() {
	if ($('#cupboard-list').length > 0) {
		cupboard();
	}
});
