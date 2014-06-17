'''
Todos

Create Readme for Github
Fix startTimebox for testing
test if clicking start creates the right timer
create dropdown menu for recently used timer-settings
Create tab-structure
Basic Tracking
  total time spent todayday
  How many timers in a row you've done today
  Begin a break timer after a work timer
Toggle-able-Dialogbox
Begin with tags from latestTimebox

Done:

    !total time spend on a tag
    !total timeboxes done on a tag

'''










root = global ? window
Timeboxes = new Meteor.Collection("Timeboxes");
Tags = new Meteor.Collection("Tags")



if root.Meteor.isClient


  countdown = 1500
  Session.set("currentUserID", undefined)
  Session.set("timeboxLimit", 8)
  timerRunning = false

  fixThings = () ->
    for timebox in Timeboxes.find().fetch()
      console.log(timebox)
      if timebox.duration && timebox.final_duration
        if timebox.duration == timebox.final_duration
          Timeboxes.update(timebox._id, { $set: {complete: "Completed"}})
        else
          Timeboxes.update(timebox._id, { $set: {complete: "Partial"}})
      else
        Timeboxes.update(timebox._id, { $set: {complete: "Completed"}})
      adjustTags(timebox)



  # createUser = (username) ->

  #   # Create a temporary user if appropriate
  #   if username == "TemporaryUser" 
  #       number = Users.find({temp:true}).count() + 1
  #       username += number.toString()
  #       temp = true
  #   else
  #       temp = false

  #   # Check if username already exists
  #   if not Users.findOne({username: username})
  #     userID = Users.insert({
  #       username: username,
  #       temp: temp,
  #       date_modified: new Date(),
  #     })
  #     Session.set("currentUserID", userID)
  #     userID
  #   else
  #     Session.set("loginError", "This username is taken")

  secondFormat = (seconds) ->
    hours = parseInt(seconds/3600).toString()
    if hours != "0"
      if hours.length < 2
        minutes = "0" + minutes
      hours += ":"
    else
      hours = ""
    minutes = parseInt((seconds%3600)/60).toString()
    if minutes.length < 2
      minutes = "0" + minutes
    minutes += ":"
    seconds = parseInt((seconds%3600)%60).toString()
    if seconds.length < 2
      seconds = "0" + seconds
    hours + minutes + seconds

  latestTimebox = () ->
    Timeboxes.findOne({userID: Meteor.userId()}, {sort: {startTime: -1}})

  interruptCounter = () ->
    if latestTimebox()
      if countdown != 0
        complete = "Partial"
      else
        complete = "Completed"
      tags = $("#tagsField").val().split(",")
      Timeboxes.update latestTimebox()._id, 
          {$set: 
            {
              complete: complete,
              tags: tags
            }
          }

  startTimebox = () ->
    interruptCounter()
    setCountdown_fromTimer()
    Session.set("timeRemaining", secondFormat(countdown))
    # if Users.findOne(Session.get("currentUserID")) == undefined
    #   createUser('TemporaryUser')
    timeboxID = Timeboxes.insert {
      userID: Meteor.userId(),
      duration: countdown,
      final_duration: 0,
      startTime: new Date(),
      startDate: moment(new Date()).format("MM/DD/YYYY"),
      endTime: undefined,
      complete: "In Progress",
      tags: $("#tagsField").val().split(","),
    }
    timerRunning = true
    Session.set("currentTimeboxID", timeboxID)
    timeboxID

  completeTimebox = () ->
    interruptCounter()
    timerRunning = false
    setTimer_and_countdown(latestTimebox().duration)
    document.title = secondFormat(countdown)
    adjustTags(latestTimebox())
    latestTimebox()._id

  tagNames = () ->
    if Meteor.user()
      tags = Tags.find({userID: Meteor.userId()}).fetch();
      tags = _.pluck(tags, "name")
      $( "#tagsField_tag" ).autocomplete({
        source: tags
      });

  adjustTags = (timebox) ->
    if timebox.tags
      for tag in timebox.tags
        if tag.length > 0
          newTag = Tags.findOne({name: tag, userID: timebox.userID})
          if newTag == undefined
            tagID = Tags.insert({
              name: tag,
              userID: timebox.userID,
              timeSpent: 0,
              timeboxesCompleted: 0,
              active: true,
            })
          else 
            tagID = newTag._id
          if timebox.final_duration
            time = timebox.final_duration
          else
            time = 0
          console.log(tagID)
          Tags.update(tagID, { $inc: {timeSpent: time, timeboxesCompleted: 1}})
          Tags.update(tagID, { $set: {active: true}})
    tagNames()
      
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
        Timeboxes.update(latestTimebox()._id, { $set: {final_duration: latestTimebox().duration - countdown}})
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
      if Meteor.user().emails
        Meteor.user().emails[0].address
    else
      undefined

  Handlebars.registerHelper "secondFormat", (seconds) ->
    return secondFormat(seconds)

  Handlebars.registerHelper "userTimeboxes", () ->
    timeboxLimit = Session.get("timeboxLimit")
    Timeboxes.find({userID: Meteor.userId()}, {sort: {startTime: -1}, limit: timeboxLimit}).fetch()
  
  Handlebars.registerHelper "userDurations", () ->
    timeboxes = Timeboxes.find().fetch();
    distinctArray = _.uniq(timeboxes, false, (d) -> return d.duration);
    distinctValues = _.pluck(distinctArray, 'duration')
    if distinctValues.length 
      return distinctValues
    else
      false

  Handlebars.registerHelper "defaultDurations", () ->
    [300,600,900,1200,1500,1800]

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
    "click": () ->
      tagNames()

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

  root.Template.durationSelect.events
    "click": () ->
      Session.set("settingTimer", undefined)
      setTimer_and_countdown(this)

  root.Template.timeboxData.events
    "click .repeatTimebox": () ->
      $('#tagsField').importTags('')
      if this.tags
        for tag in this.tags
          $("#tagsField").addTag(tag)
      setTimer_and_countdown(this.duration)
      startTimebox()

    "click .deleteTimebox": () ->
      # c = confirm("Are you sure you want to delete this?")
      # if c
      # console.log(this)
      # if this._id == latestTimebox()._id
      interruptCounter()
      timerRunning = false
      setTimer_and_countdown(latestTimebox().duration)
      Timeboxes.remove(this._id)


  root.Template.login.loginError = () ->
    return Session.get("loginError")

  root.Template.tracking.userTags = () ->
    Tags.find({
      userID: Meteor.userId(), 
      timeboxesCompleted: { $gt: 1}, 
      timeSpent: { $gt: 1},
      active: true
    })

  root.Template.tagData.totalTime = () ->
    secondFormat(this.timeSpent) 

  root.Template.timeboxData.create_date = () ->
    timeboxDateStr = moment(this.startTime).format("MM/DD/YYYY")
    todayDate = new Date()
    if timeboxDateStr == moment(todayDate).format("MM/DD/YYYY")
      return "Today"

    return timeboxDateStr

  root.Template.timeboxData.create_time = () ->
    moment(this.startTime).format("h:mm A")
  root.Template.timeboxData.duration = () ->
    secondFormat(this.duration)
  root.Template.timeboxData.final_duration = () ->
    if this.final_duration
      secondFormat(this.final_duration) + " / "


  root.Template.timeboxData.complete = () ->
    if this.duration != this.final_duration
      "Incomplete"
    else
      "Completed"

  root.Template.timeboxData.bgcolor = () ->
    if this.tags.toString()
      tagString = this.tags.toString()
  root.Template.timeboxData.rendered = () ->
    startDate = moment(this.data.startTime).format("MMDDYYYY")
    todayDate = moment(new Date()).format("MMDDYYYY")
    if startDate == todayDate
      alpha = ".25"
    else
      alpha = ".1"
    color = "200, 200, 200, "
    if this.data.tags
      if this.data.tags.toString()
        tagString = this.data.tags.toString()
        tagLetter = tagString.match(/[aeiou]/)[0]
        if tagLetter
          if tagLetter == "a"
            color = "255, 150, 150, "
          if tagLetter == "e"
            color = "150, 255, 150, "
          if tagLetter == "i"
            color = "150, 150, 255, "
          if tagLetter == "o"
            color = "255, 255, 150, "
          if tagLetter == "u"
            color = "255, 150, 255, "

    this.lastNode.setAttribute("style", "background-color:rgba(" + color + alpha + ");")





  

  Template.currentTimebox.rendered = () ->
    countdown = 1500
    document.getElementById("minutesSelect").value = "25"
    Session.set("timeRemaining", secondFormat(countdown))



  Template.timeboxes.events
    "click #clickToShowMore": () ->
      timeboxLimit = Session.get("timeboxLimit")
      Session.set("timeboxLimit", timeboxLimit+100)

  Template.timeboxes.events
    "click #clickToShowFewer": () ->
      timeboxLimit = Session.get("timeboxLimit")
      if timeboxLimit > 100
        Session.set("timeboxLimit", timeboxLimit-100)



  Template.timeboxes.show_showMore = () ->
    timeboxes = Timeboxes.find({userID: Meteor.userId()})
    console.log(timeboxes.count(), Session.get("timeboxLimit"))

    timeboxes.count() > Session.get("timeboxLimit")

  Template.timeboxes.show_showFewer = () ->
    Session.get("timeboxLimit") > 100

  Template.timeboxes.rendered = () ->
    if Meteor.user()
      console.log(latestTimebox())
      $('#tagsField').importTags('')
      for tag in latestTimebox().tags
        $("#tagsField").addTag(tag)



if root.Meteor.isServer
  if exports? then root = exports
  if window? then root = window

  Meteor.publish "Tags", ->
    Employees.find {}





root.Timeboxes = Timeboxes
root.startTimebox = startTimebox
root.completeTimebox = completeTimebox
root.secondFormat = secondFormat
root.timer = timer
root.testReset = testReset




