extends Node
#相当于是一个全局的数据访问文档，只读
var ItemRference={
    "木材":{
        "ID":1,                                 #ID，代表物品编号，也可以认为是另一种代号
        "Type":"Material",                      #类型，便于区分
        "Weight":1,                             #单个物品重量
        "Usable":false,                         #是否可以直接在背包中使用
        "Price":1,                              #单价（出售）
        "Description":"一小堆木材，常见的建筑材料。" 
        },
    "9mm子弹":{
        "ID":11,
        "Type":"Bullet",
        "Weight":0.01,
        "Usable":false,
        "Price":0.5,
        "Description":"0.5毫米子弹，常用于冲锋枪。"
       },
    "绷带":{
        "ID":21,
        "Type":"Medicine",
        "Weight":0.01,
        "Usable":true,
        "Price":10,
        "Description":"紧急救治医疗物品。可以恢复10点生命。"
       }
   }

var WeaponReference={
    "test_melee_weapon":{
        "ID":-1,
        "Type":"MeleeWeapon",
        "Weight":3,
        "MaxDurability":200,
        "Attack":20,
        "MaxRange":80,
        "KnockBack":100,
        "EnergyNeed":20,
        "GuardingValue":600,
        "AttackType":"test_damage_area",
        "RigidTime":0.5,
        "Description":"测试用近战武器。\n攻击力：10\n攻速：较慢\n击退力：中等"
       },
    "test_ranged_weapon":{
        "ID":-2,
        "Type":"RangedWeapon",
        "Weight":4,
        "MaxDurability":1000,
        "Attack":1,
        "AutoAttack":true,
        "BulletType":"9mm子弹",
        "MagazineCapacity":50,
        "RigidTime":0.3,
        "ColdTime":0.2,
        "ReloadTime":3,
        "RandomAngle":2,
        "MaxRange":500,
        "KnockBack":10,
        "BulletSpeed":15,
        "GuardingValue":1200,
        "Description":"测试用远程武器。\n攻击力：1\n使用子弹：test_bullet\n攻速：快\n击退力：低"
       },
    "test_ranged_weapon1":{
        "ID":-3,
        "Type":"RangedWeapon",
        "Weight":4,
        "MaxDurability":100,
        "Attack":10,
        "AutoAttack":false,
        "BulletType":"9mm子弹",
        "MagazineCapacity":10,
        "RigidTime":0.5,
        "ColdTime":0.5,
        "ReloadTime":3,
        "RandomAngle":2,
        "MaxRange":600,
        "KnockBack":20,
        "BulletSpeed":15,
        "GuardingValue":1500,
        "Description":"第二把测试用远程武器。\n攻击力：10\n使用子弹：test_bullet\n攻速：较快\n击退力：较低"
       }
   }

var EnermyReference={
    "test_enermy":{
        "ID":-1,
        "Type":"Enermy",
        "MaxHealth":100,
        "Attack":10,
        "AttackRange":100,
        "Speed":[3,3,3],
        "CollisionSize":Vector2(25,25),
        "AnimationOffset":Vector2(0,0),
        "Ability":[1,1,1,1],
        "SightAngle":90,
        "SightRange":400,
        "BeforeAttackTime":0.5,
        "AfterAttackTime":0.5,
        "AttackColdTime":2
       }
   }

func use_item(Target:Object,ItemName:String):
    if Global.GoodInBackpack.get(ItemName)==null or Global.GoodInBackpack[ItemName]<=0:
        return
    Global.GoodInBackpack[ItemName]-=1
    match ItemName:
        "绷带":
            Target.CreatureStatus.heal(10)
    Global.send_message(Target.Name+"使用了一个"+ItemName+"!")
    Global.update_pause_window()
    

