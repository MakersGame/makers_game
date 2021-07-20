extends Node2D

var DropNumber=1
var DropLimit=0

func init(_Droplimit):
    DropLimit=_Droplimit

signal DropItem
signal QuitDropItem

func _on_OKbutton_pressed():
    emit_signal("DropItem")
    hide()

func _on_QuitButton_pressed():
    emit_signal("QuitDropItem")
    hide()


func _on_LineEdit_text_changed(new_text):
    if $LineEdit.text=="":
        DropNumber=0
    else:
        $LineEdit.text=String(abs($LineEdit.text.to_int()))
    if $LineEdit.text.to_int()>DropLimit:
        $LineEdit.text=String(DropLimit)
    DropNumber=$LineEdit.text.to_int()
    $LineEdit.caret_position=$LineEdit.text.length()

func _on_LineEdit_text_entered(new_text):
    emit_signal("DropItem")
    hide()
