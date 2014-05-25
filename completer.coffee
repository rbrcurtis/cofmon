
dbMethods = require './db-methods'
collectionMethods = require './collection-methods'
jsGlobals = require './js-globals'

firstLevels = [
  'db.'
  'show'
  'use'
  'help'
  'it'
  'exit'
  'DBQuery'
  'rs'
  'sh'
  'load'
  'edit'
]

showCommands = [
  'dbs'
  'collections'
  'tables'
  'users'
  'profile'
  'logs'
  'log'
  'roles'
  'databases'
]

helpCommands = [
  'admin'
  'connect'
  'keys'
  'misc'
  'mr'
]

variables = []
dbNames = []
collectionNames = []

find = (text, query) ->
  (text.indexOf query) is 0

exports.completer = (data) ->
  if data.match /^\w*$/
    combined = variables.concat firstLevels
    hits = combined.filter (candidate) ->
      find candidate, data
    return [hits, data]

  if data.match /^show\s/
    match = data[5..]
    hits = showCommands.filter (candidate) ->
      find candidate, match
    return [hits, match]

  if data.match /^help\s/
    match = data[5..]
    hits = helpCommands.filter (candidate) ->
      find candidate, match
    return [hits, match]

  if data.match /^use\s/
    match = data[4..]
    hits = dbNames.filter (candidate) ->
      find candidate, match
    return [hits, match]

  if data.match /^db\.\w*$/
    match = data[3..]
    combined = collectionNames.concat dbMethods
    hits = combined.filter (candidate) ->
      find candidate, match
    return [hits, match]

  if (matchFind = data.match /^db\.\w+\.(\w*)$/)?
    match = matchFind[1]
    hits = collectionMethods.filter (candidate) ->
      find candidate, match
    return [hits, match]

  if (matchGlobal = data.match /[\s,\(\)=](\w*)$/)?
    match = matchGlobal[1]
    combined = variables.concat jsGlobals
    hits = combined.filter (candidate) ->
      find candidate, match
    return [hits, match]

  [[], '']

exports.scanVariable = (data) ->
  assignment = data.match /^([\w\.]+)\s*\=/
  if assignment?
    variable = assignment[1]
    unless variable in variables
      variables.push variable

exports.scanDBs = (data) ->
  data = data.toString()
  if data.match(/\d+GB/g)?.length > 1
    lines = data.split('\n')
    for line in lines
      matchDB = line.match /^(\w+)\s+/
      if matchDB?
        dbName = matchDB[1]
        dbNames.push dbName

  else if data.match(/^([\w\.]+\n)+$/)?
    gathers = data.trim().split('\n')
    .filter (candidate) -> candidate.indexOf('.') < 0

    if gathers.length > 0
      collectionNames = gathers