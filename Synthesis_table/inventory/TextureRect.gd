extends TextureRect



## 鼠标指上去显示数据
func _make_custom_tooltip(for_text):
    if get_parent().goods_property:
        var label = Label.new()
        var goods_data = get_parent().goods_property.get_property()	# 物品数据
        label.text = JSON.print(goods_data, '\t')
        return label
    return null
