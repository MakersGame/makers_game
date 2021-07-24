extends KinematicBody2D

var Identifier="Player"
var Name="玩家"                              #之后再说
var Speed:float                             #即creature_status中的Speed[SpeedType]
var Energy:float                            #精力值
var MaxEnergy:float                         #精力值上限
var SpeedUp:bool=false                      #是否加速跑
var TiredOut:bool=false                     #是否力竭
var KeyboardPressState:Array=[0,0,0,0]      #运动方向按键情况
var PlayerMoveState:Vector2=Vector2()       #当前运动向量
var FaceDirection:Vector2                   #面朝方向，即鼠标方向
var LoadLimit:float                         #主角的最大负重值
var KnockBack:Vector3                       #被击退值，三维向量，xy表示方向，z表示剩余击退距离，每一帧击退距离呈二次函数
var WeaponChoice:String                     #"ranged"或"melee"，代表当前选中远程或近战武器

var CurrentAreaCenter                       #当前区块中心，决定玩家图层
var E_Actions=[]

onready var CreatureStatus=$creature_status
onready var RangedWeapon=$RangedWeapon
onready var MeleeWeapon=$MeleeWeapon

func _ready():#暂时留着，之后会被init取代
    Energy=100
    MaxEnergy=100
    LoadLimit=50
    CreatureStatus.init(100,100,1,[3,5,5],"Player",$CollisionShape2D,[1,1,1,1])
    RangedWeapon.init("9mm手枪",-1,self,CreatureStatus.Ability["ranged_damage"],1,1)
    RangedWeapon.set_bullet_num()
    MeleeWeapon.init("马桶橛子",-1,self,CreatureStatus.Ability["melee_damage"],1)
    WeaponChoice="melee"
    MeleeWeapon.show()
    RangedWeapon.hide()
    $ChangeWeaponTimer.wait_time=0.1

func init():
    Energy=100
    MaxEnergy=100
    LoadLimit=50
    CreatureStatus.init(100,100,1,[5,5,5],"Player",$CollisionShape2D,[1,1,1,1])
    RangedWeapon.init("test_ranged_weapon",-1,self,CreatureStatus.Ability["ranged_damage"],1,1)
    RangedWeapon.set_bullet_num(200)
    MeleeWeapon.init("test_melee_weapon",-1,self,CreatureStatus.Ability["melee_damage"],1)
    $ChangeWeaponTimer.wait_time=0.1

func change_weapon(Type:String,NumInBackpack:int):
    if Type=="RangedWeapon":
        if RangedWeapon.BulletNum>0:
            if Global.GoodInBackpack.get(RangedWeapon.BulletType)==null:
                Global.GoodInBackpack[RangedWeapon.BulletType]=RangedWeapon.BulletNum
            else:
                Global.GoodInBackpack[RangedWeapon.BulletType]+=RangedWeapon.BulletNum
        RangedWeapon.get_node("ReloadTimer").stop()
        Global.OverworldUIs.get_node("WeaponChoice/RangedWeapon/ReloadBar").hide()
    if NumInBackpack<0 and Type!="null":
        get_node(Type).Enable=false
        return
    if Type=="MeleeWeapon":
        MeleeWeapon.init(Global.WeaponInBackpack[NumInBackpack]["Name"],Global.WeaponInBackpack[NumInBackpack]["Durability"],self,CreatureStatus.Ability["melee_damage"],1)
    elif Type=="RangedWeapon":
        RangedWeapon.init(Global.WeaponInBackpack[NumInBackpack]["Name"],Global.WeaponInBackpack[NumInBackpack]["Durability"],self,CreatureStatus.Ability["ranged_damage"],1,1)    
    get_node(Type).Enable=true

func update_area_center(Pos):
    if Pos==null:
        CurrentAreaCenter=null
    else:
        CurrentAreaCenter=Pos

func _physics_process(delta):
    
    if CurrentAreaCenter==null:
        z_index=100
    else:
        z_index=floor(((global_position-CurrentAreaCenter).y)/20)+3
    
    Global.PlayerCamera.set_camera(global_position)
    Speed=CreatureStatus.Speed[CreatureStatus.SpeedType]
    direction_action()
    energy_recover()
    move()
    Global.OverworldUIs.update_energy(Energy)
    animation_function()
    
    action_ui_function()

