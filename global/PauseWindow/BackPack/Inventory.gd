extends Area2D

var Number:int              #自身编号
var CursorOn:bool=false     #鼠标是否放在此物品栏上

onready var BackPack=get_parent().get_parent()

func _ready():
    Number=int(name.right(9))
    $DurabilityBar.hide()

func update_sprite(ItemName="null",WeaponNumber:int=-1,InHome:bool=false):
    $AnimatedSprite.animation=ItemName
    $DurabilityBar.hide()
    if ItemName=="null" or ReferenceList.ItemRference.get(ItemName)==null:
        $ItemNumber.text=""
    if WeaponNumber>=0:
        if !InHome:
            $DurabilityBar.max_value=ReferenceList.WeaponReference[Global.WeaponInBackpack[WeaponNumber]["Name"]]["MaxDurability"]
            $DurabilityBar.value=Global.WeaponInBackpack[WeaponNumber]["Durability"]
            $DurabilityBar.max_value=ReferenceList.WeaponReference[Global.WeaponInBackpack[WeaponNumber]["Name"]]["MaxDurability"]
        else:
            $DurabilityBar.max_value=ReferenceList.WeaponReference[Global.WeaponInHome[WeaponNumber]["Name"]]["MaxDurability"]
            $DurabilityBar.value=Global.WeaponInHome[WeaponNumber]["Durability"]
            $DurabilityBar.max_value=ReferenceList.WeaponReference[Global.WeaponInHome[WeaponNumber]["Name"]]["MaxDurability"]
        $DurabilityBar.show()
    elif ReferenceList.ItemRference.get(ItemName)!=null:
        if !InHome:
            $ItemNumber.text=String(Global.GoodInBackpack[ItemName])
        else:
            $ItemNumber.text=String(Global.GoodInHome[ItemName])

func _on_Inventory_mouse_entered():
    CursorOn=true
    BackPack.inventory_focus_get(Number)

func _on_Inventory_mouse_exited():
    CursorOn=false
    BackPack.inventory_focus_lose(Number)
