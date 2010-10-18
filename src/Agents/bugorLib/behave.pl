% Algoritmo de busqueda
:- consult(astar).

% Estrategia general
:- consult(strategies/general).

% X puede ser: initial, explore, hitNrun, pickGold, fleeLikeAPussy, fleeHostel,
% killkillkill
current_strategy(X):- strategy_stack([X|_]).

decide_action(Action):- 
	write('CAMINOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO1'), nl,
	current_strategy(explore),
	write('CAMINOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO2'), nl,
	current_pos([X, Y]),
	write('CAMINOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO3'), nl,
	NX is X - 3,
	NY is Y + 2,
	assert(meta(NX, NY)),
	write('CAMINOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO4'), nl,
	search([node([X, Y], 0, Path)]),
	write('CAMINOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO'), nl,
	write(Path), nl,
	explore_strat(Action).
