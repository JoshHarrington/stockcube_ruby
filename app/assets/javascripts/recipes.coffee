# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
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
    cuisine_tag_container.empty()
    cuisine_val = $('#cuisine').val()
    val_element = '<span class="cuisine_tag">' + cuisine_val + '<span class="button">X</span></span>'
    option_value = ' option[value\=\"'+cuisine_val+'\"]'
    cuisine_tag_container.append(val_element)
    $('#cuisine_dl, #cuisine_select').attr 'hidden', 'hidden'
    $('#cuisine_select' + option_value + ', #cuisine_list' + option_value).attr 'disabled', 'disabled'
    cuisine_tag_container.removeAttr('hidden')
    $('#cuisine_dl, #cuisine_select').val('')

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
    ingredientsArray_processed = false
    if ingredientsArray_processed == false
      ingredients_tags_container.empty()
      val = $('#ingredients').val()
      if val.includes('|')
        ingredientsArray = val.split('|')
      else
        ingredientsArray = [val]
      i = 0
      while i < ingredientsArray.length
        ingredients_val = ingredientsArray[i]
        val_element = '<span class="cuisine_tag"><span class="ingredient_tag_content">' + ingredients_val + '</span><span class="button">X</span></span>'
        option_value = ' option[value\=\"' + ingredients_val + '\"]'
        $('#ingredients_select' + option_value + ', #ingredient_list' + option_value).attr 'disabled', 'disabled'
        ingredients_tags_container.append(val_element)
        i++
      ingredients_tags_container.removeAttr('hidden')
      $('#ingredients_dl, #ingredients_select').val('')
    ingredientsArray_processed = true


  $('#search-form').submit ->
    ## need method to check if #recipes is empty on submit
    # if !$('#recipes').text()
      # $('#recipes').prop 'disabled', true

    if !cuisine
      $('#cuisine').prop 'disabled', true
    if !ingredientsArray.join()
      $('#ingredients').prop 'disabled', true
    $('#ingredients_dl, #ingredients_select, #cuisine_dl, #cuisine_select').prop 'disabled', true
    return
