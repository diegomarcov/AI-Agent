explore_strat(move_fwd):-
	current_pos([X,Y]),
	direction(Dir),
	ady_at_cardinal([X,Y], Dir, [NX, NY]),
	(map(NX, NY, plain); map(NX, NY, mountain)).

explore_strat(turn(Turn)):-
	direction(Dir),
	random(0, 2, Num),
	next_random(Num, Dir, Turn).

next_random(0, Dir, Turn):-
	next_90_clockwise(Dir, Turn).

next_random(1, Dir, Turn):-
	next_90_clockwise(Dir, Dir1),
	next_90_clockwise(Dir1, Dir2),
	next_90_clockwise(Dir2, Turn).
