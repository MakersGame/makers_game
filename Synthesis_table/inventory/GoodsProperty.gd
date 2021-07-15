## GoodsProperty
extends Resource


## 物品属性
const GoodsProperty = {
    Name = "goods_name",
    Number = 'goods_number'
}

signal goods_texture_changed(texture_)	# 物品贴图发生改变

export var goods_name = ""
export (Texture) var goods_texture setget set_goods_texture
export (String, MULTILINE) var goods_description


#------------------------------
#  setget
#------------------------------
## 设置物品的图片
func set_goods_texture(value: Texture):
    goods_texture = value
    emit_signal("goods_texture_changed", value)


## 返回物品的属性
func get_property() -> Dictionary:
    var property_list = GoodsProperty.values()	# 获取所有属性名
    var data = {}
    for property in property_list:
        var property_value = get(property)
        data[property] = property_value
    return data


## 设置物品的属性
func set_property(property_dict: Dictionary) -> void:
    for key in property_dict:
        var value = property_dict[key]
        set(key, value)

