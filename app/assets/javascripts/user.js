var user_function = function() {
	var $select = $('select.selectize').selectize({
    copyClassesToDropdown: true
	});
	var selectize = $select[0].selectize;
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
				selectize.setValue(weekdays[0]);
			}
		}
	});
}

$(document).on("turbolinks:load", function() {
	if ($('#notifications').length > 0) {
		user_function();
	}
});
