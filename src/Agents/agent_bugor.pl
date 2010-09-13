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
posadas([]).
agentes([]).

run:-
      get_percept(Perc),
      % write_file('This is perceptiooooooooooooooon!'), nl, nl,
	  % write_file(Perc), nl,
	  
      update_state(Perc),

      % decide_action(Action),
	  ag_name(AgName),
      
      display_ag(AgName, Perc), nl,
      % agregado esto para que el agente actue en modo joystick
%       write_file('ACCION?: '), read(Action),
      
%       do_action(Action),
	  do_action(none),
      
      run.
      
% Auxiliares %%%%%%%%%%%%%%%%%%%%%

% Reemplaza conocimiento guardado con asserts
replace(X, Y):- write_file('Trying to retract....'), nl,nl, retractall(X), !,
                assert(Y).

% Caso especial en que el retractall falla 
% porque no existe el conocimiento X
replace(X, Y):- write_file('Retract failed! Asserting only...'),nl,nl,assert(Y).

% Utilizado para "recordar" cosas solo una
% vez
assert_once(X):- write_file('*** asserting '), write_file(X), write_file('***'), nl, nl, replace(X, X).

% Utilizado para "recordar" tesoros solo una
% vez. Se trata aparte porque al almacenar el 
% turno tambien, el assert_once no funciona
assert_once_oro(Pos, Turno):- write_file('*** asserting oro ***'), nl, nl, replace(oro(Pos, _), oro(Pos, Turno)).

% Debug a archivo
write_file(T):- open('debug.txt', append, Stream),
				write(Stream, T),
				nl(Stream),
				close(Stream).

init_debug:- write_file('************************************************************').
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Percept %%%%%%%%%%%%%%%%%%%%%%%%
update_state([Turn, Vision, Attr, Inventory]):- save_turn(Turn), 
												save_map(Vision).

% TODO: TRACEARRRRRRRRRRRRRRRRRRR
% Mapa %%%%%%%%%%%%%%%%%%%%%%%%%%

% Recorre todos los elementos a la vista
% y los analiza por separado
% El primer VISION recibido es:

% [[[8,6],plain,[]],[[7,6],water,[]],[[6,6],water,[]],[[5,6],water,[]],[[8,5],plain,[]],[[7,5],water,[]],[[6,5],plain,[]],[[5,5],plain,[]],[[8,7],plain,[[agent,bugor,[[dir,n],[unconscious,false],[previous_turn_action,none]]]]],[[7,7],plain,[]],[[6,7],plain,[]],[[5,7],plain,[[treasure,t1,[[val,100]]]]],[[8,8],mountain,[]],[[7,8],mountain,[]],[[6,8],plain,[]],[[5,8],plain,[]],[[8,9],plain,[]],[[7,9],mountain,[[treasure,t4,[[val,100]]]]],[[6,9],mountain,[]],[[5,9],plain,[]]]

% El primer ObjectsAtSight recibido es:
% [[[8,7],[agent,bugor,[[dir,n],[unconscious,false],[previous_turn_action,none]]]],[[5,7],[treasure,t1,[[val,100]]]],[[7,9],[treasure,t4,[[val,100]]]]]

% con esta vision se rompe todo:
% [4,[[[5,6],water,[]],[[4,6],water,[]],[[3,6],plain,[]],[[2,6],plain,[]],[[5,5],plain,[]],[[4,5],water,[]],[[3,5],plain,[]],[[2,5],mountain,[]],[[5,7],plain,[[agent,bugor,[[dir,n],[unconscious,false],[previous_turn_action,move_fwd]]],[treasure,t1,[[val,100]]]]],[[4,7],plain,[]],[[3,7],plain,[]],[[2,7],plain,[]],[[5,8],plain,[]],[[4,8],plain,[]],[[3,8],forest,[]],[[2,8],forest,[]],[[5,9],plain,[]],[[4,9],forest,[]],[[3,9],plain,[]],[[2,9],plain,[[hostel,h2,[]],[treasure,t5,[[val,100]]]]]],[[pos,[5,7]],[dir,n],[stamina,147],[max_stamina,150],[fight_skill,100]],[]]

save_map(Vision):- objects_at_sight(Vision, ObjectsAtSight),
					forall(member([Pos, Obj], ObjectsAtSight), (analize_things([Pos, Obj]))), write_file('Done with forall'), nl.

% Analiza un elemento visto
% Si es oro o posada, recuerdo
% la posicion
%
% NOTA: Las posadas parecen tener Type=hostel, Attr=[].
% este es el caso en el que pasa por un hotel que ya conoce
analize_things([Pos, Obj]):- write_file('I am currently analizing this: '),nl,nl, write_file(Obj),nl,nl,
							Obj = [Type, Name, Attrs],
							Type = hostel, nl, nl, write_file('Ho visto a Hostel'), nl, nl,
							posadas(P),
							member(Pos, P),
							% Agrego la posada a la lista
							write_file('Ya conozco este hostel! Mi lista de posadas actual es:'), nl, write_file(P), nl, nl.
							
