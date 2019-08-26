const ready = (fn) => {
  if (document.readyState != 'loading'){
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}


const ajaxRequest = (data, path, type, windowObj = undefined, iterations = 0) => {
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

        if (this.status === 202 && iterations < 15) {
          // server not ready, retry in a moment
          const restartRequest = window.setTimeout(() => {ajaxRequest(data, path, type, windowObj, iterations + 1)}, .3*1000)
        } else {

          // Success!
          const resp = JSON.parse(this.response)

          if (windowObj !== undefined) {

            /// is there a difference between the resp and the data?

            let difference = false
            if (resp.length === 0 && resp.length !== data.length) {
              difference = true
            } else if ( resp.filter(x => !data.includes(x)).length !== 0 || data.filter(x => !resp.includes(x)).length !== 0) {
              difference = true
            }

            window.resp = resp
            window.data = data

            if (difference) {
              window[windowObj] = resp
            } else if (!difference && requestType === 'GET' && iterations < 10) {
              // response is the same as when the page loaded
              const restartRequest = window.setTimeout(() => {ajaxRequest(data, path, type, windowObj, iterations + 1)}, .3*1000)
            } else {
              // ran ten times, resp still the same as data, setting the window obj to be whatever the resp is
              window[windowObj] = resp
            }
          }
        }

      } else {
        // We reached our target server, but it returned an error
        console.log('error getting data from the server, restarting request if iterations less than 5')
        if (iterations < 5) {
          const restartRequest = window.setTimeout(() => {ajaxRequest(data, path, type, windowObj, iterations + 1)}, .3*1000)
        }
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