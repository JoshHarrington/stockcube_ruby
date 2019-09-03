const ready = (fn) => {
  if (document.readyState != 'loading'){
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}


const ajaxRequest = (data, path, loop = 0) => {
	const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  const request = new XMLHttpRequest()

  request.open('POST', path, true)
  request.setRequestHeader('X-CSRF-Token', csrfToken)
  request.onerror = function() {
    console.log('there was an error with the request')
  };
  request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8')
  request.onload = function () {
    if (this.status === 500 && loop < 4) {
      setTimeout(() => ajaxRequest(data, path, loop + 1), 600)
    }
  };
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