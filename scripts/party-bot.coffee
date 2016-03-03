# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md



module.exports = (robot) ->

   VCAP = process.env.VCAP_SERVICES
   unless VCAP?
     console.log "Missing VCAP_SERVICES in environment.  Please set and try again."
     process.exit(1)
   unless VCAP["cloudantNoSQLDB"]?
     console.log "Missing Cloudant VCAP_SERVICES credentials in environment.  Please bind and try again."
     process.exit(1)

   dbCreds = VCAP["cloudantNoSQLDB"[0].credentials
   client = new(cradle.Connection) dbCreds.host, dbCreds.port, auth:
     username: dbCreds.username
     password: dbCreds.password
   db = client.database("party-bot-playlists")

   #sanity check for functioning bot responses
   robot.hear /badger/i, (res) ->
     res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"

   #store messages from party-bot into cloudant db
   robot.respond /playlist (.*)$/i, (res) ->
     songRequest = res.match[1]
     message = res.message
     message.date = new Date

     db.save message, (err, res) ->
       if err then console.error(err)

     res.reply "Song request for '"+songRequest+"' has been submitted!"
