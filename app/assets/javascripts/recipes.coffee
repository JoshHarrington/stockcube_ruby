# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  # $('#search-form #search').focus()
  cuisine = ''
  ingredientsArray = []
  cuisine_tag_container = $('.cuisine_tag_container')
  $('#cuisine_dl, #cuisine').change ->
    val = $(this).val()
    val_element = '<span class="cuisine_tag">' + val + '<span class="button">X</span></span>'
    option_value = ' option[value\=\"'+val+'\"]'
    if !cuisine.includes(val)
      cuisine = val
      cuisine_tag_container.append(val_element)
      $('#cuisine_dl, #cuisine').attr 'hidden', 'hidden'

    $('#cuisine' + option_value).attr 'disabled', 'disabled'
    $('#cuisine_list' + option_value).attr 'disabled', 'disabled'
    cuisine_tag_container.removeAttr('hidden')
    $('#cuisine_dl').val('')
    $('#cuisine_h').val cuisine
    return

  $('body').on 'click', '.cuisine_tag_container .button', ->
    $('#cuisine_dl, #cuisine').removeAttr('hidden')
    cuisine_tag_container.empty()
    cuisine_tag_container.attr 'hidden', 'hidden'
    $('#cuisine_dl option, #cuisine option').removeAttr('disabled')
    $('#cuisine option').first().attr 'selected', 'selected'
    $('#cuisine_h').val cuisine
    return

  $('#ingredients_dl, #ingredients').change ->
    ingredients_tags_container = $('.ingredients_tags')
    val = $(this).val()
    val_element = '<span class="ingredient_tag"><span class="ingredient_tag_content">' + val + '</span><span class="button">X</span></span>'
    option_value = ' option[value\=\"'+val+'\"]'

    $('#ingredients' + option_value).attr 'disabled', 'disabled'
    $('#ingredient_list' + option_value).attr 'disabled', 'disabled'

    ingredientsArray.push(val)
    ingredients_tags_container.append(val_element)

    ingredients_tags_container.removeAttr('hidden')
    $('#ingredients_dl').val('')
    $('#ingredients_h').val ingredientsArray.join('|')
    return

  $('body').on 'click', '.ingredients_tags .button', ->
    val = $(this).siblings('.ingredient_tag_content').text()
    $(this).parent().attr 'hidden', 'hidden'
    i = ingredientsArray.indexOf(val)
    if i != -1
      ingredientsArray.splice i, 1
    $('#ingredients_h').val ingredientsArray.join('|')
    $(this).parent().remove()
  return
