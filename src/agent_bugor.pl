%% Player-Agent joystick

:- consult(ag_primitives), consult(extras_for_agents).

:- dynamic map/3.
:- dynamic turn/1.
:- dynamic posada/1.
:- dynamic oro/2.

turn(0).

run:-
      get_percept(Perc),
      
      update_state(Perc),

      %decide_action(Action),
	  ag_name(AgName),
      
      display_ag(AgName, Perc), nl,
      
      write('ACCION?: '), read(Action),
      
	  do_action(Action),
      
      run.
      
% Auxiliares %%%%%%%%%%%%%%%%%%%%%
replace(X, Y):- retractall(X), !,
                   assert(Y).

replace(X, Y):- assert(Y).

assert_once(X):- replace(X, X).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Percept %%%%%%%%%%%%%%%%%%%%%%%%
update_state([Turn, Vision, Attr, Inventory]):- save_map(Vision),
                                                save_turn(Turn).

% TODO: TRACEARRRRRRRRRRRRRRRRRRRRRRRRR
save_map([Pos, Land, []]):- Pos = [F, C],
                            assert_once(map(F, C, Land)),
			    (retractall(oro(F, C)); true).

%save_map([Pos, Land, Things]):- Pos = [F, C],
                                % assert_once(map(F, C, Land)),
				% Things = [ThingType, ThingName, Desc],
				% (
					% ThingType = building,
					% posada(P),
					% replace(posada(_), posada([[F,C] | P]))
				% );(
					% ThingType = treasure,
					% assert_once(oro(F,C))
					
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save_turn(Turn):- retract(turn(_)), assert(turn(Turn)). % guardo el numero de turno actual

decide_action(attack(Victim)).
      
:- dynamic ag_name/1.


start_ag:- AgName = jk,
           register_me(AgName, Status),
           !,
           write('REGISTRATION STATUS: '),
           write(Status), nl, nl,
           Status = connected,
           assert(ag_name(AgName)),
           run.
   
s:- start_ag.


start_ag_instance(InstanceID):-
                    AgClassName = jk,
                    AgInstanceName =.. [AgClassName, InstanceID],
                    register_me(AgInstanceName, Status),
                    !,
                    write('REGISTRATION STATUS: '),
                    write(Status), nl, nl,
                    Status = connected,
                    assert(ag_name(AgInstanceName)),
                    run.

si(InstanceID):- start_ag_instance(InstanceID).
