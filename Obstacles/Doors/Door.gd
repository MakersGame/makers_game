extends StaticBody2D

var Identifier="Door"
var Locked:bool=false
var Key=null
var Opened:bool=false
var CurrentAnimation=""

\
func init(_Direction:String,_Opened:bool=false,_Locked=false,_Key=null):
    Key=_Key
    Locked=_Locked
    if _Direction=="left":
        CurrentAnimation="right2left"
        $DoorBody/AnimatedSprite.animation="right2left"
        $DoorBody/Obstacle/CollisionShape2D.shape.extents=Vector2(10,5)   
        $DoorBody/Obstacle/CollisionShape2D.position=Vector2(0,-5)
    elif _Direction=="right":
        CurrentAnimation="left2right"
        $DoorBody/AnimatedSprite.animation="left2right"
        $DoorBody/Obstacle/CollisionShape2D.shape.extents=Vector2(10,5)   
        $DoorBody/Obstacle/CollisionShape2D.position=Vector2(0,-5)
    elif _Direction=="down":
        CurrentAnimation="up2down"
        $DoorBody/AnimatedSprite.animation="up2down"
        $DoorBody/Obstacle/CollisionShape2D.shape.extents=Vector2(5,10)
        $DoorBody/Obstacle/CollisionShape2D.position=Vector2(0,-5)

    z_index=floor(position.y/20)
func open():
    if $AnimationPlayer.is_playing():
        yield($AnimationPlayer,"animation_finished")
    if !Opened:
        $AnimationPlayer.play(CurrentAnimation)

func close():
    if $AnimationPlayer.is_playing():
        yield($AnimationPlayer,"animation_finished")
    if Opened:
        $AnimationPlayer.play_backwards(CurrentAnimation)

func _on_AnimationPlayer_animation_finished(anim_name):
    if $AnimationPlayer.get_current_animation_position()!=0:
        Opened=true
        $CloseTimer.start()
    else:
        Opened=false

func _on_CloseTimer_timeout():
    if $AnimationPlayer.is_playing():
        yield($AnimationPlayer,"animation_finished")
    close()
