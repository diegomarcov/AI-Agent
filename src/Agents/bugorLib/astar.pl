:- dynamic visitado/1.

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

f(node(Pos, Cost, _, _), F):-
	meta(Meta),
	h(Pos, Meta, H),
	F is Cost + H.

pivotear(_,[],[],[]).
pivotear(P,[X|Xs],[X|M],N):- f(X, FX), f(P, FP), FX=<FP, pivotear(P,Xs,M,N).
pivotear(P,[X|Xs],M,[X|N]):- f(X, FX), f(P, FP), FX>FP, pivotear(P,Xs,M,N).

quicksort([],[]).
quicksort([X|[]],[X]).
quicksort([X|Xs],L):-pivotear(X,Xs,M,N),quicksort(M,Ms),quicksort(N,Ns),concat2(Ms,[X],Ls),concat2(Ls,Ns,L).

handle_node(node([F, C], Cost1, _P, _D), Front, Front):-
	not(member(node([F, C], _, _, _), Front)),
	visitado(node([F, C], Cost2, _, _)),
	Cost1 < Cost2,
	retractall(visitado(node([F, C], _, _, _))).

handle_node(node([F, C], Cost1, _P, _D), Front, NFront):-
	member(node([F, C], _, _, _), Front),
	visitado(node([F, C], Cost2, _, _)),
	Cost1 < Cost2,
	retractall(visitado(node([F, C], _, _, _))),
	delete(Front, node([F, C], _, _, _), NFront).

handle_node(node([F, C], Cost1, _P, _D), Front, NFront):-
	member(node([F, C], Cost2, _, _), Front),
	not(visitado(node([F, C], _, _, _))),
	Cost1 < Cost2,
	delete(Front, node([F, C], _, _, _), NFront).

handle_node(node([F, C], _, _, _), Front, Front):-
	not(member(node([F, C], _, _, _), Front)),
	not(visitado(node([F, C], _, _, _))).

% Si existe vecino conocido al norte
get_n(node([F, C], Cost, Path, Dir), NN, [node([NewF, C], NewCost, [node([F, C], Cost, Path, Dir)], Dir)|NN], Front, NFront):-
	NewF is F - 1,
	Dir = n,
	(
		(
			NewCost is Cost + 2,
			map(NewF, C, mountain)
		) ; (
			NewCost is Cost + 1,
			map(NewF, C, plain)
		)
	),
	handle_node(node([NewF, C], NewCost, [node([F, C], Cost, Path, Dir)], Dir), Front, NFront).

get_n(node([F, C], Cost, Path, Dir), NN, [node([NewF, C], NewCost, [node([F, C], Cost, Path, Dir)], n)|NN], Front, NFront):-
	NewF is F - 1,
	Dir \= n,
	(
		(
			NewCost is Cost + 3, % un turn(dondesea) + move_fwd
			map(NewF, C, mountain)
		) ; (
			NewCost is Cost + 2, % un turn(dondesea) + move_fwd
			map(NewF, C, plain)
		)
	),
	handle_node(node([NewF, C], NewCost, [node([F, C], Cost, Path, Dir)], Dir), Front, NFront).

get_n(node([_F, _C], _Path, _Cost, _Dir), NN, NN, Front, Front).

get_s(node([F, C], Cost, Path, Dir), NN, [node([NewF, C], NewCost, [node([F, C], Cost, Path, Dir)], Dir)|NN], Front, NFront):-
	NewF is F + 1,
	Dir = s,
	(
		(
			NewCost is Cost + 2, % un move_fwd
			map(NewF, C, mountain)
		) ; (
			NewCost is Cost + 1, % un move_fwd
			map(NewF, C, plain)
		)
	),
	handle_node(node([NewF, C], NewCost, [node([F, C], Cost, Path, Dir)], Dir), Front, NFront).

get_s(node([F, C], Cost, Path, Dir), NN, [node([NewF, C], NewCost, [node([F, C], Cost, Path, Dir)], s)|NN], Front, NFront):-
	NewF is F + 1,
	Dir \= s,
	(
		(
			NewCost is Cost + 3,
			map(NewF, C, mountain)
		) ; (
			NewCost is Cost + 2,
			map(NewF, C, plain)
		)
	),
	handle_node(node([NewF, C], NewCost, [node([F, C], Cost, Path, Dir)], Dir), Front, NFront).

get_s(node([_F, _C], _Path, _Cost, _Dir), NN, NN, Front, Front).

