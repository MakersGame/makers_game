extends Node2D

var UserFocused:int=0      #鼠标聚焦的物品栏

func update_item_user():
    if Global.Team.size():
        $UserList/User1.update_sprite(Global.Team[0])
        $UserList/User1.show()
    if Global.Team.size()>1:
        $UserList/User2.update_sprite(Global.Team[1])
        $UserList/User2.show()
    else:
        $UserList/User2.hide()
    if Global.Team.size()>2:
        $UserList/User3.update_sprite(Global.Team[2])
        $UserList/User3.show()
    else:
        $UserList/User3.hide()
    if Global.Team.size()>3:
        $UserList/User4.update_sprite(Global.Team[3])
        $UserList/User4.show()  
    else:
        $UserList/User4.hide()

func _input(event):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        if UserFocused>0:
            get_parent().use_item(Global.Team[UserFocused-1])

func user_focus_get(Num:int):
    UserFocused=Num
    $UserFocused.global_position=$UserList.get_node("User"+String(UserFocused)).global_position
    $UserFocused.show()

func user_focus_lose(Num:int):
    if UserFocused==Num:
        UserFocused=0
        $UserFocused.hide()       
