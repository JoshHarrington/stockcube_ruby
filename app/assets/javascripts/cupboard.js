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


var cupboardSearch = function(turbolinks_load_happened){
	if (turbolinks_load_happened == true){
		$('.selectize-control').remove();
		$('.selectized').removeClass('selectized');
		var $search_select = $('[name="search[]"]').selectize({
			delimiter: '" or "',
			maxItems: 7,
			options: selectOptions,
			persist: false,
			sortField: 'text',
			plugins: ['remove_button', 'restore_on_backspace'],
		});
	} else {
		$('select[name="search[]"] option').each(function(){
			var val = $(this).val();
			var option = {"value": val, text: val};
			if (val != '') {
				selectOptions.push(option);
			}
		});
		var $search_select = $('[name="search[]"]').selectize({
			delimiter: '" or "',
			maxItems: 7,
			persist: false,
			sortField: 'text',
			plugins: ['remove_button', 'restore_on_backspace'],
		});
	}
	var prefill_plain = $search_select.data('prefill');
	if(typeof prefill_plain === "string") {
		var prefill_array = $search_select.data('prefill').split("','").map(function(val){
			return val.replace(/'/g, '');
		});
		console.log('hi')
	}
	$search_select[0].selectize.setValue((prefill_array || prefill_plain));
}

var selectOptions = [];
var turbolinks_load_happened = false;

$(document).on("turbolinks:load", function() {
	if ($('#cupboard-list').length > 0) {
		cupboard();
		cupboardSearch(turbolinks_load_happened);
		turbolinks_load_happened = true;
	}
});

var cupboardEdit = function() {
	window.onbeforeunload = function(e) {
		var dialogText = 'Unsaved changes';
		e.returnValue = dialogText;
		return dialogText;
	};
}

