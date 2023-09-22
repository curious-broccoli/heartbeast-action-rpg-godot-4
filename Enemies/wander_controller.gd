extends Node2D

@export var wander_range: int = 32

@onready var start_position: Vector2 = global_position
@onready var target_position: Vector2 = global_position
@onready var timer: Timer = $Timer

func _ready() -> void:
    update_target_position()

func update_target_position() -> void:
    var target = Vector2(randi_range(-wander_range, wander_range), randi_range(-wander_range, wander_range))
    target_position = start_position + target
    
func start_wander_timer(duration: float) -> void:
    timer.start(duration)

func get_time_left() -> float:
    return timer.time_left

func _on_timer_timeout() -> void:
    update_target_position()
