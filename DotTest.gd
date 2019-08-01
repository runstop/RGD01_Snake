extends Node2D

const DOT_COUNT = 3
const DOT_RADIUS = 3
const DOT_GAP = 3  # spacing between dots
const DOT_COLOR = Color(1,0,0)  # red
const UPDATE_SPEED = 0.1 # update snake every 20th second
var snake_segments = []
var segment_pos = 0
var last_updated =0.0
var last_direction = Vector2(0,0)

func draw_dots(dot_count = 1):
	# get view size
	var view_size = get_viewport_rect().size
	var center_view = view_size/2
	var dot_pos = center_view
	
	# calc starting dot from center
	dot_pos.x = center_view.x - ((dot_count * (DOT_RADIUS*2))/2) - ((DOT_GAP * (dot_count-1))/2)
	dot_pos.y = center_view.y
	
	#Draw segments slowly
	
	# ? How to draw 1 segment per second?
	
	# Draw in order or movement -- starting 0 radian (East)
	for dot_index in range(dot_count,0,-1):
		var direction = snake_segments[dot_index]
		
		if direction.x > 0:
			dot_pos.y += DOT_RADIUS
		if direction.x < 0:
			dot_pos.y -= DOT_RADIUS
			
		draw_circle(dot_pos, DOT_RADIUS, DOT_COLOR)
		dot_pos.x += (DOT_RADIUS*2) + DOT_GAP

func _init():
	for _i in range(DOT_COUNT+1):
		snake_segments.append(Vector2(1,0))

func _draw():
	draw_dots(DOT_COUNT)

func _ready():
	set_physics_process_internal(true)
	set_process_input(true)
	
	
func _input(event):
	if event.is_action("dir_left"):
		last_direction.x = -1
	elif event.is_action("dir_right"):
		last_direction.x = 1

func _process(delta):
	var change_in_time = last_updated + delta
	
	if last_updated + delta > UPDATE_SPEED:
		last_updated = 0.0
		
		var rnd_direction = randi()%2-1 
		snake_segments.push_front(last_direction)
		snake_segments.pop_back()
		#last_direction.x = 0
		update()
	else:
		last_updated += delta