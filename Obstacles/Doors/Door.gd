extends StaticBody2D

var Identifier="Door"
var Locked:bool=false
var Key=null
var Opened:bool=false
var CurrentAnimation=""
var BodyInArea=[]


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
    if $AnimationPlayer.is_playing() and Opened:
        $AnimationPlayer.stop(false)
        $AnimationPlayer.play(CurrentAnimation)
    if !Opened:
        $AnimationPlayer.play(CurrentAnimation)

func close():
    if $AnimationPlayer.is_playing():
        yield($AnimationPlayer,"animation_finished")
    if Opened:
        var i=0
        while i<BodyInArea.size():
            if !BodyInArea[i].CreatureStatus.alive():
                BodyInArea.remove(i)
                i-=1
            i+=1
        if BodyInArea.size()==0:
            $AnimationPlayer.play_backwards(CurrentAnimation)
        else:
            $CloseTimer.start()

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


func _on_DetectArea_body_entered(body):
    if body.Identifier=="Player" or Locked:
        return
    if not body in BodyInArea:
        BodyInArea.push_back(body)
    if !Opened and !$AnimationPlayer.is_playing():
        if !(body.Identifier=="Enermy" and body.AImode=="default"):
            open()
    elif Opened and $AnimationPlayer.is_playing():
        if !(body.Identifier=="Enermy" and body.AImode=="default"):
            $AnimationPlayer.stop(false)
            $AnimationPlayer.play(CurrentAnimation)
            $CloseTimer.start()

func _on_DetectArea_body_exited(body):
    if body in BodyInArea:
        BodyInArea.erase(body)
