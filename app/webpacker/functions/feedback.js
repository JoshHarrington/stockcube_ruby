import { ready } from "./utils";

const scrollToForm = () => {
	document.querySelector('[data-name="feedback-form-label"]').addEventListener('click', () => {
		document.querySelector('[data-name="feedback-form-wrapper"]').scrollIntoView({
			behavior: 'smooth'
		});
	})
}

const feedback = () => {
	if (document.querySelector('[data-name="feedback-form-wrapper"]')) {
		scrollToForm()
	}
}

ready(feedback)
