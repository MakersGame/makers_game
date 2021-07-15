## Inventory
extends PanelContainer


## 物品属性
const GoodsProperty = preload("res://Synthesis_table/inventory/GoodsProperty.gd")
## 物品节点
const ScnGoods = preload("res://Synthesis_table/inventory/Goods.tscn")


onready var grid = $Margin/Grid


#------------------------------
#  Set/Get
#------------------------------
## 设置物品数据列表
func set_goods_data_list(data_list: Array) -> void:
    for data in data_list:
        var goods_property = GoodsProperty.new()
        goods_property.set_property(data)
        
        var goods = ScnGoods.instance()
        goods.set_goods_property(goods_property)
        grid.add_child(goods)


## 返回物品数据列表
func get_goods_data_list() -> Array:
    var data_list = []
    for goods in grid.get_children():
        var goods_property = goods.goods_property	# 物品资源属性
        # 如果物品的资源属性不为 null
        if goods_property:
            var goods_data = goods_property.get_property()	# 属性数据
            
            data_list.push_back(goods_data)
    return data_list



#------------------------------
#  自定义方法
#------------------------------
## 添加物品
## @item_name 物品名称
func add_goods(item_name: String):
#    var goods s= GoodsFactory.get_goods(item_name)
#    if goods:
#        grid.add_child(goods)
    pass


## 添加一个空物品
func add_empty_goods():
    var goods = ScnGoods.instance()
    grid.add_child(goods)


