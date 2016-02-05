_ = require "lodash"
Redux = require "Redux"
riot = require "riot"
todosTag = require "./tags/todos.tag"

next_id = 0
addTodo = (text) ->
  type: "ADD_TODO"
  id: next_id++
  text: text

setTodosFilter = (filter) ->
  type: "SET_TODOS_FILTER"
  filter: filter

toggleTodo = (id) ->
  type: "TOGGLE_TODO"
  id: id

todoReducer = (state, action) ->
  switch action.type
    when "ADD_TODO"
      id: action.id
      text: action.text
      completed: no
    when "TOGGLE_TODO"
      if state.id is action.id
        _.assign {}, state, completed: !state.completed
      else state
    else state

todosReducer = (state = [], action) ->
  switch action.type
    when "ADD_TODO" then [
      state...
      todoReducer undefined, action
    ]
    when "TOGGLE_TODO"
      state.map (todo) -> todoReducer todo, action
    else state

todosFilterReducer = (state = "SHOW_ALL", action) ->
  switch action.type
    when "SET_TODOS_FILTER"
      action.filter
    else state

appReducer = Redux.combineReducers
  todos: todosReducer
  todosFilter: todosFilterReducer

ContextMixin =
  init: ->
    if not @store?
      console.log "here"
      ob = @
      ob = ob.parent while ob.parent?
      console.log ob
      @store = ob.opts.store
      @addTodo = addTodo
      @setTodosFilter = setTodosFilter
      @toggleTodo = toggleTodo

SubscribeMixin =
  init: ->
    console.log "here"
    ContextMixin.init.call @
    @on "mount", ->
      @unsubscribe = @store.subscribe => riot.mount @root, store: @store
    @on "unmount", ->
      @unsubscribe()

riot.mixin "context", ContextMixin
riot.mixin "subscribe", SubscribeMixin
riot.mount todosTag, store: Redux.createStore appReducer
