$(document).on 'turbolinks:load', ->
  $('#group-search').keypress (e) ->
    if e.keyCode == 13
      query = $(this).val()
      window.location = "/mentor/groups?query="+query
      e.preventDefault
  return

