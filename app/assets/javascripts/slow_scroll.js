$('.groups_student_control').ready(function () {
	$('.slow_scroll').click(function(){
	$('html, body').animate({
	scrollTop: $( $(this).attr('href') ).offset().top
	}, 500);
	return false;
	});
});