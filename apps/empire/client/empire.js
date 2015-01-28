createCharacter = function (userID) {
	console.log ("Created Character!!!!!!!!")
	return Characters.insert({
		name: "Nameless Wanderer",
		userID: userID,
		stats: {
				journeys: 0,
				wood: 0,
				stone: 0,
				iron: 0,
				gold: 0,
			}
		})
}

updateCharacter = function () {
	name = currentCharacter().name
	stats = {}
	if (currentCharacter().stats) {
		stats.journeys = currentCharacter().stats.journeys || 0
		stats.wood = currentCharacter().stats.wood || 0
		stats.stone = currentCharacter().stats.stone || 0
		stats.iron = currentCharacter().stats.iron || 0
		stats.gold = currentCharacter().stats.gold || 0

		stats.villagers = currentCharacter().stats.villagers || 0

		stats.huts = currentCharacter().stats.huts || 0
	} else {
		stats.journeys = currentCharacter().journeys || 0
		stats.wood = currentCharacter().wood || 0
		stats.stone = currentCharacter().stone || 0
		stats.iron = currentCharacter().iron || 0
		stats.gold = currentCharacter().gold || 0

		stats.villagers = currentCharacter().villagers || 0

		stats.huts = currentCharacter().huts || 0
	}
	console.log(stats)
	// Characters.remove(currentCharacter()._id)
	// newCharacter = createCharacter(Meteor.userId())
	Characters.update(currentCharacter()._id, {$set: {name: name, stats: stats}})
	console.log(currentCharacter().stats)
}

updateStats = function (stat, amount) {
	console.log(currentCharacter().stats)
	stats = currentCharacter().stats
	if (stats[stat] == undefined) {
		stats[stat] = 0
	}
	stats[stat] = stats[stat] + amount
	Characters.update(currentCharacter()._id, {$set: {stats: stats}})
	console.log(currentCharacter().stats)
}

currentCharacter = function () {
	return Characters.findOne({userID: Meteor.userId()})
}

journeyMessage = function (duration) {
	message = ""
	if (duration == 1) {
		duration = 1500
	}
	wood = parseInt(Math.random()*duration/75)
	stone = parseInt(Math.random()*duration/150)
	messageA = "You journey through the woods."
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
			messageB += " after a short time, refreshed from the brisk walk and ready for more"
		}
	}
	messageB += "."

	return [messageA, messageB, messageC, wood, stone]

}


completeJourney = function (duration) {
	journey = journeyMessage(duration)
	Session.set("journeyMessage", [journey[0], journey[1], journey[2]])
	document.getElementById("empireMessages").style.opacity = 1
	character = currentCharacter()
	console.log(character.stats)

	updateStats("journeys", 1)
	updateStats("wood", journey[3])
	updateStats("stone", journey[4])

	console.log(currentCharacter().stats)
}

Template.empireTab.events = {
	'click #activateCharacter': function () {
		createCharacter(Meteor.userId())
	},
	// For when the game updates in a way that removes or adds stats
	'click #updateCharacter': function () {
		updateCharacter()
	},
}

Template.characterSheet.events = {
	'click #characterName': function () {
		document.getElementById('characterName').contentEditable = true
	},
	'keydown #characterName': function (evt) {
		if (evt.keyCode == 13) {
			document.getElementById('characterName').contentEditable = false
			characterName = document.getElementById('characterName').innerHTML.trim()
			Characters.update(currentCharacter()._id, {$set: {name: characterName}})
		}
	},
	'blur #characterName': function () {
		document.getElementById('characterName').contentEditable = false
		characterName = document.getElementById('characterName').innerHTML.trim()
		Characters.update(currentCharacter()._id, {$set: {name: characterName}})
	}
}

Template.empireTab.empireActivated = function () {
	return Characters.findOne({userID: Meteor.userId()})
}

Template.empireTab.empireUpToDate = function () {
	if (Characters.findOne({userID: Meteor.userId()}).stats.iron != undefined) {
		return true
	} else {
		return false
	}
}

Template.characterSheet.character = function () {
	return Characters.findOne({userID: Meteor.userId()})
}

Template.characterSheet.stats = function () {
	return Characters.findOne({userID: Meteor.userId()}).stats
}

Template.empireMessages.messages = function () {
	return Session.get("journeyMessage")
}

Template.buildings.helpers({
	enoughWood: function (wood) {
		if (currentCharacter().stats.wood > wood) {
			return "enough"
		} else {
			return "notEnough"
		}
	}
})	

Template.buildings.events({
	'click .buildHut': function () {
		if (currentCharacter().stats.wood >= 30) {
			updateStats("wood", -30)
			updateStats("huts", 1)
		}
	}
})