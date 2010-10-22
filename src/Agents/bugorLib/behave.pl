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
	debug_term(warning, 'Meta: ', meta(NX, NY)),
	debug_term(warning, 'Pos: ', [X, Y]),
%     neighbors(node([X, Y], 0, []), NN),
%     debug_term(warning, 'Neighbors ', NN),
	read(_),
	write('CAMINOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO4'), nl,
	search([node([X, Y], 0, [])]),
	explore_strat(Action).
