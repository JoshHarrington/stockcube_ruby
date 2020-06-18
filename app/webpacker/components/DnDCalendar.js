import React, {useState, useEffect} from 'react'
import { Calendar, Views, momentLocalizer } from 'react-big-calendar'
import withDragAndDrop from 'react-big-calendar/lib/addons/dragAndDrop'
import { showAlert, addRecipeToPlanner } from '../functions/utils'
import * as classNames from "classnames"

import Moment from "moment"
import Icon from './Icon'

const localizer = momentLocalizer(Moment)

const DragAndDropCalendar = withDragAndDrop(Calendar)

function updateRecipeData(
  plannerRecipeId,
  newDate,
  csrfToken,
  updatePlannerRecipes,
  updateSuggestedRecipes,
  updateCheckedPortionCount,
  updateTotalPortionCount,
  updateShoppingListPortions
) {
	const data = {
		method: 'post',
    body: JSON.stringify({
      "planner_recipe_id": plannerRecipeId,
      "new_date": newDate
    }),
		headers: {
			'Content-Type': 'application/json',
			'X-CSRF-Token': csrfToken
		},
		credentials: 'same-origin'
  }

	showAlert("Updating recipe date in planner")

  fetch("/planner/recipe_update", data).then((response) => {
    if(response.status === 200){
      return response.json();
		} else {
			window.alert('Something went wrong! Maybe refresh the page and try again')
			throw new Error('non-200 response status')
    }
  }).then((jsonResponse) => {
    updatePlannerRecipes(jsonResponse.plannerRecipes)
		updateSuggestedRecipes(jsonResponse.suggestedRecipes)
		updateCheckedPortionCount(jsonResponse.checkedPortionCount)
		updateTotalPortionCount(jsonResponse.totalPortionCount)
    updateShoppingListPortions(jsonResponse.shoppingListPortions)
    showAlert("Planner and shopping list updated")
  })
}

const moveEvent = (
  { event, start, end, isAllDay },
  events,
  updateEvents,
  updatePlannerRecipes,
  updateSuggestedRecipes,
  updateCheckedPortionCount,
  updateTotalPortionCount,
  updateShoppingListPortions,
  csrfToken
) => {
  console.log('moveEvent')

  if (Date.parse(event.start) !== Date.parse(start)) {
    const nextEvents = events.map(existingEvent => {
      return existingEvent.id == event.id
        ? { ...existingEvent, start, end }
        : existingEvent
    })
    updateEvents(nextEvents)

    updateRecipeData(
      event.id,
      Moment(start).format('YYYY-MM-DD'),
      csrfToken,
      updatePlannerRecipes,
      updateSuggestedRecipes,
      updateCheckedPortionCount,
      updateTotalPortionCount,
      updateShoppingListPortions
    )
  }


  // alert(`${event.title} was dropped onto ${updatedEvent.start}`)
}


function deleteRecipeFromCalendar(
	plannerRecipeId,
	csrfToken,
  updatePlannerRecipes,
  updateSuggestedRecipes,
  updateCheckedPortionCount,
  updateTotalPortionCount,
  updateShoppingListPortions,
  events,
  updateEvents
) {

  updateEvents(events.filter(existingEvent => existingEvent.id !== event.id))

	const data = {
		method: 'post',
    body: JSON.stringify({
      "planner_recipe_id": plannerRecipeId
    }),
		headers: {
			'Content-Type': 'application/json',
			'X-CSRF-Token': csrfToken
		},
		credentials: 'same-origin'
  }

	showAlert("Removing recipe from your planner")

  fetch("/planner/recipe_delete", data).then((response) => {
    if(response.status === 200){
      return response.json();
		} else {
			window.alert('Something went wrong! Maybe refresh the page and try again')
			throw new Error('non-200 response status')
    }
  }).then((jsonResponse) => {
		updatePlannerRecipes(jsonResponse["plannerRecipes"])
		updateSuggestedRecipes(jsonResponse["suggestedRecipes"])
		updateCheckedPortionCount(jsonResponse["checkedPortionCount"])
		updateTotalPortionCount(jsonResponse["totalPortionCount"])
		updateShoppingListPortions(jsonResponse["shoppingListPortions"])

		showAlert("Recipe removed from your planner")
  });
}

