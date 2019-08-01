extends Node2D

const BLOCK_SIZE = 20
const NUMBER_OF_BLOCKS = 40
const START_TAIL_LENGTH = 3
const UPDATE_INTERVAL = 0.08

var snake_speed = Vector2(0,0)
var head = null
var tail_length:int = START_TAIL_LENGTH
var tails: PoolVector2Array = []
var viewsize = Rect2()
var last_updated =0.0
var block = null
var snake_color = null
var apple_pos = null

func _init():
	snake_color = Color(1, 1, 1)

func _ready():
	print("Initializing game...")
	set_physics_process(true)
	set_process_input(true)
	viewsize = get_viewport_rect().size
	
	block = Vector2(viewsize.x/NUMBER_OF_BLOCKS,viewsize.y/NUMBER_OF_BLOCKS)
	head = Vector2(NUMBER_OF_BLOCKS/2.0, NUMBER_OF_BLOCKS/ 2.0)
	
	# Set initial position of apple at random location
	randomize()
	apple_pos = spawnNewApple()
	
func _draw():
	# draw head
	var pos = Vector2(head.x * block.x, head.y * block.y)
	var head_pos = Rect2(pos, block)
	draw_rect(head_pos, snake_color)
	
	# draw tail
	for tail_pos in range(tails.size()):
		var pos2 = Vector2(tails[tail_pos].x * block.x, tails[tail_pos].y * block.y)
		var tail_block = Rect2(pos2,block)
		draw_rect(tail_block, snake_color)		
	
	# draw apple
	var view_pos = Vector2(apple_pos.x * block.x, apple_pos.y * block.y)
	var apple_block = Rect2(view_pos,block)
	draw_rect(apple_block, Color(1,0,0))
	
func _input(event):
	if event.is_action("dir_up"):
		snake_speed.x = 0
		snake_speed.y = -1 #* BLOCK_SIZE
	elif event.is_action("dir_down"):
		snake_speed.x = 0
		snake_speed.y =  1 #* BLOCK_SIZE
	elif event.is_action("dir_left"):
		snake_speed.x = -1
		snake_speed.y = 0
	elif event.is_action("dir_right"):
		snake_speed.x = 1
		snake_speed.y = 0


func updateHeadPosition(delta):
	head.x = head.x + snake_speed.x 
	head.y = head.y + snake_speed.y 
	if head.x > NUMBER_OF_BLOCKS-1:
		head.x = 0
	elif head.x < 0:
		head.x = NUMBER_OF_BLOCKS-1
	elif head.y > NUMBER_OF_BLOCKS-1:
		head.y = 0
	elif head.y < 0:
		head.y = NUMBER_OF_BLOCKS - 1	
		
func spawnNewApple():
	var x_pos = randi() % NUMBER_OF_BLOCKS
	var y_pos = randi() % NUMBER_OF_BLOCKS
	return Vector2(x_pos,y_pos)

func _physics_process(delta):
	if last_updated + delta > UPDATE_INTERVAL:
		last_updated = 0
		updateHeadPosition(delta)
		
		# Push tail element
		tails.push_back(head)
		while tails.size() > tail_length:
			tails.remove(0)
	else:
		last_updated += delta

	# Check if snake eats apple
	if head == apple_pos:
		apple_pos = spawnNewApple()
		tail_length += 1	
	
	update()
#	

	