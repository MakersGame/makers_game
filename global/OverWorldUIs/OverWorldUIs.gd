extends Node2D

var MaxHealth:int
var TempHealth:float
var MaxEnergy:int
var TempEnergy:float
var FocusCreature:Object=null
var TempRangedWeaponReloadTime:float=0
var TempMeleeWeaponReloadTime:float=0

func set_ui():   
    MaxHealth=Global.CurrentScene.get_node("Player").CreatureStatus.MaxHealth
    TempHealth=Global.CurrentScene.get_node("Player").CreatureStatus.Health
    $HealthBar/Bar.max_value=MaxHealth
    $HealthBar/MaxHealthValue.text="/"+String(MaxHealth)
    
    $EnergyBar/TiredOutBar.hide()
    $EnergyBar/Bar.show()
    MaxEnergy=Global.CurrentScene.get_node("Player").MaxEnergy
    #TempEnergy==Global.CurrentScene.get_node("Player").Energy
    $EnergyBar/TiredOutBar.max_value=MaxEnergy
    $EnergyBar/Bar.max_value=MaxEnergy
    
    $CreatureInfo.hide()
    
    update_weapon_choice()
        
    update_quick_item()
    
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
    
    $WeaponChoice/MeleeWeapon/ReloadBar.value=TempMeleeWeaponReloadTime
    if TempMeleeWeaponReloadTime<=0:
        $WeaponChoice/MeleeWeapon/ReloadBar.hide()
    $WeaponChoice/RangedWeapon/ReloadBar.value=TempRangedWeaponReloadTime
    if TempRangedWeaponReloadTime<=0:
        $WeaponChoice/RangedWeapon/ReloadBar.hide()
        
func update_health(NewValue:float):
    $HealthBar/Tween.interpolate_property(self,"TempHealth",TempHealth,NewValue,0.5)
    if not $HealthBar/Tween.is_active():
        $HealthBar/Tween.start()

func update_energy(NewValue:float):
    if NewValue==TempEnergy:
        return
    $EnergyBar/Tween.interpolate_property(self,"TempEnergy",TempEnergy,NewValue,0.1*abs(TempEnergy-NewValue)/20)
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
        $CreatureInfo/MaintainTimer.start()
    
func _on_MaintainTimer_timeout():
    $CreatureInfo.hide()

func update_weapon_choice():
    var RangedWeapon=Global.CurrentScene.get_node("Player").get_node("RangedWeapon")
    var MeleeWeapon=Global.CurrentScene.get_node("Player").get_node("MeleeWeapon")
    if RangedWeapon==null or !RangedWeapon.Enable:
        $WeaponChoice/RangedWeapon/AnimatedSprite.animation="null"
        $WeaponChoice/RangedWeapon/DurabilityBar.hide()
        $WeaponChoice/RangedWeapon/BulletNumber.hide()
    else:
        $WeaponChoice/RangedWeapon/AnimatedSprite.animation=RangedWeapon.Name
        $WeaponChoice/RangedWeapon/DurabilityBar.max_value=RangedWeapon.MaxDurability
        $WeaponChoice/RangedWeapon/DurabilityBar.value=RangedWeapon.Durability
        $WeaponChoice/MeleeWeapon/DurabilityBar.show()
        $WeaponChoice/RangedWeapon/BulletNumber.text="?????? "+String(RangedWeapon.BulletNum)
    if MeleeWeapon==null or !MeleeWeapon.Enable:
        $WeaponChoice/MeleeWeapon/AnimatedSprite.animation="null"
        $WeaponChoice/MeleeWeapon/DurabilityBar.hide()
    else:
        $WeaponChoice/MeleeWeapon/AnimatedSprite.animation=MeleeWeapon.Name
        $WeaponChoice/MeleeWeapon/DurabilityBar.max_value=MeleeWeapon.MaxDurability
        $WeaponChoice/MeleeWeapon/DurabilityBar.value=MeleeWeapon.Durability
        $WeaponChoice/MeleeWeapon/DurabilityBar.show()

