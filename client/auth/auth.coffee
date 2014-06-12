# https://waaave.com/tutorial/meteor/design-a-complete-authentication-system-with-meteor/

trimInput = (value) ->
  value.replace(/^\s*|\s*$/g, '');

isNotEmpty = (value) ->
  if value && value != ""
    return true
  else 
    Session.set("alert", "Please fill in all required Fields")
    return false

isEmail = (value) ->
  filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
  if filter.test(value)
    true
  else
    Session.set("alert", "Please enter a valid email address.");
    false;

isValidPassword = (password) ->
  if password.length <= 6
    Session.set("alert", "Your password should be at least 6 letters long")
    false
  else
    true

areValidPasswords = (password, passwordConfirm) ->
  if !isValidPassword(password)
    return false
  console.log(password)
  console.log(confirm)
  console.log password == passwordConfirm
  if password != passwordConfirm
    Session.set("alert", "Your passwords do not match")
    return false
  else 
    true


Template.alert.helpers {
  alert: () ->
    Session.get("alert")
}


Session.set("loginWindow", "signingIn")
Template.login.helpers {
  forgottenPassword: () ->
    Session.equals("loginWindow", "forgottenPassword")
  signingIn: () ->
    Session.equals("loginWindow", "signingIn")
  signingUp: () ->
    Session.equals("loginWindow", "signingUp")
}

Template.login.events {
  "click .signIn": () ->
    Session.set("loginWindow", "signingIn")
  "click .forgotPassword": () ->
    Session.set("loginWindow", "forgottenPassword")
  "click .signUp": () ->
    Session.set("loginWindow", "signingUp")
}

Template.signUp.events {
  "submit #signUpForm": (e, t) ->
    e.preventDefault()
    signUpForm = $(e.currentTarget)
    email = trimInput(signUpForm.find('#signUpEmail').val().toLowerCase())
    password = signUpForm.find('#signUpPassword').val()
    passwordConfirm = signUpForm.find('#signUpPasswordConfirm').val()

    if isNotEmpty(email) && isNotEmpty(password) && isEmail(email) && isValidPassword(password) && areValidPasswords(password, passwordConfirm)
      console.log
      Accounts.createUser({email: email, password: password}, (err) ->
        if err
          if err.message == "Email already exists. [403]"
            Session.set("alert", "Sorry! This e-mail is already being used.")
          else
            Session.set("alert", "We're sorry but something went wrong.")
        else 
          Session.set("alert", "Welcome!")
      )
  }

Template.signIn.events {
  "click #signInForm": (e,t) ->
    e.preventDefault()

    signInForm = $(e.currentTarget)
    email = trimInput(signInForm.find(".email").val().toLowerCase())
    password = signInForm.find(".password").val()

    if isNotEmpty(email) && isEmail(email) && isNotEmpty(password)
      Meteor.loginWithPassword(email, password, (err) ->
        if (err)
          Session.set("alert", "Sorry! This email/password combination is invalid.")
        else
          Session.set("alert", undefined)
        )
  "click #showForgotPassword": (e,t) ->
    Session.set("showForgotPassword", true)
}

Template.signOut.events {
  'click #signOut': (e,t) ->
    Meteor.logout () ->
      Session.set("alert", undefined)
}

Template.forgotPassword.events {
  "submit #forgotPassword": (e,t) ->
    e.preventDefault()

    forgotPasswordForm = $(e.currentTarget)
    email = trimInput(forgotPasswordForm.find("#forgotPasswordEmail").val().toLowerCase())

    if isNotEmpty(email) && isEmail(email)
      Accounts.forgotPassword({email:email}, (err) ->
        if (err) 
          if err.message == "User not found [403]"
            Session.set("alert", "This email is not in the system.")
          else
            Session.set("alert", "Sorry! Something went wrong.")
        else
          Session.set("alert", "Email Sent. Please check your mailbox to reset your password")

        )

  "click #returnToSignIn": (e,t) ->
    Session.set("showForgotPassword", undefined)

}
