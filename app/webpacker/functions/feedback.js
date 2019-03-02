var scroll_to_form = function() {
	$('.feedback_form_label').click(function(){
		if ($('.feedback_form_button.hidden_checkbox:checked').length == 0) {
			document.querySelector('.footer_feedback_form--wrapper').scrollIntoView({
				behavior: 'smooth'
			});
		}
	});
}

$(document).ready(function() {
	if ($('#footer-feedback-form').length > 0) {
		scroll_to_form();
	}
});