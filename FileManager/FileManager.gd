extends Node

func load_data():
    var SaveFile=File.new()
    SaveFile.open("res://save/save.txt",File.READ)
    while !SaveFile.eof_reached():
        var TempLine=SaveFile.get_line()
        match TempLine:
            "@GoodInHome":
                Global.GoodInHome={}
                TempLine=SaveFile.get_line()
                while TempLine!="@end":
                    var Contents=TempLine.split(" ")
                    Global.GoodInHome[Contents[0]]=int(Contents[1])
                    TempLine=SaveFile.get_line()
            "@GoodInBackpack":
                Global.GoodInBackpack={}
                TempLine=SaveFile.get_line()
                while TempLine!="@end":
                    var Contents=TempLine.split(" ")
                    Global.GoodInBackpack[Contents[0]]=int(Contents[1])
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
    SaveFile.store_string("@GoodInBackpack\n")
    for key in Global.GoodInBackpack:
        SaveFile.store_string(key+" "+String(Global.GoodInBackpack[key])+"\n")
    SaveFile.store_string("@end\n")
