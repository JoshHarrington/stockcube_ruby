function clearNotice(){
  $(".alert").animate({
		opacity: 0
	}, 1500);
	$(".alert").css("pointer-events","none");
};

$(document).on('turbolinks:load', function(){
	setTimeout(function() {clearNotice();}, 5000);
});
