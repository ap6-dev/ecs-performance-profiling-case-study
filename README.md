The goal of this case study is to closely examine the performnace of the Godot game engine during different tests. The tests invlove recording the process times of different methods
of moving entities. These tests include Godot's default nodes and ECS code loops (the entities live only as data), where different optimizations are introduced to observe how they affect
performance: Array of Structs, Structure of Arrays, Vectors vs Arrays, SIMD Vectorization, and multithreading.
