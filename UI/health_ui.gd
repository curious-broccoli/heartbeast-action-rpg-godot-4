extends Control

var hearts_height: int = 11
@onready var empty_hearts_ui: TextureRect = $EmptyHearts
@onready var full_hearts_ui: TextureRect = $FullHearts

func set_hearts() -> void:
    if full_hearts_ui != null:
        full_hearts_ui.set_size(Vector2(PlayerStats.health * 15, 11))
        
func _ready() -> void:
    PlayerStats.health_changed.connect(set_hearts)
    
