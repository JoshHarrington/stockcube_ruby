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

	$( '.cupboard.list_block' ).sortable({
		connectWith: '.cupboard.list_block',
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
			if ($('.cupboard.list_block[data-id="'+ old_cupboard_id +'"] .list_block--item:not(.list_block--item-new)').length == 0) {
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

$(document).on("turbolinks:load", function() {
	if ($('#cupboard-list').length > 0) {
		cupboard();
	}
});
