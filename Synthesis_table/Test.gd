## Test
## 测试物品场景
extends PanelContainer

# 存放数据的路径
const DataPath = "res://Synthesis_table/data/"
# 物品数据路径
const InventoryDataPath = DataPath + "InventoryGoodsData"
# 装备物品路径
const EquipmentDataPath = DataPath + "EquipmentGoodsData"
# 属性列表
const PropertyList = preload("res://Synthesis_table/inventory/GoodsProperty.gd").GoodsProperty

onready var property_label = $HBoxContainer/VBoxContainer/PropertyLabel
onready var equip_panel = $HBoxContainer/EquipmentPanel
onready var inventory = $HBoxContainer/VBoxContainer/Inventory


#------------------------------
#  节点带有的方法
#------------------------------
func _ready() -> void:
    load_inventory_data()
    
    ## 添加几个空物品，装备栏有几个物品，物品栏添加几个空物品
    for i in range(equip_panel.get_data_list().size()):
        inventory.add_empty_goods()



#------------------------------
#  自定义方法
#------------------------------
## 格式化数据转为 text
func format_data_to_text(data) -> String:
    var text = ""
    for key in data:
        text += key + ": " + str(data[key]) + "\n"
    return text


## 加载物品数据
func load_inventory_data():
    # 如果有数据，则加载数据
#    if not FileManager.exists_file(InventoryDataPath):
#        # 加载文件数据
#        var data_list = FileManager.load_data(InventoryDataPath)
#        # 图片数据无法保存，所以需要重新通过名称获取物品的图片
#        #for data in data_list:
#        #    data[PropertyList.Texture] = GoodsFactory.get_goods_texture(data[PropertyList.Name])
#        # 设置物品栏物品的数据
#        inventory.set_goods_data_list(data_list)
#    else:
#        inventory.add_goods("木材")
#        inventory.add_goods("药水")
    pass






#------------------------------
#  连接信号
#------------------------------
func _on_EquipmentPanel_property_changed(old_value, new_value) -> void:
    # 显示装备栏里的属性这里你也可以自己写属性发生改变时，
    # 对角色属性的进行修改的语句，这里我就不再写了。
    property_label.text = format_data_to_text(new_value)


func _on_Test_tree_exited():
    ## 获取物品栏的数据并保存
    var inv_data_list = inventory.get_goods_data_list()
    FileManager.save_data(InventoryDataPath, inv_data_list)
    
    ## 获取装备栏的数据并保存
    var equ_data_list = equip_panel.get_data_list()
    FileManager.save_data(EquipmentDataPath, equ_data_list)

