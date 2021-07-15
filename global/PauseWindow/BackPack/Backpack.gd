extends Node2D

var SequencedItem=[]            #背包中的物品，按编号排序，仅储存名称
var CurrentPage=1               #当前背包在第几页
var InventoryChosen:int=0       #选中的物品栏
var InventoryFocused:int=0      #鼠标聚焦的物品栏（可能没有选中） 

func _ready():
    $InventoryChosen.hide()
    $InventoryFocused.hide()
    $ItemDetail.hide()
    $Buttons/Use.hide()
    update_items_in_backpack()

func update_items_in_backpack():
    SequencedItem=[]
    for key in Global.GoodInBackpack.keys():
        if Global.GoodInBackpack[key]>0:
            SequencedItem.push_back(key)
    for i in range(SequencedItem.size()):
        for j in range(SequencedItem.size()-1):
            if ReferenceList.ItemRference[SequencedItem[j]]["ID"]>ReferenceList.ItemRference[SequencedItem[j+1]]["ID"]:
                var temp=SequencedItem[j]
                SequencedItem[j]=SequencedItem[j+1]
                SequencedItem[j+1]=temp    
    var Inventories=$InventoryList.get_children()
    for Inventory in Inventories:
        if Inventory.Number<=SequencedItem.size():
            Inventory.update_sprite(SequencedItem[12*(CurrentPage-1)+Inventory.Number-1])
        else:
            Inventory.update_sprite("null")
    while (CurrentPage-1)*12>SequencedItem.size():
        CurrentPage-=1
    if CurrentPage==1:
        $Buttons/PreviousPage.hide()
    else:
        $Buttons/PreviousPage.show()
    if SequencedItem.size()>(CurrentPage-1)*12:
        $Buttons/NextPage.hide()
    else:
        $Buttons/NextPage.show()

func _input(event):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        if InventoryFocused!=0 and InventoryChosen!=InventoryFocused:
            InventoryChosen=InventoryFocused
            $InventoryChosen.global_position=$InventoryList.get_node("Inventory"+String(InventoryChosen)).global_position
            $InventoryChosen.show()
            item_detail_change()

func item_detail_change():
    if 12*(CurrentPage-1)+InventoryChosen>SequencedItem.size():
        $ItemDetail.hide()
    else:
        $ItemDetail/ItemName.text=SequencedItem[12*(CurrentPage-1)+InventoryChosen-1]
        $ItemDetail/ItemDescription.text=ReferenceList.ItemRference[SequencedItem[12*(CurrentPage-1)+InventoryChosen-1]]["Description"]
        $ItemDetail/ItemSprite.animation=SequencedItem[12*(CurrentPage-1)+InventoryChosen-1]
        if ReferenceList.ItemRference[SequencedItem[12*(CurrentPage-1)+InventoryChosen-1]]["Usable"]:
            $Buttons/Use.show()
        else:
            $Buttons/Use.hide()
        $ItemDetail.show()
        
func inventory_focus_get(Num:int):
    InventoryFocused=Num
    $InventoryFocused.global_position=$InventoryList.get_node("Inventory"+String(InventoryFocused)).global_position
    $InventoryFocused.show()

func inventory_focus_lose(Num:int):
    if InventoryFocused==Num:
        InventoryFocused=0
        $InventoryFocused.hide()

func _on_PreviousPage_pressed():
    CurrentPage-=1

func _on_NextPage_pressed():
    CurrentPage+=1


func _on_Use_pressed():
    pass #使用物品
