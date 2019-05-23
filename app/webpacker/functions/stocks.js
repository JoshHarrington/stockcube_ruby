$(document).ready(function() {
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
  const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

  function deleteStock(hashedId, cupboardId) {
		const confirmed = confirm("Are you sure you want to delete this ingredient from your cupboards?");
		if (confirmed == true) {
			const data = "stock_id=" + hashedId
			const request = new XMLHttpRequest()
			request.open('POST', '/stocks/delete_stock', true)
			request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8')
			request.setRequestHeader('X-CSRF-Token', csrfToken)
      request.send(data)
      window.location.replace('/cupboards#' + cupboardId)
		}
	}

	const deleteBtns = document.querySelectorAll('.delete_stock_btn')
	deleteBtns.forEach(function(btn) {
		const hashedId = btn.getAttribute('id')
		const cupboardId = btn.getAttribute('data-cupboard-id')
		btn.addEventListener('click', function(){deleteStock(hashedId, cupboardId)}, false)
		btn.addEventListener('keypress', function(e){
      if (e.key === 'Enter') {
        deleteStock(hashedId, cupboardId)
      }
    }, false)
	})
};


$(document).ready(function() {
	if ($('#stock_form').length > 0) {
    stock_form();
	}
});
