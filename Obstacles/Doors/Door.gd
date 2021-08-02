extends Node2D



func _ready():
    z_index=floor(position.y/20)
    $AnimationPlayer.play("door1")


func _on_AnimationPlayer_animation_finished(anim_name):
    $AnimationPlayer.play("door1")
