extends Node2D

var InventoryFocused:int=0      #鼠标聚焦的物品栏

func update_quick_use_item():
    for i in range(5):
        if Global.QuickUseItem[i]==null or Global.GoodInBackpack[Global.QuickUseItem[i]]<=0:
            $InventoryList.get_node("Inventory"+String(i+1)).update_sprite("null",-1)
            Global.QuickUseItem[i]=null
        else:
            $InventoryList.get_node("Inventory"+String(i+1)).update_sprite(Global.QuickUseItem[i],-1)

func _input(event):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        if InventoryFocused!=0:
            get_parent().reset_quick_use_item(InventoryFocused-1)
 
func inventory_focus_get(Num:int):
    InventoryFocused=Num
    $InventoryFocused.global_position=$InventoryList.get_node("Inventory"+String(InventoryFocused)).global_position
    $InventoryFocused.show()

func inventory_focus_lose(Num:int):
    if InventoryFocused==Num:
        InventoryFocused=0
        $InventoryFocused.hide()            
