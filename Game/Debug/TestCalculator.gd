extends Node

func _ready():
	await get_tree().process_frame
	print("_______")
	perform_test()

func perform_test():
	var volatility = randf_range(0.1,1)
	var in_shadow = [true,false].pick_random()
	
	var le := Element.get_random(Vector2i(0,5),Vector2i(0,10))
	var me := Element.get_random(Vector2i(10,20),Vector2i(30,60))
	var he := Element.get_random(Vector2i(40,50),Vector2i(90,101))
	
	var la := Alloy.get_random(Vector2i(0,5),Vector2i(0,10))
	var ma := Alloy.get_random(Vector2i(10,20),Vector2i(30,60))
	var ha := Alloy.get_random(Vector2i(40,50),Vector2i(90,101))
	
	print("Performing Test")
	print("Volatility: ",volatility," / In Shadow: ", in_shadow)
	var r1 = randi_range(0,2)
	var r2 = randi_range(0,2)
	var ue : Element = [le,me,he][r1]
	print(ue.get_namegb())
	print("Using ",["Low","Med","High"][r1]," Element: value ",ue.calculate_value(volatility))
	var ua : Alloy = [la,ma,ha][r2]
	print(ua.get_namegb())
	print("Using ",["Low","Med","High"][r2]," Alloy: value ",ue.calculate_value(volatility))
	
	var m := Mixture.new()
	m.m1 = ue
	m.m2 = ua
	m.created_in_shadow = in_shadow
	#use get_random here
	
	print("final value: ", await m.calculate_value())
	print("align: ",["dark","light"][m.get_alignment()])
