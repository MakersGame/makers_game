extends KinematicBody2D
#此敌人模板仅供测试！

var Identifier="Enermy"
var Name:String                         #怪物名称，也代表种类
var Exist:bool=false
var movement:Vector2
var TargetPosition:Vector2              #暂定，可能无此变量
var Target                              #锁定的目标，为玩家或NPC
var BirthPosition:Vector2               #出生位置，回溯模式下会回到此处
var Speed:float                         #即creature_status中的Speed[SpeedType]
var AImode:String                        
#AI模式，值为“default",“guarding",attacking","backtracking",分别对应默认、进攻、警惕和回溯模式
#默认模式下按一定轨迹移动，警惕模式下前往目标点，进攻模式下追踪目标，回溯模式下寻路回到出生点
var BattleMod:String                    #值为“common"或”defense"，对应正常战斗和防御战
var KnockBack:Vector3                   #被击退值，三维向量，xy表示方向，z表示剩余击退距离，每一帧击退距离呈二次函数
var Attackable:bool=true                #是否可以进行攻击
var Attacking:bool=false                #是否正在攻击
var AttackRange:float                   #攻击距离，单位为像素
var DamageAreaRect:Vector2
var DamageAreaOffset:Vector2
var BeforeAttackTime:float              #攻击前摇
var AfterAttackTime:float               #攻击后摇
var FaceDirection:Vector2               #面朝方向，决定视野范围
var SightRange:float                    #扇形视野的半径
var SightAngle:float                    #扇形视野的夹角，采用角度制
var GuardingPosition:Vector3            #警戒坐标，前往此坐标查看，z值为警戒指数
var Territory:Vector3                   #圆形领域，xy代表中心坐标，z代表半径

var CurrentAreaCenter=null
var DamageArea=preload("res://weapons/melee/damage_area/DamageArea.tscn")   
   
onready var CreatureStatus=$CreatureStatus

signal LeaveDefaultMode

func _init():
    AImode="default"

func init(_Name:String,_FaceDirection:Vector2,_TempHealth:float,_CurrentAreaCenter):
    Name=_Name
    TargetPosition=global_position
    BirthPosition=global_position
    AImode="default"
    FaceDirection=_FaceDirection
    if ReferenceList.EnermyReference.get(Name)==null:
        print("Invalid enermy name \"",Name,"\"!")
        queue_free()
    $CollisionShape2D.shape.extents=ReferenceList.EnermyReference[Name]["CollisionSize"]
    if _TempHealth<0:
        CreatureStatus.init(ReferenceList.EnermyReference[Name]["MaxHealth"],ReferenceList.EnermyReference[Name]["MaxHealth"],ReferenceList.EnermyReference[Name]["Attack"],ReferenceList.EnermyReference[Name]["Speed"],"Enermy",$CollisionShape2D,ReferenceList.EnermyReference[Name]["Ability"]) 
    else:
        CreatureStatus.init(_TempHealth,ReferenceList.EnermyReference[Name]["MaxHealth"],ReferenceList.EnermyReference[Name]["Attack"],ReferenceList.EnermyReference[Name]["Speed"],"Enermy",$CollisionShape2D,ReferenceList.EnermyReference[Name]["Ability"]) 
    AttackRange=ReferenceList.EnermyReference[Name]["AttackRange"]
    SightAngle=ReferenceList.EnermyReference[Name]["SightAngle"]
    SightRange=ReferenceList.EnermyReference[Name]["SightRange"]
    $AttackColdTimer.wait_time=ReferenceList.EnermyReference[Name]["AttackColdTime"]
    BeforeAttackTime=ReferenceList.EnermyReference[Name]["BeforeAttackTime"]
    AfterAttackTime=ReferenceList.EnermyReference[Name]["AfterAttackTime"]
    DamageAreaRect=ReferenceList.EnermyReference[Name]["DamageAreaRect"]
    DamageAreaOffset=ReferenceList.EnermyReference[Name]["DamageAreaOffset"]
              
    Attackable=true 
    Exist=true
    CurrentAreaCenter=Vector2()
        
