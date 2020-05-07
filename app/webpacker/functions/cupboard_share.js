import { ready } from "./utils";

const addEmailToTextArea = (event) => {
	const peopleMarker = event.target
	const email = peopleMarker.dataset.email
	const emailsTextarea = document.querySelector('#cupboard_user_emails')
	const emailsTextareaValue = emailsTextarea.value
	if (emailsTextareaValue === "") {
		emailsTextarea.value = email
	} else {
		emailsTextarea.value = `${emailsTextareaValue}, ${email}`
	}
	peopleMarker.remove()
}

const cupboardShareFn = () => {
	if(!!document.querySelector('#cupboard_share')) {
		const cupboardSharePage = document.querySelector('#cupboard_share')
		const peopleMarkers = cupboardSharePage.querySelectorAll('#cupboard_share_add_user_list .people_marker:not([hidden])')
		if (peopleMarkers.length) {
			peopleMarkers.forEach((p) => {
				p.addEventListener('click', addEmailToTextArea)
			})
		}
	}
}

ready(cupboardShareFn)
