extends Node2D

var SequencedItem=[]            #背包中的物品，按编号排序，仅储存名称
var SequencedWeapon=[]          #背包中的武器，按编号和耐久排序，储存在Global.WeaponInPacket中的下标
var CurrentPage=1               #当前背包第一行是所有物品的第几行
var InventoryChosen:int=0       #选中的物品栏
var InventoryFocused:int=0      #鼠标聚焦的物品栏（可能没有选中） 
var FocusChangable:bool=true
var ItemType:String="All"

func _ready():
    $InventoryChosen.hide()
    $InventoryFocused.hide()
    $ItemDetail.hide()
#    $DropItemWindow.hide()
#    $QuickUseItem.hide()
#    $DropWeaponWindow.hide()
#    update_items_in_backpack("All")

func update_items_in_home():
    CurrentPage=1
    SequencedItem=[]
    SequencedWeapon=[]
    for key in Global.GoodInHome.keys():
        if Global.GoodInHome[key]>0 and (ItemType=="All" or ItemType==ReferenceList.ItemRference[key]["Type"]):
            SequencedItem.push_back(key)
    if ItemType=="Weapon" or ItemType=="All":
        for i in range(Global.WeaponInHome.size()):
            SequencedWeapon.push_back(i)
    for i in range(SequencedItem.size()):
        for j in range(SequencedItem.size()-1):
            if ReferenceList.ItemRference[SequencedItem[j]]["ID"]>ReferenceList.ItemRference[SequencedItem[j+1]]["ID"]:
                var temp=SequencedItem[j]
                SequencedItem[j]=SequencedItem[j+1]
                SequencedItem[j+1]=temp   
    for i in range(SequencedWeapon.size()):
        for j in range(SequencedWeapon.size()-1):
            var ID1:int=ReferenceList.WeaponReference[Global.WeaponInHome[SequencedWeapon[j]]["Name"]]["ID"]
            var ID2:int=ReferenceList.WeaponReference[Global.WeaponInHome[SequencedWeapon[j+1]]["Name"]]["ID"]
            var Durability1=Global.WeaponInHome[SequencedWeapon[j]]["Durability"]
            var Durability2=Global.WeaponInHome[SequencedWeapon[j+1]]["Durability"]
            if ID1>ID2 or (ID1==ID2 and Durability1>Durability2):
                var temp=SequencedWeapon[j]
                SequencedWeapon[j]=SequencedWeapon[j+1]
                SequencedWeapon[j+1]=temp
                  
    var Inventories=$InventoryList.get_children()
    page_change_action()
    if SequencedItem.size()+SequencedWeapon.size()>12:
        $ScrollBar/Bar.scale.y=3/ceil(float((SequencedItem.size()+SequencedWeapon.size()))/4)
    else:
        $ScrollBar/Bar.scale.y=1
    $ScrollBar/Bar.position.y=-122
    
    item_detail_change()
    
    FocusChangable=true
#    $ItemDetail/Buttons/Drop.mouse_filter=Control.MOUSE_FILTER_PASS
#    $ItemDetail/Buttons/Use.mouse_filter=Control.MOUSE_FILTER_PASS
#    $ItemDetail/Buttons/QuickUse.mouse_filter=Control.MOUSE_FILTER_PASS


func page_change_action():
    var Inventories=$InventoryList.get_children()
    for Inventory in Inventories:
        if Inventory.Number+4*(CurrentPage-1)<=SequencedItem.size():
            Inventory.update_sprite(SequencedItem[4*(CurrentPage-1)+Inventory.Number-1],-1,true)
        elif Inventory.Number+4*(CurrentPage-1)<=SequencedItem.size()+SequencedWeapon.size():
            Inventory.update_sprite(Global.WeaponInHome[SequencedWeapon[4*(CurrentPage-1)+Inventory.Number-1-SequencedItem.size()]]["Name"],SequencedWeapon[4*(CurrentPage-1)+Inventory.Number-1-SequencedItem.size()],true)
        else:
            Inventory.update_sprite("null",-1,true)

func _input(event):
    if !FocusChangable:
        return
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        if InventoryFocused!=0 and InventoryChosen!=InventoryFocused:
            InventoryChosen=InventoryFocused
            $InventoryChosen.global_position=$InventoryList.get_node("Inventory"+String(InventoryChosen)).global_position
            $InventoryChosen.show()
            item_detail_change()
    elif event.is_action_pressed("ui_focus_next") and SequencedItem.size()+SequencedWeapon.size()>(CurrentPage-1)*4+12:
        CurrentPage+=1
        $ScrollBar/Bar.position.y+=122*$ScrollBar/Bar.scale.y/1.5
        page_change_action()
    elif event.is_action_pressed("ui_focus_prev") and CurrentPage>1:
        CurrentPage-=1
        $ScrollBar/Bar.position.y-=122*$ScrollBar/Bar.scale.y/1.5
        page_change_action()

