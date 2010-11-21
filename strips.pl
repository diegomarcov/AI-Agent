:- dynamic estadoInicial/1.

%estadoInicial([sobre(a, c), libre(a), enMesa(c), enMesa(b), libre(b)]).
estadoInicial([libre(a), libre(b), libre(c), enMesa(a), enMesa(b), enMesa(c)]).

preconditions(apilar(A, B), [libre(A), libre(B), enMesa(A)]).
add_list(apilar(A, B), [sobre(A, B)]).
del_list(apilar(A, B), [libre(B), enMesa(A)]).

preconditions(desapilar(A, B), [sobre(A, B), libre(A)]).
add_list(desapilar(A, B), [enMesa(A), libre(B)]).
del_list(desapilar(A, B), [sobre(A, B)]).

plan(Metas, Plan):-
  estadoInicial(L),
  achieve_all(Metas, [], L, DoPlan),
  translate(DoPlan, Plan).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%PLANNER%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

undone([], _, []).
undone([Done|Dones], W, Undone):-
  holds(Done, W),
  undone(Dones, W, Undone), !.
undone([Done|Dones], W, [Done|Undone]):-
  undone(Dones, W, Undone).

achieve_all([], _, W0, W0).
achieve_all(Goals, DoneGoals, W0, W2):-
  remove(G, Goals, Rem_Gs),
  achieve(G, W0, W1),
  undone(DoneGoals, W1, Undone),
  append(Rem_Gs, Undone, Total_Gs),
  subtract(DoneGoals, Undone, ReallyDone),
  achieve_all(Total_Gs, [G|ReallyDone], W1, W2).

achieve(G, W, W):-
  holds(G, W).

achieve(G, W0, W1):-
  clause(G, B),
  achieve_all(B, [], W0, W1).

achieve(G, W0, do(Action, W1)):-
  achieves(Action, G),
  preconditions(Action, Pre),
  achieve_all(Pre, [], W0, W1).

holds(C, do(A, W)):-
  preconditions(A, P),
  holdsall(P, W),
  add_list(A, AL),
  member(C, AL).

holds(C, do(A, W)):-
  preconditions(A, P),
  holdsall(P, W),
  del_list(A, DL),
  notin(C, DL),
  holds(C, W).

holds(C, W):-
  member(C, W).

holdsall([C|L], W):-
  holds(C, W),
  holdsall(L, W).

holdsall([], _).

notin(C, DL):-
  not(member(C, DL)).

remove(G, [G|Rem_Gs], Rem_Gs).

achieves(Action, G):-
  add_list(Action, AL),
  in(G, AL).

in(G, [G|_AL]).
in(G, [_|AL]):-
  in(G, AL).

translate([_|_], []).
translate(do(Action, W), NPlan):-
  translate(W, Plan),
  append(Plan, [Action], NPlan).
