extends Node2D

var SequencedItem=[]            #背包中的物品，按编号排序，仅储存名称
var SequencedWeapon=[]          #背包中的武器，按编号和耐久排序，储存在Global.WeaponInPacket中的下标
var CurrentPage=1               #当前背包第一行是所有物品的第几行
var InventoryChosen:int=0       #选中的物品栏
var InventoryFocused:int=0      #鼠标聚焦的物品栏（可能没有选中） 
var LoadValue:float             #当前负重
var LoadLimit:float             #负重上限
var FocusChangable:bool=true

func _ready():
    $InventoryChosen.hide()
    $InventoryFocused.hide()
    $ItemDetail.hide()
    $DropItemWindow.hide()
    $QuickUseItem.hide()
    $DropWeaponWindow.hide()
    #update_items_in_backpack()

func update_items_in_backpack():
    LoadLimit=0
    LoadValue=0
    for i in Global.PlayerAndNPCs:
        LoadLimit+=i.LoadLimit
    CurrentPage=1
    SequencedItem=[]
    SequencedWeapon=[]
    for key in Global.GoodInBackpack.keys():
        if Global.GoodInBackpack[key]>0:
            SequencedItem.push_back(key)
            LoadValue+=Global.GoodInBackpack[key]*ReferenceList.ItemRference[key]["Weight"]
    for i in range(Global.WeaponInBackpack.size()):
        SequencedWeapon.push_back(i)
        LoadValue+=ReferenceList.WeaponReference[Global.WeaponInBackpack[i]["Name"]]["Weight"]
    $LoadValue.text="负重值："+String(LoadValue)+"/"+String(LoadLimit)
    for i in range(SequencedItem.size()):
        for j in range(SequencedItem.size()-1):
            if ReferenceList.ItemRference[SequencedItem[j]]["ID"]>ReferenceList.ItemRference[SequencedItem[j+1]]["ID"]:
                var temp=SequencedItem[j]
                SequencedItem[j]=SequencedItem[j+1]
                SequencedItem[j+1]=temp   
    for i in range(SequencedWeapon.size()):
        for j in range(SequencedWeapon.size()-1):
            var ID1:int=ReferenceList.WeaponReference[Global.WeaponInBackpack[SequencedWeapon[j]]["Name"]]["ID"]
            var ID2:int=ReferenceList.WeaponReference[Global.WeaponInBackpack[SequencedWeapon[j+1]]["Name"]]["ID"]
            var Durability1=Global.WeaponInBackpack[SequencedWeapon[j]]["Durability"]
            var Durability2=Global.WeaponInBackpack[SequencedWeapon[j+1]]["Durability"]
            if ID1>ID2 or (ID1==ID2 and Durability1>Durability2):
                var temp=SequencedWeapon[j]
                SequencedWeapon[j]=SequencedWeapon[j+1]
                SequencedWeapon[j+1]=temp
                  
    var Inventories=$InventoryList.get_children()
    page_change_action()
    if SequencedItem.size()+SequencedWeapon.size()>21:
        $ScrollBar/Bar.scale.y=3/ceil(float((SequencedItem.size()+SequencedWeapon.size()))/7)
    else:
        $ScrollBar/Bar.scale.y=1
    $ScrollBar/Bar.position.y=-122
    
    item_detail_change()
    
    $QuickUseItem.update_quick_use_item()
    $QuickUseItem.hide()
    FocusChangable=true
    $ItemDetail/Buttons/Drop.mouse_filter=Control.MOUSE_FILTER_PASS

func page_change_action():
    var Inventories=$InventoryList.get_children()
    for Inventory in Inventories:
        if Inventory.Number+7*(CurrentPage-1)<=SequencedItem.size():
            Inventory.update_sprite(SequencedItem[7*(CurrentPage-1)+Inventory.Number-1],-1)
        elif Inventory.Number+7*(CurrentPage-1)<=SequencedItem.size()+SequencedWeapon.size():
            Inventory.update_sprite(Global.WeaponInBackpack[SequencedWeapon[7*(CurrentPage-1)+Inventory.Number-1-SequencedItem.size()]]["Name"],SequencedWeapon[7*(CurrentPage-1)+Inventory.Number-1-SequencedItem.size()])
        else:
            Inventory.update_sprite("null",-1)

func _input(event):
    if !FocusChangable:
        return
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        if InventoryFocused!=0 and InventoryChosen!=InventoryFocused:
            InventoryChosen=InventoryFocused
            $InventoryChosen.global_position=$InventoryList.get_node("Inventory"+String(InventoryChosen)).global_position
            $InventoryChosen.show()
            item_detail_change()
    elif event.is_action_pressed("ui_focus_next") and SequencedItem.size()+SequencedWeapon.size()>(CurrentPage-1)*7+21:
        CurrentPage+=1
        $ScrollBar/Bar.position.y+=122*$ScrollBar/Bar.scale.y/1.5
        page_change_action()
    elif event.is_action_pressed("ui_focus_prev") and CurrentPage>1:
        CurrentPage-=1
        $ScrollBar/Bar.position.y-=122*$ScrollBar/Bar.scale.y/1.5
        page_change_action()

