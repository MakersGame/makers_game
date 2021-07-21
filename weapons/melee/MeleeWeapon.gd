extends Node2D

var Identifier="MeleeWeapon"
var Name:String                 #武器名称
var Weight:float                #武器重量
var Durability:float            #武器耐久度
var MaxDurability:float         #武器耐久度上限
var Enable:bool=true            #是否处于战斗状态
var Attackable:bool=false       #是否可以进行攻击
var Direction:Vector2           #武器对准的方向，也决定攻击和动画的方向
var Attack:float                #攻击力
var MaxRange:float              #攻击距离，仅供参考，在AI处理时作为指标
var KnockBack:float             #击退能力，单位为像素
var EnergyNeed:float            #进行一次攻击需要消耗的体力
var GuardingValue:float         #攻击造成的警戒值
var RigidTime:float             #使用者每次攻击后的僵直时间
var Owner                       #武器的使用者
var AttackType:String           #范围攻击的类型
var DamageArea=preload("res://weapons/melee/damage_area/DamageArea.tscn")

func init(_Name:String,_Durability,_Owner:Object,_AttackAbility:float,_KnockBackAbility:float):
    Name=_Name
    Attackable=true
    Owner=_Owner
    if ReferenceList.WeaponReference.get(Name)==null:
        print("Invalid melee weapon name \"",Name,"\"!")
        queue_free() 
        return
    var WeaponInfo=ReferenceList.WeaponReference[Name]
    MaxDurability=WeaponInfo["MaxDurability"]
    if _Durability==-1:
        Durability=MaxDurability
    else:
        Durability=_Durability
    Weight=WeaponInfo["Weight"]
    Attack=WeaponInfo["Attack"]
    MaxRange=WeaponInfo["MaxRange"]
    KnockBack=WeaponInfo["KnockBack"]
    GuardingValue=WeaponInfo["GuardingValue"]
    EnergyNeed=WeaponInfo["EnergyNeed"]
    AttackType=WeaponInfo["AttackType"]
    RigidTime=WeaponInfo["RigidTime"]

    Attack*=_AttackAbility
    KnockBack*=_KnockBackAbility

func attack():#对着瞄准方向进行攻击
    if !Enable or !Attackable:
        return
    get_tree().call_group("enermy","raise_guard",global_position,GuardingValue)
    var NewDamageArea=DamageArea.instance()
    NewDamageArea.init("test_damage_area",Attack,Direction,Owner,Owner.CreatureStatus.Camp,KnockBack)
    self.add_child(NewDamageArea)
    Attackable=false
    $ColdTimer.start()
    get_parent().reset_rigid_timer(RigidTime)

func _on_ColdTimer_timeout():
    Attackable=true
