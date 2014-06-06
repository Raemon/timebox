root = global ? window
#http://requirebin.com/?gist=6031068
Users = new Meteor.Collection("Users");






if root.Meteor.isClient
  countdown = 0

  setInterval () -> 
      timer()
    , 1000

  Handlebars.registerHelper 'timeRemaining', () ->
    Session.get("timeRemaining")

  secondFormat = (seconds) ->
    minutes = parseInt(seconds/60).toString()
    seconds = parseInt(seconds%60).toString()
    minutes + ":" + seconds

  timer = () ->
      countdown -= 1;
      if countdown >= 0
        Session.set("timeRemaining", secondFormat(countdown))
        document.title = secondFormat(countdown)
      if countdown == 0
        audio = new Audio 'cChord.mp3';
        audio.volume = .2
        audio.play();
        # alert("You have left the zone")




  root.Template.timebox.events
    'click .start.sec5': () ->
      countdown = 3
    'click .start.min5': () ->
      countdown = 300
    'click .start.min25': () ->
      countdown = 1500

# if (Meteor.isServer) {
#   Meteor.startup(function () {
#   });
# }

# if root.Meteor.isServer
#   if exports? then root = exports
#   if window? then root = window


