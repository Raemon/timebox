describe "TestingStartCondition", ->
  describe "Collections", ->
    it "has X timeboxes", ->
      timeboxCount = Timeboxes.find().count()
      console.log("Timebox Count: ", timeboxCount)

describe "Collections", ->
  describe "Timeboxes", ->
    describe "On startTimebox", ->
      it "has duration", ->
        setTimer_and_countdown 5*60
        timeboxID = startTimebox()
        timebox = Timeboxes.findOne(timeboxID)
        chai.assert.equal timebox.duration, 5*60
        testReset(timeboxID)
      it "has startTime", ->
        date = new Date()
        timeboxID = startTimebox()
        timebox = Timeboxes.findOne(timeboxID)
        chai.assert.equal timebox.startTime.getSeconds, date.getSeconds
        testReset(timeboxID)
      it "timebox is incomplete", ->
        timeboxID = startTimebox()
        timebox = Timeboxes.findOne(timeboxID)
        chai.assert.equal timebox.complete, "In Progress"
        testReset(timeboxID)
      it "can read currentTimebox()", ->
        timeboxID = startTimebox()
        currentTimeboxID = currentTimebox()._id
        chai.assert.equal timeboxID, currentTimeboxID
        testReset(timeboxID)
      it "appears in Timebox Log", ->
        setTimer_and_countdown 5*60*9
        timeboxID = startTimebox()
        div = document.createElement("div")
        UI.insert(UI.render(Template.logTimeboxes), div)
        document.body.insertBefore(div, document.body.childNodes[0])
        doc = document.getElementById("timeboxData" + timeboxID)
        chai.expect(doc).to.be.ok
        div.parentNode.removeChild(div)
        testReset(timeboxID)
      it "assigns the current user", ->
        timeboxID = startTimebox 5*60
        timebox = Timeboxes.findOne(timeboxID)
        chai.assert.equal timebox.userID, Meteor.userId()
        chai.expect(timebox.userID).to.be.ok
        chai.expect(Meteor.userId()).to.be.ok
        testReset(timeboxID)


#     describe "On completeTimebox", ->

#       it "reads tags", ->
#         startTimebox 5*60
#         $("#tagsField").addTag("foo")
#         $("#tagsField").addTag("bar")
#         $("#tagsField").addTag("bazz")
#         timeboxID = completeTimebox()
#         timebox = Timeboxes.findOne(timeboxID)
#         chai.expect(timebox.tags).to.deep.equal ["uncategorized", "foo", "bar", "bazz"]
#         $("#tagsField").removeTag("foo")
#         $("#tagsField").removeTag("bar")
#         $("#tagsField").removeTag("bazz")
#         testReset(timeboxID)




#   describe "Users", ->
#     describe "on createUser", ->
#       it "if username is 'TemporaryUser', create a TempUser", ->
#         userID = createUser('TemporaryUser')
#         user = Users.findOne(userID)
#         chai.expect(user.temp).to.equal true
#         chai.expect(user.username).to.contain('TemporaryUser')
#         Users.remove(userID)

#       it "if username exists already, give error", ->
#         userID = createUser('test')
#         userID2 = createUser('test')
#         chai.expect(userID2).to.equal undefined
#         chai.expect(Session.get('loginError')).to.equal 'This username is taken'
#         Users.remove(userID)
#         Users.remove(userID2)
#         Session.set("loginError", undefined)
#     describe "on login", ->
#       it "sets currentUserID to the _id matching the username you entered", ->
#         username = document.getElementById("loginField").innerHTML
#         userID = login(username)
#         chai.expect(userID).to.equal Session.get("currentUserID")


# describe "UI", ->
#   describe "Elements", ->
#     it "tagsField should exist", ->
#       tagsField = document.getElementById("tagsField")
#       chai.expect(tagsField).to.be.ok
      
#     it "username should be displayed", ->
#       username = document.getElementById("username")
#       currentUser = Users.findOne(Session.get("currentUserID"))
#       chai.expect(username).to.be.ok
#       chai.assert.equal username.innerHTML, currentUser.username

#     it "timer exists", ->
#       timer = document.getElementById("timer")

# describe "TestingEndConditions", ->
#   describe "Collections", ->
#     it "has X timeboxes", ->
#       chai.assert.equal Timeboxes.find().count() == timeboxCount

