# Description:
#   Example scripts for you to examine and try out.
#   These are from the scripting documentation:
#   https://github.com/github/hubot/blob/master/docs/scripting.md

cradle = require("cradle")

module.exports = (robot) ->

  VCAP = process.env.VCAP_SERVICES
  unless VCAP?
    console.error "Missing VCAP credentials. Please set & try again."
    process.exit(1)

  console.log(VCAP)

  VCAP_OBJ = JSON.parse(VCAP)

  dbCreds = VCAP_OBJ["cloudantNoSQLDB"][0].credentials
  client = new(cradle.Connection) dbCreds.host, dbCreds.port, auth:
    username: dbCreds.username
    password: dbCreds.password
  db = client.database("party-bot-playlists")
  db.exists (err, exists) ->
    if err then console.log('error', err)
    else if exists then console.log('Database exists.  Proceed as expected')
    else
      console.log('Database does not exist.  Creating...')
      db.create()
      #TBD Populate Design Documents?

  #sanity check for functioning bot responses
  robot.hear /badger/i, (res) ->
    res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"

  #store messages from party-bot into cloudant db
  robot.respond /playlist (.*)$/i, (res) ->
    songRequest = res.match[1]
    message = res.message
    message.date = new Date
    message.songRequest = songRequest

    db.save message, (err, res) ->
      if err then console.error(err)

    res.reply "Song request for '#{songRequest}' has been submitted!"
