// var cupboard_share = function() {

// 	$('#cupboard_share_add_user_list .people_marker:not([hidden])').click(function(){
// 		// grab email from marker
// 		$marker_email = $(this).data('email');
// 		// check content of textare
// 		$email_txtarea_val = $('#cupboard_user_emails').val();
// 		if ($email_txtarea_val == '') {
// 			$('#cupboard_user_emails').val($marker_email);
// 		} else {
// 			$new_textarea_val = $email_txtarea_val + ', ' + $marker_email
// 			$('#cupboard_user_emails').val($new_textarea_val);
// 		}
// 		$(this).attr('hidden', 'hidden');
// 		if ($('#cupboard_share_add_user_list .people_marker:not([hidden])').length == 0) {
// 			$('#cupboard_share_add_user_list__title, #cupboard_share_add_user_list').attr('hidden', 'hidden');
// 		}
// 	});


// };

// $(document).ready(function() {
// 	if ($('#cupboard_share').length > 0) {
// 		cupboard_share();
// 	}
// });
