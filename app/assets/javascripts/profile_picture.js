$(document).on('turbolinks:load', function(){
  $('#upload_profile_picture').click(function(){
    $('#user_profile_picture').click();
  });

  $('#user_profile_picture').on('change', function(){
    if (this.files && this.files[0]) {
      var reader = new FileReader();

      reader.onload = function (e) {
        $('#profile_img').attr('src', e.target.result);
      };

      reader.readAsDataURL(this.files[0]);
    }
  });
});
