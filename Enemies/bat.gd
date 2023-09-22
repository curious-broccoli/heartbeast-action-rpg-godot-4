extends CharacterBody2D

const death_effect: PackedScene = preload("res://Effects/enemy_death_effect.tscn")
@export var acceleration: float = 300
@export var max_speed: float = 50
@export var friction: float = 200
@export var collision_force: float = 300
@export var wander_target_range: float = 4

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stats: Node = $Stats
@onready var player_detection_zone = $PlayerDetectionZone
@onready var hurtbox: Area2D = $Hurtbox
@onready var soft_collision: Area2D = $SoftCollision
@onready var wander_controller: Node2D = $WanderController
enum State {
    IDLE,
    WANDER,
    CHASE,
}
var state = State.WANDER

func _ready():
    randomize()
    sprite.frame = randi_range(0, sprite.sprite_frames.get_frame_count("default") -1)

func _physics_process(delta: float) -> void:
    match state:
        State.IDLE:
            velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
            check_for_player()
            if wander_controller.get_time_left() == 0:
                switch_state()
        State.WANDER:
            check_for_player()
            if wander_controller.get_time_left() == 0:
                switch_state()
                
            accelerate_towards(wander_controller.target_position, delta)            
            if global_position.distance_to(wander_controller.target_position) <= wander_target_range:
                switch_state()
        State.CHASE:
            var player: Node = player_detection_zone.player
            if player != null:
                accelerate_towards(player.global_position, delta)
            else:
                state = State.IDLE
    sprite.flip_h = velocity.x < 0
        
    var collision_vector = soft_collision.get_push_vector()
    if collision_vector:
        velocity += collision_vector * delta * collision_force
    move_and_slide()
    
func switch_state() -> void:
    state = pick_random_state([State.IDLE, State.WANDER])
    wander_controller.start_wander_timer(randi_range(1, 3))
    
func accelerate_towards(target: Vector2, delta: float) -> void:
    var direction = global_position.direction_to(target)
    velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
    
func check_for_player():
    if player_detection_zone.can_see_player():
        state = State.CHASE
    
func pick_random_state(states: Array) -> State:
    return states.pick_random()

func _on_hurtbox_area_entered(area: Area2D) -> void:
    # get direction from sword hitbox to enemy
    var direction: Vector2 = area.owner.position.direction_to(position)
    velocity = direction * area.knockback_strength
    
    stats.health -= area.damage
    hurtbox.create_hit_effect()
    hurtbox.start_invincibility(0.4)

func _on_stats_health_depleted() -> void:
    var enemy_death_effect := death_effect.instantiate()
    get_parent().add_child(enemy_death_effect)
    enemy_death_effect.position = position
    queue_free()

func _on_hurtbox_invicibility_started() -> void:
    animation_player.play("start")

func _on_hurtbox_invincibility_ended() -> void:
    animation_player.play("stop")
