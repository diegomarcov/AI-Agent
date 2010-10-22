:- dynamic meta/1.

% Algoritmo de busqueda
:- consult(astar).

% Estrategia general
:- consult(strategies/general).

% X puede ser: initial, explore, hitNrun, pickGold, fleeLikeAPussy, fleeHostel,
% killkillkill
current_strategy(X):- strategy_stack([X|_]).
current_action(X):- planning_stack([X|_]).
current_action(none):- planning_stack([]).
pop_action:- planning_stack([X|Xs]), replace(planning_stack([X|Xs]), planning_stack(Xs)).
push_action(Action):- planning_stack(X), replace(planning_stack(X), planning_stack([Action|X])).

decide_action(Action):- 
	current_strategy(explore),
	planning_stack([]),
	current_pos([X, Y]),
	NX is X - 3,
	NY is Y + 2,
	assert(meta([NX, NY])),
	debug_term(warning, 'Meta: ', meta([NX, NY])),
	debug_term(warning, 'Pos: ', [X, Y]),
	search([node([X, Y], 0, [])], Path, Cost),
	translateAll(Path),
	debug_term(error, 'Path: ', Path),
	planning_stack(Acs),
	debug_term(error, 'Actions: ', Acs),
	read(_),
	current_action(Action).
%   explore_strat(Action).

decide_action(Action):-
	current_strategy(explore),
	current_action(Action),
	pop_action.
