assign = require "lodash.assign"
browserify = require "browserify"
buffer = require "vinyl-buffer"
coffeeify = require "coffeeify"
del = require "del"
process = require "process"
spawn = require("child_process").spawn
fs =  require "fs-extra"
gulp = require "gulp"
install = require "gulp-start"
jade = require "gulp-jade"
source = require "vinyl-source-stream"
sourcemaps = require "gulp-sourcemaps"
stylus = require "gulp-stylus"
util = require "gulp-util"
watchify = require "watchify"

run = (command, args) ->
  runningCommand = spawn command, args
  runningCommand.stdout.on "data", (data) ->
    process.stdout.write "#{command}: #{data}"
  runningCommand.stderr.on "data", (data) ->
    process.stderr.write "#{command}: #{data}"
  runningCommand.on "exit", (code) ->
    process.stdout.write "#{command} exited with code #{code}"

paths =
  clientScripts: "./src/client/index.coffee"
  serviceScripts: "./src/service/app.coffee"
  styles: "./src/**/*.stylus"
  templates: "./src/**/*.jade"
  static: "./static/**/*"
  build: "./build"
  clientBuild: "./build/client"
  serviceBuild: "./build/service"

customOpts =
  entries: paths.clientScripts
  debug: true
opts = assign {}, watchify.args, customOpts
b = watchify browserify opts
b.transform coffeeify

install = ->
  gulp.src "package.json"
    .pipe install()
clean = -> del "build"
buildStatic = ->
  gulp.src paths.static
    .pipe gulp.dest paths.build
buildScripts = ->
  b.bundle()
    .on "error", util.log.bind util, "Browserify Error"
    .pipe source "bundle.js"
    .pipe buffer()
    .pipe sourcemaps.init loadMaps: true
    .pipe sourcemaps.write "./"
    .pipe gulp.dest paths.clientBuild
buildStyles = ->
  gulp.src paths.styles
    .pipe sourcemaps.init()
    .pipe stylus()
    .pipe sourcemaps.write "."
    .pipe gulp.dest paths.build
buildTemplates = ->
  gulp.src paths.templates
    .pipe sourcemaps.init()
    .pipe jade pretty: true
    .pipe sourcemaps.write "."
    .pipe gulp.dest paths.build
build = gulp.parallel buildStatic, buildScripts, buildStyles, buildTemplates
defaultTask = gulp.series clean, build
watch =
  gulp.series clean, build, ->
    gulp.watch paths.scripts, buildScripts
    gulp.watch paths.styles, buildStyles
    gulp.watch paths.templates, buildTemplates
db = -> #run "mongodb", ["--dbpath", "./data"]
app = -> run "node", ["build/service/app.js"]
start = gulp.parallel db, app

gulp.task "install", install
gulp.task "default", defaultTask
gulp.task "clean", clean
gulp.task "build", build
gulp.task "watch", watch
gulp.task "start", start
gulp.task "db", db
gulp.task "app", app

