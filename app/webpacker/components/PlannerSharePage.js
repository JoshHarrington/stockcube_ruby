import React, {useState, useEffect} from "react"

import {ShoppingListWrapper, PortionWrapper, PortionItem, ShoppingListTopBanner} from "./ShoppingListComponents"
import Icon from "./Icon"

function PlannerSharePage(props) {
  const [checkedPortionCount, updateCheckedPortionCount] = useState(props.checkedPortionCount)
  const [totalPortionCount, updateTotalPortionCount] = useState(props.totalPortionCount)
  const [shoppingListPortions, updateShoppingListPortions] = useState(props.shoppingListPortions)
  const {sharePath, csrfToken, mailtoHrefContent} = props


  const [shoppingListComplete, updateShoppingListComplete] = useState(!!(checkedPortionCount === totalPortionCount))
	useEffect(() => {
    if (checkedPortionCount === totalPortionCount) {
      updateShoppingListComplete(true)
		} else {
      updateShoppingListComplete(false)
		}
  }, [checkedPortionCount, totalPortionCount])

  const [totalPortionsPositive, updateTotalPortionsPositive] = useState(!!(totalPortionCount && totalPortionCount !== 0))
  useEffect(() => {
		if (!!(totalPortionCount && totalPortionCount !== 0)) {
			updateTotalPortionsPositive(true)
		} else {
			updateTotalPortionsPositive(false)
		}
  }, [totalPortionCount])

  return (
    <>
      <ShoppingListTopBanner
        totalPortionsPositive={totalPortionsPositive}
        checkedPortionCount={checkedPortionCount}
        totalPortionCount={totalPortionCount}
        sharePath={sharePath}
        mailtoHrefContent={mailtoHrefContent}
        onListPage={true}
      />
      <PortionWrapper shoppingListComplete={shoppingListComplete}>
        {!totalPortionsPositive && <p>Shopping List is currently empty, move some recipes to <a href="/planner" className="underline">your planner</a> to get items added to this list</p>}
        {!!(totalPortionsPositive && !shoppingListComplete) &&
          <>
            {shoppingListPortions.map((portion, index) => (
              <PortionItem
                key={index}
                checked={portion.checked}
                portion={portion}
                csrfToken={csrfToken}
                updateShoppingListPortions={updateShoppingListPortions}
                updateShoppingListComplete={updateShoppingListComplete}
                updateCheckedPortionCount={updateCheckedPortionCount}
                updateTotalPortionCount={updateTotalPortionCount}
              />
            ))}
            {checkedPortionCount > 0 &&
              <li className="order-2 text-base pt-6 border-0 border-t border-solid border-gray-300 text-gray-600 mb-6">
                Items added to cupboards:
              </li>
            }
          </>
        }
        {!!(totalPortionsPositive && shoppingListComplete) &&
          <p><Icon name="checkmark" className="mr-3 h-8 w-8 text-green-500"/>Shopping list complete</p>
        }
      </PortionWrapper>
    </>
  )
}

export default PlannerSharePage
