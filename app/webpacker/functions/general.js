import { ready } from "./utils"

const pageSetup = () => {
  document.querySelector('html').classList.remove('no-js')
  document.querySelector('html').classList.add('js')
}

const generalFn = () => {
  pageSetup()
}

ready(generalFn)
