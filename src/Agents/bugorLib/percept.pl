% Percept %%%%%%%%%%%%%%%%%%%%%%%%

update_state([Turn, Vision, Attr, Inventory]):- 
	save_turn(Turn), 
	save_map(Vision).
% TODO: 
%	- Ver que se guarde bien el mapa


% Mapa %%%%%%%%%%%%%%%%%%%%%%%%%%

% Recorre todos los elementos a la vista
% y los analiza por separado
save_map(Vision):- 
	forall(member([[X, Y], Land, Objects], Vision), assert_once(map(X, Y, Land))), % Guardamos el mapa
	findall([X, Y, Land], map(X, Y, Land), Mapa),
	term_to_atom(Mapa, M),
	debug_term(info, 'Known Map: ', M),
	objects_at_sight(Vision, ObjectsAtSight), % Recolectamos los objetos que vemos
	forall(member([Pos, Obj], ObjectsAtSight), (analize_things([Pos, Obj]))). % Se los analiza uno a uno

% Analiza un elemento visto
% Si es oro o posada, recuerdo
% la posicion
%
% NOTA: Las posadas parecen tener Type=hostel, Attr=[].
% este es el caso en el que pasa por un hotel que ya conoce
analize_things([Pos, Obj]):- 
	debug_term(info, 'Currently analizing this: ', Obj),
	Obj = [hostel, Name, Attrs],
	posadas(P),
	member(Pos, P),
	debug_term(info, 'Already known. Known hostels: ', P).

% en este caso, el agente ve un hotel nuevo
analize_things([Pos, Obj]):- 
	debug_term(info, 'Currently analizing this: ', Obj),
	Obj = [hostel, Name, Attrs],
	posadas(P),
	% Agrego la posada a la lista
	replace(posadas(_), posadas([Pos | P])),
	debug_term(info, 'Not known hostel, adding. Known hostels: ', P).

% NOTA: Los tesoros tienen como atributo el valor
% pero parece ser siempre 100.
analize_things([Pos, Obj]):- 
	debug_term(info, 'Currently analizing this: ', Obj),
	Obj = [treasure, Name, Attrs],
	% Agrego el tesoro
	turn(T), % Se guarda el turno en el que se vio
	assert_once_oro(Pos, T),
	findall(X, oro(X, Y), O),
	debug_term(info, 'Known treasures: ', O).

% NOTAS: 
% - Recordar ver si el agente es uno mismo % - En los atributos:
%    - previous_turn_action = {none, attack(name), turn(orientation), pickup(objname), move_fwd}
%    - unconcious = {true, false}
%    - dir = {n, s, w, e}
analize_things([Pos, Obj]):- 
	debug_term(info, 'Currently analizing this: ', Obj),
	Obj = [agent, Name, Attrs],
	Name \= bugor, % Descartamos analizar este mismo agente
	% Para todos los agentes: se lo recuerda
	forall(member([AttrName, Value], Attrs), remember_agent(Name, [AttrName, Value])).

% este caso es cuando bugor se ve a si mismo; simplemente se ignora
analize_things([Pos, Obj]):- 
	Obj = [agent, bugor, Attrs],
	debug(warning,'HELLO! IT´S-A ME, BUUUUGOOOOR!').

% Predicado para filtrar atributos de agente
%
% Si se lo vio atacando a otro, y ya conocemos a este agente:
remember_agent(Name, [previous_turn_action, attack(_)]):- 
	debug(info, 'remember_agent: Case A: The agent is seeing attacking and it´s already known.'),
	agentes(A),
	debug_term(info, 'Known agents: ', A),
	member(agente(Name, Attack, Picking, Slow), A), % Si ya vimos al agente
	debug_term(info, 'Current attacking agent in sight: ', agente(Name, Attack, Picking, Slow)),
	subtract(A, [agente(Name, Attack, Picking, Slow)], NewA), % Lo sacamos temporalmente de la lista
	NewAttack is Attack + 1,
	replace(agentes(_), agentes(NewA)), % Guardamos la lista sin este agente
	insert_agent(Name, NewAttack, Picking, Slow), % Guardamos al agente con los nuevos datos
	agentes(VerA), % Consultamos que todo se haya guardado bien
	debug_term(info, 'Updated agent list: ', VerA).

