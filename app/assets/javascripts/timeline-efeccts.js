jQuery(document).ready(function($){
	var timelineBlocks = $('.timeline-block'),
		offset = 0.8;

	//Ocultar los bloques de línea de tiempo que están fuera de la ventana de visualización
	hideBlocks(timelineBlocks, offset);

	//muestra / anima los bloques de línea de tiempo al entrar en la ventana de visualización
	$(window).on('scroll', function(){
		(!window.requestAnimationFrame) 
			? setTimeout(function(){ showBlocks(timelineBlocks, offset); }, 100)
			: window.requestAnimationFrame(function(){ showBlocks(timelineBlocks, offset); });
	});

	function hideBlocks(blocks, offset) {
		blocks.each(function(){
			( $(this).offset().top > $(window).scrollTop()+$(window).height()*offset ) && $(this).find('.timeline-point, .timeline-content').addClass('is-hidden');
		});
	}

	function showBlocks(blocks, offset) {
		blocks.each(function(){
			( $(this).offset().top <= $(window).scrollTop()+$(window).height()*offset && $(this).find('.timeline-point').hasClass('is-hidden') ) && $(this).find('.timeline-point, .timeline-content').removeClass('is-hidden').addClass('bounce-in');
		});
	}
});
