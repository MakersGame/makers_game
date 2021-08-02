extends Node2D

var Identifier="RangedWeapon"
var Name:String
var Weight:float                #装备重量
var Durability:float            #武器耐久度
var MaxDurability:float         #武器耐久度上限
var Enable:bool=false           #是否处于战斗状态
var Attackable:bool=true        #是否可以发射子弹，要考虑到发射冷却和换弹
var TargetPosition:Vector2      #目标坐标
var Direction:Vector2           #武器对准的方向，也决定子弹和动画的方向
var ForceDirection:Vector2      #强制瞄准方向
var Attack:float                #攻击力
var AutoAttack:bool             #是否可以连射
var Shooting:bool=false         #是否按住攻击键，连射的武器在按住时持续攻击
var AllBulletNum:int            #剩余背包中子弹数量（未装填的）
var MagazineCapacity:int        #弹夹容量
var BulletNum:int               #弹夹剩余子弹数量
var RandomAngle:float           #子弹偏转角
var MaxRange:float              #最大射程
var BulletSpeed:float           #子弹飞行速度，供AI计算射击方向
var KnockBack:float             #击退能力，单位为像素
var GuardingValue:float         #攻击造成的警戒值
var RigidTime:float             #使用者每次攻击后的僵直时间
var Owner                       #武器的使用者
var BulletType:String           #子弹型号
var BulletOffset:Vector2


var Bullet=preload("res://weapons/ranged/bullet/bullet.tscn")

signal bullet_consume

func init(_Name:String,_Durability:float,_Owner,_AttackAbility:float,_ReloadAbility:float,_KnockBackAbility:float):
    Name=_Name
    Owner=_Owner
    Enable=true
    if ReferenceList.WeaponReference.get(Name)==null:
        print("Invalid ranged weapon name \"",Name,"\"!")
        queue_free()
        return
    var WeaponInfo=ReferenceList.WeaponReference[Name]
    $WeaponBody/AnimatedSprite.animation=Name
    $WeaponBody/AnimatedSprite.offset=WeaponInfo["CenterOffset"]
    $WeaponBody/AnimatedSprite/BulletPosition.position=WeaponInfo["BulletOffset"]
    MaxDurability=WeaponInfo["MaxDurability"]
    if _Durability==-1:
        Durability=MaxDurability
    else:
        Durability=_Durability
    Weight=WeaponInfo["Weight"]
    Attack=WeaponInfo["Attack"]
    AutoAttack=WeaponInfo["AutoAttack"]
    BulletType=WeaponInfo["BulletType"]
    MagazineCapacity=WeaponInfo["MagazineCapacity"]
    BulletNum=0              #暂定
    $ColdTimer.wait_time=WeaponInfo["ColdTime"]
    $ReloadTimer.wait_time=WeaponInfo["ReloadTime"]
    RandomAngle=WeaponInfo["RandomAngle"]
    MaxRange=WeaponInfo["MaxRange"]
    KnockBack=WeaponInfo["KnockBack"]
    BulletSpeed=WeaponInfo["BulletSpeed"]
    GuardingValue=WeaponInfo["GuardingValue"]
    RigidTime=WeaponInfo["RigidTime"]
            
    Attack*=_AttackAbility
    $ReloadTimer.wait_time*=_ReloadAbility
    KnockBack*=_KnockBackAbility
    
func _physics_process(delta):
    direction_function()
    if AutoAttack and Shooting:
        shoot()


