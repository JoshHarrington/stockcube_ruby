import { ready, ajaxRequest } from './utils'

const globalFn = () => {
	ajaxRequest('Update Stock', '/recipes/update_matches');
}

ready(globalFn)