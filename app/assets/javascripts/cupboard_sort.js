$( function() {
	$( ".cupboard.list_block" ).sortable({
		connectWith: ".cupboard.list_block",
		placeholder: "list_block--item_placeholder",
		items: ".list_block--item_show",
		cancel: ".empty-card"
	}).disableSelection();
} );

// $( ".column" ).on( "sortstart", function( event, ui ) {
// 	var currentCardHeight;
// 	currentCardHeight = ui.item.outerHeight();
// 	var placeholderStateMarker = $(".ui-state-highlight");
// 	placeholderStateMarker.height(currentCardHeight);
// 	placeholderStateMarker.parent().addClass('current-card-parent');
// } );

// $( ".column" ).on( "sortstop", function( event, ui ) {
// 	$('.current-card-parent').removeClass('current-card-parent');
// } );

// $('.card').click( function(e) {
// 	$('body').addClass('modal-overlay');
// 	e.stopImmediatePropagation();
// });
