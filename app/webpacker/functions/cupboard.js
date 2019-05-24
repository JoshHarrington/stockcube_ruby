import Sortable from 'sortablejs';

var cupboard = function() {

	const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
	const cupboardStocks = document.querySelectorAll('.cupboard.list_block .list_block--content')
	cupboardStocks.forEach(function(stock) {
		const cupboardUsersHash = stock.getAttribute('data-cupboard-users')
		new Sortable(stock, {
			group: cupboardUsersHash,
			animation: 150,
			draggable: '.list_block--item:not(.non_sortable)',
			ghostClass: 'list_block--item_placeholder',
			onStart: function() {
				document.querySelectorAll('.cupboard.list_block .list_block--content:not([data-cupboard-users="' + cupboardUsersHash + '"]').forEach(function(non_matching_cupboard) {
					non_matching_cupboard.parentNode.classList.add('sortable_not_allowed')
				})
			},
			onEnd: function(e) {
				document.querySelectorAll('.cupboard.list_block.sortable_not_allowed').forEach(function(non_matching_cupboard) {
					non_matching_cupboard.classList.remove('sortable_not_allowed')
				})

				const el = e.item
				const stock_id = el.getAttribute('data-stock-id')
				const cupboard_to_id = e.to.getAttribute('data-cupboard-id')
				const cupboard_from_id = e.from.getAttribute('data-cupboard-id')
				const data = "stock_id=" + stock_id + "&cupboard_id=" + cupboard_to_id + "&old_cupboard_id=" + cupboard_from_id
				const request = new XMLHttpRequest()
				request.open('POST', '/cupboards/autosave_sorting', true)
				request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8')
				request.setRequestHeader('X-CSRF-Token', csrfToken)
				request.send(data)
			}
		})
	});

	function deleteQuickAddStock(hashedId) {
		const confirmed = confirm("Are you sure you want to delete this quick add stock?\nThere's no going back!");
		if (confirmed == true) {
			const data = "quick_add_stock_id=" + hashedId
			const request = new XMLHttpRequest()
			request.open('POST', '/cupboards/delete_quick_add_stock', true)
			request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8')
			request.setRequestHeader('X-CSRF-Token', csrfToken)
			request.send(data)
			document.getElementById(hashedId).parentNode.style.display = 'none'
		}
	}

	const quickAddStockDeleteBtns = document.querySelectorAll('.quick_add_stock_delete_btn')
	quickAddStockDeleteBtns.forEach(function(btn) {
		const hashedId = btn.getAttribute('id')
		btn.addEventListener('click', function(){deleteQuickAddStock(hashedId)}, false)
	})

	function deleteCupboardStock(hashedId, event) {
		const confirmed = confirm("Are you sure you want to delete this ingredient from your cupboard?\nThis can't be undone :O");
		if (confirmed == true) {
			const data = "cupboard_stock_id=" + hashedId
			const request = new XMLHttpRequest()
			request.open('POST', '/cupboards/delete_cupboard_stock', true)
			request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8')
			request.setRequestHeader('X-CSRF-Token', csrfToken)
			request.send(data)
			document.getElementById(hashedId).parentNode.style.display = 'none'
		}
		event.preventDefault()
	}

	const cupboardStockDeleteBtns = document.querySelectorAll('.cupboard_stock_delete_btn')
	cupboardStockDeleteBtns.forEach(function(btn) {
		const hashedId = btn.getAttribute('id')
		btn.addEventListener('click', function(e){
			deleteCupboardStock(hashedId, event)
		}, false)
	})
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

