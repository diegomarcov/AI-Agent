% Auxiliares %%%%%%%%%%%%%%%%%%%%%

% Reemplaza conocimiento guardado con asserts
replace(X, Y):- 
	write_file('Trying to retract....'), retractall(X), !,
	assert(Y).

% Caso especial en que el retractall falla 
% porque no existe el conocimiento X
replace(X, Y):- 
	write_file('Retract failed! Asserting only...'),
	assert(Y).

% Utilizado para "recordar" cosas solo una
% vez
assert_once(X):- 
	write_file('*** asserting '), 
	write_file(X), 
	write_file('***'), 
	replace(X, X).

% Utilizado para "recordar" tesoros solo una
% vez. Se trata aparte porque al almacenar el 
% turno tambien, el assert_once no funciona
assert_once_oro(Pos, Turno):- 
	write_file('*** asserting oro ***'), 
	replace(oro(Pos, _), oro(Pos, Turno)).

% Debug a archivo
write_file(T):- 
	open('debug.txt', append, Stream),
	write(Stream, T),
	nl(Stream),
	close(Stream).

init_debug:- write_file('************************************************************').
