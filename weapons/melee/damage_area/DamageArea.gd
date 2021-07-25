extends Area2D

var identifier="DamageArea"
var Attack:float   
var SingleDamage:bool           #是否单体伤害
var Direction:Vector2 
var Camp:String="Player"        #发起攻击的阵营，和发射者一致，决定会对谁造成伤害
var KnockBack:float             #对目标造成的击退力
var DamageList:Dictionary={}    #造成伤害的目标列表，防止二次伤害
var Owner:Object                #发起这次攻击的对象实例


func init(_Attack:float,_SingleDamage:bool,_ExistTime:float,_Direction:Vector2,_Owner:Object,_Camp:String,_KnockBack:float):
    Attack=_Attack
    SingleDamage=_SingleDamage
    Direction=_Direction
    Camp=_Camp
    KnockBack=_KnockBack
    Owner=_Owner
    $DestroyTimer.wait_time=_ExistTime
    $DestroyTimer.start()

func _physics_process(delta):
    visible=true#避免第一帧方向错误采取的操作，可以改进

func _on_DamageArea_body_shape_entered(body_id, body, body_shape, local_shape):
    #当有实例进入伤害范围时触发此函数
    var collision=Global.detect_collision_in_line(global_position,body.global_position,[self], 1)
    #此处探测射线的最后一个参数为1，代表碰撞mask为0x00001，即只检测layer1的碰撞，也就是障碍物
    if collision:
        return
    elif body.CreatureStatus.Camp=="Player" and Camp=="Enermy":
        if DamageList.get(body)==null:
            hit_target(body)  
            if SingleDamage:
                $CollisionShape2D.queue_free()      
    elif body.CreatureStatus.Camp=="Enermy" and Camp=="Player":
        if DamageList.get(body)==null:
            hit_target(body)
            if SingleDamage:
                $CollisionShape2D.queue_free()   

func hit_target(target):#命中目标，并造成相应的击退
    if target!=null:
        target.CreatureStatus.get_hurt(Attack,"melee_damage",Owner)
        DamageList[target]=false
        var tempKnockback=Vector2(target.KnockBack.x,target.KnockBack.y)*target.KnockBack.z+Direction.normalized()*KnockBack
        target.KnockBack.z=tempKnockback.length()
        target.KnockBack.x=tempKnockback.normalized().x
        target.KnockBack.y=tempKnockback.normalized().y

func _on_DestroyTimer_timeout():#摧毁自身
    queue_free()
