:- dynamic meta/1.

% Algoritmo de busqueda
:- consult(astar).

% Estrategia general
:- consult(strategies/general).

% Estrategia para buscar tesoros
:- consult(strategies/treasures).

% Estrategia para huir al hostel
:- consult(strategies/fleehostel).

% Estrategia para huir al hostel
:- consult(strategies/flee).

% Estrategia para atacar a otro agente
:- consult(strategies/attack).

push_strategy(St):- strategy_stack(X), replace(strategy_stack(X), strategy_stack([St|X])).
pop_strategy:- strategy_stack([X|Xs]), replace(strategy_stack([X|Xs]), strategy_stack(Xs)).
pop_strategy.
current_strategy(X):- strategy_stack([X|_]).
current_strategy(explore):- strategy_stack([]), push_strategy(explore).
current_action(X):- planning_stack([X|_]).
current_action(none):- planning_stack([]).
pop_action:- planning_stack([X|Xs]), replace(planning_stack([X|Xs]), planning_stack(Xs)).
pop_action.
push_action(Action):- planning_stack(X), replace(planning_stack(X), planning_stack([Action|X])).
reset_actions:- replace(planning_stack(_), planning_stack([])).

decide_action(pickup(Name)):-
	me(Pos, _, _, _, _),
	oro(Name, Pos, _),
	debug(info, 'OH! Hay oro aca... juntando'),
	retractall(oro(Name, Pos, _)). % Nos olvidamos que estaba ahi

decide_action(rest):-
	me(Pos, _, St, MSt, _),
	posadas(Pos),
	Perc is St * 100 / MSt,
	Perc < 95,
	debug(info, 'Apa! que cansado que estoy... mejor me planto aca').

decide_action(attack(AgName)):-
	current_strategy(X),
	X \= fleeHostel,
	sight(Sight),
	ag_name(Bugor),
	findall(Name, (member([_Pos, [agent, Name, Attrs]], Sight), Name \= Bugor), Ags),
	attackable(Ags, AgName, AgP),
	member([AgP, [agent, AgName, Attrs]], Sight),
	member([dir, D], Attrs),
	member([unconscious, false], Attrs),
	onback(AgP, D),
	at_attack_pos(AgP),
	debug(info, 'DIE DIE DIE').

decide_action(Action):- 
	current_strategy(explore),
	planning_stack([]),
	explore_strat,
	current_action(Action), 
	pop_action.

decide_action(Action):-
	current_strategy(explore),
	current_action(Action),
	pop_action.

decide_action(Action):-
	current_strategy(fleeHostel),
	planning_stack([]),
	fleeHostel_strat,
	doit_orpop(Action).

decide_action(Action):-
	current_strategy(fleeHostel),
	current_action(Action),
	pop_action.

decide_action(Action):-
	current_strategy(treasures),
	planning_stack([]),
	sight(AtSight),
	turno(T),
	findall([Name, Pos, T], member([Pos, [treasure, Name, _]], AtSight), Which),
	treasures_strat(Which),
	doit_orpop(Action).

decide_action(Action):-
	current_strategy(treasures),
	doit_orpop(Action).

decide_action(Action):-
	current_strategy(flee),
	planning_stack([]),
	flee_strat,
	doit_orpop(Action).

decide_action(Action):-
	current_strategy(flee),
	doit_orpop(Action).

% init es la lista [X,Y] con la posicion inicial; en RPath y Cost se devuelve el path invertido y el costo
% justdoit va hacia el nodo marcado por el predicado meta/1
justdoit(Init, RPath, Cost):-
	reset_actions,
	me(_, D, _, _, _),
	search([node(Init,0,[],D)], Path, Cost),
	retractall(visitado(_)),
	reverse(Path, RPath),
	translateAll(RPath),
	planning_stack(Acs),
	reverse(Acs, NAcs),
	replace(planning_stack(Acs), planning_stack(NAcs)).

decide_strategy:-
	sight(Sight),
	ag_name(Bugor),
	member([_, [agent, Bugor, Attrs]], Sight),
	member([attacked_by, Names], Attrs),
	debug_term(info, 'AHHHHH ME ATACA', Names),
	debug(info, 'Yo mejor me rajo...'),
	current_strategy(X),
	X \= flee,
	push_strategy(flee).

decide_strategy:-
	current_strategy(X),
	X \= fleeHostel,
	me(_Pos, _Dir, St, MSt, _FS),
	Perc is St * 100 / MSt,
	Perc < 40,
	push_strategy(fleeHostel),
	reset_actions,
	debug(info, 'Upa... Mejor me voy al hostel mas cercano!').

decide_strategy:-
	current_strategy(fleeHostel),
	me(_Pos, _Dir, St, MSt, _FS),
	Perc is St * 100 / MSt,
	Perc >= 95,
	pop_strategy,
	debug(info, 'Listo la recargada, sigamos...').

decide_strategy:-
	sight(AtSight),
	member([_Pos, [treasure, _Name, _]], AtSight), % si veo algun tesoro
	current_strategy(X),
	X \= fleeHostel, % si estamos huyendo a una posada, no cambiamos de estrategia
	X \= flee, % si nos estan atacando seguir huyendo
	X \= treasures, % la estrategia actual no es buscar tesoros
	push_strategy(treasures), % defino la estrategia de busqueda de tesoros
	debug(info, 'Hmmm me parece que he visto un lindo tesorito... MIO!').

decide_strategy:-
	strategy_stack([]),
	push_strategy(explore),
	debug(info, 'Ante la duda, exploremos').

decide_strategy.

doit_orpop(Action):-
	planning_stack([]),
	pop_strategy,
	decide_action(Action).

doit_orpop(Action):-
	current_action(Action),
	pop_action.
