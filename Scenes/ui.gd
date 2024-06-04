extends CanvasLayer

#CARATTERISTICHE DELL'ARMA
@export var current_weapon = "hammer"		#nome dell'arma utilizata
@export var weapon_damage = 50		#danno dell'arma
@export var fire_rate = 1.0			#numero di volte in cui l'arma spara in un secondo
@export var fire_range = -2.0			#range dell'arma

@onready var ray_container = $"../Head/Camera3D/RayContainer"
@onready var ray = $"../Head/Camera3D/RayCast3D"
@onready var projectile_particles = $"../Head/Camera3D/ProjectileParticles"
@onready var cooldown_timer = $Weapon/CooldownTimer
@onready var reload_time = $Weapon/ReloadTime

var blood_particles = load("res://Scenes/blood.tscn")
var sparks_particles = load("res://Scenes/sparks.tscn")

var shooted_count = 0 		#variabile che conta i colpi sparati
var radial_menu = false		#check if radial menu is on or not


#VARIABILI PER LE MUNIZIONI
#capienza massima delle munizioni totali
const AMMO_MAX_STORAGE := {
	ammo_type.PISTOL_BULLET: 100,
	ammo_type.SHOTGUN_BULLET: 30,
	ammo_type.MACHINEGUN_BULLET: 150,
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
	MACHINEGUN_BULLET
}

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



# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	switch_weapon(3)		#all'inizio viene impostato il martello come arma


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if !radial_menu:
		
		match current_weapon:
			"hammer":
				if Input.is_action_pressed("shoot") and cooldown_timer.is_stopped():
						cooldown_timer.start(1.0 / fire_rate)
						$Weapon/Hammer_AnimatedSprite2D.play("hammer_shoot")
						$Shoot.play()
						shoot(current_weapon)
				
			"pistol":
				if !storage_has_ammo(ammo_type.PISTOL_BULLET) and Input.is_action_just_pressed("shoot"):
					no_ammo_animation(current_weapon, $Weapon/Pistol_AnimatedSprite2D)
				else:
					if Input.is_action_pressed("shoot") and cooldown_timer.is_stopped() and reload_time.is_stopped():
						if magazine_has_ammo(ammo_type.PISTOL_BULLET):
							use_ammo(ammo_type.PISTOL_BULLET)
							cooldown_timer.start(1.0 / fire_rate)	
							$Weapon/Pistol_AnimatedSprite2D.play("pistol_shoot")
							$Shoot.play()
							shoot(current_weapon)
						else:
							reload(ammo_type.PISTOL_BULLET, $Weapon/Pistol_AnimatedSprite2D)
					
			"shotgun":
				if !storage_has_ammo(ammo_type.SHOTGUN_BULLET) and Input.is_action_just_pressed("shoot"):
					no_ammo_animation(current_weapon, $Weapon/Shotgun_AnimatedSprite2D)
				else:
					if Input.is_action_pressed("shoot") and cooldown_timer.is_stopped():
						if magazine_has_ammo(ammo_type.SHOTGUN_BULLET):
							use_ammo(ammo_type.SHOTGUN_BULLET)
							cooldown_timer.start(1.0 / fire_rate)
							$Weapon/Shotgun_AnimatedSprite2D.play("shotgun_shoot")
							$Shoot.play()
							shoot(current_weapon)
							$Reload.play()
						else:
							reload(ammo_type.SHOTGUN_BULLET, $Weapon/Shotgun_AnimatedSprite2D)
					
			"machinegun":
				if !storage_has_ammo(ammo_type.MACHINEGUN_BULLET) and Input.is_action_just_pressed("shoot"):
					no_ammo_animation(current_weapon, $Weapon/Machinegun_AnimatedSprite2D)
				else:
					if Input.is_action_pressed("shoot") and cooldown_timer.is_stopped() and reload_time.is_stopped():
						if magazine_has_ammo(ammo_type.MACHINEGUN_BULLET):
							cooldown_timer.start(1.0 / fire_rate)
							shooted_count += 1
							#si alternano tre suoni differenti per la machinegun
							match shooted_count % 3:
								0:
									$Shoot.stream = preload("res://Machinegun/minigun.ogg")
								1:
									$Shoot.stream = preload("res://Machinegun/minigun2.ogg")
								2:
									$Shoot.stream = preload("res://Machinegun/minigun3.ogg")
									
							$Weapon/Machinegun_AnimatedSprite2D.play("machinegun_shoot")
							$Shoot.play()
							shoot(current_weapon)
							use_ammo(ammo_type.MACHINEGUN_BULLET)
							printt(ammo_storage_total[ammo_type.MACHINEGUN_BULLET], ammo_magazine[ammo_type.MACHINEGUN_BULLET])
						else:
							reload(ammo_type.MACHINEGUN_BULLET, $Weapon/Machinegun_AnimatedSprite2D)
					if Input.is_action_just_released("shoot") and $Weapon/Machinegun_AnimatedSprite2D.is_playing():
						shooted_count = 0
						$Weapon/Machinegun_AnimatedSprite2D.play("machinegun_idle")


