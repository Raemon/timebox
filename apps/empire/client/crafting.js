emptyGrid = [
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
	 ],
]

Session.set("craftGrid", emptyGrid)
Session.set("woodCost", 0)
Session.set("stoneCost", 0)

checkComponents = function (components) {
	// Components should be an array of objects formatted:
	// [{row: x, col: y, material:name}]
	craftGrid = Session.get("craftGrid")
	compareGrid = emptyGrid
	for (var i=0; i<components.length; i++) {
		compareGrid[components[i].row][components[i].col].material = components[i].material
	}
	return JSON.stringify(compareGrid) == JSON.stringify(craftGrid)
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

buildingHut = function () {
	return checkComponents([
			{row: 4, col:1, material:"wood"},
			{row: 4, col:3, material:"wood"},
			{row: 3, col:1, material:"wood"},
			{row: 3, col:3, material:"wood"},
			{row: 2, col:2, material:"wood"},
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
		console.log(Session.get("componentSelect"))
	},
	'click .stoneSelect': function () {
		Session.set("componentSelect", "stone")
		console.log(Session.get("componentSelect"))
	},
	'click .buildButton': function () {
		if (Session.get("buildReady") == "Hut") {
			console.log("Build Hut")
			console.log(currentCharacter().stats)
			if (currentCharacter().stats.wood >= 25) {
				updateStats("wood", -25)
				updateStats("huts", 1)
			}
		}
	},
	'click .craftslot': function (evt) {
		// BUG: if you change the material type, it doesn't remove the cost of that material
		craftGrid = Session.get("craftGrid")
		component = Session.get("componentSelect")
		componentCost = Session.get(component + "Cost")
		if (craftGrid[this.row][this.col].material == Session.get("componentSelect")) {
			craftGrid[this.row][this.col] = {row: this.row, col: this.col, material: 0}
			Session.set(component + "Cost", componentCost-5)
		} else {
			craftGrid[this.row][this.col] = {row: this.row, col: this.col, material: Session.get("componentSelect")}
			Session.set(component + "Cost", componentCost+5)
		}
		Session.set("craftGrid", craftGrid)
	}
})

Template.crafting.helpers({
	building: function() {
		if (buildingHut()) {
			Session.set("buildReady", "Hut")
			return "Hut"
		}
		Session.set("buildReady", undefined)
	},
	woodCost: function() {
		return "Wood: " + Session.get("woodCost")
	},
	stoneCost: function() {
		return "Stone: " + Session.get("stoneCost")
	},
	buildReady: function() {
		if (Session.get("buildReady") == "Hut") {
			if (Session.get("woodCost")<=currentCharacter().stats.wood) {
				return "ready"
			} else {
				return "notEnough"
			}
		}
	},
	craftGrid: function () {
		return Session.get("craftGrid")
	}
})
