extends Node

var pos_x := PackedFloat32Array()
var pos_y := PackedFloat32Array()
var pos_z := PackedFloat32Array()
var vel_x := PackedFloat32Array()
var vel_y := PackedFloat32Array()
var vel_z := PackedFloat32Array()

var test_counter := 0 #Counter for no of tests ran
var test_sum := 0.0 #Total of all 10 tests for this benchmark

var time_accum_sec := 0.0 #Total time accumulated in seconds?
var start_time: float
var end_time: float

var frame_counter := 0 #How many frames have passed?
var warmup_frames := 100 #Number of frames to wait until script should measure
var measure_frames := 150 #Number of frames we will measure the time of

var copy_delta := 16.6 #Fake frame time (ms)

#===============================================================================

func node_benchmark(npc_count: int) -> float:
	if npc_count > 100_000:
		print("SoA(", npc_count, " NPCs): N/A")
		return -1
		
	reset_vars()
	initialize_npc_arrays(npc_count)
	var msec_avg : float = measure_benchmark(npc_count)
	cleanup_npc_arrays()
	
	return msec_avg

#===============================================================================
func measure_benchmark(npc_count: int) -> float:
	printraw("SoA(", npc_count, " NPCs): ")
	
	while test_counter < 10:
		frames(npc_count)
	
	var avg = (test_sum / test_counter)
	print("%.2f" % avg, " ms")
	return avg

#===============================================================================
func frames(npc_count: int):
	if frame_counter >= warmup_frames:
		start_time = Time.get_ticks_usec()
		for i in range(npc_count):
			pos_x[i] += vel_x[i] * copy_delta
			pos_z[i] += vel_z[i] * copy_delta
		end_time = Time.get_ticks_usec()
		var frame_ms = (end_time - start_time) / 1000.0
		time_accum_sec += frame_ms
	
	frame_counter += 1
	
	if frame_counter >= warmup_frames + measure_frames:
		test_sum += time_accum_sec / measure_frames
		test_counter += 1
		frame_counter = warmup_frames - 1
		time_accum_sec = 0.0
		printraw(".")
#===============================================================================
func reset_vars():
	test_counter = 0
	test_sum = 0.0
	frame_counter = 0
	time_accum_sec = 0.0

#===============================================================================
func initialize_npc_arrays(npc_count: int):
	pos_x.resize(npc_count)
	pos_y.resize(npc_count)
	pos_z.resize(npc_count)
	vel_x.resize(npc_count)
	vel_y.resize(npc_count)
	vel_z.resize(npc_count)
	
	for i in range(npc_count):
		pos_x[i] = 0.0
		pos_y[i] = 0.0
		pos_z[i] = 0.0
		vel_x[i] = randf()
		vel_z[i] = randf()

#===============================================================================
func cleanup_npc_arrays():
	pos_x.clear()
	pos_y.clear()
	pos_z.clear()
	vel_x.clear()
	vel_y.clear()
	vel_z.clear()
	
	await get_tree().process_frame
