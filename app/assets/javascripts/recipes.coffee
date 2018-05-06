# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  # $('#search-form #search').focus()
  cuisine = ''
  ingredients = ''
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
    return

  $('#ingredients_dl, #ingredients').change ->
    ingredients_tags_container = $('.ingredients_tags')
    val = $(this).val()
    val_element = '<span class="ingredient_tag">' + val + '<span class="button">X</span></span>'
    option_value = ' option[value\=\"'+val+'\"]'
    if !ingredients.includes(val)
      if ingredients == ''
        ingredients += val
        ingredientsArray.push(val)
        ingredients_tags_container.append(val_element)
      else
        ingredients += '|'
        ingredients += val
        ingredientsArray.push(val)
        ingredients_tags_container.append(val_element)

    $('#ingredients' + option_value).attr 'disabled', 'disabled'
    $('#ingredient_list' + option_value).attr 'disabled', 'disabled'
    ingredients_tags_container.removeAttr('hidden')
    $('#ingredients_dl').val('')
    $('#ingredients_h').val ingredients

    # need to add method to remove ingredients from search

  return