func _physics_process(delta):
    if !CreatureStatus.alive() and Exist:
        die()#死了，但不会立刻消失。动画会持续一小段时间
    if !Exist:
        return
    if CurrentAreaCenter==null:
        z_index=100
    else:
        z_index=floor((global_position-CurrentAreaCenter).y/20)+2
    Target=CreatureStatus.TargetEnermy
    movement=Vector2()
    if Target!=null:
        TargetPosition=Target.global_position   
        movement=CreatureStatus.find_way_to_target(Target.CreatureStatus)
    else:
        movement=CreatureStatus.find_way(TargetPosition) 
    AIFunction()
    if CreatureStatus.TargetPath.size()>1:
        FaceDirection=(CreatureStatus.TargetPath[1]-CreatureStatus.TargetPath[0]).normalized()
    elif movement!=Vector2():
        FaceDirection=movement
    face_direction_normalize()
    Speed=CreatureStatus.Speed[CreatureStatus.SpeedType]
    move(movement)
    animation_function()

func detect():
    if FaceDirection==Vector2(0,0):#这种情况说明初始化有问题，且会引发错误
        return
    var Tars=Global.PlayerAndNPCs#所有和自己敌对的生物集合，包括玩家和NPC
    var res=null#检测到的离自己最近敌对生物
    var TempMinimumDis=INF#当前检测到的生物的离自己最短距离
    face_direction_normalize()
    for Tar in Tars:
        Tar.GuardingEnermies.erase(self)
        if CreatureStatus.AggroValue.get(Tar)==null and (Tar.global_position-global_position).length()>SightRange*2 or abs(FaceDirection.angle_to(Tar.global_position-global_position))*180/PI>SightAngle/2:
            continue#若对此单位没有仇恨，且其不在扇形区域内，直接判断下一个
        #判断是否撞上障碍物
        var collision=Global.detect_collision_in_line(global_position,Tar.global_position,[self], 0b100001)
        if collision:
            if CreatureStatus.AggroValue.get(Tar)!=null:
                CreatureStatus.dec_aggro(0.1*sqrt(CreatureStatus.AggroValue[Tar]),Tar)
        elif CreatureStatus.AggroValue.get(Tar)==null and (Tar.global_position-global_position).length()>SightRange and abs(FaceDirection.angle_to(Tar.global_position-global_position))*180/PI<=SightAngle/2:
            call_deferred("deferred_raise_guard",Tar.global_position,SightRange*3)
            if not self in Tar.GuardingEnermies:
                Tar.GuardingEnermies.push_back(self)
        elif TempMinimumDis>(Tar.global_position-global_position).length():
            res=Tar
            TempMinimumDis=(Tar.global_position-global_position).length()
            if CreatureStatus.AggroValue.get(Tar)==null or CreatureStatus.AggroValue[Tar]<100:
                CreatureStatus.add_aggro(100,Tar)
    return res#结果为离自己最近的被检测到的敌人，若没有检测到则返回null
        
func move(movement:Vector2):#移动策略，同NPC的
    if (TargetPosition-global_position).length()<Speed: 
        movement=Vector2()
    if $RigidTimer.time_left:
        movement=Vector2(0,0)
    if KnockBack.z:
        var KnockBackDistance=sqrt(KnockBack.z)
        movement+=Vector2(KnockBack.x,KnockBack.y).normalized()*KnockBackDistance
        KnockBack.z-=KnockBackDistance
        if KnockBack.z<=1:
            KnockBack.z=0
    var OriginalPosition=global_position
    var collision=move_and_collide(movement)
    if collision:
        movement = movement.slide(collision.normal).normalized()*(Speed-(global_position-OriginalPosition).length())
        move_and_collide(movement)

