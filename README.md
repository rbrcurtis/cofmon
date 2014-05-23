
A CoffeeScript Shell for MongoDB
------

so that you can write CoffeeScript instead of JavaScript in the Mongo Shell.

To use, just `npm install -g cofmon` and then use `cofmon` as you would the Mongo command.

In additon to being able to write CoffeeScript instead of JavaScript, any 24 character hex string that's wrapped in double quotes is automatically made into an `ObjectId`, i.e.

`'51bb660191888d7acc355ed8'` compiles to `ObjectId('51bb660191888d7acc355ed8')`
`"51bb660191888d7acc355ed8"` compiles to `"51bb660191888d7acc355ed8"`

Note that the quotes were reversed in a previous version. It was changed because the mongo repl returns object ids with double quotes, which meant you couldnt copy/paste the entire ID.
