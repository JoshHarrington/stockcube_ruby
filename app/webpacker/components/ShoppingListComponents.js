import React from "react"
import * as classNames from "classnames"
import { showAlert, switchShoppingListClass } from "../functions/utils"

import Icon from './Icon'

function togglePortionCheck(
  portion,
  csrfToken,
  checked,
  updateShoppingListPortions,
  updateShoppingListComplete,
  updateCheckedPortionCount,
  updateTotalPortionCount
) {

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


  fetch("/stock/toggle_portion", data).then((response) => {
    if(response.status != 200){
      window.alert('Something went wrong! Maybe refresh the page and try again')
    } else {
      return response.json();
    }
  }).then((jsonResponse) => {
    updateShoppingListPortions(jsonResponse.shoppingListPortions)
    updateCheckedPortionCount(jsonResponse.checkedPortionCount)
    updateTotalPortionCount(jsonResponse.totalPortionCount)
    if (jsonResponse["checkedPortionCount"] === jsonResponse["totalPortionCount"]) {
      updateShoppingListComplete(true)
    }
    if (!checked){
      showAlert(`${jsonResponse["portionDescription"]} - added to your cupboards`, 20000)
    } else {
      showAlert(`${jsonResponse["portionDescription"]} - removed from your cupboards`, 20000)
    }
  });

}

function ShoppingListExample(props) {

  const {
    checkedPortionCount,
    updateCheckedPortionCount,
    shoppingListShown,
    toggleShoppingListShow,
    totalPortionCount,
    updateTotalPortionCount,
    shoppingListComplete,
    updateShoppingListComplete,
    shoppingListPortions,
    updateShoppingListPortions,
    toggleButtonShow,
    updateToggleButtonShow,
    totalPortionsPositive,
    onListPage,
    sharePath,
    mailtoHrefContent,
    csrfToken
  } = props


  return (
    <ShoppingListWrapper shoppingListShown={shoppingListShown}>
      {toggleButtonShow &&
        <ShoppingListButton
          switchShoppingListClass={switchShoppingListClass}
          shoppingListShown={shoppingListShown}
          toggleShoppingListShow={toggleShoppingListShow}
          checkedPortionCount={checkedPortionCount}
          totalPortionCount={totalPortionCount}
        />
      }
      <ShoppingListTopBanner
        totalPortionsPositive={totalPortionsPositive}
        checkedPortionCount={checkedPortionCount}
        totalPortionCount={totalPortionCount}
        sharePath={sharePath}
        mailtoHrefContent={mailtoHrefContent}
        onListPage={onListPage}
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
      {!!(totalPortionsPositive && !onListPage && !!mailtoHrefContent) &&
        <ShoppingListBottomBanner mailtoHrefContent={mailtoHrefContent} />
      }
    </ShoppingListWrapper>
  )
}

const ShoppingListWrapper = ({children, shoppingListShown}) => {
  return (
    <aside className="fixed h-screen bottom-0 right-0 z-10 bg-white border-0 border-l border-solid border-primary-200 transition-all duration-500" style={{width: "30rem", left: shoppingListShown ? 'calc(100% - 30rem)' : '100%'}}>
      <div className="flex h-screen flex-col">
        {children}
      </div>
    </aside>
  )
}

const ShoppingListButton = ({
  switchShoppingListClass,
  shoppingListShown,
  toggleShoppingListShow,
  checkedPortionCount,
  totalPortionCount
}) => {
  return (
    <button
      className="fixed border-0 bg-primary-600 text-white overflow-hidden outline-none transition-all duration-500 shadow-lg flex w-auto items-center rounded-full p-2 pr-4 right-0 top-0 mt-32 mr-5 focus:outline-none focus:shadow-outline"
      onClick={() => {
        switchShoppingListClass()
        toggleShoppingListShow(!shoppingListShown)
      }}
      style={{right: shoppingListShown ? '30rem' : 0}}>
      <>
        { shoppingListShown ? <Icon name="close" className="w-5 h-5 my-1 mx-1" /> :
        <Icon name="navigate_before" className="w-8 h-8" />}
        <span className="text-base">{`${checkedPortionCount}/${totalPortionCount}`}</span>
      </>
    </button>
  )
}

const ShoppingListTopBanner = ({
  totalPortionsPositive,
  checkedPortionCount,
  totalPortionCount,
  sharePath,
  mailtoHrefContent,
  onListPage
}) => {
  return (
    <div
      className="bg-primary-200 p-5 flex items-start flex-col justify-center relative"
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
  )
}

const ShoppingListBottomBanner = ({mailtoHrefContent}) => (
  <div className="bg-primary-200 flex p-8 w-full justify-center">
    <a href={mailtoHrefContent} className="bg-white px-8 py-4 cursor-pointer rounder-sm hover:bg-primary-50 focus:bg-primary-50 text-center _list_block--collection--action" target="_blank">Email shopping list</a>
  </div>
)

const PortionWrapper = ({
  shoppingListComplete,
  children
}) => {
  return (
    <ul className={classNames("py-8 px-5 flex flex-col flex-grow overflow-y-auto", {"text-center": shoppingListComplete})}>
      {children}
    </ul>
  )
}

const PortionItem = ({
  checked,
  portion,
  csrfToken,
  updateShoppingListPortions,
  updateShoppingListComplete,
  updateCheckedPortionCount,
  updateTotalPortionCount
}) => {
  return (
    <li
      id={portion.encodedId}
      className={classNames('shopping_list_portion flex items-baseline flex-wrap justify-between mb-6',
        {'portion_checked order-3': checked})}>
      <input
        type="checkbox" id={`planner_shopping_list_portions_add_${portion.encodedId}`}
        className="fancy_checkbox"
        onChange={() => {
          togglePortionCheck(
            portion,
            csrfToken,
            checked,
            updateShoppingListPortions,
            updateShoppingListComplete,
            updateCheckedPortionCount,
            updateTotalPortionCount
          )
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
}

export {
  ShoppingListExample,
  ShoppingListWrapper,
  ShoppingListButton,
  PortionWrapper,
  PortionItem,
  ShoppingListTopBanner,
  ShoppingListBottomBanner
}
