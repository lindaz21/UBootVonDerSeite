extends Node2D

const TILE_NONE = -1
const TILE_ROOM  = 0 # ??
const TILE_LEAK = 1 # ??
const TILE_LADDER = 2 # ??
const TILE_PLAYER = 3 # ??
const TILE_BACKGROUND = 5
const TILE_HOLE = 7

onready var PlayerScene = preload("res://characters/players/TilePlayer.tscn")

export (NodePath) onready var hole_holder

const World = preload("res://levels/World.gd")

export (NodePath) onready var PlayerRoot

export (int) var health = 1000

var max_size = null

func _ready():
	randomize()
	var hole_timer = Timer.new()
	add_child(hole_timer)
	hole_timer.connect("timeout", self, "generate_new_hole")
	hole_timer.set_wait_time(10.0)
	hole_timer.set_one_shot(false)
	hole_timer.start()
	
	create_bucket(Vector2(24, 42), 7)
	create_bucket(Vector2(168, 102), 2)
	
	var PlayerList = get_node("/root/Global").PlayerList
	
	for player in PlayerList:
		var newPlayer = PlayerScene.instance()
		newPlayer.prefix = player
		newPlayer.position = get_node("SpawnPoints").get_child(int(player) - 1).position
		newPlayer.drop_item_to = $Tiles.get_path()
		newPlayer.level = self
		get_node(PlayerRoot).add_child(newPlayer)

func create_bucket(pos, fillsize): # fillsize in litre (10l max)
	var to_drop = pickupable.new(pos, World.Item.Bucket)
	to_drop.value = fillsize
	
	if fillsize > 10:
		fillsize = 10

	var rect = ColorRect.new()
	rect.name = "Back"
	rect.set_position(Vector2(-4, 5))
	rect.set_size(Vector2(8, 1))
	rect.color = Color(0.5,0.5,0.5)
	to_drop.add_child(rect)

	rect = ColorRect.new()
	rect.name = "Progress"
	rect.set_position(Vector2(-4, 5))
	rect.set_size(Vector2(fillsize / 10.0 * 8, 1))
	rect.color = Color(1,0,0)	
	to_drop.add_child(rect)
	
	$Tiles.add_child(to_drop)

func generate_new_hole():
	if self.max_size != null:
		var tile_x = rand_range(0, self.max_size.x)
		var tile_y = rand_range(0, self.max_size.y)
		
		var cell = $Tiles.world_to_map(Vector2(tile_x, tile_y))
		var background_tile = $Tiles.get_cellv(cell)
		var foreground_tile = $ForegroundTiles.get_cellv(cell)
		
		if background_tile == TILE_BACKGROUND && foreground_tile == TILE_NONE:
			var hole = load("res://items/hole/Hole.tscn");
			var instance = hole.instance()
			print(instance)
			instance.call("initialize", cell, $ForegroundTiles)
			instance.position = $Tiles.map_to_world(cell)

			get_node(hole_holder).add_child(instance)

			$ForegroundTiles.set_cellv(cell, TILE_HOLE)


func calculate_health():
	var count_holes = get_node(hole_holder).get_child_count()
	print(count_holes)
	if health - count_holes > 0:
		health -= count_holes
	else:
		health = 0
		$"RichTextLabel".show()
	
	
func _process(_delta):
	if Input.is_action_pressed("stop"):
		get_tree().paused = true
		$"Panel".show()
	
	for player in get_node(PlayerRoot).get_children():
		var tile = $Tiles.get_cellv($Tiles.world_to_map(player.position))
		player.is_on_ladder = tile == TILE_LADDER

func _on_Timer_timeout():
	print("Decreased health")
	calculate_health()
