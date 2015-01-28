# createCharacter = (userID) ->
#   console.log "Created Character!!!!!!!!"
#   Characters.insert
#     name: "Nameless Wanderer"
#     userID: userID
#     stats:
#       journeys: 0
#       wood: 0
#       stone: 0
#       iron: 0
#       gold: 0


# currentCharacter = ->
#   Characters.findOne userID: Meteor.userId()

# journeyMessage = (duration) ->
#   message = ""
#   wood = parseInt(Math.random() * duration / 75)
#   stone = parseInt(Math.random() * duration / 100)
#   messageA = "You journey through the woods."
#   messageB = "You return"
#   messageC = ""
#   if wood > 0
#     messageB += " with a bundle of wood"
#     messageC += "+ " + wood + " wood.\n"
#   if stone > 0
#     messageB += " and some nice stones"
#     messageC += "+ " + stone + " stone."
#   messageB += " after a short time, refreshed from the brisk walk and ready for more"  if stone is 0  if wood is 0
#   messageB += "."
#   [
#     messageA
#     messageB
#     messageC
#     wood
#     stone
#   ]

# empire.completeJourney = (duration) ->
#   document.getElementById("empireMessages").style.opacity = 1
#   journey = journeyMessage(duration)
#   Session.set "journeyMessage", [
#     journey[0]
#     journey[1]
#     journey[2]
#   ]
#   character = Characters.findOne(userID: Meteor.userId())
#   Characters.update
#     _id: character._id
#   ,
#     $inc:
#       wood: journey[3]
#       stone: journey[4]
#       journeys: 1

#   console.log journey
#   return

# Template.empireTab.events =
#   "click #activateCharacter": ->
#     createCharacter Meteor.userId()
#     return

  
#   # For when the game updates in a way that removes or adds stats
#   "click #updateCharacter": ->
#     name = currentCharacter().name
#     stats = {}
#     if currentCharacter.stats
#       stats.journeys = currentCharacter().stats.journeys or 0
#       stats.wood = currentCharacter().stats.wood or 0
#       stats.stone = currentCharacter().stats.stone or 0
#       stats.iron = currentCharacter().stats.iron or 0
#       stats.gold = currentCharacter().stats.gold or 0
#     else
#       stats.journeys = currentCharacter().journeys or 0
#       stats.wood = currentCharacter().wood or 0
#       stats.stone = currentCharacter().stone or 0
#       stats.iron = currentCharacter().iron or 0
#       stats.gold = currentCharacter().gold or 0
#     Characters.remove currentCharacter()._id
#     newCharacter = createCharacter(Meteor.userId())
#     Characters.update newCharacter._id,
#       $set:
#         name: name
#         stats: stats

#     console.log currentCharacter()
#     return

# Template.characterSheet.events =
#   "click #characterName": ->
#     document.getElementById("characterName").contentEditable = true
#     return

#   "keydown #characterName": (evt) ->
#     if evt.keyCode is 13
#       document.getElementById("characterName").contentEditable = false
#       characterName = document.getElementById("characterName").innerHTML.trim()
#       Characters.update currentCharacter()._id,
#         $set:
#           name: characterName

#     return

#   "blur #characterName": ->
#     document.getElementById("characterName").contentEditable = false
#     characterName = document.getElementById("characterName").innerHTML.trim()
#     Characters.update currentCharacter()._id,
#       $set:
#         name: characterName

#     return

# Template.empireTab.empireActivated = ->
#   Characters.findOne userID: Meteor.userId()

# Template.empireTab.empireUpToDate = ->
#   if Characters.findOne(userID: Meteor.userId()).stats.iron?
#     true
#   else
#     false

# Template.characterSheet.character = ->
#   Characters.findOne userID: Meteor.userId()

# Template.characterSheet.stats = ->
#   Characters.findOne(userID: Meteor.userId()).stats