get_w(node([F, C], Cost, Path, Dir), NN, [node([F, NewC], NewCost, [node([F, C], Cost, Path, Dir)], Dir)|NN], Front, NFront):-
	NewC is C - 1,
	Dir = w,
	(
		(
			NewCost is Cost + 2, % un move_fwd
			map(F, NewC, mountain)
		) ; (
			NewCost is Cost + 1, % un move_fwd
			map(F, NewC, plain)
		)
	),
	handle_node(node([F, NewC], NewCost, [node([F, C], Cost, Path, Dir)], Dir), Front, NFront).

get_w(node([F, C], Cost, Path, Dir), NN, [node([F, NewC], NewCost, [node([F, C], Cost, Path, Dir)], w)|NN], Front, NFront):-
	NewC is C - 1,
	Dir \= w,
	(
		(
			NewCost is Cost + 3,
			map(F, NewC, mountain)
		) ; (
			NewCost is Cost + 2,
			map(F, NewC, plain)
		)
	),
	handle_node(node([F, NewC], NewCost, [node([F, C], Cost, Path, Dir)], Dir), Front, NFront).

get_w(node([_F, _C], _Path, _Cost, _Dir), NN, NN, Front, Front).

get_e(node([F, C], Cost, Path, Dir), NN, [node([F, NewC], NewCost, [node([F, C], Cost, Path, Dir)], Dir)|NN], Front, NFront):-
	NewC is C + 1,
	Dir = e,
	(
		(
			NewCost is Cost + 2, % un move_fwd
			map(F, NewC, mountain)
		) ; (
			NewCost is Cost + 1, % un move_fwd
			map(F, NewC, plain)
		)
	),
	handle_node(node([F, NewC], NewCost, [node([F, C], Cost, Path, Dir)], Dir), Front, NFront).

get_e(node([F, C], Cost, Path, Dir), NN, [node([F, NewC], NewCost, [node([F, C], Cost, Path, Dir)], e)|NN], Front, NFront):-
	NewC is C + 1,
	Dir \= e,
	(
		(
			NewCost is Cost + 3,
			map(F, NewC, mountain)
		) ; (
			NewCost is Cost + 2,
			map(F, NewC, plain)
		)
	),
	handle_node(node([F, NewC], NewCost, [node([F, C], Cost, Path, Dir)], Dir), Front, NFront).

get_e(node([_F, _C], _Path, _Cost, _Dir), NN, NN, Front, Front).

select(Node, [Node|Frontier], Frontier).

add_to_frontier(Neighbors, Frontier1, Frontier3):-
	append(Frontier1, Neighbors, Frontier2),
	quicksort(Frontier2, Frontier3).

neighbors(Node, Neighbors, Frontier, NFrontier):-
	get_n(Node, [], N1, Frontier, NF1),
	get_s(Node, N1, N2, NF1, NF2),
	get_w(Node, N2, N3, NF2, NF3),
	get_e(Node, N3, Neighbors, NF3, NFrontier).

search(F0, Path, Cost):-
	select(Node, F0, _F1),
	Node = node(Pos, Cost, _Parent, _),
	meta(Pos),
	build_path(Node, Path),
	retractall(visitado(_)).

search(F0, Path, Cost):-
	select(Node, F0, F1),
	Node = node([F, C], _, _, _),
	not(visitado(node([F, C], _, _, _))),
	assert_once(visitado(Node)),
	neighbors(Node, NN, F1, F2),
	add_to_frontier(NN, F2, F3),
	search(F3, Path, Cost).

search(_, [], inf):- retractall(visitado(_)).

build_path(node(Pos, Cost, [], D), [node(Pos, Cost, [], D)]).
build_path(node(Pos, Cost, [Parent], D), Path):-
	build_path(Parent, RestPath),
	Path = [node(Pos, Cost, [], D) | RestPath].

%translate(From, To, Action):-
translate(node([X1, Y1], _, _, _), node([X1, Y1], _, _, _), none).

translate(node([_, _], _, _, Dir), node([_, _], _, _, Dir), move_fwd).

translate(node([_, _], _, _, D1), node([_, _], _, _, D2), turn(D2)):-
	D1 \= D2.

translateAll([X|Xs]):-
	Xs = [X2|_],
	translate(X, X2, move_fwd),
	push_action(move_fwd),
	translateAll(Xs).

translateAll([X|Xs]):-
	Xs = [X2|_],
	translate(X, X2, turn(D)),
	push_action(turn(D)),
	X = node([X1, Y1], P, C, _),
	translateAll([node([X1, Y1], P, C, D)|Xs]).

translateAll([_|[]]).
translateAll([]).

% map(X, Y, L):-
%   cell_land([X, Y], L).