func item_detail_change():
    if InventoryChosen==0 or 4*(CurrentPage-1)+InventoryChosen>SequencedItem.size()+SequencedWeapon.size():
        $ItemDetail.hide()
    elif 7*(CurrentPage-1)+InventoryChosen<=SequencedItem.size():
        $ItemDetail/ItemName.text=SequencedItem[4*(CurrentPage-1)+InventoryChosen-1]
        $ItemDetail/ItemType.text=ReferenceList.ItemRference[SequencedItem[4*(CurrentPage-1)+InventoryChosen-1]]["Type"]
        $ItemDetail/ItemDescription.text=ReferenceList.ItemRference[SequencedItem[4*(CurrentPage-1)+InventoryChosen-1]]["Description"]
        $ItemDetail.show()
    else:
        $ItemDetail/ItemName.text=Global.WeaponInHome[SequencedWeapon[4*(CurrentPage-1)+InventoryChosen-1-SequencedItem.size()]]["Name"]
        $ItemDetail/ItemType.text=ReferenceList.WeaponReference[Global.WeaponInHome[SequencedWeapon[4*(CurrentPage-1)+InventoryChosen-1-SequencedItem.size()]]["Name"]]["Type"]
        $ItemDetail/ItemDescription.text=ReferenceList.WeaponReference[Global.WeaponInHome[SequencedWeapon[4*(CurrentPage-1)+InventoryChosen-1-SequencedItem.size()]]["Name"]]["Description"]
        $ItemDetail/ItemDescription.text+="\n耐久："+String(Global.WeaponInHome[SequencedWeapon[4*(CurrentPage-1)+InventoryChosen-1-SequencedItem.size()]]["Durability"])+"/"
        $ItemDetail/ItemDescription.text+=String(ReferenceList.WeaponReference[Global.WeaponInHome[SequencedWeapon[4*(CurrentPage-1)+InventoryChosen-1-SequencedItem.size()]]["Name"]]["MaxDurability"])
        $ItemDetail.show()

        
func inventory_focus_get(Num:int):
    if !FocusChangable:
        return
    InventoryFocused=Num
    $InventoryFocused.global_position=$InventoryList.get_node("Inventory"+String(InventoryFocused)).global_position
    $InventoryFocused.show()

func inventory_focus_lose(Num:int):
    if !FocusChangable:
        return
    if InventoryFocused==Num:
        InventoryFocused=0
        $InventoryFocused.hide()


func _on_All_pressed():
    ItemType="All"
    update_items_in_home()


func _on_Weapon_pressed():
    ItemType="Weapon"
    update_items_in_home()


func _on_Medicine_pressed():
    ItemType="Medicine"
    update_items_in_home()


func _on_Bullet_pressed():
    ItemType="Bullet"
    update_items_in_home()


func _on_Other_pressed():
    ItemType="Other"
    update_items_in_home()


func _on_Resource_pressed():
    ItemType="Resource"
    update_items_in_home()


func _on_Drop_pressed():
    if !FocusChangable and !$ItemDetail/DropItemWindow.visible and !$ItemDetail/DropWeaponWindow.visible:
        return
    FocusChangable=false
    if 4*(CurrentPage-1)+InventoryChosen<=SequencedItem.size():
        $ItemDetail/DropItemWindow.init(Global.GoodInHome[SequencedItem[4*(CurrentPage-1)+InventoryChosen-1]])
        $ItemDetail/DropItemWindow.show()
    else:
        $ItemDetail/DropWeaponWindow.show()


func _on_DropItemWindow_DropItem():
    FocusChangable=true
    Global.GoodInHome[SequencedItem[4*(CurrentPage-1)+InventoryChosen-1]]-=$ItemDetail/DropItemWindow.DropNumber
    Global.update_pause_window()
    $ItemDetail/DropItemWindow.DropNumber=1
    $ItemDetail/DropItemWindow/LineEdit.text="1"


func _on_DropItemWindow_QuitDropItem():
    FocusChangable=true
    $ItemDetail/DropItemWindow.DropNumber=1
    $ItemDetail/DropItemWindow/LineEdit.text="1"


func _on_DropWeapon_OK():
    FocusChangable=true
    Global.WeaponInHome.remove(SequencedWeapon[4*(CurrentPage-1)+InventoryChosen-1-SequencedItem.size()])
    Global.update_pause_window()
    $ItemDetail/DropWeaponWindow.hide()


func _on_DropWeapon_Quit():
    FocusChangable=true
    $ItemDetail/DropWeaponWindow.hide()


func _on_AccessItemWindow_OK():
    FocusChangable=true
    var ItemName=SequencedItem[4*(CurrentPage-1)+InventoryChosen-1]
    Global.GoodInHome[ItemName]-=$ItemDetail/AccessItemWindow.DropNumber
    if Global.GoodInBackpack.get(ItemName)==null:
        Global.GoodInBackpack[ItemName]=$ItemDetail/AccessItemWindow.DropNumber
    else:
        Global.GoodInBackpack[ItemName]+=$ItemDetail/AccessItemWindow.DropNumber
    Global.update_pause_window()
    $ItemDetail/AccessItemWindow.DropNumber=1
    $ItemDetail/AccessItemWindow/LineEdit.text="1"


func _on_AccessItemWindow_QuitDropItem():
    FocusChangable=true
    $ItemDetail/AccessItemWindow.DropNumber=1
    $ItemDetail/AccessItemWindow/LineEdit.text="1"

func _on_MoveToBackpack_pressed():
    if !FocusChangable and !$ItemDetail/AccessItemWindow.visible and !$ItemDetail/AccessWeaponWindow.visible:
        return
    FocusChangable=false
    if 4*(CurrentPage-1)+InventoryChosen<=SequencedItem.size():
        $ItemDetail/AccessItemWindow.init(Global.GoodInHome[SequencedItem[4*(CurrentPage-1)+InventoryChosen-1]])
        $ItemDetail/AccessItemWindow.show()
    else:
        FocusChangable=true
        var WeaponNum=SequencedWeapon[4*(CurrentPage-1)+InventoryChosen-1-SequencedItem.size()]
        var WeaponInfo=Global.WeaponInHome[WeaponNum]
        Global.WeaponInHome.remove(WeaponNum)
        Global.WeaponInBackpack.push_back(WeaponInfo)
        Global.update_pause_window()
