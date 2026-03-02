class_name consoleLogger

static func print_header():
	print("\n==================================================")
	print("ECS PERFORMANCE PROFILING CASE STUDY")
	print("Developer: Ap6-dev")
	print("Engine: Godot 4.x")
	print("==================================================\n")

static func print_desc():
	print("DESCRIPTION")
	print("Records Avg. frame time of the movement of increasing amounts of ")
	print("entities (Godot nodes or Simulated data) using different processing paradigms.\n")

static func print_systems():
	print("LIST OF PROCESSING PARADIGMS")
	print("- Default Godot Node3D per entity")
	print("- Loop-based Node3D-per-entity")
	print("- AoS (Array of Structs)")
	print("- SoA (Structure of Arrays)")
	print("- SoA + SIMD")
	print("- SoA + SIMD + 4 Worker threads")
	print("- SoA + SIMD + 6 Worker threads\n")

static func print_test_counts():
	print("ENTITY AMOUNTS")
	print("1,000\n10,000\n100,000 -- if applicable\n1,000,000 -- if applicable\n")

static func print_results(test_counts : Array, avg_times : Dictionary):
	var fs = "| %-16s"
	var fd = "| %-16.2f"
	var table_padding = "_____________________________________________________________________"
	
	print(table_padding, "RESULTS", table_padding)
	print(fs % "NPCs", fs % "Default-Node", fs % "Node-Loop", fs % "AoS",fs % "SoA", fs % "SoA + SIMD", fs % "SoA + SIMD + 4T", fs % "SoA + SIMD + 6T", "|")
	for count in test_counts.size():
		printraw("| %-16d" % test_counts[count])
		for test in avg_times:
			if avg_times[test].is_empty():
				printraw(fs % "---")
			elif avg_times[test][count] == -1:
				printraw(fs % "---")
			else:
				printraw(fd % avg_times[test][count])
		print("|")
	print("\nEND OF BENCHMARK----\n")