func switch_weapon(to):
	#SET PISTOL'S ANIMATION
	if to == 0 and current_weapon != "pistol":
		
		current_weapon = "pistol"
		fire_rate = 1.8
		fire_range = -20.0
		weapon_damage = 10.0
		
		set_projectile_particles(0.35, -0.35, 1.0, 0.015, 0.015, 0.0, fire_range, calculate_bullet_lifetime(fire_range, 100), 100.0, 100.0, 0.0)
		
		$Shoot.volume_db = -20.0
		$Shoot.stream = preload("res://Pistol/gunshot-fast-[AudioTrimmer.com].wav")
		
		if $Weapon/Shotgun_AnimatedSprite2D.visible:
			$Weapon/Shotgun_AnimatedSprite2D.visible = false
			$Weapon/Shotgun_AnimatedSprite2D.stop()
		else: if $Weapon/Machinegun_AnimatedSprite2D.visible:
			$Weapon/Machinegun_AnimatedSprite2D.visible = false
			$Weapon/Machinegun_AnimatedSprite2D.stop()
		else: if $Weapon/Hammer_AnimatedSprite2D.visible:
			$Weapon/Hammer_AnimatedSprite2D.visible = false
			$Weapon/Hammer_AnimatedSprite2D.stop()
		
		$Weapon/Pistol_AnimatedSprite2D.visible = true
		$Weapon/Pistol_AnimatedSprite2D.play(current_weapon + "_idle")
		$Crosshair/weapon_crosshair.play(current_weapon + "_crosshair")
		
	#SET MACHINEGUN'S ANIMATION
	else: if to == 2 and current_weapon != "machinegun":
		
		current_weapon = "machinegun"
		fire_rate = 5.0
		fire_range = -30.0
		weapon_damage = 10.0
		set_projectile_particles(0.0, -0.35, 1.0, 0.015, 0.0, 0.0, fire_range, calculate_bullet_lifetime(fire_range, 100), 100.0, 100.0, 0.0)
		
		$Shoot.stream = preload("res://Machinegun/minigun.ogg")
		$Shoot.volume_db = -30.0
		
		if $Weapon/Pistol_AnimatedSprite2D.visible:
			$Weapon/Pistol_AnimatedSprite2D.visible = false
			$Weapon/Pistol_AnimatedSprite2D.stop()
		else: if $Weapon/Shotgun_AnimatedSprite2D.visible:
			$Weapon/Shotgun_AnimatedSprite2D.visible = false
			$Weapon/Shotgun_AnimatedSprite2D.stop()
		else: if $Weapon/Hammer_AnimatedSprite2D.visible:
			$Weapon/Hammer_AnimatedSprite2D.visible = false
			$Weapon/Hammer_AnimatedSprite2D.stop()
			
		$Weapon/Machinegun_AnimatedSprite2D.visible = true
		$Weapon/Machinegun_AnimatedSprite2D.play(current_weapon + "_idle")
		$Crosshair/weapon_crosshair.play(current_weapon + "_crosshair")
		
	#SET SHOTGUN'S ANIMATION
	else: if to == 1 and current_weapon != "shotgun":
		
		current_weapon = "shotgun"
		fire_range = -11
		fire_rate = 0.75
		weapon_damage = 7	#danno di un singolo proiettile
		
		set_projectile_particles(0.0, -0.35, 0.0, 0.015, 0.0, 0.0, fire_range, calculate_bullet_lifetime(fire_range, 100) , 100.0, 100.0, 5.0)
		
		$Shoot.volume_db = -20.0
		$Shoot.stream = preload("res://Shotgun/shotgun-fx_168bpm.wav")
		
		if $Weapon/Pistol_AnimatedSprite2D.visible:
			$Weapon/Pistol_AnimatedSprite2D.visible = false
			$Weapon/Pistol_AnimatedSprite2D.stop()
		else: if $Weapon/Machinegun_AnimatedSprite2D.visible:
			$Weapon/Machinegun_AnimatedSprite2D.visible = false
			$Weapon/Machinegun_AnimatedSprite2D.stop()
		else: if $Weapon/Hammer_AnimatedSprite2D.visible:
			$Weapon/Hammer_AnimatedSprite2D.visible = false
			$Weapon/Hammer_AnimatedSprite2D.stop()
		
		$Weapon/Shotgun_AnimatedSprite2D.visible = true
		$Weapon/Shotgun_AnimatedSprite2D.play(current_weapon + "_idle")
		$Crosshair/weapon_crosshair.play(current_weapon + "_crosshair")
		
	#SET HAMMER'S ANIMATION
	else: if to == 3 and current_weapon != "hammer":
		
		current_weapon = "hammer"
		fire_range = -2
		fire_rate = 1.0
		weapon_damage = 50
		$Shoot.volume_db = -20.0
		$Shoot.stream = preload("res://Hammer/classic-double-swoosh_F#_minor-[AudioTrimmer.com].wav")
		projectile_particles.visible = false
		
		if $Weapon/Pistol_AnimatedSprite2D.visible:
			$Weapon/Pistol_AnimatedSprite2D.visible = false
			$Weapon/Pistol_AnimatedSprite2D.stop()
		else: if $Weapon/Machinegun_AnimatedSprite2D.visible:
			$Weapon/Machinegun_AnimatedSprite2D.visible = false
			$Weapon/Machinegun_AnimatedSprite2D.stop()
		else: if $Weapon/Shotgun_AnimatedSprite2D.visible:
			$Weapon/Shotgun_AnimatedSprite2D.visible = false
			$Weapon/Shotgun_AnimatedSprite2D.stop()
		
		$Weapon/Hammer_AnimatedSprite2D.visible = true
		$Weapon/Hammer_AnimatedSprite2D.play(current_weapon + "_idle")
		$Crosshair/weapon_crosshair.play(current_weapon + "_crosshair")
	
	ray.target_position.z = fire_range		#Il range viene modificato in base al range dell'arma attuale


