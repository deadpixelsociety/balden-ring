extends Level
class_name Salon

var _boss_started = false

onready var _boss := $Entities/BossSpawn/Ciliara
onready var _lock := $Walls/BossLock/CollisionShape2D
onready var _boss_music := $BOSS
onready var _pop_music := $POP


func _ready():
	EventBus.connect("you_died", self, "_on_balden_died")
	EventBus.connect("boss_started", self, "_on_boss_started")
	EventBus.connect("boss_ended", self, "_on_boss_ended")


func reset():
	_boss_started = false
	_lock.set_deferred("disabled", true)
	_boss.reset()
	

func _on_BossArena_body_entered(body):
	if _boss_started:
		return
	_lock.set_deferred("disabled", false)
	_boss.start_fight()
	_boss_started = true


func _on_balden_died():
	reset()


func _on_boss_started(boss_name: String):
	_pop_music.stop()
	_boss_music.play()


func _on_boss_ended(dead: bool):
	_pop_music.play()
	_boss_music.stop()
	if dead:
		$Entities/BossDoor.visible = true
		$Entities/BossTrashfire.visible = true
		$Entities/Writing4.visible = true
		$Entities/Writing5.visible = true
		EventBus.emit_signal("large_text_display", "HAIR SEVERED", 2.0)
