var user_function = function() {
	$('#notifications input[type="checkbox"]').change(function(){
		console.log('hello');
		var notifications = false;
		if($(this).prop('checked')) {
			notifications = true;
		}
		$.ajax({
			type: "POST",
			url: "/users/notifications",
			data: (notifications ? "notifications[true]" : "notifications[false]"),
			dataType: "script"
		});
	});
}

$(document).on("turbolinks:load", function() {
	if ($('#notifications').length > 0) {
		user_function();
	}
});
