import Sortable from 'sortablejs';


var cupboard = function() {

	const cupboardStocks = document.querySelectorAll('.cupboard.list_block:not(.shared) .list_block--content')
	cupboardStocks.forEach(function(stock) {
		new Sortable(stock, {
			group: 'shared',
			animation: 150,
			draggable: '.list_block--item:not(.non_sortable)',
			ghostClass: 'list_block--item_placeholder',
			onStart: function() {
				document.querySelectorAll('.cupboard.list_block.shared').forEach(function(shared_cupboard) {
					shared_cupboard.classList.add('sortable_not_allowed')
				})
			},
			onEnd: function(e) {
				document.querySelectorAll('.cupboard.list_block.shared.sortable_not_allowed').forEach(function(shared_cupboard) {
					shared_cupboard.classList.remove('sortable_not_allowed')
				})

				const el = e.item
				const stock_id = el.getAttribute('data-stock-id')
				const cupboard_to_id = e.to.getAttribute('data-cupboard-id')
				const cupboard_from_id = e.from.getAttribute('data-cupboard-id')
				const data = "stock_id=" + stock_id + "&cupboard_id=" + cupboard_to_id + "&old_cupboard_id=" + cupboard_from_id;
				const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
				const request = new XMLHttpRequest();
				request.open('POST', '/cupboards/autosave_sorting', true);
				request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
				request.setRequestHeader('X-CSRF-Token', csrfToken);
				request.send(data);
			}
		})
	});



	/// use hashids to create data-matching attribute based on shared users
	/// on sortstart find out data-matching attr of current element
	/// add 'matching' class to all other lists with the same data-matching attrs
	/// on sortstop remove all matching classes

	/// possible issue: does the sortable system ignore classes added whilst sorting is ongoing

	// $( '.cupboard.list_block:not(.shared) .list_block--content' ).sortable({
	// 	connectWith: '.cupboard.list_block:not(.shared) .list_block--content',
	// 	placeholder: 'list_block--item_placeholder',
	// 	items: '.list_block--item_show',
	// 	cancel: '.empty-card'
	// }).disableSelection();


	/// currently not setup in new version - is this needed?
	// $( '.cupboard.list_block .list_block--content' ).on( 'sortstart', function() {
	// 	$( '.cupboard.list_block .list_block--content' ).addClass('hide_add');
	// });

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