func _input(event):
	if event.is_action_pressed("radial_menu"):
		get_node("Weapon/" + capitalizza_prima_lettera(current_weapon) + "_AnimatedSprite2D").play(current_weapon + "_idle")


func capitalizza_prima_lettera(testo):		#funzione di servizio, mette la prima lettera di una parola in maiusolo
	if testo.length() == 0:
		return testo  # Restituisce la stringa vuota se il testo è vuoto
	var prima_lettera = testo[0].to_upper()  # Prende la prima lettera e la converte in maiuscolo
	var resto_stringa = testo.substr(1, testo.length() - 1)  # Prende il resto della stringa
	return prima_lettera + resto_stringa  # Concatenazione della prima lettera maiuscola con il resto della stringa


func set_projectile_particles(pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, f_range, lifetime, v_min, v_max, spread):
		projectile_particles.visible = true
		projectile_particles.position.x = pos_x
		projectile_particles.position.y = pos_y
		projectile_particles.position.z = pos_z
		projectile_particles.rotation.x = rot_x
		projectile_particles.rotation.y = rot_y
		projectile_particles.rotation.z = rot_z
		projectile_particles.process_material.direction.z = f_range
		projectile_particles.lifetime = lifetime
		projectile_particles.process_material.initial_velocity_min = v_min
		projectile_particles.process_material.initial_velocity_max = v_max
		projectile_particles.process_material.spread = spread


