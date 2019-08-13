const ready = (fn) => {
  if (document.readyState != 'loading'){
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}

const ajaxRequest = (data, path) => {
	const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
	const request = new XMLHttpRequest()
	request.open('POST', path, true)
	request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8')
	request.setRequestHeader('X-CSRF-Token', csrfToken)
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