

function myStopFunction() {
    clearInterval(myVar);
}



if (Meteor.isClient) {
  var countdown = 0;

  var myVar = setInterval(function(){timer()}, 1000);

  Handlebars.registerHelper('timeRemaining',function(){
    return Session.get("timeRemaining")
  });

  var secondFormat = function (seconds) {
    minutes = parseInt(seconds/60).toString()
    seconds = parseInt(seconds%60).toString()
    return minutes + ":" + seconds
  }

  var timer = function () {
      countdown -= 1;
      if (countdown >= 0) {
        Session.set("timeRemaining", secondFormat(countdown))
        document.title = secondFormat(countdown)
      }
      if (countdown == 0) {
        alert("You have left the zone")
      }

  }


  Template.timebox.events({
    'click .start5min': function () {
      // template data, if any, is available in 'this'
      countdown = 300
    },
    'click .start25min': function () {
      // template data, if any, is available in 'this'
      countdown = 1500
    }
  });
}

if (Meteor.isServer) {
  Meteor.startup(function () {
    // code to run on server at startup
  });
}


