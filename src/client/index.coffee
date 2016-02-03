Redux = require "Redux"
counter = (state = 0, action) ->
  switch action.type
    when "INCREMENT" then state + 1
    when "DECREMENT" then state - 1
    else state
store = createStore counter
console.log store.getState()

