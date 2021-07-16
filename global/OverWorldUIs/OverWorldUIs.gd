extends Node2D

var MaxHealth:int
var TempHealth:float
var MaxEnergy:int
var TempEnergy:float

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
    
func _process(delta):
    global_position=Global.PlayerCamera.global_position-Vector2(640,360)
    $HealthBar/Bar.value=TempHealth
    $HealthBar/TempHealthValue.text=String(round(TempHealth))
    $EnergyBar/Bar.value=TempEnergy
    $EnergyBar/TiredOutBar.value=TempEnergy
    
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

