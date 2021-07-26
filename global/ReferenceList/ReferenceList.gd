extends Node
#相当于是一个全局的数据访问文档，只读
var ItemRference={
    "木材":{
        "ID":1,                                 #ID，代表物品编号，也可以认为是另一种代号
        "Type":"Resource",                      #类型，便于区分
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
        "Description":"常用于手枪。"
       },
    "雷明顿16号弹":{
        "ID":12,
        "Type":"Bullet",
        "Weight":0.02,
        "Usable":false,
        "Price":1,
        "Description":"常用于老式霰弹枪。"
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
    "马桶橛子":{
        "ID":1,
        "Type":"MeleeWeapon",
        "Weight":3,
        "MaxDurability":200,
        "Attack":1,
        "AttackExistTime":0.5,
        "SingleTarget":false,
        "MaxRange":70,
        "KnockBack":150,
        "EnergyNeed":20,
        "GuardingValue":300,
        "DamageAreaRect":Vector2(10,5.5),
        "RigidTime":0.5,
        "ColdTime":2,
        "CenterOffset":Vector2(4,0),
        "DamageAreaOffset":Vector2(21,1.5),
        "Description":"马桶橛子，上古神器。\n攻击力：5\n攻速：中等\n击退力：高"
       },
    "EX咖喱棒":{
        "ID":2,
        "Type":"MeleeWeapon",
        "Weight":10,
        "MaxDurability":200,
        "Attack":20,
        "AttackExistTime":0.1,
        "SingleTarget":true,
        "MaxRange":90,
        "KnockBack":50,
        "EnergyNeed":20,
        "GuardingValue":600,
        "DamageAreaRect":Vector2(13,2),
        "RigidTime":1,
        "ColdTime":3,
        "CenterOffset":Vector2(14,1),
        "DamageAreaOffset":Vector2(62,0.6),
        "Description":"亚瑟王之剑（迫真）。\n攻击力：20\n攻速：较慢\n击退力：较高"
       },
    "9mm手枪":{
        "ID":11,
        "Type":"RangedWeapon",
        "Weight":2.5,
        "MaxDurability":100,
        "Attack":10,
        "AutoAttack":false,
        "BulletType":"9mm子弹",
        "MagazineCapacity":10,
        "RigidTime":0.6,
        "ColdTime":0.6,
        "ReloadTime":3,
        "RandomAngle":2,
        "MaxRange":600,
        "KnockBack":8,
        "BulletSpeed":15,
        "GuardingValue":1500,
        "Description":"9mm手枪。\n攻击力：10\n使用子弹：9mm子弹\n攻速：一般\n击退力：低",
        "CenterOffset":Vector2(5,0),
        "BulletOffset":Vector2(15,-4)
       },
    "老式霰弹枪":{
        "ID":12,
        "Type":"RangedWeapon",
        "Weight":6,
        "MaxDurability":100,
        "Attack":25,
        "AutoAttack":false,
        "BulletType":"雷明顿16号弹",           #记得改
        "MagazineCapacity":6,
        "RigidTime":1.2,
        "ColdTime":1.2,
        "ReloadTime":3.5,
        "RandomAngle":5,
        "MaxRange":350,
        "KnockBack":15,
        "BulletSpeed":15,
        "GuardingValue":1800,
        "Description":"老式霰弹枪\n攻击力：25\n使用子弹：9mm子弹（主要是还没做其他子弹\n攻速：较慢\n击退力：中",
        "CenterOffset":Vector2(9,0),
        "BulletOffset":Vector2(21,-3)   
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
    

