extends Node

var pos: PackedVector3Array
var vel: PackedVector3Array

var logical = OS.get_processor_count()
var thread_count = max(1, (logical / 2) - 1)
var threads: Array[Thread] = []
var semaphores_start: Array[Semaphore] = []
var semaphores_done: Array[Semaphore] = []
var thread_chunk_size: int
var _shutdown := false

# Benchmark state
var test_counter := 0
var test_sum := 0.0
var time_accum_ms := 0.0
var frame_counter := 0
const MEASURE_FRAMES := 150
const COPY_DELTA := 16.6

# Per-thread work parameters (avoid repeated bind allocation)
var _chunk_starts: PackedInt32Array
var _chunk_ends: PackedInt32Array

#===============================================================================
func node_benchmark(npc_count: int) -> float:
	
	reset_vars()
	initialize_npc_arrays(npc_count)
	_setup_persistent_threads(npc_count)
	var msec_avg := measure_benchmark(npc_count)
	_teardown_persistent_threads()
	cleanup_npc_arrays()
	return msec_avg

#===============================================================================
func _setup_persistent_threads(npc_count: int):
	threads.clear()
	semaphores_start.clear()
	semaphores_done.clear()
	_shutdown = false
	thread_chunk_size = npc_count / thread_count
	_chunk_starts.resize(thread_count)
	_chunk_ends.resize(thread_count)
	
	for t in range(thread_count):
		_chunk_starts[t] = t * thread_chunk_size
		if t == thread_count - 1:
			_chunk_ends[t] = npc_count
		else:
			_chunk_ends[t] = min(_chunk_starts[t] + thread_chunk_size, npc_count)
		
		var sem_start = Semaphore.new()
		var sem_done = Semaphore.new()
		semaphores_start.append(sem_start)
		semaphores_done.append(sem_done)
		
		var thread = Thread.new()
		thread.start(_worker_thread.bind(t, sem_start, sem_done))
		threads.append(thread)

#===============================================================================
func _teardown_persistent_threads():
	_shutdown = true
	for sem in semaphores_start:
		sem.post()  # Wake threads so they can exit
	for thread in threads:
		thread.wait_to_finish()
	threads.clear()
	semaphores_start.clear()
	semaphores_done.clear()

#===============================================================================
func _worker_thread(thread_idx: int, sem_start: Semaphore, sem_done: Semaphore):
	while true:
		sem_start.wait()
		if _shutdown:
			break
		var s = _chunk_starts[thread_idx]
		var e = _chunk_ends[thread_idx]
		# Inner loop — cache-friendly sequential access on PackedVector3Array
		for i in range(s, e):
			pos[i] += vel[i] * COPY_DELTA
		sem_done.post()

#===============================================================================
func measure_benchmark(npc_count: int) -> float:
	printraw("SoA-Vectors + Threads: ", thread_count, " (", npc_count, " NPCs): ")
	while test_counter < 10:
		_run_frame()
	var avg := test_sum / test_counter
	print("%.2f" % avg, " ms")
	return avg

#===============================================================================
func _run_frame():
	var start := Time.get_ticks_usec()
	
	# Signal all workers
	for sem in semaphores_start:
		sem.post()
	# Wait for all workers to finish
	for sem in semaphores_done:
		sem.wait()
	
	var frame_ms := (Time.get_ticks_usec() - start) / 1000.0
	time_accum_ms += frame_ms
	frame_counter += 1
	
	if frame_counter >= MEASURE_FRAMES:
		test_sum += time_accum_ms / MEASURE_FRAMES
		test_counter += 1
		frame_counter = 0
		time_accum_ms = 0.0
		printraw(".")

#===============================================================================
func reset_vars():
	test_counter = 0
	test_sum = 0.0
	frame_counter = 0
	time_accum_ms = 0.0

#===============================================================================
func initialize_npc_arrays(npc_count: int):
	pos.resize(npc_count)
	vel.resize(npc_count)
	for i in range(npc_count):
		pos[i] = Vector3.ZERO
		vel[i] = Vector3(randf(), 0.0, randf())

#===============================================================================
func cleanup_npc_arrays():
	pos.clear()
	vel.clear()
	await get_tree().process_frame
