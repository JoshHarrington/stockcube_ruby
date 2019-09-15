import { ajaxRequest, ready } from "./utils";

const notificationsData = (notificationsWanted, notificationDay) => (
	"notifications[" + notificationsWanted + "]&weekday[" + notificationDay + "]"
)

const notificationFunction = () => {
	const notifications = document.querySelector('#notifications')
	const notificationsUserPickRow = notifications.querySelector('#notifications_user_pick_row')
	const notificationsCheckbox = notifications.querySelector('input[type="checkbox"]')
	const notificationDayPick = notifications.querySelector('#day_pick')


	let notificationsWanted = notificationsCheckbox.checked
	let notificationDay = notificationDayPick.value

	notificationsCheckbox.addEventListener('change', () => {
		notificationsWanted = notificationsCheckbox.checked
		notificationsUserPickRow.classList.toggle('faded_out')
		ajaxRequest(notificationsData(notificationsWanted, notificationDay), "/users/notifications")
	})

	notificationDayPick.addEventListener('change', (event) => {
		notificationDay = event.target.value
		ajaxRequest(notificationsData(notificationsWanted, notificationDay), "/users/notifications")
	})


}

var passUserEmail = function() {
	const forgottenPasswordLink = document.querySelector('#forgotten_password_link')
	const emailField = document.querySelector('#session_email')
	forgottenPasswordLink.addEventListener('click', (e) => {
		if (emailField.value !== '') {
			e.preventDefault()
			window.location.assign('/password_resets/new?email=' + encodeURIComponent(emailField.value));
		}
	})
}

const userPageFunctions = () => {
	if (document.querySelector('#notifications')) {
		notificationFunction();
	}
	if (document.querySelector('#forgotten_password_link')) {
		passUserEmail();
	}
}

ready(userPageFunctions)
