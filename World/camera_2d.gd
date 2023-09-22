extends Camera2D

@onready var top_left: Marker2D = $Limit/TopLeft
@onready var bottom_right: Marker2D = $Limit/BottomRight


func _ready() -> void:
    limit_top = top_left.position.y
    limit_left = top_left.position.x
    limit_bottom = bottom_right.position.y
    limit_right = bottom_right.position.x
