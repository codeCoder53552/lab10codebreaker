restart

add_force clk {0 0} {1 5ns} -repeat_every 10ns
run 400 ns

add_force btnu 1
add_force btnc 0

run 20ns

add_force btnu 0

run 20ns

add_force btnc 1

run 10ns

add_force btnc 0

run 800ns