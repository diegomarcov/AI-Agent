fleeHostel_strat:-
	planning_stack([]),
	me(P, _, _, _, _),
	not(posadas(P)),
	most_close_hostel.

most_close_hostel:-
	findall([X, Y], posadas([X, Y]), P),
	astar_all_hostel(P, L),
	L = [[_Cost, Pl, _T] | _Ls],
	replace(planning_stack(_), planning_stack(Pl)).

astar_all_hostel([], []).

astar_all_hostel([T|Ts], Lsorted):-
	me(Pos, _, _, _, _),
	replace(meta(_), meta(T)),
	justdoit(Pos, _, Cost),
	planning_stack(Pl),
	astar_all_hostel(Ts, NL),
	append([[Cost, Pl, T]], NL, L),
	sort(L, Lsorted).
