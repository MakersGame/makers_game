extends Node2D

onready var AreaContents=$AreaContents
var navigation=null

func _ready():
    navigation=AreaContents.get_node("TileMaps/Navigation2D")
    if Global.CurrentAreaBlock!=self:
        remove_child(AreaContents)
    $AreaContents/Enermies/Enermy.init("test_enermy",Vector2(-1,0),-1,global_position)
    $AreaContents/Enermies/Enermy2.init("test_enermy",Vector2(-1,0),-1,global_position)
    $AreaContents/Enermies/Enermy3.init("test_enermy",Vector2(0,-1),-1,global_position)
    $AreaContents/Enermies/Enermy4.init("test_enermy",Vector2(0,-1),-1,global_position)
    $AreaContents/Enermies/Enermy5.init("test_enermy",Vector2(0,-1),-1,global_position)
    $AreaContents/Chests/Chest.init([
        {"Name":"45ACP子弹","Type":"Item","Number":100},
        {"Name":"木材","Type":"Item","Number":10},
        {"Name":"汤姆逊冲锋枪","Type":"Weapon","Number":1},
        {"Name":"军刀","Type":"Weapon","Number":1}
       ])
    $AreaContents/Doors/Door1.init("left")
    $AreaContents/Doors/Door2.init("right")
    $AreaContents/Doors/Door3.init("down")
    $AreaContents/Doors/Door4.init("down")
    $AreaContents/Doors/Door5.init("right")
    $AreaContents/Doors/Door6.init("right")
    $AreaContents/Doors/Door7.init("right")
    $AreaContents/Doors/Door8.init("right")
    $AreaContents/Doors/Door9.init("right")
    

func _on_UpdateArea_body_entered(body):
    if body.Identifier=="Player":
        Global.area_block_change(self)
    if not self.is_a_parent_of(AreaContents):
        call_deferred("add_child",AreaContents)


func _on_UpdateArea_body_exited(body):
    if body.Identifier=="Player":
        Global.area_block_change(null)
    if self.is_a_parent_of(AreaContents):
        call_deferred("remove_child",AreaContents)