func AIFunction():#AI切换以及不同AI的行动
    match AImode:
        "default":#默认模式
            if !$RandomMoveTimer.time_left and CreatureStatus.TargetPath.size()<=1:
                $RandomMoveTimer.start()
            elif CreatureStatus.TargetPath.size()>1:
                $RandomMoveTimer.stop()
            var Tar=detect()
            if Tar!=null:
                Target=Tar
                AImode="attacking"#找到目标后进入攻击模式
                emit_signal("LeaveDefaultMode")
                $CreatureStatus/GuardSign.show()
            elif GuardingPosition.z>0:
                AImode="guarding"
                SightAngle*=1.5
                SightRange*=1.5
                $CreatureStatus/GuardSign.show()
                emit_signal("LeaveDefaultMode")
        "guarding":#警戒模式
            $CreatureStatus/GuardSign.animation="Guarding"
            detect()
            TargetPosition=Vector2(GuardingPosition.x,GuardingPosition.y)
            if Target!=null:
                AImode="attacking"
                SightAngle/=1.5
                SightRange/=1.5
                $CreatureStatus/GuardSign.show()
            if (TargetPosition-global_position).length()<=SightRange/3:
                var collision=Global.detect_collision_in_line(global_position,TargetPosition,[self],0b100001)
                if collision:
                    return
                TargetPosition=global_position
                GuardingPosition.z-=2
            if GuardingPosition.z<=0:
                GuardingPosition.z=0
                AImode="backtracking"
                SightAngle/=1.5
                SightRange/=1.5
                $CreatureStatus/GuardSign.hide()
        "attacking":#冲突模式，追踪目标进行攻击
            $CreatureStatus/GuardSign.animation="Attacking"
            detect()
            if Target==null :
                if GuardingPosition.z<=0:
                    AImode="backtracking"#失去目标，则进入回溯模式 
                    $CreatureStatus/GuardSign.hide()
                else:
                    AImode="guarding"
                    SightAngle*=1.5
                    SightRange*=1.5
                    $CreatureStatus/GuardSign.show()
            else:
                if not self in Target.AttackingEnermies:
                    Target.AttackingEnermies.push_back(self)
                if !$RigidTimer.time_left and !$AttackColdTimer.time_left and Attackable and (Target.global_position-global_position).length()<=AttackRange:
                    $RigidTimer.wait_time=BeforeAttackTime
                    FaceDirection=(Target.global_position-global_position).normalized()
                    face_direction_normalize()
                    $RigidTimer.start()      
                                        #准备攻击
        "backtracking":#回溯模式，回到出生点
            if Target!=null:
                AImode="attacking"
                $CreatureStatus/GuardSign.show()
                return
            elif GuardingPosition.z>0:
                AImode="guarding"    
                SightAngle*=1.5
                SightRange*=1.5
                $CreatureStatus/GuardSign.show()
            TargetPosition=BirthPosition
            if abs(TargetPosition.x-global_position.x)<=$CollisionShape2D.shape.extents.x and abs(TargetPosition.y-global_position.y)<=$CollisionShape2D.shape.extents.y:
                TargetPosition=global_position
                AImode="default"
                $CreatureStatus/GuardSign.hide()
        _:
            print("WARNING!!! ",self," in an unknown AImode!")
            return


func attack():#攻击
    if !Attackable:
        return
    var NewDamageArea=DamageArea.instance()
    NewDamageArea.init($CreatureStatus.Attack,true,0.5,FaceDirection.normalized(),self,CreatureStatus.Camp,100)
    $DamageAreas.add_child(NewDamageArea)
    NewDamageArea.get_node("CollisionShape2D").shape.extents=DamageAreaRect
    NewDamageArea.get_node("CollisionShape2D").position=DamageAreaOffset
    $DamageAreas.rotation=FaceDirection.angle()
    Attackable=false
    $AttackColdTimer.start()
    $RigidTimer.wait_time=AfterAttackTime
    $RigidTimer.start()
    Attacking=true   

