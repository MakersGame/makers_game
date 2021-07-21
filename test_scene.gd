extends Node2D

onready var navigation=$TileMaps/Navigation2D

var Identifier="BattleScene"

func _ready():
    Global.set_navigation()
    Global.PlayerCamera.reset_camera_area(-2000,-2000,2000,2000)
    $NPCs/NPC.init("test_NPC","following")
    $Enermies/Enermy.init("test_enermy",Vector2(-1,0))
    $Enermies/Enermy2.init("test_enermy",Vector2(-1,0))
    $Enermies/Enermy3.init("test_enermy",Vector2(0,-1))
    Global.OverworldUIs.set_ui()
    Global.update_pause_window()
 

