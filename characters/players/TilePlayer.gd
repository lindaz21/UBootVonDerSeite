extends KinematicBody2D

var gravity = 800
onready var velocity:Vector2 = Vector2.ZERO

export var speed = 65

var is_on_ladder = false
var can_jump = false

var prefix

export (NodePath) onready var drop_item_to
export (NodePath) onready var tilemap

# Do not export, because then it cannot be easily nulled at the beginning
# If this is exported, there is a ghostitem in the players hand that has
# to be discarded before he can pick up any object
var holding

const World = preload("res://levels/World.gd")

func _ready():
	self.add_to_group("players")

	
func _process(_delta):
	velocity.x = 0
	if is_on_ladder:
		gravity = 0
		velocity.y = 0
	else:
		gravity = 800

	if Input.is_action_pressed(prefix + "_left"):
		velocity.x = -speed
	if Input.is_action_pressed(prefix + "_right"):
		velocity.x = speed
	if Input.is_action_pressed(prefix + "_up") and (is_on_floor() or is_on_ladder):
		velocity.y = -speed * 2
	if Input.is_action_pressed(prefix + "_down") and is_on_ladder:
		velocity.y = speed
	
	if velocity.x == 0:
		$Animation.play("idle")
	elif velocity.x > 0:
		$Animation.play("walk_right")
	else:
		$Animation.play("walk_left")

	if Input.is_action_pressed(prefix + "_interact"):
		var areas = $InteractableArea.get_overlapping_areas()
		if areas.size() > 0 && areas[0].has_method("interact_with_player"):
			print("Interacting with ", areas[0]);
			areas[0].call("interact_with_player", self)
			
	if Input.is_action_pressed(prefix + "_drop_item"):
		if holding != null:
			var to_drop = pickupable.new(self.position + $Holding.position, self.take_item())
			get_node(drop_item_to).add_child(to_drop)
		self.set_holding(null)
		
func can_pickup():
	return holding == null
		
func take_item():
	var item = self.holding
	self.set_holding(null)
	return item
	
func take_item_if_eq(item):
	var holding = self.holding
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
		$Holding.texture = World.load_texture_for_item(item)
		var sx = World.ItemSize.x /  $Holding.texture.get_size().x 
		var sy = World.ItemSize.y /  $Holding.texture.get_size().y 
		$Holding.scale = Vector2(sx, sy)

		var sx = World.ItemSize.x /  $Holding.texture.get_size().x 
		var sy = World.ItemSize.y /  $Holding.texture.get_size().y 
		$Holding.scale = Vector2(sx, sy)


func _physics_process(delta):
	velocity.y += gravity * delta;
	velocity = move_and_slide(velocity, Vector2.UP, true)
