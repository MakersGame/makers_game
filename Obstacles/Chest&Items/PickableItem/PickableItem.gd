extends KinematicBody2D

var Identifier="PickableItem"
var Type:String="Item"
var Name:String
var Number:int=0
var OffsetPosition:Vector2=Vector2()


func init(_Type:String,_Name:String,_Number:int,_OffsetPosition:Vector2):
    Type=_Type
    Name=_Name
    Number=_Number
    $AnimatedSprite.animation=Name
    OffsetPosition=_OffsetPosition

func _physics_process(delta):
    if !$CollisionShape2D.disabled:
        return
    elif OffsetPosition.length()<=1:
        global_position+=OffsetPosition
        OffsetPosition=Vector2()
        $CollisionShape2D.disabled=false
    else:
        global_position+=OffsetPosition.normalized()*sqrt(OffsetPosition.length())
        OffsetPosition-=OffsetPosition.normalized()*sqrt(OffsetPosition.length())
