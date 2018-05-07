# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('#search-form #recipes').focus()
  cuisine = ''
  ingredientsArray = []
  cuisine_tag_container = $('.cuisine_tag_container')
  ingredients_tags_container = $('.ingredients_tags')
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

  if $('#cuisine').val() != ''
    dl_val = $('#cuisine_dl').val()
    select_val = $('#cuisine_select').val()
    val_element = '<span class="cuisine_tag">' + select_val + '<span class="button">X</span></span>'
    option_value = ' option[value\=\"'+select_val+'\"]'
    cuisine = select_val
    cuisine_tag_container.append(val_element)
    $('#cuisine_dl, #cuisine_select').attr 'hidden', 'hidden'
    $('#cuisine_select' + option_value + ', #cuisine_list' + option_value).attr 'disabled', 'disabled'
    cuisine_tag_container.removeAttr('hidden')
    $('#cuisine_dl, #cuisine_select').val('')
    $('#cuisine').val cuisine

  $('body').on 'click', '.cuisine_tag_container .button', ->
    $('#cuisine_dl, #cuisine_select').removeAttr('hidden')
    cuisine_tag_container.empty()
    cuisine_tag_container.attr 'hidden', 'hidden'
    $('#cuisine_list option[disabled], #cuisine_select option[disabled]').removeAttr('disabled')
    $('#cuisine').val('')
    return

  $('#ingredients_dl, #ingredients_select').change ->
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
    $('#ingredient_list' + option_value + ', #ingredients_select' + option_value).removeAttr('disabled')
    $(this).parent().remove()
    return

  if $('#ingredients').val() != ''
    val = $('#ingredients').val()
    if val.includes('|')
      ingredientsArray = val.split('|')
    else
      ingredientsArray = [val]
    i = 0
    while i < ingredientsArray.length
      ingredients_val = ingredientsArray[i]
      console.log ingredients_val
      val_element = '<span class="cuisine_tag">' + ingredients_val + '<span class="button">X</span></span>'
      option_value = ' option[value\=\"' + ingredients_val + '\"]'
      $('#ingredients_select' + option_value + ', #ingredient_list' + option_value).attr 'disabled', 'disabled'
      ingredients_tags_container.append(val_element)
      i++
    ingredients_tags_container.removeAttr('hidden')
    $('#ingredients_dl, #ingredients_select').val('')


  $('#search-form').submit ->
    # if $('#recipes').is(':empty')
    #   $('#recipes').prop 'disabled', true
    # if $('#cuisine').is(':empty')
    #   $('#cuisine').prop 'disabled', true
    # if $('#ingredients').is(':empty')
    #   $('#ingredients').prop 'disabled', true
    $('#ingredients_dl, #ingredients_select, #cuisine_dl, #cuisine_select').prop 'disabled', true
    return
