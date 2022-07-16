extends Resource
class_name WeaponDef

export(String) var display_name = ""
export(Texture) var texture = null
export(Material) var material = null
export(Vector2) var pivot_point = Vector2.ZERO
export(Shape2D) var hitbox = null
export(float) var attack_speed = 1.0 # attacks per second
export(float) var attack_angle = 45.0
export(float) var swing_time = 1.0
export(float) var damage_min = 1.0
export(float) var damage_max = 1.0
export(float) var crit_chance = 1.0
export(float) var crit_multi = 1.0
export(float) var knockback_power = 0.0
