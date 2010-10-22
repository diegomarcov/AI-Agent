explore_strat:-
	current_pos([X,Y]),
	direction(Dir),
	debug_term(warning, 'Current pos = ', [X,Y]),
	getFrontierPos(Target),
	replace(meta(_), meta(Target)),
	debug_term(warning, 'Meta: ', meta(Target)),
	justdoit([X,Y],_,_),
	debug(warning, 'Pase el A*.... LETS A-GO!').
	
explore_strat:-
	direction(Dir),
	random(0, 2, Num),
	next_random(Num, Dir, Turn),
	replace(planning_stack(_), planning_stack([])),
	push_action(turn(Turn)).
	
explore_strat:-
	replace(planning_stack(_), planning_stack([])),
	push_action(move_fwd).

next_random(0, Dir, Turn):-
	next_90_clockwise(Dir, Turn).

next_random(1, Dir, Turn):-
	next_90_clockwise(Dir, Dir1),
	next_90_clockwise(Dir1, Dir2),
	next_90_clockwise(Dir2, Turn).	

getFrontierPos(Target):-
	findall([X,Y], 
			(	map(X,Y,Land),
				(
					Land = mountain 
					;
					Land = plain
				), 
				P1 is X+1, 
				P2 is X-1, 
				P3 is Y+1, 
				P4 is Y-1,
				(
					(not(map(P1,Y, _))) 
					; 
					(not(map(P2,Y, _))) 
					; 
					(not(map(X, P3, _))) 
					; 
					(not(map(X, P4, _)))
				)
			),
			TargetList),
	debug(warning, 'Pase'),
	length(TargetList, CantTargets),
	random(1, CantTargets, Index),
	nth1(Index, TargetList, Target).
	
	
% explore_strat(turn(Turn)):-
	% direction(Dir),
	% random(0, 2, Num),
	% next_random(Num, Dir, Turn).

% next_random(0, Dir, Turn):-
	% next_90_clockwise(Dir, Turn).

% next_random(1, Dir, Turn):-
	% next_90_clockwise(Dir, Dir1),
	% next_90_clockwise(Dir1, Dir2),
	% next_90_clockwise(Dir2, Turn).
