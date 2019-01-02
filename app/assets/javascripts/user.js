var user_function = function() {
	var $select = $('select.selectize').selectize({
    copyClassesToDropdown: true
	});
	$('#notifications input[type="checkbox"], #notifications #day_pick').change(function(){
		var notifications = false;
		var notification_status = $('#notifications input[type="checkbox"]').prop('checked');
		if($(this).is('#notifications input[type="checkbox"]')){
			$('.selectize_flex_container').toggleClass('faded_out')
		}
		if(notification_status) {
			notifications = true;
		}
		var day_pick = $('#day_pick').val();
		var weekdays = [0,1,2,3,4,5,6];
		if (weekdays.includes(parseInt(day_pick))){
			$.ajax({
				type: "POST",
				url: "/users/notifications",
				data: "notifications[" + notifications + "]&weekday[" + day_pick + "]",
				dataType: "script"
			});
		} else {
			if($(this).is('#notifications input[type="checkbox"]') && !notification_status ) {
				$select[0].selectize.setValue(weekdays[0]);
			}
		}
	});
}

var pass_user_email = function() {
	$('#forgotten_password_link').click(function(e){
		if ($('#session_email').val() != '') {
			var user_email = $('#session_email').val()
			e.preventDefault();
			window.location.replace('/password_resets/new?email=' + encodeURIComponent(user_email));
		}
	});
}

$(document).ready(function() {
	if ($('#notifications').length > 0) {
		user_function();
	}
	if ($('#forgotten_password_link').length > 0) {
		pass_user_email();
	}
});
