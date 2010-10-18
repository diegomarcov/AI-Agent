:- dynamic meta/1.

concat2(X,[],X).
concat2([],Y,Y).
concat2([X|Xs],Y,[X|L]):- concat2(Xs,Y,L).

% QuickSort

h([X1, Y1], [X2, Y2], H):-
	X is X1 - X2,
	abs(X, NX),
	Y is Y1 - Y2,
	abs(Y, NY),
	H is X + Y.

f(node(Pos, Cost, _), F):-
	meta(Meta),
	h(Pos, Meta, H),
	F is Cost + H.

pivotear(P,[],[],[]).
pivotear(P,[X|Xs],[X|M],N):- f(X, FX), f(P, FP), FX=<FP, pivotear(P,Xs,M,N).
pivotear(P,[X|Xs],M,[X|N]):- f(X, FX), f(P, FP), FX>FP, pivotear(P,Xs,M,N).

quicksort([],[]).
quicksort([X|[]],[X]).
quicksort([X|Xs],L):-pivotear(X,Xs,M,N),quicksort(M,Ms),quicksort(N,Ns),concat2(Ms,[X],Ls),concat2(Ls,Ns,L).

% Si existe vecino conocido al norte
get_n(node([F, C], Path, Cost), NN, [node([NewF, C], NewCost, [node([F, C], Path, Cost)|Path])|NN]):-
	NewF is F - 1,
	direction(n),
	NewCost is Cost + 1, % un move_fwd
	map(NewF, C, plain).

get_n(node([F, C], Path, Cost), NN, [node([NewF, C], NewCost, [node([F, C], Path, Cost)|Path])|NN]):-
	NewF is F - 1,
	NewCost is Cost + 2, % un turn(dondesea) + move_fwd
	map(NewF, C, plain).

get_n(node([F, C], Path, Cost), NN, NN).

get_s(node([F, C], Path, Cost), NN, [node([NewF, C], NewCost, [node([F, C], Path, Cost)|Path])|NN]):-
	NewF is F + 1,
	direction(s),
	NewCost is Cost + 1, % un move_fwd
	map(NewF, C, plain).

get_s(node([F, C], Path, Cost), NN, [node([NewF, C], NewCost, [node([F, C], Path, Cost)|Path])|NN]):-
	NewF is F + 1,
	NewCost is Cost + 2,
	map(NewF, C, plain).

get_s(node([F, C], Path, Cost), NN, NN).

get_w(node([F, C], Path, Cost), NN, [node([F, NewC], NewCost, [node([F, C], Path, Cost)|Path])|NN]):-
	NewC is C - 1,
	direction(w),
	NewCost is Cost + 1, % un move_fwd
	map(F, NewC, plain).

get_w(node([F, C], Path, Cost), NN, [node([F, NewC], NewCost, [node([F, C], Path, Cost)|Path])|NN]):-
	NewC is C - 1,
	NewCost is Cost + 2,
	map(F, NewC, plain).

get_w(node([F, C], Path, Cost), NN, NN).

get_e(node([F, C], Path, Cost), NN, [node([F, NewC], NewCost, [node([F, C], Path, Cost)|Path])|NN]):-
	NewC is C + 1,
	direction(e),
	NewCost is Cost + 1, % un move_fwd
	map(F, NewC, plain).

get_e(node([F, C], Path, Cost), NN, [node([F, NewC], NewCost, [node([F, C], Path, Cost)|Path])|NN]):-
	NewC is C + 1,
	NewCost is Cost + 2,
	map(F, NewC, plain).

get_e(node([F, C], Path, Cost), NN, NN).

select(Node, [Node|Frontier], Frontier).

add_to_frontier(Neighbors, Frontier1, Frontier3):-
	append(Frontier1, Neighbors, Frontier2),
	quicksort(Frontier2, Frontier3).

neighbors(Node, Neighbors):-
	get_n(Node, [], NN),
	get_s(Node, NN, NN),
	get_w(Node, NN, NN),
	get_e(Node, NN, Neighbors).

search(F0):-
	select(Node, F0, F1),
	Node = node(Pos, Cost, Path),
	meta(Pos),
	write('CAMINOOOOOOO'),nl,
	write(Pos), nl,
	write(Cost), nl,
	write(Path), nl.

search(F0):-
	select(Node, F0, F1),
	neighbors(Node, NN),
	add_to_frontier(NN, F1, F2),
	search(F2).
