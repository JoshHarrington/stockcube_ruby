$(document).on('turbolinks:load', function() {
  if ($('#stock-form[method="post"]')) {
    (function() {
      var empty;
      empty = false;
      $('#stock-form input').each(function() {
        if ($(this).val() === '') {
          empty = true;
        }
      });
      if (empty) {
        return $('input[type="submit"]').attr('disabled', 'disabled');
      }
    })();
    $('#stock-form input').on('keyup blur', function(e) {
      var empty;
      empty = false;
      $('#stock-form input').each(function() {
        if ($(this).val() === '') {
          empty = true;
        }
      });
      if (empty) {
        $('input[type="submit"]').attr('disabled', 'disabled');
        return $(this).siblings('.message-special').removeAttr('hidden');
      } else {
        return $('input[type="submit"]').removeAttr('disabled');
      }
    });
    $('#stock-form input').on('keyup blur', function(e) {
      if ($(this).val() !== '') {
        return $(this).siblings('.message-special').attr('hidden', 'hidden');
      }
    });
  }
});