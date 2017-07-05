// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require ahoy
//= require jquery-ui
//= require medium-editor
//= require jquery.turbolinks
//= require jquery_ujs
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require dataTables/extras/dataTables.responsive
//= require dataTables/extras/dataTables.fixedColumns
//= require dataTables/extras/dataTables.tableTools
//= require turbolinks
//= require bootstrap
//= require ckeditor/init
//= require modernizr
//= require jquery.scrollbar
//= require cocoon
//= require Chart.bundle
//= require chartkick
//= require jquery-readyselector
//= require_tree "."
//= stub landings/pace.min
//= stub landings/pages.frontend
//= stub landings/velocity.min
//= stub landings/velocity.ui
//= require editable/bootstrap-editable
//= require editable/rails
//= require typeahead.js.js

$(document).on('turbolinks:load', function(){
  $('.editable').editable();
});
