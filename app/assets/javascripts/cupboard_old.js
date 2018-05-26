// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.


// window.onbeforeunload = confirmExit;
// function confirmExit()
// {
// 	return "You have attempted to leave this page.  If you have made any changes to the fields without clicking the Save button, your changes will be lost.  Are you sure you want to exit this page?";
// }
$(document).on('turbolinks:load', function() {


  if ($('.cupboard_edit_all')) {
		console.log('cupboard only');

		var dispatchUnloadEvent = function() {
			var event = document.createEvent("Events");
			event.initEvent("turbolinks:unload", true, false);
			document.dispatchEvent(event);
		}

		addEventListener("beforeunload", dispatchUnloadEvent);
		addEventListener("turbolinks:before-render", dispatchUnloadEvent);
	}
});


var cupboardFunction = function() {
	if ($('.cupboard_edit_all')) {
		console.log('check check');
	}
}
