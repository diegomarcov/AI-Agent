explore_unknown([]).

explore_unknown([Target|Targets]):-
	me([X, Y], _, _, _, _),
	replace(meta(_), meta(Target)),
	justdoit([X,Y],_,Cost),
	( Cost \= 100000 ; explore_unknown(Targets) ).

explore_unknown1([Self | NotVisited]):-
	me(CPos, _, _, _, _),
	Self = CPos,
	explore_unknown(NotVisited).

explore_unknown1(NotVisited):-
	explore_unknown(NotVisited).

explore_strat:-
	getNotVisited(NotVisited),
	NotVisited \= [],
	explore_unknown1(NotVisited).

% Si ya conozco todo el mapa, voy a explorar a donde recuerdo que habia tesoros
explore_strat:-
	findall([Name, Pos, T], oro(Name, Pos, T), Which),
	treasures_strat(Which),
	planning_stack(X), % si no recuerdo que habia ningun tesoro, falla
	X \= [].

% si la anterior fallo, voy a algun lugar aleatorio para ver que pasa
explore_strat:-
	findall([X, Y], (map(X, Y, Land), (Land = mountain; Land = plain)), Targets),
	length(Targets, CantTargets),
	random(1, CantTargets, Index),
	nth1(Index, Targets, Target),
	explore_unknown([Target]).
	
explore_strat:-
	me(_, Dir, _, _, _),
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
	me(Pos, _, _, _, _),
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
	sort(TargetList, TargetList2),
	findall([X1, Y1], member([_C1, X1, Y1], TargetList2), TargetList3).
