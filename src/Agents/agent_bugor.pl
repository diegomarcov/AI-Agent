%% Player-Agent bugor

% Primitivas base del agente
:- consult(ag_primitives), consult(extras_for_agents).

% Predicados auxiliares para comodidad en el manejo de datos
:- consult(bugorLib/auxiliares).

% Predicados que controlan el procesado de la percepsion
:- consult(bugorLib/percept).

% Predicados dinamicos para la percepsion
:- dynamic map/3.
:- dynamic turn/1.
:- dynamic posadas/1.
:- dynamic oro/2.
:- dynamic agentes/1.
:- dynamic ag_name/1.

% init de los predicados dinamicos
turn(0).
posadas([]).
agentes([]).

run:-
      get_percept(Perc),
      update_state(Perc),
      % decide_action(Action),
	  % ag_name(AgName),
      % display_ag(AgName, Perc), nl,
      % agregado esto para que el agente actue en modo joystick
	  % write('ACCION?: '), read(Action),
	  random(0,20,ActionNumber),
	  decide_action(ActionNumber, Action),
	  do_action(Action),
%       do_action(none),
      run.
      
decide_action(0, turn(n)).
decide_action(1, turn(s)).
decide_action(2, turn(e)).
decide_action(3, turn(w)).
decide_action(_, move_fwd).
      
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