function Event(
  { event },
  csrfToken,
  updatePlannerRecipes,
  updateSuggestedRecipes,
  updateCheckedPortionCount,
  updateTotalPortionCount,
  updateShoppingListPortions,
  events,
  updateEvents,
  yesterday,
  weeksTime
) {

  let fadedOut = false

  if (Date.parse(event.start) < yesterday) {
    fadedOut = true
  } else if(Date.parse(event.start) > weeksTime) {
    fadedOut = true
  }

  return (
    <div className={classNames(
        "flex justify-between items-start p-2 rounded-sm h-full",
        {"bg-primary-400 text-black": !fadedOut},
        {"bg-primary-200 text-gray-600": fadedOut}
      )}>
      <span className="leading-snug">{event.title}</span>
      <button
        className="p-1 mb-1 ml-2 w-6 h-6 bg-white rounded-sm flex-shrink-0 flex focus:shadow-outline"
        onClick={() => deleteRecipeFromCalendar(
          event.id,
          csrfToken,
          updatePlannerRecipes,
          updateSuggestedRecipes,
          updateCheckedPortionCount,
          updateTotalPortionCount,
          updateShoppingListPortions,
          events,
          updateEvents
        )}
      ><Icon name="close" className="w-full h-full" /></button>
    </div>
  )
}

function EventAgenda({ event }) {
  return (
    <span>
      <em style={{ color: 'magenta' }}>{event.title}</em>
      <p>{event.desc}</p>
    </span>
  )
}

const customDayPropGetter = (date, yesterday, weeksTime) => {
  if(Date.parse(date) < yesterday) {
    return {
      className: 'bg-gray-100'
    }
  }
  if(Date.parse(date) > weeksTime) {
    return {
      className: 'bg-gray-100'
    }
  }
}

function onDropFromOutside(
  e,
  events,
  updateEvents,
  currentlyDraggedItem,
  updatePlannerRecipes,
  updateSuggestedRecipes,
  updateCheckedPortionCount,
  updateTotalPortionCount,
  updateShoppingListPortions,
  csrfToken
) {

  updateEvents([...events, {
    id: currentlyDraggedItem.encodedId,
    title: currentlyDraggedItem.title,
    start: e.start,
    end: e.end,
    allDay: true
  }])

  console.log(e)

  addRecipeToPlanner(
    currentlyDraggedItem.encodedId,
    csrfToken,
    updatePlannerRecipes,
    updateSuggestedRecipes,
    updateCheckedPortionCount,
    updateTotalPortionCount,
    updateShoppingListPortions,
    Moment(e.start).format('YYYY-MM-DD')
  )

  // const event = {
  //   id: draggedEvent.id,
  //   title: draggedEvent.title,
  //   start,
  //   end,
  //   allDay: allDay,
  // }

  // this.setState({ draggedEvent: null })
  // moveEvent({ event, start, end })
}

const Dnd = props => {
  const {
    updatePlannerRecipes,
    csrfToken,
    updateSuggestedRecipes,
    updateCheckedPortionCount,
    updateTotalPortionCount,
    updateShoppingListPortions,
    events,
    updateEvents,
    currentlyDraggedItem
  } = props

  const yesterday = new Date(new Date().setDate(new Date().getDate()-1));
  const weeksTime = new Date(new Date().setDate(new Date().getDate()+6));

  return (
    <DragAndDropCalendar
      localizer={localizer}
      startAccessor="start"
      endAccessor="end"
      selectable
      events={events}
      onEventDrop={(e) => moveEvent(
        e,
        events,
        updateEvents,
        updatePlannerRecipes,
        updateSuggestedRecipes,
        updateCheckedPortionCount,
        updateTotalPortionCount,
        updateShoppingListPortions,
        csrfToken
      )}
      popup={true}
      views={['week', 'month']}
      components={{
        event: (e) => Event(
          e,
          csrfToken,
          updatePlannerRecipes,
          updateSuggestedRecipes,
          updateCheckedPortionCount,
          updateTotalPortionCount,
          updateShoppingListPortions,
          events,
          updateEvents,
          yesterday,
          weeksTime
        ),
        agenda: {
          event: EventAgenda,
        },
      }}
      dayPropGetter={(date) => customDayPropGetter(date, yesterday, weeksTime)}
      onDropFromOutside={(e) => onDropFromOutside(
        e,
        events,
        updateEvents,
        currentlyDraggedItem,
        updatePlannerRecipes,
        updateSuggestedRecipes,
        updateCheckedPortionCount,
        updateTotalPortionCount,
        updateShoppingListPortions,
        csrfToken
      )}
    />
  )
}

export default Dnd
