import React, {useState} from "react"

import {ShoppingListWrapper} from "./ShoppingListInternal"

function ShoppingListStandalone(props) {
  const [checkedPortionCount, updateCheckedPortionCount] = useState(props.checkedPortionCount)
  const [shoppingListShown, toggleShoppingListShow] = useState(false)
  const [totalPortionCount, updateTotalPortionCount] = useState(props.totalPortionCount)
  const [shoppingListComplete, updateShoppingListComplete] = useState(!!(checkedPortionCount === totalPortionCount))
  const [shoppingListPortions, updateShoppingListPortions] = useState(props.shoppingListPortions)
  const {controller, action, sharePath, csrfToken, mailtoHrefContent} = props

  const onListPage = !!(controller === "planner" && action === "list")
  const totalPortionsPositive = !!(totalPortionCount && totalPortionCount !== 0)
  const [toggleButtonShow, updateToggleButtonShow] = useState(!!(totalPortionsPositive && !onListPage))

  return (
    <ShoppingListWrapper
      checkedPortionCount={checkedPortionCount}
      updateCheckedPortionCount={updateCheckedPortionCount}

      shoppingListShown={shoppingListShown}
      toggleShoppingListShow={toggleShoppingListShow}

      totalPortionCount={totalPortionCount}
      updateTotalPortionCount={updateTotalPortionCount}

      shoppingListComplete={shoppingListComplete}
      updateShoppingListComplete={updateShoppingListComplete}

      shoppingListPortions={shoppingListPortions}
      updateShoppingListPortions={updateShoppingListPortions}

      toggleButtonShow={toggleButtonShow}
      updateToggleButtonShow={updateToggleButtonShow}

      totalPortionsPositive={totalPortionsPositive}
      onListPage={onListPage}
      sharePath={sharePath}
      mailtoHrefContent={mailtoHrefContent}
      csrfToken={csrfToken}
    />
  )
}

export default ShoppingListStandalone
