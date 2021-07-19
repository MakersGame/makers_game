extends Node2D

var DetailedMember:Object   #当前查看的详细信息的队员

func update_team():
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
    if DetailedMember.get_node("MeleeWeapon")!=null:
        $Detail/MeleeWeapon/AnimatedSprite.animation=DetailedMember.get_node("MeleeWeapon").Name
    else:
        $Detail/MeleeWeapon/AnimatedSprite.animation="default"
    if DetailedMember.get_node("RangedWeapon")!=null:
        $Detail/RangedWeapon/AnimatedSprite.animation=DetailedMember.get_node("RangedWeapon").Name
    else:
        $Detail/RangedWeapon/AnimatedSprite.animation="default"

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
