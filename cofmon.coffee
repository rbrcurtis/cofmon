url = require 'url'
readline = require 'readline'

coffee = require 'coffee-script'

{completer, scanVariable, scanDBs} = require './completer'

tid = null
proc = require 'child_process'
shell = proc.spawn 'mongo', process.argv.slice 2
rl = readline.createInterface
  input: process.stdin
  output: process.stdout
  completer: completer

query = ->
	rl.question '> ', (data) ->
		scanVariable data
		try
			data = data.replace /('[0-9a-f]{24}')/g, "ObjectId($1)"
			if data.match /^(show|use|it|help)( |\n)/
				c = data+"\n"
			else
				if data.match /^db\.\w+\.\w+$/
					data += '()'
				c = coffee.compile data.toString(), {bare:true}
			shell.stdin.write c
		catch e
			shell.stdin.write data
		tid = setTimeout query, 100

shell.stdout.on 'data', (data) ->
	scanDBs data
	process.stdout.write data.toString()
	if tid then clearTimeout tid
	setTimeout query

shell.stderr.on 'data', (data) ->
	process.stderr.write data.toString()
	if tid then clearTimeout tid
	setTimeout query

shell.on 'exit', ->
	process.exit(0)

rl.on 'SIGINT', ->
	process.stdout.write '\nbye'
	process.stdout.write '\n'
	process.exit(0)