extends CharacterBody2D

const PlayerHurtSound: PackedScene = preload("res://Sound/player_hurt_sound.tscn")

@export var max_speed: float = 120
@export var acceleration: float = 500
@export var friction: float = 700
@export var roll_speed: float = 160

enum State {
    MOVE,
    ROLL,
    ATTACK,
}
var state = State.MOVE
var roll_vector := Vector2.DOWN
var stats: Node = PlayerStats
var direction: Vector2 = Vector2.ZERO

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var blink_animation_player: AnimationPlayer = $BlinkAnimationPlayer
@onready var hurtbox: Area2D = $Hurtbox

func _ready() -> void:
    stats.health_depleted.connect(on_health_depleted)
    animation_tree.active = true

func _physics_process(delta: float) -> void:
    match state:
        State.MOVE:
            move_state(delta)
        State.ROLL:
            roll_state(delta)
        State.ATTACK:
            attack_state(delta)
            
    move_and_slide()

func move_state(delta: float):
    var input_vector := Vector2.ZERO
    input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    input_vector = input_vector.normalized()
    if input_vector != Vector2.ZERO:
        direction = input_vector
    
    if input_vector != Vector2.ZERO:
        roll_vector = input_vector
        animation_tree.set("parameters/idle/blend_position", input_vector)
        animation_tree.set("parameters/run/blend_position", input_vector)
        animation_tree.set("parameters/attack/blend_position", input_vector)
        animation_tree.set("parameters/roll/blend_position", input_vector)
        velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta) 
        animation_state.travel("run")
    else:
        velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
        animation_state.travel("idle")
    
    if Input.is_action_just_pressed("attack"):
        state = State.ATTACK
    elif  Input.is_action_just_pressed("roll"):
        state = State.ROLL

func attack_state(_delta: float):
    velocity *= 0.8
    animation_state.travel("attack")
    
func roll_state(_delta: float):
    velocity = roll_vector * roll_speed
    animation_state.travel("roll")
    
func roll_animation_finished() -> void:
    velocity *= 0.6
    state = State.MOVE
    
func attack_animation_finished() -> void:
    state = State.MOVE  

func _on_hurtbox_area_entered(area: Area2D) -> void:
    stats.health -= area.damage
    hurtbox.start_invincibility(0.6)
    hurtbox.create_hit_effect()
    var player_hurt_sound = PlayerHurtSound.instantiate()
    get_tree().current_scene.add_child(player_hurt_sound)
    
func on_health_depleted() -> void:
    queue_free()

func _on_hurtbox_invicibility_started() -> void:
    blink_animation_player.play("start")

func _on_hurtbox_invincibility_ended() -> void:
    blink_animation_player.play("stop")
