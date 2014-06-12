root = global ? window
#http://requirebin.com/?gist=6031068
Timeboxes = new Meteor.Collection("Timeboxes");
Users = new Meteor.Collection("Users")


if root.Meteor.isClient
  Session.set("currentUserID", undefined)

  countdown = 0

  createUser = (username) ->

    # Create a temporary user if appropriate
    if username == "TemporaryUser" 
        number = Users.find({temp:true}).count() + 1
        username += number.toString()
        temp = true
    else
        temp = false

    # Check if username already exists
    if not Users.findOne({username: username})
      userID = Users.insert({
        username: username,
        temp: temp,
        date_modified: new Date(),
      })
      Session.set("currentUserID", userID)
      userID
    else
      Session.set("loginError", "This username is taken")

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
    if Users.findOne(Session.get("currentUserID")) == undefined
      createUser('TemporaryUser')
    timeboxID = Timeboxes.insert {
      userID: Session.get("currentUserID"),
      duration: duration,
      startTime: new Date(),
      endTime: undefined,
      complete: false,
      tags: undefined,
    }
    Session.set("currentTimeboxID", timeboxID)
    timeboxID

  completeTimebox = () ->
    timeboxID = Session.get("currentTimeboxID")
    userID = Session.get("currentUser")
    tags = $("#tagsField").val().split(",")
    Timeboxes.update timeboxID, 
        {$set: 
          {
            complete: true,
            tags: tags
          }
        }
    timeboxID
      
  testReset = (timeboxID) ->
    Timeboxes.remove(timeboxID)
    countdown = 0
    Session.set("timeRemaining", secondFormat(countdown))

  timer = () ->
      countdown -= 1;
      if countdown >= 0
        Session.set("timeRemaining", secondFormat(countdown))
        document.title = secondFormat(countdown)
      if countdown == 0
        completeTimebox(Session.get("currentTimeboxID"))
        audio = new Audio "cChord.mp3"
        audio.play()
        # alert("You have left the zone")
      countdown



  setInterval () -> 
      timer()
    , 1000


  # getPosition = (id, style) ->
  #   element = document.getElementById(id)
  #   if element.getAttribute("style", style)
  #     value = parseInt(element.getAttribute("style", style).split(":")[1].split("px")[0])

  # setPosition = (id, style, value) ->
  #   element = document.getElementById(id)
  #   if element.getAttribute("style", style)
  #     set = style + ":" + value.toString() + "px"
  #     star1.setAttribute("style",set);


  
  # stars = () ->
  #   star1 = document.getElementById('star1')
  #   if star1
  #       transform()
  #   if star1.getAttribute("style", "top")
  #     yaxis = getPosition("star1", "top")
  #     setPosition("star1", "top", yaxis+1)
  #     console.log(yaxis)
  #   else
  #     star1.setAttribute("style", "top:0px")

  # starMovement = setInterval () -> 
  #     stars()
  #   , 50


  Handlebars.registerHelper "timeRemaining", () ->
    Session.get("timeRemaining")

  Handlebars.registerHelper "currentTimebox", () ->
    Timeboxes.findOne(Session.get("currentTimeboxID"))

  Handlebars.registerHelper "userAddress", () ->
    if Meteor.user()
      Meteor.user().emails[0].address
    else
      undefined

  Handlebars.registerHelper "date", (date) ->
    date.getDate()

  Handlebars.registerHelper "time", (date) ->
    date.getTime()

  # Handlebars.registerHelper "timeboxes", () ->
  #   userID = Session.get("currentUserID")
  #   Timeboxes.find({}, {sort: {startTime: -1}, limit: 10}).fetch()


  root.Template.timerButtons.events
    "click .start.sec3": () ->
      startTimebox(3)
    "click .start.min5": () ->
      startTimebox(300)
    "click .start.min25": () ->
      startTimebox(1500)

  root.Template.login.loginError = () ->
    return Session.get("loginError")

  root.Template.userInfo.timeboxes = () ->
    Timeboxes.find({}, {sort: {startTime: -1}, limit: 10}).fetch()

  root.Template.timeboxData.create_date = () ->
    this.startTime.toDateString()
  root.Template.timeboxData.create_time = () ->
    this.startTime.toLocaleTimeString()

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
root.testReset = testReset
  




