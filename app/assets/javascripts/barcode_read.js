var quagga_init = function (){
	Quagga.init({
		inputStream : {
			name : "Live",
			type : "LiveStream",
			target: document.querySelector('#quagga_element')
		},
		decoder : {
			readers: [
				'ean_reader',
			],
			debug: {
					drawBoundingBox: true,
					showFrequency: false,
					drawScanline: false,
					showPattern: false
			},
			multiple: true
		}
	}, function(err) {
		if (err) {
			console.log(err);
			return
		}
		console.log("Initialization finished. Ready to start");
		Quagga.start();
	});
}


$(document).on("turbolinks:load", function() {
	if ($('#quagga_element').length > 0) {
		quagga_init();
	}
});