func _input(event):
    if Global.GameStatus!="PlayerControl":
        return
    if event is InputEventMouseMotion or (event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed):
        FaceDirection=(event.global_position+Global.PlayerCamera.global_position-Vector2(640,360)-global_position).normalized()
        RangedWeapon.TargetPosition=event.global_position+Global.PlayerCamera.global_position-Vector2(640,360)
        MeleeWeapon.Direction=FaceDirection
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        #按下鼠标左键，使用当前武器攻击
        if WeaponChoice=="ranged" and RangedWeapon.Enable:
            RangedWeapon.ForceDirection=Vector2()
            RangedWeapon.direction_function()
            RangedWeapon.Shooting=true
            RangedWeapon.shoot()
            Global.send_message("Ranged Weapon Attack!")
        elif WeaponChoice=="melee":
            if !TiredOut and MeleeWeapon.Enable and MeleeWeapon.Attackable:
                MeleeWeapon.attack()
                Global.send_message("Melee Weapon Attack!")
                energy_consume(MeleeWeapon.EnergyNeed)
    elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed:
        if WeaponChoice=="ranged" and RangedWeapon.BulletNum<RangedWeapon.MagazineCapacity:
            RangedWeapon.set_bullet_num()
            if RangedWeapon.AllBulletNum>0:
                RangedWeapon.Shooting=false
                RangedWeapon.Attackable=false
                RangedWeapon.reload()
    elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT and !event.pressed:
        #放开鼠标左键，如果装备远程武器且需要换弹，则重新装弹
        if WeaponChoice=="ranged":
            RangedWeapon.Shooting=false
            RangedWeapon.set_bullet_num()
            if RangedWeapon.AllBulletNum>0 and RangedWeapon.BulletNum<=0:
                RangedWeapon.Attackable=false
                RangedWeapon.reload()
    elif event.is_action_pressed("ui_focus_prev"):
        #鼠标滚轮上滚，切换近战/远程武器。如果远程武器没有弹药，则重新装弹
        if $ChangeWeaponTimer.time_left:
            return
        if RangedWeapon.BulletNum<=0:
            RangedWeapon.reload()
        if WeaponChoice=="ranged":
            WeaponChoice="melee"
            RangedWeapon.hide()
            MeleeWeapon.show()
            Global.OverworldUIs.change_weapon_choice("melee")
        elif WeaponChoice=="melee":
            WeaponChoice="ranged"
            MeleeWeapon.hide()
            RangedWeapon.show()
            Global.OverworldUIs.change_weapon_choice("ranged")
        $ChangeWeaponTimer.start()
    elif event.is_action_pressed("ui_focus_next"):#鼠标下滚切换快捷栏道具
        Global.QuickUseItemChoice=(Global.QuickUseItemChoice+1)%5
        Global.OverworldUIs.update_quick_item()
    elif event.is_action_pressed("quick_use_item"):
        if Global.QuickUseItem[Global.QuickUseItemChoice]==null:
            return
        ReferenceList.use_item(self,Global.QuickUseItem[Global.QuickUseItemChoice])
        Global.OverworldUIs.update_quick_item()
    elif event.is_action_pressed("ui_speed_up"):
        if !TiredOut:
            SpeedUp=true
            CreatureStatus.SpeedType=1
    elif event.is_action_released("ui_speed_up"):
        SpeedUp=false
        CreatureStatus.SpeedType=0
    elif event.is_action_pressed("E_action"):
        E_action()
    
