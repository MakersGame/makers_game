extends Node2D

var Identifier="BattleScene"

func _ready():
    Global.set_navigation()
    Global.PlayerCamera.reset_camera_area(-4000,-4000,4000,4000)
    $NPCs/NPC.init("test_NPC","following")
    Global.OverworldUIs.set_ui()
    Global.update_pause_window()
 

