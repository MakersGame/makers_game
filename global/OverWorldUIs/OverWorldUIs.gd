extends Node2D

var MaxHealth:int
var TempHealth:float
var MaxEnergy:int
var TempEnergy:float
var FocusCreature:Object=null

func set_ui():   
    MaxHealth=Global.CurrentScene.get_node("Player").CreatureStatus.MaxHealth
    TempHealth=Global.CurrentScene.get_node("Player").CreatureStatus.Health
    $HealthBar/Bar.max_value=MaxHealth
    $HealthBar/MaxHealthValue.text="/"+String(MaxHealth)
    
    $EnergyBar/TiredOutBar.hide()
    $EnergyBar/Bar.show()
    MaxEnergy=Global.CurrentScene.get_node("Player").MaxEnergy
    TempEnergy==Global.CurrentScene.get_node("Player").Energy
    $EnergyBar/TiredOutBar.max_value=MaxEnergy
    $EnergyBar/Bar.max_value=MaxEnergy
    
    $CreatureInfo.hide()
    
    var RangedWeapon=Global.CurrentScene.get_node("Player").get_node("RangedWeapon")
    var MeleeWeapon=Global.CurrentScene.get_node("Player").get_node("MeleeWeapon")
    if RangedWeapon!=null:
        $WeaponChoice/RangedWeapon/AnimatedSprite.animation=RangedWeapon.Name
    else:
        $WeaponChoice/RangedWeapon/AnimatedSprite.animation="default"
    if MeleeWeapon!=null:
        $WeaponChoice/MeleeWeapon/AnimatedSprite.animation=MeleeWeapon.Name
    else:
        $WeaponChoice/MeleeWeapon/AnimatedSprite.animation="default"
    
func _process(delta):
    global_position=Global.PlayerCamera.global_position-Vector2(640,360)
    
    $HealthBar/Bar.value=TempHealth
    $HealthBar/TempHealthValue.text=String(round(TempHealth))
    
    $EnergyBar/Bar.value=TempEnergy
    $EnergyBar/TiredOutBar.value=TempEnergy
    
    if FocusCreature!=null and FocusCreature.alive():
        $CreatureInfo/CreatureHealth.text=String(FocusCreature.Health)+"/"+String(FocusCreature.MaxHealth)
    elif FocusCreature!=null:
        $CreatureInfo/CreatureHealth.text="0/"+String(FocusCreature.MaxHealth)
        FocusCreature=null
        $CreatureInfo/MaintainTimer.start()
        
func update_health(NewValue:float):
    $HealthBar/Tween.interpolate_property(self,"TempHealth",TempHealth,NewValue,0.5)
    if not $HealthBar/Tween.is_active():
        $HealthBar/Tween.start()

func update_energy(NewValue:float):
    $EnergyBar/Tween.interpolate_property(self,"TempEnergy",TempEnergy,NewValue,0.1)
    if not $EnergyBar/Tween.is_active():
        $EnergyBar/Tween.start()
    if NewValue<=0:
        $EnergyBar/TiredOutBar.show()
        $EnergyBar/Bar.hide()
    elif NewValue>=MaxEnergy and !$EnergyBar/Bar.visible:
        $EnergyBar/TiredOutBar.hide()
        $EnergyBar/Bar.show()

func enable_creature_info(creature):
    FocusCreature=creature
    $CreatureInfo/CreatureName.text=creature.get_parent().Name
    $CreatureInfo/CreatureAttack.text=String(creature.Attack)  
    $CreatureInfo.show()
    $CreatureInfo/MaintainTimer.stop()
    
func disable_creature_info(creature):
    if FocusCreature==creature:
        FocusCreature=null
        $CreatureInfo/MaintainTimer.start()
    
func _on_MaintainTimer_timeout():
    $CreatureInfo.hide()

func update_weapon_choice(type):
    if type=="ranged":
        $WeaponChoice/WeaponChangeAnimation.play("MeleeToRanged")   
    elif type=="melee":
        $WeaponChoice/WeaponChangeAnimation.play_backwards("MeleeToRanged")