% en este caso, el agente ve un hotel nuevo							
analize_things([Pos, Obj]):- Obj = [Type, Name, Attrs],
							Type = hostel, nl, nl, write_file('Ho visto a Hostel'), nl, nl,
							posadas(P),
							% Agrego la posada a la lista
							replace(posadas(_), posadas([Pos | P])),
							write_file('Hostel added! Mi lista de posadas actual es:'), nl, write_file([Pos|P]), nl, nl.

% NOTA: Los tesoros tienen como atributo el valor
% pero parece ser siempre 100.
analize_things([Pos, Obj]):- Obj = [Type, Name, Attrs],
							Type = treasure,
							% Agrego el tesoro
							turn(T), % Se guarda el turno en el que se vio
							assert_once_oro(Pos, T),
							findall(X, oro(X, Y), O),
							write_file('Este es mi oro: '), write_file(O), nl.

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
							write_file('Analizando un agenteeuuueiii    ---->'), write_file(Attrs),nl,
							forall(member([AttrName, Value], Attrs), (remember_agent(Name, [AttrName, Value]), zone_it(Name, Pos))).
							
% este caso es cuando bugor se ve a si mismo; simplemente se ignora
% otra opcion: imprimir un simpatico cartel que diga "HELLO! IT'S-A ME, BUUUUGOOOOR!"
analize_things([Pos, Obj]):- Obj = [Type, Name, Attrs],
							Type = agent,
							Name = bugor,
							write_file('HELLO! IT´S-A ME, BUUUUGOOOOR!').

% Predicado para filtrar atributos de agente
%
% Si se lo vio atacando a otro, y ya conocemos a este agente:
%
% TODO: reordenar la lista con prioridad cuando se actualizan los datos de un agente ya conocido
remember_agent(Name, [previous_turn_action, attack(_)]):- write_file('################### A'),nl,nl,agentes(A), 
															write_file('cette le list: '),write_file(A),
															member(agente(Name, Attack, Picking), A),
															write_file('le agent:'),write_file(agente(Name, Attack, Picking)),
															subtract(A, [agente(Name, Attack, Picking)], NewA),
															NewAttack is Attack + 1,
															write_file(NewA),
															replace(agentes(_), agentes(NewA)),
															priority_insert(Name, NewAttack, Picking),
															agentes(VerA),
															write_file('LISTA DESPUES'),
															write_file(VerA),
															write_file('YOU BULLY BASTARD '), write_file(Name), nl, nl.

% Si el predicado member falla, es decir, nunca vimos a este agente:
remember_agent(Name, [previous_turn_action, attack(_)]):- write_file('################### B'),nl,nl,
																	priority_insert(Name, 1, 0),
																	write_file('Epa! Y este quien es?').

% Analogamente para los tesoros recojidos
remember_agent(Name, [previous_turn_action, pickup(_)]):- write_file('################### C'),nl,nl,agentes(A), 
															write_file('cette le list: '),write_file(A),
															member(agente(Name, Attack, Picking), A),
															write_file('le agent:'),write_file(agente(Name, Attack, Picking)),
															subtract(A, [agente(Name, Attack, Picking)], NewA),
															NewPick is Picking + 1,
															write_file(NewA),
															replace(agentes(_), agentes(NewA)),
															priority_insert(Name, Attack, NewPick),
															agentes(VerA),
															write_file('LISTA DESPUES'),
															write_file(VerA),
															write_file('YOU GREEDY BASTARD '), write_file(Name), nl, nl.

% Si el predicado member falla, es decir, nunca vimos a este agente:
remember_agent(Name, [previous_turn_action, pickup(_)]):- write_file('################### D'),nl,nl,
															priority_insert(Name, 0, 1),
															write_file('Done adding pick'),nl.

% Si el agente no hizo nada
remember_agent(Name, [previous_turn_action, none]):- write_file('################### E'),nl,nl,
															priority_insert(Name, 0, 0).

% Si el agente no hizo nada
remember_agent(Name, [Attr, Val]):- write_file('****** No se que hacer con esto: '), write_file(Attr), write_file('<->'), write_file(Val),nl,nl.

% Inserta a un agente en el orden correspondiente segun la prioridad
% TODO: Por ahora lo inserta adelante, hay que hacer insercion con criterio
% Caso especial: 
%	- Cuando el agente tiene como previous_turn_action= none trata de agregar
%	al agente con 0,0, por eso se checkea not(member(agente(Name, _, _)
priority_insert(Name, Attack, Picking):- agentes(A), not(member(agente(Name, _, _), A)), replace(agentes(_), agentes([agente(Name, Attack, Picking) | A])).

% Caso especial que el agente ya este insertado, no se hace nada.
priority_insert(Name, Attack, Picking).

% Dado un agente y una posicion se analiza si agregarlo a una zona existente o
% crear una zona nueva
% TODO: hacer
zone_it(Pos, Name).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save_turn(Turn):- retract(turn(_)), assert(turn(Turn)). % guardo el numero de turno actual

decide_action(attack(Victim)).
      
:- dynamic ag_name/1.


start_ag:- init_debug,AgName = bugor,
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
