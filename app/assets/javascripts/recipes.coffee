# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('#search-form #recipes').focus()
  cuisine = ''
  ingredientsArray = []
  cuisine_tag_container = $('.cuisine_tag_container')
  $('#cuisine_dl, #cuisine_select').change ->
    val = $(this).val()
    val_element = '<span class="cuisine_tag">' + val + '<span class="button">X</span></span>'
    option_value = ' option[value\=\"'+val+'\"]'
    cuisine = val
    cuisine_tag_container.append(val_element)
    $('#cuisine_dl, #cuisine_select').attr 'hidden', 'hidden'

    $('#cuisine_select' + option_value + ', #cuisine_list' + option_value).attr 'disabled', 'disabled'
    cuisine_tag_container.removeAttr('hidden')
    $('#cuisine_dl, #cuisine_select').val('')
    $('#cuisine').val cuisine
    return

  $('body').on 'click', '.cuisine_tag_container .button', ->
    $('#cuisine_dl, #cuisine_select').removeAttr('hidden')
    cuisine_tag_container.empty()
    cuisine_tag_container.attr 'hidden', 'hidden'
    $('#cuisine_dl option, #cuisine_select option').removeAttr('disabled')
    $('#cuisine').val cuisine
    return

  $('#ingredients_dl, #ingredients_select').change ->
    ingredients_tags_container = $('.ingredients_tags')
    val = $(this).val()
    val_element = '<span class="ingredient_tag"><span class="ingredient_tag_content">' + val + '</span><span class="button">X</span></span>'
    option_value = ' option[value\=\"'+val+'\"]'

    $('#ingredients_select' + option_value + ', #ingredient_list' + option_value).attr 'disabled', 'disabled'

    ingredientsArray.push(val)
    ingredients_tags_container.append(val_element)

    ingredients_tags_container.removeAttr('hidden')
    $('#ingredients_dl, #ingredients_select').val('')
    $('#ingredients').val ingredientsArray.join('|')
    return

  $('body').on 'click', '.ingredients_tags .button', ->
    val = $(this).siblings('.ingredient_tag_content').text()
    option_value = ' option[value\=\"'+val+'\"]'
    $(this).parent().attr 'hidden', 'hidden'
    i = ingredientsArray.indexOf(val)
    if i != -1
      ingredientsArray.splice i, 1
    $('#ingredients').val ingredientsArray.join('|')
    $('#ingredients_dl' + option_value + ', #ingredients_select' + option_value).removeAttr('disabled')
    $(this).parent().remove()
    return

  setTimeout (->
    $('#search-form #submit').removeAttr('disabled')
    $('#search-form #submit').prop('disabled', false)
    console.log 'hi'
  ), 3000
  return
