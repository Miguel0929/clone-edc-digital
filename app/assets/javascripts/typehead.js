$( document ).on('turbolinks:load', function() {
  $('.typehead-entries').typeahead({ hint: false}, {
    name: 'entries',
    autoSelect: false,
    minLength: 1,
    delay: 400,
    limit: 10,
    display: 'name',
    source: new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      remote: {
        url: '/api/v1/users?search=%QUERY',
        wildcard: '%QUERY'
      }
    }),
    templates: {
      suggestion: function (entry) {
        return '<div>'+
        '<h6 class="search-h4">' + entry.name  + '</h6>'+
        '<p class="text-black">' + entry.phone_number  + '</p>'+
        '<p class="text-complete">' + entry.email  + '</p>'+
        '</div>';
      }
    }
 })
 .bind('typeahead:selected', function(obj, datum) {
   window.location = datum.url;
 });
});
