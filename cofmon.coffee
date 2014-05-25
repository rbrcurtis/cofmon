url = require 'url'
readline = require 'readline'

coffee = require 'coffee-script'

tid = null
proc = require 'child_process'
shell = proc.spawn 'mongo', process.argv.slice 2
rl = readline.createInterface process.stdin, process.stdout

query = ->
	rl.question '> ', (data) ->
		try
			data = data.replace /('[0-9a-f]{24}')/g, "ObjectId($1)"
			if data.match /^(show|use|it)( |\n)/ then c = data+"\n"
			else c = coffee.compile data.toString(), {bare:true}
			shell.stdin.write c
		catch e
			shell.stdin.write data
		tid = setTimeout query, 100

shell.stdout.on 'data', (data) ->
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