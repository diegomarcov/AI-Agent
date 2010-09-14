% Percept %%%%%%%%%%%%%%%%%%%%%%%%

update_state([Turn, Vision, Attr, Inventory]):- save_turn(Turn), 
												save_map(Vision).
% TODO: 
%	- Ver que se guarde bien el mapa


% Mapa %%%%%%%%%%%%%%%%%%%%%%%%%%

% Recorre todos los elementos a la vista
% y los analiza por separado
save_map(Vision):- 
	forall(member([[X, Y], Land, Objects], Vision), assert_once(map(X, Y, Land))), % Guardamos el mapa
	objects_at_sight(Vision, ObjectsAtSight), % Recolectamos los objetos que vemos
	forall(member([Pos, Obj], ObjectsAtSight), (analize_things([Pos, Obj]))), write_file('Done with forall'), nl. % Se los analiza uno a uno

% Analiza un elemento visto
% Si es oro o posada, recuerdo
% la posicion
%
% NOTA: Las posadas parecen tener Type=hostel, Attr=[].
% este es el caso en el que pasa por un hotel que ya conoce
analize_things([Pos, Obj]):- 
	write_file('I am currently analizing this: '),nl,nl, write_file(Obj),nl,nl,
	Obj = [Type, Name, Attrs],
	Type = hostel, nl, nl, write_file('Ho visto a Hostel'), nl, nl,
	posadas(P),
	member(Pos, P),
	% Agrego la posada a la lista
	write_file('Ya conozco este hostel! Mi lista de posadas actual es:'), nl, write_file(P), nl, nl.
							
% en este caso, el agente ve un hotel nuevo							
analize_things([Pos, Obj]):- 
	Obj = [Type, Name, Attrs],
	Type = hostel, nl, nl, write_file('Ho visto a Hostel'), nl, nl,
	posadas(P),
	% Agrego la posada a la lista
	replace(posadas(_), posadas([Pos | P])),
	write_file('Hostel added! Mi lista de posadas actual es:'), nl, write_file([Pos|P]), nl, nl.

% NOTA: Los tesoros tienen como atributo el valor
% pero parece ser siempre 100.
analize_things([Pos, Obj]):- 
	Obj = [Type, Name, Attrs],
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
analize_things([Pos, Obj]):- 
	Obj = [Type, Name, Attrs],
	Type = agent,
	Name \= bugor, % Descartamos analizar este mismo agente
	% Para todos los agentes: se lo recuerda y se lo asigna a una zona
	write_file('Analizando un agenteeuuueiii    ---->'), write_file(Attrs),nl,
	forall(member([AttrName, Value], Attrs), (remember_agent(Name, [AttrName, Value]), zone_it(Name, Pos))).
							
% este caso es cuando bugor se ve a si mismo; simplemente se ignora
% otra opcion: imprimir un simpatico cartel que diga "HELLO! IT'S-A ME, BUUUUGOOOOR!"
analize_things([Pos, Obj]):- 
	Obj = [Type, Name, Attrs],
	Type = agent,
	Name = bugor,
	write_file('HELLO! IT´S-A ME, BUUUUGOOOOR!').

% Predicado para filtrar atributos de agente
%
% Si se lo vio atacando a otro, y ya conocemos a este agente:
%
% TODO: reordenar la lista con prioridad cuando se actualizan los datos de un agente ya conocido
remember_agent(Name, [previous_turn_action, attack(_)]):- 
	write_file('################### A'),nl,nl,agentes(A), 
	write_file('cette le list: '),write_file(A),
	member(agente(Name, Attack, Picking), A),
	write_file('le agent:'),write_file(agente(Name, Attack, Picking)),
	subtract(A, [agente(Name, Attack, Picking)], NewA),
	NewAttack is Attack + 1,
	write_file(NewA),
	replace(agentes(_), agentes(NewA)),
	insert_agent(Name, NewAttack, Picking),
	agentes(VerA),
	write_file('LISTA DESPUES'),
	write_file(VerA),
	write_file('YOU BULLY BASTARD '), write_file(Name), nl, nl.

% Si el predicado member falla, es decir, nunca vimos a este agente:
remember_agent(Name, [previous_turn_action, attack(_)]):- 
	write_file('################### B'),nl,nl,
	insert_agent(Name, 1, 0),
	write_file('Epa! Y este quien es?').

% Analogamente para los tesoros recojidos
remember_agent(Name, [previous_turn_action, pickup(_)]):- 
	write_file('################### C'),nl,nl,agentes(A), 
	write_file('cette le list: '),write_file(A),
	member(agente(Name, Attack, Picking), A),
	write_file('le agent:'),write_file(agente(Name, Attack, Picking)),
	subtract(A, [agente(Name, Attack, Picking)], NewA),
	NewPick is Picking + 1,
	write_file(NewA),
	replace(agentes(_), agentes(NewA)),
	insert_agent(Name, Attack, NewPick),
	agentes(VerA),
	write_file('LISTA DESPUES'),
	write_file(VerA),
	write_file('YOU GREEDY BASTARD '), write_file(Name), nl, nl.

% Si el predicado member falla, es decir, nunca vimos a este agente:
remember_agent(Name, [previous_turn_action, pickup(_)]):- 
	write_file('################### D'),nl,nl,
	insert_agent(Name, 0, 1),
	write_file('Done adding pick'),nl.

% Si el agente no hizo nada
remember_agent(Name, [previous_turn_action, none]):- 
	write_file('################### E'),nl,nl,
	insert_agent(Name, 0, 0).

% Si el agente no hizo nada
remember_agent(Name, [Attr, Val]):- 
	write_file('****** No se que hacer con esto: '), 
	write_file(Attr), 
	write_file('<->'), 
	write_file(Val).

% Inserta a un agente en la lista
% Caso especial: 
%	- Cuando el agente tiene como previous_turn_action= none trata de agregar
%	al agente con 0,0, por eso se checkea not(member(agente(Name, _, _)
insert_agent(Name, Attack, Picking):- 
	agentes(A), 
	not(member(agente(Name, _, _), A)), 
	replace(agentes(_), 
	agentes([agente(Name, Attack, Picking) | A])).

% Caso especial que el agente ya este insertado, no se hace nada.
% Es decir, el not(memeber()) falla
insert_agent(Name, Attack, Picking).

% Dado un agente y una posicion se analiza si agregarlo a una zona existente o
% crear una zona nueva
% TODO: hacer
zone_it(Pos, Name).

% Guardo el numero de turno actual
save_turn(Turn):- 
	retract(turn(_)), 
	assert(turn(Turn)).
