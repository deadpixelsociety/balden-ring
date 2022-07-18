extends Node

signal large_text_hidden()

signal boss_started(boss_name)
signal boss_ended(dead)
signal boss_health_changed(value)
signal life_changed(value)
signal life_max_value_changed(value)
signal stamina_changed(value)
signal stamina_max_value_changed(value)
signal strands_collected(amount)
signal strands_updated(amount)
signal trashfire_lit(trashfire)
signal trashfire_rest()
signal large_text_display(message, delay)
signal large_text_hide()
signal you_died()
signal item_uses_updated(item_idx, uses)
signal item_texture_updated(item_idx, texture)
signal change_level(next_level, player)
