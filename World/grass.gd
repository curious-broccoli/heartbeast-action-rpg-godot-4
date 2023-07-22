extends Node2D

var grassEffect: PackedScene = preload("res://Effects/grass_effect.tscn")

func create_grass_effect():
    var grass_effect = grassEffect.instantiate()
    get_parent().add_child(grass_effect)
    grass_effect.position = position


func _on_hurtbox_area_entered(area: Area2D) -> void:
    create_grass_effect()
    queue_free()
