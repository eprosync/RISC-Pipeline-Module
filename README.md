# RISC-Pipeline-Module
A simple pipelined version of RISC-Compute-Module.\
An FSM based processor will only get you so far.\
Yes its very easy to modify but with such modifications to the core, but it costs you precious cycles and other aspects.

In this repository instead of doing it through a massive FSM controller, it will be a one-shot route pipeline.\
Obviously I don't intend to add things like "multi-core" processing datapaths, and instruction queues.\
If a hazard occurs (if I make a detection unit) then so be it, we will stall & wait.

The objective here is to make all instructions flow through the entire circuit without needing to wait for a next-cycle.\
*This would exclude me adding "cycles" to each stage: IF, ID, EX, MEM, WB\
Since obviously I need to allow monitoring for each stage so that we can inspect them.