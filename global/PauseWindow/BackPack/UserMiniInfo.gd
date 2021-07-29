extends Area2D

var Number:int              #自身编号
var CursorOn:bool=false     #鼠标是否放在此物品栏上

func _ready():
    Number=int(name.right(4))

func update_sprite(User):
    if User.Identifier=="Player":
        $AnimatedSprite.frames=User.get_node("Animations/PlayerAnimation").frames
        $AnimatedSprite.animation="info"
    elif User.Identifier=="NPC":
        $AnimatedSprite.frames=User.get_node("Animations/NPCAnimation").frames
        $AnimatedSprite.animation="info"
    $HealthBar.max_value=User.CreatureStatus.MaxHealth
    $HealthBar.value=User.CreatureStatus.Health
    $HealthBar/HealthValue.text=String(round($HealthBar.value))+"/"+String(round($HealthBar.max_value))

func _on_User_mouse_entered():
    CursorOn=true
    get_parent().get_parent().user_focus_get(Number)


func _on_User_mouse_exited():
    CursorOn=false
    get_parent().get_parent().user_focus_lose(Number)

