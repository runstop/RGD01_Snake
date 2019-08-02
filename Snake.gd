extends Node2D

const NUMBER_OF_BLOCKS:int = 10
const START_TAIL_LENGTH:int = 3
const UPDATE_INTERVAL:float = 0.15
const MAX_NEW_APPLE_ATTEMPTS = 1000  # reasonable attempt limit before stopping search

var snake_speed = Vector2(0,0)
var head = null
var tail_length:int = START_TAIL_LENGTH
var tails: Array = []
var viewsize = Rect2()
var last_updated =0.0
var block = null
var snake_color = null
var apple_pos = null
var last_speed = Vector2.ZERO


func _init():
	snake_color = Color(1, 1, 1)


func _ready():
	print("Initializing game...")
	set_physics_process(true)
	set_process_input(true)
	viewsize = get_viewport_rect().size
	
	block = Vector2(int(round(viewsize.x/NUMBER_OF_BLOCKS)),int(round(viewsize.y/NUMBER_OF_BLOCKS)))
	head = Vector2( int(round(NUMBER_OF_BLOCKS/2.0)), int(round(NUMBER_OF_BLOCKS/ 2.0)))
	
	var tail = head
	tail.x = tail.x - 1
	var lent = tails.size()
	while lent < tail_length:
		tails.push_back(tail)
		tail.x -= 1
		lent += 1
		
	# Set initial position of apple at random location
	randomize()
	apple_pos = spawn_new_apple()


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
	#ZERO  = Vector2( 0, 0 )  — Zero vector
	#ONE   = Vector2( 1, 1 )  — One vector
	#LEFT  = Vector2( -1, 0 ) — Left unit vector
	#RIGHT = Vector2( 1, 0 )  — Right unit vector
	#UP    = Vector2( 0, -1 ) — Up unit vector
	#DOWN  = Vector2( 0, 1 )  — Down unit vector

	# prevent player from reversing direction 180 degrees - snake runs over self
	if event.is_action("dir_up") && last_speed != Vector2.DOWN:
		snake_speed = Vector2.UP
	elif event.is_action("dir_down") && last_speed != Vector2.UP:
		snake_speed = Vector2.DOWN
	elif event.is_action("dir_left") && last_speed != Vector2.RIGHT:
		snake_speed = Vector2.LEFT
	elif event.is_action("dir_right") && last_speed != Vector2.LEFT:
		snake_speed = Vector2.RIGHT


func update_head_position(head_pos: Vector2):
	var new_pos = Vector2(head_pos.x + snake_speed.x, head_pos.y + snake_speed.y)
	
	# wrap snake head around edges of game window
	if new_pos.x > NUMBER_OF_BLOCKS-1:
		new_pos.x = 0
	elif new_pos.x < 0:
		new_pos.x = NUMBER_OF_BLOCKS-1
	elif new_pos.y > NUMBER_OF_BLOCKS-1:
		new_pos.y = 0
	elif new_pos.y < 0:
		new_pos.y = NUMBER_OF_BLOCKS - 1
	return new_pos


func get_random_position():
	var x = randi() % NUMBER_OF_BLOCKS
	var y = randi() % NUMBER_OF_BLOCKS
	return Vector2(x,y)


func spawn_new_apple():
	var new_apple_pos = Vector2.ZERO
	var attempts = 0
	
	while new_apple_pos == Vector2.ZERO && attempts < MAX_NEW_APPLE_ATTEMPTS:
		var pos = get_random_position()
		# apple should spawn outside area of the snake
		if head != pos && !tails.has(pos):
			new_apple_pos = pos
		else:
			attempts += 1
	return new_apple_pos


func _physics_process(delta):
	if last_updated + delta > UPDATE_INTERVAL:
		last_updated = 0.0
		if snake_speed == Vector2.ZERO:
			return

		if tails.find(head,0) >= 0:
			#check if snake collides with tail (a game ending event)
			print("found head in tail")
		#else:
			#while tails.size() >= tail_length:
		if tails.size() > tail_length:
			tails.pop_back()
		tails.push_front(head)
	
		head = update_head_position(head) #move snake head in direction of speed
		last_speed = snake_speed # save last speed direction

		# Check if snake eats apple
		if  head == apple_pos:
			apple_pos = spawn_new_apple()
			tail_length += 1
		
		update()
	else:
		last_updated += delta
		

