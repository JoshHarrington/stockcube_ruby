$(document).on('turbolinks:load', function() {
  if ($('#stock_form[method="post"]')) {
    (function() {
      var empty;
      empty = false;
      $('#stock_form input').each(function() {
        if ($(this).val() === '') {
          empty = true;
        }
      });
      if (empty) {
        return $('input[type="submit"]').attr('disabled', 'disabled');
      }
    })();
    $('#stock_form input').on('keyup blur', function(e) {
      var empty;
      empty = false;
      $('#stock_form input').each(function() {
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
    $('#stock_form input').on('keyup blur', function(e) {
      if ($(this).val() !== '') {
        return $(this).siblings('.message-special').attr('hidden', 'hidden');
      }
    });
  }
});

var stock_form = function(){
  $('select').selectize({
    create: true,
    sortField: 'text',
    copyClassesToDropdown: true
  });
};


$(document).on("turbolinks:load", function() {
	if ($('#stock_form').length > 0) {
		stock_form();
	}
});
