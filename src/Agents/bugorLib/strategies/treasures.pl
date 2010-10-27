treasures_strat(Which):-
	planning_stack([]),
	me(P, _, _, _, _),
	not(oro(_, P, _)),
	most_close(Which).

most_close(Which):-
	astar_all(Which, L),
	turno(T),
	mincost_maxturn(L, [_, P, _], T),
	replace(planning_stack(_), planning_stack(P)).

astar_all([T|Ts], L):-
	me(Pos, _, _, _, _),
	T = [_, TPos, _],
	replace(meta(_), meta(TPos)),
	justdoit(Pos, _, Cost),
	planning_stack(Pl),
	astar_all(Ts, NL),
	append([[T, Pl, Cost]], NL, L).

astar_all([], []).

mincost_maxturn([Min | []], Min, _).

mincost_maxturn([T2|Ls], Min, T):-
	mincost_maxturn(Ls, T1, T),
	giveme_min(T1, T2, Min, T).

giveme_min([[Name1,Pos1,T1], P1, C1], [[_Name2, _Pos2, _T2], _P2, C2], Min, _T):-
	C1 = inf,
	C2 = inf,
	Min = [[Name1, Pos1, T1], P1, C1].

giveme_min([[_Name1,_Pos1,_T1], _P1, C1], [[Name2, Pos2, T2], P2, C2], Min, _T):-
	C1 = inf,
	C2 \= inf,
	Min = [[Name2, Pos2, T2], P2, C2].

giveme_min([[Name1,Pos1,T1], P1, C1], [[_Name2, _Pos2, _T2], _P2, C2], Min, _T):-
	C1 \= inf,
	C2 = inf,
	Min = [[Name1, Pos1, T1], P1, C1].

giveme_min([[Name1,Pos1,T1], P1, C1], [[Name2, Pos2, T2], P2, C2], Min, T):-
	RC1 is (T - T1) + C1,
	RC2 is (T - T2) + C2,
	(
		(
			RC2 < RC1,
			Min = [[Name2, Pos2, T2], P2, C2]
		) ; (
			Min = [[Name1, Pos1, T1], P1, C1]
		)
	).
