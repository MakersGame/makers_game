extends Panel
signal ClosePanel

func _on_close_pressed():
    emit_signal("ClosePanel")
    pass # Replace with function body.

var SequencedItem=[]            #背包中的物品，按编号排序，仅储存名称
var CurrentPage=1               #当前背包在第几页
var InventoryChosen:int=0       #选中的物品栏
var InventoryFocused:int=0      #鼠标聚焦的物品栏（可能没有选中） 
var CraftList = {
    "木材":{
        "木材":1,
        },
    "9mm子弹":{
        "木材":500,
       }
   }

func _ready():
    $InventoryChosen.hide()
    $InventoryFocused.hide()
    $ItemDetail.hide()
    $Buttons/Craft.hide()
    $Buttons/CannotCraft.hide()
    update_items_in_backpack()

func update_items_in_backpack():
    SequencedItem=[]
    for key in CraftList.keys():
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
            Inventory.update_sprite(SequencedItem[9*(CurrentPage-1)+Inventory.Number-1],-1)
        else:
            Inventory.update_sprite("null",-1)
    while (CurrentPage-1)*9>SequencedItem.size():
        CurrentPage-=1
    if CurrentPage==1:
        $Buttons/PreviousPage.hide()
    else:
        $Buttons/PreviousPage.show()
    if SequencedItem.size()>(CurrentPage-1)*9:
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
    if 9*(CurrentPage-1)+InventoryChosen>SequencedItem.size():
        $ItemDetail.hide()
    else:
        $ItemDetail/ItemName.text=SequencedItem[9*(CurrentPage-1)+InventoryChosen-1]
        update_Inf()
        $ItemDetail/ItemSprite.animation=SequencedItem[9*(CurrentPage-1)+InventoryChosen-1]
        $ItemDetail.show()
        
        
func good_whether_enough(GoodList, NeedNumber):
    for x in GoodList:
        if Global.GoodInHome.has(x) == false || Global.GoodInHome[x] < NeedNumber[x]:
            return false
    return true
    pass
    


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



func _on_Craft_pressed():
    print(InventoryChosen)
    for keys in CraftList[SequencedItem[9*(CurrentPage-1)+InventoryChosen-1]].keys():
        Global.GoodInHome[keys] -= CraftList[SequencedItem[9*(CurrentPage-1)+InventoryChosen-1]][keys]
        print(Global.GoodInHome[keys],keys)
    update_Inf()
    pass # Replace with function body.

func update_Inf():
    var string = ""
    var GoodList = []
    var NeedNumber = {}
    for keys in CraftList[SequencedItem[9*(CurrentPage-1)+InventoryChosen-1]].keys():
        var item = CraftList[SequencedItem[9*(CurrentPage-1)+InventoryChosen-1]][keys]
        GoodList.push_back(keys)
        NeedNumber[keys] = item
        var GoodHomeHave = Global.GoodInHome[keys]
        string = string +keys + ':' + String(item) + ' / ' + String(GoodHomeHave) + "\n"
    $ItemDetail/ItemNeed.text = string
    if good_whether_enough(GoodList, NeedNumber):
        $Buttons/Craft.show()
        $Buttons/CannotCraft.hide()
    else:
        $Buttons/Craft.hide()
        $Buttons/CannotCraft.show()
