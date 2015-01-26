empire = {}

createCharacter = (userID) ->
	console.log ("Created Character!!!!!!!!")
	return Characters.insert({
		name: "Nameless Wanderer",
		userID: userID,
		wood: 0,
		stone: 0,
		})

empire.messages = () ->
	"You "



empire.completeJourney = (duration) -> 
	if duration > 1500
		Session.set("empireMessage", empire.messages())
		console.log("You return from the forest after " + duration + " seconds")


Template.characterSheet.characterName = () ->
	character = Characters.findOne({userID: Meteor.userId()})

	if character==undefined
		character = createCharacter(Meteor.userId())
		return character.name
	else
		return character.name