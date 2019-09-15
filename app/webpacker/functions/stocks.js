import { ready } from "./utils";

const deleteStockBtnFunction = () => {
  const stockDeleteBtn = document.querySelector('#stock_delete_btn')
  if (stockDeleteBtn) {
    stockDeleteBtn.addEventListener('click', (e) => {
      const confirmed = confirm("Are you sure you want to delete this ingredient from your cupboards?")
      if (!confirmed) {
        e.preventDefault()
      }
    })
  }
}

const stockPageFunctions = () => {
  deleteStockBtnFunction()
}

ready(stockPageFunctions)
