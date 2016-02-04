Redux = require "Redux"
_ = require "lodash"
riot = require "riot"
counter = require "./counter.tag"
jquery = require "jquery"

initialState = {count: 0}

bind = (store) ->
  ($el, event, action) ->
    $el.bind event, -> store.dispatch type: action

appState = (state = initialState, action) ->
  switch action.type
    when "INITIALIZE" then _.assign {}, state,
      bind: bind(store)
      $: jquery
    when "INCREMENT" then _.assign {}, state, count: state.count + 1
    when "DECREMENT" then _.assign {}, state, count: state.count - 1
    else state

store = Redux.createStore appState

store.dispatch type: "INITIALIZE"

render = ->
  riot.mount counter, store.getState()

store.subscribe render
render()
