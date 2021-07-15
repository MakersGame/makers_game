extends Panel
signal panel_close



# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass


func _on_close_pressed():
    Global.close_synthesis()
    Global.GameStatus = "PlayerControl"
    pass # Replace with function body.
