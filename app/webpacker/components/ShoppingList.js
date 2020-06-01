import React, {useState} from "react"
// import PropTypes from "prop-types"
const classNames = require('classnames')
import SVG from '../icons/symbol-defs.svg'

function Icon(props) {
  const name = props.name
  const className = props.className
  return (
    <svg className={className}><use className="fill-current" xlinkHref={`${SVG}#icon-${name}`} /></svg>
  )
}

function togglePortionCheck(portion, csrfToken, checked) {

	const data = {
		method: 'post',
    body: JSON.stringify({
      "shopping_list_portion_id": portion.encodedId,
      "portion_type": portion.type
    }),
		headers: {
			'Content-Type': 'application/json',
			'X-CSRF-Token': csrfToken
		},
		credentials: 'same-origin'
  }

  if (!checked) {
    fetch("/stock/add_portion", data)
  } else {
    fetch("/stock/remove_portion", data)
  }

}

function switchShoppingListClass() {
  document.querySelector('html').classList.toggle('shopping_list_open')
}

function ShoppingList(props) {
  const [checkedPortionCount, updateCheckedPortionCount] = useState(props.checkedPortionCount)
  const [shoppingListShown, toggleShoppingListShow] = useState(false)
  const totalPortionCount = props.totalPortionCount
  const [shoppingListComplete, updateShoppingListComplete] = useState(!!(checkedPortionCount === totalPortionCount))
  const shoppingListPortions = props.shoppingListPortions
  const controller = props.controller
  const action = props.action

  const onListPage = !!(controller === "planner" && action === "list")
  const totalPortionsPositive = !!(totalPortionCount && totalPortionCount !== 0)
  const showToggleButton = !!(totalPortionsPositive && !onListPage)

  const sharePath = props.sharePath

  const mailtoHrefContent = props.mailtoHrefContent

  return (
    <div>
      {showToggleButton &&
        <button
          className="fixed border-0 bg-primary-600 text-white overflow-hidden outline-none transition-all duration-500 shadow-lg flex w-auto items-center rounded-full p-2 pr-4 right-0 top-0 mt-32 mr-5 focus:outline-none focus:shadow-outline"
          onClick={() => {
            switchShoppingListClass()
            toggleShoppingListShow(!shoppingListShown)
          }}
          style={{right: shoppingListShown ? '30rem' : 0}}>
          <>
            { shoppingListShown ? <Icon name="close" className="w-5 h-5 my-2 mx-1" /> :
            <Icon name="navigate_before" className="w-8 h-8" />}
            <span className="text-base">{`${checkedPortionCount}/${totalPortionCount}`}</span>
          </>
        </button>
      }
      <div
        className="bg-primary-200 p-5 flex items-start flex-wrap flex-col justify-center relative"
        style={{minHeight: "7rem"}}>
        <div className="flex justify-between w-full">
          <h2>Shopping List { totalPortionsPositive && `(${checkedPortionCount}/${totalPortionCount})`}</h2>
          {!!(!!sharePath && !onListPage) && <a href={sharePath} className="w-10 h-10 bg-white hover:bg-primary-400 ml-2"><Icon className="w-full h-full flex items-center justify-center text-black" name="fullscreen"/></a>}
        </div>
        {totalPortionsPositive && <p data-name="shopping-list-note" className="flex text-gray-600 text-sm mt-2">Add to cupboards by checking off items</p>}
        {!!(!!mailtoHrefContent && onListPage) &&
          <a
            href={mailtoHrefContent}
            className="mt-8 bg-white p-3 inline-block rounded hover:bg-primary-700 hover:text-white focus:bg-primary-800 focus:text-white"
            target="_blank">Email shopping list</a>}
      </div>
      <ul className={classNames("py-8 px-5 flex flex-col", {"text-center": shoppingListComplete})}>
        {!totalPortionsPositive && <p>Shopping List is currently empty, move some recipes to <a href="/planner" className="underline">your planner</a> to get items added to this list</p>}
        {!!(totalPortionsPositive && checkedPortionCount !== totalPortionCount) &&
          <>
            {shoppingListPortions.map((portion, index) => {
              const [checked, updateCheck] = useState(portion.checked)
              return (
                <li
                  key={index}
                  id={portion.encodedId}
                  className={classNames('shopping_list_portion flex items-baseline flex-wrap justify-between mb-6',
                    {'portion_checked order-3': checked})}>
                  <input
                    type="checkbox" id={`planner_shopping_list_portions_add_${portion.encodedId}`}
                    className="fancy_checkbox"
                    onChange={() => {
                      togglePortionCheck(portion, props.csrfToken, checked)
                      if (!checked) {
                        updateCheckedPortionCount(checkedPortionCount + 1)
                      } else {
                        updateCheckedPortionCount(checkedPortionCount - 1)
                      }
                      updateCheck(!checked)
                      if (checkedPortionCount === totalPortionCount) {
                        updateShoppingListComplete(true)
                      }
                    }}
                    name={`planner_shopping_list_portions_add[${portion.encodedId}]`} checked={checked} />
                  <label className={classNames('fancy_checkbox_label flex-wrap text-lg')} htmlFor={`planner_shopping_list_portions_add_${portion.encodedId}`}>
                    <span className={classNames({'line-through text-gray-500': checked})}>
                      {portion.description}
                    </span>
                    { checked &&
                      <span className="fresh_note w-full text-sm mt-1 text-gray-500">Typically fresh for {portion.freshForTime} days</span>
                    }
                  </label>
                </li>
              )
            })}
            {checkedPortionCount > 0 &&
              <li className="order-2 text-base pt-6 border-0 border-t border-solid border-gray-300 text-gray-600 mb-6">
                Items added to cupboards:
              </li>
            }
          </>
        }
        {!!(totalPortionsPositive && checkedPortionCount === totalPortionCount) && <p><Icon name="checkmark" className="mr-3 h-8 w-8 text-green-500"/>Shopping list complete</p>}
      </ul>
    </div>
  )
}

export default ShoppingList