#FUNZIONE CHE GESTISCE IL RAGGIO E IL DANNO DI UN'ARMA QUANDO SPARA E HITTA UN ENEMY
func shoot(_weapon):
	projectile_particles.restart()		#animazione del proiettile
	var collider
	var enemy_hit = false
	
	if _weapon == "shotgun":		#se l'arma selezionata è uno shotgun vengono randomizzati i raycast
		var spread = 1.5
		for r in ray_container.get_children():
			r.target_position.x = randf_range(spread, -spread)
			r.target_position.y = randf_range(spread, -spread)
			r.force_raycast_update()
			if r.is_colliding():
				collider = r.get_collider()
				if collider.is_in_group("enemy"):		#Se l'oggetto collisionato è un nemico allora gli togli vita
					collider.hitpoints -= weapon_damage
					collider.take_damage()
					enemy_hit = true
					show_blood(r)
				else:
					show_sparks(r)
	else:
		ray.force_raycast_update()
		if ray.is_colliding():
			collider = ray.get_collider()
			if collider.is_in_group("enemy"):		#Se l'oggetto collisionato è un nemico allora gli togli vita
				collider.hitpoints -= weapon_damage
				collider.take_damage()
				enemy_hit = true
				show_blood(ray)
			else:
				show_sparks(ray)
	
	
	if enemy_hit:
		$Crosshair/weapon_crosshair.play(_weapon + "_crosshair_hit")


func show_blood(raycast):
	var collision_point = raycast.get_collision_point()
	var blood = blood_particles.instantiate()
	blood.position = collision_point
	blood.rotation.y = -1 * (get_node("..").rotation.y)
	add_child(blood)


func show_sparks(raycast):
	var collision_point = raycast.get_collision_point()
	var sparks = sparks_particles.instantiate()
	sparks.position = collision_point
	add_child(sparks)


func calculate_bullet_lifetime(the_range, velocity):		#funzione che calcola il tempo di vita del proiettile
	if velocity != 0:
		return (-1 * the_range) / velocity



#GESTIONE DELLE MUNIZIONI-----------------------------------------------------------------------------------------
func storage_has_ammo(type: ammo_type):
	return ammo_storage_total[type] > 0

func magazine_has_ammo(type):
	return ammo_magazine[type] > 0
	
func use_ammo(type: ammo_type):
	if magazine_has_ammo(type):
		ammo_magazine[type] -= 1
	#else:
		#reload(type, animation)
		
func reload(type, animation: AnimatedSprite2D):
	if storage_has_ammo(type):
		
		printt(ammo_storage_total[type], AMMO_MAX_MAGAZINE[type])
		
		if ammo_storage_total[type] >= AMMO_MAX_MAGAZINE[type]:
			ammo_magazine[type] += AMMO_MAX_MAGAZINE[type]
			ammo_storage_total[type] -= AMMO_MAX_MAGAZINE[type]
			
		if ammo_storage_total[type] < AMMO_MAX_MAGAZINE[type] and ammo_storage_total[type] > 0:
			ammo_magazine[type] += ammo_storage_total[type]
			ammo_storage_total[type] = 0
		
		if type != ammo_type.SHOTGUN_BULLET:
			$Reload.play()
			reload_time.start(1.5)
			reload_animation(current_weapon, animation)
	else:
		$NoAmmo.play()

func reload_animation(weapon, animation: AnimatedSprite2D):
	animation.play(weapon + "_idle")
	$AnimationPlayer.play(weapon + "_reload")

func no_ammo_animation(weapon, animation: AnimatedSprite2D):
	$NoAmmo.play()
	$AnimationPlayer.play(weapon + "_idle")
