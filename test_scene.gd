extends Node2D

onready var navigation=$Navigation2D

var Identifier="BattleScene"

func _ready():
    Global.set_navigation()
    Global.PlayerCamera.reset_camera_area(-2000,-2000,2000,2000)
    $NPCs/NPC.init("test_NPC","following")
    Global.OverworldUIs.set_ui()
    Global.update_pause_window()
 

