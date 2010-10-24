explore_strat:-
	getNotVisited([Self | NotVisited]),
	explore_unknown(NotVisited).

explore_unknown([]).

explore_unknown([Target|Targets]):-
	current_pos([X,Y]),
	debug_term(warning, 'Current pos = ', [X,Y]),
	replace(meta(_), meta(Target)),
	debug_term(warning, 'Meta: ', meta(Target)),
	justdoit([X,Y],_,Cost),
	debug_term(warning, 'Pase el A*.... LETS A-GO!', Cost),
	( Cost \= inf ; read(_), explore_unknown(Targets) ).
	
explore_strat:-
	debug(warning, 'Fallo el A*. Ahora veo si giro.'),
	direction(Dir),
	random(0, 8, Num),
	Num < 2,
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

getNotVisited(TargetList3):-
	current_pos(Pos),
	findall([C, X, Y], 
		(
			map(X,Y,Land),
			h(Pos, [X, Y], C),
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
	debug_term(warning, 'Pase', TargetList),
	sort(TargetList, TargetList2),
	debug(warning, 'Pase2'),
	findall([X1, Y1], member([C1, X1, Y1], TargetList2), TargetList3),
	debug_term(warning, 'TargetList: ', TargetList3).
%   length(TargetList, CantTargets),
%   random(1, CantTargets, Index),
%   nth1(Index, TargetList, Target).
	
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