% Si el predicado member falla, es decir, nunca vimos a este agente:
remember_agent(Name, [previous_turn_action, attack(_)]):- 
	debug(info, 'remember_agent: Case B: The agent is seeing attacking but it´s the first time we saw it.'),
	agentes(A),
	debug_term(info, 'Known agents: ', A),
	insert_agent(Name, 1, 0),
	agentes(VerA), % Consultamos que todo se haya guardado bien
	debug_term(info, 'Updated agent list: ', VerA).

% Analogamente para los tesoros recojidos
remember_agent(Name, [previous_turn_action, pickup(_)]):- 
	debug(info, 'remember_agent: Case C: The agent is seeing picking a treasure and it´s already known.'),
	agentes(A),
	debug_term(info, 'Known agents: ', A),
	member(agente(Name, Attack, Picking, Slow), A), % Si ya vimos al agente
	debug_term(info, 'Current attacking agent in sight: ', agente(Name, Attack, Picking, Slow)),
	subtract(A, [agente(Name, Attack, Picking, Slow)], NewA), % Lo sacamos temporalmente de la lista
	NewPick is Picking + 1,
	replace(agentes(_), agentes(NewA)),
	insert_agent(Name, Attack, NewPick, Slow),
	agentes(VerA), % Consultamos que todo se haya guardado bien
	debug_term(info, 'Updated agent list: ', VerA).

% Si el predicado member falla, es decir, nunca vimos a este agente:
remember_agent(Name, [previous_turn_action, pickup(_)]):- 
	debug(info, 'remember_agent: Case D: The agent is seeing picking a treasure but we don´t know it.'),
	agentes(A),
	debug_term(info, 'Known agents: ', A),
	insert_agent(Name, 0, 1, false),
	agentes(VerA), % Consultamos que todo se haya guardado bien
	debug_term(info, 'Updated agent list: ', VerA).

% Si el agente no hizo nada y ya lo conocemos
remember_agent(Name, [previous_turn_action, none]):- 
	debug(info, 'remember_agent: Case E: The agent is evidently a slow one.'),
	agentes(A),
	debug_term(info, 'Known agents: ', A),
	member(agente(Name, Attack, Picking, Slow), A), % Si ya vimos al agente
	subtract(A, [agente(Name, Attack, Picking, Slow)], NewA), % Lo sacamos temporalmente de la lista
	replace(agentes(_), agentes(NewA)),
	insert_agent(Name, Attack, Picking, true),
	agentes(VerA), % Consultamos que todo se haya guardado bien
	debug_term(info, 'Updated agent list: ', VerA).

% Si el agente no hizo nada y no lo conocimos
remember_agent(Name, [previous_turn_action, none]):- 
	debug(info, 'remember_agent: Case F: The agent is evidently a slow one.'),
	insert_agent(Name, 0, 0, true),
	agentes(VerA), % Consultamos que todo se haya guardado bien
	debug_term(info, 'Updated agent list: ', VerA).

% Si el agente no hizo nada
remember_agent(Name, [Attr, Val]):- 
	debug(warning, 'remember_agent: Case G: What the hell is this?'),
	term_to_atom(Attr, A),
	term_to_atom(Val, V),
	concat(A, ' = ', Str),
	concat(Str, V, Str2),
	debug(warning, Str2).

% Inserta a un agente en la lista
% Caso especial: 
%	- Cuando el agente tiene como previous_turn_action= none trata de agregar
%	al agente con 0,0, por eso se checkea not(member(agente(Name, _, _)
insert_agent(Name, Attack, Picking, Slow):- 
	agentes(A), 
	not(member(agente(Name, _, _, _), A)), 
	replace(agentes(_), 
	agentes([agente(Name, Attack, Picking, Slow) | A])).

% Caso especial que el agente ya este insertado, no se hace nada.
% Es decir, el not(memeber()) falla
insert_agent(Name, Attack, Picking, Slow).

% TODO: Hacer predicado de feasibilidad de ataque de agente
agent_priority(agente(Name, Attack, Pick, false), Priority):-
	Total is Pick + Attack,
	Priority is Pick * 100 / Total.

agent_priority(agente(Name, Attack, Pick, true), Priority):-
	Total is Pick + Attack,
	Temp is Pick * 100 / Total,
	Priority is Temp * 2.

% Guardo el numero de turno actual
save_turn(Turn):- 
	retract(turn(_)), 
	assert(turn(Turn)).
