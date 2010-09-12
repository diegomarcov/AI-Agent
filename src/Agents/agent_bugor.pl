%% Player-Agent joystick


% La percepcion que recibe originalmente el agente es esta:
% [1,[[[8,6],plain,[]],[[7,6],water,[]],[[6,6],water,[]],[[5,6],water,[]],[[8,5],plain,[]],[[7,5],water,[]],[[6,5],plain,[]],[[5,5],plain,[]],[[8,7],plain,[[agent,bugor,[[dir,n],[unconscious,false],[previous_turn_action,none]]]]],[[7,7],plain,[]],[[6,7],plain,[]],[[5,7],plain,[[treasure,t1,[[val,100]]]]],[[8,8],mountain,[]],[[7,8],mountain,[]],[[6,8],plain,[]],[[5,8],plain,[]],[[8,9],plain,[]],[[7,9],mountain,[[treasure,t4,[[val,100]]]]],[[6,9],mountain,[]],[[5,9],plain,[]]],[[pos,[8,7]],[dir,n],[stamina,150],[max_stamina,150],[fight_skill,100]],[]]
:- consult(ag_primitives), consult(extras_for_agents).

:- dynamic map/3.
:- dynamic turn/1.
:- dynamic posadas/1.
:- dynamic oro/2.
:- dynamic agentes/1.

turn(0).

run:-
      get_percept(Perc),
      
	  write(Perc), nl,
	  
      update_state(Perc),

      %decide_action(Action),
	  ag_name(AgName),
      
      display_ag(AgName, Perc), nl,
      
      write('ACCION?: '), read(Action),
      
	  do_action(Action),
      
      run.
      
% Auxiliares %%%%%%%%%%%%%%%%%%%%%

% Reemplaza conocimiento guardado con asserts
replace(X, Y):- retractall(X), !,
                assert(Y).

% Caso especial en que el retractall falla 
% porque no existe el conocimiento X
replace(X, Y):- assert(Y).

% Utilizado para "recordar" cosas solo una
% vez
assert_once(X):- replace(X, X).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Percept %%%%%%%%%%%%%%%%%%%%%%%%
update_state([Turn, Vision, Attr, Inventory]):- save_map(Vision),
                                                save_turn(Turn).

% TODO: TRACEARRRRRRRRRRRRRRRRRRR
% Mapa %%%%%%%%%%%%%%%%%%%%%%%%%%

% Recorre todos los elementos a la vista
% y los analiza por separado
% El primer VISION recibido es:

% [[[8,6],plain,[]],[[7,6],water,[]],[[6,6],water,[]],[[5,6],water,[]],[[8,5],plain,[]],[[7,5],water,[]],[[6,5],plain,[]],[[5,5],plain,[]],[[8,7],plain,[[agent,bugor,[[dir,n],[unconscious,false],[previous_turn_action,none]]]]],[[7,7],plain,[]],[[6,7],plain,[]],[[5,7],plain,[[treasure,t1,[[val,100]]]]],[[8,8],mountain,[]],[[7,8],mountain,[]],[[6,8],plain,[]],[[5,8],plain,[]],[[8,9],plain,[]],[[7,9],mountain,[[treasure,t4,[[val,100]]]]],[[6,9],mountain,[]],[[5,9],plain,[]]]

% El primer ObjectsAtSight recibido es:
% [[[8,7],[agent,bugor,[[dir,n],[unconscious,false],[previous_turn_action,none]]]],[[5,7],[treasure,t1,[[val,100]]]],[[7,9],[treasure,t4,[[val,100]]]]]
save_map(Vision):- write('Getting objects at sight...'), nl, objects_at_sight(Vision, ObjectsAtSight), write(Vision), nl, nl, nl, write(ObjectsAtSight),
					forall(member([Pos, Obj], ObjectsAtSight), (analize_things([Pos, Obj]))), write('Done with forall'), nl.

% Analiza un elemento visto
% Si es oro o posada, recuerdo
% la posicion
%
% NOTA: Las posadas parecen tener Type=hostel, Attr=[].
analize_things([Pos, Obj]):- Obj = [Type, Name, Attrs],
							Type = hostel,
							posadas(P),
							% Agrego la posada a la lista
							replace(posadas(_), posadas([Pos | P])).

% NOTA: Los tesoros tienen como atributo el valor
% pero parece ser siempre 100.
analize_things([Pos, Obj]):- Obj = [Type, Name, Attrs],
							Type = treasure,
							% Agrego el tesoro
							assert_once(oro(Pos)).

% NOTAS: 
% - Recordar ver si el agente es uno mismo
% - En los atributos:
%    - previous_turn_action = {none, attack(name), turn(orientation), pickup(objname), move_fwd}
%    - unconcious = {true, false}
%    - dir = {n, s, w, e}
analize_things([Pos, Obj]):- Obj = [Type, Name, Attrs],
							Type = agent,
							Name \= bugor, % Descartamos analizar este mismo agente
							% Para todos los agentes: se lo recuerda y se lo asigna a una zona
							forall(member([AtrName, Value], Attrs), (remember_agent(Name, [AttrName, Value]), zone_it(Name, Pos))).

analize_things([Pos, Obj]):- Obj = [Type, Name, Attrs],
							Type = agent.
% Predicado para filtrar atributos de agente
%
% Si se lo vio atacando a otro, y ya conocemos a este agente:
%
% TODO: reordenar la lista con prioridad cuando se actualizan los datos de un agente ya conocido
remember_agent(Name, [previous_turn_action, attack(VictimName)]):- agentes(A), 
																	member(agente(Name, Attack, Picking), A),
																	Attack is Attack + 1.

% Si el predicado member falla, es decir, nunca vimos a este agente:
remember_agent(Name, [previous_turn_action, attack(VictimName)]):- agentes(A),
																	priority_insert(Name, 1, 0).

% Analogamente para los tesoros recojidos
remember_agent(Name, [previous_turn_action, pickup(_)]):- agentes(A), 
															member(agente(Name, Attack, Picking), A),
															Picking is Picking + 1.

% Si el predicado member falla, es decir, nunca vimos a este agente:
remember_agent(Name, [previous_turn_action, pickup(_)]):- agentes(A),
															priority_insert(Name, 0, 1).

% Inserta a un agente en el orden correspondiente segun la prioridad
% TODO: Por ahora lo inserta adelante, hay que hacer insercion con criterio
priority_insert(Name, Attack, Picking):- replace(agentes(_), agentes([agente(Name, Attack, Picking) | A])).

% Dado un agente y una posicion se analiza si agregarlo a una zona existente o
% crear una zona nueva
% TODO: hacer
zone_it(Pos, Name).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save_turn(Turn):- retract(turn(_)), assert(turn(Turn)). % guardo el numero de turno actual

decide_action(attack(Victim)).
      
:- dynamic ag_name/1.


start_ag:- AgName = bugor,
           register_me(AgName, Status),
           !,
           write('REGISTRATION STATUS: '),
           write(Status), nl, nl,
           Status = connected,
           assert(ag_name(AgName)),
           run.
   
s:- start_ag.


start_ag_instance(InstanceID):-
                    AgClassName = bugor,
                    AgInstanceName =.. [AgClassName, InstanceID],
                    register_me(AgInstanceName, Status),
                    !,
                    write('REGISTRATION STATUS: '),
                    write(Status), nl, nl,
                    Status = connected,
                    assert(ag_name(AgInstanceName)),
                    run.

si(InstanceID):- start_ag_instance(InstanceID).