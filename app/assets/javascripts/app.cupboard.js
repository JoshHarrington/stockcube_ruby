const cupboard = function() {

	$('#cupboard-list input').change(function(){
		const $cupboard_block_inputs = $(this).closest('.list_block').find('input');
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
		const $cupboard_block = $(this).closest('.list_block');
		$('.list_block.edit_mode').removeClass('edit_mode');
		$cupboard_block.toggleClass('edit_mode');
	});
	$('.finish_editing_cupboard_button').click(function(e){
		const $cupboard_block = $(this).closest('.list_block');
		const $cupboard_block_checkbox_inputs = $(this).closest('.list_block').find('input[type="checkbox"]:checked');
		$cupboard_block_checkbox_inputs.each(function(i){
			const stock_edit_id = $(this).attr('id');
			$('label[for="'+ stock_edit_id +'"]').attr('hidden', 'hidden');
			$('.'+ stock_edit_id).attr('hidden', 'hidden');
			const list_block = $('.'+ stock_edit_id).closest('.list_block');
			if (!($(list_block).hasClass('empty')) && (!($(list_block).find('.list_block--item_show:not([hidden])').length > 0))){
				$('.'+ stock_edit_id).closest('.list_block').addClass('empty');
			}
		})
		$cupboard_block.removeClass('edit_mode');
		$cupboard_block_checkbox_values = $cupboard_block_checkbox_inputs.serializeArray();

		if ($cupboard_block_checkbox_values.length > 0) {
			console.log('here be data');
			$.ajax({
				type: "POST",
				url: "/cupboards/autosave",
				data: $cupboard_block_checkbox_values,
				dataType: "script"
			});
		} else {
			console.log('here be dragons');
		}
	});

}

$(document).on("turbolinks:load", function() {
	if ($('#cupboard-list').length > 0) {
		cupboard();
	}
});
