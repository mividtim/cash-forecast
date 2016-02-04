Redux = require "Redux"
counter = (state = 0, action) ->
  switch action.type
    when "INCREMENT" then state + 1
    when "DECREMENT" then state - 1
    else state
store = Redux.createStore counter
render = ->
  document.getElementsByClassName("content")[0]
    .innerText = store.getState()
store.subscribe render
render()
document.addEventListener "click", ->
  store.dispatch type: "INCREMENT"
