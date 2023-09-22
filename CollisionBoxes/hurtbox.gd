extends Area2D

signal invicibility_started
signal invincibility_ended

const hit_effect_scene = preload("res://Effects/hit_effect.tscn")
var invincible: bool = false:
    set(value):
        invincible = value
        if invincible == true:
            invicibility_started.emit()
        else:
            invincibility_ended.emit()
            
@onready var timer: Timer = $Timer
            
func start_invincibility(duration: float):
    invincible = true
    timer.start(duration)

func create_hit_effect() -> void:
    var effect: Node = hit_effect_scene.instantiate()
    var main: Node = get_tree().current_scene
    main.add_child(effect)
    effect.global_position = global_position  

func _on_timer_timeout() -> void:
    invincible = false

func _on_invicibility_started() -> void:
    set_deferred("monitoring", false)

func _on_invincibility_ended() -> void:
    set_deferred("monitoring", true)
