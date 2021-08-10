extends Node2D

onready var AreaContents=$AreaContents
var navigation=null

func _ready():
    navigation=AreaContents.get_node("TileMaps/Navigation2D")
    set_enermies()
    set_chests()
    $AreaContents/Doors/Door1.init("right")
    $AreaContents/Doors/Door2.init("right")
    $AreaContents/Doors/Door3.init("right")
    $AreaContents/Doors/Door4.init("right")
    $AreaContents/Doors/Door5.init("right")
    $AreaContents/Doors/Door6.init("right")
    $AreaContents/Doors/Door7.init("right")
    $AreaContents/Doors/Door8.init("right")
    $AreaContents/Doors/Door9.init("right")
    $AreaContents/Doors/Door10.init("right")
    $AreaContents/Doors/Door11.init("down")
    $AreaContents/Doors/Door12.init("down")
    $AreaContents/Doors/Door13.init("down")
    $AreaContents/Doors/Door14.init("down")
    
    if Global.CurrentAreaBlock!=self:
        remove_child(AreaContents)

func set_chests():
    for i in $AreaContents/Chests.get_children():
        i.init([
            {"Name":"建材","Type":"Item","Number":[10,50],"RandomGroup":1,"Probability":1},
            {"Name":"45ACP子弹","Type":"Item","Number":[80,120],"RandomGroup":2,"Probability":0.1},
            {"Name":"汤姆逊冲锋枪","Type":"Weapon","Number":[1,1],"RandomGroup":2,"Probability":0.1},
            {"Name":"雷明顿16号弹","Type":"Item","Number":[15,40],"RandomGroup":3,"Probability":0.1},
            {"Name":"老式霰弹枪","Type":"Weapon","Number":[1,1],"RandomGroup":3,"Probability":0.1},
            {"Name":"9mm子弹","Type":"Item","Number":[20,50],"RandomGroup":4,"Probability":0.1},
            {"Name":"9mm手枪","Type":"Weapon","Number":[1,1],"RandomGroup":4,"Probability":0.1},
            {"Name":"军刀","Type":"Weapon","Number":[1,1],"RandomGroup":5,"Probability":0.1},
            {"Name":"马桶橛子","Type":"Weapon","Number":[1,1],"RandomGroup":6,"Probability":0.1},
            {"Name":"EX咖喱棒","Type":"Weapon","Number":[1,1],"RandomGroup":7,"Probability":0.1},
        ])

func set_enermies():
    $AreaContents/Enermies/Enermy1.init("Zombie",Vector2(-1,0),-1,global_position)
    $AreaContents/Enermies/Enermy2.init("Zombie",Vector2(-1,0),-1,global_position)
    $AreaContents/Enermies/Enermy3.init("Zombie",Vector2(0,-1),-1,global_position)
    $AreaContents/Enermies/Enermy4.init("Zombie",Vector2(0,-1),-1,global_position)
    $AreaContents/Enermies/Enermy5.init("Zombie",Vector2(0,-1),-1,global_position)
    $AreaContents/Enermies/Enermy6.init("Zombie",Vector2(-1,0),-1,global_position)
    $AreaContents/Enermies/Enermy7.init("Zombie",Vector2(-1,0),-1,global_position)
    $AreaContents/Enermies/Enermy8.init("Zombie",Vector2(0,-1),-1,global_position)
    $AreaContents/Enermies/Enermy9.init("Zombie",Vector2(0,-1),-1,global_position)
    $AreaContents/Enermies/Enermy10.init("Zombie",Vector2(0,-1),-1,global_position)
    $AreaContents/Enermies/Enermy11.init("Zombie",Vector2(0,-1),-1,global_position)

func _on_UpdateArea_body_entered(body):
    if body.Identifier=="Player":
        Global.area_block_change(self)
        if not self.is_a_parent_of(AreaContents):
            call_deferred("add_child",AreaContents)
        for i in AreaContents.get_node("Enermies").get_children():
            i.CreatureStatus.set_navigation(AreaContents.get_node("TileMaps/Navigation2D"))


func _on_UpdateArea_body_exited(body):
    if body.Identifier=="Player":
        Global.area_block_change(null)
        if self.is_a_parent_of(AreaContents):
            call_deferred("remove_child",AreaContents)
