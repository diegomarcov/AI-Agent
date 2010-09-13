% Auxiliares %%%%%%%%%%%%%%%%%%%%%

% Reemplaza conocimiento guardado con asserts
replace(X, Y):- 
	debug(info, 'Trying to retract'),
	retractall(X), !,
	assert(Y).

% Caso especial en que el retractall falla 
% porque no existe el conocimiento X
replace(X, Y):- 
	debug(warning, 'Retract failed! Asserting only'),
	assert(Y).

% Utilizado para "recordar" cosas solo una
% vez
assert_once(X):- 
	concat('Asserting ', X, Str),
	debug(info, Str),
	replace(X, X).

% Utilizado para "recordar" tesoros solo una
% vez. Se trata aparte porque al almacenar el 
% turno tambien, el assert_once no funciona
assert_once_oro(Pos, Turno):- 
	debug(info, 'Asserting treasure'), 
	replace(oro(Pos, _), oro(Pos, Turno)).

% Debug a archivo
write_file(T):- 
	open('debug.txt', append, Stream),
	write(Stream, T),
	nl(Stream),
	close(Stream).

debug(title, Text):-
	open('debug.txt', append, Stream),
	write(Stream, '########'),
	write(Stream, Text),
	write(Stream, '########'),
	nl(Stream),
	close(Stream).

debug(Header, Text):-
	open('debug.txt', append, Stream),
	write(Stream, Header),
	write(Stream, ': '),
	write(Stream, Text),
	nl(Stream),
	close(Stream).

debug(info, Text):-
	debug('*INFO*', Text).

debug(error, Text):-
	debug('!!ERROR!!', Text).

debug(warning, Text):-
	debug('$WARNING$', Text).

init_debug:- write_file('************************************************************').
