extends Area2D
    
func get_push_vector() -> Vector2:
    var areas: Array = get_overlapping_areas()
    var push_vector = Vector2.ZERO
    if areas.size() > 0:
        var area: Area2D = areas[0]
        push_vector = area.global_position.direction_to(global_position)
    return push_vector
