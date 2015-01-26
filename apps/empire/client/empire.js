


createCharacter = function (userID) {
	console.log ("Created Character!!!!!!!!")
	return Characters.insert({
		name: "Nameless Wanderer",
		userID: userID,
		wood: 0,
		stone: 0,
		})
}

journeyMessage = function (duration) {
	message = ""
	wood = parseInt(Math.random()*duration/50)
	stone = parseInt(Math.random()*duration/100)
	messageA = "You journey through the woods, looking for supplies."
	messageB = "You return"
	messageC = ""
	if (wood > 0) {
		messageB += " with a bundle of wood"
		messageC += "+ " + wood + " wood.\n"
	}
	if (stone > 0) {
		messageB += " and some nice stones"
		messageC += "+ " + stone + " stone."
	}
	if (wood == 0) {
		if (stone == 0) {
			messageC += "empty handed, but refreshed from the brisk walk, ready for more."
		}
	}
	messageB += "."

	return [messageA, messageB, messageC, wood, stone]

}


completeJourney = function (duration) {
	document.getElementById("empireMessages").style.opacity = 1
	journey = journeyMessage(duration)
	Session.set("journeyMessage", [journey[0], journey[1], journey[2]])
	character = Characters.findOne({userID: Meteor.userId()})
	Characters.update({_id: character._id}, { $inc: {wood: journey[3], stone: journey[4]}})
    console.log(journey)
}

Template.characterSheet.characterName = function () {
	character = Characters.findOne({userID: Meteor.userId()})

	if (character==undefined) {
		character = createCharacter(Meteor.userId())
		return character.name
	} else {
		return character.name
	}
}

Template.characterSheet.wood = function () {
	character = Characters.findOne({userID: Meteor.userId()})
	return character.wood
}

Template.characterSheet.stone = function () {
	character = Characters.findOne({userID: Meteor.userId()})
	return character.stone
}

Template.empireMessages.messages = function () {
	return Session.get("journeyMessage")
}