func item_detail_change():
    if InventoryChosen==0 or 7*(CurrentPage-1)+InventoryChosen>SequencedItem.size()+SequencedWeapon.size():
        $ItemDetail.hide()
    elif 7*(CurrentPage-1)+InventoryChosen<=SequencedItem.size():
        $ItemDetail/ItemName.text=SequencedItem[7*(CurrentPage-1)+InventoryChosen-1]
        $ItemDetail/ItemType.text=ReferenceList.ItemRference[SequencedItem[7*(CurrentPage-1)+InventoryChosen-1]]["Type"]
        $ItemDetail/ItemDescription.text=ReferenceList.ItemRference[SequencedItem[7*(CurrentPage-1)+InventoryChosen-1]]["Description"]
        $ItemDetail.show()
        if ReferenceList.ItemRference[SequencedItem[7*(CurrentPage-1)+InventoryChosen-1]]["Usable"]:
            $ItemDetail/Buttons/Use.show()
            $ItemDetail/Buttons/QuickUse.show()
        else:
            $ItemDetail/Buttons/Use.hide()
            $ItemDetail/Buttons/QuickUse.hide()
    else:
        $ItemDetail/ItemName.text=Global.WeaponInBackpack[SequencedWeapon[7*(CurrentPage-1)+InventoryChosen-1-SequencedItem.size()]]["Name"]
        $ItemDetail/ItemType.text=ReferenceList.WeaponReference[Global.WeaponInBackpack[SequencedWeapon[7*(CurrentPage-1)+InventoryChosen-1-SequencedItem.size()]]["Name"]]["Type"]
        $ItemDetail/ItemDescription.text=ReferenceList.WeaponReference[Global.WeaponInBackpack[SequencedWeapon[7*(CurrentPage-1)+InventoryChosen-1-SequencedItem.size()]]["Name"]]["Description"]
        $ItemDetail/ItemDescription.text+="\n耐久："+String(Global.WeaponInBackpack[SequencedWeapon[7*(CurrentPage-1)+InventoryChosen-1-SequencedItem.size()]]["Durability"])+"/"
        $ItemDetail/ItemDescription.text+=String(ReferenceList.WeaponReference[Global.WeaponInBackpack[SequencedWeapon[7*(CurrentPage-1)+InventoryChosen-1-SequencedItem.size()]]["Name"]]["MaxDurability"])
        $ItemDetail.show()
        $ItemDetail/Buttons/Use.hide()
        $ItemDetail/Buttons/QuickUse.hide()
        
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

func reset_quick_use_item(num):
    var ItemNumber=7*(CurrentPage-1)+InventoryChosen
    if SequencedItem.size()<ItemNumber or !ReferenceList.ItemRference[SequencedItem[ItemNumber-1]]["Usable"]:
        return
    for i in range(5):
        if Global.QuickUseItem[i]==SequencedItem[ItemNumber-1]:
            Global.QuickUseItem[i]=null
    Global.QuickUseItem[num]=SequencedItem[ItemNumber-1]
    Global.update_pause_window()
    

func _on_Use_pressed():
    if !FocusChangable:
        return
    if ReferenceList.ItemRference[SequencedItem[7*(CurrentPage-1)+InventoryChosen-1]]["Usable"]:
        ReferenceList.use_item(Global.PlayerAndNPCs[0],SequencedItem[7*(CurrentPage-1)+InventoryChosen-1])
    
func _on_Drop_pressed():
    if !FocusChangable and !$DropItemWindow.visible:
        return
    FocusChangable=false
    if 7*(CurrentPage-1)+InventoryChosen<=SequencedItem.size():
        $DropItemWindow.init(Global.GoodInBackpack[SequencedItem[7*(CurrentPage-1)+InventoryChosen-1]])
        $DropItemWindow.show()
    else:
        $DropWeaponWindow.show()

func _on_QuickUse_pressed():
    if !FocusChangable and !$QuickUseItem.visible:
        return
    if !$QuickUseItem.visible:
        $QuickUseItem.show()
        FocusChangable=false
        $ItemDetail/Buttons/Drop.mouse_filter=Control.MOUSE_FILTER_IGNORE
    else:
        $QuickUseItem.hide()
        FocusChangable=true
        $ItemDetail/Buttons/Drop.mouse_filter=Control.MOUSE_FILTER_PASS

func _on_DropItemWindow_DropItem():
    FocusChangable=true
    Global.GoodInBackpack[SequencedItem[7*(CurrentPage-1)+InventoryChosen-1]]-=$DropItemWindow.DropNumber
    Global.update_pause_window()
    $DropItemWindow.DropNumber=1
    $DropItemWindow/LineEdit.text="1"


func _on_DropItemWindow_QuitDropItem():
    FocusChangable=true
    $DropItemWindow.DropNumber=1
    $DropItemWindow/LineEdit.text="1"


func _on_DropWeapon_OKbutton_pressed():
    FocusChangable=true
    Global.WeaponInBackpack.remove(SequencedWeapon[7*(CurrentPage-1)+InventoryChosen-1-SequencedItem.size()])
    Global.update_pause_window()
    $DropWeaponWindow.hide()

func _on_DropWeapon_QuitButton_pressed():
    FocusChangable=true
    $DropWeaponWindow.hide()
