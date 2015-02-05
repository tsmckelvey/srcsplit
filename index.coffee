#!/usr/bin/env coffee
fs      = require 'fs'
_       = require 'lodash'
cson    = require 'cson'
coffee  = require 'coffee-script'
sandbox = require './lib/transformers'
cli     = require 'commander'

cli.version('0.0.1')
   .usage('[options] <file>')
   .option('-s, --stream <stream>', 'Stream to write')
   .parse(process.argv)

inputFile = _.first cli.args

lines = fs.readFileSync(inputFile).toString()

# Normalize line-endings
lines = lines.trim().replace /\r\n|\r/g, "\n"

matchers = {
  Cfg: /^\/\*-\n((.|\n)*)-\*\//g
  Cmd: /^\[([a-zA-Z0-9]+)\]/
  StreamNameCmd: /^\[~([a-zA-Z0-9]+)\]/
}

buffers = {}

# Read configuration block
config = {}

if lines.substr(0, 3) is '/*-'
  cfgMatch = matchers.Cfg.exec lines

  if cfgMatch[1]
    config = cson.parseSync cfgMatch[1], { sandbox }
    lines = lines.substr lines.indexOf('-*/') + 3

currentState = 'Command'
currentCommand = 'All'

# Initialize empty named buffers
lines.split("\n").forEach (line) ->
  if matchers.StreamNameCmd.test line
    stream = _.last matchers.StreamNameCmd.exec line
    buffers[stream] = []

# Add values to buffers
lines.split("\n").forEach (line) ->
  if matchers.Cmd.test line
    cmd = _.last matchers.Cmd.exec line

    if cmd is 'All'
      currentState = 'Command'
      currentCommand = 'All'

    return

  if matchers.StreamNameCmd.test line
    currentState = 'Line'
    stream = _.last matchers.StreamNameCmd.exec line
    currentCommand = stream

    return

  # Do operations
  if currentState is 'Command'
    if currentCommand is 'All'
      # Add line to every buffer
      _.forOwn buffers, (n, key) -> n.push line

  if currentState is 'Line'
    # Add line to current buffer
    buffers[currentCommand].push line

# Apply 'All'
if config.All? and _.isArray(config.All)
  _.forEach config.All, (mutator) ->
    _.forOwn buffers, (n, key) ->
      buffers[key] = mutator buffers[key]

# Apply named buffer transforms
_.forOwn config, (n, key) ->
  if key isnt 'All'
    # TODO: Dedupe this w/ All
    _.forEach config[key], (mutator) ->
      buffers[key] = mutator buffers[key]

# Join buffers into strings
_.forOwn buffers, (n, key) -> buffers[key] = buffers[key].join "\n"

# Print named stream
if cli.stream? and buffers[cli.stream]?
  console.log buffers[cli.stream]
# Print All (useful for debugging)
else
  _.forOwn buffers, (b) -> console.log b
