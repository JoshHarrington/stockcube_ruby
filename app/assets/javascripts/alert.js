function clearNotice(){
  $(".alert").animate({
		opacity: 0
	}, 1500);
	$(".alert").css("pointer-events","none");
};

$(document).ready(function() {
	setTimeout(function() {clearNotice();}, 6000);
});
