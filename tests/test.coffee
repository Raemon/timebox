describe "Collections", ->
  describe "Timeboxes", ->
    describe "On startTimebox", ->
      it "has duration", ->
        timeboxID = startTimebox 5*60
        timebox = Timeboxes.findOne(timeboxID)
        chai.assert.equal timebox.duration, 5*60
        Timeboxes.remove(timeboxID)
      it "has startTime", ->
        date = new Date()
        timeboxID = startTimebox 5*60
        timebox = Timeboxes.findOne(timeboxID)
        chai.assert.equal timebox.startTime.getSeconds, date.getSeconds
        Timeboxes.remove(timeboxID)
      it "timebox is incomplete", ->
        timeboxID = startTimebox 5*60
        timebox = Timeboxes.findOne(timeboxID)
        chai.assert.equal timebox.complete, false
        Timeboxes.remove(timeboxID)
      it "can read currentTimebox", ->
        timeboxID = startTimebox 5*60
        currentTimeboxID = Session.get("currentTimeboxID")
        chai.assert.equal timeboxID, currentTimeboxID
        Timeboxes.remove(timeboxID)

    describe "On completeTimebox", ->
      it 'assigns the current user or creates a new one', ->
        userID = Session.get("currentUserID")
        if userID == undefined
          userID = createUser("temporary")
        startTimebox 5*60
        timeboxID = completeTimebox()
        timebox = Timeboxes.findOne(timeboxID)
        chai.assert.equal timebox.userID, Session.get("currentUserID")
        Timeboxes.remove(timeboxID)

      it "reads tags", ->
        startTimebox 5*60
        $('#tagsField').addTag('foo')
        $('#tagsField').addTag('bar')
        $('#tagsField').addTag('bazz')
        timeboxID = completeTimebox()
        timebox = Timeboxes.findOne(timeboxID)
        chai.expect(timebox.tags).to.deep.equal ['foo', 'bar', 'bazz']
        $('#tagsField').removeTag('foo')
        $('#tagsField').removeTag('bar')
        $('#tagsField').removeTag('bazz')
        Timeboxes.remove(timeboxID)


  describe "Users", ->
    describe "on createUser", ->
      it "o", ->
        userID = Users.insert({username: 'foo'})
        user = Users.findOne(userID)
        chai.assert.equal user.username, 'foo'

describe "UI", ->
  describe "Elements", ->
    it "tagsField should exist", ->
      tagsField = document.getElementById('tagsField')
      console.log(tagsField)
      chai.expect(tagsField).to.be.ok
