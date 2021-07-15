## Goods
tool
extends CenterContainer


signal swaped_property(old_property, new_property)	# 交换属性信号
signal unload(property)	# 卸下物品


const GoodsProperty = preload("res://Synthesis_table/inventory/GoodsProperty.gd")

export (Resource) var goods_property setget set_goods_property


onready var texture_rect = $TextureRect

var drag_source


#------------------------------
#  setget
#------------------------------
export (Texture) var background setget set_background
onready var background_rect = $Background
func set_background(value):
    background = value
    if background_rect == null:
        yield(self, "ready")
    background_rect.texture = value


func set_goods_property(value):
    # texture_rect 为 null 时代表还没加载到场景中
    # 所以我们要 yield 等待当前节点发出 ready 信号
    # 当前节点 ready 后 texture_rect 在他之前加载了
    if texture_rect == null:
        # 当前节点发出 ready 信号后再继续执行后面的语句
        yield(self, "ready")
    
    if not value is GoodsProperty:
        goods_property = null
        texture_rect.texture = null
        return
    goods_property = value
    
    # 连接资源的 goods_texture_changed 信号
    # goods_texture_changed 信号附加有 texture
    # 连接到 texture_rect 的 set_texture 方法上
    # goods_texture 属性改变的时候，
    # 将会调用 texture_rect 的 set_texture 方法
    if not goods_property.is_connected("goods_texture_changed", texture_rect, "set_texture"):
        goods_property.connect("goods_texture_changed", texture_rect, "set_texture")
    texture_rect.texture = value.goods_texture



#------------------------------
#  节点带有的方法
#------------------------------
func get_drag_data(position: Vector2):
    var drag_node = self.duplicate()	# 复制一份当前的节点，用于拖拽显示
    drag_node.use_top_left = true	# 使图片居中，看起来自然
    drag_node.drag_source = self	# 复制用于拖拽的节点记录当前拖拽的源节点
    set_drag_preview(drag_node)		# 设置鼠标拖拽的节点
    drag_node.background_rect.visible = false
    return drag_node


func can_drop_data(position: Vector2, data) -> bool:
    # 判断能否放在这个节点上
    return data && data.get("goods_property")	# 有 goods_property 属性才能放下


func drop_data(position: Vector2, data) -> void:
    # 接收放下的节点数据
    swap_goods(self, data.drag_source)




#------------------------------
#  自定义方法
#------------------------------
## 交换两个物品
## (其实两个物品的属性都做成了资源，剩下节点都一样
## 这样我们只用交换一下资源属性就等于物品给替换了)
func swap_goods(a, b):
    # 交换物品信号
    a.emit_signal("swaped_property", a.goods_property, b.goods_property)
    b.emit_signal("swaped_property", b.goods_property, a.goods_property)
    
    # 卸下物品信号
    if a == null:
        b.emit_signal("unload", b.goods_property)
    if b == null:
        a.emit_signal("unload", a.goods_property)
    
    # 进行属性交换
    var p_temp = a.goods_property
    a.goods_property = b.goods_property
    b.goods_property = p_temp