func weapon_reload_change(Type:String):
    if Type=="RangedWeapon":
        var RangedWeapon=Global.CurrentScene.get_node("Player").get_node("RangedWeapon")
        if  RangedWeapon==null or !RangedWeapon.Enable:
            $WeaponChoice/RangedWeapon/ReloadBar.hide()
        elif RangedWeapon.get_node("ReloadTimer").time_left:
            TempRangedWeaponReloadTime=100
            $WeaponChoice/RangedWeapon/Tween.interpolate_property(self,"TempRangedWeaponReloadTime",TempRangedWeaponReloadTime,0,RangedWeapon.get_node("ReloadTimer").time_left)
            if not $WeaponChoice/RangedWeapon/Tween.is_active():
                $WeaponChoice/RangedWeapon/Tween.start()
            $WeaponChoice/RangedWeapon/ReloadBar.show()
        else:
            $WeaponChoice/RangedWeapon/ReloadBar.hide()
    elif Type=="MeleeWeapon":
        var MeleeWeapon=Global.CurrentScene.get_node("Player").get_node("MeleeWeapon")
        if  MeleeWeapon==null or !MeleeWeapon.Enable:
            $WeaponChoice/MeleeWeapon/ReloadBar.hide()
        elif MeleeWeapon.get_node("ColdTimer").time_left:
            TempMeleeWeaponReloadTime=100
            $WeaponChoice/MeleeWeapon/Tween.interpolate_property(self,"TempMeleeWeaponReloadTime",TempMeleeWeaponReloadTime,0,MeleeWeapon.get_node("ColdTimer").time_left)
            $WeaponChoice/MeleeWeapon/ReloadBar.show()
            if not $WeaponChoice/MeleeWeapon/Tween.is_active():
                $WeaponChoice/MeleeWeapon/Tween.start()
        else:
            $WeaponChoice/MeleeWeapon/ReloadBar.hide()
    
func change_weapon_choice(type):
    if type=="ranged":
        $WeaponChoice/WeaponChangeAnimation.play("MeleeToRanged")   
    elif type=="melee":
        $WeaponChoice/WeaponChangeAnimation.play_backwards("MeleeToRanged")

func update_quick_item():
    $QuickUseItem/QucikItemChoice.global_position=$QuickUseItem/InventoryList.get_node("Inventory"+String(Global.QuickUseItemChoice+1)).global_position
    for i in range(5):
        var Inventory=$QuickUseItem/InventoryList.get_node("Inventory"+String(i+1))
        if Global.QuickUseItem[i]!=null:
            if Global.GoodInBackpack[Global.QuickUseItem[i]]<=0:
                Global.QuickUseItem[i]=null
                Inventory.get_node("AnimatedSprite").animation="null"
                Inventory.get_node("ItemNumber").text=""
            else:
                Inventory.get_node("AnimatedSprite").animation=Global.QuickUseItem[i]
                Inventory.get_node("ItemNumber").text=String(Global.GoodInBackpack[Global.QuickUseItem[i]])
        else:
            Inventory.get_node("AnimatedSprite").animation="null"
            Inventory.get_node("ItemNumber").text=""


    
    
func send_message(Message:String):
    if $Message/Message1.text=="":
        $Message/Message1.text=Message
        $Message/Message1/Messager1Timer.start()
    elif $Message/Message2.text=="":
        $Message/Message2.text=Message
        $Message/Message2/Messager2Timer.start()
    else:
        if  $Message/Message3.text!="":
            _on_Messager1Timer_timeout()
        $Message/Message3.text=Message
        $Message/Message3/Messager3Timer.start()

func _on_Messager1Timer_timeout():
    $Message/Message1.text=$Message/Message2.text
    $Message/Message1/Messager1Timer.stop()
    if $Message/Message1.text=="":
        $Message/Message1/Messager1Timer.wait_time=3
    else:
        $Message/Message1/Messager1Timer.wait_time=$Message/Message2/Messager2Timer.time_left
        $Message/Message1/Messager1Timer.start()
        _on_Messager2Timer_timeout()

func _on_Messager2Timer_timeout():
    $Message/Message2.text=$Message/Message3.text
    $Message/Message2/Messager2Timer.stop()
    if $Message/Message2.text=="":
        $Message/Message2/Messager2Timer.wait_time=3
    else:
        $Message/Message2/Messager2Timer.wait_time=$Message/Message3/Messager3Timer.time_left
        $Message/Message2/Messager2Timer.start()
        _on_Messager3Timer_timeout()

func _on_Messager3Timer_timeout():
    $Message/Message3.text=""
    $Message/Message3/Messager3Timer.wait_time=3
    $Message/Message3/Messager3Timer.stop()

func update_clock():
    $Clock/Time.text=""
    if Global.WorldTime.x<10:
        $Clock/Time.text+=" "
    $Clock/Time.text+=String(Global.WorldTime.x)+":"
    if Global.WorldTime.y<10:
        $Clock/Time.text+="0"
    $Clock/Time.text+=String(Global.WorldTime.y)
    if Global.WorldTime.x>=6 and Global.WorldTime.x<18:
        $Clock/Period.text="??????"
    elif Global.WorldTime.x>=18 and Global.WorldTime.x<20:
        $Clock/Period.text="??????"
    else:
        $Clock/Period.text="??????"

