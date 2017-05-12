$(document).on 'turbolinks:load', ->
  $('#group-search').keypress (e) ->
    if e.keyCode == 13
      query = $(this).val()
      window.location = "/mentor/groups?query="+query
      e.preventDefault
  
  $('#group_student').keypress (e) ->
    if e.keyCode == 13
      query = $(this).val()
      window.location = "?query="+query
      e.preventDefault
  
  $('#mentor_students').keypress (e) ->
    if e.keyCode == 13
      query = $(this).val()
      window.location = "?query="+query
      e.preventDefault
  $('#admin_students').keypress (e) ->
    if e.keyCode == 13
      query = $(this).val()
      window.location = "?query="+query
      e.preventDefault
  return

