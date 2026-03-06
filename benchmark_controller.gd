extends Node
@onready var default_node_test : Node = $"../default_node_test"
@onready var loop_node_test : Node = $"../loop_node_test"
@onready var aos_test : Node = $"../aos_test"
@onready var soa_test : Node = $"../soa_test"
@onready var soa_simd_test : Node = $"../soa_simd_test"
@onready var soa_simd_thread_test : Node = $"../soa_simd_thread_test"

var npc_counts := [1_000, 10_000, 100_000, 1_000_000]
var float_array : Array[float]
var avg_times: Dictionary = {
	"Node": [],
	"Loop": [],
	"AoS": [],
	"SoA": [],
	"SoA_SIMD": [],
	"SoA_SIMD_4": [],
	"SoA_SIMD_6": []
}


func _ready():
	consoleLogger.print_header()
	consoleLogger.print_desc()
	consoleLogger.print_systems()
	consoleLogger.print_test_counts()
	
	# ==================================>NOTE<==================================
	# The baseline node tree _process time without any NPC instantiations = ~0.04ms
	
	# await default_node_test.node_benchmark(0) # Test Engine _process time without any NPCs
	
	for i in range(npc_counts.size()):
		#avg_times["Node"].append(await default_node_test.node_benchmark(npc_counts[i]))
		#avg_times["Loop"].append(loop_node_test.node_benchmark(npc_counts[i]))
		#avg_times["AoS"].append(aos_test.node_benchmark(npc_counts[i]))
		#avg_times["SoA"].append(soa_test.node_benchmark(npc_counts[i]))
		#avg_times["SoA_SIMD"].append(soa_simd_test.node_benchmark(npc_counts[i]))
		avg_times["SoA_SIMD_4"].append(soa_simd_thread_test.node_benchmark(npc_counts[i]))
	
	consoleLogger.print_results(npc_counts, avg_times)
	
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()
