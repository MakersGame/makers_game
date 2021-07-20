extends Area2D

var Number:int              #自身编号
var CursorOn:bool=false     #鼠标是否放在此物品栏上

onready var BackPack=get_parent().get_parent()

func _ready():
    Number=int(name.right(9))
    $DurabilityBar.hide()

func update_sprite(ItemName,WeaponNumber:int):
    $AnimatedSprite.animation=ItemName
    $DurabilityBar.hide()
    if ItemName=="null" or ReferenceList.ItemRference.get(ItemName)==null:
        $ItemNumber.text=""
    if WeaponNumber>=0:
        $DurabilityBar.max_value=ReferenceList.WeaponReference[Global.WeaponInBackpack[WeaponNumber]["Name"]]["MaxDurability"]
        $DurabilityBar.value=Global.WeaponInBackpack[WeaponNumber]["Durability"]
        $DurabilityBar.max_value=ReferenceList.WeaponReference[Global.WeaponInBackpack[WeaponNumber]["Name"]]["MaxDurability"]
        $DurabilityBar.show()
    elif ReferenceList.ItemRference.get(ItemName)!=null:
        $ItemNumber.text=String(Global.GoodInBackpack[ItemName])

func _on_Inventory_mouse_entered():
    CursorOn=true
    BackPack.inventory_focus_get(Number)

func _on_Inventory_mouse_exited():
    CursorOn=false
    BackPack.inventory_focus_lose(Number)
