:- dynamic meta/1.

% Algoritmo de busqueda
:- consult(astar).

% Estrategia general
:- consult(strategies/general).

% Estrategia para buscar tesoros
:- consult(strategies/treasures).

% X puede ser: initial, explore, hitNrun, treasures, fleeLikeAPussy, fleeHostel,
% killkillkill
push_strategy(St):- strategy_stack(X), replace(strategy_stack(X), strategy_stack([St|X])).
pop_strategy:- strategy_stack([X|Xs]), replace(strategy_stack([X|Xs]), strategy_stack(Xs)).
pop_strategy.
current_strategy(X):- strategy_stack([X|_]).
current_action(X):- planning_stack([X|_]).
current_action(none):- planning_stack([]).
pop_action:- planning_stack([X|Xs]), replace(planning_stack([X|Xs]), planning_stack(Xs)).
pop_action.
push_action(Action):- planning_stack(X), replace(planning_stack(X), planning_stack([Action|X])).
reset_actions:- replace(planning_stack(_), planning_stack([])).

decide_action(Action):- 
	current_strategy(explore),
	planning_stack([]),
	% current_pos([X, Y]),
	% direction(D),
	% NX is X - 3,
	% NY is Y + 2,
	% assert(meta([NX, NY])),
	% debug_term(warning, 'Meta: ', meta([NX, NY])),
	% debug_term(warning, 'Pos: ', [X, Y]),
	% debug_term(error, 'Path: ', Path),
	% debug_term(error, 'Actions: ', NAcs),
	% justdoit([X, Y], _,_),
	% read(_),
	% current_action(Action),
  explore_strat,
	current_pos(Pos),
%   justdoit(Pos, _Path, Cost),
%   debug_term(warning, 'FIN: ', Cost),
	debug(warning, 'Termine de explorar'),
%   read(_),
	current_action(Action), 
	debug_term(warning, 'Ahora voy a ', Action),
	pop_action.

decide_action(Action):-
%   debug(warning, 'A CIEGAS'),
	current_strategy(explore),
	current_action(Action),
	debug_term(warning, 'No hice A*. Ahora voy a ', Action),
	pop_action.

% init es la lista [X,Y] con la posicion inicial; en RPath y Cost se devuelve el path invertido y el costo
% justdoit va hacia el nodo marcado por el predicado meta/1
justdoit(Init, RPath, Cost):-
	reset_actions,
	debug(error, 'Antes del search'),
%   gtrace,
	direction(D),
	search([node(Init,0,[],D)], Path, Cost),
	retractall(visitado(_)),
	debug(error, 'Despues del search'),
	reverse(Path, [], RPath),
	translateAll(RPath),
	planning_stack(Acs),
	reverse(Acs, [], NAcs),
	debug_term(error, 'Path: ', Path),
	debug_term(error, 'Actions: ', NAcs),
	replace(planning_stack(Acs), planning_stack(NAcs)).

% decide_strategy:-
%   turn(T),
%   T > 10,
%   current_strategy(X),
%   X \= treasures,
%   push_strategy(treasures).

decide_strategy:-
	current_strategy(treasures),
	findall([Name, Pos, T], oro(Name, Pos, T), O),
	O = [],
	gtrace,
	pop_strategy.

decide_strategy:-
	strategy_stack([]),
	push_strategy(explore).

decide_strategy.
