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

const updateTypicalIngredientUseByDate = (target) => {
  const IngredientBlock = target.closest('.list_block.list_block__column')
  const value = target.value
  const useByDateObj = new Date((new Date()).getTime() + (Number(value) * (60*60*24*1000)))
  let useByDateMonthString = String(Number(useByDateObj.getUTCMonth()) + 1)
  if (useByDateMonthString.length < 2){
    useByDateMonthString = "0" + useByDateMonthString
  }
  let useByDateDayString = String(useByDateObj.getUTCDate())
  if (useByDateDayString.length < 2){
    useByDateDayString = "0" + useByDateDayString
  }

  const useByDateString = useByDateObj.getUTCFullYear() + '-' + useByDateMonthString + '-' + useByDateDayString

  const useByDateFields = IngredientBlock.querySelectorAll('input[name="stock[use_by_date]"]')

  useByDateFields.forEach((field) => {
    field.value = useByDateString
  })
}

const watchForUseByDateChange = () => {
  if(document.querySelector('.stocks_controller.new_page')){
    const UpdateUseByDateInputs = document.querySelectorAll('.set_use_by_date_diff')
    UpdateUseByDateInputs.forEach((Input) => {
      Input.addEventListener('change', (e) => {
        updateTypicalIngredientUseByDate(e.target)
      })
    })
  }
}

const stockPageFunctions = () => {
  deleteStockBtnFunction()
  watchForUseByDateChange()
}

ready(stockPageFunctions)
