extends Node2D

const NUMBER_OF_BLOCKS:int = 15
const START_TAIL_LENGTH:int = 3
const UPDATE_INTERVAL:float = 0.15
const MAX_NEW_APPLE_ATTEMPTS = 1000  #limit retries for random apple position

var snake_movement = Vector2.ZERO
var last_movement = Vector2.ZERO
var last_updated = 0.0
var head = Vector2.ZERO
var tails: Array = []
var tail_length:int = START_TAIL_LENGTH
var viewsize = Rect2()
var block = Vector2.ZERO
var snake_color = Color.white
var apple_pos = Vector2.ZERO
var score = 0
var high_score = 5


func _init():
	snake_color = Color.white

	
func _ready():
	randomize()
	
	# calculate the block size based on viewsize 
	viewsize = get_viewport_rect().size
	var width:int = viewsize.x / NUMBER_OF_BLOCKS
	var height = width
	#var height:int = viewsize.y / NUMBER_OF_BLOCKS	
	block = Vector2(width, height)
	
	set_physics_process(true)
	set_process_input(true)

	new_snake()
	
	apple_pos = new_apple()


func _draw():
	# everything drawn here is in pixels, not blocks :-)
	
	# adjust ypos to accomodate HUD at top of game screen
	var y_offset = viewsize.y - viewsize.x
	
	# draw head
	var pos = Vector2(head.x * block.x, y_offset + head.y * block.y)
	var head_pos = Rect2(pos, block)
	draw_rect(head_pos, snake_color)
	
	# draw tail
	for tail_pos in range(tails.size()):
		var pos2 = Vector2(tails[tail_pos].x * block.x, y_offset + tails[tail_pos].y * block.y)
		var tail_block = Rect2(pos2,block)
		draw_rect(tail_block, snake_color)
	
	# draw apple
	if apple_pos != Vector2.ZERO:
		var view_pos = Vector2(apple_pos.x * block.x, y_offset + apple_pos.y * block.y)
		var apple_block = Rect2(view_pos,block)
		draw_rect(apple_block, Color.red)


func update_snake_position():
	last_updated = 0.0
	
	#check if snake collides with tail (a game ending event)
	if tails.find(head,0) >= 0:
		new_snake()
	else:
		if tails.size() > tail_length:
			tails.pop_back()   # cut off extra tail
		tails.push_front(head) # add last head position to front of tail
	
		head = update_head_position(head) #move snake head in direction of movement
	last_movement = snake_movement # save last speed direction


func update_score(reward):
	score += reward
	if score > high_score:
		high_score = score


func update_hud():
	$Score.text = "Score: " + str(score)
	$HighScore.text = "HI Score: " + str(high_score)

func has_snake_eatten():
	# Check if snake eats apple
	if  head == apple_pos:
		apple_pos = new_apple()
		tail_length += 1
		update_score(1)


func _physics_process(delta):
	if last_updated + delta > UPDATE_INTERVAL:
		if snake_movement == Vector2.ZERO:
			return

		update_snake_position()
		has_snake_eatten()
		update_hud()
		update()  # draw new snake and apple position
	else:
		last_updated += delta


func _input(event):
	#ZERO  = Vector2( 0, 0 )  — Zero vector
	#ONE   = Vector2( 1, 1 )  — One vector
	#LEFT  = Vector2( -1, 0 ) — Left unit vector
	#RIGHT = Vector2( 1, 0 )  — Right unit vector
	#UP    = Vector2( 0, -1 ) — Up unit vector
	#DOWN  = Vector2( 0, 1 )  — Down unit vector

	# prevent player from reversing direction and running over snake
	if event.is_action("dir_up") && last_movement != Vector2.DOWN:
		snake_movement = Vector2.UP
	elif event.is_action("dir_down") && last_movement != Vector2.UP:
		snake_movement = Vector2.DOWN
	elif event.is_action("dir_left") && last_movement != Vector2.RIGHT:
		snake_movement = Vector2.LEFT
	elif event.is_action("dir_right") && last_movement != Vector2.LEFT:
		snake_movement = Vector2.RIGHT


func new_snake():
	tails.clear()
	
	# position snake from center block of screen 
	var x_pos = round(int((NUMBER_OF_BLOCKS-1)/ 2.0))
	var y_pos = round(int((NUMBER_OF_BLOCKS-1) / 2.0))
	
	head = Vector2(x_pos, y_pos)
	tail_length = START_TAIL_LENGTH

	# Build out snake tail, left of the starting block
	var tail = head + Vector2.LEFT
	for _i in range(tail_length):
		tails.push_back(tail)
		tail += Vector2.LEFT
		
	snake_movement = Vector2.ZERO  #snake has zero speed


func update_head_position(head_pos: Vector2):
	var new_pos = Vector2(head_pos.x + snake_movement.x, head_pos.y + snake_movement.y)
	
	# wrap snake head around edges of game window
	if new_pos.x > NUMBER_OF_BLOCKS - 1:
		new_pos.x = 0
	elif new_pos.x < 0:
		new_pos.x = NUMBER_OF_BLOCKS - 1
	elif new_pos.y > NUMBER_OF_BLOCKS - 1:
		new_pos.y = 0
	elif new_pos.y < 0:
		new_pos.y = NUMBER_OF_BLOCKS - 1
	return new_pos


func get_random_position():
	var x = randi() % NUMBER_OF_BLOCKS
	var y = randi() % NUMBER_OF_BLOCKS
	return Vector2(x, y)


func new_apple():
	var new_apple_pos = Vector2.ZERO
	var attempts = 0
	
	while new_apple_pos == Vector2.ZERO && attempts < MAX_NEW_APPLE_ATTEMPTS:
		var pos = get_random_position()
		# apple should spawn outside area of the snake's body
		if head != pos && !tails.has(pos):
			new_apple_pos = pos
		else:
			attempts += 1
	return new_apple_pos

