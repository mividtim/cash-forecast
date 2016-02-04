counter
  h1 {count}
  button.increment +
  button.decrement -
  style(scoped).
    h1
      font-size: 500%
    button
      width: 200px
      height: 200px
      font-size: 200%
  script.
    @count = opts.count
    @on "mount", ->
      opts.bind opts.$("button.increment"), "click", "INCREMENT"
      opts.bind opts.$("button.decrement"), "click", "DECREMENT"
