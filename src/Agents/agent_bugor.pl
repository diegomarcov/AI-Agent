%% Player-Agent bugor

% Primitivas base del agente
:- consult(ag_primitives), consult(extras_for_agents).

% Predicados auxiliares para comodidad en el manejo de datos
:- consult(bugorLib/auxiliares).

% Predicados que controlan el procesado de la percepsion
:- consult(bugorLib/percept).

% Predicados que controlan el comportamiento
:- consult(bugorLib/behave).

% Predicados dinamicos para la percepsion
:- dynamic map/3.
:- dynamic turno/1.
:- dynamic posadas/1.
:- dynamic oro/3.
:- dynamic agentes/1.
:- dynamic ag_name/1.
:- dynamic direction/1.
:- dynamic current_pos/1.
:- dynamic me/5.
:- dynamic sight/1.

% Predicados dinamicos para el comportamiento
:- dynamic strategy_stack/1.
:- dynamic planning_stack/1.

% init de los predicados dinamicos
turno(0).
agentes([]).
strategy_stack([]).
planning_stack([]).
attacking([]).

run:-
	get_percept(Perc),
	update_state(Perc),
	decide_strategy,
	decide_action(Action),
	do_action(Action),
	run.

start_ag:- 
	init_debug,
	AgName = bugor,
	register_me(AgName, Status),
	!,
	write_file('REGISTRATION STATUS: '),
	write_file(Status), nl, nl,
	Status = connected,
	assert(ag_name(AgName)),
	run.
   
s:- start_ag.

start_ag_instance(InstanceID):-
	AgClassName = bugor,
	AgInstanceName =.. [AgClassName, InstanceID],
	register_me(AgInstanceName, Status),
	!,
	write_file('REGISTRATION STATUS: '),
	write_file(Status), nl, nl,
	Status = connected,
	assert(ag_name(AgInstanceName)),
	run.

si(InstanceID):- start_ag_instance(InstanceID).
