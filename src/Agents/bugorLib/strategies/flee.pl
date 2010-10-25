flee_strat:-
	findall([X, Y], (map(X, Y, Land), (Land = mountain; Land = plain)), Targets),
	add_parts(Targets, Targets1),
	sort(Targets1, Targets2),
	reverse(Targets2, RTargets),
	findall([X,Y], member([_H, [X, Y]], RTargets), RTargets2),
	explore_unknown(RTargets2).

add_parts([], []).

add_parts([map(X, Y, _L)|Ts], Parts):-
	add_parts(Ts, Parts2),
	me(Pos, _, _, _, _),
	h(Pos, [X, Y], H),
	Parts = [[H, [X, Y]]| Parts2].
