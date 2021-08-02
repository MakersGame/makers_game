extends Node

func load_data():
    var SaveFile=File.new()
    SaveFile.open("res://save/save.txt",File.READ)
    while !SaveFile.eof_reached():
        var TempLine=SaveFile.get_line()
        match TempLine:
            "@HomeUpdateInfo":
                Global.HomeUpdateInfo={}
                TempLine=SaveFile.get_line()
                while TempLine!="@end":
                    var Contents=TempLine.split(" ")
                    Global.HomeUpdateInfo[Contents[0]]=int(Contents[1])
                    TempLine=SaveFile.get_line()
            "@GoodInHome":
                Global.GoodInHome={}
                TempLine=SaveFile.get_line()
                while TempLine!="@end":
                    var Contents=TempLine.split(" ")
                    Global.GoodInHome[Contents[0]]=int(Contents[1])
                    TempLine=SaveFile.get_line()
            "@WeaponInHome":
                Global.WeaponInHome=[]
                TempLine=SaveFile.get_line()
                while TempLine!="@end":
                    var Contents=TempLine.split(" ")
                    Global.WeaponInHome.push_back({"Name":Contents[0],"Durability":float(Contents[1])})
                    TempLine=SaveFile.get_line()
            "@GoodInBackpack":
                Global.GoodInBackpack={}
                TempLine=SaveFile.get_line()
                while TempLine!="@end":
                    var Contents=TempLine.split(" ")
                    Global.GoodInBackpack[Contents[0]]=int(Contents[1])
                    TempLine=SaveFile.get_line()
            "@WeaponInBackpack":
                Global.WeaponInBackpack=[]
                TempLine=SaveFile.get_line()
                while TempLine!="@end":
                    var Contents=TempLine.split(" ")
                    Global.WeaponInBackpack.push_back({"Name":Contents[0],"Durability":float(Contents[1])})
                    TempLine=SaveFile.get_line()
            _:
                continue

func save_data():
    var SaveFile=File.new()
    SaveFile.open("res://save/save.txt",File.WRITE)
    SaveFile.store_string("@GoodInHome\n")
    for key in Global.GoodInHome:
        SaveFile.store_string(key+" "+String(Global.GoodInHome[key])+"\n")
    SaveFile.store_string("@end\n")
    SaveFile.store_string("\n")
    SaveFile.store_string("@WeaponInHome\n")
    for i in Global.WeaponInHome:
        SaveFile.store_string(i["Name"]+" "+String(i["Durability"])+"\n")
    SaveFile.store_string("@end\n")
    SaveFile.store_string("\n")
    SaveFile.store_string("@GoodInBackpack\n")
    for key in Global.GoodInBackpack:
        SaveFile.store_string(key+" "+String(Global.GoodInBackpack[key])+"\n")
    SaveFile.store_string("@end\n")
    SaveFile.store_string("@WeaponInBackpack\n")
    for i in Global.WeaponInBackpack:
        SaveFile.store_string(i["Name"]+" "+String(i["Durability"])+"\n")
    SaveFile.store_string("@end\n")
