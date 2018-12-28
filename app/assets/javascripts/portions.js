var portion_form = function(){
  $('select').selectize({
    create: true,
    sortField: 'text',
    copyClassesToDropdown: true
  });
};


$(document).ready(function() {
	if ($('#portion_form').length > 0) {
    portion_form();
	}
});
