

function myStopFunction() {
    clearInterval(myVar);
}



if (Meteor.isClient) {
  var countdown = 0;

  var myVar = setInterval(function(){timer()}, 1000);

  Handlebars.registerHelper('timeRemaining',function(){
    return Session.get("timeRemaining")
  });

  var timer = function () {
      countdown -= 1;
      if (countdown >= 0) {
        Session.set("timeRemaining", countdown)
      }
  }


  Template.timebox.events({
    'click .start.5min': function () {
      // template data, if any, is available in 'this'
      countdown = 5
    }
  });
}

if (Meteor.isServer) {
  Meteor.startup(function () {
    // code to run on server at startup
  });
}
