% Se declara dinamico el predicado estadoInicial para poder realizar pruebas de
% forma mas comoda
:- dynamic estadoInicial/1.

% Estado inicial definido en el enunciado
estadoInicial([libre(a), libre(b), libre(c), enMesa(a), enMesa(b), enMesa(c)]).

% Accion: apilar
preconditions(apilar(A, B), [libre(A), libre(B), enMesa(A)]).
add_list(apilar(A, B), [sobre(A, B)]).
del_list(apilar(A, B), [libre(B), enMesa(A)]).

% Accion: desapilar
preconditions(desapilar(A, B), [sobre(A, B), libre(A)]).
add_list(desapilar(A, B), [enMesa(A), libre(B)]).
del_list(desapilar(A, B), [sobre(A, B)]).

% plan(+Metas, -Plan)
% Dadas las Metas devuelve una planificacion segun el estadoInicial establecido
plan(Metas, Plan):-
  estadoInicial(L),
  achieve_all(Metas, [], L, DoPlan),
  translate(DoPlan, Plan).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%PLANNER%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% undone(+Done, +W, -Undone)
% Dadas las metas que se cree que ya estan hechas (Done) en el mundo W, se
% devuelven en Undone las metas de Done que no se mantienen en W.
undone([], _, []).
undone([Done|Dones], W, Undone):-
  holds(Done, W),
  undone(Dones, W, Undone), !.
undone([Done|Dones], W, [Done|Undone]):-
  undone(Dones, W, Undone).

% achieve_all(+Goals, +DoneGoals, +W0, -W2)
% W2 es el mundo que resulta despues de cumplir cada meta en Goals en el mundo
% W1.
% DoneGoals es utilizado para saber que metas ya se cumplieron, y saber cuales
% rehacer en caso que ya no se cumplan en mundos futuros.
%
% Si no hay metas a cumplir, el mundo se mantiene igual
achieve_all([], _, W0, W0).
% Si hay metas a cumplir, seleccionar una del conjunto y cumplirla.
% Si cumplir la meta actual resulta en que metas cumplidas con anterioridad se
% deshagan, sacar las metas deshechas de DoneGoals, y agregarlas al final del 
% resto de las metas a realizar.
achieve_all(Goals, DoneGoals, W0, W2):-
  remove(G, Goals, Rem_Gs),
  achieve(G, W0, W1),
  undone(DoneGoals, W1, Undone),
  append(Rem_Gs, Undone, Total_Gs),
  subtract(DoneGoals, Undone, ReallyDone),
  achieve_all(Total_Gs, [G|ReallyDone], W1, W2).

% achieve(+Goal, +World1, -World2)
% World2 es el mundo resultante luego de cumplir la meta Goal en el mundo
% World1.
%
% Si la meta ya se cumple en el mundo actual, no se hace nada y el mundo se
% mantiene.
achieve(G, W, W):-
  holds(G, W).

% Si la meta es una es de la forma G:-B. donde B es una disyuncion de clausulas,
% cumplir B, para que por consecuencia se cumpla G.
achieve(G, W0, W1):-
  clause(G, B),
  achieve_all(B, [], W0, W1).

% Si G se puede cumplir realizando una accion especifica, cumplir las
% preconficiones de esa accion, y luego realizar la accion en cuestion
achieve(G, W0, do(Action, W1)):-
  achieves(Action, G),
  preconditions(Action, Pre),
  achieve_all(Pre, [], W0, W1).

% holds(+C, +W)
% Este predicado es verdadero si C se cumple en el mundo W.
%
% Sean P las precondiciones de la accion A, si se cumplen todas las
% precondiciones en el mundo W,  y C es parte de la add_list de A, entonces C se
% cumple.
holds(C, do(A, W)):-
  preconditions(A, P),
  holdsall(P, W),
  add_list(A, AL),
  member(C, AL).

% Sean P las precondiciones de la accion A, si se cumplen las precondiciones en
% el mundo W, y C no esta en la del_list de la accion A, es verdadero si C se
% cumple en W
holds(C, do(A, W)):-
  preconditions(A, P),
  holdsall(P, W),
  del_list(A, DL),
  notin(C, DL),
  holds(C, W).

% C se cumple si es parte del mundo actual W
holds(C, W):-
  member(C, W).

% holdsall(+Metas, +W)
% Verdadero si cada una de las metas en Metas se cumple en el mundo W.
holdsall([C|L], W):-
  holds(C, W),
  holdsall(L, W).

holdsall([], _).

% notin(+C, +DL)
% Verdadero si C no es miembro de la lista DL
notin(C, DL):-
  not(member(C, DL)).

% remove(-G, +Goals, -Rem_Gs)
% Selecciona la primer meta de Goals en G, y el resto de las metas en Rem_Gs.
remove(G, [G|Rem_Gs], Rem_Gs).

% achieves(+Action, +Goal)
% Verdadero si Goal es parte de la add_list de Action
achieves(Action, G):-
  add_list(Action, AL),
  in(G, AL).

% in(+Goal, +AL).
% Verdadero si G es parte de AL.
in(G, [G|_AL]).
in(G, [_|AL]):-
  in(G, AL).

% translate(+World, -Plan)
% Dado un mundo World, traduce el mismo a una lista de acciones en Plan.
translate([_|_], []).
translate(do(Action, W), NPlan):-
  translate(W, Plan),
  append(Plan, [Action], NPlan).
