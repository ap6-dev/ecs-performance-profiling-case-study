extends Node

@export var npc_scene : PackedScene

var npc_count := 1_000_000

var warmup_frames := 100
var measure_frames := 120

var frame_counter := 0
var time_accum_sec := 0.0
var measuring = false

var start := 0.0
var end := 0.0

#var npcs : Array[NPCData] = []

#var pos_x : PackedFloat32Array
#var pos_y : PackedFloat32Array
#var pos_z : PackedFloat32Array
#var vel_x : PackedFloat32Array
#var vel_y : PackedFloat32Array
#var vel_z : PackedFloat32Array
var pos : PackedVector3Array
var vel : PackedVector3Array

var num_threads := 6
var threads := []
var chunk_size

func _ready():
	chunk_size = ceil(npc_count / num_threads)
	#pos_x.resize(npc_count)
	#pos_y.resize(npc_count)
	#pos_z.resize(npc_count)
	#vel_x.resize(npc_count)
	#vel_y.resize(npc_count)
	#vel_z.resize(npc_count)
	
	pos.resize(npc_count)
	vel.resize(npc_count)
	
	for i in npc_count:
		pos[i] = Vector3(randf() * 100.0, 0.0, randf() * 100.0)
		vel[i] = Vector3(1, 0, 0)
		
		#vel_x[i] = 1.0
		#vel_y[i] = 0.0
		#vel_z[i] = 0.0
	
	#npcs.resize(npc_count)
	#spawn_npcs()
	
	#await get_tree().process_frame
	#for i in npc_count:
		#var npc := NPCData.new()
		#npc.pos = Vector3(randf() * 100.0, 0.0, randf() * 100.0)
		#npc.vel = Vector3(1, 0, 0)
		#
		#npcs[i] = npc
	
	frame_counter = 0
	time_accum_sec = 0.0
	measuring = true

func spawn_npcs():
		for i in npc_count:
			var npc = npc_scene.instantiate()
			#npcs.push_back(npc)
			add_child(npc)
			

func measure_frame(delta:float):
	threads.clear()
	start = Time.get_ticks_usec()
	for t in num_threads:
		var thread = Thread.new()
		threads.append(thread)
		var start_idx = t * chunk_size
		var end_idx = min(start_idx + chunk_size, npc_count)
		thread.start(_update_chunk.bind(start_idx, end_idx, delta))
		
	#if frame_counter >= warmup_frames:
		#print("Starting frame...")
		#var frame_sec = Performance.get_monitor(Performance.TIME_PROCESS)
	for thread in threads:
		thread.wait_to_finish()
	
	end = Time.get_ticks_usec()
	var frame_sec = (end - start)
	time_accum_sec += frame_sec
		#start = Time.get_ticks_usec()
		#for i in npc_count:
			#pos[i] += vel[i] * delta
			##pos_x[i] += vel_x[i] * delta
			##pos_y[i] += vel_y[i] * delta
			##pos_z[i] += vel_z[i] * delta
		#end = Time.get_ticks_usec()
		#var frame_sec = (end - start)
		##print(frame_sec)
		#time_accum_sec += frame_sec

	frame_counter += 1

	if frame_counter >= warmup_frames + measure_frames:
		var avg_sec = time_accum_sec / measure_frames

		print("NPCs: ", npc_count)
		print("Avg frame time: ", "%.6f" % (avg_sec / 1000), " ms")

		measuring = false
		await get_tree().process_frame  # wait for frees to complete
		frame_counter = 0
		time_accum_sec = 0.0

func _update_chunk(start_idx, end_idx, delta):
	var d = delta
	for i in range(start_idx, end_idx):
		pos[i] += vel[i] * d

func _process(_delta):
	measure_frame(_delta)
	#if not measuring:
		#return
#
	#if frame_counter >= warmup_frames:
		##var frame_sec = Performance.get_monitor(Performance.TIME_PROCESS)
		#start = Time.get_ticks_msec()
		#
		#end = Time.get_ticks_msec()
		#var frame_sec = (start - end)
		#time_accum_sec += frame_sec
#
	#frame_counter += 1
#
	#if frame_counter >= warmup_frames + measure_frames:
		#var avg_sec = time_accum_sec / measure_frames
#
		#print("NPCs: ", npc_count)
		#print("Avg frame time: ", "%.6f" % (avg_sec), " ms")
#
		#measuring = false
		#await get_tree().process_frame  # wait for frees to complete
		#frame_counter = 0
		#time_accum_sec = 0.0
		#measuring = true

#func cleanup_npcs():
	#for child in get_children():
		#child.queue_free()
