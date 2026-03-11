# The Problem
The Godot game engine excels at providing developers with a smooth and quick development process, but its performance
begins to drop as more and more entities are added due to the node tree overhead. Currently there is not a detailed
breakdown of maintaining or even increasing performance at such high entity counts.
> This case study focuses only on processing speed and excludes rendering (I will address rendering at a different time).
# The Solution
I have developed a benchmark Godot project that tests various processing paradigms at entity counts of: 1_000, 10_000,
100_000, and 1_000_000 (within reason based on process times). The benchmark explores manipulating the default godot npc nodes
in _process, within a code loop, ECS-style data only NPCs in singular/separate arrays, data only NPCs utilizing a Vector3 array,
data only NPCs existing in the Vector3 array with multithreading, and lastly data only NPCs exisiting in the Vector3 array with
multithreading and cache friendly batching.
