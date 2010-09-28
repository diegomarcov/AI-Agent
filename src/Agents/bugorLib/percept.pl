% Percept %%%%%%%%%%%%%%%%%%%%%%%%

update_state([Turn, Vision, _Attr, _Inventory]):-
	save_turn(Turn),
	save_map(Vision).

% primer caso: recuerdo que habia oro, y sigue estando
processPosition(X, Y, Land, Objects):-
	assert_once(map(X, Y, Land)),  % Guardamos el mapa
	oro([X,Y],_),
	member([treasure,_name,_data], Objects).
	
% segundo caso: recuerdo que habia oro, pero alguien lo levanto!
processPosition(X, Y, Land, Objects):-
	assert_once(map(X, Y, Land)),  % Guardamos el mapa
	oro([X,Y],_),
	retract(oro([X,Y],_)).

% tercer caso: no recuerdo que haya habido oro anteriormente,
% asi que unicamente guardo el mapa.
processPosition(X, Y, Land, Objects):-
	assert_once(map(X, Y, Land)).  % Guardamos el mapa
	
% Mapa %%%%%%%%%%%%%%%%%%%%%%%%%%

% Recorre todos los elementos a la vista
% y los analiza por separado
save_map(Vision):-
	debug(info, '##################################'),
	forall(member([[X, Y], Land, Objects], Vision), processPosition(X, Y, Land, Objects)), % Guardo el mapa y borro el oro
	findall([X, Y, Land], map(X, Y, Land), Mapa),
	term_to_atom(Mapa, M),
	debug_term(info, 'Known Map: ', M),
	objects_at_sight(Vision, ObjectsAtSight), % Recolectamos los objetos que vemos
	forall(member([Pos, Obj], ObjectsAtSight), (analize_things([Pos, Obj]))),
	posadas(P),
	debug_term(info, 'Known hostels: ', P),
	findall(X, oro(X, _Y), O),
	debug_term(info, 'Known treasures: ', O),
	agentes(A),
	debug_term(info, 'Known agents: ', A).

% Analiza un elemento visto
% Si es oro o posada, recuerdo
% la posicion
%
% NOTA: Las posadas parecen tener Type=hostel, Attr=[].
% este es el caso en el que pasa por un hotel que ya conoce
analize_things([Pos, Obj]):-
	Obj = [hostel, _Name, _Attrs],
	posadas(P),
	member(Pos, P).

% en este caso, el agente ve un hotel nuevo
analize_things([Pos, Obj]):-
	Obj = [hostel, _Name, _Attrs],
	posadas(P),
	% Agrego la posada a la lista
	replace(posadas(_), posadas([Pos | P])).

% NOTA: Los tesoros tienen como atributo el valor
% pero parece ser siempre 100.
analize_things([Pos, Obj]):-
	Obj = [treasure, _Name, _Attrs],
	% Agrego el tesoro
	turn(T), % Se guarda el turno en el que se vio
	assert_once_oro(Pos, T).

% NOTAS:
% - Recordar ver si el agente es uno mismo % - En los atributos:
%    - previous_turn_action = {none, attack(name), turn(orientation), pickup(objname), move_fwd}
%    - unconscious = {true, false}
%    - dir = {n, s, w, e}
analize_things([_Pos, Obj]):-
	Obj = [agent, Name, Attrs],
	Name \= bugor, % Descartamos analizar este mismo agente
	% Para todos los agentes: se lo recuerda
	forall(member([AttrName, Value], Attrs), remember_agent(Name, [AttrName, Value])).

% este caso es cuando bugor se ve a si mismo; simplemente se ignora
analize_things([_Pos, Obj]):-
	Obj = [agent, bugor, _Attrs].

% Predicado para filtrar atributos de agente
%
% Si se lo vio atacando a otro, y ya conocemos a este agente:
remember_agent(Name, [previous_turn_action, attack(_)]):-
	agentes(A),
	member(agente(Name, Attack, Picking, Slow), A), % Si ya vimos al agente
	subtract(A, [agente(Name, Attack, Picking, Slow)], NewA), % Lo sacamos temporalmente de la lista
	NewAttack is Attack + 1,
	replace(agentes(_), agentes(NewA)), % Guardamos la lista sin este agente
	insert_agent(Name, NewAttack, Picking, Slow). % Guardamos al agente con los nuevos datos

% Si el predicado member falla, es decir, nunca vimos a este agente:
remember_agent(Name, [previous_turn_action, attack(_)]):-
	agentes(A),
	insert_agent(Name, 1, 0).

% Analogamente para los tesoros recojidos
remember_agent(Name, [previous_turn_action, pickup(_)]):-
	agentes(A),
	member(agente(Name, Attack, Picking, Slow), A), % Si ya vimos al agente
	subtract(A, [agente(Name, Attack, Picking, Slow)], NewA), % Lo sacamos temporalmente de la lista
	NewPick is Picking + 1,
	replace(agentes(_), agentes(NewA)),
	insert_agent(Name, Attack, NewPick, Slow).

% Si el predicado member falla, es decir, nunca vimos a este agente:
remember_agent(Name, [previous_turn_action, pickup(_)]):-
	agentes(A),
	insert_agent(Name, 0, 1, false).

% Si el agente no hizo nada y ya lo conocemos
remember_agent(Name, [previous_turn_action, none]):-
	agentes(A),
	member(agente(Name, Attack, Picking, Slow), A), % Si ya vimos al agente
	subtract(A, [agente(Name, Attack, Picking, Slow)], NewA), % Lo sacamos temporalmente de la lista
	replace(agentes(_), agentes(NewA)),
	insert_agent(Name, Attack, Picking, true).

% Si el agente no hizo nada y no lo conocimos
remember_agent(Name, [previous_turn_action, none]):-
	insert_agent(Name, 0, 0, true).

% Si el agente esta inconsciente y ya lo conocemos
remember_agent(Name, [unconscious, true]):-
	agentes(A),
	member(agente(Name, Attack, Picking, Slow), A), % Si ya vimos al agente
	subtract(A, [agente(Name, Attack, Picking, Slow)], NewA), % Lo sacamos temporalmente de la lista
	replace(agentes(_), agentes(NewA)),
	insert_agent(Name, 0, 0, Slow).

% Si el agente esta inconsciente y no lo conocemos
remember_agent(Name, [unconscious, true]):-
	insert_agent(Name, 0, 0, false).

remember_agent(_Name, [Attr, Val]):-
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
insert_agent(_Name, _Attack, _Picking, _Slow).

agent_priority(agente(_Name, Attack, Pick, false), Priority):-
	Total is Pick + Attack,
	Priority is Pick * 100 / Total.

agent_priority(agente(_Name, Attack, Pick, true), Priority):-
	Total is Pick + Attack,
	Temp is Pick * 100 / Total,
	Priority is Temp * 2.

% Guardo el numero de turno actual
save_turn(Turn):-
	retract(turn(_)),
	assert(turn(Turn)).
