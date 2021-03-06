extends Node2D
#这是一个全局的实例，也是单例。它以及他的子节点进行一系列全局控制工作。
#全局任意代码段可以通过Global来访问此实例，调用全局函数。
var Root                                #场景根节点
var CurrentScene                        #当前场景，很明显只会存在一个（全局场景之外的）
var CurrentAreaBlock                    #当前加载区块
var PlayerAndNPCs=[]                    #当前中的玩家和NPC对象
var Team=[]                             #当前队伍中的玩家和NPC
var GameStatus:String                   #游戏状态
#不同状态对应的情况：（暂定）
#“MainMenu"：在主菜单界面
#“PlayerControl”：玩家控制中，可以自由移动
#“AnimationPlaying"：动画播放中，游戏暂停
#"Paused"：玩家暂停游戏
var HomeUpdateInfo:Dictionary={}
var GoodInHome:Dictionary={}            #家中的物品
var GoodInBackpack:Dictionary={}        #背包中的物品
var WeaponInHome:Array=[]               #家中的武器，每个元素为字典，记录名称和耐久
var WeaponInBackpack:Array=[]           #背包中的武器，每个元素为字典，记录名称和耐久
var QuickUseItem:Array=[null,null,null,null,null]   #快捷栏物品
var QuickUseItemChoice:int=0                        #选中的快捷栏物品
var InCraftTable = false

var WorldTime:Vector2=Vector2(6,0)
var TimePaused:bool=false

onready var PlayerCamera=$PlayerCamera  #游戏镜头对象实例
onready var SceneChanger=$PlayerCamera/SceneChanger
onready var OverworldUIs=$OverWorldUIs

func _ready():#游戏最开始会执行一次，之后就不会了
    randomize()
    Root=get_tree().get_root()
    CurrentScene=Root.get_child(Root.get_child_count() - 1)
    CurrentAreaBlock=CurrentScene.get_node("AreaBlocks/Home")
    GameStatus="PlayerControl"
    $PlayerCamera.current=true
    set_scnene_info()
    FileManager.load_data()
    
func _input(event):
    if event.is_action_pressed("ui_pause") && !InCraftTable:
        if GameStatus=="Paused":
            if $PauseWindow.visible:
                $PauseWindow.hide()
            elif $HomeUpdateWindow.visible:
                $HomeUpdateWindow.hide()
            elif $ItemAccess.visible:
                $ItemAccess.hide()
            get_tree().paused=false
            GameStatus="PlayerControl"
        elif GameStatus=="PlayerControl" and !$PauseWindow.visible:
            GameStatus="Paused"
            get_tree().paused=true
            $PauseWindow.show()
    if event.is_action_pressed("test_key"):
        if GameStatus=="Paused" and $ItemAccess.visible:
            get_tree().paused=false
            GameStatus="PlayerControl"
            $ItemAccess.hide()
        elif GameStatus=="PlayerControl" and !$ItemAccess.visible:
            GameStatus="Paused"
            get_tree().paused=true
            $ItemAccess.show()

func set_scnene_info():#在进入新场景的时候，记录场景中的所有玩家和NPC，供敌人查看
    PlayerAndNPCs=[]
    PlayerAndNPCs.push_back(CurrentScene.get_node("Player"))
    Team.push_back(CurrentScene.get_node("Player"))
    var NPCs=CurrentScene.get_node("NPCs").get_children()
    if NPCs!=null:
        PlayerAndNPCs+=CurrentScene.get_node("NPCs").get_children()
        for i in CurrentScene.get_node("NPCs").get_children():
            if i.InTeam:
                Team.push_back(i)
    
func set_navigation():#给所有生物初始化navigation，用于导航
    if CurrentAreaBlock!=null:
        if !CurrentAreaBlock.is_inside_tree():
            yield(CurrentAreaBlock,"ready")       
        get_tree().call_deferred("call_group","creature","set_navigation",CurrentAreaBlock.navigation)
    else:

        get_tree().call_deferred("call_group","creature","set_navigation",null)
    
func detect_collision_in_line(Pos1:Vector2,Pos2:Vector2,Ignore:Array,CollisionMask:int):
    #将探测射线功能封装，便于调用，参数Ignore为碰撞检测中忽略的对象数组
    var space_state = get_world_2d().direct_space_state#获取2D空间，准备发射碰撞检测射线
    var collision=space_state.intersect_ray(Pos1,Pos2,Ignore, CollisionMask)
    return collision

func change_scene(path):#切换场景
    SceneChanger.get_node("ColorRect").show()
    SceneChanger.get_node("AnimationPlayer").play("scenechange")
    yield(SceneChanger.get_node("AnimationPlayer"), "animation_finished")
    CurrentScene.queue_free()
    var NextScene=load(path).instance()
    CurrentScene=NextScene
    if CurrentScene.Identifier=="BattleScene":
        set_scnene_info()
    Root.add_child(NextScene)
    SceneChanger.get_node("AnimationPlayer").play_backwards("scenechange")
    yield(SceneChanger.get_node("AnimationPlayer"), "animation_finished")
    SceneChanger.get_node("ColorRect").hide()

## 用于打开合成面板
#func open_synthesis():
#    InCraftTable = true
#    get_tree().paused=true
#    var SynthesisTablePanel=preload("res://Synthesis_table/VirtualNodeForCrafting.tscn").instance()
#    var middle_position=Global.PlayerCamera.global_position
#    SynthesisTablePanel.set_global_position(Vector2(middle_position.x - 450, middle_position.y - 250))
#    CurrentScene.add_child(SynthesisTablePanel)
#
## 关闭合成面板
#func close_synthesis():
#    CurrentScene.get_node("VirtualNodeForCrafting").queue_free()
#    get_tree().paused=false
#    InCraftTable = false

func open_home_update():
    if GameStatus=="PlayerControl":
        GameStatus="Paused"
        get_tree().paused=true
        $HomeUpdateWindow.show()

func update_pause_window():
    $PauseWindow/Backpack.update_items_in_backpack()
    $PauseWindow/TeamInfo.update_team() 
    $OverWorldUIs.set_ui()   
    $ItemAccess.update_items()
    $HomeUpdateWindow.refresh_update_window()

func send_message(Message:String):
    OverworldUIs.send_message(Message)

func area_block_change(area):
    if area==null:
        for i in PlayerAndNPCs:
            i.update_area_center(null)
        CurrentAreaBlock=null
    else:
        for i in PlayerAndNPCs:
            i.update_area_center(area.global_position)
        CurrentAreaBlock=area
    set_navigation()

func _on_WorldTimer_timeout():
    if TimePaused:
        return
    WorldTime.y+=10
    if WorldTime.y>=60:
        WorldTime.y-=60
        WorldTime.x+=1
    OverworldUIs.update_clock()
    
