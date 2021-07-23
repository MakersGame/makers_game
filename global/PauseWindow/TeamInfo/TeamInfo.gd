extends Node2D

var DetailedMember:Object   #当前查看的详细信息的队员
var WeaponTypeChosen:String=""

func update_team():
    if !DetailedMember in Global.Team:
        DetailedMember=Global.Team[0]
    $Members/Player/AnimatedSprite.animation="info"
    if Global.Team.size()>1:
        $Members/NPC1/AnimatedSprite.frames=Global.Team[1].get_node("AnimatedSprite").frames
        $Members/NPC1/AnimatedSprite.animation="info"
        $Members/NPC1.show()
    else:
        $Members/NPC1.hide()
    if Global.Team.size()>2:
        $Members/NPC2/AnimatedSprite.frames=Global.Team[2].get_node("AnimatedSprite").frames
        $Members/NPC2/AnimatedSprite.animation="info"
        $Members/NPC2.show()
    else:
        $Members/NPC2.hide()
    if Global.Team.size()>3:
        $Members/NPC3/AnimatedSprite.frames=Global.Team[3].get_node("AnimatedSprite").frames
        $Members/NPC3/AnimatedSprite.animation="info"
        $Members/NPC3.show()
    else:
        $Members/NPC3.hide()
    update_detail()

func update_detail():
    $Detail/Name.text="姓名:"+DetailedMember.Name
    $Detail/Level.text="等级：未知"#之后完善
    $Detail/EnergyBar.max_value=DetailedMember.MaxEnergy
    $Detail/EnergyBar.value=DetailedMember.Energy
    $Detail/EnergyBar/EnergyValue.text=String(round(DetailedMember.Energy))+"/"+String(round(DetailedMember.MaxEnergy))
    $Detail/HealthBar.max_value=DetailedMember.CreatureStatus.MaxHealth
    $Detail/HealthBar.value=DetailedMember.CreatureStatus.Health
    $Detail/HealthBar/HealthValue.text=String(round(DetailedMember.CreatureStatus.Health))+"/"+String(round(DetailedMember.CreatureStatus.MaxHealth))
    if DetailedMember.get_node("MeleeWeapon").Enable:
        $Detail/MeleeWeapon/AnimatedSprite.animation=DetailedMember.get_node("MeleeWeapon").Name
        var Durability=DetailedMember.get_node("MeleeWeapon").Durability
        var MaxDyrability=DetailedMember.get_node("MeleeWeapon").MaxDurability
        $Detail/MeleeWeapon/DurabilityBar.max_value=MaxDyrability
        $Detail/MeleeWeapon/DurabilityBar.value=Durability
        $Detail/MeleeWeapon/DurabilityBar/DurabilityValue.text=String(Durability)+"/"+String(MaxDyrability)
        $Detail/MeleeWeapon/DurabilityBar.show()
        $Buttons/TakeOffMeleeWeaponButton.show()
    else:
        $Detail/MeleeWeapon/AnimatedSprite.animation="null"
        $Detail/MeleeWeapon/DurabilityBar.hide()
        $Buttons/TakeOffMeleeWeaponButton.hide()
    if DetailedMember.get_node("RangedWeapon").Enable:
        $Detail/RangedWeapon/AnimatedSprite.animation=DetailedMember.get_node("RangedWeapon").Name
        var Durability=DetailedMember.get_node("RangedWeapon").Durability
        var MaxDyrability=DetailedMember.get_node("RangedWeapon").MaxDurability
        $Detail/RangedWeapon/DurabilityBar.max_value=MaxDyrability
        $Detail/RangedWeapon/DurabilityBar.value=Durability
        $Detail/RangedWeapon/DurabilityBar/DurabilityValue.text=String(Durability)+"/"+String(MaxDyrability)
        $Detail/RangedWeapon/DurabilityBar.show()
        $Buttons/TakeOffRangedWeaponButton.show()
    else:
        $Detail/RangedWeapon/AnimatedSprite.animation="null"
        $Detail/RangedWeapon/DurabilityBar.hide()
        $Buttons/TakeOffRangedWeaponButton.hide()
    $WeaponChoiceWindow.hide()
    WeaponTypeChosen=""

func _on_Player_pressed():
    DetailedMember=Global.Team[0]
    update_detail()

func _on_NPC1_pressed():
    if Global.Team.size()<2:
        return
    DetailedMember=Global.Team[1]
    update_detail()

func _on_NPC2_pressed():
    if Global.Team.size()<3:
        return
    DetailedMember=Global.Team[2]
    update_detail()

func _on_NPC3_pressed():
    if Global.Team.size()<4:
        return
    DetailedMember=Global.Team[3]
    update_detail()

func weapon_change(num:int):
    if WeaponTypeChosen=="":
        return
    if DetailedMember.get_node(WeaponTypeChosen).Enable:
        var OriginalWeapon={"Name":DetailedMember.get_node(WeaponTypeChosen).Name,"Durability":DetailedMember.get_node(WeaponTypeChosen).Durability}
        Global.WeaponInBackpack.push_back(OriginalWeapon)
    if num<0:
        DetailedMember.change_weapon(WeaponTypeChosen,-1)
    else:
        DetailedMember.change_weapon(WeaponTypeChosen,num)
        Global.WeaponInBackpack.remove(num) 
    WeaponTypeChosen=""
    $WeaponChoiceWindow.hide()
    Global.update_pause_window()   
        
func _on_change_melee_weapon():
    if WeaponTypeChosen!="MeleeWeapon":
        $WeaponChoiceWindow.position.x=0
        $WeaponChoiceWindow.update_weapons("MeleeWeapon")
        $WeaponChoiceWindow.show()
        WeaponTypeChosen="MeleeWeapon"
    elif $WeaponChoiceWindow.visible:
        $WeaponChoiceWindow.hide()
        WeaponTypeChosen=""

func _on_change_ranged_weapon():
    if WeaponTypeChosen!="RangedWeapon":
        $WeaponChoiceWindow.position.x=200
        $WeaponChoiceWindow.update_weapons("RangedWeapon")
        $WeaponChoiceWindow.show()
        WeaponTypeChosen="RangedWeapon"
    elif $WeaponChoiceWindow.visible:
        $WeaponChoiceWindow.hide()
        WeaponTypeChosen=""

func _on_TakeOffMeleeWeaponButton_pressed():
    if DetailedMember.get_node("MeleeWeapon").Enable:
        var OriginalWeapon={"Name":DetailedMember.get_node("MeleeWeapon").Name,"Durability":DetailedMember.get_node("MeleeWeapon").Durability}
        Global.WeaponInBackpack.push_back(OriginalWeapon)
        DetailedMember.change_weapon("MeleeWeapon",-1)
    WeaponTypeChosen=""
    $WeaponChoiceWindow.hide()
    Global.update_pause_window() 
        
func _on_TakeOffRangedWeaponButton_pressed():
    if DetailedMember.get_node("RangedWeapon").Enable:
        var OriginalWeapon={"Name":DetailedMember.get_node("RangedWeapon").Name,"Durability":DetailedMember.get_node("RangedWeapon").Durability}
        Global.WeaponInBackpack.push_back(OriginalWeapon)
        DetailedMember.change_weapon("RangedWeapon",-1)
    WeaponTypeChosen=""
    $WeaponChoiceWindow.hide()
    Global.update_pause_window() 
