concat2(X,[],X).
concat2([],Y,Y).
concat2([X|Xs],Y,[X|L]):- concat2(Xs,Y,L).

% QuickSort

h([X1, Y1], [X2, Y2], H):-
	X is X1 - X2,
	abs(X, NX),
	Y is Y1 - Y2,
	abs(Y, NY),
	H is NX + NY.

f(node(Pos, Cost, _), F):-
	meta(Meta),
	h(Pos, Meta, H),
	F is Cost + H.

pivotear(_,[],[],[]).
pivotear(P,[X|Xs],[X|M],N):- f(X, FX), f(P, FP), FX=<FP, pivotear(P,Xs,M,N).
pivotear(P,[X|Xs],M,[X|N]):- f(X, FX), f(P, FP), FX>FP, pivotear(P,Xs,M,N).

quicksort([],[]).
quicksort([X|[]],[X]).
quicksort([X|Xs],L):-pivotear(X,Xs,M,N),quicksort(M,Ms),quicksort(N,Ns),concat2(Ms,[X],Ls),concat2(Ls,Ns,L).

% Si existe vecino conocido al norte
get_n(node([F, C], Cost, Path), NN, [node([NewF, C], NewCost, [node([F, C], Cost, Path)|Path])|NN]):-
	NewF is F - 1,
	direction(n),
	NewCost is Cost + 1, % un move_fwd
	(map(NewF, C, mountain); map(NewF, C, plain)).

get_n(node([F, C], Cost, Path), NN, [node([NewF, C], NewCost, [node([F, C], Cost, Path)|Path])|NN]):-
	NewF is F - 1,
	not(direction(n)),
	NewCost is Cost + 2, % un turn(dondesea) + move_fwd
	(map(NewF, C, mountain); map(NewF, C, plain)).

get_n(node([_F, _C], _Path, _Cost), NN, NN).

get_s(node([F, C], Cost, Path), NN, [node([NewF, C], NewCost, [node([F, C], Cost, Path)|Path])|NN]):-
	NewF is F + 1,
	direction(s),
	NewCost is Cost + 1, % un move_fwd
	(map(NewF, C, mountain); map(NewF, C, plain)).

get_s(node([F, C], Cost, Path), NN, [node([NewF, C], NewCost, [node([F, C], Cost, Path)|Path])|NN]):-
	NewF is F + 1,
	NewCost is Cost + 2,
	(map(NewF, C, mountain); map(NewF, C, plain)).

get_s(node([_F, _C], _Path, _Cost), NN, NN).

get_w(node([F, C], Cost, Path), NN, [node([F, NewC], NewCost, [node([F, C], Cost, Path)|Path])|NN]):-
	NewC is C - 1,
	direction(w),
	NewCost is Cost + 1, % un move_fwd
	(map(F, NewC, mountain); map(F, NewC, plain)).

get_w(node([F, C], Cost, Path), NN, [node([F, NewC], NewCost, [node([F, C], Cost, Path)|Path])|NN]):-
	NewC is C - 1,
	not(direction(w)),
	NewCost is Cost + 2,
	(map(F, NewC, mountain); map(F, NewC, plain)).

get_w(node([_F, _C], _Path, _Cost), NN, NN).

get_e(node([F, C], Cost, Path), NN, [node([F, NewC], NewCost, [node([F, C], Cost, Path)|Path])|NN]):-
	NewC is C + 1,
	direction(e),
	NewCost is Cost + 1, % un move_fwd
	(map(F, NewC, mountain); map(F, NewC, plain)).

get_e(node([F, C], Cost, Path), NN, [node([F, NewC], NewCost, [node([F, C], Cost, Path)|Path])|NN]):-
	NewC is C + 1,
	NewCost is Cost + 2,
	(map(F, NewC, mountain); map(F, NewC, plain)).

get_e(node([_F, _C], _Path, _Cost), NN, NN).

select(Node, [Node|Frontier], Frontier).

add_to_frontier(Neighbors, Frontier1, Frontier3):-
	append(Frontier1, Neighbors, Frontier2),
	quicksort(Frontier2, Frontier3).

neighbors(Node, Neighbors):-
	get_n(Node, [], N1),
	get_s(Node, N1, N2),
	get_w(Node, N2, N3),
	get_e(Node, N3, Neighbors).

search(F0, [Node|Path], Cost):-
	select(Node, F0, _F1),
	Node = node(Pos, Cost, Path),
	meta(Pos).

search(F0, Path, Cost):-
	select(Node, F0, F1),
	neighbors(Node, NN),
	add_to_frontier(NN, F1, F2),
	search(F2, Path, Cost).

%translate(From, To, Action):-
translate(node([X1, Y1], _, _), node([X1, Y1], _, _), none, _).

translate(node([X1, Y1], _, _), node([X2, Y2], _, _), move_fwd, Dir):-
	(
		X2 is X1 - 1,
		Dir = n
	) ; (
		X2 is X1 + 1,
		Dir = s
	) ; (
		Y2 is Y1 + 1,
		Dir = e
	) ; (
		Y2 is Y1 - 1,
		Dir = w
	).

translate(node([X1, Y1], _, _), node([X2, Y2], _, _), turn(D), Dir):-
	X2 is X1 - 1,
	Dir \= n,
	D = n.

translate(node([X1, Y1], _, _), node([X2, Y2], _, _), turn(D), Dir):-
	X2 is X1 + 1,
	Dir \= s,
	D = s.

translate(node([X1, Y1], _, _), node([X2, Y2], _, _), turn(D), Dir):-
	Y2 is Y1 + 1,
	Dir \= e,
	D = e.

translate(node([X1, Y1], _, _), node([X2, Y2], _, _), turn(D), Dir):-
	Y2 is Y1 - 1,
	Dir \= w,
	D = w.

translateAll([X|Xs], D):-
	Xs = [X2|Xs2],
	translate(X, X2, move_fwd, D),
	push_action(move_fwd),
	translateAll(Xs, D).

translateAll([X|Xs], D):-
	Xs = [X2|Xs2],
	translate(X, X2, turn(ND), D),
	push_action(turn(ND)),
	translateAll([X|Xs], ND).

translateAll([_], _).
translateAll([], _).

%node([5,9],7,),
%node([5,8],5,),
%node([6,8],4,),
%node([7,8],3,),
%node([7,7],1,),
%node([8,7],0,[])]

%move_fwd, turn(e), move_fwd, turn(n), move_fwd, move_fwd, turn(e), move_fwd

