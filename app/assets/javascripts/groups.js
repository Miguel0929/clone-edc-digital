$(document).on('turbolinks:load', function(){
	universities= $("#group_university_id").html()
	$("#group_state_id").change(function(){
		state = $('#group_state_id :selected').val();
		$.ajax({
			url: "/universities/state.json?state="+state,
			type: "GET",
			success: function(data) {
				$('#group_university_id').empty()	
				options=data;
				$('#group_university_id').append($('<option></option>').val("").html("Selecciona una universidad"))
	  			if (options){
					$.each(options, function(id, name) {   
     					$('#group_university_id').append($('<option></option>').val(id).html(name)); 
					});
					console.log(options);
				}else{
					$('#group_university_id').empty()	
				}
			}
		});
	});	
});
