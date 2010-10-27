% Agents: lista de nombres de agentes
attackable(Agents, Ag, _Pos):-
	add_agents(Agents, Ags),
	sort(Ags, AgOrder1),
	reverse(AgOrder1, AgOrder),
	AgOrder = [[_Pr, Ag]|_].

add_agents([], []).

add_agents([Ag|Ags], AgOrder1):-
	add_agents(Ags, AgOrder),
	agentes(A),
	member(agente(Ag, Attack, Pick, Slow), A),
	agent_priority(agente(Ag, Attack, Pick, Slow), Pr),
	append([[Pr, Ag]], AgOrder, AgOrder1).

onback(_P, D):-
	me(_, D, _, _, _).

onback([_X1, Y1], e):- me([_X, Y], n, _, _, _), Y < Y1.
onback([_X1, Y1], w):- me([_X, Y], n, _, _, _), Y > Y1.
onback([X1, _Y1], n):- me([X, _Y], e, _, _, _), X > X1.
onback([X1, _Y1], s):- me([X, _Y], e, _, _, _), X < X1.
onback([X1, _Y1], n):- me([X, _Y], w, _, _, _), X > X1.
onback([X1, _Y1], s):- me([X, _Y], w, _, _, _), X < X1.
onback([_X1, Y1], e):- me([_X, Y], s, _, _, _), Y < Y1.
onback([_X1, Y1], w):- me([_X, Y], s, _, _, _), Y > Y1.

at_attack_pos(P):- me(P, _, _, _, _).

at_attack_pos([X, Y]):- me([X1, Y ], n, _, _, _), X is X1 - 1.
at_attack_pos([X, Y]):- me([X1, Y1], n, _, _, _), X is X1 - 1, Y is Y1 - 1.
at_attack_pos([X, Y]):- me([X1, Y1], n, _, _, _), X is X1 - 1, Y is Y1 + 1.
at_attack_pos([X, Y]):- me([X1, Y ], s, _, _, _), X is X1 + 1.
at_attack_pos([X, Y]):- me([X1, Y1], s, _, _, _), X is X1 + 1, Y is Y1 - 1.
at_attack_pos([X, Y]):- me([X1, Y1], s, _, _, _), X is X1 + 1, Y is Y1 + 1.
at_attack_pos([X, Y]):- me([X , Y1], e, _, _, _), Y is Y1 + 1.
at_attack_pos([X, Y]):- me([X1, Y1], e, _, _, _), Y is Y1 + 1, X is X1 - 1.
at_attack_pos([X, Y]):- me([X1, Y1], e, _, _, _), Y is Y1 + 1, X is X1 + 1.
at_attack_pos([X, Y]):- me([X , Y1], w, _, _, _), Y is Y1 - 1.
at_attack_pos([X, Y]):- me([X1, Y1], w, _, _, _), Y is Y1 - 1, X is X1 - 1.
at_attack_pos([X, Y]):- me([X1, Y1], w, _, _, _), Y is Y1 - 1, X is X1 + 1.