func direction_function():
    var DirectionAngle
    if $WeaponBody/AnimatedSprite.flip_v:
        DirectionAngle=(TargetPosition-global_position).angle()+asin($WeaponBody/AnimatedSprite/BulletPosition.position.y*$WeaponBody/AnimatedSprite.scale.y/(TargetPosition-global_position).length())
    else:
        DirectionAngle=(TargetPosition-global_position).angle()-asin($WeaponBody/AnimatedSprite/BulletPosition.position.y*$WeaponBody/AnimatedSprite.scale.y/(TargetPosition-global_position).length())
    if ForceDirection==Vector2(0,0):
        Direction=Vector2(cos(DirectionAngle),sin(DirectionAngle))
    else:
        Direction=ForceDirection
    rotation=Direction.angle()
    if rotation<-PI/2 or rotation>PI/2:
        $WeaponBody/AnimatedSprite.flip_v=true
    else:
        $WeaponBody/AnimatedSprite.flip_v=false

    
    if $WeaponBody/AnimatedSprite.flip_v:
        $WeaponBody/AnimatedSprite/BulletPosition.position.y*=-1
        BulletOffset=$WeaponBody/AnimatedSprite/BulletPosition.global_position
        $WeaponBody/AnimatedSprite/BulletPosition.position.y*=-1
    else:
        BulletOffset=$WeaponBody/AnimatedSprite/BulletPosition.global_position
    
func shoot():#（试图）开枪
    if !Enable or !Attackable:
        return
    Owner.reset_rigid_timer(RigidTime)
    direction_function()
    get_tree().call_group("enermy","raise_guard",global_position,GuardingValue)
    var NewBullet=Bullet.instance()
    NewBullet.visible=true
    Global.CurrentScene.add_child(NewBullet)
    var TempAngle=(randf()-0.5)*RandomAngle*PI/180
    var RandomDirection=Vector2(Direction.x*cos(TempAngle)+Direction.y*sin(TempAngle),-Direction.x*sin(TempAngle)+Direction.y*cos(TempAngle))
    NewBullet.init(BulletType,BulletOffset,Attack,BulletSpeed,RandomDirection,MaxRange,Owner,KnockBack)
    $ColdTimer.start()
    BulletNum-=1
    Durability-=1
    if Durability<0:
        Durability=0
    Attackable=false
    if Owner.Identifier=="Player":
        Global.OverworldUIs.update_weapon_choice()
    if !AutoAttack:
        if $WeaponBody/AnimatedSprite.flip_v:
            $AnimationPlayer.play("NonautoAttackFlipV")
        else:
            $AnimationPlayer.play("NonautoAttackNormal")
    else:
        if $WeaponBody/AnimatedSprite.flip_v:
            $AnimationPlayer.play("AutoAttackFlipV")
        else:
            $AnimationPlayer.play("AutoAttackNormal")
            
func reload():#重新装弹
    if AllBulletNum<=0 or $ReloadTimer.time_left:
        return
    Attackable=false
    $ReloadTimer.start()
    if Owner.Identifier=="Player":
        Global.OverworldUIs.weapon_reload_change("RangedWeapon")

func set_bullet_num():#初始化此武器需要的子弹的背包数量，中途增加的话也通过此函数更改
    if Global.GoodInBackpack.get(BulletType)!=null:
        AllBulletNum=Global.GoodInBackpack[BulletType]
    else:
        AllBulletNum=0

func consume_bullet(num:int):
    if Global.GoodInBackpack.get(BulletType)!=null:
        Global.GoodInBackpack[BulletType]-=num
        if Global.GoodInBackpack[BulletType]<0:
            Global.GoodInBackpack[BulletType]=0
        Global.update_pause_window()

func _on_ColdTimer_timeout():
    if BulletNum>0 and Durability:
        Attackable=true

func _on_ReloadTimer_timeout():#重新装弹完成
    set_bullet_num()
    if AllBulletNum>=MagazineCapacity-BulletNum:
        consume_bullet(MagazineCapacity-BulletNum)
        BulletNum=MagazineCapacity
    else:
        consume_bullet(AllBulletNum)
        BulletNum+=AllBulletNum
    if $ColdTimer.time_left==0 and Durability:
        Attackable=true
    if Owner.Identifier=="Player":
        Global.OverworldUIs.update_weapon_choice()
        Global.OverworldUIs.weapon_reload_change("RangedWeapon")
