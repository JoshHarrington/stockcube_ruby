var portion_form = function(){
  $('select').selectize({
    create: true,
    sortField: 'text',
    copyClassesToDropdown: true
  });
};


$(document).on("turbolinks:load", function() {
	if ($('#portion_form').length > 0) {
    portion_form();
    beforeUnload();
	}
});
