extends CharacterBody3D
class_name Enemy

@export var max_hitpoints := 100
@export var fire_rate = 2.0 		#numero di colpi sparati in un secondo
@export var attack_range = 10.0
@export var damage = 10

const SPEED = 4.0
const JUMP_VELOCITY = 4.5
const AGGRO_RANGE = 40.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var navigation_agent_3d = $NavigationAgent3D

@onready var ray = $RayCast3D
@onready var timer = $CooldownTimer

var player
var provoked = false		#l'enemy è stato provocato? 
var attacking = false

var hitpoints = max_hitpoints:
	set(value):
		hitpoints = value
		if hitpoints <= 0:
			queue_free()
		provoked = true


func _ready() -> void:
	$AnimatedSprite3D.play("default")
	player = get_tree().get_first_node_in_group("player")


func _process(_delta):
	if provoked and !attacking:
		$AnimatedSprite3D.play("walk")
		navigation_agent_3d.target_position = player.global_position
	else: if attacking:
		$AnimatedSprite3D.play("shoot")


func _physics_process(delta):
	var next_position = navigation_agent_3d.get_next_path_position()
	ray.look_at(player.global_position)
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	
	var direction = global_position.direction_to(next_position)
	var distance = global_position.distance_to(player.global_position)
	
		
	if distance <= AGGRO_RANGE:
		provoked = true
		
	if provoked and distance <= attack_range:
		attacking = true
		if ray.is_colliding() and ray.get_collider() is Player:
			attack()
	else:
		attacking = false
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if !attacking: 
		move_and_slide()


func attack():
	if timer.is_stopped():
		timer.start(1.0)
		ray.get_collider().player_health -= damage
		print(ray.get_collider().player_health)




#func die():
	#dead = true  # Corrected variable scope
	#$AnimatedSprite3D.play("die")
	#$CollisionShape3D.disabled = true		#disattivo le collisioni così posso attraversarlo quando muore
	#Global.player_score += 100
