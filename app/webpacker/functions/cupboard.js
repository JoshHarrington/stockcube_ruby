import Sortable from 'sortablejs';
import { ajaxRequest, isMobileDevice, ready, showAlert } from './utils';

const cupboardFn = function() {

	const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
	const cupboardStocks = document.querySelectorAll('.cupboard.list_block .list_block--content')

	if (isMobileDevice() === false){
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
	}

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

	const cupboardStockDeleteBtns = document.querySelectorAll('.cupboard_stock_delete_btn')
	cupboardStockDeleteBtns.forEach(function(btn) {
		btn.addEventListener('click', deleteCupboardStock, false)
	})
}


const deleteCupboardStock = (event) => {
	const btn = event.target
	const hashedId = btn.getAttribute('id')
	const stock = btn.closest('.list_block--item')
	const stockTitle = stock.querySelector('.list_block--item--content').innerText
	const confirmCheck = confirm(`Deleting "${stockTitle}" - do you want to continue?`);

	const	data = {
		method: 'post',
		body: JSON.stringify(
			{
				type: "post",
				id: hashedId
			}
		),
		headers: {
			'Content-Type': 'application/json',
			'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
		},
		credentials: 'same-origin'
	}
	event.preventDefault()

	if (confirmCheck == true) {
		fetch(`/stock/delete/${hashedId}`, data)
		.then(response => response.json())
		.then(data => {
			if(data["status"] === "success"){
				stock.remove()
				showAlert(`Stock "${stockTitle}" deleted`)
			} else {
				showAlert(`Something went wrong, couldn't delete "${stockTitle}"`)
			}
		})
		.catch((error) => {
			console.error('Error:', error);
		});
	}
}

const cupboardShareDeleteFn = () => {
	const deleteCupboardUser = (deleteEl, hashedId) => {
		const confirmed = confirm("Are you sure you want to remove this user from your cupboard?");
		if (confirmed == true) {
			const data = "user_id=" + hashedId
			ajaxRequest(data, '/cupboards/delete_cupboard_user')
			deleteEl.parentNode.style.display = 'none'
		}
	}
	const deleteUsersEls = document.querySelectorAll('.delete_cupboard_user')
	if(deleteUsersEls.length) {
		deleteUsersEls.forEach(function(deleteEl) {
			const hashedId = deleteEl.getAttribute('id')
			deleteEl.addEventListener('click', deleteCupboardUser(deleteEl, hashedId), false)
		})
	}
}


/// Is this needed?
const cupboardEditFn = () => {
	window.onbeforeunload = function(e) {
		var dialogText = 'Unsaved changes';
		e.returnValue = dialogText;
		return dialogText;
	};
}


const cupboardFns = () => {
	if(!!document.querySelector('#cupboard-list')){
		cupboardFn()
	}
	if(!!document.querySelector('.cupboards_controller.share_page')){
		cupboardShareDeleteFn()
	}
}

ready(cupboardFns)

