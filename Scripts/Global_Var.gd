extends Node


var player_health = 100

var diff := 1  #variabile globale difficoltà

#VARIABILI PER LE MUNIZIONI
#capienza massima delle munizioni totali
const AMMO_MAX_STORAGE := {
	ammo_type.PISTOL_BULLET: 100,	#100
	ammo_type.SHOTGUN_BULLET: 30,	#30
	ammo_type.MACHINEGUN_BULLET: 150,	#150
}

#capienza massima di caricatori
const AMMO_MAX_MAGAZINE := {
	ammo_type.PISTOL_BULLET: 15,
	ammo_type.SHOTGUN_BULLET: 1,
	ammo_type.MACHINEGUN_BULLET: 25
}

enum ammo_type {
	PISTOL_BULLET, 
	SHOTGUN_BULLET,
	MACHINEGUN_BULLET,
	HAMMER
}

var current_bullet_type = ammo_type.HAMMER

#Capienza attuale dei caricatori
var ammo_magazine := {
	ammo_type.PISTOL_BULLET: AMMO_MAX_MAGAZINE[ammo_type.PISTOL_BULLET],
	ammo_type.SHOTGUN_BULLET: AMMO_MAX_MAGAZINE[ammo_type.SHOTGUN_BULLET],
	ammo_type.MACHINEGUN_BULLET: AMMO_MAX_MAGAZINE[ammo_type.MACHINEGUN_BULLET]
}

#Capienza attuale delle munizioni totali
var ammo_storage_total := {
	ammo_type.PISTOL_BULLET: AMMO_MAX_STORAGE[ammo_type.PISTOL_BULLET],
	ammo_type.SHOTGUN_BULLET: AMMO_MAX_STORAGE[ammo_type.SHOTGUN_BULLET],
	ammo_type.MACHINEGUN_BULLET: AMMO_MAX_STORAGE[ammo_type.MACHINEGUN_BULLET]
}


## Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
	#pass
