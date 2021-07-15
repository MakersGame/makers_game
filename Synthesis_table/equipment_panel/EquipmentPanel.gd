## Equipment Panel
## 装备面板
extends Panel


signal property_changed(old_value, new_value)	# 属性发生改变信号


const GoodsProperty = preload("res://Synthesis_table/inventory/GoodsProperty.gd")
const Goods = preload("res://Synthesis_table/inventory/Goods.gd")


## 所有物品属性总和
var all_property := {}


#------------------------------
#  Set/Get
#------------------------------
func set_data_list(data_list: Array):
    for data in data_list:
        # 获取是哪个节点上的物品
        var node_name = data['id']
        var goods = get_node(node_name) as Goods
        
        # 设置物品资源属性
        var goods_property = GoodsProperty.new()
        goods_property.set_property(data)
        
        # 设置属性到物品上
        goods.set_goods_property(goods_property)
        
        # 装备属性发生改变
        change_property(goods_property, true)


func get_data_list() -> Array:
    var data_list = []
    return data_list



#------------------------------
#  节点带有的方法
#------------------------------
func _init() -> void:
    var temp_goods_property = GoodsProperty.new()	# 临时属性，用于获取变量判断类型
    var GoodsPropertyList = GoodsProperty.GoodsProperty	# 属性列表，用于获取变量名
    
    ## 以下是为了先将需要的属性记录到 all_property 字典中，方便计算
    for property in GoodsPropertyList.values():
        var value = temp_goods_property.get(property)	# 属性值
        var property_type = typeof(value)	# 属性类型
        
        # 如果是 int 类型，或是 float 类型则记录到 all_property 中
        if property_type == TYPE_INT: 	# int 类型
            all_property[property] = 0
        elif property_type == TYPE_REAL:	# float 类型
            all_property[property] = 0.0


func _ready() -> void:
    # 连接物品信号
    for goods in get_children():
        goods.connect("swaped_property", self, "_on_Goods_swaped_property")
        goods.connect("unload", self, "_on_Goods_unload")



#------------------------------
#  自定义方法
#------------------------------
## 改变属性
## @property 物品属性
## @is_add 是否增加，如果为 false 则为减去
func change_property(goods_property: GoodsProperty, is_add: bool):
    var temp_all_property = all_property.duplicate(true)
    
    # 加上
    if is_add:
        for property in all_property.keys():
            var value = goods_property.get(property)
            all_property[property] += value
    # 减去
    else:
        for property in all_property.keys():
            var value = goods_property.get(property)
            all_property[property] -= value
    
    emit_signal("property_changed", temp_all_property, all_property)



#------------------------------
#  连接信号
#------------------------------
func _on_Goods_swaped_property(old_property, new_property) -> void:
    if old_property != null:
        change_property(old_property, false)	# 减去旧属性
        print("换掉物品：", old_property.goods_name)
    
    if new_property != null:
        change_property(new_property, true)		# 加上新属性
        print("装备物品：", new_property.goods_name)


func _on_Goods_unload(property) -> void:
    change_property(property, false)	# 减去属性
    print("卸下物品：", property.goods_name)
