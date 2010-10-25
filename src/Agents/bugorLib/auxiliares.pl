% Auxiliares %%%%%%%%%%%%%%%%%%%%%
% Reemplaza conocimiento guardado con asserts
replace(X, Y):- 
	retractall(X), !,
	assert(Y).

% Caso especial en que el retractall falla 
% porque no existe el conocimiento X
replace(_X, Y):- 
	assert(Y).

% Utilizado para "recordar" cosas solo una
% vez
assert_once(X):- 
	replace(X, X).

% Utilizado para "recordar" tesoros solo una
% vez. Se trata aparte porque al almacenar el 
% turno tambien, el assert_once no funciona
assert_once_oro(Name, Pos, Turno):- 
	replace(oro(Name, _, _), oro(Name, Pos, Turno)).

% Debug a archivo
write_file(T):- 
	open('debug.txt', append, Stream),
	write(Stream, T),
	nl(Stream),
	close(Stream).

debug_lowlevel(Header, Text):-
	write(Header), write(' '),
	write(Text), nl.

debug(title, Text):-
	concat(Text, '########', C),
	debug_lowlevel('########', C).

debug(info, Text):-
	debug_lowlevel('*INFO*', Text).

debug(error, Text):-
	debug_lowlevel('!!ERROR!!', Text).

debug(warning, Text):-
	debug_lowlevel('$WARNING$', Text).

debug_term(Header, Text, Term):-
	term_to_atom(Term, X),
	concat(Text, X, Str),
	debug(Header, Str).

time_stamp(Today):- get_time(X), format_time(atom(Today), '%H:%M - %d/%m/%Y', X).

init_debug:- 
	time_stamp(T),
	concat('*** Starting debug @ ', T, Str),
	write_file(Str).
