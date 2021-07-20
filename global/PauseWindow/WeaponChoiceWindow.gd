extends Node2D

var InventoryFocused:int=0      #鼠标聚焦的物品栏
onready var Backpack:Object=get_parent().get_parent().get_node("Backpack")
var Weapons:Array=[]
var CurrentPage:int=1

func update_weapons(Type:String):#Type值为"MeleeWeapon"或"RangedWeapon"
    CurrentPage=1
    Weapons=[]
    for i in Backpack.SequencedWeapon:
        if ReferenceList.WeaponReference[Global.WeaponInBackpack[i]["Name"]]["Type"]==Type:
            Weapons.push_back(i)
    page_change_action()
    if Weapons.size()>8:
        $ScrollBar/Bar.scale.y=2/ceil(float((Weapons.size()))/4)
    else:
        $ScrollBar/Bar.scale.y=1
    $ScrollBar/Bar.position.y=-122
    
func page_change_action():
    var Inventories=$InventoryList.get_children()
    for Inventory in Inventories:
        if Inventory.Number+4*(CurrentPage-1)<=Weapons.size():
            Inventory.update_sprite(Global.WeaponInBackpack[Weapons[4*(CurrentPage-1)+Inventory.Number-1]]["Name"],Weapons[4*(CurrentPage-1)+Inventory.Number-1])
        else:
            Inventory.update_sprite("null",-1)
   
func _input(event):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        if InventoryFocused!=0:
            if Weapons.size()>=InventoryFocused+4*(CurrentPage-1):
                get_parent().weapon_change(Weapons[InventoryFocused+4*(CurrentPage-1)-1])
            else:
                get_parent().weapon_change(-1)
    elif event.is_action_pressed("ui_focus_next") and Weapons.size()>(CurrentPage-1)*4+8:
        CurrentPage+=1
        $ScrollBar/Bar.position.y+=122*$ScrollBar/Bar.scale.y
        page_change_action()
    elif event.is_action_pressed("ui_focus_prev") and CurrentPage>1:
        CurrentPage-=1
        $ScrollBar/Bar.position.y-=122*$ScrollBar/Bar.scale.y
        page_change_action() 

func inventory_focus_get(Num:int):
    InventoryFocused=Num
    $InventoryFocused.global_position=$InventoryList.get_node("Inventory"+String(InventoryFocused)).global_position
    $InventoryFocused.show()

func inventory_focus_lose(Num:int):
    if InventoryFocused==Num:
        InventoryFocused=0
        $InventoryFocused.hide()
