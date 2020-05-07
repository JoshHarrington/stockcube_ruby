import { ready, showAlert } from "./utils"

const sendCupboardTitleUpdate = (event) => {
	const title = event.target


	const cupboard = title.closest('.cupboard.list_block')
	const cupboardId = cupboard.querySelector('input[name="cupboard_id').value
	const titleValue = title.value

	const	data = {
		method: 'post',
		body: JSON.stringify(
			{
				cupboard_location: titleValue,
				cupboard_id: cupboardId
			}
		),
		headers: {
			'Content-Type': 'application/json',
			'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
		},
		credentials: 'same-origin'
	}
	fetch("/cupboards/name_update", data)
	.then(response => response.json())
	.then(data => {
		if(data["status"] === "success" || data["status"] === "no_change"){
			title.value = data["location"]
			if(data["status"] !== "no_change") {
				showAlert(`Cupboard "${titleValue}" - name updated`)
			}
		} else {
			showAlert(`Something went wrong, couldn't update "${titleValue}"`)
		}
	})
	.catch((error) => {
		console.error('Error:', error);
	});
}


const CupboardTitleUpdateFn = () => {
	const cupboardTitleInputs = document.querySelectorAll('input[name="cupboard_location"]')
	if (cupboardTitleInputs.length === 0) {
		return null
	}

	cupboardTitleInputs.forEach((title) => {
		title.addEventListener('blur', sendCupboardTitleUpdate)
	})
}

const sendDeleteCupboardUpdateFn = (event) => {
	const deleteBtn = event.target
	const cupboard = deleteBtn.closest('.cupboard.list_block')
	const cupboardId = cupboard.querySelector('input[name="cupboard_id').value
	const titleValue = cupboard.querySelector('input[name="cupboard_location').value

	const confirmAction = confirm(`Deleting "${titleValue}" - do you want to continue?`)
	if (confirmAction === true){
		const	data = {
			method: 'post',
			body: JSON.stringify(
				{
					cupboard_id_delete: cupboardId
				}
			),
			headers: {
				'Content-Type': 'application/json',
				'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
			},
			credentials: 'same-origin'
		}
		fetch("/cupboards/delete", data)
		.then(response => response.json())
		.then(data => {
			if(data["status"] === "success"){
				cupboard.style.display = 'none'
				showAlert(`"${titleValue}" deleted`)
			} else {
				showAlert(`Something went wrong, couldn't delete "${titleValue}"`)
			}
		})
		.catch((error) => {
			console.error('Error:', error);
		});
	}
}

const DeleteCupboardFn = () => {

	const cupboardDeleteBtns = document.querySelectorAll('.delete_list_block_button')
	if (cupboardDeleteBtns.length === 0) {
		return null
	}

	cupboardDeleteBtns.forEach((btn) => {
		btn.addEventListener('click', sendDeleteCupboardUpdateFn)
	})
}

const CupboardFns = () => {
	DeleteCupboardFn()
	CupboardTitleUpdateFn()
}

ready(CupboardFns)
