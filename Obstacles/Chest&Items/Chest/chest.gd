extends Node2D

var Identifier="Chest"
var Opened=false
var Contents={}
onready var Item=preload("res://Obstacles/Chest&Items/PickableItem/PickableItem.tscn")

func _ready():
    z_index=floor(position.y/20)


func init(_Contents):
    Contents=_Contents
    
func open():
    Opened=true
    $CollisionShape2D.disabled=true
    $AnimatedSprite.animation="opened"
    for i in Contents:
        var Offset=Vector2()
        while Offset==Vector2():
            Offset=Vector2(randi()%150+40,randi()%150+40)
            if Global.detect_collision_in_line(global_position+Offset,global_position+Offset+Vector2(0.1,0.1),[self],1):
                Offset=Vector2()
        var NewItem=Item.instance()
        NewItem.init(i["Type"],i["Name"],i["Number"],Offset)
        NewItem.global_position=global_position
        Global.CurrentScene.add_child(NewItem)
        
            
