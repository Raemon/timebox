'''
Todos

Create Readme for Github
test if clicking start creates the right timer
Begin a break timer after a work timer

Toggleable Alert-at-end-of-timebox

Done:

  Basic Tracking
    How many timers in a row you've done today

    total time spent todayday

    create dropdown menu for recently used timer-settings
    Begin with tags from currentTimebox
    total time spend on a tag
    total timeboxes done on a tag
    Create tab-structure


'''

root = global ? window
Timeboxes = new Meteor.Collection("Timeboxes");
Tags = new Meteor.Collection("Tags")

#Empire Collections
Characters = new Meteor.Collection("Characters")


if root.Meteor.isClient

  countdown = 1500
  previous_countdownTime = 0
  new_countdownTime = 0
  Session.set("currentUserID", undefined)
  Session.set("timeboxLimit", 8)
  Session.set("trackingTimeframe", "Today")
  timerRunning = false

  fixThings = () ->
    for timebox in Timeboxes.find().fetch()
      if timebox.duration && timebox.final_duration
        if timebox.duration == timebox.final_duration
          Timeboxes.update(timebox._id, { $set: {complete: "Completed"}})
        else
          Timeboxes.update(timebox._id, { $set: {complete: "Partial"}})
      else
        Timeboxes.update(timebox._id, { $set: {complete: "Completed"}})
      updateTags(timebox)

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

  currentTimebox = () ->
    if Session.get("currentTimeboxID")
      return Timeboxes.findOne(Session.get("currentTimeboxID"))
    else
      return undefined

  interruptCounter = () ->
    if currentTimebox()
      if countdown != 0
        complete = "Partial"
      else
        complete = "Completed"
      Timeboxes.update currentTimebox()._id, 
          {$set: 
            {
              complete: complete,
            }
          }

  startTimebox = () ->
    interruptCounter()
    document.getElementById("empireMessages").style.opacity = 0
    setCountdown_fromTimer()
    Session.set("timeRemaining", secondFormat(countdown))
    # if Users.findOne(Session.get("currentUserID")) == undefined
    #   createUser('TemporaryUser')
    timeboxID = Timeboxes.insert {
      userID: Meteor.userId(),
      duration: countdown,
      final_duration: 0,
      startTime: new Date(),
      endTime: undefined,
      complete: "In Progress",
      tags: $("#tagsField").val().split(","),
    }
    timerRunning = true
    Session.set("currentTimeboxID", timeboxID)
    timeboxID




  completeTimebox = () ->
    timebox = currentTimebox()
    interruptCounter()
    timerRunning = false
    setTimer_and_countdown(timebox.duration)
    updateTags(timebox)
    document.title = secondFormat(countdown)
    tags = $("#tagsField").val().split(",")
    Timeboxes.update timebox._id, 
        {$set: 
          {
            tags: tags
          }
        }
    completeJourney(timebox.duration)
    Session.set("currentTimeboxID", undefined)
    timebox._id

  tagNames = () ->
    if Meteor.user()
      tags = Tags.find({userID: Meteor.userId()}).fetch();
      tags = _.pluck(tags, "name")
      $( "#tagsField_tag" ).autocomplete({
        source: tags
      });

  updateTags = (timebox) ->
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
          Tags.update(tagID, { $inc: {timeSpent: time, timeboxesCompleted: 1}})
          Tags.update(tagID, { $set: {active: true}})
    tagNames()

  trackingStartDate = (string) ->
    date = new Date().setHours(0,0,0,0)
    if string == "Today"
      return [date, new Date()]
    if string == "Yesterday"
      return  [date - 1000*60*60*24*1, date]
    if string == "7 Days"
      return [date - 1000*60*60*24*7, new Date()]
    if string == "30 Days"
      return [date - 1000*60*60*24*30, new Date()]
    if string == "One Year"
      return [date - 1000*60*60*24*365, new Date()]

  updateTagTracking = () ->
    dates = trackingStartDate(Session.get("trackingTimeframe"))
    timeboxes = Timeboxes.find({userID: Meteor.userId()}, { sort: {startTime: -1}}).fetch()
    timeboxes = _.filter(timeboxes, (timebox) -> timebox.startTime > dates[0])
    timeboxes = _.filter(timeboxes, (timebox) -> timebox.startTime < dates[1])
    tagStrings = {}
    for timebox in timeboxes
      if !tagStrings[timebox.tags.sort().toString()]
        tagStrings[timebox.tags.sort().toString()] = {}
        tagStrings[timebox.tags.sort().toString()]['tags'] = timebox.tags.toString()
        tagStrings[timebox.tags.sort().toString()]['timeSpent'] = 0
        tagStrings[timebox.tags.sort().toString()]['timeboxesCompleted'] = 0
      tagStrings[timebox.tags.toString()]['timeSpent'] += timebox.final_duration
      if timebox.duration == timebox.final_duration
        tagStrings[timebox.tags.sort().toString()]['timeboxesCompleted'] += 1
    Session.set("tagTracking", _.toArray(tagStrings))
      
  testReset = (timeboxID) ->
    Timeboxes.remove(timeboxID)
    countdown = 0
    timerRunning = false
    Session.set("timeRemaining", secondFormat(countdown))

  timer = () ->
    if timerRunning
      # to prevent small variations in the elapsed time, measures the current Date against the last 
      # countdown's Date(). This should usually about 1 second
      new_countdownTime = new Date()
      countdown -= (new_countdownTime - previous_countdownTime)/1000
      console.log((new_countdownTime - previous_countdownTime)/1000)
      console.log countdown
      previous_countdownTime = new_countdownTime
      # countdown -= 1;
      if countdown >= 0
        Session.set("timeRemaining", secondFormat(countdown))
        document.title = secondFormat(countdown)
        Timeboxes.update(currentTimebox()._id, { $set: {final_duration: currentTimebox().duration - countdown}})
        updateTagTracking()
      if countdown < 0
        completeTimebox(Session.get("currentTimeboxID")) 
        # if Meteor.user().emails[0].address == "raemon777@gmail.com"
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
    timeboxes = Timeboxes.find({userID: Meteor.userId()}).fetch();
    distinctArray = _.uniq(timeboxes, false, (d) -> return d.duration);
    distinctValues = _.pluck(distinctArray, 'duration')
    if distinctValues.length 
      return distinctValues
    else
      false

  Handlebars.registerHelper "defaultDurations", () ->
    [30, 60, 300,600,900,1200,1500,1800, 3]

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

  timerUneditable = () ->
    document.getElementById("secondsTimer").contentEditable = false
    document.getElementById("minutesTimer").contentEditable = false



  setCountdown_fromTimer = ()->
    countdown = 0
    countdown += parseInt(document.getElementById("minutesSelect").value) * 60
    countdown += parseInt(document.getElementById("secondsSelect").value)
    previous_countdownTime = new Date()
    Session.set("timeRemaining", secondFormat(countdown))

  setTimer_and_countdown = (seconds) ->
    document.getElementById("minutesSelect").value = parseInt(seconds/60).toString()
    document.getElementById("secondsSelect").value = parseInt(seconds%60).toString()
    countdown = seconds
    previous_countdownTime = new Date()
    Session.set("timeRemaining", secondFormat(countdown))

  root.Template.timeboxData.current = ->
    if currentTimebox()
      if this._id == currentTimebox()._id
        return "current"
      else
        return undefined

  root.Template.timeboxData.events
    "click .repeatTimebox": () ->
      $('#tagsField').importTags('')
      if this.tags
        for tag in this.tags
          $("#tagsField").addTag(tag)
      else
        $("#tagsField").addTag("uncategorized")
      setTimer_and_countdown(this.duration)
      startTimebox()

    "click .deleteTimebox": () ->
      Timeboxes.remove(this._id)

    "click .addTag": ()->
      Session.set("addingTag" + this._id, "addingTag")
      $("#addTag" + this._id).focus()

    "click .deleteTag": (e) ->
      timeboxID = e.target.parentElement.parentElement.id
      tag = e.target.parentElement.innerHTML.trim().split(" ")[0]
      Timeboxes.update(timeboxID, { $pull: { tags: tag}})
      if currentTimebox()
        if currentTimebox()._id == timeboxID
          $("#tagsField").removeTag(tag)

    "keydown .addTagField": (e)->
      if e.which == 13
        if e.target.value.trim() != ""
          Timeboxes.update(this._id, { $addToSet: { tags: e.target.value}})
          if currentTimebox()
            if currentTimebox()._id == this._id
              $("#tagsField").addTag(e.target.value.trim())
        e.target.value = ""
        Session.set("addingTag" + this._id, undefined)

    "focusout .addTagField": (e)->
      Session.set("addingTag" + this._id, undefined)
      e.target.value = ""

  root.Template.login.loginError = () ->
    return Session.get("loginError")

  root.Template.tracking.events
    "click .timeframe": (e) ->
      Session.set("trackingTimeframe", e.target.innerHTML)
      updateTagTracking()

  root.Template.tracking.trackingTimeframe = () ->
    Session.get("trackingTimeframe")


  root.Template.tracking.timeframeTags = () ->
    Session.get("tagTracking")


  root.Template.tracking.userTags = () ->
    Tags.find({
      userID: Meteor.userId(), 
      timeboxesCompleted: { $gt: 1}, 
      timeSpent: { $gt: 1},
      active: true
    })


  root.Template.tracking.totalTime = () ->
    today = new Date().setHours(0,0,0,0)
    timeboxes = Timeboxes.find({userID: Meteor.userId()}).fetch()
    timeboxes = _.filter(timeboxes, (timebox) -> timebox.startTime > today)
    totalTime = 0
    timeboxes.forEach((timebox, index, array) -> totalTime += timebox.final_duration)
    secondFormat(totalTime)


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
  root.Template.timeboxData.addingTag = () ->
    Session.get("addingTag" + this._id)

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
        if tagString.match(/[aeiou]/)
          tagLetter = tagString.match(/[aeiou]/)[0]
          if tagLetter == "a"
            color = "255, 150, 150, "
          if tagLetter == "e"
            color = "150, 200, 150, "
          if tagLetter == "i"
            color = "255, 200, 150, "
          if tagLetter == "o"
            color = "150, 150, 255, "
          if tagLetter == "u"
            color = "255, 150, 255, "

    this.lastNode.setAttribute("style", "background-color:rgba(" + color + alpha + ");")

  Template.bigTimer.rendered = () ->
      countdown = 1500
      document.getElementById("minutesSelect").value = "25"
      Session.set("timeRemaining", secondFormat(countdown))
      $("#tagsField").tagsInput 
        onChange: (tag) ->
          if currentTimebox()
            Timeboxes.update(currentTimebox()._id, { $set: { tags: $("#tagsField").val().split(",")}})
      console.log("asdf")

  root.Template.bigTimer.editing = () ->
      return Session.get("timerEditing")

  root.Template.bigTimer.events
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

  Template.logTimeboxes.events
    "click #clickToShowMore": () ->
      timeboxLimit = Session.get("timeboxLimit")
      Session.set("timeboxLimit", timeboxLimit+100)

    "click #clickToShowFewer": () ->
      timeboxLimit = Session.get("timeboxLimit")
      if timeboxLimit > 100
        Session.set("timeboxLimit", timeboxLimit-100)





  Template.logTimeboxes.show_showMore = () ->
    timeboxes = Timeboxes.find({userID: Meteor.userId()})

    timeboxes.count() > Session.get("timeboxLimit")

  Template.logTimeboxes.show_showFewer = () ->
    Session.get("timeboxLimit") > 100

  Template.logTimeboxes.rendered = () ->
    if Meteor.user()
      $('#tagsField').importTags('')
      if currentTimebox()
        for tag in currentTimebox().tags
          $("#tagsField").addTag(tag)
      else
        $("#tagsField").addTag('uncategorized')
      if Meteor.user().emails[0].address == "raemon777@gmail.com"
        console.log(Meteor.users.find().fetch())

  Template.tracking.rendered = () ->
    updateTagTracking()



if root.Meteor.isServer
  if exports? then root = exports
  if window? then root = window



  Meteor.publish "Tags", ->
    Employees.find {}




root.currentTimebox = currentTimebox
root.Timeboxes = Timeboxes
root.Characters = Characters
root.startTimebox = startTimebox
root.completeTimebox = completeTimebox
root.secondFormat = secondFormat
root.setTimer_and_countdown = setTimer_and_countdown
root.timer = timer
root.testReset = testReset

console.log(root)




