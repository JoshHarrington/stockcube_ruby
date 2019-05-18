var cupboard = function() {


	/// use hashids to create data-matching attribute based on shared users
	/// on sortstart find out data-matching attr of current element
	/// add 'matching' class to all other lists with the same data-matching attrs
	/// on sortstop remove all matching classes

	/// possible issue: does the sortable system ignore classes added whilst sorting is ongoing

	$( '.cupboard.list_block:not(.shared) .list_block--content' ).sortable({
		connectWith: '.cupboard.list_block:not(.shared) .list_block--content',
		placeholder: 'list_block--item_placeholder',
		items: '.list_block--item_show',
		cancel: '.empty-card'
	}).disableSelection();

	$( '.cupboard.list_block .list_block--content' ).on( 'sortstart', function() {
		$( '.cupboard.list_block .list_block--content' ).addClass('hide_add');
	});

	$( '.cupboard.list_block .list_block--content' ).on( 'sortstop', function(e, ui) {
		$( '.cupboard.list_block .list_block--content' ).removeClass('hide_add');
		var moved_item = ui.item;
		var list_block_parent = moved_item.closest('.list_block');
		var new_cupboard_id = list_block_parent.data('id');
		var old_cupboard_id = moved_item.data('cupboard-id');
		var stock_id = moved_item.data('stock-id');
		var data = "stock_id=" + stock_id + "&cupboard_id=" + new_cupboard_id + "&old_cupboard_id=" + old_cupboard_id;
		if (new_cupboard_id !== old_cupboard_id) {
			$('#stock_' + stock_id).appendTo(list_block_parent);
			$('label[for="stock_' + stock_id + '"]').appendTo(list_block_parent);
			if (list_block_parent.hasClass('empty')) {
				list_block_parent.removeClass('empty all-out-of-date');
			}
			if ($('.cupboard.list_block[data-id="'+ old_cupboard_id +'"] .list_block--item:not(.list_block--item_new)').length == 0) {
				$('.cupboard.list_block[data-id="'+ old_cupboard_id +'"]').addClass('empty');
			}
			$.ajax({
				type: "POST",
				beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
				url: "/cupboards/autosave_sorting",
				data: data,
				dataType: "script"
			});
			moved_item.data('cupboard-id', new_cupboard_id);
		}
	});

}


$(document).ready(function() {
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

