const ready = (fn) => {
  if (document.readyState != 'loading'){
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}


const ajaxRequest = (data, path, loop = 0, type = 'application/x-www-form-urlencoded; charset=UTF-8') => {
	const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  const request = new XMLHttpRequest()

  request.open('POST', path, true)
  request.setRequestHeader('X-CSRF-Token', csrfToken)
  request.onerror = function() {
    console.log('there was an error with the request')
  };
  request.setRequestHeader('Content-Type', type)
  request.onload = function () {
    if (this.status === 500 && loop < 4) {
      setTimeout(() => ajaxRequest(data, path, loop + 1), 600)
    }
  };
  request.send(data)
  return request
}


const makeUniqueId = (length) => {
  let result           = '';
  const characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  const charactersLength = characters.length;
  for ( let i = 0; i < length; i++ ) {
     result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }
  return result
}

const showAlert = (message, hideTime = 8000) => {
	let alertGroup
	if (document.querySelector('.alert_group')) {
		alertGroup = document.querySelector('.alert_group')
	} else {
		const innerWrap = document.querySelector('#inner-wrap')
		alertGroup = document.createElement('div')
		alertGroup.classList.add('alert_group')
		innerWrap.prepend(alertGroup)
  }
  const otherAlerts = document.querySelectorAll('.alert_wrapper')

	const alertWrapper = document.createElement('div')
	alertWrapper.classList.add('alert_wrapper', 'alert_hide')
	alertGroup.appendChild(alertWrapper)
	const alertNotice = document.createElement('div')
	alertNotice.classList.add('alert', 'alert-notice')
	alertNotice.innerHTML = message
	alertWrapper.appendChild(alertNotice)
	setTimeout(() => {
		alertWrapper.classList.remove('alert_hide')
  }, 15)

  if (otherAlerts.length > 0) {
    setTimeout(() => {
      otherAlerts.forEach(el => {
        el.classList.add('alert_hide')
      })
    }, 600)
  }


	setTimeout(() => {
		alertWrapper.classList.add('alert_hide')
	}, hideTime)

}


const qs = s => document.createDocumentFragment().querySelector(s)

const isSelectorValid = selector => {
  try { qs(selector) }
  catch (e) { return false }
  return true
}

const isMobileDevice = () => {
  return (typeof window.orientation !== "undefined") || (navigator.userAgent.indexOf('IEMobile') !== -1);
};



export {
  ready,
  ajaxRequest,
  makeUniqueId,
  showAlert,
  isSelectorValid,
  isMobileDevice
}