func direction_action():
    #根据按键情况，决定移动方向
    if Input.is_action_pressed("ui_up")&&!KeyboardPressState[0]:
        KeyboardPressState[0]=1
        PlayerMoveState.y=-1
    elif !Input.is_action_pressed("ui_up")&&KeyboardPressState[0]:
        KeyboardPressState[0]=0
        if KeyboardPressState[1]:
            PlayerMoveState.y=1
        else:
            PlayerMoveState.y=0
    if Input.is_action_pressed("ui_down")&&!KeyboardPressState[1]:
        KeyboardPressState[1]=1
        PlayerMoveState.y=1
    elif !Input.is_action_pressed("ui_down")&&KeyboardPressState[1]:
        KeyboardPressState[1]=0
        if KeyboardPressState[0]:
            PlayerMoveState.y=-1
        else:
            PlayerMoveState.y=0
    if Input.is_action_pressed("ui_left")&&!KeyboardPressState[2]:
        KeyboardPressState[2]=1
        PlayerMoveState.x=-1
    elif !Input.is_action_pressed("ui_left")&&KeyboardPressState[2]:
        KeyboardPressState[2]=0
        if KeyboardPressState[3]:
            PlayerMoveState.x=1
        else:
            PlayerMoveState.x=0
    if Input.is_action_pressed("ui_right")&&!KeyboardPressState[3]:
        KeyboardPressState[3]=1
        PlayerMoveState.x=1
    elif !Input.is_action_pressed("ui_right")&&KeyboardPressState[3]:
        KeyboardPressState[3]=0
        if KeyboardPressState[2]:
            PlayerMoveState.x=-1
        else:
            PlayerMoveState.x=0
                
func move():
    var OriginPosition=global_position
    var movement=(PlayerMoveState.normalized())*Speed       #算出移动距离
    if $RigidTimer.time_left:
        movement=Vector2(0,0)
    if KnockBack.z:#如果自身被击退，需要往击退方向移动（向量加）
        var KnockBackDistance=sqrt(KnockBack.z)#每一帧击退距离平方递减！
        movement+=Vector2(KnockBack.x,KnockBack.y).normalized()*KnockBackDistance
        KnockBack.z-=KnockBackDistance
        if KnockBack.z<=1:
            KnockBack.z=0    
    var OriginalPosition=global_position                    #记下移动前位置
    var collision = move_and_collide(movement)              #检测是否碰撞，并且沿碰撞方向滑动
    if collision:                                           #如果碰撞，沿着滑动方向运动直到达到一帧运动距离
            movement = movement.slide(collision.normal).normalized()*(Speed-(global_position-OriginalPosition).length())
            move_and_collide(movement)
    if (global_position-OriginalPosition).length()>Speed/2 and SpeedUp and !$RigidTimer.time_left and KnockBack.z==0:
        energy_consume(1.03333)

func energy_recover():
    if !TiredOut:
        Energy+=0.66667
    else:
        Energy+=0.41667
    if Energy>MaxEnergy:
        Energy=MaxEnergy
        TiredOut=false
        
func energy_consume(value:float):
    Energy-=value
    if Energy<=0:
        Energy=0
        TiredOut=true
        CreatureStatus.SpeedType=0
        SpeedUp=false

