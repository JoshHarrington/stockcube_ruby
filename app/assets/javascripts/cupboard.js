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

$(document).on("turbolinks:load", function() {
	if ($('#cupboard-list').length > 0) {
		cupboard();
	}
});

var cupboardEdit = function() {
	window.onbeforeunload = function(e) {
		var dialogText = 'Unsaved changes';
		e.returnValue = dialogText;
		return dialogText;
	};
}

