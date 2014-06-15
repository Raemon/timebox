root = global ? window
#http://requirebin.com/?gist=6031068
Timeboxes = new Meteor.Collection("Timeboxes");
Users = new Meteor.Collection("Users")



if root.Meteor.isClient
  countdown = 1500
  Session.set("currentUserID", undefined)
  timerRunning = false

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



  startTimebox = () ->
    setCountdown_fromTimer()
    for timebox in Timeboxes.find({userID: Meteor.userId()}).fetch()
      if !timebox.complete
        Timeboxes.remove(timebox._id)
    Session.set("timeRemaining", secondFormat(countdown))
    if Users.findOne(Session.get("currentUserID")) == undefined
      createUser('TemporaryUser')
    timeboxID = Timeboxes.insert {
      userID: Meteor.userId(),
      duration: countdown,
      startTime: new Date(),
      endTime: undefined,
      complete: false,
      tags: $("#tagsField").val().split(","),
    }
    timerRunning = true
    Session.set("currentTimeboxID", timeboxID)
    timeboxID

  completeTimebox = () ->
    latestTimebox = Timeboxes.findOne({userID: Meteor.userId()}, {sort: {startTime: -1}})
    tags = $("#tagsField").val().split(",")
    Timeboxes.update latestTimebox._id, 
        {$set: 
          {
            complete: true,
            final_duration: latestTimebox.duration - countdown
            tags: tags
          }
        }
    timerRunning = false
    setTimer_and_countdown(latestTimebox.duration)
    latestTimebox._id
      
  testReset = (timeboxID) ->
    Timeboxes.remove(timeboxID)
    countdown = 1500
    Session.set("timeRemaining", secondFormat(countdown))

  timer = () ->
    if timerRunning
      countdown -= 1;
      if countdown >= 0
        Session.set("timeRemaining", secondFormat(countdown))
        document.title = secondFormat(countdown)
      if countdown == 0
        completeTimebox(Session.get("currentTimeboxID")) 
        if Meteor.user().emails[0].address == "raemon777@gmail.com"
          alert("You have left the zone")
        audio = new Audio "cChord.mp3"
        audio.play()

      countdown



  setInterval () -> 
      timer()
    , 1000

  #helper functions
  zfill = (string, n) ->
    string = string.toString()
    while string.length < n
      string = "0" + string
    string

  Handlebars.registerHelper "timeRemaining", () ->
    Session.get("timeRemaining")

  Handlebars.registerHelper "currentTimebox", () ->
    Timeboxes.findOne(Session.get("currentTimeboxID"))

  Handlebars.registerHelper "range", (n) ->
    _.range(59)

  Handlebars.registerHelper "zfill", (string, n) ->
    zfill(string, n)

  Handlebars.registerHelper "userAddress", () ->
    if Meteor.user()
      Meteor.user().emails[0].address
    else
      undefined

  Handlebars.registerHelper "userTimeboxes", () ->
    Timeboxes.find({userID: Meteor.userId()}, {sort: {startTime: -1}, limit: 10}).fetch()

  Handlebars.registerHelper "date", (date) ->
    date.getDate()

  Handlebars.registerHelper "time", (date) ->
    date.getTime()

  Handlebars.registerHelper "isRay", () ->
    if Meteor.user()
      Meteor.user().emails[0].address == "raemon777@gmail.com"
    else
      false

  Handlebars.registerHelper "settingTimer", () ->
    Session.get("settingTimer")

  keycodeIsNumber = (input) ->
    if input >= 48 && input <=57
      true

  timerUneditable = () ->
    document.getElementById("secondsTimer").contentEditable = false
    document.getElementById("minutesTimer").contentEditable = false


  root.Template.currentTimebox.editing = () ->
    return Session.get("timerEditing")

  setCountdown_fromTimer = ()->
    countdown = 0
    countdown += parseInt(document.getElementById("minutesSelect").value) * 60
    countdown += parseInt(document.getElementById("secondsSelect").value)
    Session.set("timeRemaining", secondFormat(countdown))

  setTimer_and_countdown = (seconds) ->
    document.getElementById("minutesSelect").value = parseInt(seconds/60).toString()
    document.getElementById("secondsSelect").value = parseInt(seconds%60).toString()
    countdown = seconds
    Session.set("timeRemaining", secondFormat(countdown))

  root.Template.currentTimebox.events

    "click #minutesTimer" : (e) ->
      Session.set("timerEditing", "editing minutes")

    "keydown #secondsTimer" : (e) ->
      seconds = document.getElementById("secondsTimer")
      minutes = document.getElementById("minutesTimer")
      if e.which >= 48 && e.which <=57
        if seconds.value.toString().length >= 2
          minutes.focus()

  root.Template.timerButtons.events
    "click .timer-set": () ->
      if Session.equals("settingTimer", undefined)
        timerRunning = false
        Session.set("settingTimer", "settingTimer")
        document.getElementById("minutesSelect").value = parseInt(countdown / 60).toString()
        document.getElementById("secondsSelect").value = parseInt(countdown % 60).toString()
      else
        Session.set("settingTimer", undefined)
        setCountdown_fromTimer()

    "click .timer-start": () ->
      if Session.equals("settingTimer", undefined)
        startTimebox()
      else
        Session.set("settingTimer", undefined)
        setCountdown_fromTimer()
        startTimebox()
    "click .timer-stop": () ->
      Session.set("settingTimer", undefined)
      setCountdown_fromTimer()
      completeTimebox()

  root.Template.timeboxData.events
    "click .repeatTimebox": () ->
      $('#tagsField').importTags('')
      if this.tags
        for tag in this.tags
          $("#tagsField").addTag(tag)
      setTimer_and_countdown(this.duration)
      console.log(this)
      console.log(countdown)
      startTimebox()


  root.Template.login.loginError = () ->
    return Session.get("loginError")


  root.Template.timeboxData.create_date = () ->
    timeboxDateStr = this.startTime.toDateString()
    todayDate = new Date()
    if timeboxDateStr == todayDate.toDateString()
      return "Today"

    return timeboxDateStr

  root.Template.timeboxData.create_time = () ->
    moment(this.startTime).format("h:mm A")
  root.Template.timeboxData.duration = () ->
    secondFormat(this.duration)
  root.Template.timeboxData.complete = () ->
    if this.complete
      return "Completed"
    else
      return "Incomplete"
  root.Template.timeboxData.bgcolor = () ->
    if this.duration >= 300
      color = "red"
    if this.duration >= 600
      color = "green"
    if this.duration >= 900
      color = "blue"
    if this.duration >= 1200
      color = "gold"
    if this.duration >= 1500
      color = "cyan"
    if this.duration >= 1800
      color = "white"
    color
    

  Template.currentTimebox.rendered = () ->
    countdown = 1500
    document.getElementById("minutesSelect").value = "25"
    Session.set("timeRemaining", secondFormat(countdown))

  Template.oldTimeboxes.rendered = () ->
    latestTimebox = Timeboxes.findOne({userID: Meteor.userId()}, {sort: {startTime: -1}})
    console.log(latestTimebox)
    $('#tagsField').importTags('')
    for tag in latestTimebox.tags
      $("#tagsField").addTag(tag)

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