func face_direction_normalize():
    FaceDirection=FaceDirection.normalized()
    if FaceDirection.x>0 and abs(FaceDirection.y)<=FaceDirection.x:
        FaceDirection=Vector2(1,0)
    elif FaceDirection.x<0 and abs(FaceDirection.y)<=-FaceDirection.x:
        FaceDirection=Vector2(-1,0)
    elif FaceDirection.y>0 and abs(FaceDirection.x)<FaceDirection.y:
        FaceDirection=Vector2(0,1)
    elif FaceDirection.y<0 and abs(FaceDirection.x)<-FaceDirection.y:
        FaceDirection=Vector2(0,-1)
        
func animation_function():
    var ani=""
    if (Attackable and $RigidTimer.time_left) or (Attacking and $AnimatedSprite.playing and $AnimatedSprite.animation.find("attack")!=-1):
        ani+="attack"
    else:
        $AnimatedSprite.playing=true
        ani+="normal"
        if movement==Vector2() or $RigidTimer.time_left:
            ani+="_stand"
        else:
            ani+="_walk"
    match(FaceDirection):
        Vector2(1,0):
            ani+="_right"
        Vector2(-1,0):
            ani+="_left"
        Vector2(0,1):
            ani+="_down"
        Vector2(0,-1):
            ani+="_up"                
    $AnimatedSprite.animation=ani
    if $AnimatedSprite.animation.find("attack")!=-1:
        if !Attacking and $AnimatedSprite.playing and $AnimatedSprite.frames.get_animation_speed(ani)*$AnimatedSprite.speed_scale*$RigidTimer.time_left>$AnimatedSprite.frames.get_frame_count(ani)-1:
            $AnimatedSprite.playing=false
            $AnimatedSprite.frame=0
#        print($AnimatedSprite.frames.get_animation_speed(ani)*$AnimatedSprite.speed_scale*$RigidTimer.time_left)
#        print($AnimatedSprite.frames.get_frame_count(ani)-1)
        elif !Attacking and !$AnimatedSprite.playing and $AnimatedSprite.frames.get_animation_speed(ani)*$AnimatedSprite.speed_scale*$RigidTimer.time_left<=$AnimatedSprite.frames.get_frame_count(ani)-1:
            $AnimatedSprite.playing=true
        elif Attacking and $AnimatedSprite.frame==0:
            $AnimatedSprite.playing=false
    
    $SightSprite.rotation=FaceDirection.angle()+PI/2

func _on_AttackColdTimer_timeout():
    if !$RigidTimer.time_left:
        Attackable=true

func _on_RigidTimer_timeout():
    if Attackable and !$AttackColdTimer.time_left:
        $AttackColdTimer.start()
        attack()
    elif $AttackColdTimer.time_left:
        Attacking=false
        Attackable=true

func raise_guard(pos:Vector2,value:float):
    if GuardingPosition.z<=value and (global_position-pos).length()<=value:
        GuardingPosition=Vector3(pos.x,pos.y,value)

func deferred_raise_guard(pos:Vector2,value:float):
    if AImode!="attacking":
        $CreatureStatus/GuardSign.animation="Guarding"
        $CreatureStatus/GuardSign.show()
    if $RaiseGuardTimer.time_left==0:
        $RaiseGuardTimer.start()
    yield($RaiseGuardTimer,"timeout")
    raise_guard(pos,value)

func die():
    $DisappearTimer.start()
    Exist=false
    $CollisionShape2D.queue_free()

func _on_DisappearTimer_timeout():
    queue_free()

func _on_RandomMoveTimer_timeout():
    if AImode!="default" or $RaiseGuardTimer.time_left:
        return
    for i in range(100):
        var RandomNumber=randi()%200
        var RandomMovement
        if RandomNumber%4==0:
            RandomMovement=Vector2(1,0)*(100+RandomNumber)
        elif RandomNumber%4==1:
            RandomMovement=Vector2(-1,0)*(100+RandomNumber)
        elif RandomNumber%4==2:
            RandomMovement=Vector2(0,1)*(100+RandomNumber)
        else:
            RandomMovement=Vector2(0,-1)*(100+RandomNumber)
        if !Global.detect_collision_in_line(global_position,global_position+RandomMovement,[self],0b100001):
            TargetPosition=global_position+RandomMovement
            return
