extends Node2D

var SequencedItem=[]            #背包中的物品，按编号排序，仅储存名称
var CurrentPage=1               #当前背包第一行是所有物品的第几行
var InventoryChosen:int=0       #选中的物品栏
var InventoryFocused:int=0      #鼠标聚焦的物品栏（可能没有选中） 
var LoadValue:float             #当前负重
var LoadLimit:float             #负重上限

func _ready():
    $InventoryChosen.hide()
    $InventoryFocused.hide()
    $ItemDetail.hide()
    update_items_in_backpack()

func update_items_in_backpack():
    LoadLimit=0
    LoadValue=0
    for i in Global.PlayerAndNPCs:
        LoadLimit+=i.LoadLimit
    CurrentPage=1
    SequencedItem=[]
    for key in Global.GoodInBackpack.keys():
        if Global.GoodInBackpack[key]>0:
            SequencedItem.push_back(key)
            LoadValue+=Global.GoodInBackpack[key]*ReferenceList.ItemRference[key]["Weight"]
    $LoadValue.text="负重值："+String(LoadValue)+"/"+String(LoadLimit)
    for i in range(SequencedItem.size()):
        for j in range(SequencedItem.size()-1):
            if ReferenceList.ItemRference[SequencedItem[j]]["ID"]>ReferenceList.ItemRference[SequencedItem[j+1]]["ID"]:
                var temp=SequencedItem[j]
                SequencedItem[j]=SequencedItem[j+1]
                SequencedItem[j+1]=temp    
    var Inventories=$InventoryList.get_children()
    page_change_action()
    if SequencedItem.size()>21:
        $ScrollBar/Bar.scale.y=3/ceil(SequencedItem.size()/7)
    else:
        $ScrollBar/Bar.scale.y=1
    $ScrollBar/Bar.position.y=-122
    

func page_change_action():
    var Inventories=$InventoryList.get_children()
    for Inventory in Inventories:
        if Inventory.Number+7*(CurrentPage-1)<=SequencedItem.size():
            Inventory.update_sprite(SequencedItem[7*(CurrentPage-1)+Inventory.Number-1])
        else:
            Inventory.update_sprite("null")

func _input(event):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        if InventoryFocused!=0 and InventoryChosen!=InventoryFocused:
            InventoryChosen=InventoryFocused
            $InventoryChosen.global_position=$InventoryList.get_node("Inventory"+String(InventoryChosen)).global_position
            $InventoryChosen.show()
            item_detail_change()
    elif event.is_action_pressed("ui_focus_next") and SequencedItem.size()>(CurrentPage-1)*7+21:
        CurrentPage+=1
        $ScrollBar/Bar.position.y+=122*$ScrollBar/Bar.scale.y/3
        page_change_action()
    elif event.is_action_pressed("ui_focus_prev") and CurrentPage>1:
        CurrentPage-=1
        $ScrollBar/Bar.position.y-=122*$ScrollBar/Bar.scale.y/3
        page_change_action()

func item_detail_change():
    if 12*(CurrentPage-1)+InventoryChosen>SequencedItem.size():
        $ItemDetail.hide()
    else:
        $ItemDetail/ItemName.text=SequencedItem[7*(CurrentPage-1)+InventoryChosen-1]
        $ItemDetail/ItemType.text=ReferenceList.ItemRference[SequencedItem[7*(CurrentPage-1)+InventoryChosen-1]]["Type"]
        $ItemDetail/ItemDescription.text=ReferenceList.ItemRference[SequencedItem[7*(CurrentPage-1)+InventoryChosen-1]]["Description"]
        $ItemDetail.show()
        
func inventory_focus_get(Num:int):
    InventoryFocused=Num
    $InventoryFocused.global_position=$InventoryList.get_node("Inventory"+String(InventoryFocused)).global_position
    $InventoryFocused.show()

func inventory_focus_lose(Num:int):
    if InventoryFocused==Num:
        InventoryFocused=0
        $InventoryFocused.hide()

func _on_Use_pressed():
    pass #使用物品

func _on_Drop_pressed():
    pass # Replace with function body.

func _on_QuickUse_pressed():
    pass # Replace with function body.
