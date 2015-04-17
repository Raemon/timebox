emptyGrid = function () {
	return [
	[{row: 0, col: 0, material: 0}, 
	 {row: 0, col: 1, material: 0},
	 {row: 0, col: 2, material: 0},
	 {row: 0, col: 3, material: 0},
	 {row: 0, col: 4, material: 0},
	 ],
	[{row: 1, col: 0, material: 0}, 
	 {row: 1, col: 1, material: 0},
	 {row: 1, col: 2, material: 0},
	 {row: 1, col: 3, material: 0},
	 {row: 1, col: 4, material: 0},
	 ],
	[{row: 2, col: 0, material: 0}, 
	 {row: 2, col: 1, material: 0},
	 {row: 2, col: 2, material: 0},
	 {row: 2, col: 3, material: 0},
	 {row: 2, col: 4, material: 0},
	 ],
	[{row: 3, col: 0, material: 0}, 
	 {row: 3, col: 1, material: 0},
	 {row: 3, col: 2, material: 0},
	 {row: 3, col: 3, material: 0},
	 {row: 3, col: 4, material: 0},
	 ],
	[{row: 4, col: 0, material: 0}, 
	 {row: 4, col: 1, material: 0},
	 {row: 4, col: 2, material: 0},
	 {row: 4, col: 3, material: 0},
	 {row: 4, col: 4, material: 0},
	 ]]
}

Session.set("craftGrid", emptyGrid())
Session.set("woodCost", 0)
Session.set("stoneCost", 0)

checkComponents = function (components) {
	// Components should be an array of objects formatted:
	// [{row: x, col: y, material:name}]
	craftGrid = Session.get("craftGrid")
	compareGrid = emptyGrid()
	for (var i=0; i<components.length; i++) {
		compareGrid[components[i].row][components[i].col].material = components[i].material
	}
	return JSON.stringify(compareGrid) == JSON.stringify(craftGrid)
}

costUp = function (cost) {
	if (cost < 25) {
		return cost + 5
	} else if (cost >= 25 && cost < 75) {
		return cost + 10
	} else if (cost >= 75 && cost < 200) {
		return cost + 25
	} else if (cost >= 200) {
		return cost + 100
	}
}

costDown = function (cost) {
	if (cost <= 25) {
		return cost -5
	} else if (cost > 25 && cost <= 75) {
		return cost - 10
	} else if (cost > 75 && cost <= 200) {
		return cost - 25
	} else if (cost > 200) {
		return cost - 100
	}
}

buildingHut = function () {
	return checkComponents([
			{row: 4, col:1, material:"wood"},
			{row: 4, col:3, material:"wood"},
			{row: 3, col:1, material:"wood"},
			{row: 3, col:3, material:"wood"},
			{row: 2, col:2, material:"wood"},
		])
}

buildingLodge = function () {
	return checkComponents([
			{row: 4, col:0, material:"wood"},
			{row: 4, col:1, material:"wood"},
			{row: 4, col:3, material:"wood"},
			{row: 4, col:4, material:"wood"},
			{row: 3, col:1, material:"wood"},
			{row: 3, col:2, material:"wood"},
			{row: 3, col:3, material:"wood"},
			{row: 2, col:2, material:"wood"},
		])
}
buildingLumbermill = function () {
	return checkComponents([
			{row: 4, col:0, material:"wood"},
			{row: 4, col:1, material:"wood"},
			{row: 4, col:3, material:"wood"},
			{row: 4, col:4, material:"wood"},
			{row: 3, col:0, material:"wood"},
			{row: 3, col:1, material:"wood"},
			{row: 3, col:2, material:"wood"},
			{row: 3, col:3, material:"wood"},
			{row: 3, col:4, material:"wood"},
			{row: 2, col:1, material:"wood"},
			{row: 2, col:2, material:"wood"},
			{row: 2, col:3, material:"wood"},
		])
}

buildingTemple = function () {
	return checkComponents([
			{row: 4, col:0, material:"stone"},
			{row: 4, col:1, material:"stone"},
			{row: 4, col:2, material:"wood"},
			{row: 4, col:3, material:"stone"},
			{row: 4, col:4, material:"stone"},
			{row: 3, col:1, material:"stone"},
			{row: 3, col:2, material:"stone"},
			{row: 3, col:3, material:"stone"},
			{row: 2, col:2, material:"stone"},
			{row: 1, col:1, material:"stone"},
			{row: 1, col:2, material:"stone"},
			{row: 1, col:3, material:"stone"},
			{row: 0, col:2, material:"stone"},
		])
}



Template.componentSelection.helpers({
	enoughWood: function (wood) {
		if (currentCharacter().stats.wood > wood) {
			return "enough"
		} else {
			return "notEnough"
		}
	},
	selected: function () {
		return Session.get("componentSelect")
	}
})


Template.crafting.events({
	'click .woodSelect': function () {
		Session.set("componentSelect", "wood")
		// console.log(Session.get("componentSelect"))
	},
	'click .stoneSelect': function () {
		Session.set("componentSelect", "stone")
		// console.log(Session.get("componentSelect"))
	},
	'click .buildButton': function () {
		if (Session.get("buildReady")) {
			updateStats("wood", Session.get("woodCost"))
			updateStats("stone", Session.get("stoneCost"))
			updateStats(Session.get("buildReady"), 1)
		}
	},
	'click .craftslot': function (evt) {
		// BUG: if you change the material type, it doesn't remove the cost of that material
		craftGrid = Session.get("craftGrid")
		if (craftGrid[this.row][this.col].material == Session.get("componentSelect")) {
			craftGrid[this.row][this.col] = {row: this.row, col: this.col, material: 0}
			componentCost = Session.get(component + "Cost")
			Session.set(component + "Cost", costDown(componentCost))
		} else {
			if (craftGrid[this.row][this.col].material != 0) {
				// console.log(craftGrid[this.row][this.col].material + "Cost")
				componentCost = Session.get(craftGrid[this.row][this.col].material + "Cost")
				Session.set(craftGrid[this.row][this.col].material + "Cost", costDown(componentCost))
			}
			component = Session.get("componentSelect")
			componentCost = Session.get(component + "Cost")
			craftGrid[this.row][this.col] = {row: this.row, col: this.col, material: Session.get("componentSelect")}
			Session.set(component + "Cost", costUp(componentCost))
		}

		Session.set("craftGrid", craftGrid)
	},
	'dblclick .craftslot': function (evt) {
		Session.set("craftGrid", emptyGrid())
		Session.set("woodCost", 0)
		Session.set("stoneCost", 0)
	}
})

Template.crafting.helpers({
	building: function() {
		if (buildingHut()) {
			Session.set("buildReady", "Hut")
			return "Hut"
		}
		if (buildingTemple()) {
			Session.set("buildReady", "Temple")
			return "Temple"
		}
		if (buildingLodge()) {
			Session.set("buildReady", "Lodge")
			return "Lodge"
		}
		if (buildingLumbermill()) {
			Session.set("buildReady", "Lumbermill")
			return "Lumbermill"
		}
		return Session.set("buildReady", undefined)
	},
	woodCost: function() {
		return "Wood: " + Session.get("woodCost")
	},
	stoneCost: function() {
		return "Stone: " + Session.get("stoneCost")
	},
	buildReady: function() {
		if (Session.get("buildReady") &&
			Session.get("woodCost")<=currentCharacter().stats.wood &&
			Session.get("stoneCost")<=currentCharacter().stats.stone) {
			return "ready"
		} else {
			return "notEnough"
		}

	},
	craftGrid: function () {
		return Session.get("craftGrid")
	}
})
