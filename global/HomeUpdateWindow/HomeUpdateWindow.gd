extends Node2D

var UpdateChoice:int=1
var CurrentPage:int=1
var AllUpdateProject=[]

func _physics_process(delta):
    global_position=Global.PlayerCamera.global_position-Vector2(640,360)

func refresh_update_window():
    AllUpdateProject=[]
    for i in range(7):
        get_node("Buttons/Button"+String(i+1)).show()
    for key in Global.HomeUpdateInfo.keys():
        if Global.HomeUpdateInfo[key]<4:
            AllUpdateProject.push_back({"Name":key,"Level":Global.HomeUpdateInfo[key]})
    if AllUpdateProject.size()>7:
        $ScrollBar/Bar.scale.y=7/AllUpdateProject.size()
        $ScrollBar.show()
    else:
        $ScrollBar/Bar.scale.y=1
        $ScrollBar.hide()
        for i in range(AllUpdateProject.size()+1,8):
            get_node("Buttons/Button"+String(i)).hide()  
    $ScrollBar/Bar.position.y=-122
    
    for i in range(7):
        if i<=AllUpdateProject.size()-CurrentPage:
            get_node("Buttons/Button"+String(i+1)+"/Label").text=AllUpdateProject[i]["Name"]
    
    $Chosen.global_position=$Buttons.global_position+get_node("Buttons/Button"+String(UpdateChoice)).rect_position
    
    var Updatable=true
    $UpdateDetail/Name.text=AllUpdateProject[UpdateChoice+CurrentPage-2]["Name"]
    $UpdateDetail/Level.text="等级  "+String(AllUpdateProject[UpdateChoice+CurrentPage-2]["Level"])
    $UpdateDetail/Description.text=ReferenceList.HomeUpdateReference[AllUpdateProject[UpdateChoice+CurrentPage-2]["Name"]][AllUpdateProject[UpdateChoice+CurrentPage-2]["Level"]]["Description"]
    var Need=ReferenceList.HomeUpdateReference[AllUpdateProject[UpdateChoice+CurrentPage-2]["Name"]][AllUpdateProject[UpdateChoice+CurrentPage-2]["Level"]]["Need"]
    for key in Need.keys():
        var Number=0
        if Global.GoodInBackpack.get(key)!=null:
            Number+=Global.GoodInBackpack[key]
        if Global.GoodInHome.get(key)!=null:
            Number+=Global.GoodInHome[key]
        $UpdateDetail/Need.bbcode_text=""    
        if Number>=Need[key]:
            $UpdateDetail/Need.bbcode_text+=key+"\t"+String(Need[key])+"\n"
        else:
            $UpdateDetail/Need.bbcode_text+="[color=red]"+key+"\t"+String(Need[key])+"[color=red/]"+"\n"
            Updatable=false
    if Updatable:
        $UpdateDetail/UpdateButton.show()
    else:
        $UpdateDetail/UpdateButton.hide()
    
func _input(event):
    if event.is_action_pressed("ui_focus_next") and AllUpdateProject.size()>CurrentPage+6:
        CurrentPage+=1
        $ScrollBar/Bar.position.y+=122*$ScrollBar/Bar.scale.y*2
        refresh_update_window()
    elif event.is_action_pressed("ui_focus_prev") and CurrentPage>1:
        CurrentPage-=1
        $ScrollBar/Bar.position.y-=122*$ScrollBar/Bar.scale.y*2
        refresh_update_window()
               
func _on_Button1_pressed():
    UpdateChoice=1
    refresh_update_window()

func _on_Button2_pressed():
    UpdateChoice=2
    refresh_update_window()
    
func _on_Button3_pressed():
    UpdateChoice=3
    refresh_update_window()

func _on_Button4_pressed():
    UpdateChoice=4
    refresh_update_window()

func _on_Button5_pressed():
    UpdateChoice=5
    refresh_update_window()

func _on_Button6_pressed():
    UpdateChoice=6
    refresh_update_window()
   
func _on_Button7_pressed():
    UpdateChoice=7
    refresh_update_window()
 


func _on_UpdateButton_pressed():
    var Need=ReferenceList.HomeUpdateReference[AllUpdateProject[UpdateChoice+CurrentPage-2]["Name"]][AllUpdateProject[UpdateChoice+CurrentPage-2]["Level"]]["Need"]
    for key in Need.keys():
        var Number=Need[key]
        if Global.GoodInBackpack.get(key)!=null:
            if Global.GoodInBackpack[key]>=Number:
                Global.GoodInBackpack[key]-=Number
                Number=0
            else:
                Number-=Global.GoodInBackpack[key]
                Global.GoodInBackpack[key]=0
        if Global.GoodInHome.get(key)!=null:
            if Global.GoodInHome[key]>=Number:
                Global.GoodInHome[key]-=Number
                Number=0
            else:
                Number-=Global.GoodInHome[key]
                Global.GoodInHome[key]=0
    Global.HomeUpdateInfo[AllUpdateProject[UpdateChoice+CurrentPage-2]["Name"]]+=1
    if Global.HomeUpdateInfo[AllUpdateProject[UpdateChoice+CurrentPage-2]["Name"]]>=4:
        CurrentPage=1
        UpdateChoice=1
    Global.update_pause_window()
