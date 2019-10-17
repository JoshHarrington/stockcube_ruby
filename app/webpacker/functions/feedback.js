import { ready } from "./utils";

const scrollToForm = () => {
	document.querySelector('.feedback_form_label').addEventListener('click', () => {
		document.querySelector('.footer_feedback_form--wrapper').scrollIntoView({
			behavior: 'smooth'
		});
	})
}

const feedback = () => {
	if (document.querySelector('.footer_feedback_form--wrapper')) {
		scrollToForm()
	}
}

ready(feedback)