func animation_function():
    var ani
    $Animations/PlayerAnimation.speed_scale=0.7
    if (WeaponChoice=="ranged" and !RangedWeapon.Enable) or (WeaponChoice=="melee" and !MeleeWeapon.Enable):
        ani="unarmed"
        $Animations/left_hand.hide()
        $Animations/right_hand.hide()
    else:
        ani="armed"
        $Animations/left_hand.show()
        $Animations/right_hand.show()
    var Direction
    if PlayerMoveState==Vector2(0,0) or $RigidTimer.time_left:
        ani+="_stand" 
        Direction=FaceDirection.normalized()
    else:
        ani+="_walk"
        Direction=PlayerMoveState.normalized()
    if Direction.x>0.5:
        ani+="_right"
    elif Direction.x<-0.5:
        ani+="_left"
    if Direction.y>=-0.2:
        ani+="_down"
    elif Direction.y<0.2:
        ani+="_up"
        if SpeedUp:
            $Animations/PlayerAnimation.speed_scale=1
    $Animations/PlayerAnimation.animation=ani
    
    var Weapon=null
    if WeaponChoice=="melee":
        Weapon=MeleeWeapon
    elif WeaponChoice=="ranged":
        Weapon=RangedWeapon
    if Weapon==null or !Weapon.Enable:
        return
    Weapon.rotation=Direction.angle()
    if Direction.x>=0 and Direction.x<=0.5 and Direction.y<-0.2:
        $Animations/left_hand.z_index=-1
        $Animations/left_hand.position=Vector2(-28,-8)
        $Animations/right_hand.z_index=-1
        $Animations/right_hand.position=Vector2(28,8)
        Weapon.global_position=$Animations/left_hand.global_position
        Weapon.z_index=-2
    elif Direction.x>0.5 and  Direction.y<-0.2:
        $Animations/left_hand.z_index=-1
        $Animations/left_hand.position=Vector2(-24,-12)
        $Animations/right_hand.z_index=-1
        $Animations/right_hand.position=Vector2(28,4)
        Weapon.global_position=$Animations/left_hand.global_position
        Weapon.z_index=-2
    elif Direction.x>=0.5 and  Direction.y>=-0.2:
        $Animations/left_hand.z_index=-1
        $Animations/left_hand.position=Vector2(24,4)
        $Animations/right_hand.z_index=1
        $Animations/right_hand.position=Vector2(-12,4)
        Weapon.global_position=$Animations/right_hand.global_position
        Weapon.z_index=0
    elif Direction.x>=0 and Direction.x<0.5 and  Direction.y>-0.2:
        $Animations/left_hand.z_index=-1
        $Animations/left_hand.position=Vector2(24,8)
        $Animations/right_hand.z_index=1
        $Animations/right_hand.position=Vector2(-24,8)
        Weapon.global_position=$Animations/right_hand.global_position
        Weapon.z_index=0
    elif Direction.x>=-0.5 and Direction.x<=0 and Direction.y<-0.2:
        $Animations/left_hand.z_index=-1
        $Animations/left_hand.position=Vector2(-28,8)
        $Animations/right_hand.z_index=-1
        $Animations/right_hand.position=Vector2(28,-8)
        Weapon.global_position=$Animations/right_hand.global_position
        Weapon.z_index=-2
    elif Direction.x<=-0.5 and  Direction.y<-0.2:
        $Animations/left_hand.z_index=-1
        $Animations/left_hand.position=Vector2(-28,4)
        $Animations/right_hand.z_index=-1
        $Animations/right_hand.position=Vector2(24,-12)
        Weapon.global_position=$Animations/right_hand.global_position
        Weapon.z_index=-2
    elif Direction.x<=-0.5 and  Direction.y>=-0.2:
        $Animations/left_hand.z_index=1
        $Animations/left_hand.position=Vector2(12,4)
        $Animations/right_hand.z_index=-1
        $Animations/right_hand.position=Vector2(-24,4)
        Weapon.global_position=$Animations/left_hand.global_position
        Weapon.z_index=0
    elif Direction.x>-0.5 and Direction.x<0 and  Direction.y>-0.2:
        $Animations/left_hand.z_index=1
        $Animations/left_hand.position=Vector2(24,8)
        $Animations/right_hand.z_index=-1
        $Animations/right_hand.position=Vector2(-24,8)
        Weapon.global_position=$Animations/left_hand.global_position
        Weapon.z_index=0
    
    if PlayerMoveState==Vector2(0,0) or $RigidTimer.time_left:
        RangedWeapon.ForceDirection=Vector2()
    else:
        RangedWeapon.ForceDirection=Direction
    

func reset_rigid_timer(num:float):
    $RigidTimer.wait_time=num
    $RigidTimer.start()
    RangedWeapon.ForceDirection=Vector2()

func action_ui_function():
    var i =0
    while i<E_Actions.size():
        if E_Actions[i]["Type"]=="Assassinate" and (E_Actions[i]["Target"].AImode=="attacking" or !E_Actions[i]["Target"].CreatureStatus.alive()):
            E_Actions.remove(i)
            i-=1
        i+=1
    for key in E_Actions:
        var Collision=Global.detect_collision_in_line(global_position,key["Target"].global_position,[self,key["Target"]],1)
        if Collision:
            $E_ActionUI.hide()
            key["Enable"]=false
            continue
        else:
            $E_ActionUI.show()  
            $E_ActionUI.global_position=key["Target"].global_position
            key["Enable"]=true
            return
    $E_ActionUI.hide()      

func _on_ActionArea_body_entered(body):
    if body.Identifier=="Enermy" and body.AImode!="Attacking":
        E_Actions.push_back({"Type":"Assassinate","Target":body,"Enable":false})


func _on_ActionArea_body_exited(body):
    for i in range(E_Actions.size()):
        if E_Actions[i]["Target"]==body:
            E_Actions.remove(i)

func E_action():
    for i in E_Actions:
        if i["Enable"]:
            if i["Type"]=="Assassinate":
                i["Target"].CreatureStatus.get_hurt(9999,"real",self)
            return    
