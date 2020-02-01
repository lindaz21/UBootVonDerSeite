extends KinematicBody2D

const World = preload("res://levels/World.gd")

var gravity = 10
const floorUp = Vector2(0, -1)
export var speed = 200

export (NodePath) onready var drop_item_to
export (Array) var keymap

# Do not export, because then it cannot be easily nulled at the beginning
# If this is exported, there is a ghostitem in the players hand that has
# to be discarded before he can pick up any object
var holding

var velocity = Vector2()
var ladder_on = false

func _ready():
	self.add_to_group("players")

func _physics_process(delta):
	var movement_direction = 0;
	gravity = 10
	
	velocity.y += gravity
	if is_on_floor():
		velocity.y = gravity
		if Input.is_action_pressed('jump'):
			velocity.y = -300
	
		
	if Input.is_action_pressed(keymap[2]):
		movement_direction -= speed
	
	if Input.is_action_pressed(keymap[3]):
		movement_direction += speed
	if ladder_on == true:
		gravity = 0
		if Input.is_action_pressed(keymap[1]):
			velocity.y = speed
		elif Input.is_action_pressed(keymap[0]):
			velocity.y = -speed
		
	velocity.x = movement_direction

	velocity = move_and_slide(velocity, floorUp)
	
	if Input.is_action_pressed(keymap[4]):
		var areas = $Area2D.get_overlapping_areas()
		if areas.size() > 0 && areas[0].has_method("interact_with_player"):
			areas[0].call("interact_with_player", self)
			
	if Input.is_action_pressed(keymap[5]):
		if holding != null:
			var itemtodrop = pickupable.new()
			itemtodrop.texture = load("res://items/interactables/bed/Bedsheet.png")
			itemtodrop.item_type = holding
			# Set itemposition to player position. Otherwise it will spawn
			# at (0,0)
			itemtodrop.position = self.position
			get_node(drop_item_to).add_child(itemtodrop)
		self.set_holding(null)
		
func can_pickup():
	return holding == null
		
func take_item():
	var item = self.holding
	self.set_holding(null)
	return item
	
func take_item_if_eq(item):
	holding = self.holding
	if holding == item:
		self.set_holding(null)
		return holding
	else:
		return null
		
func set_holding(item):
	holding = item
	
	if item == null:
		$Holding.texture = null
	else:
		var asset = "";
		match item:
			World.Item.Gasoline:
				asset = "gasoline/Gasoline.png"
			World.Item.Bucket:
				asset = "bucket/Bucket.png"
			World.Item.Bedsheet:
				asset = "bed/Bedsheet.png"
		$Holding.texture = load("res://items/interactables/" + asset)
