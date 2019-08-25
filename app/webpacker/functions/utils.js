const ready = (fn) => {
  if (document.readyState != 'loading'){
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}

let iterations = 0

const ajaxRequest = (data, path, type, windowObj = undefined) => {
	const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  const request = new XMLHttpRequest()
  const requestType = type || 'POST'

  request.open(requestType, path, true)
  request.setRequestHeader('X-CSRF-Token', csrfToken)
  request.onerror = function() {
    console.log('there was an error with the request')
  };
  if (requestType == 'POST') {
    request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8')
  } else if (requestType == 'GET') {
    request.setRequestHeader('Content-Type', 'application/json')
    request.onload = function() {
      if (this.status >= 200 && this.status < 400) {
        // Success!
        const resp = JSON.parse(this.response)

        if (windowObj !== undefined) {

          if (data === resp && requestType === 'GET' && iterations < 10) {
            // response is the same as when the page loaded
            ++iterations
            const restartRequest = window.setTimeout(() => {ajaxRequest(data, path, type)}, .2*1000)
          } else {
            window[windowObj] = resp
          }
        }

      } else {
        // We reached our target server, but it returned an error
        console.log('error getting data from the server')
      }
    }
  }
  request.send(data)
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


export {
  ready,
  ajaxRequest,
  makeUniqueId
}