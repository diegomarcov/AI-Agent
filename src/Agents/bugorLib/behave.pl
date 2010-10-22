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
	direction(D),
	NX is X - 3,
	NY is Y + 2,
	assert(meta([NX, NY])),
	debug_term(warning, 'Meta: ', meta([NX, NY])),
	debug_term(warning, 'Pos: ', [X, Y]),
%   debug_term(error, 'Path: ', Path),
%   debug_term(error, 'Actions: ', NAcs),
	justdoit([node([X, Y], 0, [])], _,_),
	read(_),
	current_action(Action),
	pop_action.
%   explore_strat(Action).

decide_action(Action):-
	current_strategy(explore),
	current_action(Action),
	pop_action.

justdoit(Init, RPath, Cost):-
	search(Init, Path, Cost),
	reverse(Path, [], RPath),
	translateAll(RPath, D),
	planning_stack(Acs),
	reverse(Acs, [], NAcs),
	replace(planning_stack(Acs), planning_stack(NAcs)).
