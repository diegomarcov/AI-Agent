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
	map(NewF, C, plain).

get_n(node([F, C], Cost, Path), NN, [node([NewF, C], NewCost, [node([F, C], Cost, Path)|Path])|NN]):-
	NewF is F - 1,
	not(direction(n)),
	NewCost is Cost + 2, % un turn(dondesea) + move_fwd
	map(NewF, C, plain).

get_n(node([_F, _C], _Path, _Cost), NN, NN).

get_s(node([F, C], Cost, Path), NN, [node([NewF, C], NewCost, [node([F, C], Cost, Path)|Path])|NN]):-
	NewF is F + 1,
	direction(s),
	NewCost is Cost + 1, % un move_fwd
	map(NewF, C, plain).

get_s(node([F, C], Cost, Path), NN, [node([NewF, C], NewCost, [node([F, C], Cost, Path)|Path])|NN]):-
	NewF is F + 1,
	NewCost is Cost + 2,
	map(NewF, C, plain).

get_s(node([_F, _C], _Path, _Cost), NN, NN).

get_w(node([F, C], Cost, Path), NN, [node([F, NewC], NewCost, [node([F, C], Cost, Path)|Path])|NN]):-
	NewC is C - 1,
	direction(w),
	NewCost is Cost + 1, % un move_fwd
	map(F, NewC, plain).

get_w(node([F, C], Cost, Path), NN, [node([F, NewC], NewCost, [node([F, C], Cost, Path)|Path])|NN]):-
	NewC is C - 1,
	not(direction(w)),
	NewCost is Cost + 2,
	map(F, NewC, plain).

get_w(node([_F, _C], _Path, _Cost), NN, NN).

get_e(node([F, C], Cost, Path), NN, [node([F, NewC], NewCost, [node([F, C], Cost, Path)|Path])|NN]):-
	NewC is C + 1,
	direction(e),
	NewCost is Cost + 1, % un move_fwd
	map(F, NewC, plain).

get_e(node([F, C], Cost, Path), NN, [node([F, NewC], NewCost, [node([F, C], Cost, Path)|Path])|NN]):-
	NewC is C + 1,
	NewCost is Cost + 2,
	map(F, NewC, plain).

get_e(node([_F, _C], _Path, _Cost), NN, NN).

select(Node, [Node|Frontier], Frontier).

add_to_frontier(Neighbors, Frontier1, Frontier3):-
	append(Frontier1, Neighbors, Frontier2),
	debug_term(error, 'Neight ', Neighbors),
	debug_term(error, 'Frontier1 ', Frontier1),
	debug_term(error, 'Frontier2 ', Frontier2),
	quicksort(Frontier2, Frontier3),
	debug_term(error, 'Frontier3 ', Frontier3).

neighb0rs(Node, Neighbors):-
	get_n(Node, [], N1),
	get_s(Node, N1, N2),
	get_w(Node, N2, N3),
	get_e(Node, N3, Neighbors).

search(F0):-
	select(Node, F0, _F1),
	Node = node(Pos, Cost, Path),
	meta(Pos),
	write('CAMINOOOOOOO'),nl,
	write(Pos), nl,
	write(Cost), nl,
	write(Path), nl.

search(F0):-
	select(Node, F0, F1),
	debug_term(warning, 'Selecting node ', Node),
	read(_),
	debug(warning, '************************* '),
	neighb0rs(Node, NN),
	debug_term(warning, 'Neighbors ', NN),
	read(_),
	debug(warning, '////////////////// '),
	add_to_frontier(NN, F1, F2).
%     debug(warning, '(((((((((((((((((((( '),
%     debug_term(warning, 'New frontier ', F2),
%     read(_),
%     debug(warning, '########################## '),
%     search(F2),
%     debug(warning, 'UUUUUUUUUUUUUUUUUUUUUUUUU').
