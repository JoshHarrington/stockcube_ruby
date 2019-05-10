$(document).ready(function() {
  var previousDate;
  $('html').removeClass('no-js');
  $('.no_js_show').prop('hidden', true);
  $('.js_show').prop('hidden', false);

  if (Modernizr.input.list) {
    $('html').removeClass('input-list-supported');
  } else {
    $('html').addClass('input-list-not-supported');
    return;
  }
  if (!Modernizr.inputtypes.date) {
    $('html').addClass('input-type-date-not-supported');
    $('input[type="date"]').datepicker({
      dateFormat: 'yy-mm-dd',
      minDate: new Date(),
      changeMonth: true,
      changeYear: true
    });
    previousDate = void 0;
    $('input[type="date"]').focus(function() {
      previousDate = $(this).val();
    });
    $('input[type="date"]').blur(function() {
      var newDate;
      newDate = $(this).val();
      if (!moment(newDate, 'yy-mm-dd', true).isValid()) {
        $(this).val(previousDate);
        console.log('Error');
      }
    });
    return $('input[type="date"]').on('keyup', function(e) {
      if (e.keyCode === 13) {
        $(this).trigger('focusout');
        return false;
      }
    });
  } else {
    return $('html').addClass('input-type-date-supported');
  }
});
