:- dynamic meta/1.

% Algoritmo de busqueda
:- consult(astar).

% Estrategia general
:- consult(strategies/general).

% X puede ser: initial, explore, hitNrun, pickGold, fleeLikeAPussy, fleeHostel,
% killkillkill
current_strategy(X):- strategy_stack([X|_]).

decide_action(Action):- 
	current_strategy(explore),
	current_pos([X, Y]),
	NX is X - 3,
	NY is Y + 2,
	assert(meta([NX, NY])),
	debug_term(warning, 'Meta: ', meta([NX, NY])),
	debug_term(warning, 'Pos: ', [X, Y]),
	search([node([X, Y], 0, [])]),
	explore_strat(Action).
