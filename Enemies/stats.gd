extends Node

signal health_depleted
signal health_changed

@export var max_health: float = 4
@onready var health: float = max_health:
    set(value):
        health = clampf(value, 0, max_health)
        health_changed.emit()
        if health == 0:
            health_depleted.emit()

