root = global ? window
#http://requirebin.com/?gist=6031068
Timeboxes = new Meteor.Collection("Timeboxes");
Users = new Meteor.Collection("Users")


if root.Meteor.isClient


  '''
  TODOS

  When a timer finishes, it should begin a break timer
  If a break timer is active

  If currentTimer is > 0, screen is blue
  If (on break) currentTimer is < 0 & > -300, screen is orange



  It should list your completed timeBoxes



  '''

  createUser = () ->
    userID = Users.insert({})

  secondFormat = (seconds) ->
    minutes = parseInt(seconds/60).toString()
    if minutes.length < 2
      minutes = "0" + minutes
    seconds = parseInt(seconds%60).toString()
    if seconds.length < 2
      seconds = "0" + seconds
    minutes + ":" + seconds

  startTimebox = (duration) ->
    countdown = duration
    timeboxID = Timeboxes.insert {
      duration: duration,
      startTime: new Date(),
      complete: false
    }
    Session.set("currentTimeboxID", timeboxID)
    timeboxID

  completeTimebox = () ->
    timeboxID = Session.get("currentTimeboxID")
    userID = Session.get("currentUser")
    tags = $('#tagsField').val().split(",")
    Timeboxes.update timeboxID, 
        {$set: 
          {
            complete: true,
            tags: tags
          }
        }
    timeboxID
      


  timer = () ->
      countdown -= 1;
      if countdown >= 0
        Session.set("timeRemaining", secondFormat(countdown))
        document.title = secondFormat(countdown)
      if countdown == 0
        audio = new Audio "cChord.mp3"
        audio.play()
        # alert("You have left the zone")
      countdown

  countdown = 0
  Session.set("timeRemaining", secondFormat(countdown))

  setInterval () -> 
      timer()
    , 1000

  Handlebars.registerHelper 'timeRemaining', () ->
    Session.get("timeRemaining")
  Handlebars.registerHelper 'currentTimebox', () ->
    Timeboxes.findOne(Session.get("currentTimeboxID"))

  root.Template.timerButtons.events
    'click .start.sec3': () ->
      countdown = 3
    'click .start.min5': () ->
      countdown = 300
    'click .start.min25': () ->
      countdown = 1500




 
if root.Meteor.isServer
  if exports? then root = exports
  if window? then root = window


root.Timeboxes = Timeboxes
root.Users = Users
root.startTimebox = startTimebox
root.completeTimebox = completeTimebox
root.secondFormat = secondFormat
root.timer = timer
root.createUser = createUser

  




