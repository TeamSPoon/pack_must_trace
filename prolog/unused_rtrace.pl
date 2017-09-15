
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.



end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.

/* Part of LogicMOO Base Logicmoo Debug Tools
% ===================================================================
% File '$FILENAME.pl'
% Purpose: An Implementation in SWI-Prolog of certain debugging tools
% Maintainer: Douglas Miles
% Contact: $Author: dmiles $@users.sourceforge.net ;
% Version: '$FILENAME.pl' 1.0.0
% Revision: $Revision: 1.1 $
% Revised At:  $Date: 2002/07/11 21:57:28 $
% Licience: LGPL
% ===================================================================
*/
:- module(dumpst,[
          getPFA/3,getPFA1/3,getPFA2/3,get_m_opt/4,fdmsg/1,fdmsg1/1,
          neg1_numbervars/3,clauseST/2,
          dtrace/0,dbreak/0,
          dtrace/1,dtrace/2,
          dumptrace/1,dumptrace/2,dumptrace0/1,dumptrace1/1,
          dumptrace_ret/1,
          drain_framelist/1,
          drain_framelist_ele/1,
          printable_variable_name/2,
          v_name1/2,
          v_name2/2,
          dump_st/0,
          with_source_module/1,
          to_wmsg/2,
          fmsg_rout/1,
          simplify_goal_printed/2,
          dumpST/0,dumpST/1,dumpST1/0,
          dumpST0/0,dumpST0/1,dumpST0/2,
          dumpST9/0,dumpST9/1,dumpST9/2,dumpST_now/2,printFrame/3,frame_to_fmsg/4
   ]).

:-  meta_predicate dumptrace_ret(?),
  neg1_numbervars(?, ?, 0),
  with_source_module(0),
  dumptrace_ret(0),
  dumptrace0(0),
  dumptrace1(0),
  dumptrace(0),
  dtrace(*,0).


:- use_module(library(logicmoo_util_common)).
:- reexport(library(debug),[debug/3]).
:- use_module(library(xlisting)).
:- use_module(library(loop_check)).
:- set_module(class(library)).
:- user:use_module(library(memfile)).
%:- use_module(logicmoo_util_rtrace).
:- use_module(library(with_thread_local)).
%:- use_module(logicmoo_util_loop_check).
:- use_module(library(random),[random/1]).
% TODO Make a speed,safety,debug Triangle instead of these flags
:- create_prolog_flag(runtime_must,debug,[]).
:- thread_local(tlbugger:ifHideTrace/0).
:- reexport(library(listing_vars)).
:- use_module(library(lists)).


:- module_transparent
        current_frames/4,
        current_next_frames/4,
        in_pengines/0,
        find_parent_frame_attribute/5,
        parent_goal/2,
        prolog_frame_match/3,
        relative_frame/3,
        stack_check/0,
        stack_check/1,
        stack_check/2,
        stack_check_else/2,
        stack_depth/1.


:- set_prolog_flag(backtrace_depth,      200).
:- set_prolog_flag(backtrace_goal_depth, 20).
:- set_prolog_flag(backtrace_show_lines, true).

:- module_transparent
          getPFA/3,getPFA1/3,getPFA2/3,get_m_opt/4,fdmsg/1,fdmsg1/1,
          neg1_numbervars/3,clauseST/2,
          % dtrace/0,
          dtrace/1,dtrace/2,
          dumptrace/1,dumptrace/2,
          dumptrace_ret/1,
          dump_st/0,
          dumpST/0,dumpST/1,
          dumpST0/0,dumpST0/1,dumpST0/2,
          dumpST9/0,dumpST9/1,dumpST9/2.



  

/*
:- mpred_trace_nochilds(stack_depth/1).
:- mpred_trace_nochilds(stack_check/0).
:- mpred_trace_nochilds(stack_check/1).
:- mpred_trace_nochilds(stack_check/2).
*/

%= 	 	 

%% stack_depth( ?Level) is semidet.
%
% Stack Depth.
%
stack_depth(Level):-quietly((prolog_current_frame(Frame),prolog_frame_attribute(Frame,level,Level))).


:-  module_transparent stack_check/0.
:-  module_transparent stack_check/1.

%% stack_check is semidet.
%
% Stack Check.
%
stack_check:- sanity(stack_check(6606)).

%= 	 	 

%% stack_check( ?BreakIfOver) is semidet.
%
% Stack Check.
%
stack_check(BreakIfOver):- stack_check_else(BreakIfOver, trace_or_throw(stack_check(BreakIfOver))).

%= 	 	 

%% stack_check( ?BreakIfOver, ?Error) is semidet.
%
% Stack Check.
%
stack_check(BreakIfOver,Error):- stack_check_else(BreakIfOver, trace_or_throw(stack_check(BreakIfOver,Error))).

%= 	 	 

%% stack_check_else( ?BreakIfOver, ?Call) is semidet.
%
% Stack Check Else.
%
stack_check_else(BreakIfOver,Call):- stack_depth(Level) ,  ( Level < BreakIfOver -> true ; (dbgsubst(Call,stack_lvl,Level,NewCall),NewCall)).



%= 	 	 

%% in_pengines is semidet.
%
% In Pengines.
%
in_pengines:- quietly(relative_frame(context_module,pengines,_)).

% ?- relative_frame(context_module,X,Y).
:- export(relative_frame/3).

%= 	 	 

%% relative_frame( ?Attrib, ?Term, ?Nth) is semidet.
%
% Relative Frame.
%
relative_frame(Attrib,Term,Nth):- find_parent_frame_attribute(Attrib,Term,Nth,_RealNth,_FrameNum).

:- export(parent_goal/2).

%= 	 	 

%% parent_goal( ?Goal) is semidet.
%
% Parent Goal.
%
parent_goal(Goal):- nonvar(Goal), quietly((prolog_current_frame(Frame),prolog_frame_attribute(Frame,parent,PFrame),
  prolog_frame_attribute(PFrame,parent_goal,Goal))).
parent_goal(Goal):- !, quietly((prolog_current_frame(Frame),prolog_frame_attribute(Frame,parent,PFrame0),
  prolog_frame_attribute(PFrame0,parent,PFrame),
  goals_above(PFrame,Goal))).

goals_above(Frame,Goal):- prolog_frame_attribute(Frame,goal,Term),unify_goals(Goal,Term).
goals_above(Frame,Goal):- prolog_frame_attribute(Frame,parent,PFrame), goals_above(PFrame,Goal).

unify_goals(Goal,Term):- (var(Goal);var(Term)),!,Term=Goal.
unify_goals(M:Goal,N:Term):-!, unify_goals0(Goal,Term),M=N.
unify_goals(Goal,_:Term):-!, unify_goals0(Goal,Term).
unify_goals(_:Goal,Term):-!, unify_goals0(Goal,Term).

unify_goals0(X,X).

%= 	 	 

%% parent_goal( ?Goal, ?Nth) is semidet.
%
% Parent Goal.
%
parent_goal(Goal,Nth):-  number(Nth),!, prolog_current_frame(Frame),prolog_frame_attribute(Frame,parent,PFrame),nth_parent_goal(PFrame,Goal,Nth).
parent_goal(Goal,Nth):-  find_parent_frame_attribute(goal,Goal,Nth,_RealNth,_FrameNum).


%= 	 	 

%% nth_parent_goal( ?Frame, ?Goal, ?Nth) is semidet.
%
% Nth Parent Goal.
%
nth_parent_goal(Frame,Goal,Nth):- Nth>0, Nth2 is Nth-1, prolog_frame_attribute(Frame,parent,PFrame),!,quietly((nth_parent_goal(PFrame,Goal,Nth2))).
nth_parent_goal(Frame,Goal,_):- quietly((prolog_frame_attribute(Frame,goal,Goal))),!.

:- export(find_parent_frame_attribute/5).

%= 	 	 

%% find_parent_frame_attribute( ?Attrib, ?Term, ?Nth, ?RealNth, ?FrameNum) is semidet.
%
% Find Parent Frame Attribute.
%
find_parent_frame_attribute(Attrib,Term,Nth,RealNth,FrameNum):-quietly((ignore(Attrib=goal),prolog_current_frame(Frame),
                                                current_frames(Frame,Attrib,5,NextList))),!,nth1(Nth,NextList,RealNth-FrameNum-Term).



%= 	 	 

%% prolog_frame_match( ?Frame, :TermAttrib, :TermTerm) is semidet.
%
% Prolog Frame Match.
%
prolog_frame_match(Frame,goal,Term):-!,prolog_frame_attribute(Frame,goal,TermO),!,Term=TermO.
prolog_frame_match(Frame,parent_goal,Term):-nonvar(Term),!,prolog_frame_attribute(Frame,parent_goal,Term).
prolog_frame_match(Frame,not(Attrib),Term):-!,nonvar(Attrib),not(prolog_frame_attribute(Frame,Attrib,Term)).
prolog_frame_match(_,[],X):-!,X=[].
prolog_frame_match(Frame,[I|IL],[O|OL]):-!,prolog_frame_match(Frame,I,O),!,prolog_frame_match(Frame,IL,OL),!.
prolog_frame_match(Frame,Attrib,Term):-prolog_frame_attribute(Frame,Attrib,Term).


%= 	 	 

%% current_frames( ?Frame, ?Attrib, :GoalN, ?NextList) is semidet.
%
% Current Frames.
%
current_frames(Frame,Attrib,N,NextList):- N>0, N2 is N-1,prolog_frame_attribute(Frame,parent,ParentFrame),!,current_frames(ParentFrame,Attrib,N2,NextList).
current_frames(Frame,Attrib,0,NextList):- current_next_frames(Attrib,1,Frame,NextList).


%= 	 	 

%% current_next_frames( ?Attrib, ?Nth, ?Frame, ?NextList) is semidet.
%
% Current Next Frames.
%
current_next_frames(Attrib,Nth,Frame,[Nth-Frame-Term|NextList]):- quietly((prolog_frame_match(Frame,Attrib,Term))), !,
   (prolog_frame_attribute(Frame,parent,ParentFrame) -> 
    ( Nth2 is Nth+1, current_next_frames(Attrib,Nth2, ParentFrame,NextList));
         NextList=[]).
current_next_frames(Attrib,Nth,Frame,NextList):- 
   (prolog_frame_attribute(Frame,parent,ParentFrame) -> 
    ( Nth2 is Nth+1, current_next_frames(Attrib,Nth2, ParentFrame,NextList));
         NextList=[]).
current_next_frames(_,_,_,[]).



:- ignore((source_location(S,_),prolog_load_context(module,M),module_property(M,class(library)),
 forall(source_file(M:H,S),
 ignore((functor(H,F,A),
  ignore(((\+ atom_concat('$',_,F),(export(F/A) , current_predicate(system:F/A)->true; system:import(M:F/A))))),
  ignore(((\+ predicate_property(M:H,transparent), module_transparent(M:F/A), \+ atom_concat('__aux',_,F),debug(modules,'~N:- module_transparent((~q)/~q).~n',[F,A]))))))))).




% :- use_module(library(gui_tracer)).
:- use_module(library(check)).


% :- use_module('logicmoo_util_rtrace').
:- set_module(class(library)).


/*
%% all_source_file_predicates_are_transparent() is det.
%
% All Module Predicates Are Transparent.
%
:- module_transparent(all_source_file_predicates_are_transparent/0).
:- export(all_source_file_predicates_are_transparent/0).
all_source_file_predicates_are_transparent:-
  must(prolog_load_context(source,SFile)),all_source_file_predicates_are_transparent(SFile),
  must(prolog_load_context(file,File)),(SFile==File->true;all_source_file_predicates_are_transparent(File)).
*/

:- module_transparent(all_source_file_predicates_are_transparent/1).
:- export(all_source_file_predicates_are_transparent/1).
all_source_file_predicates_are_transparent(File):-
    debug(logicmoo(loader),'~N~p~n',[all_source_file_predicates_are_transparent(File)]),
    forall((source_file(ModuleName:P,File),functor(P,F,A)),
      ignore(( 
        ignore(( \+ atom_concat('$',_,F), ModuleName:export(ModuleName:F/A))),
            \+ (predicate_property(ModuleName:P,(transparent))),
                   % ( nop(dmsg(todo(module_transparent(ModuleName:F/A))))),
                   (module_transparent(ModuleName:F/A))))).



:- 
      op(1150,fx,(baseKB:kb_shared)),
      op(1150,fx,meta_predicate),
      op(1150,fx,thread_local).


:- set_prolog_flag(backtrace_show_lines,true).
% :- set_prolog_flag(access_level,system).
:- set_prolog_flag(backtrace_goal_depth,10). % default 3
:- set_prolog_flag(backtrace_depth,100). % default 20
:- set_prolog_flag(backtrace,true). % default true
:- set_prolog_flag(debug_on_error,true). % default true

swi_module(M,Preds):- forall(member(P,Preds),M:export(P)). % ,dmsg(swi_module(M)).


dont_make_cyclic(G):-skipWrapper,!,call(G).
dont_make_cyclic(G):-cyclic_break(G),!,G,cyclic_break(G).

%% bugger_flag( :TermF) is semidet.
%
% Logic Moo Debugger Flag.
%
bugger_flag(F=V):-bugger_flag(F,V).



%% bugger_flag( ?F, ?V) is semidet.
%
% Logic Moo Debugger Flag.
%
bugger_flag(F,V):-current_prolog_flag(F,V).



%% set_bugger_flag( ?F, ?V) is semidet.
%
% Set Logic Moo Debugger Flag.
%
set_bugger_flag(F,V):-current_prolog_flag(F,_Old),!,set_prolog_flag(F,V).
set_bugger_flag(F,V):-create_prolog_flag(F,V,[keep(true),tCol(ftTerm)]),!.





%% writeSTDERR0( ?A) is semidet.
%
% Write S True Structure (debug) E R R Primary Helper.
%
      writeSTDERR0(A):-dmsg(A).



%% debugFmt( ?A) is semidet.
%
% Debug Format.
%
      debugFmt(A):-dmsg(A).
/*

:- export((     on_x_debug/1, % Throws unless [Fail or Debug]
     on_x_log_throw/1, % Succeeds unless no error and failure occured

     on_x_cont/1, % same
        on_x_debug_cont/1,

        must_det/1, % must leave no coice points behind 
     on_f_throw/1, % Throws unless [Fail or Debug]

     % cant ignore - Throws but can be set to [Throw, Fail or Ignore or Debug]
     dsddf must/1, % must succeed at least once
     sanity/1, % doesnt run on release
     gmust/2, % like must/1 but arg2 must be ground at exit
    
     must_each/1,  % list block must succeed once .. it smartly only debugs to the last failures
     on_x_log_cont/1,
     on_f_debug/1, % Succeeds but can be set to [Fail or Debug]
     on_f_log_fail/1,  % Fails unless [+Ignore]
          % can ignore
     on_x_fail/1, % for wrapping code may throw to indicate failure
   must_not_repeat/1)).  % predicate must never bind the same arguments the same way twice
*/



:- meta_predicate(call_count(0,?)).
call_count(C,N):-findall(C,C,L),nth1(N,L,C).


% :- if_may_hide('$hide'(skipWrapper/0)).
% :- if_may_hide('$hide'(tracing/0)).
% :- if_may_hide('$set_predicate_attribute'(tlbugger:skipMust,hide_childs,1)).
% :- if_may_hide('$set_predicate_attribute'(tlbugger:skipWrapper,hide_childs,1)).

:- export(ignore_each/1).
% = %= :- meta_predicate (ignore_each(1)).



%% ignore_each( :PRED1A) is semidet.
%
% Ignore Each.
%
ignore_each((A,B)):-ignore_each(A),ignore_each(B),!.
ignore_each(A):-ignore(A).

:- meta_predicate 
	must_maplist(:, ?),
	must_maplist(:, ?, ?),
        must_maplist(:, ?, ?, ?).

%% 	must_maplist(:Goal, ?List)
%
%	True if Goal can successfully  be   applied  on  all elements of
%	List. Arguments are reordered to gain  performance as well as to
%	make the predicate deterministic under normal circumstances.




%% must_maplist( :PRED1Goal, ?Elem) is semidet.
%
% Must Be Successfull Maplist.
%
must_maplist(_, []).
must_maplist(Goal, [Elem|Tail]) :-
	must(call(Goal, Elem)),
	must_maplist(Goal, Tail).

%% 	must_maplist(:Goal, ?List1, ?List2)
%
%	As must_maplist/2, operating on pairs of elements from two lists.



%% must_maplist( :PRED2Goal, ?Elem1, ?Elem2) is semidet.
%
% Must Be Successfull Maplist.
%
must_maplist(_, [], []).
must_maplist( Goal, [Elem1|Tail1], [Elem2|Tail2]) :-
	must(call(Goal, Elem1, Elem2)),
	must_maplist( Goal, Tail1, Tail2).




%% must_maplist( :PRED3Goal, ?Elem1, ?Elem2, ?Elem3) is semidet.
%
% Must Be Successfull Maplist.
%
must_maplist(_, [], [],[]).
must_maplist( Goal, [Elem1|Tail1], [Elem2|Tail2], [Elem3|Tail3]) :-
	must(call(Goal, Elem1, Elem2, Elem3)),
	must_maplist( Goal, Tail1, Tail2, Tail3).




:- meta_predicate 
	must_maplist_det(:, ?),
	must_maplist_det(:, ?, ?),
        must_maplist_det(:, ?, ?, ?).

%% 	must_maplist_det(:Goal, ?List)
%
%	True if Goal can successfully  be   applied  on  all elements of
%	List. Arguments are reordered to gain  performance as well as to
%	make the predicate deterministic under normal circumstances.




%% must_maplist_det( :PRED1Goal, ?Elem) is semidet.
%
% Must Be Successfull Maplist.
%
must_maplist_det(_, []):-!.
must_maplist_det(Goal, [Elem|Tail]) :-
	must(call(Goal, Elem)),!,
	must_maplist_det(Goal, Tail).

%% 	must_maplist_det(:Goal, ?List1, ?List2)
%
%	As must_maplist_det/2, operating on pairs of elements from two lists.



%% must_maplist_det( :PRED2Goal, ?Elem1, ?Elem2) is semidet.
%
% Must Be Successfull Maplist.
%
must_maplist_det(_, [], []):-!.
must_maplist_det( Goal, [Elem1|Tail1], [Elem2|Tail2]) :-
	must(call(Goal, Elem1, Elem2)),!,
	must_maplist_det( Goal, Tail1, Tail2).




%% must_maplist_det( :PRED3Goal, ?Elem1, ?Elem2, ?Elem3) is semidet.
%
% Must Be Successfull Maplist.
%
must_maplist_det(_, [], [],[]):-!.
must_maplist_det( Goal, [Elem1|Tail1], [Elem2|Tail2], [Elem3|Tail3]) :-
	must(call(Goal, Elem1, Elem2, Elem3)),!,
	must_maplist_det( Goal, Tail1, Tail2, Tail3).



:- ensure_loaded(library(lists)).


%% throw_safe( ?Exc) is semidet.
%
% Throw Safely Paying Attention To Corner Cases.
%
throw_safe(Exc):-trace_or_throw(Exc).

:- thread_local( t_l:testing_for_release/1).




%% test_for_release( ?File) is semidet.
%
% Test For Release.
%
test_for_release(File):-  source_file(File), \+ make:modified_file(File), !.
test_for_release(File):-  
 G = test_for_release(File),
  scce_orig(dmsg("~N~nPress Ctrl-D to begin ~n~n  :- ~q. ~n~n",[G]),
  if_interactive(prolog),
   setup_call_cleanup(dmsg("~N~nStarting ~q...~n",[G]),
      locally(t_l:testing_for_release(File),ensure_loaded(File)),
      test_for_release_problems(File))).




%% test_for_release_problems( ?File) is semidet.
%
% Test For Release Problems.
%
test_for_release_problems(_):-!.
test_for_release_problems(File):-  
      dmsg("~N~nListing problems after ~q...~n",[File]),
      list_undefined,
      nop(after_boot(if_defined(gxref,true))),!.

%= :- meta_predicate  if_interactive(0).




%% if_interactive( :Goal) is semidet.
%
% If Interactive.
%
if_interactive(Goal):-ignore(if_interactive0(Goal)),!.



%% if_interactive0( :Goal) is semidet.
%
% If Interactive Primary Helper.
%
if_interactive0(Goal):- 
   thread_self(main),
   current_input(In),
   stream_property(In,input),
   stream_property(In,tty(true)),
   read_pending_input(In,_,_),!,
   dmsg("~n(waiting ... ~n",[]),!,
   wait_for_input([In],RL,5),!,
   ( RL ==[] -> dmsg("...moving on)~n",[]) ; (dmsg("... starting goal)~n",[]),Goal)),
   !.



:- create_prolog_flag(bugger_debug,filter,[type(term),keep(true)]).
:- create_prolog_flag(dmsg_level,filter,[type(term),keep(true)]).
:- create_prolog_flag(dmsg_color,true,[type(boolean),keep(false)]).

% :- mpred_trace_nochilds(system:catch/3).


%:-multifile( tlbugger:bugger_prolog_flag/2).
% :- export( tlbugger:bugger_prolog_flag/2).


% = %= :- meta_predicate (callsc(0)).



%% callsc( :GoalG) is semidet.
%
% Callsc.
%
callsc(G):-G.
% :- '$hide'(callsc/1).
% :- current_predicate(M:callsc/1),mpred_trace_nochilds(M,callsc,1,0,0).


/*
current_prolog_flag(N,VV):-
   (( tlbugger:bugger_prolog_flag(N,V),
   ignore(current_prolog_flag(N,VO)),!,(VO=@=V -> true; ddmsg_call(set_prolog_flag(N,VO))));(current_prolog_flag(N,V),asserta( tlbugger:bugger_prolog_flag(N,V)))),!, V=VV.

set_prolog_flag(N,V):- current_prolog_flag(N,VV),!,
        (V==VV ->  true ; (asserta( tlbugger:bugger_prolog_flag(N,V)),set_prolog_flag(N,V))).
*/


:- set_prolog_flag(dmsg_level,filter).
% :- set_prolog_flag(dmsg_color,false).

:- dynamic(double_quotes_was/1).
:- multifile(double_quotes_was/1).
:- current_prolog_flag(double_quotes,WAS),asserta(double_quotes_was(WAS)).
:- retract(double_quotes_was(WAS)),set_prolog_flag(double_quotes,WAS).
:- current_prolog_flag(double_quotes,WAS),asserta(double_quotes_was(WAS)).




%% define_if_missing( :PRED3M, ?List) is semidet.
%
% Define If Missing.
%
define_if_missing(M:F/A,List):-current_predicate(M:F/A)->true;((forall(member(C,List),M:assertz(C)),export(M:F/A))).

define_if_missing(system:atomics_to_string/3, [
  ( system:atomics_to_string(List, Separator, String):- new_a2s(List, Separator, String) ) ]).

define_if_missing(system:atomics_to_string/2, [
  ( system:atomics_to_string(List, String):- new_a2s(List, '', String) ) ]).




%% new_a2s( ?List, ?Separator, ?String) is semidet.
%
% New A2s.
%
new_a2s(List, Separator, String):-catchv(new_a2s0(List, Separator, String),_,((dtrace,new_a2s0(List, Separator, String)))).



%% new_a2s0( ?List, ?Separator, ?String) is semidet.
%
% New A2s Primary Helper.
%
new_a2s0(List, Separator, String):-
 (atomic(String) -> (string_to_atom(String,Atom),concat_atom(List, Separator, Atom));
     (concat_atom(List, Separator, Atom),string_to_atom(String,Atom))).



:- export(bad_idea/0).



%% bad_idea is semidet.
%
% Bad Idea used to make code that shuld not be ran in release mode
%
bad_idea:- current_prolog_flag(bad_idea,true).


% ===================================================================
% Bugger Term Expansions
% ===================================================================

%=  :- mpred_trace_childs(must(0)).


:- ensure_loaded(dmsg).


%% prolog_call( :Goal) is semidet.
%
% Prolog Call.
%
prolog_call(Call):-call(Call).
% :- mpred_trace_childs(prolog_call(0)).

:- export(hidetrace/1).



%% hidetrace( ?X) is semidet.
%
% Hide Trace.
%
hidetrace(X):- X.
% :- mpred_trace_none(hidetrace(0)).

:- export( tlbugger:use_bugger_expansion/0).
:- dynamic( tlbugger:use_bugger_expansion/0).
:- retractall( tlbugger:use_bugger_expansion).
% :- asserta( tlbugger:use_bugger_expansion).




%% functor_h0( ?P, ?F, :PRED1A) is semidet.
%
% Functor Head Primary Helper.
%
functor_h0(P,F,A):-var(P),!,throw(functor_h_var(P,F,A)).
functor_h0(_:P,F,A):-nonvar(P),!,functor_h0(P,F,A).
functor_h0((P :- _),F,A):-nonvar(P),!,functor_h0(P,F,A).
functor_h0(P,_:F,A):-atom(F),compound(P),compound_name_arity(P,F,A),!.
functor_h0(P,F,A):-compound(P),compound_name_arity(P,F,A),!.
functor_h0(F,F,1):-!.

% = %= :- meta_predicate (bugger_t_expansion(+,+,-)).



%% bugger_t_expansion( +OUT1, +T, -T) is semidet.
%
% Logic Moo Debugger True Structure Expansion.
%
bugger_t_expansion(_,T,T):-var(T),!.
bugger_t_expansion(CM,(H:-B),(H:-BB)):-!,bugger_t_expansion(CM,B,BB).
bugger_t_expansion(_,T,T):-not(compound(T)),!.
% bugger_t_expansion(_,C =.. List,compound_name_arguments(C,F,ARGS)):-List =@= [F|ARGS],!.
bugger_t_expansion(_,prolog_call(T),T):-!.
bugger_t_expansion(_,dynamic(T),dynamic(T)):-!.
bugger_t_expansion(_,format(F,A),format_safe(F,A)):-!.
bugger_t_expansion(CM,quietly(T),quietly(TT)):-!,bugger_t_expansion(CM,(T),(TT)).
bugger_t_expansion(_,F/A,F/A):-!.
bugger_t_expansion(_,M:F/A,M:F/A):-!.
bugger_t_expansion(CM,[F0|ARGS0],[F1|ARGS1]):- !,bugger_t_expansion(CM,F0,F1),bugger_t_expansion(CM,ARGS0,ARGS1).
% bugger_t_expansion(CM,T,AA):-  tlbugger:use_bugger_expansion,compound_name_arguments(T,F,[A]),unwrap_for_debug(F),!,bugger_t_expansion(CM,A,AA),
%  dmsg(bugger_term_expansion((T->AA))),!.
bugger_t_expansion(_,use_module(T),use_module(T)):-!.
bugger_t_expansion(_,module(A,B),module(A,B)):-!.
bugger_t_expansion(_,listing(A),listing(A)):-!.
bugger_t_expansion(CM,M:T,M:TT):-!,bugger_t_expansion(CM,T,TT),!.
bugger_t_expansion(_,test_is(A),test_is_safe(A)):-!.
bugger_t_expansion(_,delete(A,B,C),delete(A,B,C)):-!.
bugger_t_expansion(CM,T,TT):-  
     compound_name_arguments(T,F,A),quietly((bugger_t_expansion(CM,A,AA),
     functor_h0(T,FH,AH))),
    ( (fail,bugger_atom_change(CM,T,F,FH,AH,FF))-> true; FF=F ),
    compound_name_arguments(TT,FF,AA),!,
    ((true;T =@= TT)-> true;  dmsg(bugger_term_expansion(CM,(T->TT)))),!.

% = %= :- meta_predicate (bugger_atom_change(:,0,+,+,-,-)).



%% bugger_atom_change( ?CM, :GoalT, +F, +FH, -FA, -FF) is semidet.
%
% Logic Moo Debugger Atom Change.
%
bugger_atom_change(CM,T,F,FH,FA,FF):- tlbugger:use_bugger_expansion, bugger_atom_change0(CM,T,F,FH,FA,FF).



%% bugger_atom_change0( ?CM, ?T, ?F, ?FH, ?FA, ?FF) is semidet.
%
% Logic Moo Debugger Atom Change Primary Helper.
%
bugger_atom_change0(_CM,T,_F,FH,FA,FF):- current_predicate_module(T,M1),atom_concat(FH,'_safe',FF),functor_safe(FFT,FF,FA),current_predicate_module(FFT,M2),differnt_modules(M1,M2).

% = %= :- meta_predicate (bugger_atom_change(:,(-))).



%% bugger_atom_change( ?CM, -TT) is semidet.
%
% Logic Moo Debugger Atom Change.
%
bugger_atom_change(CM:T,TT):-
     functor_h0(T,FH,AH),
     F = CM:T,
    (bugger_atom_change(CM,T,F,FH,AH,FF)->true;FF=F),!,
    compound_name_arity(TT,FF,AH).





%% differnt_modules( ?User2, ?User1) is semidet.
%
% Differnt Modules.
%
differnt_modules(User2,User1):- (User1==user;User2==user),!.
differnt_modules(User2,User1):- User1 \== User2.


:- dynamic(unwrap_for_debug/1).
% unwrap_for_debug(F):-member(F,[notrace,quietly]).
% unwrap_for_debug(F):-member(F,[traceok,must,must_det,quietly]).
%unwrap_for_debug(F):-member(F,['on_x_debug',on_x_debug]),!,fail.
%unwrap_for_debug(F):-member(FF,['OnError','OnFailure','LeastOne','Ignore','must']),atom_concat(_,FF,F),!.

% = %= :- meta_predicate (bugger_goal_expansion(:,-)).



%% bugger_goal_expansion( ?CM, -TT) is semidet.
%
% Logic Moo Debugger Goal Expansion.
%
bugger_goal_expansion(CM:T,TT):-  tlbugger:use_bugger_expansion,!,bugger_goal_expansion(CM,T,TT).
% = %= :- meta_predicate (bugger_goal_expansion(+,+,-)).



%% bugger_goal_expansion( +CM, +T, -T3) is semidet.
%
% Logic Moo Debugger Goal Expansion.
%
bugger_goal_expansion(CM,T,T3):- once(bugger_t_expansion(CM,T,T2)),T\==T2,!,on_x_fail(expand_term(T2,T3)).

% = %= :- meta_predicate (bugger_expand_goal(0,-)).



%% bugger_expand_goal( :GoalT, -IN2) is semidet.
%
% Logic Moo Debugger Expand Goal.
%
bugger_expand_goal(T,_):- fail,dmsg(bugger_expand_goal(T)),fail.

% = %= :- meta_predicate (bugger_expand_term(0,-)).



%% bugger_expand_term( :GoalT, -IN2) is semidet.
%
% Logic Moo Debugger Expand Term.
%
bugger_expand_term(T,_):- fail, dmsg(bugger_expand_term(T)),fail.

:- export(format_safe/2).



%% format_safe( ?A, ?B) is semidet.
%
% Format Safely Paying Attention To Corner Cases.
%
format_safe(A,B):-catchv(format(A,B),E,(dumpST,dtrace_msg(E:format(A,B)))).

% = %= :- meta_predicate (bugger_term_expansion(:,-)).



%% bugger_term_expansion( ?CM, -TT) is semidet.
%
% Logic Moo Debugger Term Expansion.
%
bugger_term_expansion(CM:T,TT):- compound(T),  tlbugger:use_bugger_expansion,!,bugger_term_expansion(CM,T,TT).
% = %= :- meta_predicate (bugger_term_expansion(+,+,-)).



%% bugger_term_expansion( +CM, +T, -T3) is semidet.
%
% Logic Moo Debugger Term Expansion.
%
bugger_term_expansion(CM,T,T3):- once(bugger_t_expansion(CM,T,T2)),T\==T2,!,nop(dmsg(T\==T2)),catchv(expand_term(T2,T3),_,fail).

%      expand_goal(G,G2):- compound(G),bugger_expand_goal(G,G2),!.


% goal_expansion(G,G2):- compound(G),bugger_goal_expansion(G,G2).

% expand_term(G,G2):- compound(G),bugger_expand_term(G,G2),!.


:- export(traceok/1).
%=  = %= :- meta_predicate (quietly(0)).
% = %= :- meta_predicate (traceok(0)).






%% thread_local_leaks is semidet.
%
% Thread Local Leaks.
%
thread_local_leaks:-!.






%% dtrace_msg( ?E) is semidet.
%
% (debug) Trace Msg.
%
dtrace_msg(E):- dumpST,wdmsg(E),dtrace(wdmsg(E)),!.



%% has_gui_debug is semidet.
%
% Has Gui Debug.
%
has_gui_debug :- current_prolog_flag(windows,true),!.
has_gui_debug :- ( \+ current_prolog_flag(gui,true) ),!,fail.
has_gui_debug :- getenv('DISPLAY',NV),NV\==''.

:- export(nodebugx/1).
:- module_transparent(nodebugx/1).



%% nodebugx( :GoalX) is semidet.
%
% Nodebugx.
%
nodebugx(X):- prolog_debug:debugging(Topic, true, _),!,scce_orig(nodebug(Topic),nodebugx(X),debug(Topic)).
nodebugx(X):- current_prolog_flag(debug_threads,true),!,call(X).
nodebugx(X):- 
 locally(-tlbugger:ifCanTrace,
   locally(tlbugger:ifWontTrace,
    locally(tlbugger:show_must_go_on,
       locally(tlbugger:ifHideTrace,quietly(X))))).

debugging_logicmoo(Mask):- logicmoo_topic(Mask,Topic),prolog_debug:debugging(Topic, TF, _),!,TF=true.

logicmoo_topic(Mask,Topic):-var(Mask),!,Topic=logicmoo(_).
logicmoo_topic(logicmoo,Topic):-!,Topic=logicmoo(_).
logicmoo_topic(Mask,Topic):-prolog_debug:debugging(Topic, _, _),Topic=@=Mask,!.
logicmoo_topic(Mask,Topic):-atomic(Mask),!,logicmoo_topic(logicmoo(Mask),Topic),!.
logicmoo_topic(Topic,Topic):-(ground(Topic)->nodebug(Topic);true).

nodebug_logicmoo(Mask):-
  forall(retract(prolog_debug:debugging(Mask, true, O)),asserta(prolog_debug:debugging(Mask, false, O))),
   logicmoo_topic(Mask,Topic),
   forall(retract(prolog_debug:debugging(Topic, true, O)),asserta(prolog_debug:debugging(Topic, false, O))),
   (ground(Mask)->nodebug(Topic);true),!.

debug_logicmoo(Mask):-
  forall(retract(prolog_debug:debugging(Mask, false, O)),asserta(prolog_debug:debugging(Mask, true, O))),
   logicmoo_topic(Mask,Topic),
   forall(retract(prolog_debug:debugging(Topic, false, O)),asserta(prolog_debug:debugging(Topic, true, O))),
   (ground(Mask)->debug(Topic);debug(Topic)),!.



:- dynamic isDebugging/1.

:- multifile was_module/2.
:- dynamic was_module/2.
:- module_transparent was_module/2.

:- thread_local(tlbugger:has_auto_trace/1).

%term_expansion(G,G2):- loop_check(bugger_term_expansion(G,G2)).
%goal_expansion(G,G2):- loop_check(bugger_goal_expansion(G,G2)).




% - 	list_difference_eq(+List, -Subtract, -Rest)
%
%	Delete all elements of Subtract from List and unify the result
%	with Rest. Element comparision is done using ==/2.



%% list_difference_eq( :TermX, ?Ys, ?L) is semidet.
%
% List Difference Using (==/2) (or =@=/2) ).
%
list_difference_eq([],_,[]).
list_difference_eq([X|Xs],Ys,L) :-
 	(  list_difference_eq_memberchk_eq(X,Ys)
 	-> list_difference_eq(Xs,Ys,L)
 	;  L = [X|T],
 	  list_difference_eq(Xs,Ys,T)
 	).



%% list_difference_eq_memberchk_eq( ?X, :TermY) is semidet.
%
% List Difference Using (==/2) (or =@=/2) ) Memberchk Using (==/2) (or =@=/2) ).
%
list_difference_eq_memberchk_eq(X, [Y|Ys]) :- (  X == Y -> true ;  list_difference_eq_memberchk_eq(X, Ys) ).


%= :- meta_predicate  meta_interp(:,+).




%% meta_interp_signal( :TermV) is semidet.
%
% Meta Interp Signal.
%
meta_interp_signal(meta_call(V)):-!,nonvar(V).
meta_interp_signal(meta_callable(_,_)).
meta_interp_signal(_:meta_call(V)):-!,nonvar(V).
meta_interp_signal(_:meta_callable(_,_)).

:- export(meta_interp/2).



%% meta_interp( ?CE, +A) is semidet.
%
% Meta Interp.
%
meta_interp(CE,A):- quietly((var(A); \+ if_defined(stack_check,fail))),!, throw(meta_interp(CE,A)).
meta_interp(_CE,A):- maybe_leash(+all),meta_interp_signal(A),!,fail.
meta_interp(CE,M:X):- atom(M),!,meta_interp(CE,X).
meta_interp(_,true):-!.
meta_interp(CE,A):- call(CE, meta_callable(A,NewA)),!,call(NewA).
meta_interp(CE,\+(A)):-!,\+(meta_interp(CE,A)).
meta_interp(CE,not(A)):-!,\+(meta_interp(CE,A)).
meta_interp(CE,once(A)):-!,once(meta_interp(CE,A)).
meta_interp(CE,must(A)):-!,must(meta_interp(CE,A)).
meta_interp(CE,(A->B;C)):-!,(meta_interp(CE,A)->meta_interp(CE,B);meta_interp(CE,C)).
meta_interp(CE,(A*->B;C)):-!,(meta_interp(CE,A)*->meta_interp(CE,B);meta_interp(CE,C)).
meta_interp(CE,(A;B)):-!,meta_interp(CE,A);meta_interp(CE,B).
meta_interp(CE,(A->B)):-!,meta_interp(CE,A)->meta_interp(CE,B).
meta_interp(CE,(A,!)):-!,meta_interp(CE,A),!.
meta_interp(CE,(A,B)):-!,meta_interp(CE,A),meta_interp(CE,B).
%meta_interp(_CE,!):- !, cut_block(!).
meta_interp(CE,A):- show_call(why,call(CE,meta_call(A))).


% was_module(Mod,Exports) :- nop(was_module(Mod,Exports)).




% ===================================================

% = %= :- meta_predicate (once_if_ground(0)).



%% once_if_ground( :Goal) is semidet.
%
% Once If Ground.
%
once_if_ground(Call):-not(ground(Call)),!,Call.
once_if_ground(Call):- once(Call).

% = %= :- meta_predicate (once_if_ground(0,-)).



%% once_if_ground( :Goal, -T) is semidet.
%
% Once If Ground.
%
once_if_ground(Call,T):-not(ground(Call)),!,Call,deterministic(D),(D=yes -> T= (!) ; T = true).
once_if_ground(Call,!):-once(Call).

% ===================================================




%% to_list_of( ?VALUE1, :TermRest, ?Rest) is semidet.
%
% Converted To List Of.
%
to_list_of(_,[Rest],Rest):-!.
to_list_of(RL,[R|Rest],LList):-
      to_list_of(RL,R,L),
      to_list_of(RL,Rest,List),
      LList=..[RL,L,List],!.

% ===================================================




%% call_or_list( ?Rest) is semidet.
%
% Call Or List.
%
call_or_list([Rest]):-!,call(Rest).
call_or_list(Rest):-to_list_of(';',Rest,List),!,call(List).




%% call_skipping_n_clauses( ?N, ?H) is semidet.
%
% Call Skipping N Clauses.
%
call_skipping_n_clauses(N,H):-
   findall(B,clause_safe(H,B),L),length(L,LL),!,LL>N,length(Skip,N),append(Skip,Rest,L),!,call_or_list(Rest).

% =========================================================================

:- thread_local( tlbugger:wastracing/0).
% :- mpred_trace_none( tlbugger:wastracing/0).

% =========================================================================
% cli_ntrace(+Call) is nondet.
% use call/1 with dtrace turned off



%% cli_ntrace( :GoalX) is semidet.
%
% Cli N Trace.
%
cli_ntrace(X):- tracing -> locally( tlbugger:wastracing,call_cleanup((notrace,call(X)),dtrace)) ; call(X).



%% traceok( :GoalX) is semidet.
%
% Traceok.
%
traceok(X):-  tlbugger:wastracing -> call_cleanup((dtrace,call(X)),notrace) ; call(X).

% :- mpred_trace_none(tlbugger:skip_bugger).
% :- mpred_trace_none(skipWrapper).


% =========================================================================


% = %= :- meta_predicate (show_entry(Why,0)).



%% show_entry( +Why, :Goal) is semidet.
%
% Show Entry.
%
show_entry(Why,Call):-debugm(Why,show_entry(Call)),show_call(Why,Call).



%% show_entry( :Goal) is semidet.
%
% Show Entry.
%
show_entry(Call):-show_entry(mpred,Call).

%= :- meta_predicate  dcall0(0).



%% dcall0( :Goal) is semidet.
%
% Dirrectly Call Primary Helper.
%
dcall0(Goal):- Goal. % on_x_debug(Goal). % dmsg(show_call(why,Goal)),Goal.      

%= :- meta_predicate  show_call(+,0).



%% show_call( +Why, :Goal) is semidet.
%
% Show Call.
%
show_call(Why,Goal):- show_success(Why,Goal)*->true;(dmsg(show_failure(Why,Goal)),!,fail).


%% show_call( :Goal) is semidet.
%
% Show Call.
%
show_call(Goal):- strip_module(Goal,Why,_),show_call(Why,Goal).

%= :- meta_predicate  show_failure(+,0).



%% show_failure( +Why, :Goal) is semidet.
%
% Show Failure.
%
show_failure(Why,Goal):-one_must(dcall0(Goal),(debugm(Why,sc_failed(Why,Goal)),!,fail)).



%% show_failure( :Goal) is semidet.
%
% Show Failure.
%
show_failure(Goal):- show_failure(mpred,Goal).


%% show_success( +Why, :Goal) is semidet.
%
% Show Success.
%
show_success(Why,Goal):- cyclic_term(Goal),dumpST,
 ((cyclic_term(Goal)->  dmsg(show_success(Why,cyclic_term)) ; 
  \+ \+ quietly(debugm(Why,sc_success(Why,Goal))))).
show_success(Why,Goal):- dcall0(Goal), 
 quietly((cyclic_term(Goal)->  dmsg(show_success(Why,cyclic_term)) ; 
  \+ \+ quietly(wdmsg(c_success(Why,Goal))))).



%% show_success( :Goal) is semidet.
%
% Show Success.
%
show_success(Goal):- show_success(mpred,Goal).

%= :- meta_predicate  on_f_log_fail(0).
:- export(on_f_log_fail/1).



%% on_f_log_fail( :Goal) is semidet.
%
% Whenever Functor Log Fail.
%
on_f_log_fail(Goal):-one_must(Goal,quietly((dmsg(on_f_log_fail(Goal)),cleanup_strings,!,fail))).



% ==========================================================
% can/will Tracer.
% ==========================================================



%% shrink_clause( ?P, ?Body, ?Prop) is semidet.
%
% Shrink Clause.
%
shrink_clause(P,Body,Prop):- (Body ==true -> Prop=P ; (Prop= (P:-Body))).





%% shrink_clause( ?HB, ?HB) is semidet.
%
% Shrink Clause.
%
shrink_clause( (H:-true),H):-!.
shrink_clause( HB,HB).


:- thread_local(tlbugger:ifCanTrace/0).
:- asserta((tlbugger:ifCanTrace:-!)).
% :- '$hide'(tlbugger:ifCanTrace/0).
% thread locals should defaults to false: tlbugger:ifCanTrace.
%MAIN 

:- export(tlbugger:ifWontTrace/0).
:- thread_local(tlbugger:ifWontTrace/0).
% :- '$hide'(tlbugger:ifWontTrace/0).

% :- '$hide'(tlbugger:ifHideTrace/0).

%:-meta_predicate(set_no_debug).
:- export(set_no_debug/0).

:- dynamic(is_set_no_debug/0).




%% set_no_debug is semidet.
%
% Set No Debug.
%
set_no_debug:- 
  must_det_l((
   asserta(is_set_no_debug),
   set_prolog_flag(generate_debug_info, true),
   retractall(tlbugger:ifCanTrace),
   retractall(tlbugger:ifWontTrace),
   asserta(tlbugger:ifWontTrace),   
   set_prolog_flag(report_error,false),   
   set_prolog_flag(debug_on_error,false),
   set_prolog_flag(debug, false),   
   set_prolog_flag(query_debug_settings, debug(false, false)),
   set_gui_debug(fail),
   maybe_leash(-all),
   maybe_leash(+exception),
   visible(-cut_call),!,
   notrace, nodebug)),!.

:- export(set_no_debug_thread/0).



%% set_no_debug_thread is semidet.
%
% Set No Debug Thread.
%
set_no_debug_thread:- 
  must_det_l((
   retractall(tlbugger:ifCanTrace),
   retractall(tlbugger:ifWontTrace),
   asserta(tlbugger:ifWontTrace))),!.

:- if(prolog_dialect:exists_source(library(gui_tracer))).
%= :- meta_predicate  set_gui_debug(0).



%% set_gui_debug( :GoalTF) is semidet.
%
% Set Gui Debug.
%
set_gui_debug(TF):- current_prolog_flag(gui,true),!,
   ((TF, has_gui_debug,set_yes_debug, ignore((use_module(library(gui_tracer)),catchv(guitracer,_,true)))) 
     -> set_prolog_flag(gui_tracer, true) ;
        set_prolog_flag(gui_tracer, false)).
:- endif.
set_gui_debug(false):-!.
set_gui_debug(true):- dmsg("Warning: no GUI").

:- module_transparent(set_yes_debug/0).
:- export(set_yes_debug/0).



%% set_yes_debug is semidet.
%
% Set Yes Debug.
%
set_yes_debug:- 
  must_det_l((
   set_prolog_flag(generate_debug_info, true),
   set_prolog_flag(report_error,true),   
   set_prolog_flag(debug_on_error,true),
   set_prolog_flag(debug, true),   
   set_prolog_flag(query_debug_settings, debug(true, true)),
   % set_gui_debug(true),
   maybe_leash(+all),
   maybe_leash(+exception),
   visible(+cut_call),
   notrace, debug)),!.




%% set_yes_debug_thread is semidet.
%
% Set Yes Debug Thread.
%
set_yes_debug_thread:-
  set_yes_debug,
   (tlbugger:ifCanTrace->true;assert(tlbugger:ifCanTrace)),
   retractall(tlbugger:ifWontTrace).

:- tlbugger:use_bugger_expansion->true;assert(tlbugger:use_bugger_expansion).

% :- set_yes_debug.




% ==========================================================
%  can/will Tracer.
% ==========================================================
  
%% isConsole is semidet.
%
% If Is A Console.
%
isConsole :- current_output(X),!,stream_property(X,alias(user_output)).
%isConsole :- telling(user).


:-dynamic(canTrace/0).
canTrace.
 

%% willTrace is semidet.
%
% will  Trace.
%
willTrace:-tlbugger:ifWontTrace,!,fail.
willTrace:-not(isConsole),!,fail.
willTrace:-tlbugger:ifCanTrace.
willTrace:-canTrace.




%% hideTrace is semidet.
%
% hide  Trace.
%
hideTrace:-
  hideTrace([quietly/1], -all),
  % hideTrace(computeInnerEach/4, -all),

  hideTrace(
   [maplist_safe/2,
       maplist_safe/3], -all),


  hideTrace([hideTrace/0,
     tlbugger:ifCanTrace/0,
     ctrace/0,
     willTrace/0], -all),

  hideTrace([traceafter_call/1], -all),
  % hideTrace([notrace_call/1], -all),

  hideTrace([
   call/1,
   call/2,
   apply/2,
   '$bags':findall/3,
   '$bags':findall/4,
   once/1,
   ','/2,
   catch/3,
   catchv/3,
   member/2], -all),

  hideTrace(setup_call_catcher_cleanup/4,-all),

  hideTrace(system:throw/1, +all),
  % hideTrace(system:dmsg/2, +all),
  hideTrace(message_hook/3 , +all),
  hideTrace(system:message_to_string/2, +all),
  !,hideRest,!.
  % findall(File-F/A,(functor_source_file(M,P,F,A,File),M==user),List),sort(List,Sort),dmsg(Sort),!.

/*
hideRest:- fail, buggerDir(BuggerDir),
   functor_source_file(M,_P,F,A,File),atom_concat(BuggerDir,_,File),hideTraceMFA(M,F,A,-all),
   fail.  */



%% hideRest is semidet.
%
% Hide Rest.
%
hideRest:- functor_source_file(system,_P,F,A,_File),hideTraceMFA(system,F,A, - all), fail.
hideRest.

% = %= :- meta_predicate (hideTrace(:,-)).




%% functor_source_file( ?M, ?P, ?F, ?A, ?File) is semidet.
%
% Functor Source File.
%
functor_source_file(M,P,F,A,File):-functor_source_file0(M,P,F,A,File). % sanity(ground((M,F,A,File))),must(nonvar(P)).



%% functor_source_file0( ?M, ?P, ?F, ?A, ?File) is semidet.
%
% Functor Source File Primary Helper.
%
functor_source_file0(M,P,F,A,File):-current_predicate(F/A),functor_safe(P,F,A),source_file(P,File),predicate_module(P,M).




%% predicate_module( ?P, ?M) is semidet.
%
% Predicate Module.
%
predicate_module(P,M):- var(P),!,trace_or_throw(var_predicate_module(P,M)).
predicate_module(P,M):- predicate_property(P,imported_from(M)),!.
predicate_module(F/A,M):- atom(F),integer(A),functor(P,F,A),P\==F/A,predicate_property(P,imported_from(M)),!.
predicate_module(Ctx:P,M):- Ctx:predicate_property(P,imported_from(M)),!.
predicate_module(Ctx:F/A,M):- Ctx:((atom(F),integer(A),functor(P,F,A),P\==F/A,predicate_property(P,imported_from(M)))),!.
predicate_module(M:_,M):-!. %strip_module(P,M,_F),!.
predicate_module(_P,user):-!. %strip_module(P,M,_F),!.
% predicate_module(P,M):- strip_module(P,M,_F),!.




%% hideTrace( ?MA, -T) is semidet.
%
% hide  Trace.
%
hideTrace(_:A, _) :-
    var(A), !, dtrace, fail,
    throw(error(instantiation_error, _)).
hideTrace(_:[], _) :- !.
hideTrace(A:[B|D], C) :- !,
    hideTrace(A:B, C),
    hideTrace(A:D, C),!.

hideTrace(M:A,T):-!,hideTraceMP(M,A,T),!.
hideTrace(MA,T):-hideTraceMP(_,MA,T),!.




%% hideTraceMP( ?M, ?P, ?T) is semidet.
%
% hide  Trace Module Pred.
%
hideTraceMP(M,F/A,T):-!,hideTraceMFA(M,F,A,T),!.
hideTraceMP(M,P,T):-functor_safe(P,F,0),dtrace,hideTraceMFA(M,F,_A,T),!.
hideTraceMP(M,P,T):-functor_safe(P,F,A),hideTraceMFA(M,F,A,T),!.




%% tryCatchIgnore( :GoalMFA) is semidet.
%
% Try Catch Ignore.
%
tryCatchIgnore(MFA):- catchv(MFA,_E,true). % dmsg(tryCatchIgnoreError(MFA:E))),!.
tryCatchIgnore(_MFA):- !. % dmsg(tryCatchIgnoreFailed(MFA)).

% tryHide(_MFA):-showHiddens,!.



%% tryHide( ?MFA) is semidet.
%
% Try Hide.
%
tryHide(MFA):- tryCatchIgnore('$hide'(MFA)).




%% hideTraceMFA( ?M, ?F, ?A, ?T) is semidet.
%
% hide  Trace Module Functor a.
%
hideTraceMFA(_,M:F,A,T):-!,hideTraceMFA(M,F,A,T),!.
hideTraceMFA(M,F,A,T):-nonvar(A),functor_safe(P,F,A),predicate_property(P,imported_from(IM)),IM \== M,!,nop(dmsg(doHideTrace(IM,F,A,T))),hideTraceMFA(IM,F,A,T),!.
hideTraceMFA(M,F,A,T):-hideTraceMFAT(M,F,A,T),!.




%% hideTraceMFAT( ?M, ?F, ?A, ?T) is semidet.
%
% hide  Trace Module Functor a True Stucture.
%
hideTraceMFAT(M,F,A,T):-doHideTrace(M,F,A,T),!.




%% doHideTrace( ?M, ?F, ?A, ?ATTRIB) is semidet.
%
% do hide  Trace.
%
doHideTrace(_M,_F,_A,[]):-!.
doHideTrace(M,F,A,[hide|T]):- tryHide(M:F/A),!,doHideTrace(M,F,A,T),!.
doHideTrace(M,F,A,[-all]):- '$hide'(M:F/A),fail.
doHideTrace(M,F,A,ATTRIB):- ( \+ is_list(ATTRIB)),!,doHideTrace(M,F,A,[ATTRIB]).
doHideTrace(M,F,A,ATTRIB):- tryHide(M:F/A),!,
  tryCatchIgnore(dtrace(M:F/A,ATTRIB)),!.





%% ctrace is semidet.
%
% Class Trace.
%
ctrace:-willTrace->dtrace;notrace.




%% buggeroo is semidet.
%
% Buggeroo.
%
buggeroo:-hideTrace,traceAll,atom_concat(guit,racer,TRACER), catchv(call(TRACER),_,true),debug,list_undefined.




%% singletons( ?VALUE1) is semidet.
%
% Singletons.
%
singletons(_).

/*
 Stop turning GC on/off
:- set_prolog_flag(backtrace_goal_depth, 2000).
:- set_prolog_flag(debugger_show_context,true).
:- set_prolog_flag(trace_gc,true).
:- set_prolog_flag(gc,true).
:- set_prolog_flag(debug,true).
:- set_prolog_flag(debugger_write_options,[quoted(true), portray(true), max_depth(1000), attributes(portray),spacing(next_argument)]).
 put_attr(VV,vn,'YY'),writeq(vv(VV)).

:- set_prolog_flag(toplevel_print_factorized,true). % default false
:- set_prolog_flag(toplevel_print_anon,true).
:- set_prolog_flag(toplevel_mode,backtracking). % OR recursive 

*/
:- set_prolog_flag(backtrace_depth,   2000).
:- set_prolog_flag(backtrace_show_lines, true).
:- set_prolog_flag(debugger_show_context,true).



%% set_optimize( ?TF) is semidet.
%
% Set Optimize.
%
set_optimize(_):- !.
set_optimize(TF):- set_prolog_flag(gc,TF),set_prolog_flag(last_call_optimisation,TF),set_prolog_flag(optimise,TF).




%% do_gc is semidet.
%
% Do Gc.
%
% do_gc:- !.
do_gc:- do_gc0,!.




%% do_gc0 is semidet.
%
% Do Gc Primary Helper.
%
do_gc0:- current_prolog_flag(gc,true),!,do_gc1.
do_gc0:- set_prolog_flag(gc,true), do_gc1, set_prolog_flag(gc,false).



%% do_gc1 is semidet.
%
% Do Gc Secondary Helper.
%
do_gc1:- quietly((garbage_collect, cleanup_strings /*garbage_collect_clauses*/ /*, statistics*/
                    )).





%% fresh_line is semidet.
%
% Fresh Line.
%
fresh_line:-current_output(Strm),fresh_line(Strm),!.



% :- multifile(lmcache:is_prolog_stream/1).
% :- dynamic(lmcache:is_prolog_stream/1).

%% fresh_line( ?Strm) is semidet.
%
% Fresh Line.
%
%fresh_line(Strm):-lmcache:is_prolog_stream(Strm),on_x_fail(format(Strm,'~n',[])),!.
fresh_line(Strm):-on_x_fail(format(Strm,'~N',[])),!.
fresh_line(Strm):-on_x_fail((stream_property(Strm,position('$stream_position'(_,_,POS,_))),(POS>0->nl(Strm);true))),!.
fresh_line(Strm):-on_x_fail(nl(Strm)),!.
fresh_line(_).




%% ifThen( :GoalWhen, :GoalDo) is semidet.
%
% If Then.
%
ifThen(When,Do):-When->Do;true.

% :- current_predicate(F/N),dtrace(F/N, -all),fail.
/*
traceAll:- current_predicate(F/N),
  functor_safe(P,F,N),
  local_predicate(P,F/N),
  trace(F/N, +fail),fail.
traceAll:- not((predicate_property(clearCateStack/1,_))),!.
traceAll:-findall(_,(member(F,[member/2,dmsg/1,takeout/3,findall/3,clearCateStack/1]),trace(F, -all)),_).
*/



%% traceAll is semidet.
%
%  Trace all.
%
traceAll:-!.





%% forall_member( ?C, ?C1, :Goal) is semidet.
%
% Forall Member.
%
forall_member(C,[C],Call):-!,once(Call).
forall_member(C,C1,Call):-forall(member(C,C1),once(Call)).




%% prolog_must( :Goal) is semidet.
%
% Prolog Must Be Successfull.
%
% prolog_must(Call):-must(Call).


% gmust is must with sanity



%% gmust( :GoalTrue, :Goal) is semidet.
%
% Gmust.
%
gmust(True,Call):-catchv((Call,(True->true;throw(retry(gmust(True,Call))))),retry(gmust(True,_)),(dtrace,Call,True)).

% must is used declaring the predicate must suceeed




%% on_f_throw( :Goal) is semidet.
%
% Whenever Functor Throw.
%
on_f_throw(Call):-one_must(Call,throw(on_f_throw(Call))).



%% on_x_cont( :GoalCX) is semidet.
%
% If there If Is A an exception in  :Goal Class x then cont.
%
on_x_cont(CX):-ignore(catchv(CX,_,true)).

% pause_trace(_):- quietly(((debug,visible(+all),maybe_leash(+exception),maybe_leash(+call)))),dtrace.

%debugCall(Goal):-quietly,dmsg(debugCall(Goal)),dumpST, pause_trace(errored(Goal)),ggtrace,Goal.
%debugCallF(Goal):-quietly,dmsg(debugCallF(Goal)),dumpST, pause_trace(failed(Goal)),gftrace,Goal.





%% with_skip_bugger( :Goal) is semidet.
%
% Using Skip Logic Moo Debugger.
%
with_skip_bugger(Goal):-setup_call_cleanup(asserta( tlbugger:skip_bugger,Ref),Goal,erase(Ref)).




%% on_x_rtraceEach( :Goal) is semidet.
%
% If there If Is A an exception in  :Goal goal then r Trace each.
%
on_x_rtraceEach(Goal):-with_each(1,on_x_debug,Goal).



%! on_x_debug( :GoalC) is nondet.
%
% If there If Is A an exception in  :Goal Class then r Trace.
%
on_x_debug(C):- !,
 notrace(((skipWrapper;tracing;(tlbugger:rtracing)),maybe_leash(+exception))) -> C;
   catchv(C,E,
     (wdmsg(on_x_debug(E)),catchv(rtrace(with_skip_bugger(C)),E,wdmsg(E)),dtrace(C))).
% on_x_debug(Goal):- with_each(0,on_x_debug,Goal).


%% on_x_debug_cont( :Goal) is semidet.
%
% If there If Is A an exception in  :Goal goal then debug cont.
%
on_x_debug_cont(Goal):-ignore(on_x_debug(Goal)).




%% with_each( :GoalWrapperGoal) is semidet.
%
% Using Each.
%
with_each(WrapperGoal):- WrapperGoal=..[Wrapper,Goal],with_each(Wrapper,Goal).



%% with_each( ?Wrapper, :Goal) is semidet.
%
% Using Each.
%
with_each(Wrapper,Goal):-with_each(1,Wrapper,Goal).





%% on_f_debug( :Goal) is semidet.
%
% Whenever Functor Debug.
%
on_f_debug(Goal):-  Goal *-> true; ((nortrace,notrace,debugCallWhy(failed(on_f_debug(Goal)),Goal)),fail).


%% debugCallWhy( ?Why, :GoalC) is semidet.
%
% Debug Call Generation Of Proof.
%
debugCallWhy(Why, C):- wdmsg(Why),catch(dtrace(C),E,wdmsg(cont_X_debugCallWhy(E,Why, C))).





%% logOnFailure0( :Goal) is semidet.
%
% Log Whenever Failure Primary Helper.
%
logOnFailure0(Goal):- one_must(Goal,(dmsg(on_f_log_fail(Goal)),fail)).



%% logOnFailureEach( :Goal) is semidet.
%
% Log Whenever Failure Each.
%
logOnFailureEach(Goal):-with_each(1,on_f_log_fail,Goal).




%on_f_debug(Goal):-ctrace,Goal.
%on_f_debug(Goal):-catchv(Goal,E,(writeFailureLog(E,Goal),throw(E))).
%on_f_throw/1 is like Java/C's assert/1
%debugOnFailure1(Module,Goal):-dtrace,on_f_debug(Module:Goal),!.
%debugOnFailure1(arg_domains,Goal):-!,on_f_log_fail(Goal),!.





% = %= :- meta_predicate (with_no_term_expansions(0)).



%% with_no_term_expansions( :Goal) is semidet.
%
% Using No Term Expansions.
%
with_no_term_expansions(Call):-
  locally_hide(term_expansion(_,_),
    locally_hide(term_expansion(_,_),
    locally_hide(goal_expansion(_,_),
      locally_hide(goal_expansion(_,_),Call)))).




%% kill_term_expansion is semidet.
%
% Kill Term Expansion.
%
kill_term_expansion:-
   abolish(term_expansion,2),
   abolish(goal_expansion,2),
   dynamic(term_expansion/2),
   dynamic(goal_expansion/2),
   multifile(term_expansion/2),
   multifile(goal_expansion/2).




%% local_predicate( ?P, :TermARG2) is semidet.
%
% Local Predicate.
%
local_predicate(_,_/0):-!,fail.
local_predicate(_,_/N):-N>7,!,fail.
local_predicate(P,_):-real_builtin_predicate(P),!,fail.
local_predicate(P,_):-predicate_property(P,imported_from(_)),!,fail.
%local_predicate(P,_):-predicate_property(P,file(F)),!,atom_contains666(F,'aiml_'),!.
local_predicate(P,F/N):-functor_safe(P,F,N),!,fail.




%% atom_contains666( ?F, ?C) is semidet.
%
% Atom Contains666.
%
atom_contains666(F,C):- quietly((atom(F),atom(C),sub_atom(F,_,_,_,C))).

% = %= :- meta_predicate (real_builtin_predicate(0)).





%% real_builtin_predicate( :GoalG) is semidet.
%
% Real Builtin Predicate.
%
real_builtin_predicate(G):- predicate_property(G,foreign),!.
real_builtin_predicate(G):- \+ predicate_property(G,defined),!,fail.
%real_builtin_predicate(G):- predicate_property(G,imported_from(W))-> W==system,!.
%real_builtin_predicate(G):- strip_module(G,_,GS),predicate_property(system:GS,BI),BI==built_in,!.
real_builtin_predicate(G):-    \+ predicate_property(G,dynamic),
   predicate_property(G,BI),BI==built_in,
   get_functor(G,F,A),
   M=_,
   %suggest_m(M),current_assertion_module(M)
   if_defined(baseKB:mpred_prop(M,F,A,prologBuiltin),fail),
   !.





%% will_debug_else_throw( :GoalE, :Goal) is semidet.
%
% Will Debug Else Throw.
%
will_debug_else_throw(E,Goal):- dmsg(bugger(will_debug_else_throw(E,Goal))),rtrace,Goal.




%% show_goal_rethrow( ?E, ?Goal) is semidet.
%
% Show Goal Rethrow.
%
show_goal_rethrow(E,Goal):-
   dmsg(bugger(show_goal_rethrow(E,Goal))),
   throw(E).




%% on_prolog_ecall( ?F, ?A, ?Var, ?Value) is semidet.
%
% Whenever Prolog Ecall.
%
on_prolog_ecall(F,A,Var,Value):-
  bin_ecall(F,A,Var,Value),!.
on_prolog_ecall(F,A,Var,Value):-
  default_ecall(IfTrue,Var,Value),
  on_prolog_ecall(F,A,IfTrue,true),!.





%% default_ecall( ?VALUE1, ?VALUE2, ?VALUE3) is semidet.
%
% Default Ecall.
%
default_ecall(asis,call,call).
default_ecall(asis,fake_failure,fail).
default_ecall(asis,error,nocatch).

default_ecall(neverfail,call,call).
default_ecall(neverfail,fail,fake_bindings).
default_ecall(neverfail,error,show_goal_rethrow).

default_ecall(onfailure,call,none).
default_ecall(onfailure,fail,reuse).
default_ecall(onfailure,error,none).

default_ecall(onerror,call,none).
default_ecall(onerror,fail,none).
default_ecall(onerror,error,reuse).





%% on_prolog_ecall_override( ?F, ?A, ?Var, ?SentValue, ?Value) is semidet.
%
% Whenever Prolog Ecall Override.
%
on_prolog_ecall_override(F,A,Var,_SentValue, Value):- on_prolog_ecall(F,A,Var,Value), Value \== reuse,!.
on_prolog_ecall_override(_F,_A,_Var, Value, Value).




%% bin_ecall( ?F, ?A, ?VALUE3, ?VALUE4) is semidet.
%
% Bin Ecall.
%
bin_ecall(F,A,unwrap,true):-member(F/A,[(';')/2,(',')/2,('->')/2,('call')/1]).
bin_ecall(F,A,fail,
 throw(never_fail(F/A))):-
   member(F/A,
    [(retractall)/1]).
bin_ecall(F,A,asis,true):-member(F/A,[('must')/1]).


% :- mpred_trace_childs(with_each/2).





%% with_each( ?UPARAM1, :PRED1VALUE2, :Goal) is semidet.
%
% Using Each.
%
with_each(_,_,Call):-var(Call),!,dtrace,randomVars(Call).
% with_each(BDepth,Wrapper,M:Call):- fail,!, '@'( with_each(BDepth,Wrapper,Call), M).

with_each(_,_,Call):-skipWrapper,!,Call.
with_each(BDepth,Wrapper, (X->Y;Z)):- atom(Wrapper),atom_concat('on_f',_,Wrapper),!,(X -> with_each(BDepth,Wrapper,Y) ; with_each(BDepth,Wrapper,Z)).
with_each(N, Wrapper, Call):- N < 1, !, call(Wrapper,Call).
with_each(BDepth,Wrapper, (X->Y;Z)):- with_each(BDepth,Wrapper,X) -> with_each(BDepth,Wrapper,Y) ; with_each(BDepth,Wrapper,Z).
with_each(PDepth,Wrapper, (X , Y)):- BDepth is PDepth-1, !,(with_each(BDepth,Wrapper,X),with_each(BDepth,Wrapper,Y)).
with_each(PDepth,Wrapper, [X | Y]):- BDepth is PDepth-1, !,(with_each(BDepth,Wrapper,X),!,with_each(BDepth,Wrapper,Y)).
with_each(BDepth,Wrapper,Call):-functor_safe(Call,F,A),prolog_ecall_fa(BDepth,Wrapper,F,A,Call).

% :- mpred_trace_childs(with_each/3).

% fake = true



%% prolog_ecall_fa( ?UPARAM1, :PRED1VALUE2, ?F, ?A, :Goal) is semidet.
%
% Prolog Ecall Functor-arity.
%
prolog_ecall_fa(_,_,F,A,Call):-
  on_prolog_ecall(F,A,fake,true),!,
  atom_concat(F,'_FaKe_Binding',FAKE),
  snumbervars(Call,FAKE,0),
  dmsg(error(fake(succeed,Call))),!.

% A=0 , (unwrap = true ; asis = true)
prolog_ecall_fa(_,_,F,0,Call):-
  (on_prolog_ecall(F,0,unwrap,true);on_prolog_ecall(F,0,asis,true)),!,
  call(Call).

% A=1 , (unwrap = true )
prolog_ecall_fa(BDepth,Wrapper,F,1,Call):-
  on_prolog_ecall(F,1,unwrap,true),
  arg(1,Call,Arg),!,
  with_each(BDepth,Wrapper,Arg).

% A>1 , (unwrap = true )
prolog_ecall_fa(BDepth,Wrapper,F,A,Call):-
  on_prolog_ecall(F,A,unwrap,true),!,
  Call=..[F|OArgs],
  functor_safe(Copy,F,A),
  Copy=..[F|NArgs],
  replace_elements(OArgs,E,with_each(BDepth,Wrapper,E),NArgs),
  call(Copy).

% A>1 , (asis = true )
prolog_ecall_fa(_,_,F,A,Call):-
  on_prolog_ecall(F,A,asis,true),!,
  call(Call).

% each = true
prolog_ecall_fa(BDepth,Wrapper,F,A,Call):-
  (on_prolog_ecall(F,A,each,true);BDepth>0),!,
  BDepth1 is BDepth-1,
  predicate_property(Call,number_of_clauses(_Count)),
  % any with bodies
  clause(Call,NT),NT \== true,!,
  clause(Call,Body),
   with_each(BDepth1,Wrapper,Body).

prolog_ecall_fa(_,Wrapper,_F,_A,Call):-
  call(Wrapper,Call).




%% replace_elements( :TermA, ?A, ?B, :TermB) is semidet.
%
% Replace Elements.
%
replace_elements([],_,_,[]):-!.
replace_elements([A|ListA],A,B,[B|ListB]):-replace_elements(ListA,A,B,ListB).




%% prolog_must_l( ?T) is semidet.
%
% Prolog Must Be Successfull (list Version).
%
prolog_must_l(T):-T==[],!.
prolog_must_l([H|T]):-!,must(H), prolog_must_l(T).
prolog_must_l((H,T)):-!,prolog_must_l(H),prolog_must_l(T).
prolog_must_l(H):-must(H).




%% rmust_det( :GoalC) is semidet.
%
% Rmust Deterministic.
%
rmust_det(C):- C *-> true ; dtrace(C).
% rmust_det(C)-  catchv((C *-> true ; debugCallWhy(failed(must(C)),C)),E,debugCallWhy(thrown(E),C)).



%% must_each( :GoalList) is semidet.
%
% Must Be Successfull Each.
%
must_each(List):-var(List),trace_or_throw(var_must_each(List)).
must_each([List]):-!,must(List).
must_each([E|List]):-!,must(E),must_each0(List).



%% must_each0( :TermList) is semidet.
%
% Must Be Successfull Each Primary Helper.
%
must_each0(List):-var(List),trace_or_throw(var_must_each(List)).
must_each0([]):-!.
must_each0([E|List]):-E,must_each0(List).

%=  :- mpred_trace_childs(one_must/2).
:- meta_predicate one_must(0,0,0).



%% one_must( :GoalC1, :GoalC2, :GoalC3) is semidet.
%
% One Must Be Successfull.
%
one_must(C1,C2,C3):-one_must(C1,one_must(C2,C3)).




%% is_deterministic( :TermAtomic) is semidet.
%
% If Is A Deterministic.
%
is_deterministic(once(V)):-var(V),trace_or_throw(is_deterministic(var_once(V))).
is_deterministic(M:G):-atom(M),!,is_deterministic(G).
is_deterministic(Atomic):-atomic(Atomic),!.
is_deterministic(Ground):-ground(Ground),!.
is_deterministic((_,Cut)):-Cut==!.
is_deterministic(_ = _).
is_deterministic(_ =@= _).
is_deterministic(_ =.. _).
is_deterministic(_ == _).
is_deterministic(_ \== _).
is_deterministic(_ \== _).
is_deterministic(atom(_)).
is_deterministic(compound(_)).
is_deterministic(findall(_,_,_)).
is_deterministic(functor_safe(_,_,_)).
is_deterministic(functor_safe(_,_,_)).
is_deterministic(ground(_)).
is_deterministic(nonvar(_)).
is_deterministic(not(_)).
is_deterministic(once(_)).
is_deterministic(var(_)).
%is_deterministic(Call):-predicate_property(Call,nodebug),!.
%is_deterministic(Call):-predicate_property(Call,foreign),!.




% ===============================================================================================
% UTILS
% ===============================================================================================




% = %= :- meta_predicate (time_call(0)).



%% time_call( :Goal) is semidet.
%
% Time Call.
%
time_call(Call):-
  statistics(runtime,[MSecStart,_]),   
  ignore(show_failure(why,Call)),
  statistics(runtime,[MSecEnd,_]),
   MSec is (MSecEnd-MSecStart),
   Time is MSec/1000,
   ignore((Time > 0.5 , dmsg('Time'(Time)=Call))).


% = %= :- meta_predicate (gripe_time(+,0)).
:- export(gripe_time/2).



%% gripe_time( +TooLong, :Goal) is nondet.
%
% Gripe Time.
%

call_for_time(Goal,ElapseCPU,ElapseWALL,Success):- 
   statistics(cputime,StartCPU0),statistics(walltime,[StartWALL0,_]),
   My_Starts = start(StartCPU0,StartWALL0),  
   (Goal*->Success=true;Success=fail),
   statistics(cputime,EndCPU),statistics(walltime,[EndWALL,_]),
   arg(1,My_Starts,StartCPU), ElapseCPU is EndCPU-StartCPU,nb_setarg(1,My_Starts,EndCPU),
   arg(2,My_Starts,StartWALL), ElapseWALL is  (EndWALL-StartWALL)/1000,nb_setarg(2,My_Starts,EndWALL).

gripe_time(_TooLong,Goal):- current_prolog_flag(runtime_speed,0),!,Goal.
gripe_time(_TooLong,Goal):- current_prolog_flag(runtime_debug,0),!,Goal.
gripe_time(_TooLong,Goal):- current_prolog_flag(runtime_debug,1),!,Goal.
% gripe_time(_TooLong,Goal):- \+ current_prolog_flag(runtime_debug,3),\+ current_prolog_flag(runtime_debug,2),!,Goal.
gripe_time(TooLong,Goal):-
 call_for_time(Goal,ElapseCPU,ElapseWALL,Success),
 (ElapseCPU>TooLong -> wdmsg(gripe_CPUTIME(Success,warn(ElapseCPU>TooLong),Goal)) ;
   (ElapseWALL>TooLong -> wdmsg(gripe_WALLTIME(Success,warn(ElapseWALL>TooLong),Goal,cputime=ElapseCPU)) ;
     true)),
  Success.



%% cleanup_strings is semidet.
%
% Cleanup Strings.
%
cleanup_strings:-!.
cleanup_strings:-garbage_collect_atoms.



%=========================================
% Module Utils
%=========================================


:- export(loading_module/1).
:- module_transparent(loading_module/1).
:- export(loading_module/2).
:- module_transparent(loading_module/2).
:- export(show_module/1).
:- module_transparent(show_module/1).




%% loading_module( ?M, ?U) is semidet.
%
% Loading Module.
%
loading_module(M,Why):- quiently(loading_module0(M,Why)).

loading_module0(M,use_module(U)):- if_defined(parent_goal(_:catch(M:use_module(U),_,_),_)).
loading_module0(M,ensure_loaded(U)):- if_defined(parent_goal(_:catch(M:ensure_loaded(U),_,_),_)).
loading_module0(M,consult(F)):- if_defined(parent_goal(_:'$consult_file_2'(F,M,_,_,_),_)).
loading_module0(M,source_location(F)):- source_location(F,_),source_file_property(F,module(M)).
loading_module0(M,file(F)):- prolog_load_context(file,F),source_file_property(F,module(M)).
loading_module0(M,source(F)):- prolog_load_context(source,F),source_file_property(F,module(M)).
loading_module0(M,prolog_load_context):- prolog_load_context(module,M).
loading_module0(M,stream_property(F)):- stream_property(_X,file_name(F)),source_file_property(F,module(M)).
loading_module0(M,source_context_module):- source_context_module(M).





%% prolog_current_frames( ?Each) is semidet.
%
% Prolog Current Frames.
%
prolog_current_frames(Each):- prolog_current_frame(Frame),prolog_current_frame_or_parent(Frame,Each).



%% prolog_current_frame_or_parent( ?Frame, ?Each) is semidet.
%
% Prolog Current Frame Or Parent.
%
prolog_current_frame_or_parent(Frame,Each):- Each=Frame; 
  (prolog_frame_attribute(Frame,parent,Parent),prolog_current_frame_or_parent(Parent,Each)).

:- module_transparent(caller_module(-)).



%% caller_module( ?Module) is semidet.
%
% Caller Module.
%
caller_module(Module):-caller_module(Module,v(function_expansion,func,user,'$toplevel','$apply','$expand')).



%% caller_module( ?Module, ?Skipped) is semidet.
%
% Hook To [t_l:caller_module/2] For Module Logicmoo_util_bugger.
% Caller Module.
%
caller_module(Module,Skipped):- module_stack(Module,_), \+ arg(_,Skipped,Module).

:- module_transparent(module_stack(-,-)).



%% module_stack( ?M, ?VALUE2) is semidet.
%
% Module Stack.
%
module_stack(M,prolog_load_context):- prolog_load_context(module, M).
module_stack(M,'$current_typein_module'):- '$current_typein_module'(M).
module_stack(M,of):- predicate_property(M:of(_,_),imported_from(func)).
module_stack(M,frame):- prolog_current_frames(Each), prolog_frame_attribute(Each,context_module,M).





%% loading_module( ?M) is semidet.
%
% Loading Module.
%
loading_module(M):- (((loading_module(M,_),M\=user));M=user),!.




%% show_module( ?W) is semidet.
%
% Show Module.
%
show_module(W):-dmsg("<!--:~w",[W]),ignore((show_call(why,(loading_module(_,_))),fail)),dmsg("~w:-->",[W]).



% ========================================================================================
% Some prologs have a printf() tCol predicate.. so I made up fmtString/fmt in the Cyc code that calls the per-prolog mechaism
% in SWI it''s formzat/N and sformat/N
% ========================================================================================
:- dynamic(isConsoleOverwritten_bugger/0).




% ===============================================================================================
% unlistify / listify
% ===============================================================================================






%% module_hotrace( ?M) is semidet.
%
% Module Ho Trace.
%
module_hotrace(M):- forall(predicate_property(P,imported_from(M)),mpred_trace_nochilds(M:P)).



% = %= :- meta_predicate (test_tl(1,+)).



%% test_tl( :PRED1Pred, +Term) is semidet.
%
% Test Thread Local.
%
test_tl(Pred,Term):-call(Pred,Term),!.
test_tl(Pred,Term):-compound(Term),functor_safe(Term,F,_),call(Pred,F),!.

% = %= :- meta_predicate (test_tl(+)).



%% test_tl( +C) is semidet.
%
% Test Thread Local.
%
test_tl(M:C):-!,call(M:C).
test_tl(C):-functor(C,F,A),test_tl(C,F,A).

% = %= :- meta_predicate (test_tl(+,+,+)).



%% test_tl( +C, +F, +A) is semidet.
%
% Test Thread Local.
%
test_tl(C,F,A):-current_predicate(baseKB:F/A),call(baseKB:C).
test_tl(C,F,A):-current_predicate(t_l:F/A),call(t_l:C).
test_tl(C,F,A):-current_predicate(t_l_global:F/A),call(t_l_global:C).


% asserta_if_ground(_):- !.



%% asserta_if_ground( ?G) is semidet.
%
% Asserta If Ground.
%
asserta_if_ground(G):- ground(G),asserta(G),!.
asserta_if_ground(_).


% =====================================================================================================================
:- module_hotrace(user).
% =====================================================================================================================

% :- ignore((source_location(File,_Line),module_property(M,file(File)),!,forall(current_predicate(M:F/A),mpred_trace_childs(M:F/A)))).

% :- mpred_trace_childs(must/1).
% :- mpred_trace_childs(must/2).
% :- mpred_trace_childs(must_flag/3).

% though maybe dtrace



%% default_dumptrace( ?VALUE1) is semidet.
%
% Default Dump Trace.
%
default_dumptrace(dtrace).

:- thread_local(is_pushed_def/3).

% = %= :- meta_predicate (push_def(:)).



%% push_def( ?Pred) is semidet.
%
% Push Def.
%
push_def(Pred):-must((get_functor(Pred,F,A),prolog_load_context(file,CurrentFile),
   functor_safe(Proto,F,A))),must(forall(clause(Proto,Body),is_pushed_def(CurrentFile,Proto,Body))),!.

:- meta_predicate(pop_def(:)).



%% pop_def( ?Pred) is semidet.
%
% Pop Def.
%
pop_def(Pred):-must((get_functor(Pred,F,A),prolog_load_context(file,CurrentFile),
   functor_safe(Proto,F,A))),forall(retract(is_pushed_def(CurrentFile,Proto,Body)),assertz((Proto:-Body))),!.





%% show_and_do( :GoalC) is semidet.
%
% Show And Do.
%
show_and_do(C):-wdmsg(show_and_do(C)),!,dtrace,C.




:- module_transparent(nth_pi/2).
:- module_transparent(nth_goal/2).
:- module_transparent(nth_frame/3).
:- module_transparent(nth_frame_attribute/5).



%% nth_pi( ?Nth, ?Value) is semidet.
%
% Nth Predicate Indicator.
%
nth_pi(Nth, Value):- prolog_current_frame(Frame), nth_frame_attribute(Nth,-1, Frame, predicate_indicator, Value).



%% nth_goal( ?Nth, ?Value) is semidet.
%
% Nth Goal.
%
nth_goal(Nth, Value):- prolog_current_frame(Frame), nth_frame_attribute(Nth,-1, Frame, goal, Value).



%% nth_frame( ?Nth, ?Key, ?Value) is semidet.
%
% Nth Frame.
%
nth_frame(Nth, Key, Value):- prolog_current_frame(Frame), nth_frame_attribute(Nth,-1, Frame, Key, Value).



%% nth_frame_attribute( ?Nth, ?NthIn, ?Frame, ?Key, ?Value) is semidet.
%
% Nth Frame Attribute.
%
nth_frame_attribute(Nth,NthIn, Frame, Key, Value):-  
 quietly((
   (NthIn>=0,Nth=NthIn,prolog_frame_attribute(Frame, Key, Value));
   ((prolog_frame_attribute(Frame, parent, ParentFrame),
     NthNext is NthIn + 1, nth_frame_attribute(Nth,NthNext, ParentFrame, Key, Value))))).




%% in_file_expansion is semidet.
%
% In File Expansion.
%
in_file_expansion :- nth_pi(LF,_:'$load_file'/_),nth_pi(TL,'$toplevel':_/0),!,LF<TL, 
  (nth_pi(ED,_:'$execute_directive_3'/_)-> (LF<ED) ; true).




%% in_file_directive is semidet.
%
% In File Directive.
%
in_file_directive :- nth_pi(LF,_:'$load_file'/_),nth_pi(TL,'$toplevel':_/0),!,LF<TL, 
  (nth_pi(ED,_:'$execute_directive_3'/_)-> (LF>ED) ; false).




%% in_toplevel is semidet.
%
% In Toplevel.
%
in_toplevel :- nth_pi(LF,_:'$load_file'/_),nth_pi(TL,'$toplevel':_/0),!,LF>TL, 
  (nth_pi(ED,_:'$execute_directive_3'/_)-> (ED>TL) ; true).



:- dynamic(did_ref_job/1).



%% do_ref_job( :GoalBody, ?Ref) is semidet.
%
% Do Ref Job.
%
do_ref_job(_Body,Ref):-did_ref_job(Ref),!.
do_ref_job(Body ,Ref):-asserta(did_ref_job(Ref)),!,show_call(why,Body).


% bugger_prolog_exception_hook(error(syntax_error(operator_expected),_),_,_,_).



%% bugger_prolog_exception_hook( ?Info, ?VALUE2, ?VALUE3, ?VALUE4) is semidet.
%
% Logic Moo Debugger Prolog Exception Hook.
%
bugger_prolog_exception_hook(Info,_,_,_):- bugger_error_info(Info),!, dumpST,dmsg(prolog_exception_hook(Info)), dtrace.




%% bugger_error_info( ?C) is semidet.
%
% Logic Moo Debugger Error Info.
%
bugger_error_info(C):-contains_var(type_error,C).
bugger_error_info(C):-contains_var(instantiation_error,C).
bugger_error_info(C):-contains_var(existence_error(procedure,_/_),C).



% Installs exception reporter.
:- multifile(user:prolog_exception_hook/4).

:- dynamic(user:prolog_exception_hook/4).

% Writes exceptions with stacktrace into stderr.
% Fail/0 call at the end allows the exception to be
% processed by other hooks too.



%% disabled_this is semidet.
%
% Disabled This.
%
disabled_this:- asserta((user:prolog_exception_hook(Exception, Exception, Frame, _):- 
 \+ current_prolog_flag(no_debug_ST,true),
 set_prolog_flag(no_debug_ST,true),
 get_thread_current_error(ERR),
    (   Exception = error(Term) ;   Exception = error(Term, _)),
    Term \= type_error(number,_), 
    Term \= type_error(character_code,_), 
    Term \= type_error(character,_), 
    Term \= type_error(text,_), 
    Term \= syntax_error(_), 
    Term \= existence_error(procedure,iCrackers1),
    prolog_frame_attribute(Frame,parent,PFrame),
    prolog_frame_attribute(PFrame,goal,Goal),
    format(ERR, 'Error ST-Begin: ~p', [Term]), nl(ERR),
    ignore((lmcache:thread_current_input(main,In),see(In))),
    dumpST,

    dtrace(Goal),
    format(ERR, 'Error ST-End: ~p', [Term]), nl(ERR),
    nl(ERR), fail)),
    set_prolog_flag(no_debug_ST,false).

% :-disabled_this.

:- dynamic(baseKB:no_buggery/0).
% show the warnings origins
:- multifile(user:message_hook/3). 
:- dynamic(user:message_hook/3).
:- thread_local(tlbugger:no_buggery_tl/0).


% :- '$hide'(maybe_leash/1).
% :- '$hide'(quietly/1).
% :- '$hide'('$syspreds':visible/1).
% :- '$hide'('$syspreds':leash/1).
% :- '$hide'(visible/1).
% :- '$hide'(notrace/0).
% :- '$hide'(dtrace/0).
% :-'$set_predicate_attribute'(!, trace, 1).

% :-hideTrace.

%:-module(user).
%:-prolog.

:- retract(double_quotes_was(WAS)),set_prolog_flag(double_quotes,WAS).
% :- mpred_trace_none(locally/2).
% :- '$set_predicate_attribute'(locally(_,_), hide_childs, 0).


% :- '$hide'(tlbugger:_/_).
% :- '$hide'(tlbugger:A/0).

% :- '$hide'(dmsg/1).
% :-'$hide'(system:notrace/1). 



/*

must_det(Level,Goal) :- Goal,  
  (deterministic(true) -> true ; 
    (print_message(Level, assertion_failed(deterministic, Goal)),
       (member(Level,[informational,warn]) -> ! ; assertion_failed(deterministic, Goal)))).



*/

% :- module_property(user, exports(List)),mpred_trace_childs(List).

% :- must((source_context_module(X),!,X==user)).
% :- must(('$set_source_module'(X,X),!,X==user)).

:- '$set_predicate_attribute'(t_l:dont_varname, trace, 0).
:- unlock_predicate(system:true/0).
:- '$set_predicate_attribute'(system:true, trace, 0).
:- lock_predicate(system:true/0).

% 

:- ignore((source_location(S,_),prolog_load_context(module,M),module_property(M,class(library)),
 forall(source_file(M:H,S),
 ignore((functor(H,F,A),
  ignore(((\+ atom_concat('$',_,F),(export(F/A) , current_predicate(system:F/A)->true; system:import(M:F/A))))),
  ignore(((\+ predicate_property(M:H,transparent), module_transparent(M:F/A), \+ atom_concat('__aux',_,F),debug(modules,'~N:- module_transparent((~q)/~q).~n',[F,A]))))))))).

 
 
:- export(logicmoo_bugger_loaded/0).




%% logicmoo_bugger_loaded is semidet.
%
% Logicmoo Logic Moo Debugger Loaded.
%
logicmoo_bugger_loaded.

% :- source_location(S,_),prolog_load_context(module,M),forall(source_file(M:H,S),(functor(H,F,A),M:module_transparent(M:F/A),M:export(M:F/A))).
% :- source_location(S,_),forall(source_file(H,S),(functor(H,F,A),logicmoo_util_bugger:export(logicmoo_util_bugger:F/A),logicmoo_util_bugger:module_transparent(logicmoo_util_bugger:F/A))).


% :- all_module_predicates_are_transparent.
% :- module_predicates_are_exported.
% :- module_meta_predicates_are_transparent(user).
% :- all_module_predicates_are_transparent(logicmoo_util_catch).


% :- mpred_trace_childs(prolog_ecall_fa/5).
% :- mpred_trace_childs(with_each/3).



%= 	 	 

%% dump_st is semidet.
%
% Dump Stack Trace.
%
dump_st:- prolog_current_frame(Frame),dumpST0(Frame,10).


%= 	 	 

%% dumpST0 is semidet.
%
% Dump S True Stucture Primary Helper.
%
dumpST0:- dbreak, 
   prolog_current_frame(Frame),(tracing->quietly((CU=dtrace,notrace));CU=true),dumpST0(Frame,800),!,CU.

%= 	 	 

%% dumpST0( ?Opts) is semidet.
%
% Dump S True Stucture Primary Helper.
%
dumpST0(Opts):- once(nb_current('$dump_frame',Frame);prolog_current_frame(Frame)),dumpST0(Frame,Opts).

%= 	 	 

%% dumpST0( ?Frame, ?MaxDepth) is semidet.
%
% Dump S True Stucture Primary Helper.
%
:- thread_local(tlbugger:ifHideTrace/0).
dumpST0(_,_):- tlbugger:ifHideTrace,!.
dumpST0(Frame,MaxDepth):- ignore(MaxDepth=5000),Term = dumpST(MaxDepth),
   (var(Frame)->once(nb_current('$dump_frame',Frame);prolog_current_frame(Frame));true),
   ignore(( get_prolog_backtrace(MaxDepth, Trace,[frame(Frame),goal_depth(13)]),
    format(user_error, '% dumpST ~p', [Term]), nl(user_error),
    attach_console,dtrace,
    dbreak,

    print_prolog_backtrace(user_error, Trace,[subgoal_positions(true)]), nl(user_error), fail)),!.



% dumpstack_arguments.

%= 	 	 

%% dumpST is semidet.
%
% Dump S True Stucture.
%
dumpST:- quietly((prolog_current_frame(Frame),b_setval('$dump_frame',Frame),dumpST1)).


:- thread_local(tlbugger:no_slow_io/0).
:- multifile(tlbugger:no_slow_io/0).

%= 	 	 

%% dumpST1 is semidet.
%
% Dump S True Stucture Secondary Helper.
%
dumpST1:- current_prolog_flag(dmsg_level,never),!.
dumpST1:- tlbugger:no_slow_io,!,dumpST0,!.
dumpST1:- tlbugger:ifHideTrace,!.
dumpST1:- loop_check_early(dumpST9,dumpST0).

%= 	 	 

%% dumpST( ?Depth) is semidet.
%
% Dump S True Stucture.
%
dumpST(Depth):- quietly((prolog_current_frame(Frame),b_setval('$dump_frame',Frame))),
   loop_check_early(logicmoo_util_dumpst:dumpST9(Depth),dumpST0(Depth)).


%= 	 	 

%% get_m_opt( ?Opts, ?Max_depth, ?D100, ?RetVal) is semidet.
%
% Get Module Opt.
%
get_m_opt(Opts,Max_depth,D100,RetVal):-E=..[Max_depth,V],(((member(E,Opts),nonvar(V)))->RetVal=V;RetVal=D100).



%= 	 	 

%% dumpST9 is semidet.
%
% Dump S T9.
%
dumpST9:- quietly((once(nb_current('$dump_frame',Frame);prolog_current_frame(Frame)), dumpST9(Frame,5000))).

%= 	 	 

%% dumpST9( ?Depth) is semidet.
%
% Dump S T9.
%
dumpST9(Depth):- once(nb_current('$dump_frame',Frame);prolog_current_frame(Frame)), dumpST9(Frame,Depth).


%= 	 	 

%% dumpST9( ?Frame, :TermMaxDepth) is semidet.
%
% Dump S T9.
%
dumpST9(_,_):- tlbugger:ifHideTrace,!.
dumpST9(Frame,MaxDepth):- integer(MaxDepth),!,dumpST_now(Frame,[max_depth(MaxDepth),numbervars(true),show([level,has_alternatives,hidden,context_module,goal,clause])]).
dumpST9(Frame,From-MaxDepth):- integer(MaxDepth),!,dumpST_now(Frame,[skip_depth(From),max_depth(MaxDepth),numbervars(true),show([level,has_alternatives,hidden,context_module,goal,clause])]).
dumpST9(Frame,List):- is_list(List),dumpST_now(Frame,[show([level,has_alternatives,hidden,context_module,goal,clause])|List]).



%= 	 	 

%% drain_framelist( ?Opts) is semidet.
%
% Drain Framelist.
%
drain_framelist(Opts):- repeat, \+ drain_framelist_ele(Opts).


%= 	 	 

%% drain_framelist_ele( ?Opts) is semidet.
%
% Drain Framelist Ele.
%
drain_framelist_ele(Opts):- 
    nb_getval('$current_stack_frame_list',[N-Frame|Next]),
    nb_setval('$current_stack_frame_list',Next),!,
    printFrame(N,Frame,Opts),!.
    
        


%= 	 	 

%% dumpST_now( ?FrameIn, ?Opts) is semidet.
%
% Dump S True Stucture Now.
%
dumpST_now(FrameIn,Opts):-
  once(number(FrameIn);prolog_current_frame(FrameIn)),
   nb_setval('$hide_rest_frames',false),
   b_setval('$current_stack_frame_depth',0),
   b_setval('$current_stack_frame_list',[]),
   get_m_opt(Opts,max_depth,100,MD),
   b_setval('$current_stack_frame_handle',FrameIn),
  (repeat,  
     nb_getval('$current_stack_frame_depth',N),
     nb_getval('$current_stack_frame_handle',Frame),
    ((pushFrame(N,Frame,Opts),MD>N)-> 
     ((prolog_frame_attribute(Frame,parent,ParentFrame)->
       (nb_setval('$current_stack_frame_handle',ParentFrame),
       NN is N +1,nb_setval('$current_stack_frame_depth',NN),fail); !));
     (!))),
   drain_framelist(Opts),!.



%% pushFrame( ?N, ?Frame, ?Opts) is semidet.
%
% Push Frame.
%
pushFrame(N,Frame,_Opts):- nb_getval('$current_stack_frame_list',Current),nb_setval('$current_stack_frame_list',[N-Frame|Current]).


%= 	 	 

%% printFrame( ?N, ?Frame, ?Opts) is semidet.
%
% Print Frame.
%
printFrame(_,_,_):- nb_current('$hide_rest_frames',true),!.
printFrame(N,Frame,Opts):-
  ignore(((frame_to_fmsg(N,Frame,Opts,Out)),must(fmsg_rout(Out)))),!.


%= 	 	 

%% frame_to_fmsg( ?N, ?Frame, ?Opts, ?N) is semidet.
%
% Frame Converted To Functor Message.
%
frame_to_fmsg(N,Frame,Opts,[nf(max_depth,N,Frame,Opts)]):-get_m_opt(Opts,max_depth,100,MD),N>=MD,!,fail.
%  dumpST9(N,Frame,Opts,[nf(max_depth,N,Frame,Opts)]):-get_m_opt(Opts,skip_depth,100,SD),N=<SD,!.
frame_to_fmsg(_,Frame,Opts,[fr(Goal)]):- get_m_opt(Opts,show,goal,Ctrl),getPFA(Frame,Ctrl,Goal),!.
frame_to_fmsg(N,Frame,Opts,[nf(no(Ctrl),N,Frame,Opts)]):- get_m_opt(Opts,show,goal,Ctrl),!.
frame_to_fmsg(N,Frame,Opts,[nf(noFrame(N,Frame,Opts))]).

 


%= 	 	 

%% fmsg_rout( :TermRROut) is semidet.
%
% Functor Message Rout.
%
fmsg_rout([]):-!.
fmsg_rout([fr(E)|_]):- member(goal=GG,E),end_dump(GG),!,ignore(fdmsg(fr(E))),!.
fmsg_rout([fr(E)|_]):- member(goal=GG,E),end_dump(GG),!,ignore(fdmsg(fr(E))),!.
fmsg_rout([E|RROut]):- ignore(fdmsg(E)),!,fmsg_rout(RROut).
fmsg_rout(RROut):- show_call(why,forall(member(E,RROut),fdmsg(E))),!.


%= 	 	 

%% neg1_numbervars( ?Out, ?Start, :GoalROut) is semidet.
%
% Negated Secondary Helper Numbervars.
%
neg1_numbervars(T,-1,T):-!.
neg1_numbervars(Out,false,Out):-!.
neg1_numbervars(Out,true,ROut):-copy_term(Out,ROut),!,snumbervars(ROut,777,_).
neg1_numbervars(Out,Start,ROut):-copy_term(Out,ROut),integer(Start),!,snumbervars(ROut,Start,_).
neg1_numbervars(Out,safe,ROut):-copy_term(Out,ROut),safe_numbervars(ROut).

if_defined_mesg_color(G,C):- current_predicate(mesg_color/2),mesg_color(G,C).

%= 	 	 

%% fdmsg1( ?G) is semidet.
%
% Fdmsg Secondary Helper.
%
fdmsg1(txt(S)):-'format'(S,[]),!.
fdmsg1(level=L):-'format'('(~q)',[L]),!.
fdmsg1(context_module=G):- simplify_m(G,M),!,if_defined_mesg_color(G,Ctrl),ansicall(Ctrl,format('[~w]',[M])),!.
fdmsg1(has_alternatives=G):- (G==false->true;'format'('*',[G])),!.
fdmsg1(hidden=G):- (G==false->true;'format'('$',[G])),!.
fdmsg1(goal=G):-simplify_goal_printed(G,GG),!,if_defined_mesg_color(GG,Ctrl),ansicall(Ctrl,format(' ~q. ',[GG])),!.
fdmsg1(clause=[F,L]):- directory_file_path(_,FF,F),'format'('  %  ~w:~w: ',[FF,L]),!.
fdmsg1(clause=[F,L]):- fresh_line,'format'('%  ~w:~w: ',[F,L]),!.
fdmsg1(clause=[]):-'format'(' /*DYN*/ ',[]),!.
fdmsg1(G):- if_defined_mesg_color(G,Ctrl),ansicall(Ctrl,format(' ~q ',[G])),!.
fdmsg1(M):-dmsg(failed_fdmsg1(M)).



%= 	 	 

%% simplify_m( ?G, ?M) is semidet.
%
% Simplify Module.
%
simplify_m(G,M):-atom(G),sub_atom(G,_,6,0,M),!.
simplify_m(G,G).

%= 	 	 

%% fdmsg( ?M) is semidet.
%
% Fdmsg.
%
fdmsg(fr(List)):-is_list(List),!,must((fresh_line,ignore(forall(member(E,List),fdmsg1(E))),nl)).
fdmsg(M):- logicmoo_util_catch:ddmsg(failed_fdmsg(M)).

:- thread_local(tlbugger:plain_attvars/0).

:-export(simplify_goal_printed/2).

%= 	 	 
printable_variable_name(Var, Name) :- nonvar(Name),!,must(printable_variable_name(Var, NameO)),!,Name=NameO.
printable_variable_name(Var, Name) :- nonvar(Var),Var='$VAR'(_),format(atom(Name),"~w_VAR",Var).
printable_variable_name(Var, Name) :- nonvar(Var),format(atom(Name),"(_~q_)",Var).
printable_variable_name(Var,Name):- (get_attr(Var, vn, Name1);
  get_attr(Var, varnames, Name1)),
 (var_property(Var,name(Name2))-> 
   (Name1==Name2-> atom_concat(Name1,'_VN',Name) ; Name=(Name1:Name2)); 
    (atom(Name1)->atom_concat('?',Name1,Name);
   format(atom(Name),"'$VaR'(~q)",Var))),!.
printable_variable_name(Var,Name):- v_name1(Var,Name),!.
printable_variable_name(Var,Name):- v_name2(Var,Name),!. % ,atom_concat(Name1,'_TL',Name).

v_name1(Var,Name):- var_property(Var,name(Name)),!.
v_name1(Var,Name):- get_varname_list(Vs),member(Name=V,Vs),atomic(Name),V==Var,!.
v_name1(Var,Name):- nb_current('$old_variable_names', Vs),member(Name=V,Vs),atomic(Name),V==Var,!.
v_name2(Var,Name):- get_varname_list(Vs),format(atom(Name),'~W',[Var, [variable_names(Vs)]]).
 

%attrs_to_list(att(sk,_,ATTRS),[sk|List]):-!,attrs_to_list(ATTRS,List).
attrs_to_list(att(vn,_,ATTRS),List):-!,attrs_to_list(ATTRS,List).
attrs_to_list(att(M,V,ATTRS),[M=VV|List]):- locally(tlbugger:plain_attvars,simplify_goal_printed(V,VV)),!,attrs_to_list(ATTRS,List).
attrs_to_list([],[]).
attrs_to_list(_ATTRS,[]).

%% simplify_goal_printed( :TermVar, :TermVar) is semidet.
%
% Simplify Goal Printed.
%

simplify_var_printed(Var,'$avar'('$VAR'(Name))):- tlbugger:plain_attvars,must(printable_variable_name(Var,Name)),!.
simplify_var_printed(Var,'$VAR'(Name)):- get_attrs(Var,att(vn, _, [])),printable_variable_name(Var, Name),!.
simplify_var_printed(Var,'$avar'('$VAR'(Name))):- tlbugger:plain_attvars,must(printable_variable_name(Var,Name)),!.
simplify_var_printed(Var,'$avar'(Dict)):- get_attrs(Var,ATTRS),must(printable_variable_name(Var,Name)),attrs_to_list(ATTRS,List),
                         dict_create(Dict,'$VAR'(Name),List).
simplify_var_printed(Var,'$VAR'(Name)):- is_ftVar(Var),!,printable_variable_name(Var, Name).

simplify_goal_printed(Var,Var):-var(Var),!.
simplify_goal_printed(Var,Name):-cyclic_term(Var),!,Name=Var.
simplify_goal_printed(Var,Name):-is_ftVar(Var),\+ current_prolog_flag(variable_names_bad,true),simplify_var_printed(Var,Name),!.
simplify_goal_printed(Var,Var):-var(Var),!.
simplify_goal_printed(setup_call_catcher_cleanup,scccu).
simplify_goal_printed(existence_error(X,Y),existence_error(X,Y)):-nl,writeq(existence_error(X,Y)),nl,fail.
simplify_goal_printed(setup_call_cleanup,sccu).
simplify_goal_printed(existence_error,'existence_error_XXXXXXXXX__\e[0m\e[1;34m%-6s\e[m\'This is text\e[0mRED__existence_error_existence_error').
simplify_goal_printed(each_call_cleanup,eccu).
simplify_goal_printed(call_cleanup,ccu).
simplify_goal_printed(call_term_expansion(_,A,_,B,_),O):- !, simplify_goal_printed(call_term_expansion_5('...',A,'...',B,'...'),O).
simplify_goal_printed(A,'...'(SA)):- atom(A),atom_concat('/opt/PrologMUD/pack/logicmoo_base/prolog/logicmoo/',SA,A),!.
simplify_goal_printed(A,'...'(SA)):- atom(A),atom_concat('/home/dmiles/lib/swipl/pack/logicmoo_base/prolog/logicmoo/',SA,A),!.
simplify_goal_printed(A,'...'(SA)):- atom(A),atom_concat('/home/dmiles/lib/swipl/pack/logicmoo_base/t/',SA,A),!.
% simplify_goal_printed(A,'...'(SA)):- atom(A),atom_concat('/',_,A),!,directory_file_path(_,SA,A),!.
simplify_goal_printed(GOAL=A,AS):- goal==GOAL,!,simplify_goal_printed(A,AS).
simplify_goal_printed(Var,Var):- \+ compound(Var),!.
simplify_goal_printed(term_position(_,_,_,_,_),'$..term_position/4..$').
%simplify_goal_printed(user:G,GS):-!,simplify_goal_printed(G,GS).
%simplify_goal_printed(system:G,GS):-!,simplify_goal_printed(G,GS).
%simplify_goal_printed(catchv(G,_,_),GS):-!,simplify_goal_printed(G,GS).
%simplify_goal_printed(catch(G,_,_),GS):-!,simplify_goal_printed(G,GS).
%simplify_goal_printed(skolem(V,N,_F),GS):-!,simplify_goal_printed(skeq(V,N,'..'),GS).

simplify_goal_printed('<meta-call>'(G),GS):-!,simplify_goal_printed(G,GS).
simplify_goal_printed(must_det_lm(M,G),GS):-!,simplify_goal_printed(M:must_det_l(G),GS).
simplify_goal_printed(call(G),GS):-!,simplify_goal_printed(G,GS).
simplify_goal_printed(M:G,MS:GS):-atom(M), simplify_m(M,MS),!,simplify_goal_printed(G,GS).
simplify_goal_printed([F|A],[FS|AS]):- !,simplify_goal_printed(F,FS),simplify_goal_printed(A,AS).
simplify_goal_printed(G,GS):- G=..[F|A],maplist(simplify_goal_printed,[F|A],AA),GS=..AA.




%= 	 	 

%% getPFA( ?Frame, ?Ctrl, ?Goal) is semidet.
%
% Get Pred Functor A.
%
getPFA(Frame,[L|List],Goal):- !,findall(R, (member(A,[L|List]),getPFA1(Frame,A,R)) ,Goal).
getPFA(Frame,Ctrl,Goal):-getPFA1(Frame,Ctrl,Goal).


%= 	 	 

%% getPFA1( ?Frame, ?Txt, ?Txt) is semidet.
%
% Get Pred Functor A Secondary Helper.
%
getPFA1(_Frame,txt(Txt),txt(Txt)):-!.
getPFA1(Frame,clause,Goal):-getPFA2(Frame,clause,ClRef),clauseST(ClRef,Goal),!.
getPFA1(Frame,Ctrl,Ctrl=Goal):-getPFA2(Frame,Ctrl,Goal),!.
getPFA1(_,Ctrl,no(Ctrl)).


%= 	 	 

%% getPFA2( ?Frame, ?Ctrl, ?Goal) is semidet.
%
% Get Pred Functor A Extended Helper.
%
getPFA2(Frame,Ctrl,Goal):- catchv((prolog_frame_attribute(Frame,Ctrl,Goal)),E,Goal=[error(Ctrl,E)]),!.


%= 	 	 

%% clauseST( ?ClRef, :TermGoal) is semidet.
%
% Clause S True Stucture.
%
clauseST(ClRef,clause=Goal):- findall(V,(member(Prop,[file(V),line_count(V)]),clause_property(ClRef,Prop)),Goal).

clauseST(ClRef,Goal = HB):- ignore(((clause(Head, Body, ClRef),copy_term(((Head :- Body)),HB)))),
   snumbervars(HB,0,_),
   findall(Prop,(member(Prop,[source(_),line_count(_),file(_),fact,erased]),clause_property(ClRef,Prop)),Goal).


:- thread_local(tlbugger:ifCanTrace/0).


%= 	 	 

%% end_dump( :TermGG) is semidet.
%
% End Dump.
%
end_dump(true):-!,fail.
end_dump(_:GG):-!,end_dump(GG).
end_dump(GG):-compound(GG),functor(GG,F,_),atom_concat(dump,_,F),nb_setval('$hide_rest_frames',true).

% =====================
% dtrace/0/1/2
% =====================

%:- redefine_system_predicate(system:dtrace()).
dtrace:- wdmsg("DUMP_TRACE/0"), (thread_self_main->(dumpST,rtrace);(dumpST(30),abort)).
%= 	 	 

%% dtrace is semidet.
%
% (debug) Trace.
%
%:- redefine_system_predicate(system:dbreak()).

:- thread_local(t_l:no_dbreak/0).
dbreak:- wdmsg("DUMP_BREAK/0"),dumpST,wdmsg("DUMP_BREAK/0"),
  (t_l:no_dbreak -> wdmsg("NO__________________DUMP_BREAK/0") ;
   (thread_self_main->(dumpST,dtrace(system:break),break);true)).

:- thread_local(tlbugger:has_auto_trace/1).
:-meta_predicate(dtrace(0)).

%= 	 	 

%% dtrace( :GoalG) is semidet.
%
% (debug) Trace.
%

dtrace(G):- quietly((tlbugger:has_auto_trace(C),wdmsg(has_auto_trace(C,G)))),!,call(C,G). 
dtrace(G):- strip_module(G,_,dbreak),\+ thread_self_main,!.
% dtrace(G):- quietly((tracing,notrace)),!,wdmsg(tracing_dtrace(G)),
%   scce_orig(notrace,restore_trace((leash(+all),dumptrace_or_cont(G))),trace).

dtrace(G):- quietly((once(((G=dmsg(GG);G=_:dmsg(GG);G=GG),nonvar(GG))),wdmsg(GG)))->true;
 catch(dumptrace1(G),E, handle_dumptrace_signal(G,E)),fail. %always fails
%dtrace(G):- \+ tlbugger:ifCanTrace,!,quietly((wdmsg((not(tlbugger:ifCanTrace(G)))))),!,badfood(G),!,dumpST.
%dtrace(G):- \+ tlbugger:ifCanTrace,!,quietly((wdmsg((not(tlbugger:ifCanTrace(G)))))),!,badfood(G),!,dumpST.
dtrace(G):- 
    catch(dumptrace1(G),E,handle_dumptrace_signal(G,E)).

handle_dumptrace_signal(G,E):-arg(_,v(continue,abort),E),!,wdmsg(continuing(E,G)),notrace,nodebug.
handle_dumptrace_signal(_,E):-throw(E).
%:- export(dumptrace_or_cont/1).
%dumptrace_or_cont(G):- catch(dumptrace(G),E,handle_dumptrace_signal(G,E)).



% :-meta_predicate(dtrace(+,?)).

%= 	 	 

%% dtrace( +MSG, ?G) is semidet.
%
% (debug) Trace.
%
dtrace(MSG,G):-wdmsg(MSG),dtrace(G).


%= 	 	 

%% to_wmsg( :TermG, :TermWG) is semidet.
%
% Converted To Wmsg.
%
to_wmsg(G,WG):- \+ compound(G),!,WG=G.
to_wmsg(M:G,M:WG):-atom(M), to_wmsg(G,WG).
to_wmsg(dmsg(G),WG):-!, to_wmsg(G,WG).
to_wmsg(wdmsg(G),WG):-!, to_wmsg(G,WG).
to_wmsg(G,WG):- (G=WG).


with_source_module(G):-
  '$current_source_module'(M),
  '$current_typein_module'(WM),
  scce_orig('$set_typein_module'(M),G,'$set_typein_module'(WM)).
   


% =====================
% dumptrace/1/2
% =====================
% :-meta_predicate(dumptrace(?)).

%= 	 	 

%% dumptrace( ?G) is semidet.
%
% Dump Trace.
%
dumptrace(G):- non_user_console,!,dumpST_error(non_user_console+dumptrace(G)),abort,fail.
dumptrace(G):-
  locally(set_prolog_flag(gui_tracer, false),
   locally(set_prolog_flag(gui, false),
    locally(flag_call(runtime_debug= false),
     dumptrace0(G)))).

dumptrace0(G):- quietly((tracing,notrace,wdmsg(tracing_dumptrace(G)))),!, catch(((dumptrace0(G) *-> dtrace ; (dtrace,fail))),_,true).
dumptrace0(G):-dumptrace1(G).
dumptrace1(G):-   
  catch(attach_console,_,true),
    repeat, 
    (tracing -> (!,fail) ; true),
    to_wmsg(G,WG),
    fmt(in_dumptrace(G)),
    wdmsg(WG),
    (get_single_char(C)->with_all_dmsg(dumptrace(G,C));throw(cant_get_single_char(!))).

:-meta_predicate(dumptrace(0,+)).

ggtrace:-
  leash(+all),
  visible(+all),
  debug,
  maybe_leash(+exception).

%= 	 	 

%% dumptrace( :GoalG, +C) is semidet.
%
% Dump Trace.
%
dumptrace(_,0'h):- listing(dumptrace/2),!,fail.
dumptrace(_,0'g):-!,dumpST,!,fail.
dumptrace(_,0'G):-!,quietly(dumpST0(500000)),!,fail.
dumptrace(_,0'D):-!,prolog_stack:backtrace(8000),!,fail.
dumptrace(_,0'd):-!,prolog_stack:backtrace(800),!,fail.

dumptrace(G,0'l):-!, 
  restore_trace(( quietly(ggtrace),G)),!,notrace.
%dumptrace(G,0's):-!,quietly(ggtrace),!,(quietly(G)*->true;true).
dumptrace(G,0'S):-!, wdmsg(skipping(G)),!.
dumptrace(_,0'c):-!, throw(continue).
%dumptrace(G,0'i):-!,quietly(ggtrace),!,ignore(G).
dumptrace(_,0'b):-!,debug,break,!,fail.
dumptrace(_,0'a):-!,abort,!,fail.
% dumptrace(_,0'x):-!,must(lex),!,fail.
dumptrace(_,0'e):-!,halt(1),!.
dumptrace(_,0'm):-!,make,fail.
dumptrace(G,0'L):-!,xlisting(G),!,fail.
dumptrace(G,0'l):-!,visible(+all),show_and_do(rtrace(G)).
% dumptrace(G,0'c):-!, show_and_do((G))*->true;true.
dumptrace(G,0'r):-!, stop_rtrace,notrace,nortrace,srtrace,(rtrace((trace,G,notrace))),!,fail.
dumptrace(G,0'f):-!, notrace,(ftrace((G,notrace))),!,fail.
dumptrace(G,0't):-!,visible(+all),leash(+all),trace,!,G.
dumptrace(G,10):-!,dumptrace_ret(G).
dumptrace(G,13):-!,dumptrace_ret(G).
dumptrace(G,Code):- number(Code),char_code(Char,Code),!,dumptrace(G,Char).
dumptrace(_G,'p'):- in_cmt(if_defined(pp_DB,fail)),!,fail.


dumptrace(_,C):-fmt(unused_keypress(C)),!,fail.
% )))))))))))))) %

%= 	 	 

%% dumptrace_ret( ?G) is semidet.
%
% Dump Trace Ret.
%
dumptrace_ret(G):- quietly((leash(+all),visible(+all),visible(+unify),trace)),G.


%% hook_message_hook is semidet.
%
% Hook Message Hook.
%
% hook_message_hook
hook_message_hook:- 
 asserta((
 
%  current_predicate(logicmoo_bugger_loaded/0)

user:message_hook(Term, Kind, Lines):- 
 quietly(( 
 loop_check((ignore((
 tlbugger:rtracing,
 \+ \+ 
 catch(((
 (Kind= warning;Kind= error), 
 Term\=syntax_error(_), 
 backtrace(40), \+ baseKB:no_buggery, \+ tlbugger:no_buggery_tl,
 stop_rtrace,trace,
  dmsg(message_hook(Term, Kind, Lines)),quietly(dumpST(10)),dmsg(message_hook(Term, Kind, Lines)),
   !,fail,
   (sleep(1.0),read_pending_codes(user_input, Chars, []), format(error_error, '~s', [Chars]),flush_output(error_error),!,Chars=[C],
                dtrace(true,C),!),

   fail)),_,true))),fail)))))).

% have to load this module here so we dont take ownership of prolog_exception_hook/4.
% :- load_files(library(prolog_stack), [silent(true)]).
%prolog_stack:stack_guard(none).

% :-hook_message_hook.

%user:prolog_exception_hook(A,B,C,D):- fail,
%   once(copy_term(A,AA)),catchv(( once(bugger_prolog_exception_hook(AA,B,C,D))),_,fail),fail.




:- multifile
        term_color0/2.
:- meta_predicate
    %    must(0),
        must_once(0),
        must_det(0),
        nop(*),
        sanity(0),
        scce_orig(0,0,0),
        ansicall(?, 0),
        ansicall(?, ?, 0),
        ansicall0(?, ?, 0),
        ansicall1(?, ?, 0),
        fmt_ansi(0),
        if_color_debug(0),
        if_color_debug(0, 0),
        in_cmt(0),
        keep_line_pos_w_w(?, 0),        
        prepend_each_line(?, 0),
        to_stderror(0),
        with_all_dmsg(0),
        with_current_indent(0),
        with_dmsg(?, 0),
        with_no_dmsg(0),
        with_no_dmsg(?, 0),
        with_output_to_console(0),
        with_output_to_main(0),
        with_output_to_stream(?, 0),
        with_show_dmsg(?, 0).

:- meta_predicate if_defined_local(:,0).
if_defined_local(G,Else):- current_predicate(_,G)->G;Else.

:- module_transparent
        ansi_control_conv/2,
        ansifmt/2,
        ansifmt/3,
        colormsg/2,
        contrasting_color/2,
        defined_message_color/2,
        dfmt/1,
        dfmt/2,
        dmsg/3,
        dmsg0/1,
        dmsg0/2,
        dmsg1/1,
        dmsg2/1,
        dmsg3/1,
        dmsg4/1,
        dmsg5/1,
        dmsg5/2,
        dmsg_hide/1,
        dmsg_hides_message/1,
        dmsg_show/1,
        dmsg_showall/1,
        dmsg_text_to_string_safe/2,
        dmsginfo/1,

        with_output_to_each/2,
        f_word/2,
        fg_color/2,
        flush_output_safe/0,
        flush_output_safe/1,
        fmt/1,
        fmt/2,
        fmt/3,
        fmt0/1,
        fmt0/2,
        fmt0/3,
        fmt9/1,
        fmt_or_pp/1,
        fmt_portray_clause/1,
        functor_color/2,
        get_indent_level/1,
        good_next_color/1,
        if_color_debug/0,
        indent_e/1,
        indent_to_spaces/2,
        is_sgr_on_code/1,
        is_tty/1,
        last_used_fg_color/1,
        mesg_arg1/2,
        
        msg_to_string/2,
        next_color/1,
        portray_clause_w_vars/1,
        portray_clause_w_vars/2,
        portray_clause_w_vars/3,
        portray_clause_w_vars/4,
        predef_functor_color/2,
        print_prepended/2,
        print_prepended_lines/2,
        random_color/1,
        sformat/4,
        sgr_code_on_off/3,
        sgr_off_code/2,
        sgr_on_code/2,
        sgr_on_code0/2,
        tst_color/0,
        tst_color/1,
        tst_fmt/0,
        unliked_ctrl/1,
        vdmsg/2,
        withFormatter/4,
        writeFailureLog/2.
:- dynamic
        defined_message_color/2,
        term_color0/2.


:- if(current_predicate(lmcode:combine_logicmoo_utils/0)).
:- module(logicmoo_util_dmsg,
[  % when the predciates are not being moved from file to file the exports will be moved here
       ]).

:- else.

:- endif.


% :- abolish(system:nop/1),asserta(system:nop(_)).

getenv_safe(Name,ValueO,Default):-
   (getenv(Name,RV)->Value=RV;Value=Default),
    (number(Default)->( \+ number(Value) -> atom_number(Value,ValueO); Value=ValueO);(Value=ValueO)).

qdmsg(M):-compound(M),functor(M,F,_),!,debug(logicmoo(F),'~q',[M]).
qdmsg(M):-debug(logicmoo(M),'QMSG: ~q',[M]).

%= 	 	 

%% alldiscontiguous is semidet.
%
% Alldiscontiguous.
%
alldiscontiguous:-!.


%= 	 	 

%% source_context_module( ?CM) is semidet.
%
% Source Context Module.
%
source_context_module(M):- source_context_module0(M),M\==user, \+ '$current_typein_module'(M),!.
source_context_module(M):- source_context_module0(M),M\==user,!.
source_context_module(M):- source_context_module0(M).

source_context_module0(M):- context_module(M).
source_context_module0(M):- prolog_load_context(module, M).
source_context_module0(M):- '$current_typein_module'(M).



:-export(on_x_fail/1).
%% on_x_fail( :Goal) is semidet.
%
% If there If Is an exception in :Goal just fail
%
on_x_fail(Goal):- catchv(Goal,_,fail).


%================================================================
% pred tracing 
%================================================================

% = :- meta_predicate('match_predicates'(:,-)).


%= 	 	 

%% match_predicates( ?MSpec, -MatchesO) is semidet.
%
% Match Predicates.
%
match_predicates(M:Spec,Preds):- catch('$find_predicate'(M:Spec, Preds),_,catch('$find_predicate'(Spec, Preds),_,catch('$find_predicate'(baseKB:Spec, Preds),_,fail))),!.
match_predicates(MSpec,MatchesO):- catch('$dwim':'$find_predicate'(MSpec,Matches),_,Matches=[]),!,MatchesO=Matches.


%= 	 	 

%% match_predicates( ?Spec, -M, -P, -F, -A) is semidet.
%
% Match Predicates.
%
match_predicates(_:[],_M,_P,_F,_A):-!,fail.
match_predicates(IM:(ASpec,BSpec),M,P,F,A):-!, (match_predicates(IM:(ASpec),M,P,F,A);match_predicates(IM:(BSpec),M,P,F,A)).
match_predicates(IM:[ASpec|BSpec],M,P,F,A):-!, (match_predicates(IM:(ASpec),M,P,F,A);match_predicates(IM:(BSpec),M,P,F,A)).
match_predicates(IM:IF/IA,M,P,F,A):- '$find_predicate'(IM:P,Matches),member(CM:F/A,Matches),functor(P,F,A),(predicate_property(CM:P,imported_from(M))->true;CM=M),IF=F,IA=A.
match_predicates(Spec,M,P,F,A):- '$find_predicate'(Spec,Matches),member(CM:F/A,Matches),functor(P,F,A),(predicate_property(CM:P,imported_from(M))->true;CM=M).

:- module_transparent(if_may_hide/1).
% = :- meta_predicate(if_may_hide(0)).
%if_may_hide(_G):-!.

%= 	 	 

%% if_may_hide( :GoalG) is semidet.
%
% If May Hide.
%
if_may_hide(G):-G.

:- meta_predicate with_unlocked_pred(:,0).

%= 	 	 

%% with_unlocked_pred( ?Pred, :Goal) is semidet.
%
% Using Unlocked Predicate.
%
with_unlocked_pred(Pred,Goal):-
   (predicate_property(Pred,foreign)-> true ;
  (
 ('$get_predicate_attribute'(Pred, system, 0) -> Goal ;
 ('$set_predicate_attribute'(Pred, system, 0),
   catch(Goal,_,true),'$set_predicate_attribute'(Pred, system, 1))))).



:- export(mpred_trace_less/1).

%= 	 	 

%% mpred_trace_less( ?W) is semidet.
%
% Managed Predicate  Trace less.
%
mpred_trace_less(W):- if_may_hide(forall(match_predicates(W,M,Pred,_,_),(
with_unlocked_pred(M:Pred,(
  '$set_predicate_attribute'(M:Pred, noprofile, 1),
  (A==0 -> '$set_predicate_attribute'(M:Pred, hide_childs, 1);'$set_predicate_attribute'(M:Pred, hide_childs, 1)),
  (A==0 -> '$set_predicate_attribute'(M:Pred, trace, 0);'$set_predicate_attribute'(M:Pred, trace, 1))))))).

:- export(mpred_trace_none/1).

%= 	 	 

%% mpred_trace_none( ?W) is semidet.
%
% Managed Predicate  Trace none.
%
mpred_trace_none(W):- (forall(match_predicates(W,M,Pred,F,A),
  with_unlocked_pred(M:Pred,(('$hide'(M:F/A),'$set_predicate_attribute'(M:Pred, hide_childs, 1),noprofile(M:F/A),nop(nospy(M:Pred))))))).

:- export(mpred_trace_nochilds/1).

%= 	 	 

%% mpred_trace_nochilds( ?W) is semidet.
%
% Managed Predicate  Trace nochilds.
%
mpred_trace_nochilds(W):- if_may_hide(forall(match_predicates(W,M,Pred,_,_),(
with_unlocked_pred(M:Pred,(
'$set_predicate_attribute'(M:Pred, trace, 1),
'$set_predicate_attribute'(M:Pred, noprofile, 0),
'$set_predicate_attribute'(M:Pred, hide_childs, 1)))))).

:- export(mpred_trace_childs/1).



%% mpred_trace_childs( ?W) is semidet.
%
% Managed Predicate  Trace childs.
%
mpred_trace_childs(W) :- if_may_hide(forall(match_predicates(W,M,Pred,_,_),(
with_unlocked_pred(M:Pred,(
'$set_predicate_attribute'(M:Pred, trace, 0),
'$set_predicate_attribute'(M:Pred, noprofile, 1),
'$set_predicate_attribute'(M:Pred, hide_childs, 0)))))).   


%= 	 	 

%% mpred_trace_all( ?W) is semidet.
%
% Managed Predicate  Trace all.
%
mpred_trace_all(W) :- forall(match_predicates(W,M,Pred,_,A),( 
 with_unlocked_pred(M:Pred,(
 (A==0 -> '$set_predicate_attribute'(M:Pred, trace, 0);'$set_predicate_attribute'(M:Pred, trace, 1)),
 '$set_predicate_attribute'(M:Pred, noprofile, 0),
'$set_predicate_attribute'(M:Pred, hide_childs, 0))))).

%:-mpred_trace_all(prolog:_).
%:-mpred_trace_all('$apply':_).
%:-mpred_trace_all(system:_).

:- set_module(class(library)).


:- thread_local(tlbugger:ifHideTrace/0).
:- export(tlbugger:ifHideTrace/0).



%% oncely_clean(Goal)
%
% throws an exception if Goal leaves choicepoints or
% if goal fails
oncely_clean(Goal):- 
 '$sig_atomic'((Goal,assertion(deterministic(true))))
  ->true;
   throw(failed_oncely_clean(Goal)).



%= 	 	 

%% term_to_string( ?IS, ?I) is semidet.
%
% Hook To [pldoc_html:term_to_string/2] For Module Logicmoo_util_first.
% Term Converted To String.
%
term_to_string(IS,I):- on_x_fail(term_string(IS,I)),!.
term_to_string(I,IS):- on_x_fail(string_to_atom(IS,I)),!.
term_to_string(I,IS):- rtrace(term_to_atom(I,A)),string_to_atom(IS,A),!.


:- meta_predicate mustvv(0).

%= 	 	 

%% mustvv( :GoalG) is semidet.
%
% Mustvv.
%
mustvv(G):-must(G).

%:- export(unnumbervars/2).
% unnumbervars(X,YY):- lbl_vars(_,_,X,[],Y,_Vs),!, mustvv(YY=Y).
% TODO compare the speed
% unnumbervars(X,YY):- mustvv(unnumbervars0(X,Y)),!,mustvv(Y=YY).


get_varname_list(VsOut):- nb_current('$variable_names',Vs),!,check_variable_names(Vs,VsOut),!.
get_varname_list([]).
set_varname_list(VsIn):- check_variable_names(VsIn,Vs),
  b_setval('$variable_names',[]),
  dupe_term(Vs,VsD),
  nb_linkval('$variable_names',VsD).

add_var_to_env(NameS,Var):-
   ((is_list(NameS);string(NameS))->name(Name,NameS);NameS=Name),
   get_varname_list(VsIn),
   add_var_to_list(Name,Var,VsIn,NewName,NewVar,NewVs),
   (NewName\==Name -> put_attr(Var, vn, NewName) ; true),
   (NewVar \==Var  -> put_attr(NewVar, vn, Name) ; true),
   (NewVs  \==VsIn -> put_variable_names(NewVs) ; true).
   

%% add_var_to_list(Name,Var,Vs,NewName,NewVar,NewVs) is det.
add_var_to_list(Name,Var,Vs,NewName,NewVar,NewVs):- member(N0=V0,Vs), Var==V0,!,
            (Name==N0 -> ( NewName=Name,NewVar=Var, NewVs=Vs ) ;  ( NewName=N0,NewVar=Var,NewVs=[Name=Var|Vs])),!.
% a current name but points to a diffentrt var
add_var_to_list(Name,Var,Vs,NewName,NewVar,NewVs):- member(Name=_,Vs),
              length(Vs,Len),atom_concat(Name,Len,NameAgain0),( \+ member(NameAgain0=_,Vs)-> NameAgain0=NameAgain ; gensym(Name,NameAgain)),
              NewName=NameAgain,NewVar=Var, 
              NewVs=[NewName=NewVar|Vs],!.
add_var_to_list(Name,Var,Vs,NewName,NewVar,NewVs):-  
  NewName=Name,NewVar=Var,NewVs=[Name=Var|Vs],!.


%= 	 	 

%% unnumbervars( ?X, ?Y) is semidet.
%
% Unnumbervars.
%
% unnumbervars(STUFF,UN):-sformat(S,'~W',[STUFF,[quoted(true),character_escapes(true),module(user),numbervars(true),portray(false),double_quotes(true)]]),string_to_atom(S,Atom),atom_to_term(Atom,UN,_).
unnumbervars(X,Y):- must(quietly(unnumbervars_and_save(X,Y))).


put_variable_names(NewVs):-  check_variable_names(NewVs,Checked),call(b_setval,'$variable_names',Checked).
nput_variable_names(NewVs):- check_variable_names(NewVs,Checked),call(nb_setval,'$variable_names',Checked).

check_variable_names(I,O):- (\+ (member(N=_,I),var(N)) -> O=I ; 
   (set_prolog_flag(variable_names_bad,true),trace_or_throw(bad_check_variable_names))).

%= 	 	 

%% unnumbervars_and_save( ?X, ?YO) is semidet.
%
% Unnumbervars And Save.
%

unnumbervars_and_save(X,YO):- must(quietly(unnumbervars4(X,[],_,YO))),!.
% unnumbervars_and_save(X,YO):- \+ ((sub_term(V,X),compound(V),'$VAR'(_)=V)),!,YO=X.

/*
unnumbervars_and_save(X,YO):- (get_varname_list(Vs)->true;Vs=[]),unnumbervars4(X,Vs,NewVs,YO),!,
   (NewVs  \==Vs   -> put_variable_names(NewVs) ; true).
unnumbervars_and_save(X,YO):-
 term_variables(X,TV),
 mustvv((source_variables_l(Vs),
   with_output_to(string(A),write_term(X,[numbervars(true),variable_names(Vs),character_escapes(true),ignore_ops(true),quoted(true)])))),
   mustvv(atom_to_term(A,Y,NewVs)),
   (NewVs==[]-> YO=X ; (length(TV,TVL),length(NewVs,NewVarsL),(NewVarsL==TVL-> (YO=X) ; (add_newvars(NewVs),YO=Y)))).
*/

%% unnumbervars4(TermIn,VsIn,NewVs,TermOut) is det.
%
% Unnumbervars And Save.
%
unnumbervars4(Var,Vs,Vs,Var):- \+ compound(Var),!.
unnumbervars4((I,TermIn),VsIn,NewVs,(O,TermOut)):- !,unnumbervars4(I,VsIn,VsM,O),unnumbervars4(TermIn,VsM,NewVs,TermOut).
unnumbervars4((I:TermIn),VsIn,NewVs,(O:TermOut)):- !,unnumbervars4(I,VsIn,VsM,O),unnumbervars4(TermIn,VsM,NewVs,TermOut).
unnumbervars4([I|TermIn],VsIn,NewVs,[O|TermOut]):- !,unnumbervars4(I,VsIn,VsM,O),unnumbervars4(TermIn,VsM,NewVs,TermOut).
unnumbervars4('$VAR'(Name),VsIn,NewVs,Var):- nonvar(Name),!, (member(Name=Var,VsIn)->NewVs=VsIn;NewVs=[Name=Var|VsIn]),!,put_attr(Var,vn,Name).
unnumbervars4(PTermIn,VsIn,NewVs,PTermOut):- compound_name_arguments(PTermIn,F,TermIn),unnumbervars4(TermIn,VsIn,NewVs,TermOut),compound_name_arguments(PTermOut,F,TermOut).
   

 

/*

unnumbervars_and_save(X,YO):-
 term_variables(X,TV),
 mustvv((source_variables_l(Vs),
   with_output_to(string(A),write_term(X,[numbervars(true),variable_names(Vs),character_escapes(true),ignore_ops(true),quoted(true)])))),
   mustvv(atom_to_term(A,Y,NewVs)),
   (NewVs==[]-> YO=X ; (length(TV,TVL),length(NewVs,NewVarsL),(NewVarsL==TVL-> (YO=X) ; (dtrace,add_newvars(NewVs),Y=X)))).


:- export(unnumbervars_and_save/2).
unnumbervars_and_save(X,YY):-
   lbl_vars(_,_,X,[],Y,Vs),
    (Vs==[]->mustvv(X=YY);
    ( % writeq((lbl_vars(N,NN,X,Y,Vs))),nl,
     save_clause_vars(Y,Vs),mustvv(Y=YY))).

% todo this slows the system!
unnumbervars0(X,clause(UH,UB,Ref)):- sanity(nonvar(X)),
  X = clause(H,B,Ref),!,
  mustvv(unnumbervars0((H:-B),(UH:-UB))),!.

unnumbervars0(X,YY):-lbl_vars(N,NN,X,YY,_Vs).

lbl_vars(N,NN,X,YY):-
   must_det_l((with_output_to(string(A),write_term(X,[snumbervars(true),character_escapes(true),ignore_ops(true),quoted(true)])),
   atom_to_term(A,Y,_NewVars),!,mustvv(YY=Y))),check_varnames(YY).
lbl_vars(N,NN,X,YY,Vs):-!,lbl_vars(N,NN,X,[],YY,Vs).

lbl_vars(S1,S1,A,OVs,A,OVs):- atomic(A),!.
lbl_vars(S1,S1,Var,IVs,Var,OVs):- attvar(Var),get_attr(Var,logicmoo_varnames,Nm), (memberchk(Nm=PreV,IVs)->(OVs=IVs,mustvv(PreV==Var));OVs=[Nm=Var|IVs]).
lbl_vars(S1,S2,Var,IVs,Var,OVs):- var(Var),!,(\+number(S1)->true;(((member(Nm=PreV,IVs),Var==PreV)->(OVs=IVs,put_attr(Var,logicmoo_varnames,Nm));
  (format(atom(Nm),'~q',['$VAR'(S1)]),S2 is S1+1,(memberchk(Nm=Var,IVs)->OVs=IVs;OVs=[Nm=Var|IVs]))))).

lbl_vars(S1,S1,NC,OVs,NC,OVs):- ( \+ compound(NC)),!.
lbl_vars(S1,S1,'$VAR'(Nm),IVs,PreV,OVs):-  atom(Nm), !, must(memberchk(Nm=PreV,IVs)->OVs=IVs;OVs=[Nm=PreV|IVs]).
lbl_vars(S1,S1,'$VAR'(N0),IVs,PreV,OVs):- (number(N0)->format(atom(Nm),'~q',['$VAR'(N0)]);Nm=N0), (memberchk(Nm=PreV,IVs)->OVs=IVs;OVs=[Nm=PreV|IVs]).
lbl_vars(S1,S3,[X|XM],IVs,[Y|YM],OVs):-!,lbl_vars(S1,S2,X,IVs,Y,VsM),lbl_vars(S2,S3,XM,VsM,YM,OVs).
lbl_vars(S1,S2,XXM,VsM,YYM,OVs):- XXM=..[F|XM],lbl_vars(S1,S2,XM,VsM,YM,OVs),!,YYM=..[F|YM].

*/

/*
lbl_vars(N,NN,X,YY,Vs):-
 must_det_l((
   with_output_to(codes(A),write_term(X,[numbervars(true),character_escapes(true),ignore_ops(true),quoted(true)])),   
   read_term_from_codes(A,Y,[variable_names(Vs),character_escapes(true),ignore_ops(true)]),!,mustvv(YY=Y),check_varnames(YY))).




unnumbervars_and_copy(X,YO):-
 term_variables(X,TV),
 mustvv((source_variables(Vs),
   with_output_to(string(A),write_term(X,[numbervars(true),variable_names(Vs),character_escapes(true),ignore_ops(true),quoted(true)])))),
   mustvv(atom_to_term(A,Y,NewVs)),
   (NewVs==[]-> YO=X ; (length(TV,TVL),length(NewVs,NewVarsL),(NewVarsL==TVL-> (YO=X) ; (dtrace,add_newvars(NewVs),Y=X)))).
*/

%add_newvars(_):-!.

%= 	 	 

%% add_newvars( :TermVs) is semidet.
%
% Add Newvars.
%
add_newvars(Vs):- (var(Vs);Vs=[]),!.
add_newvars([N=V|Vs]):- add_newvar(N,V), (var(V)->put_attr(V,vn,N);true), !,add_newvars(Vs).



%= 	 	 

%% add_newvar( ?VALUE1, ?V) is semidet.
%
% Add Newvar.
%
add_newvar(_,V):-nonvar(V),!.
add_newvar(N,_):-var(N),!.
add_newvar('A',_):-!.
add_newvar('B',_):-!.
add_newvar(N,_):- atom(N),atom_concat('_',_,N),!.
add_newvar(N,V):- 
  (get_varname_list(V0s)->true;V0s=[]),
  remove_grounds(V0s,Vs),
 once((member(NN=Was,Vs),N==NN,var(Was),var(V),(Was=V))-> (V0s==Vs->true;set_varname_list(Vs)); set_varname_list([N=V|Vs])).


%= 	 	 

%% remove_grounds( :TermVs, :TermVs) is semidet.
%
% Remove Grounds.
%
remove_grounds(Vs,Vs):-var(Vs),!.
remove_grounds([],[]):-!.
remove_grounds([N=V|NewCNamedVarsS],NewCNamedVarsSG):-
   (N==V;ground(V)),remove_grounds(NewCNamedVarsS,NewCNamedVarsSG).
remove_grounds([N=V|V0s],[N=NV|Vs]):-
   (var(V) -> NV=V ; NV=_ ),
   remove_grounds(V0s,Vs).

% renumbervars_prev(X,X):-ground(X),!.

%= 	 	 

%% renumbervars_prev( ?X, ?Y) is semidet.
%
% Renumbervars Prev.
%
renumbervars_prev(X,Y):-renumbervars1(X,[],Y,_),!.
renumbervars_prev(X,Z):-unnumbervars(X,Y),safe_numbervars(Y,Z),!.
renumbervars_prev(Y,Z):-safe_numbervars(Y,Z),!.



%= 	 	 

%% renumbervars1( ?X, ?Y) is semidet.
%
% Renumbervars Secondary Helper.
%
renumbervars1(X,Y):-renumbervars1(X,[],Y,_).


%= 	 	 

%% renumbervars1( :TermV, ?IVs, :TermX, ?Vs) is semidet.
%
% Renumbervars Secondary Helper.
%
renumbervars1(V,IVs,'$VAR'(X),Vs):- var(V), sformat(atom(X),'~w_RNV',[V]), !, (memberchk(X=V,IVs)->Vs=IVs;Vs=[X=V|IVs]).
renumbervars1(X,Vs,X,Vs):- ( \+ compound(X)),!.
renumbervars1('$VAR'(V),IVs,Y,Vs):- sformat(atom(X),'~w_VAR',[V]), !, (memberchk(X=Y,IVs)->Vs=IVs;Vs=[X=Y|IVs]).
renumbervars1([X|XM],IVs,[Y|YM],Vs):-!,
  renumbervars1(X,IVs,Y,VsM),
  renumbervars1(XM,VsM,YM,Vs).
renumbervars1(XXM,IVs,YYM,Vs):-
  XXM=..[F,X|XM],
  renumbervars1(X,IVs,Y,VsM),
  renumbervars1(XM,VsM,YM,Vs),
  YYM=..[F,Y|YM].



  
% ========================================================================================
% safe_numbervars/1 (just simpler safe_numbervars.. will use a random start point so if a partially numbered getPrologVars wont get dup getPrologVars)
% Each prolog has a specific way it could unnumber the result of a safe_numbervars
% ========================================================================================
% 7676767

%= 	 	 

%% safe_numbervars( ?E, ?EE) is semidet.
%
% Safely Paying Attention To Corner Cases Numbervars.
%
safe_numbervars(E,EE):-dupe_term(E,EE),
  get_gtime(G),numbervars(EE,G,End,[attvar(skip),functor_name('$VAR'),singletons(true)]),
  term_variables(EE,AttVars),
  numbervars(EE,End,_,[attvar(skip),functor_name('$VAR'),singletons(true)]),
  forall(member(V,AttVars),(copy_term(V,VC,Gs),V='$VAR'(VC=Gs))),check_varnames(EE).


%= 	 	 

%% get_gtime( ?GG) is semidet.
%
% Get Gtime.
%
get_gtime(GG):- get_time(T),convert_time(T,_A,_B,_C,_D,_E,_F,G),GG is (floor(G) rem 500).


%= 	 	 

%% safe_numbervars( ?EE) is semidet.
%
% Safely Paying Attention To Corner Cases Numbervars.
%
safe_numbervars(EE):-get_gtime(G),numbervars(EE,G,_End,[attvar(skip),functor_name('$VAR'),singletons(true)]),check_varnames(EE).




% register_var(?, ?, ?)
%
%   During copying one has to remeber copies of variables which can be used further during copying.
%   Therefore the register of variable copies is maintained.
%

%= 	 	 

%% register_var( :TermN, ?IN, ?OUT) is semidet.
%
% Register Variable.
%
register_var(N=V,IN,OUT):- (var(N)->true;register_var(N,IN,V,OUT)),!.


%= 	 	 

%% register_var( ?N, ?T, ?V, ?OUTO) is semidet.
%
% Register Variable.
%
register_var(N,T,V,OUTO):-register_var_0(N,T,V,OUT),mustvv(OUT=OUTO),!.
register_var(N,T,V,O):-append(T,[N=V],O),!.


%= 	 	 

%% register_var_0( ?N, ?T, ?V, ?OUT) is semidet.
%
% register Variable  Primary Helper.
%
register_var_0(N,T,V,OUT):- atom(N),is_list(T),member(NI=VI,T),atom(NI),N=NI,V=@=VI,samify(V,VI),!,OUT=T.
register_var_0(N,T,V,OUT):- atom(N),is_list(T),member(NI=VI,T),atom(NI),N=NI,V=VI,!,OUT=T.

register_var_0(N,T,V,OUT):- mustvv(nonvar(N)),
   ((name_to_var(N,T,VOther)-> mustvv((OUT=T,samify(V,VOther)));
     ((get_varname_list(Before)->true;Before=[]),
      (name_to_var(N,Before,VOther)  -> mustvv((samify(V,VOther),OUT= [N=V|T]));
         (var_to_name(V,T,_OtherName)                  -> OUT= [N=V|T];
           (var_to_name(V,Before,_OtherName)              -> OUT= [N=V|T];fail)))))),!.


register_var_0(N,T,V,OUT):- var(N),
   (var_to_name(V,T,N)                -> OUT=T;
     ((get_varname_list(Before)->true;Before=[]),
          (var_to_name(V,Before,N)   -> OUT= [N=V|T];
               OUT= [N=V|T]))),!.





% different variables (now merged)

%= 	 	 

%% samify( ?V, ?V0) is semidet.
%
% Samify.
%
samify(V,V0):-var(V),var(V0),!,mustvv(V=V0).
samify(V,V0):-mustvv(V=@=V0),V=V0. 


%= 	 	 

%% var_to_name( ?V, :TermN, ?N) is semidet.
%
% Variable Converted To Name.
%
var_to_name(V,[N=V0|T],N):-
    V==V0 -> true ;          % same variables
    var_to_name(V,T,N).


%= 	 	 

%% name_to_var( ?N, :TermT, ?V) is semidet.
%
% Name Converted To Variable.
%
name_to_var(N,T,V):- var(N),!,var_to_name(N,T,V).
name_to_var(N,[N0=V0|T],V):- 
   N0==N -> samify(V,V0) ; name_to_var(N,T,V).


/*
% ===================================================================
% Safely number vars
% ===================================================================
bugger_numbervars_with_names(Term):-
   term_variables(Term,Vars),bugger_name_variables(Vars),!,snumbervars(Vars,91,_,[attvar(skip),singletons(true)]),!,

bugger_name_variables([]).
bugger_name_variables([Var|Vars]):-
   (var_property(Var, name(Name)) -> Var = '$VAR'(Name) ; true),
   bugger_name_variables(Vars).

*/
:- export(snumbervars/1).

%= 	 	 

%% snumbervars( ?Term) is semidet.
%
% Snumbervars.
%
snumbervars(Term):-snumbervars(Term,0,_).

:- export(snumbervars/3).

%= 	 	 

%% snumbervars( ?Term, ?Start, ?End) is semidet.
%
% Snumbervars.
%
snumbervars(Term,Start,End):- integer(Start),var(End),!,snumbervars(Term,Start,End,[]).
snumbervars(Term,Start,List):- integer(Start),is_list(List),!,snumbervars(Term,Start,_,List).
snumbervars(Term,Functor,Start):- integer(Start),atom(Functor),!,snumbervars(Term,Start,_End,[functor_name(Functor)]).
snumbervars(Term,Functor,List):- is_list(List),atom(Functor),!,snumbervars(Term,0,_End,[functor_name(Functor)]).


:- export(snumbervars/4).

%= 	 	 

%% snumbervars( ?Term, ?Start, ?End, ?List) is semidet.
%
% Snumbervars.
%
snumbervars(Term,Start,End,List):-numbervars(Term,Start,End,List).








%= 	 	 

%% module_predicate( ?ModuleName, ?P, ?F, ?A) is semidet.
%
% Module Predicate.
%
module_predicate(ModuleName,P,F,A):-current_predicate(ModuleName:F/A),functor_catch(P,F,A), not((( predicate_property(ModuleName:P,imported_from(IM)),IM\==ModuleName ))).


:- export((user_ensure_loaded/1)).
:- module_transparent user_ensure_loaded/1.

%= 	 	 

%% user_ensure_loaded( ?What) is semidet.
%
% User Ensure Loaded.
%
user_ensure_loaded(What):- !, '@'(ensure_loaded(What),'user').

:- module_transparent user_use_module/1.
% user_ensure_loaded(logicmoo(What)):- !, '@'(ensure_loaded(logicmoo(What)),'user').
% user_use_module(library(What)):- !, use_module(library(What)).

%= 	 	 

%% user_use_module( ?What) is semidet.
%
% User Use Module.
%
user_use_module(What):- '@'(use_module(What),'user').





%= 	 	 

%% export_all_preds is semidet.
%
% Export All Predicates.
%
export_all_preds:-source_location(File,_Line),module_property(M,file(File)),!,export_all_preds(M).


%= 	 	 

%% export_all_preds( ?ModuleName) is semidet.
%
% Export All Predicates.
%
export_all_preds(ModuleName):-forall(current_predicate(ModuleName:F/A),
                   ((export(F/A),functor_safe(P,F,A),mpred_trace_nochilds(ModuleName:P)))).







%= 	 	 

%% module_predicate( ?ModuleName, ?F, ?A) is semidet.
%
% Module Predicate.
%
module_predicate(ModuleName,F,A):-current_predicate(ModuleName:F/A),functor_safe(P,F,A),
   \+ ((( predicate_property(ModuleName:P,imported_from(IM)),IM\==ModuleName ))).

:- module_transparent(module_predicates_are_exported/0).
:- module_transparent(module_predicates_are_exported/1).
:- module_transparent(module_predicates_are_exported0/1).


%= 	 	 

%% module_predicates_are_exported is semidet.
%
% Module Predicates Are Exported.
%
module_predicates_are_exported:- source_context_module(CM),module_predicates_are_exported(CM).


%= 	 	  

%% module_predicates_are_exported( ?Ctx) is semidet.
%
% Module Predicates Are Exported.
%
module_predicates_are_exported(user):-!,source_context_module(CM),module_predicates_are_exported0(CM).
module_predicates_are_exported(Ctx):- module_predicates_are_exported0(Ctx).


%= 	 	 

%% module_predicates_are_exported0( ?ModuleName) is semidet.
%
% Module Predicates Are Exported Primary Helper.
%
module_predicates_are_exported0(user):- !. % dmsg(warn(module_predicates_are_exported(user))).
module_predicates_are_exported0(ModuleName):-
   module_property(ModuleName, exports(List)),
    findall(F/A,
    (module_predicate(ModuleName,F,A),
      not(member(F/A,List))), Private),
   module_predicates_are_not_exported_list(ModuleName,Private).

:- export(export_if_noconflict_mfa/2).
:- export(export_if_noconflict_mfa/3).
:- module_transparent(export_if_noconflict_mfa/2).
:- module_transparent(export_if_noconflict_mfa/3).

%= 	 	 

%% export_if_noconflict( ?M, :TermF) is semidet.
%
% Export If Noconflict.
%
%:- redefine_system_predicate(system:export_if_noconflict/2),abolish(system:export_if_noconflict/2).
:- module_transparent(export_if_noconflict/2).
:- export(export_if_noconflict/2).
export_if_noconflict(M,FA):- export_if_noconflict_mfa(M,FA).
:- sexport(export_if_noconflict/2).

:- module_transparent(export_if_noconflict_mfa/2).
export_if_noconflict_mfa(SM,Var):- var(Var),throw(var(export_if_noconflict_mfa(SM,Var))).
export_if_noconflict_mfa(_,  M:FA):-!,export_if_noconflict_mfa(M,FA).
export_if_noconflict_mfa(SM,(A,B)):-!,export_if_noconflict_mfa(SM,A),export_if_noconflict_mfa(SM,B).
export_if_noconflict_mfa(SM,[A]):-  !,export_if_noconflict_mfa(SM,A).
export_if_noconflict_mfa(SM,[A|B]):-!,export_if_noconflict_mfa(SM,A),export_if_noconflict_mfa(SM,B).
export_if_noconflict_mfa(SM,F/A):- !,export_if_noconflict_mfa(SM,F,A).
export_if_noconflict_mfa(SM,F//A):- A2 is A + 2, !,export_if_noconflict_mfa(SM,F,A2).
export_if_noconflict_mfa(_,SM:F//A):- A2 is A + 2, !,export_if_noconflict_mfa(SM,F,A2).
export_if_noconflict_mfa(SM,P):-functor(P,F,A),export_if_noconflict_mfa(SM,F,A).

:- module_transparent(export_if_noconflict_mfa/3).
export_if_noconflict_mfa(M,F,A):- functor(P,F,A),
   predicate_property(M:P,imported_from(Other)),
   (Other==system->unlock_predicate(Other:P);true),
   Other:export(Other:F/A),
   (Other==system->lock_predicate(Other:P);true),
   M:import(Other:F/A),!,
   M:export(Other:F/A), writeln(rexporting(M=Other:F/A)).
export_if_noconflict_mfa(M,F,A):- 
  functor(P,F,A),
 findall(import(Real:F/A),
  (current_module(M2),module_property(M2,exports(X)),member(F/A,X),
    (predicate_property(M2:P,imported_from(Real))->true;Real=M2),
    Real\=M,
    writeln(should_be_skipping_export(M:Real=M2:F/A)),
    Real:export(Real:F/A),
    Real\==M),List),
 (List==[]->(M:export(M:F/A));
  (maplist(call,List)),(M:export(M:F/A))).
/*
export_if_noconflict_mfa(M,F,A):- current_module(M2),M2\=M,module_property(M2,exports(X)),
   member(F/A,X),ddmsg(skipping_export(M2=M:F/A)),!,
   must(M:export(M:F/A)),
   ((M2==system;M==baseKB)->true;must(M2:import(M:F/A))).
export_if_noconflict_mfa(M,F,A):-M:export(F/A).
*/
% module_predicates_are_not_exported_list(ModuleName,Private):- once((length(Private,Len),dmsg(module_predicates_are_not_exported_list(ModuleName,Len)))),fail.

%= 	 	 

%% module_predicates_are_not_exported_list( ?ModuleName, ?Private) is semidet.
%
% Module Predicates Are Not Exported List.
%
module_predicates_are_not_exported_list(ModuleName,Private):- forall(member(F/A,Private),export_if_noconflict(ModuleName,F/A)).






%= 	 	 

%% arg_is_transparent( :GoalArg) is semidet.
%
% Argument If Is A Transparent.
%
arg_is_transparent(Arg):- member(Arg,[':','^']).
arg_is_transparent(0).
arg_is_transparent(Arg):- number(Arg).

% make meta_predicate's module_transparent

%= 	 	 

%% module_meta_predicates_are_transparent( ?ModuleName) is semidet.
%
% Module Meta Predicates Are Transparent.
%
module_meta_predicates_are_transparent(_):-!.
module_meta_predicates_are_transparent(ModuleName):-
    forall((module_predicate(ModuleName,F,A),functor_safe(P,F,A)),
      ignore(((predicate_property(ModuleName:P,(meta_predicate( P ))),
            not(predicate_property(ModuleName:P,(transparent))), (compound(P),arg(_,P,Arg),arg_is_transparent(Arg))),
                   (nop(dmsg(todo(module_transparent(ModuleName:F/A)))),
                   (module_transparent(ModuleName:F/A)))))).

:- export(all_module_predicates_are_transparent/1).
% all_module_predicates_are_transparent(_):-!.

%= 	 	 

%% all_module_predicates_are_transparent( ?ModuleName) is semidet.
%
% All Module Predicates Are Transparent.
%
all_module_predicates_are_transparent(ModuleName):-
    forall((module_predicate(ModuleName,F,A),functor_safe(P,F,A)),
      ignore((
            not(predicate_property(ModuleName:P,(transparent))),
                   ( nop(dmsg(todo(module_transparent(ModuleName:F/A))))),
                   (module_transparent(ModuleName:F/A))))).


%= 	 	 

%% quiet_all_module_predicates_are_transparent( ?ModuleName) is semidet.
%
% Quiet All Module Predicates Are Transparent.
%
quiet_all_module_predicates_are_transparent(_):-!.
quiet_all_module_predicates_are_transparent(ModuleName):-
    forall((module_predicate(ModuleName,F,A),functor_safe(P,F,A)),
      ignore((
            not(predicate_property(ModuleName:P,(transparent))),
                   nop(dmsg(todo(module_transparent(ModuleName:F/A)))),
                   (module_transparent(ModuleName:F/A))))).


:- multifile(user:term_expansion/2).
:- dynamic(user:term_expansion/2).
:- module_transparent(user:term_expansion/2).
% user:term_expansion( (:-export(FA) ),(:- export_if_noconflict(M,FA))):-  current_prolog_flag(subclause_expansion,true),prolog_load_context(module,M).


:- ignore((source_location(S,_),prolog_load_context(module,M),module_property(M,class(library)),
 forall(source_file(M:H,S),
 ignore((functor(H,F,A),
  ignore(((\+ atom_concat('$',_,F),(export(F/A) , current_predicate(system:F/A)->true; system:import(M:F/A))))),
  ignore(((\+ predicate_property(M:H,transparent), module_transparent(M:F/A), \+ atom_concat('__aux',_,F),debug(modules,'~N:- module_transparent((~q)/~q).~n',[F,A]))))))))).




%! must(:Goal) is nondet.
%
% Goal must succeed at least once once
%
% Wrap must/1 over parts of your code you do not trust
% If your code fails.. it will rewind to your entry block (at the scope of this declaration) and invoke rtrace/1 .
% If there are 50 steps to your code, it will save you from pushing `creep` 50 times.  
% Instead it turns off the leash to allow you to trace with your eyeballs instead of your fingers.
%
%% must( :Goal) is semidet.
%
% Must Be Successfull.
%

% must(Goal):- \+ flag_call(runtime_debug == true) ,flag_call(unsafe_speedups == true) ,!,call(Goal).
% must(Call):- !, (repeat, (catchv(Call,E,(dmsg(E:Call),fail)) *-> true ; (ignore(rtrace(Call)),leash(+all),repeat,wdmsg(failed(Call)),trace,Call))).
/*
must(Goal):- skipWrapper,!, (Goal *-> true;throw(failed_must(Goal))).
must(Goal):- current_prolog_flag(runtime_must,How),!,
          (How == speed -> call(Goal);
           How == debug -> on_f_rtrace(Goal);
           How == keep_going -> ignore(on_f_rtrace(Goal));
           on_f_rtrace(Goal)).
must(Goal):-  get_must(Goal,MGoal),!,call(MGoal).
must(Goal):- Goal*->true;prolog_debug:assertion_failed(fail, must(Goal)).
*/

%! sanity(:Goal) is det.
%
% Optional Sanity Checking.
%
% like assertion/1 but adds trace control
%
/*
sanity(_):- notrace(current_prolog_flag(runtime_safety,0)),!.

sanity(Goal):- \+ tracing,
   \+ current_prolog_flag(runtime_safety,3),
   \+ current_prolog_flag(runtime_debug,0),
   (current_prolog_flag(runtime_speed,S),S>1),
   !,                                                       
   (1 is random(10)-> must(Goal) ; true).
sanity(Goal):- notrace(quietly(Goal)),!.
sanity(_):- dumpST,fail.
sanity(Goal):- tlbugger:show_must_go_on,!,dmsg(show_failure(sanity(Goal))).
sanity(Goal):- setup_call_cleanup(wdmsg(begin_FAIL_in(Goal)),rtrace(Goal),wdmsg(end_FAIL_in(Goal))),!,dtrace(assertion(Goal)).
*/
sanity(G):-hotrace(G)*->true;rtrace(G).
                                                     
%! must_once(:Goal) is det.
%
% Goal must succeed at most once
%
must_once(Goal):- must(Goal),!.


%! must_det(:Goal) is det.
%
% Goal must succeed determistically
%

% must_det(Goal):- current_prolog_flag(runtime_safety,0),!,must_once(Goal).
must_det(Goal):- \+ current_prolog_flag(runtime_safety,3),!,must_once(Goal).
must_det(Goal):- must_once(Goal),!.
/*
must_det(Goal):- must_once((Goal,deterministic(YN))),(YN==true->true;dmsg(warn(nondet_exit(Goal)))),!.
must_det(Goal):- must_once((Goal,deterministic(YN))),(YN==true->true;throw(nondet_exit(Goal))).
*/

%! nop( :Goal) is det.
%
%  Comments out code without losing syntax
%
nop(_).


/*
scce_orig(Setup,Goal,Cleanup):-
   \+ \+ '$sig_atomic'(Setup), 
   catch( 
     ((Goal, deterministic(DET)),
       '$sig_atomic'(Cleanup),
         (DET == true -> !
          ; (true;('$sig_atomic'(Setup),fail)))), 
      E, 
      ('$sig_atomic'(Cleanup),throw(E))). 

:- abolish(system:scce_orig,3).


[debug]  ?- scce_orig( (writeln(a),trace,start_rtrace,rtrace) , (writeln(b),member(X,[1,2,3]),writeln(c)), writeln(d)).
a
b
c
d
X = 1 ;
a
c
d
X = 2 ;
a
c
d
X = 3.


*/

scce_orig(Setup0,Goal,Cleanup0):-
  notrace((Cleanup = notrace('$sig_atomic'(Cleanup0)),Setup = notrace('$sig_atomic'(Setup0)))),
   \+ \+ Setup, !,
   (catch(Goal, E,(Cleanup,throw(E)))
      *-> (notrace(tracing)->(notrace,deterministic(DET));deterministic(DET)); (Cleanup,!,fail)),
     Cleanup,
     (DET == true -> ! ; (true;(Setup,fail))).
      
/*
scce_orig(Setup,Goal,Cleanup):-
   \+ \+ '$sig_atomic'(Setup), 
   catch( 
     ((Goal, deterministic(DET)),
       '$sig_atomic'(Cleanup),
         (DET == true -> !
          ; (true;('$sig_atomic'(Setup),fail)))), 
      E, 
      ('$sig_atomic'(Cleanup),throw(E))). 
*/




:- ignore((source_location(S,_),prolog_load_context(module,M),module_property(M,class(library)),
 forall(source_file(M:H,S),
 ignore((functor(H,F,A),
  ignore(((\+ atom_concat('$',_,F),(export(F/A) , current_predicate(system:F/A)->true; system:import(M:F/A))))),
  ignore(((\+ predicate_property(M:H,transparent), module_transparent(M:F/A), \+ atom_concat('__aux',_,F),debug(modules,'~N:- module_transparent((~q)/~q).~n',[F,A]))))))))).

 
 
 
%:-ensure_loaded('../logicmoo/logicmoo_util_library.pl').
%:-use_module(library('logicmoo/logicmoo_util_library.pl')).
%:-use_module(library('logicmoo/logicmoo_util_ctx_frame.pl')).
 
:- multi_transparent(current_directory_search/1).
:- multi_transparent(isDebugOption/1).
:- multi_transparent(formatter_hook/4).
:- module_transparent(hotrace/1).
 
 
% :-guitracer.
 
 
 
 
 
%:-module()
%:-include('logicmoo_utils_header.pl'). %<?
%:- style_check(-singleton).
%%:- style_check(-discontiguous).
%:- style_check(-atom).
%:- style_check(-string).
 
:-op(1150,fx,meta_predicate_transparent).

/*
must_assign(From=To):-must_assign(From,To).
must_assign(From,To):-To=From,!.
must_assign(From,To):-dmsg(From),dmsg(=),dmsg(From),dmsg(must_assign),!,trace,To=From.
 */
dhideTrace(X):-'$hide'(X),!.

:-dhideTrace(prolog_must/1).
:-dhideTrace(ctrace/0).
prolog_must(Call):-tracing,!,prolog_must_tracing(Call).
prolog_must(Call):-must(Call).
 
 
:-dhideTrace(must/1).
:-dhideTrace(debugOnFailure0/1).
must(X):-prolog_ecall(debugOnFailure0,X).
debugOnFailure0(X):-!,atLeastOne(X).
%%debugOnFailure0(X):-!,atLeastOne(debugOnError(X)).
%%debugOnFailure0(X):-catch(X,E,(writeFailureLog(E,X),throw(E))).
%%debugOnFailure0(X):-ctrace,X.
 
debugOnFailure1(arg_domains,CALL):-!,logOnFailure(CALL),!.
debugOnFailure1(Module,CALL):-trace,must(Module:CALL),!.
 
 
:-dhideTrace(debugOnError/1).
debugOnError(Call):- prolog_ecall(debugOnError0,Call).   
:-dhideTrace(debugOnError0/1).
debugOnError0(Call):- catch(Call,E,dmsg(error(Call,E),trace,Call)).
 
 
:-'$hide'(prolog_may/1).
prolog_may(Call):-prolog_ecall(debugOnError,Call).
 
 
:-dhideTrace(prolog_must_tracing/1).
:-dhideTrace(prolog_must_tracing0/1).
prolog_must_tracing(Call):-!, Call.
prolog_must_tracing(Call):- notrace,prolog_ecall(prolog_must_tracing0,Call).   
prolog_must_tracing0(Call):- 
   notrace((trace(Call,Before),trace(Call,[-all,+fail,+exit]))), 
   atLeastOne(Call,(trace,Call)), 
   notrace(trace(Call,Before)).
 


rtrace(A):-traceCall(A).

traceCall(A):-trace(A,[-all,+fail]),A,!.
 
 
:-dhideTrace(debugOnFailureEach/1).
:-dhideTrace(debugOnFailureEach0/1).
debugOnFailureEach(Call):- prolog_ecall(must,fail,debugOnFailureEach0,Call).
debugOnFailureEach0(Call):- once(Call;(trace,Call)).
 
 
beenCaught(prolog_must(Call)):- !, beenCaught(Call).
beenCaught((A,B)):- !,beenCaught(A),beenCaught(B).
beenCaught(Call):- fail, predicate_property(Call,number_of_clauses(_Count)), clause(Call,(_A,_B)),!,clause(Call,Body),beenCaught(Body).
beenCaught(Call):- catch(once(Call),E,(dmsg(caugth(Call,E)),beenCaught(Call))),!.
beenCaught(Call):- traceAll,dmsg(tracing(Call)),debug,trace,Call.
 
/*
atom_contains(F,C):- hotrace((atom(F),atom(C),sub_atom(F,_,_,_,C))).

local_predicate(_,_/0):-!,fail.
local_predicate(_,_/N):-N>7,!,fail.
local_predicate(P,_):-predicate_property(P,built_in),!,fail.
local_predicate(P,_):-predicate_property(P,imported_from(_)),!,fail.
local_predicate(P,_):-predicate_property(P,file(F)),!,atom_contains(F,'aiml_'),!.
local_predicate(P,F/N):-functor(P,F,N),!,fail.
 */
 
 
 
:-dhideTrace(prolog_ecall/2).
:-dhideTrace(prolog_ecall/4).
prolog_ecall(Pred,Call):-prolog_ecall(call,fail,Pred,Call).
prolog_ecall(ClauseEach,Pred,Call):-prolog_ecall(ClauseEach,fail,Pred,Call).
 
prolog_ecall(_ClauseEach,_Tracing,_Pred,Call):-notrace,var(Call),!,trace,randomVars(Call).
prolog_ecall(_ClauseEach,_Tracing,_Pred,Call):-functor(Call,F,_),member(F,[assert,asserta,assertz]),!,catch(Call,_,true),!.
prolog_ecall(_ClauseEach,_Tracing,_Pred,Call):-functor(Call,F,A),member(F/A,[retract/_,retractall/_]),!,dmsg(fakingCall(Call)),numbervars(Call,0,_),!.
prolog_ecall(ClauseEach,Tracing,Pred,(X->Y;Z)):-!,(hotrace(X) -> prolog_ecall(ClauseEach,Tracing,Pred,Y) ; prolog_ecall(ClauseEach,Tracing,Pred,Z)).
prolog_ecall(ClauseEach,Tracing,Pred,(X->Y)):-!,(hotrace(X)->prolog_ecall(ClauseEach,Tracing,Pred,Y)).
prolog_ecall(ClauseEach,Tracing,Pred,(X;Y)):-!,prolog_ecall(ClauseEach,Tracing,Pred,X);prolog_ecall(ClauseEach,Tracing,Pred,Y).
prolog_ecall(ClauseEach,Tracing,Pred,(X,Y)):-!,prolog_ecall(ClauseEach,Tracing,Pred,X),prolog_ecall(ClauseEach,Tracing,Pred,Y).
prolog_ecall(ClauseEach,Tracing,Pred,prolog_must(Call)):-!,prolog_ecall(ClauseEach,Tracing,Pred,Call).
prolog_ecall(ClauseEach,_Tracing,_Pred,Call):- fail, ignore((Call=atom(_),trace)), 
    predicate_property(Call,number_of_clauses(_Count)),
    clause(Call,NT),NT \== true,!,
    catch(clause(Call,Body),_,
      (trace,predicate_property(Call,number_of_clauses(_Count2)),
      clause(Call,Body))),
      call(ClauseEach,Body).
 
prolog_ecall(_ClauseEach,_Fail,Pred,Call):- call(Pred,Call).
%prolog_ecall(_ClauseEach,Fail,_Pred,Call):- Fail\=fail, call(Fail,Call).
 
 
:-dhideTrace(atLeastOne/1).
:-dhideTrace(atLeastOne/2).
:-dhideTrace(atLeastOne0/2).
 
atLeastOne(OneA):- atLeastOne(OneA,(trace,OneA)).
atLeastOne(OneA,Else):-atLeastOne0(OneA,Else).
 
atLeastOne0(OneA,_Else):-copy_term(OneA,One),findall(One,call(One),OneL),[_|_]=OneL,!,member(OneA,OneL).
atLeastOne0(OneA,Else):-dmsg(failed(OneA)),!,Else,!,fail.
 
 
randomVars(Term):- random:random(R), StartR is round('*'(R,1000000)), !,
  %ignore(Start=0),
  ignore(Start=StartR),
  numbervars(Term, Start, _End, [attvar(skip),functor_name('$VAR')]).
 
prolog_must_not(Call):-Call,!,trace,!,programmer_error(prolog_must_not(Call)).
prolog_must_not(_Call):-!.                    
 
%:- meta_predicate dynamic_if_missing(:).
%:- meta_predicate meta_predicate_transparent(:).
 
 
meta_predicate_transparent(X):-strip_module(X,M,F),!, meta_predicate_transparent(M,F).
meta_predicate_transparent(M,(X,Y)):-!,meta_predicate_transparent(M,X),meta_predicate_transparent(M,Y),!.
meta_predicate_transparent(_M,X):-atom(X),!.
meta_predicate_transparent(_M,X):- 
   debugOnFailureEach((   
   arg(1,X,A),functor(X,F,_),
   FA=F/A,
   dynamic_if_missing(FA),
   %module_transparent(FA),
   %%meta_predicate(X),
   %trace(FA, -all),
   %%dhideTrace(FA),
   !)).
 
 
asserta_new(_Ctx,NEW):-ignore(retract(NEW)),asserta(NEW).
writeqnl(_Ctx,NEW):- format('~q.~n',[NEW]),!.
 
 
%%%retractall(E):- retractall(E),functor(E,File,A),dynamic(File/A),!.
 
%pp_listing(_Pred):-!. %%functor(Pred,File,A),functor(FA,File,A),listing(File),nl,findall(NV,predicate_property(FA,NV),LIST),writeq(LIST),nl,!.
 
% =================================================================================
% Utils
% =================================================================================
 
printPredCount(Msg,Pred,N1):- compound(Pred), debugOnFailureEach((arg(_,Pred,NG))),user:nonvar(NG),!,
   findall(Pred,Pred,LEFTOVERS),length(LEFTOVERS,N1),dmsg(num_clauses(Msg,Pred,N1)),!.
 
printPredCount(Msg,Pred,N1):-!,functor(Pred,File,A),functor(FA,File,A), predicate_property(FA,number_of_clauses(N1)),dmsg(num_clauses(Msg,File/A,N1)),!.
 
 
% ===============================================================================================
% UTILS
% ===============================================================================================
 
printAll2(FileMatch):-printAll2(FileMatch,FileMatch).
printAll2(Call,Print):- flag(printAll2,_,0), forall((Call,flag(printAll2,N,N+1)),(format('~q.~n',[Print]))),fail.
printAll2(_Call,Print):- flag(printAll2,PA,0),(format('~n /* found ~q for ~q. ~n */ ~n',[PA,Print])).
 
%contains_term(SearchThis,Find):-Find==SearchThis,!.
%contains_term(SearchThis,Find):-compound(SearchThis),functor(SearchThis,Func,_),(Func==Find;arg(_,SearchThis,Arg),contains_term(Arg,Find)).
 
 
 
% ===================================================================
% Lowlevel printng
% ===================================================================
 
open_list(V,V):-var(V).
open_list(A,B):-append(A,_,B).
 
unnumbervars_nil(X,Y):-!,unnumbervars(X,Y).
 
collect_temp_vars(VARS):-!,(setof(=(Name,Number),numbered_var(Name,Number),VARS);VARS=[]).
 
% ==========================================================
%  Sending Notes
% ==========================================================
  

 
if_prolog(swi,G):-call(G).  % Run B-Prolog Specifics
if_prolog(_,_):-!.  % Dont run SWI Specificd or others


 
dumpstack_argument(_T):-isDebugOption(opt_debug=off),!.  
     
dumpstack_argument(Frame):-
    write(frame=Frame),write(' '),
    dumpstack_argument(1,Frame).
 
dumpstack_argument(1,Frame):-!,
    prolog_frame_attribute(Frame,goal,Goal),!,
    write(goal=Goal),write('\n').
     
dumpstack_argument(N,Frame):-
    prolog_frame_attribute(Frame,argument(N),O),!,
    write(N=O),write(' '),
    NN is N +1,
    dumpstack_argument(NN,Frame).
     
dumpstack_argument(_N,_Frame):-!,write('\n').
     
:-dynamic_transparent(seenNote/1).
 
sendNote(X):-var(X),!.
sendNote(X):-seenNote(X),!.
sendNote(X):-!,assert(seenNote(X)).
sendNote(_).             
 
sendNote(To,From,Subj,Message):-sendNote(To,From,Subj,Message,_).
 
sendNote(To,From,Subj,Message,Vars):-
    not(not((safe_numbervars((To,From,Subj,Message,Vars)),
    %dmsg(sendNote(To,From,Subj,Message,Vars)),
    catch(sendNote_1(To,From,Subj,Message,Vars),E,
    writeFmt('send note ~w ~w \n <HR>',[E,sendNote(To,From,Subj,Message,Vars)]))))).
 
 
sendNote_1(To,From,Subj,surf,Vars):-singletons([To,Subj,From,Vars]),!.
sendNote_1(To,From,[],surf,Vars):-singletons([To,From,Vars]),!.
sendNote_1(To,From,[],end_of_file,Vars):-singletons([To,From,Vars]),!.
sendNote_1(doug,From,_,_,Vars):-singletons([From,Vars]),!.
sendNote_1(extreme_debug,_From,_,_,_Vars):-!.
sendNote_1(debug,'Belief',_,_,_Vars):-!.
 
%sendNote_1(canonicalizer,From,Subj,Message,Vars):-!.
 
 
sendNote_1(canonicalizer,From,Subj,Message,Vars):-
            withFormatter(cycl,From,Vars,SFrom),
            withFormatter(cycl,nv(Subj),Vars,SS),
            withFormatter(cycl,nv(Message),Vars,SA),
            writeFmt('<font color=red>canonicalizer</font>: ~w "~w" (from ~w). \n',[SA,SS,SFrom]),!.
 
/*
 
sendNote_1(debug,From,Subj,Message,Vars):- %isDebugOption(disp_notes_nonuser=on),!,
            withFormatter(cycl,From,Vars,SFrom),
            withFormatter(cycl,Subj,Vars,SS),
            withFormatter(cycl,Message,Vars,SA),
            writeFmt('% debug: ~w "~w" (from ~w). \n',[SA,SS,SFrom]).
sendNote_1(debug,From,Subj,Message,Vars):-!.
*/
 
            /*
 
 
sendNote_1(To,From,Subj,Message,Vars):- isDebugOption(client=consultation),  !, 
            withFormatter(cycl,To,Vars,STo),
            withFormatter(cycl,From,Vars,SFrom),
            withFormatter(cycl,nv(Subj),Vars,S),
            withFormatter(cycl,nv(Message),Vars,A),
            fmtString(Output,'~w (~w from ~w) ',[A,S,SFrom]),
        sayn(Output),!.
 
sendNote_1(To,From,'Rejected',Message,Vars):- isDebugOption(client=automata),  !.
 
sendNote_1(To,From,Subj,Message,Vars):- isDebugOption(client=automata),  !, 
            withFormatter(cycl,To,Vars,STo),
            withFormatter(cycl,From,Vars,SFrom),
            withFormatter(cycl,nv(Subj),Vars,S),
            withFormatter(cycl,nv(Message),Vars,A),
            writeFmt(user_error,'% ~w (~w from ~w) ',[A,S,SFrom]).
 
sendNote_1(To,From,Subj,Message,Vars):- isDebugOption(client=html),  !, %  In Html
            withFormatter(cycl,To,Vars,STo),
            withFormatter(cycl,From,Vars,SFrom),
            withFormatter(cycl,nv(Subj),Vars,S),
            withFormatter(html,nv(Message),Vars,A),
            writeFmt('<hr><B>To=<font color=green>~w</font> From=<font color=green>~w</font> Subj=<font color=green>~w</font></B><BR>~w\n',[To,From,S,A]),!.
 
sendNote_1(To,From,Subj,Message,Vars):- isDebugOption(client=console),!, % In CYC
            withFormatter(cycl,To,Vars,STo),
            withFormatter(cycl,From,Vars,SFrom),
            withFormatter(cycl,nv(Subj),Vars,SS),
            withFormatter(cycl,nv(Message),Vars,SA),
            writeFmt(user_error,'; ~w: ~w "~w" (from ~w). \n',[STo,SA,SS,SFrom]),!.
   
sendNote_1(To,From,Subj,Message,Vars):-  % In CYC
            withFormatter(cycl,To,Vars,STo),
            withFormatter(cycl,From,Vars,SFrom),
            withFormatter(cycl,nv(Subj),Vars,SS),
            withFormatter(cycl,nv(Message),Vars,SA),
            writeFmt(user_error,'; ~w: ~w "~w" (from ~w). \n',[STo,SA,SS,SFrom]),!.
 
sendNote(To,From,Subj,Message,Vars):-!.
                                                                       */
debugFmtFast(X):-writeq(X),nl.
 
logOnFailure(assert(X,Y)):- catch(assert(X,Y),_,Y=0),!.
logOnFailure(assert(X)):- catch(assert(X),_,true),!.
logOnFailure(assert(X)):- catch(assert(X),_,true),!.
%logOnFailure(X):-catch(X,E,true),!.
logOnFailure(X):-catch(X,E,(writeFailureLog(E,X),!,catch((true,X),_,fail))),!.
logOnFailure(X):- writeFailureLog('Predicate Failed',X),!.

on_f_log_ignore(X):-logOnFailure(X).
 
 
noDebug(CALL):-CALL.
     
 
 
%unknown(Old, autoload).
 
 
 
 
% ========================================================================================
% Some prologs have a printf() type predicate.. so I made up fmtString/writeFmt in the Cyc code that calls the per-prolog mechaism
% in SWI it''s formzat/N and sformat/N
% ========================================================================================
:-dynamic_transparent(isConsoleOverwritten/0).
 
/*
defined above
wdmsg(X,Y,Z):-catch((format(X,Y,Z),flush_output_safe(X)),_,true).
wdmsg(X,Y):-catch((format(X,Y),flush_output),_,true).
wdmsg(X):- once((atom(X) -> catch((format(X,[]),flush_output),_,true) ; wdmsg('~q~n',[X]))).
*/
 
writeFmt(X,Y,Z):-catch(format(X,Y,Z),_,true).
writeFmt(X,Y):-format(X,Y).
writeFmt(X):-format(X,[]).
 
fmtString(X,Y,Z):-sformat(X,Y,Z).
fmtString(Y,Z):-sformat(Y,Z).
 
saveUserInput:-retractall(isConsoleOverwritten),flush_output.
writeSavedPrompt:-not(isConsoleOverwritten),!.
writeSavedPrompt:-flush_output.
writeOverwritten:-isConsoleOverwritten,!.
writeOverwritten:-assert(isConsoleOverwritten).
 
writeErrMsg(Out,E):- message_to_string(E,S),wdmsg(Out,'<cycml:error>~s</cycml:error>\n',[S]),!.
writeErrMsg(Out,E,Goal):- message_to_string(E,S),wdmsg(Out,'<cycml:error>goal "~q" ~s</cycml:error>\n',[Goal,S]),!.
writeFileToStream(Dest,Filename):-
        catch((
        open(Filename,'r',Input),
        repeat,
                get_code(Input,Char),
                put(Dest,Char),
        at_end_of_stream(Input),
        close(Input)),E,
        wdmsg('<cycml:error goal="~q">~w</cycml:error>\n',[writeFileToStream(Dest,Filename),E])).
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/* 
assert_if_new(N):-N,!.
assert_if_new(N):-assert(N),!.
 */
                              
% =================================================================================
% Utils
% =================================================================================
test_call(G):-writeln(G),ignore(once(catch(G,E,writeln(E)))).
 
debugFmtList(ListI):-notrace((copy_term(ListI,List),debugFmtList0(List,List0),randomVars(List0),dmsg(List0))),!.
debugFmtList0([],[]):-!.
debugFmtList0([A|ListA],[B|ListB]):-debugFmtList1(A,B),!,debugFmtList0(ListA,ListB),!.
 
debugFmtList1(Value,Value):-var(Value),!.
debugFmtList1(Name=Number,Name=Number):-number(Number).
debugFmtList1(Name=Value,Name=Value):-var(Value),!.
debugFmtList1(Name=Value,Name=(len:Len)):-copy_term(Value,ValueO),append(ValueO,[],ValueO),is_list(ValueO),length(ValueO,Len),!.
debugFmtList1(Name=Value,Name=(F:A)):-functor(Value,F,A).
debugFmtList1(Value,shown(Value)).
 
% ===============================================================================================
% unlistify / listify
% ===============================================================================================
 
unlistify([L],O):-user:nonvar(L),unlistify(L,O),!.
unlistify(L,L).
 
listify(OUT,OUT):-not(not(is_list(OUT))),!.
listify(OUT,[OUT]).
 
 
 
 
 
traceIf(_Call):-!.
traceIf(Call):-ignore((Call,trace)).
 
 
% When you trust the code enough you dont to debug it
%  but if that code does something wrong while your not debugging, you want to see the error
hotrace(X):- tracing -> notrace_call(X) ; call(X).


notrace_call(X):-notrace,catch(traceafter_call(X),E,(dmsg(E-X),trace,throw(E))).
traceafter_call(X):-X,trace.
traceafter_call(_):-tracing,fail.
traceafter_call(_):-trace,fail.
 
 
debugFmtS([]):-!.
debugFmtS([A|L]):-!,dmsg('% ~q~n',[[A|L]]).
debugFmtS(Comp):-ctxHideIfNeeded(_,Comp,Comp2),!,dmsg('% ~q~n',[Comp2]).
debugFmtS(Stuff):-!,dmsg('% ~q~n',[Stuff]).
 
 
%getWordTokens(WORDS,TOKENS):-concat_atom(TOKENS,' ',WORDS).
%is_string(S):-string(S).
 

vsubst(In,B,A,Out):-var(In),!,(In==B->Out=A;Out=In).
vsubst(In,B,A,Out):-subst(In,B,A,Out).

% :- use_module(logicmoo_util_prolog_streams).
:- thread_self(Goal),assert(lmcache:thread_main(user,Goal)).

main_self(main).
main_self(W):-atom(W),atom_concat('pdt_',_,W),!.
main_self(W):-lmcache:thread_main(user,W),!.

thread_self_main:- quietly((thread_self(W),!,main_self(W))).

%% hide_non_user_console is semidet.
%
% Not User Console.
%
hide_non_user_console:-thread_self_main,!,fail.
hide_non_user_console:-current_input(In),stream_property(In,tty(true)),!,fail.
hide_non_user_console:-current_prolog_flag(debug_threads,true),!,fail.
hide_non_user_console:-current_input(In),stream_property(In, close_on_abort(true)).
hide_non_user_console:-current_input(In),stream_property(In, close_on_exec(true)).


/*
:- if(\+ current_predicate(system:nop/1)).
:- use_module(logicmoo_util_supp).
:- endif.
*/


:- meta_predicate


		block3(+, :, ?),
		catchv(0, ?, 0),

		if_defined(:),
		if_defined(:, 0),
		ddmsg_call(0),

                on_xf_log_cont(0),

		skip_failx_u(0),
		on_xf_log_cont_l(0),
		on_x_log_throw(0),
                with_current_why(*,0),


		on_x_log_cont(0),
		on_x_log_fail(0),


        % must(0),
        must2(+,0),
        must_find_and_call(0),
        must_det_u(0),
        %must_det_dead(0, 0),

        must_det_l(0),
        must_det_l_pred(1,+),
        call_must_det(1,+),
        call_each(*,+),
        p_call(*,+),

        must_l(0),
        one_must(0, 0),
        one_must_det(0, 0),
        unsafe_safe(0,0),
        % sanity(0),
        sanity2(+,0),
        slow_sanity(0),
        to_pi(?, ?),
        when_defined(:),
        with_main_error_to_output(0),
        with_current_io(0),
        with_dmsg_to_main(0),
        with_error_to_main(0),
        with_main_input(0),
        with_main_io(0),
        with_preds(?, ?, ?, ?, ?, 0),
        without_must(0),
        %on_x_log_throwEach(0),
        y_must(?, 0).

:- module_transparent
        !/1,
        addLibraryDir/0,
        as_clause_no_m/3,
        as_clause_w_m/4,
        as_clause_w_m/5,
        bad_functor/1,
        badfood/1,
        (block)/2,
        %bubbled_ex/1,
        %bubbled_ex_check/1,
        current_source_file/1,
        lmcache:current_main_error_stream/1,
        dbgsubst/4,
        dbgsubst0/4,
        ddmsg/1,
        ddmsg/2,
        det_lm/2,
        dif_safe/2,
        errx/0,
        format_to_error/2,
        fresh_line_to_err/0,
        functor_catch/3,
        functor_safe/3,
        with_current_why/2,
        get_must/2,
        ib_multi_transparent33/1,
        input_key/1,
        is_ftCompound/1,
        not_ftCompound/1,
        is_ftNameArity/2,
        is_ftNonvar/1,
        is_ftVar/1,
        is_main_thread/0,
        is_pdt_like/0,
        is_release/0,
        keep/2,
        loading_file/1,
        %on_x_log_throwEach/1,
        maplist_safe/2,
        maplist_safe/3,
        module_functor/4,

        nd_dbgsubst/4,
        nd_dbgsubst1/5,
        nd_dbgsubst2/4,
        not_is_release/0,
        save_streams/0,
        save_streams/1,
        set_block_exit/2,
        showHiddens/0,
        show_new_src_location/1,
        show_new_src_location/2,

            on_xf_log_cont/1,
            on_xf_log_cont_l/1,
            skip_failx_u/1,
            p_call/2,

        show_source_location/0,
        skipWrapper/0,
        skipWrapper0/0,
        strip_arity/3,
        strip_f_module/2,
        get_thread_current_error/1,
        throwNoLib/0,
        to_m_f_arity_pi/5,
        to_pi0/3,
        warn_bad_functor/1.

:- meta_predicate
   doall_and_fail(0),
   quietly_must(0).

:- set_module(class(library)).


/** <module> logicmoo_util_catch - catch-like bocks

   Tracer modes:

   quietly/1 - turn off tracer if already on but still dtrace on failure
   must/1 - dtrace on failure
   rtrace/1 - non interactive debug
   sanity/1 - run in quietly/1 when problems were detected previously otherwise skippable slow_sanity/1+hide_trace/1
   assertion/1 - throw on failure
   hide_trace/1 - hide dtrace temporarily
   slow_sanity/1 - skip unless in developer mode

*/

:- thread_local( tlbugger:old_no_repeats/0).
:- thread_local( tlbugger:skip_bugger/0).
:- thread_local( tlbugger:dont_skip_bugger/0).

:-meta_predicate(skip_failx_u(*)).
skip_failx_u(G):- must_det_l(G).
% skip_failx_u(G):-call_each([baseKB:call_u,on_xf_log_cont,notrace],G).



%=

%% is_pdt_like is semidet.
%
% If Is A Pdt Like.
%
is_pdt_like:-thread_property(_,alias(pdt_console_server)).
is_pdt_like:-lmcache:thread_main(user,Goal),!,Goal \= main.


%=

%% is_main_thread is semidet.
%
% If Is A Main Thread.
%
is_main_thread:-lmcache:thread_main(user,Goal),!,thread_self(Goal).
is_main_thread:-thread_self_main,!.

:- thread_local(tlbugger:no_colors/0).
:- thread_local(t_l:thread_local_error_stream/1).
:- volatile(t_l:thread_local_error_stream/1).

:- is_pdt_like-> assert(tlbugger:no_colors); true.


% = :- meta_predicate(with_main_error_to_output(0)).

%=

%% with_main_error_to_output( :Goal) is semidet.
%
% Using Main Error Converted To Output.
%
with_main_error_to_output(Goal):-
 current_output(Out),
  locally(t_l:thread_local_error_stream(Out),Goal).


with_current_io(Goal):-
  current_input(IN),current_output(OUT),get_thread_current_error(Err),
  scce_orig(set_prolog_IO(IN,OUT,Err),Goal,set_prolog_IO(IN,OUT,Err)).


with_dmsg_to_main(Goal):-
  get_main_error_stream(Err),current_error_stream(ErrWas),Err==ErrWas,!,Goal.
with_dmsg_to_main(Goal):-
  get_main_error_stream(Err),current_error_stream(ErrWas),
  current_input(IN),current_output(OUT),
   locally(t_l:thread_local_error_stream(Err),
   scce_orig(set_prolog_IO(IN,OUT,Err),Goal,set_prolog_IO(IN,OUT,ErrWas))).

with_error_to_main(Goal):-
  get_main_error_stream(Err),current_error_stream(ErrWas),Err=ErrWas,!,Goal.
with_error_to_main(Goal):- trace,
  get_main_error_stream(Err),get_thread_current_error(ErrWas),
  current_input(IN),current_output(OUT),
   locally(t_l:thread_local_error_stream(Err),
   scce_orig(set_prolog_IO(IN,OUT,Err),Goal,set_prolog_IO(IN,OUT,ErrWas))).





%% get_thread_current_error( ?Err) is det.
%
% Thread Current Error Stream.
%
get_thread_current_error(Err):- t_l:thread_local_error_stream(Err),!.
get_thread_current_error(Err):- thread_self(ID),lmcache:thread_current_error_stream(ID,Err),!.
get_thread_current_error(Err):- stream_property(Err,alias(user_error)),!.
get_thread_current_error(Err):- get_main_error_stream(Err),!.

%% get_main_error_stream( ?Err) is det.
%
% Current Main Error Stream.
%
get_main_error_stream(Err):- stream_property(Err,alias(main_error)),!.
get_main_error_stream(Err):- lmcache:thread_main(user,ID),lmcache:thread_current_error_stream(ID,Err).
get_main_error_stream(Err):- t_l:thread_local_error_stream(Err),!.
get_main_error_stream(Err):- stream_property(Err,alias(user_error)),!.


%=

%% format_to_error( ?F, ?A) is semidet.
%
% Format Converted To Error.
%
format_to_error(F,A):-get_main_error_stream(Err),!,format(Err,F,A).

%=

%% fresh_line_to_err is semidet.
%
% Fresh Line Converted To Err.
%
fresh_line_to_err:- quietly((flush_output_safe,get_main_error_stream(Err),format(Err,'~N',[]),flush_output_safe(Err))).

:- dynamic(lmcache:thread_current_input/2).
:- volatile(lmcache:thread_current_input/2).

:- dynamic(lmcache:thread_current_error_stream/2).
:- volatile(lmcache:thread_current_error_stream/2).

%=

%% save_streams is semidet.
%
% Save Streams.
%
save_streams:- thread_self(ID),save_streams(ID),!.

set_mains:-
       stream_property(In, alias(user_input)),set_stream(In,alias(main_input)),
       stream_property(Out, alias(user_output)),set_stream(Out,alias(main_output)),
       find_main_eror(Err),set_stream(Err,alias(main_error)), set_stream(Err,alias(current_error)),set_stream(Err, alias(user_error)).

find_main_eror(Err):-stream_property(Err, alias(user_error)).
find_main_eror(Err):-stream_property(Err, alias(main_error)).
find_main_eror(Err):-stream_property(Err, alias(current_error)).
find_main_eror(user_error).

set_main_error:- thread_self_main->set_mains;true.


current_error_stream_ucatch(Err):-
  stream_property(Err,alias(current_error))-> true;  % when we set it
  stream_property(Err,alias(user_error)) -> true;
  stream_property(Err,file_no(2)).


%=

%% save_streams( ?ID) is semidet.
%
% Save Streams.
%
save_streams(ID):-
  retractall((lmcache:thread_current_input(ID,_))),
  retractall((lmcache:thread_current_error_stream(ID,_))),
  current_input(In),asserta(lmcache:thread_current_input(ID,In)),
  thread_at_exit(retractall((lmcache:thread_current_input(ID,_)))),
  thread_at_exit(retractall((lmcache:thread_current_error_stream(ID,_)))),
  (stream_property(Err, alias(user_error));current_error_stream_ucatch(Err)),
              asserta(lmcache:thread_current_error_stream(ID,Err)).


:- meta_predicate(with_main_input(0)).

%% with_main_input( :Goal) is semidet.
%
% Using Main Input.
%
with_main_input(Goal):-
    current_output(OutPrev),current_input(InPrev),stream_property(ErrPrev,alias(user_error)),
    lmcache:thread_main(user,ID),lmcache:thread_current_input(ID,In),lmcache:thread_current_error_stream(ID,Err),
    scce_orig(set_prolog_IO(In,OutPrev,Err),Goal,set_prolog_IO(InPrev,OutPrev,ErrPrev)).


%=

%% with_main_io( :Goal) is semidet.
%
% Using Main Input/output.
%
 with_main_io(Goal):-
    current_output(OutPrev),
    current_input(InPrev),
    stream_property(ErrPrev,alias(user_error)),
    lmcache:thread_main(user,ID),
     lmcache:thread_current_input(ID,In),
       lmcache:thread_current_error_stream(ID,Err),
    scce_orig(set_prolog_IO(In,Err,Err),Goal,set_prolog_IO(InPrev,OutPrev,ErrPrev)).


% bugger_debug=never turns off just debugging about the debugger
% dmsg_level=never turns off all the rest of debugging
% ddmsg(_):-current_prolog_flag(bugger_debug,false),!.
% ddmsg(D):- current_predicate(_:wdmsg/1),wdmsg(D),!.

%=

%% ddmsg( ?D) is semidet.
%
% Ddmsg.
%
ddmsg(D):- ddmsg("~N~q~n",[D]).
%ddmsg(F,A):- current_predicate(_:wdmsg/2),wdmsg(F,A),!.

%=

%% ddmsg( ?F, ?A) is semidet.
%
% Ddmsg.
%
ddmsg(F,A):- format_to_error(F,A),!.

%=

%% ddmsg_call( :GoalD) is semidet.
%
% Ddmsg Call.
%
ddmsg_call(D):- ( (ddmsg(ddmsg_call(D)),call(D),ddmsg(ddmsg_exit(D))) *-> true ; ddmsg(ddmsg_failed(D))).



%% doall_and_fail( :Goal) is semidet.
%
% Doall And Fail.
%
doall_and_fail(Call):- time_call(once(doall(Call))),fail.

quietly_must(G):- /*quietly*/(must(G)).


:- module_transparent((if_defined/1,if_defined/2)).

%% if_defined( ?G) is semidet.
%
% If Defined.
%
if_defined(Goal):- if_defined(Goal,((dmsg(warn_undefined(Goal))),!,fail)).

%% if_defined( ?Goal, :GoalElse) is semidet.
%
% If Defined Else.
%
if_defined(Goal,Else):- current_predicate(_,Goal)*->Goal;Else.
% if_defined(M:Goal,Else):- !, current_predicate(_,OM:Goal),!,OM:Goal;Else.
%if_defined(Goal,  Else):- current_predicate(_,OM:Goal)->OM:Goal;Else.





:- meta_predicate when_defined(:).
:- export(when_defined/1).

%=

%% when_defined( ?Goal) is semidet.
%
% When Defined.
%
when_defined(Goal):-if_defined(Goal,true).

:- if(current_predicate(run_sanity_tests/0)).
:- listing(lmcache:thread_current_error_stream/2).
:- endif.

% = :- meta_predicate(to_pi(?,?)).

%=

%% to_pi( ?P, ?M) is semidet.
%
% Converted To Predicate Indicator.
%
to_pi(P,M:P):-var(P),!,current_module(M).
to_pi(M:P,M:P):-var(P),!,current_module(M).
to_pi(Find,(M:PI)):-
 locally(flag_call(runtime_debug=false),
   (once(catch(match_predicates(Find,Found),_,fail)),Found=[_|_],!,member(M:F/A,Found),functor(PI,F,A))).
to_pi(M:Find,M:PI):-!,current_module(M),to_pi0(M,Find,M:PI).
to_pi(Find,M:PI):-current_module(M),to_pi0(M,Find,M:PI).


%=

%% to_pi0( ?M, :TermFind, :TermPI) is semidet.
%
% Converted To Predicate Indicator Primary Helper.
%
to_pi0(M,Find,M:PI):- atom(Find),!,when(nonvar(PI),(nonvar(PI),functor(PI,Find,_))).
to_pi0(M,Find/A,M:PI):-var(Find),number(A),!,when(nonvar(PI),(nonvar(PI),functor(PI,_,A))).
to_pi0(M,Find,PI):-get_pi(Find,PI0),!,(PI0\=(_:_)->(current_module(M),PI=(M:PI0));PI=PI0).


:- thread_local(t_l:last_src_loc/2).

%=

%% input_key( ?K) is semidet.
%
% Input Key.
%
input_key(K):-thread_self(K).


%=

%% show_new_src_location( ?FL) is semidet.
%
% Show New Src Location.
%
show_new_src_location(FL):-input_key(K),show_new_src_location(K,FL).


%=

%% show_new_src_location( ?K, ?FL) is semidet.
%
% Show New Src Location.
%
show_new_src_location(_,F:_):-F==user_input,!.
show_new_src_location(K,FL):- t_l:last_src_loc(K,FL),!.
show_new_src_location(K,FL):- retractall(t_l:last_src_loc(K,_)),format_to_error('~N% ~w ',[FL]),!,asserta(t_l:last_src_loc(K,FL)).


:- thread_local(t_l:current_local_why/2).
:- thread_local(t_l:current_why_source/1).


%=

%% sl_to_filename( ?W, ?W) is semidet.
%
% Sl Converted To Filename.
%
sl_to_filename(W,W):-atom(W),exists_file(W),!.
sl_to_filename(W,W):-atom(W),!.
sl_to_filename(_:W,W):-atom(W),!.
sl_to_filename(mfl(_,F,_),F):-atom(F),!.
sl_to_filename(W,W).
sl_to_filename(W,To):-nonvar(To),To=(W:_),atom(W),!.



                 


%=

%% current_source_file( -CtxColonLinePos) is semidet.
%
% Current Source Location.
%
current_source_file(F:L):- clause(current_source_location0(W,L),Body),catchv(Body,_,fail),
 sl_to_filename(W,F),!.
current_source_file(F):- F = unknown.


source_ctx(B:L):-current_source_file(F:L),file_base_name(F,B).

%=

%% current_source_location0( -Ctx, -LinePos) is semidet.
%
% Current Source Location Primary Helper.
%
current_source_location0(F,why):- t_l:current_why_source(F).
current_source_location0(F,L):-source_location(F,L),!.
current_source_location0(F,L):-prolog_load_context(file,F),current_input(S),line_position(S,L),!.
current_source_location0(F,loading_file):-loading_file(F).
current_source_location0(F,L):- prolog_load_context(file,F),!,ignore((prolog_load_context(stream,S),!,line_count(S,L))),!.
current_source_location0(F,L):- current_input(S),stream_property(S,position(L)),stream_property(S,alias(F)).
current_source_location0(M,source):- source_module(M),!.
current_source_location0(F,L):- current_filesource(F),ignore((prolog_load_context(stream,S),!,line_count(S,L))),!.
current_source_location0(M,typein):- '$current_typein_module'(M).

:-export(current_why/1).
:-module_transparent(current_why/1).

%=

%% current_why( ?Why) is semidet.
%
% Current Generation Of Proof.
%
current_why(Why):- t_l:current_local_why(Why,_),!.
current_why(mfl(M,F,L)):- current_source_file(F:L),var(L),F= module(M),!.
current_why(mfl(M,F,L)):- source_module(M),call(ereq,mtHybrid(M)),current_source_file(F:L),!.
current_why(mfl(M,F,L)):- call(ereq,defaultAssertMt(M)),current_source_file(F:L),!.


%% with_current_why( +Why, +:Prolog) is semidet.
%
% Save Well-founded Semantics Reason while executing code.
%
with_current_why(Why,Prolog):- locally(t_l:current_local_why(Why,Prolog),Prolog).


% source_module(M):-!,M=u.
:-export(source_module/1).

%=

%% source_module( ?M) is semidet.
%
% Source Module.
%
source_module(M):-nonvar(M),!,source_module(M0),!,(M0=M).
source_module(M):-'$current_source_module'(M),!.
source_module(M):-loading_module(M),!.

:- thread_local(t_l:last_source_file/1).
:- export(loading_file/1).

%=

%% loading_file( ?FIn) is semidet.
%
% Loading File.
%
loading_file(FIn):- ((source_file0(F) *-> (retractall(t_l:last_source_file(_)),asserta(t_l:last_source_file(F))) ; (fail,t_l:last_source_file(F)))),!,F=FIn.

%=

%% source_file0( ?F) is semidet.
%
% Source File Primary Helper.
%
source_file0(F):-source_location(F,_).
source_file0(F):-prolog_load_context(file, F).
source_file0(F):-prolog_load_context(source, F).
source_file0(F):-seeing(S),is_stream(S),stream_property(S,file_name(F)),exists_file(F).
source_file0(F):-prolog_load_context(stream, S),stream_property(S,file_name(F)),exists_file(F).
source_file0(F):-findall(E,catch((stream_property( S,mode(read)),stream_property(S,file_name(E)),exists_file(E),
  line_count(S,Goal),Goal>0),_,fail),L),last(L,F).


:-export(source_variables_l/1).

%=

%% source_variables_l( ?AllS) is semidet.
%
% Source Variables (list Version).
%
source_variables_l(AllS):-
 quietly((
  (prolog_load_context(variable_names,Vs1);Vs1=[]),
  (get_varname_list(Vs2);Vs2=[]),
  quietly(catch((parent_goal('$toplevel':'$execute_goal2'(_, Vs3),_);Vs3=[]),E,(writeq(E),Vs3=[]))),
  ignore(Vs3=[]),
  append(Vs1,Vs2,Vs12),append(Vs12,Vs3,All),!,list_to_set(All,AllS),
  set_varname_list( AllS))).



%=




%% show_source_location is semidet.
%
% Show Source Location.
%
:-export( show_source_location/0).
show_source_location:- current_prolog_flag(dmsg_level,never),!.
%show_source_location:- quietly((tlbugger:no_slow_io)),!.
show_source_location:- source_location(F,L),!,show_new_src_location(F:L),!.
show_source_location:- current_source_file(FL),sanity(nonvar(FL)),!,show_new_src_location(FL),!.
show_source_location:- dumpST,dtrace.


% :- ensure_loaded(hook_database).

:-export( as_clause_no_m/3).

%=

%% as_clause_no_m( ?MHB, ?H, ?B) is semidet.
%
% Converted To Clause No Module.
%
as_clause_no_m( MHB,  H, B):- strip_module(MHB,_M,HB), expand_to_hb( HB,  MH, MB),strip_module(MH,_M2H,H),strip_module(MB,_M2B,B).

%=

%% as_clause_w_m( ?MHB, ?M, ?H, ?B) is semidet.
%
% Converted To Clause W Module.
%
as_clause_w_m(MHB, M, H, B):-  as_clause_w_m(MHB, M1H, H, B, M2B), (M1H==user->M2B=M;M1H=M).

%=

%% as_clause_w_m( ?MHB, ?M1H, ?H, ?B, ?M2B) is semidet.
%
% Converted To Clause W Module.
%
as_clause_w_m(MHB, M1H, H, B, M2B):-  expand_to_hb( MHB,  MH, MB),strip_module(MH,M1H,H),strip_module(MB,M2B,B).

:- export(is_ftCompound/1).

%% is_ftNameArity(+F,+A) is semidet.
%
% If Is A Format Type of a Compound specifier
%
is_ftNameArity(F,A):-integer(A), atom(F), (F \= (/)),A>=0.

%% is_ftCompound( ?Goal) is semidet.
%
% If Is A Format Type Compound.
%
is_ftCompound(Goal):-compound(Goal),\+ is_ftVar(Goal).

%% not_ftCompound( ?InOut) is semidet.
%
% Not Compound.
%
not_ftCompound(A):- \+ is_ftCompound(A).

:- export(is_ftVar/1).

%% is_ftVar( :TermV) is semidet.
%
% If Is A Format Type Variable.
%
is_ftVar(V):- quietly(is_ftVar0(V)).
is_ftVar0(V):- \+ compound(V),!,var(V).
is_ftVar0('$VAR'(_)).
is_ftVar0('avar'(_,_)).
%:- mpred_trace_nochilds(is_ftVar/1).

ftVar(X):- is_ftVar(X).
ftCompound(X):- is_ftCompound(X).
ftNonvar(X):- is_ftNonvar(X).

:- export(is_ftNonvar/1).

%=

%% is_ftNonvar( ?V) is semidet.
%
% If Is A Format Type Nonvar.
%
is_ftNonvar(V):- \+ is_ftVar(V).


%================================================================
% maplist/[2,3]
% this must succeed  maplist_safe(=,[Goal,Goal,Goal],[1,2,3]).
% well if its not "maplist" what shall we call it?
%================================================================
% so far only the findall version works .. the other runs out of local stack!?

:- export((   maplist_safe/2,
   maplist_safe/3)).


%=

%% maplist_safe( ?Pred, ?LIST) is semidet.
%
% Maplist Safely Paying Attention To Corner Cases.
%
maplist_safe(_Pred,[]):-!.
maplist_safe(Pred,LIST):-findall(E,(member(E,LIST), on_f_debug(apply(Pred,[E]))),LISTO),!, ignore(LIST=LISTO),!.
% though this should been fine %  maplist_safe(Pred,[A|B]):- copy_term(Pred+A, Pred0+A0), on_f_debug(once(call(Pred0,A0))),     maplist_safe(Pred,B),!.


%=

%% maplist_safe( ?Pred, ?LISTIN, ?LIST) is semidet.
%
% Maplist Safely Paying Attention To Corner Cases.
%
maplist_safe(_Pred,[],[]):-!.
maplist_safe(Pred,LISTIN, LIST):-!, findall(EE, ((member(E,LISTIN),on_f_debug(apply(Pred,[E,EE])))), LISTO),  ignore(LIST=LISTO),!.
% though this should been fine % maplist_safe(Pred,[A|B],OUT):- copy_term(Pred+A, Pred0+A0), debugOnFailureEach(once(call(Pred0,A0,AA))),  maplist_safe(Pred,B,BB), !, ignore(OUT=[AA|BB]).



:- export(bad_functor/1).

%=

%% bad_functor( ?L) is semidet.
%
% Bad Functor.
%
bad_functor(L) :- arg(_,v('|','.',[],':','/'),L).

:- export(warn_bad_functor/1).

%=

%% warn_bad_functor( ?L) is semidet.
%
% Warn Bad Functor.
%
warn_bad_functor(L):-ignore((quietly(bad_functor(L)),!,dtrace,call(ddmsg(bad_functor(L))),break)).

:- export(strip_f_module/2).

%=

%% strip_f_module( ?P, ?PA) is semidet.
%
% Strip Functor Module.
%
strip_f_module(_:P,FA):-nonvar(P),!,strip_f_module(P,F),!,F=FA.
strip_f_module(P,PA):-atom(P),!,P=PA.

strip_f_module(P,FA):- is_list(P),catch(text_to_string(P,S),_,fail),!,maybe_notrace(atom_string(F,S)),!,F=FA.
strip_f_module(P,FA):- quietly(string(P);atomic(P)), maybe_notrace(atom_string(F,P)),!,F=FA.
strip_f_module(P,P).

% use catchv/3 to replace catch/3 works around SWI specific issues arround using $abort/0 and block/3
% (catch/3 allows you to have these exceptions bubble up past your catch block handlers)
% = :- meta_predicate((catchv(0, ?, 0))).
% = :- meta_predicate((catchv(0, ?, 0))).
:- export((catchv/3,catchv/3)).


%! catchv( :Goal, ?E, :GoalRecovery) is nondet.
%
%  Like catch/3 but rethrows block/2 and $abort/0.
%
catchv(Goal,E,Recovery):- 
   nonvar(E) 
   -> catch(Goal,E,Recovery); % normal mode (the user knows what they want)
   catch(Goal,E,(rethrow_bubbled(E),Recovery)). % prevents promiscous mode

%! bubbled_ex( ?Ex) is det.
%
% Bubbled Exception.
%
bubbled_ex('$aborted').
bubbled_ex('time_limit_exceeded').
bubbled_ex('$time_limit_exceeded').
bubbled_ex(block(_,_)).


%! rethrow_bubbled( ?E) is det.
%
% Bubbled Exception Check.
%
rethrow_bubbled(E):- ( \+ bubbled_ex(E)),!.
rethrow_bubbled(E):-throw(E).



:- export(functor_catch/3).

%=

%% functor_catch( ?P, ?F, ?A) is semidet.
%
% Functor Catch.
%
functor_catch(P,F,A):- catchv(functor(P,F,A),_,compound_name_arity(P,F,A)).
% functor_catch(F,F,0):-atomic(F),!.
% functor_catch(P,F,A):-catchv(compound_name_arity(P,F,A),E,(ddmsg(E:functor(P,F,A)),dtrace)).


:- export(functor_safe/3).

%=

%% functor_safe( ?P, ?F, ?A) is semidet.
%
% Functor Safely Paying Attention To Corner Cases.
%
functor_safe(P,F,A):- (compound(P)->compound_name_arity(P,F,A);functor(P,F,A)),sanity(warn_bad_functor(F)).
% functor_safe(P,F,A):- catchv(functor(P,F,A),_,compound_name_arity(P,F,A)).
% functor_safe(P,F,A):- catchv(compound_name_arity(P,F,A),_,functor(P,F,A)).
/*
% functor_safe(P,F,A):-var(P),A==0,compound_name_arguments(P,F,[]),!.
functor_safe(P,F,A):-var(P),A==0,!,P=F,!.
functor_safe(P,F,A):-functor_safe0(P,F,A),!.
functor_safe0(M:P,M:F,A):-var(P),atom(M),functor_catch(P,F,A),!,warn_bad_functor(F).
functor_safe0(P,F,A):-var(P),strip_f_module(F,F0),functor_catch(P,F0,A),!,warn_bad_functor(F).
functor_safe0(P,F,0):- quietly(string(P);atomic(P)), maybe_notrace(atom_string(F,P)),warn_bad_functor(F).
functor_safe_compound((_,_),',',2).
functor_safe_compound([_|_],'.',2).
functor_safe_compound(_:P,F,A):- functor_catch(P,F,A),!.
functor_safe_compound(P,F,A):- functor_catch(P,F,A).
functor_safe_compound(P,F,A):- var(F),strip_f_module(P,P0),!,functor_catch(P0,F0,A),strip_f_module(F0,F),!.
functor_safe_compound(P,F,A):- strip_f_module(P,P0),strip_f_module(F,F0),!,functor_catch(P0,F0,A).
*/

% block3(test, (repeat, !(test), fail))).
:- meta_predicate block3(+, :, ?).

%=

%% block3( +Name, ?Goal, ?Var) is semidet.
%
% Block.
%
block3(Name, Goal, Var) :- Goal, keep(Name, Var).	% avoid last-call and GC

%=

%% keep( ?VALUE1, ?VALUE2) is semidet.
%
% Keep.
%
keep(_, _).

%=

%% set_block_exit( ?Name, ?Value) is semidet.
%
% Set Block Exit.
%
set_block_exit(Name, Value) :-  prolog_current_frame(Frame), 
   prolog_frame_attribute(Frame, parent_goal,  mcall:block3(Name, _, Value)).

%=

%% block( ?Name, ?Goal) is semidet.
%
% Block.
%
block(Name, Goal) :-  block3(Name, Goal, Var),  (   Var == !  ->  !  ;   true  ).

%=

%% !( ?Name) is semidet.
%
% !.
%
!(Name) :- set_block_exit(Name, !).

:- export((block3/3,
            set_block_exit/2,
            (block)/2,
            !/1 )).

:- dynamic(buggerFile/1).
:- abolish(buggerFile/1),prolog_load_context(source,D),asserta(buggerFile(D)).


% hasLibrarySupport :- absolute_file_name('logicmoo_util_library.pl',File),exists_file(File).


%=

%% throwNoLib is semidet.
%
% Throw No Lib.
%
throwNoLib:- dtrace,absolute_file_name('.',Here), buggerFile(BuggerFile), listing(user:library_directory), trace_or_throw(error(existence_error(url, BuggerFile), context(_, status(404, [BuggerFile, from( Here) ])))).

:- dynamic(buggerDir/1).
:- abolish(buggerDir/1),prolog_load_context(directory,D),asserta(buggerDir(D)).


%=

%% addLibraryDir is semidet.
%
% Add Library Dir.
%
addLibraryDir :- buggerDir(Here),atom_concat(Here,'/..',UpOne), absolute_file_name(UpOne,AUpOne),asserta(user:library_directory(AUpOne)).

% if not has library suport, add this direcotry as a library directory
% :-not(hasLibrarySupport) -> addLibraryDir ; true .

% :-hasLibrarySupport->true;throwNoLib.





%=

%% ib_multi_transparent33( ?MT) is semidet.
%
% Ib Multi Transparent33.
%
ib_multi_transparent33(MT):-multifile(MT),module_transparent(MT),dynamic_safe(MT).


%=

%% dif_safe( ?Agent, ?Obj) is semidet.
%
% Dif Safely Paying Attention To Corner Cases.
%
dif_safe(Agent,Obj):- (var(Agent);var(Obj)),!.
dif_safe(Agent,Obj):- Agent\==Obj.

% hide Pred from tracing

%=

%% to_m_f_arity_pi( ?Term, ?M, ?F, ?A, ?PI) is semidet.
%
% Converted To Module Functor Arity Predicate Indicator.
%
to_m_f_arity_pi(M:Plain,M,F,A,PI):-!,to_m_f_arity_pi(Plain,M,F,A,PI).
to_m_f_arity_pi(Term,M,F,A,PI):- strip_module(Term,M,Plain),Plain\==Term,!,to_m_f_arity_pi(Plain,M,F,A,PI).
to_m_f_arity_pi(F/A,_M,F,A,PI):-functor_safe(PI,F,A),!.
to_m_f_arity_pi(PI,_M,F,A,PI):-functor_safe(PI,F,A).


%=

%% with_preds( ?H, ?M, ?F, ?A, ?PI, :Goal) is semidet.
%
% Using Predicates.
%
with_preds((H,Y),M,F,A,PI,Goal):-!,with_preds(H,M,F,A,PI,Goal),with_preds(Y,M,F,A,PI,Goal).
with_preds([H],M,F,A,PI,Goal):-!,with_preds(H,M,F,A,PI,Goal).
with_preds([H|Y],M,F,A,PI,Goal):-!,with_preds(H,M,F,A,PI,Goal),with_preds(Y,M,F,A,PI,Goal).
with_preds(M:H,_M,F,A,PI,Goal):-!, with_preds(H,M,F,A,PI,Goal).
with_preds(H,M,F,A,PI,Goal):-forall(to_m_f_arity_pi(H,M,F,A,PI),Goal).



% ===================================================================
% Substitution based on ==
% ===================================================================
% Usage: dbgsubst(+Fml,+Goal,+Sk,?FmlSk)

:- export(dbgsubst/4).

%=

%% dbgsubst( ?A, ?B, ?Goal, ?A) is semidet.
%
% Dbgsubst.
%
dbgsubst(A,B,Goal,A):- B==Goal,!.
dbgsubst(A,B,Goal,D):-var(A),!,ddmsg(dbgsubst(A,B,Goal,D)),dumpST,dtrace(dbgsubst0(A,B,Goal,D)).
dbgsubst(A,B,Goal,D):-dbgsubst0(A,B,Goal,D).


%=

%% dbgsubst0( ?A, ?B, ?Goal, ?D) is semidet.
%
% Dbgsubst Primary Helper.
%
dbgsubst0(A,B,Goal,D):-
      catchv(quietly(nd_dbgsubst(A,B,Goal,D)),E,(dumpST,ddmsg(E:nd_dbgsubst(A,B,Goal,D)),fail)),!.
dbgsubst0(A,_B,_C,A).


%=

%% nd_dbgsubst( ?Var, ?VarS, ?SUB, ?SUB) is semidet.
%
% Nd Dbgsubst.
%
nd_dbgsubst(  Var, VarS,SUB,SUB ) :- Var==VarS,!.
nd_dbgsubst(  P, Goal,Sk, P1 ) :- functor_safe(P,_,N),nd_dbgsubst1( Goal, Sk, P, N, P1 ).


%=

%% nd_dbgsubst1( ?Goal, ?Sk, ?P, ?N, ?P1) is semidet.
%
% Nd Dbgsubst Secondary Helper.
%
nd_dbgsubst1( _,  _, P, 0, P  ).
nd_dbgsubst1( Goal, Sk, P, N, P1 ) :- N > 0, P =.. [F|Args],
            nd_dbgsubst2( Goal, Sk, Args, ArgS ),
            nd_dbgsubst2( Goal, Sk, [F], [FS] ),
            P1 =.. [FS|ArgS].


%=

%% nd_dbgsubst2( ?X, ?Sk, ?L, ?L) is semidet.
%
% Nd Dbgsubst Extended Helper.
%
nd_dbgsubst2( _,  _, [], [] ).
nd_dbgsubst2( Goal, Sk, [A|As], [Sk|AS] ) :- Goal == A, !, nd_dbgsubst2( Goal, Sk, As, AS).
nd_dbgsubst2( Goal, Sk, [A|As], [A|AS]  ) :- var(A), !, nd_dbgsubst2( Goal, Sk, As, AS).
nd_dbgsubst2( Goal, Sk, [A|As], [Ap|AS] ) :- nd_dbgsubst( A,Goal,Sk,Ap ),nd_dbgsubst2( Goal, Sk, As, AS).
nd_dbgsubst2( _X, _Sk, L, L ).



%=========================================
% Module Utils
%=========================================

%=

%% module_functor( ?PredImpl, ?Module, ?Pred, ?Arity) is semidet.
%
% Module Functor.
%
module_functor(PredImpl,Module,Pred,Arity):-strip_module(PredImpl,Module,NewPredImpl),strip_arity(NewPredImpl,Pred,Arity).


%=

%% strip_arity( ?PredImpl, ?Pred, ?Arity) is semidet.
%
% Strip Arity.
%
strip_arity(Pred/Arity,Pred,Arity).
strip_arity(PredImpl,Pred,Arity):-functor_safe(PredImpl,Pred,Arity).

/*

debug(+Topic, +Format, +Arguments)
Prints a message using format(Format, Arguments) if Topic unies with a topic
enabled with debug/1.
debug/nodebug(+Topic [>le])
Enables/disables messages for which Topic unies. If >le is added, the debug
messages are appended to the given le.
assertion(:Goal)
Assumes that Goal is true. Prints a stack-dump and traps to the debugger otherwise.
This facility is derived from the assert() macro as used in Goal, renamed
for obvious reasons.
*/
:- meta_predicate with_preds(?,?,?,?,?,0).



%set_prolog_flag(N,V):-!,nop(set_prolog_flag(N,V)).


% have to load this module here so we dont take ownership of prolog_exception_hook/4.
:- set_prolog_flag(generate_debug_info, true).
% have to load this module here so we dont take ownership of prolog_exception_hook/4.

% :- ensure_loaded(library(backcomp)).
:- ensure_loaded(library(ansi_term)).
:- ensure_loaded(library(check)).
:- ensure_loaded(library(debug)).
:- ensure_loaded(library(lists)).
:- ensure_loaded(library(make)).
:- ensure_loaded(library(system)).
:- ensure_loaded(library(apply)).

:- thread_local(t_l:session_id/1).
:- multifile(t_l:session_id/1).

:- thread_local(tlbugger:no_colors/0).


% =========================================================================


%=

%% trace_or_throw( ?E) is semidet.
%
%  Trace or throw.
%
trace_or_throw(E):- hide_non_user_console,quietly((thread_self(Self),wdmsg(thread_trace_or_throw(Self+E)),!,throw(abort),
                    thread_exit(trace_or_throw(E)))).
trace_or_throw(E):- wdmsg(trace_or_throw(E)),trace,break,dtrace((dtrace,throw(E))).
programmer_error(E):-trace,  randomVars(E),dmsg('~q~n',[error(E)]),trace,randomVars(E),!,throw(E).

 %:-interactor.


% false = hide this wrapper

%=

%% showHiddens is semidet.
%
% Show Hiddens.
%
showHiddens:-true.

:- meta_predicate on_x_log_fail(0).
:- export(on_x_log_fail/1).

%=

%% on_x_log_fail( :Goal) is semidet.
%
% If there If Is A an exception in  :Goal goal then log fail.
%
on_x_log_fail(Goal):- catchv(Goal,E,(dmsg(E:Goal),fail)).

on_xf_log_cont(Goal):- (on_x_log_cont(Goal)*->true;dmsg(on_f_log_cont(Goal))).

on_xf_log_cont_l(Goal):- call_each(on_xf_log_cont,Goal).

% -- CODEBLOCK

:- export(on_x_log_throw/1).
:- export(on_x_log_cont/1).

%=

%% on_x_log_throw( :Goal) is semidet.
%
% If there If Is A an exception in  :Goal goal then log throw.
%
on_x_log_throw(Goal):- catchv(Goal,E,(ddmsg(on_x_log_throw(E,Goal)),throw(E))).
%on_x_log_throwEach(Goal):-with_each(1,on_x_log_throw,Goal).

%=

%% on_x_log_cont( :Goal) is semidet.
%
% If there If Is A an exception in  :Goal goal then log cont.
%
on_x_log_cont(Goal):- catchv( (Goal*->true;ddmsg(failed_on_x_log_cont(Goal))),E,ddmsg(E:Goal)).

:- thread_local( tlbugger:skipMust/0).
%MAIN tlbugger:skipMust.


:- export(errx/0).

%=

%% errx is semidet.
%
% Errx.
%
errx:-on_x_debug((ain(tlbugger:dont_skip_bugger),do_gc,dumpST(10))),!.

:- thread_local(tlbugger:rtracing/0).



/*

A value 0 means that the corresponding quality is totally unimportant, and 3 that the quality is extremely important; 
1 and 2 are intermediate values, with 1 the neutral value. (quality 3) can be abbreviated to quality.

*/
compute_q_value(N,N):- number(N),!.
compute_q_value(false,0).
compute_q_value(neutral,1).
compute_q_value(true,2).
compute_q_value(quality,3).
compute_q_value(Flag,Value):-current_prolog_flag(Flag,M),!,compute_q_value(M,Value).
compute_q_value(N,1):- atom(N).
compute_q_value(N,V):- V is N.

/*

Name                        Meaning
---------------------       --------------------------------
logicmoo_compilation_speed  speed of the compilation process   

runtime_debug              ease of debugging                  
logicmoo_space              both code size and run-time space  

runtime_safety             run-time error checking            
runtime_speed              speed of the object code

unsafe_speedups      speed up that are possibily

*/
flag_call(FlagHowValue):-quietly(flag_call0(FlagHowValue)).
flag_call0(Flag = Quality):- compute_q_value(Quality,Value),!, set_prolog_flag(Flag,Value).
flag_call0(FlagHowValue):- FlagHowValue=..[How,Flag,Value],
    compute_q_value(Flag,QVal),compute_q_value(Value,VValue),!,call(How,QVal,VValue).



%=

%% skipWrapper is semidet.
%
% Skip Wrapper.
%

% false = use this wrapper, true = code is good and avoid using this wrapper
:- export(skipWrapper/0).

% skipWrapper:-!.
skipWrapper:- quietly((ucatch:skipWrapper0)).

skipWrapper0:- current_prolog_flag(bugger,false),!.
skipWrapper0:- tracing, \+ tlbugger:rtracing,!.
skipWrapper0:- tlbugger:dont_skip_bugger,!,fail.
%skipWrapper0:- flag_call(runtime_debug true) ,!,fail.
%skipWrapper0:- current_prolog_flag(unsafe_speedups , true) ,!.
skipWrapper0:- tlbugger:skip_bugger,!.
%skipWrapper0:- is_release,!.
%skipWrapper0:- 1 is random(5),!.
%skipWrapper0:- tlbugger:skipMust,!.

:- '$hide'(skipWrapper/0).

%MAIN tlbugger:skip_bugger.


% = :- meta_predicate(one_must(0,0)).

%=

%% one_must( :GoalMCall, :GoalOnFail) is semidet.
%
% One Must Be Successfull.
%
one_must(MCall,OnFail):-  call(MCall) *->  true ; call(OnFail).



%=

%% must_det_u( :Goal) is semidet.
%
% Must Be Successfull Deterministic.
%
must_det_u(Goal):- !,maybe_notrace(Goal),!.
must_det_u(Goal):- Goal->true;ignore(rtrace(Goal)).


%=

%% one_must_det( :Goal, :GoalOnFail) is semidet.
%
% One Must Be Successfull Deterministic.
%
one_must_det(Goal,_OnFail):-Goal,!.
one_must_det(_Call,OnFail):-OnFail,!.


%=

%% must_det_dead( :Goal, :GoalOnFail) is semidet.
%
% Must Be Successfull Deterministic.
%
%must_det_dead(Goal,OnFail):- trace_or_throw(deprecated(must_det_u(Goal,OnFail))),Goal,!.
%must_det_dead(_Call,OnFail):-OnFail.

:- module_transparent(must_det_l/1).

%=

%% must_det_l( :GoalMGoal) is semidet.
%
% Must Be Successfull Deterministic (list Version).
%
must_det_l(Goal):- call_each(must_det_u,Goal).

must_det_l_pred(Pred,Rest):- tlbugger:skip_bugger,!,call(Pred,Rest).
must_det_l_pred(Pred,Rest):- call_each(call_must_det(Pred),Rest).

call_must_det(Pred,Arg):- must_det_u(call(Pred,Arg)),!.

is_call_var(Goal):- strip_module(Goal,_,P),var(P).

call_each(Pred,Goal):- (is_call_var(Pred);is_call_var(Goal)),!,trace_or_throw(var_call_each(Pred,Goal)),!.
call_each(Pred,[Goal]):- !, dmsg(trace_syntax(call_each(Pred,[Goal]))),!,call_each(Pred,Goal).
call_each(Pred,[Goal|List]):- !, dmsg(trace_syntax(call_each(Pred,[Goal|List]))), !, call_each(Pred,Goal),!,call_each(Pred,List).
% call_each(Pred,Goal):-tlbugger:skip_bugger,!,p_call(Pred,Goal).
call_each(Pred,M:(Goal,List)):-!, call_each(Pred,M:Goal),!,call_each(Pred,M:List).
call_each(Pred,(Goal,List)):- !, call_each(Pred,Goal),!,call_each(Pred,List).
call_each(Pred,Goal):- p_call(Pred,Goal),!.

% p_call(Pred,_:M:Goal):-!,p_call(Pred,M:Goal).
p_call([Pred1|PredS],Goal):-!,p_call(Pred1,Goal),p_call(PredS,Goal).
p_call((Pred1,PredS),Goal):-!,p_call(Pred1,Goal),p_call(PredS,Goal).
p_call((Pred1;PredS),Goal):-!,p_call(Pred1,Goal);p_call(PredS,Goal).
p_call(Pred,Goal):-call(Pred,Goal).

must_find_and_call(G):-must(G).

:- module_transparent(det_lm/2).

%=

%% det_lm( ?M, ?Goal) is semidet.
%
% Deterministic Lm.
%
det_lm(M,(Goal,List)):- !,Goal,!,det_lm(M,List).
det_lm(M,Goal):-M:Goal,!.

:- module_transparent(must_l/1).

%=

%% must_l( :Goal) is semidet.
%
% Must Be Successfull (list Version).
%
must_l(Goal):- skipWrapper,!,call(Goal).
must_l(Goal):- var(Goal),trace_or_throw(var_must_l(Goal)),!.
must_l((A,!,B)):-!,must(A),!,must_l(B).
must_l((A,B)):-!,must((A,deterministic(Det),true,(Det==true->(!,must_l(B));B))).
must_l(Goal):- must(Goal).


:- thread_local tlbugger:skip_use_slow_sanity/0.
:- asserta((tlbugger:skip_use_slow_sanity:-!)).

% thread locals should defaults to false  tlbugger:skip_use_slow_sanity.


%=

%% slow_sanity( :Goal) is semidet.
%
% Slow Optional Sanity Checking.
%
slow_sanity(Goal):- ( tlbugger:skip_use_slow_sanity ; must(Goal)),!.


:- meta_predicate(hide_trace(0)).

hide_trace(G):- \+ tracing,!,call(G).
hide_trace(G):- !,call(G).
hide_trace(G):- skipWrapper,!,call(G).
hide_trace(G):-
 restore_trace((
   quietly(
      ignore((tracing,
      visible(-all),
      visible(-unify),
      visible(+exception),
      maybe_leash(-all),
      maybe_leash(+exception)))),G)).

:- meta_predicate(on_x_f(0,0,0)).
on_x_f(G,X,F):-catchv(G,E,(dumpST,wdmsg(E),X)) *-> true ; F .

% :- meta_predicate quietly(0).
:- '$hide'(quietly/1).
quietly(G):-hotrace(G).
% quietly(G):- skipWrapper,!,call(G).
% quietly(G):- !,quietly(G).
% quietly(G):- !, on_x_f((G),setup_call_cleanup(wdmsg(begin_eRRor_in(G)),rtrace(G),wdmsg(end_eRRor_in(G))),fail).
/*quietly(G):- on_x_f(hide_trace(G),
                     setup_call_cleanup(wdmsg(begin_eRRor_in(G)),rtrace(G),wdmsg(end_eRRor_in(G))),
                     fail).
*/

:- if(current_prolog_flag(optimise,true)).
is_recompile:-fail.
:- else.
is_recompile:-fail.
:- endif.

% -- CODEBLOCK
% :- export(7sanity/1).
% = :- meta_predicate(sanity(0)).



compare_results(N+NVs,O+OVs):-
   NVs=@=OVs -> true; trace_or_throw(compare_results(N,O)).

allow_unsafe_code :- fail.

unsafe_safe(_,O):- \+ allow_unsafe_code, !, call(O).
unsafe_safe(N,O):- on_diff_throw(N,O).

:- export(need_speed/0).
need_speed:-current_prolog_flag(unsafe_speedups , true) .

:- export(is_release/0).
%% is_release is semidet.
%
% If Is A Release.

is_release:- current_prolog_flag(unsafe_speedups, false) ,!,fail.
is_release:- !,fail.
is_release:- current_prolog_flag(unsafe_speedups , true) ,!.
is_release:- quietly((\+ flag_call(runtime_debug == true) , \+ (1 is random(4)))).



%% not_is_release is semidet.
%
% Not If Is A Release.
%
:- export(not_is_release/0).
not_is_release:- \+ is_release.



:- thread_local tlbugger:show_must_go_on/0.

%=

%% badfood( ?MCall) is semidet.
%
% Badfood.
%
badfood(MCall):- numbervars(MCall,0,_,[functor_name('VAR_______________________x0BADF00D'),attvar(bind),singletons(false)]),dumpST.

% -- CODEBLOCK
:- export(without_must/1).
% = :- meta_predicate(without_must(0)).


%=

%% without_must( :Goal) is semidet.
%
% Without Must Be Successfull.
%
without_must(Goal):- locally(tlbugger:skipMust,Goal).

% -- CODEBLOCK
:- export(y_must/2).
:- meta_predicate (y_must(?,0)).

%=

%% y_must( ?Y, :Goal) is semidet.
%
% Y Must Be Successfull.
%
y_must(Y,Goal):- catchv(Goal,E,(wdmsg(E:must_xI__xI__xI__xI__xI_(Y,Goal)),fail)) *-> true ; dtrace(y_must(Y,Goal)).

% -- CODEBLOCK
% :- export(must/1).
%:- meta_predicate(must(0)).
%:- meta_predicate(must(0)).

%=


dumpST_error(Msg):- quietly((ddmsg(error,Msg),dumpST,wdmsg(error,Msg))).

%=

%% get_must( ?Goal, ?CGoal) is semidet.
%
% Get Must Be Successfull.
%
%get_must(quietly(Goal),CGoal):-  fail, !,get_must(Goal,CGoal).
get_must(M:Goal,M:CGoal):- must_be(nonvar,Goal), !,get_must(Goal,CGoal).
get_must(quietly(Goal),CGoal):- !,get_must((quietly(Goal)*->true;Goal),CGoal).
get_must(Goal,CGoal):-  (tlbugger:show_must_go_on; hide_non_user_console),!,
 CGoal = ((catchv(Goal,E,
     quietly(((dumpST_error(sHOW_MUST_go_on_xI__xI__xI__xI__xI_(E,Goal)),ignore(rtrace(Goal)),badfood(Goal)))))
            *-> true ;
              quietly(dumpST_error(sHOW_MUST_go_on_failed_F__A__I__L_(Goal))),ignore(rtrace(Goal)),badfood(Goal))).

get_must(Goal,CGoal):-  (tlbugger:skipMust),!,CGoal = Goal.
get_must(Goal,CGoal):- !, (CGoal = (on_x_debug(Goal) *-> true; debugCallWhy(failed(on_f_debug(Goal)),Goal))).
% get_must(Goal,CGoal):- !, CGoal = (Goal *-> true ; ((dumpST_error(failed_FFFFFFF(must(Goal))),dtrace(Goal)))).

%get_must(Goal,CGoal):- !, CGoal = (catchv(Goal,E,(notrace,ddmsg(eXXX(E,must(Goal))),rtrace(Goal),dtrace,!,throw(E))) *-> true ; ((ddmsg(failed(must(Goal))),dtrace,Goal))).
get_must(Goal,CGoal):-
   (CGoal = (catchv(Goal,E,
     ignore_each(((dumpST_error(must_xI_(E,Goal)), %set_prolog_flag(debug_on_error,true),
         rtrace(Goal),nortrace,dtrace(Goal),badfood(Goal)))))
         *-> true ; (dumpST,ignore_each(((dtrace(must_failed_F__A__I__L_(Goal),Goal),badfood(Goal))))))).

:- '$hide'(get_must/2).

:- thread_self_main.
:- save_streams.
:- initialization(save_streams,now).
:- initialization(save_streams,after_load).
:- initialization(save_streams,restore).


:- setup_call_cleanup(true,set_main_error,notrace).
:- initialization(set_main_error).
:- initialization(set_main_error,after_load).
:- initialization(set_main_error,restore).
:- notrace.

%:- 'mpred_trace_none'(ddmsg(_)).
%:- 'mpred_trace_none'(ddmsg(_,_)).


sanity2(_Loc,Goal):- sanity(Goal).
must2(_Loc,Goal):- must(Goal).

ge_expand_goal(G,G):- \+ compound(G),!,fail.
ge_expand_goal(G,GO):- expand_goal(G,GO).

% ge_must_sanity(sanity(_),true).
% ge_must_sanity(must(Goal),GoalO):-ge_expand_goal(Goal,GoalO).
% ge_must_sanity(find_and_call(Goal),GoalO):-ge_expand_goal(Goal,GoalO).

% ge_must_sanity(sanity(Goal),nop(sanity(GoalO))):- ge_expand_goal(Goal,GoalO).
% ge_must_sanity(must(Goal),(GoalO*->true;debugCallWhy(failed_must(Goal,FL),GoalO))):- source_ctx(FL),ge_expand_goal(Goal,GoalO).

ge_must_sanity(P,O):- P=..[F,Arg],nonvar(Arg),ge_must_sanity(F,Arg,O).

ge_must_sanity(sanity,Goal,sanity2(FL,Goal)):- source_ctx(FL).
ge_must_sanity(must,Goal,must2(FL,Goal)):- source_ctx(FL).
% ge_must_sanity(must_det_l,Goal,must2(FL,Goal)):- source_ctx(FL).

system:goal_expansion(I,P,O,P):- compound(I), source_location(_,_), once(ge_must_sanity(I,O)),I \== O.

:- dynamic(inlinedPred/1).

/*
system:goal_expansion(I,O):- fail, compound(I),functor(I,F,A),inlinedPred(F/A),
  source_location(File,L),clause(I,Body),O= (file_line(F,begin,File,L),Body,file_line(F,end,File,L)).
*/

file_line(F,What,File,L):- (debugging(F)->wdmsg(file_line(F,What,File,L));true).


:- ignore((source_location(S,_),prolog_load_context(module,M),module_property(M,class(library)),
 forall(source_file(M:H,S),
 ignore((functor(H,F,A),
  ignore(((\+ atom_concat('$',_,F),(export(F/A) , current_predicate(system:F/A)->true; system:import(M:F/A))))),
  ignore(((\+ predicate_property(M:H,transparent), module_transparent(M:F/A), \+ atom_concat('__aux',_,F),debug(modules,'~N:- module_transparent((~q)/~q).~n',[F,A]))))))))).


:- fixup_exports.
% :- set_prolog_flag(compile_meta_arguments,true).



:- meta_predicate with_output_to_each(+,0).

with_output_to_each(Output,Goal):- Output= atom(A),!,
   current_output(Was),
   nb_setarg(1,Output,""),
   new_memory_file(Handle),
   open_memory_file(Handle,write,Stream,[free_on_close(true)]),
     scce_orig(set_output(Stream),
      setup_call_cleanup(true,Goal,
        (close(Stream),memory_file_to_atom(Handle,Atom),nb_setarg(1,Output,Atom),ignore(A=Atom))),
      (set_output(Was))).

with_output_to_each(Output,Goal):- Output= string(A),!,
   current_output(Was),
   nb_setarg(1,Output,""),
   new_memory_file(Handle),
   open_memory_file(Handle,write,Stream,[free_on_close(true)]),
     scce_orig(set_output(Stream),
      setup_call_cleanup(true,Goal,
        (close(Stream),memory_file_to_string(Handle,Atom),nb_setarg(1,Output,Atom),ignore(A=Atom))),
      (set_output(Was))).

with_output_to_each(Output,Goal):- 
   current_output(Was), scce_orig(set_output(Output),Goal,set_output(Was)).
    

% ==========================================================
% Sending Notes
% ==========================================================
:- thread_local( tlbugger:tlbugger:dmsg_match/2).
% = :- meta_predicate(with_all_dmsg(0)).
% = :- meta_predicate(with_show_dmsg(*,0)).



%= 	 	 

%% with_all_dmsg( :Goal) is nondet.
%
% Using All (debug)message.
%
with_all_dmsg(Goal):-
   locally(set_prolog_flag(dmsg_level,always),     
       locally( tlbugger:dmsg_match(show,_),Goal)).



%= 	 	 

%% with_show_dmsg( ?TypeShown, :Goal) is nondet.
%
% Using Show (debug)message.
%
with_show_dmsg(TypeShown,Goal):-
  locally(set_prolog_flag(dmsg_level,always),
     locally( tlbugger:dmsg_match(showing,TypeShown),Goal)).

% = :- meta_predicate(with_no_dmsg(0)).

%= 	 	 

%% with_no_dmsg( :Goal) is nondet.
%
% Using No (debug)message.
%

 % with_no_dmsg(Goal):- current_prolog_flag(dmsg_level,always),!,Goal.
with_no_dmsg(Goal):-locally(set_prolog_flag(dmsg_level,never),Goal).

%= 	 	 

%% with_no_dmsg( ?TypeUnShown, :Goal) is nondet.
%
% Using No (debug)message.
%
with_no_dmsg(TypeUnShown,Goal):-
 locally(set_prolog_flag(dmsg_level,filter),
  locally( tlbugger:dmsg_match(hidden,TypeUnShown),Goal)).

% dmsg_hides_message(_):- !,fail.

%= 	 	 

%% dmsg_hides_message( ?C) is det.
%
% (debug)message Hides Message.
%
dmsg_hides_message(_):- current_prolog_flag(dmsg_level,never),!.
dmsg_hides_message(_):- current_prolog_flag(dmsg_level,always),!,fail.
dmsg_hides_message(C):-  tlbugger:dmsg_match(HideShow,Matcher),matches_term(Matcher,C),!,HideShow=hidden.

:- export(matches_term/2).

%% matches_term( ?Filter, ?VALUE2) is det.
%
% Matches Term.
%
matches_term(Filter,_):- var(Filter),!.
matches_term(Filter,Term):- var(Term),!,Filter=var.
matches_term(Filter,Term):- ( \+ \+ (matches_term0(Filter,Term))),!.

%% contains_atom( ?V, ?A) is det.
%
% Contains Atom.
%
contains_atom(V,A):-sub_term(VV,V),nonvar(VV),functor_safe(VV,A,_).

%% matches_term0( :TermFilter, ?Term) is det.
%
% Matches Term Primary Helper.
%
matches_term0(Filter,Term):- Term = Filter.
matches_term0(Filter,Term):- atomic(Filter),!,contains_atom(Term,Filter).
matches_term0(F/A,Term):- (var(A)->member(A,[0,1,2,3,4]);true), functor_safe(Filter,F,A), matches_term0(Filter,Term).
matches_term0(Filter,Term):- sub_term(STerm,Term),nonvar(STerm),matches_term0(Filter,STerm),!.


%= 	 	 

%% dmsg_hide( ?Term) is det.
%
% (debug)message Hide.
%
dmsg_hide(isValueMissing):-!,set_prolog_flag(dmsg_level,never).
dmsg_hide(Term):-set_prolog_flag(dmsg_level,filter),sanity(nonvar(Term)),aina( tlbugger:dmsg_match(hidden,Term)),retractall( tlbugger:dmsg_match(showing,Term)),nodebug(Term).

%= 	 	 

%% dmsg_show( ?Term) is det.
%
% (debug)message Show.
%
dmsg_show(isValueMissing):-!,set_prolog_flag(dmsg_level,always).
dmsg_show(Term):-set_prolog_flag(dmsg_level,filter),aina( tlbugger:dmsg_match(showing,Term)),ignore(retractall( tlbugger:dmsg_match(hidden,Term))),debug(Term).

%= 	 	 

%% dmsg_showall( ?Term) is det.
%
% (debug)message Showall.
%
dmsg_showall(Term):-ignore(retractall( tlbugger:dmsg_match(hidden,Term))).


%= 	 	 

%% indent_e( ?X) is det.
%
% Indent E.
%
indent_e(0):-!.
indent_e(X):- X > 20, XX is X-20,!,indent_e(XX).
indent_e(X):- catchvvnt((X < 2),_,true),write(' '),!.
indent_e(X):-XX is X -1,!,write(' '), indent_e(XX).


%= 	 	 

%% dmsg_text_to_string_safe( ?Expr, ?Forms) is det.
%
% (debug)message Text Converted To String Safely Paying Attention To Corner Cases.
%
dmsg_text_to_string_safe(Expr,Forms):-on_x_fail(text_to_string(Expr,Forms)).

% ===================================================================
% Lowlevel printng
% ===================================================================
:- multifile lmconf:term_to_message_string/2.
:- dynamic lmconf:term_to_message_string/2.
%% catchvvnt( :GoalT, ?E, :GoalF) is det.
%
% Catchvvnt.
%
catchvvnt(T,E,F):-catchv(quietly(T),E,F).

:- meta_predicate(catchvvnt(0,?,0)).

%= 	 	 

%% fmt0( ?X, ?Y, ?Z) is det.
%
% Format Primary Helper.
%
%fmt0(user_error,F,A):-!,get_main_error_stream(Err),!,format(Err,F,A).
%fmt0(current_error,F,A):-!,get_thread_current_error(Err),!,format(Err,F,A).
fmt0(X,Y,Z):-catchvvnt((format(X,Y,Z),flush_output_safe(X)),E,dfmt(E:format(X,Y))).

%= 	 	 

%% fmt0( ?X, ?Y) is det.
%
% Format Primary Helper.
%
fmt0(X,Y):-catchvvnt((format(X,Y),flush_output_safe),E,dfmt(E:format(X,Y))).

%= 	 	 

%% fmt0( ?X) is det.
%
% Format Primary Helper.
%
fmt0(X):- (atomic(X);is_list(X)), dmsg_text_to_string_safe(X,S),!,format('~w',[S]),!.
fmt0(X):- (atom(X) -> catchvvnt((format(X,[]),flush_output_safe),E,dmsg(E)) ; 
  (lmconf:term_to_message_string(X,M) -> 'format'('~q~N',[M]);fmt_or_pp(X))).

%= 	 	 

%% fmt( ?X) is det.
%
% Format.
%
fmt(X):-fresh_line,fmt_ansi(fmt0(X)).

%= 	 	 

%% fmt( ?X, ?Y) is det.
%
% Format.
%
fmt(X,Y):- fresh_line,fmt_ansi(fmt0(X,Y)),!.

%= 	 	 

%% fmt( ?X, ?Y, ?Z) is det.
%
% Format.
%
fmt(X,Y,Z):- fmt_ansi(fmt0(X,Y,Z)),!.



:- module_transparent((format_to_message)/3).

format_to_message(Format,Args,Info):- 
  on_xf_cont(((( sanity(is_list(Args))-> 
     format(string(Info),Format,Args);
     (format(string(Info),'~N~n~p +++++++++++++++++ ~p~n',[Format,Args])))))).


new_line_if_needed:- flush_output,format('~N',[]),flush_output.

%= 	 	 

%% fmt9( ?Msg) is det.
%
% Fmt9.
%
fmt9(Msg):- new_line_if_needed, must(fmt90(Msg)),!,new_line_if_needed.

fmt90(fmt0(F,A)):-on_x_fail(fmt0(F,A)).
fmt90(Msg):- on_x_fail(((string(Msg);atom(Msg)),format(Msg,[fmt90_x1,fmt90_x2,fmt90_x3]))).
fmt90(Msg):- on_x_fail((with_output_to(string(S),on_x_fail(if_defined_local(portray_clause_w_vars(Msg),fail))),format('~s',[S]))).
fmt90(Msg):- on_x_fail(format('~p',[Msg])).
fmt90(Msg):- writeq(fmt9(Msg)).

% :-reexport(library(ansi_term)).
:- use_module(library(ansi_term)).


%= 	 	 

%% tst_fmt is det.
%
% Tst Format.
%
tst_fmt:- make,
 findall(R,(clause(ansi_term:sgr_code(R, _),_),ground(R)),List),
 ignore((
        ansi_term:ansi_color(FC, _),
        member(FG,[hfg(FC),fg(FC)]),
        % ansi_term:ansi_term:ansi_color(Key, _),
        member(BG,[hbg(default),bg(default)]),
        member(R,List),
        % random_member(R1,List),
    C=[reset,R,FG,BG],
  fresh_line,
  ansi_term:ansi_format(C,' ~q ~n',[C]),fail)).



%= 	 	 

%% fmt_ansi( :Goal) is nondet.
%
% Format Ansi.
%
fmt_ansi(Goal):-ansicall([reset,bold,hfg(white),bg(black)],Goal).


%= 	 	 

%% fmt_portray_clause( ?X) is det.
%
% Format Portray Clause.
%
fmt_portray_clause(X):- renumbervars_prev(X,Y),!, portray_clause(Y).


%= 	 	 

%% fmt_or_pp( ?X) is det.
%
% Format Or Pretty Print.
%
fmt_or_pp(portray((X:-Y))):-!,fmt_portray_clause((X:-Y)),!.
fmt_or_pp(portray(X)):- !,functor_safe(X,F,A),fmt_portray_clause((pp(F,A):-X)),!.
fmt_or_pp(X):-format('~q~N',[X]).


%= 	 	 

%% with_output_to_console( :GoalX) is det.
%
% Using Output Converted To Console.
%
with_output_to_console(X):- get_main_error_stream(Err),!,with_output_to_stream(Err,X).

%= 	 	 

%% with_output_to_main( :GoalX) is det.
%
% Using Output Converted To Main.
%
with_output_to_main(X):- get_main_error_stream(Err),!,with_output_to_stream(Err,X).


%= 	 	 

%% dfmt( ?X) is det.
%
% Dfmt.
%
dfmt(X):- get_thread_current_error(Err),!,with_output_to_stream(Err,fmt(X)).

%= 	 	 

%% dfmt( ?X, ?Y) is det.
%
% Dfmt.
%
dfmt(X,Y):- get_thread_current_error(Err), with_output_to_stream(Err,fmt(X,Y)).


%= 	 	 

%% with_output_to_stream( ?Stream, :Goal) is det.
%
% Using Output Converted To Stream.
%
with_output_to_stream(Stream,Goal):-
   current_output(Saved),
   scce_orig(set_output(Stream),
         Goal,
         set_output(Saved)).


%= 	 	 

%% to_stderror( :Goal) is nondet.
%
% Converted To Stderror.
%
to_stderror(Goal):- get_thread_current_error(Err), with_output_to_stream(Err,Goal).



:- dynamic dmsg_log/3.


:- dynamic(logLevel/2).
:- module_transparent(logLevel/2).
:- multifile(logLevel/2).


:- dynamic logger_property/2.

%= 	 	 

%% logger_property( ?VALUE1, ?VALUE2, ?VALUE3) is det.
%
% Logger Property.
%
logger_property(todo,once,true).



%= 	 	 

%% setLogLevel( ?M, ?L) is det.
%
% Set Log Level.
%
setLogLevel(M,L):-retractall(logLevel(M,_)),(nonvar(L)->asserta(logLevel(M,L));true).
setLogLevel(M,L):-retractall(logLevel(M,_)),(user:nonvar(L)->asserta(logLevel(M,L));true).


 
:-dynamic(logLevel/2).
:-module_transparent(logLevel/2).
:-multifile(logLevel/2).

%% logLevel( ?S, ?Z) is det.
%
% Log Level.
%
logLevel(debug,ERR):-get_thread_current_error(ERR).
logLevel(error,ERR):-get_thread_current_error(ERR).
logLevel(private,none).
logLevel(S,Z):-current_stream(_X,write,Z),dtrace,stream_property(Z,alias(S)).
 


%= 	 	 

%% loggerReFmt( ?L, ?LRR) is det.
%
% Logger Re Format.
%
loggerReFmt(L,LRR):-logLevel(L,LR),L \==LR,!,loggerReFmt(LR,LRR),!.
loggerReFmt(L,L).


%= 	 	 

%% loggerFmtReal( ?S, ?F, ?A) is det.
%
% Logger Format Real.
%
loggerFmtReal(none,_F,_A):-!.
loggerFmtReal(S,F,A):-
  current_stream(_,write,S),
    fmt(S,F,A),
    flush_output_safe(S),!.



:- thread_local tlbugger:is_with_dmsg/1.


%= 	 	 

%% with_dmsg( ?Functor, :Goal) is det.
%
% Using (debug)message.
%
with_dmsg(Functor,Goal):-
   locally(tlbugger:is_with_dmsg(Functor),Goal).


:- use_module(library(listing)).

%= 	 	 

%% sformat( ?Str, ?Msg, ?Vs, ?Opts) is det.
%
% Sformat.
%
sformat(Str,Msg,Vs,Opts):- nonvar(Msg),functor_safe(Msg,':-',_),!,with_output_to_each(string(Str),
   (current_output(CO),portray_clause_w_vars(CO,Msg,Vs,Opts))).
sformat(Str,Msg,Vs,Opts):- with_output_to_each(chars(Codes),(current_output(CO),portray_clause_w_vars(CO,':-'(Msg),Vs,Opts))),append([_,_,_],PrintCodes,Codes),'sformat'(Str,'   ~s',[PrintCodes]),!.


free_of_attrs_dmsg(Term):- var(Term),!,(get_attrs(Term,Attrs)-> Attrs==[] ; true).
free_of_attrs_dmsg(Term):- term_attvars(Term,Vs),!,(Vs==[]->true;maplist(free_of_attrs_dmsg,Vs)).


:- use_module(library(listing)).

%= 	 	 

%% portray_clause_w_vars( ?Out, ?Msg, ?Vs, ?Options) is det.
%
% Portray Clause W Variables.
%

portray_clause_w_vars(Out,Msg,Vs,Options):- free_of_attrs_dmsg(Msg+Vs),!, portray_clause_w_vars5(Out,Msg,Vs,Options).
portray_clause_w_vars(Out,Msg,Vs,Options):- if_defined_local(serialize_attvars_now(Msg+Vs,SMsg+SVs),fail),!,portray_clause_w_vars2(Out,SMsg,SVs,Options).
portray_clause_w_vars(Out,Msg,Vs,Options):- portray_clause_w_vars2(Out,Msg,Vs,Options).
 
portray_clause_w_vars2(Out,Msg,Vs,Options):- free_of_attrs_dmsg(Msg+Vs),!, portray_clause_w_vars5(Out,Msg,Vs,Options).
portray_clause_w_vars2(Out,Msg,Vs,Options):- copy_term(Msg+Vs+Options,CMsg+CVs+COptions,Goals), 
   portray_clause_w_vars5(Out,CMsg+Goals,CVs,COptions).

portray_clause_w_vars5(Out,Msg,Vs,Options):-
 \+ \+ ((prolog_listing:do_portray_clause(Out,Msg,
  [variable_names(Vs),numbervars(true),
      attributes(ignore),
      character_escapes(true),quoted(true)|Options]))),!.



%= 	 	 

%% portray_clause_w_vars( ?Msg, ?Vs, ?Options) is det.
%
% Portray Clause W Variables.
%
portray_clause_w_vars(Msg,Vs,Options):- portray_clause_w_vars(current_output,Msg,Vs,Options).

%= 	 	 

%% portray_clause_w_vars( ?Msg, ?Options) is det.
%
% Portray Clause W Variables.
%
portray_clause_w_vars(Msg,Options):- source_variables_lwv(Msg,Vs),portray_clause_w_vars(current_output,Msg,Vs,Options).

grab_varnames(Msg,Vs2):- term_attvars(Msg,AttVars),grab_varnames2(AttVars,Vs2).

grab_varnames2([],[]):-!.
grab_varnames2([AttV|AttVS],Vs2):-
    grab_varnames2(AttVS,VsMid),!,
     (get_attr(AttV,vn,Name) -> Vs2 = [Name=AttV|VsMid] ; VsMid=       Vs2),!.
   


%= 	 	 

%% source_variables_lwv( ?AllS) is det.
%
% Source Variables Lwv.
%
source_variables_lwv(Msg,AllS):-
  (prolog_load_context(variable_names,Vs1);Vs1=[]),
   grab_varnames(Msg,Vs2),
   quietly(catch((parent_goal('$toplevel':'$execute_goal2'(_, Vs3),_);Vs3=[]),_,Vs3=[])),
   ignore(Vs3=[]),
   append(Vs3,Vs2,Vs32),append(Vs32,Vs1,All),!,list_to_set(All,AllS).
   % set_varname_list( AllS).



:- export(portray_clause_w_vars/1).

%= 	 	 

%% portray_clause_w_vars( ?Msg) is det.
%
% Portray Clause W Variables.
%
portray_clause_w_vars(Msg):- portray_clause_w_vars(Msg,[]),!.


%= 	 	 

%% print_prepended( ?Pre, ?S) is det.
%
% Print Prepended.
%
print_prepended(Pre,S):-atom_concat(L,' ',S),!,print_prepended(Pre,L).
print_prepended(Pre,S):-atom_concat(L,'\n',S),!,print_prepended(Pre,L).
print_prepended(Pre,S):-atom_concat('\n',L,S),!,print_prepended(Pre,L).
print_prepended(Pre,S):-atomics_to_string(L,'\n',S),print_prepended_lines(Pre,L).

%= 	 	 

%% print_prepended_lines( ?Pre, :TermARG2) is det.
%
% Print Prepended Lines.
%
print_prepended_lines(_Pre,[]):- format('~N',[]).
print_prepended_lines(Pre,[H|T]):-format('~N~w~w',[Pre,H]),print_prepended_lines(Pre,T).



%= 	 	 

%% in_cmt( :Goal) is nondet.
%
% In Comment.
%

% in_cmt(Goal):- tlbugger:no_slow_io,!,format('~N/*~n',[]),call_cleanup(Goal,format('~N*/~n',[])).
in_cmt(Goal):- call_cleanup(prepend_each_line('% ',Goal),format('~N',[])).


%= 	 	 

%% with_current_indent( :Goal) is nondet.
%
% Using Current Indent.
%
with_current_indent(Goal):- 
   get_indent_level(Indent), 
   indent_to_spaces(Indent,Space),
   prepend_each_line(Space,Goal).


%= 	 	 

%% indent_to_spaces( :PRED3N, ?Out) is det.
%
% Indent Converted To Spaces.
%
indent_to_spaces(1,' '):-!.
indent_to_spaces(0,''):-!.
indent_to_spaces(2,'  '):-!.
indent_to_spaces(3,'   '):-!.
indent_to_spaces(N,Out):- 1 is N rem 2,!, N1 is N-1, indent_to_spaces(N1,Spaces),atom_concat(' ',Spaces,Out).
indent_to_spaces(N,Out):- N2 is N div 2, indent_to_spaces(N2,Spaces),atom_concat(Spaces,Spaces,Out).


%= 	 	 

%% mesg_color( :TermT, ?C) is det.
%
% Mesg Color.
%
mesg_color(_,[reset]):-tlbugger:no_slow_io,!.
mesg_color(T,C):-var(T),!,C=[blink(slow),fg(red),hbg(black)],!.
mesg_color(T,C):- if_defined(is_sgr_on_code(T)),!,C=T.
mesg_color(T,C):-cyclic_term(T),!,C=reset.
mesg_color("",C):- !,C=[blink(slow),fg(red),hbg(black)],!.
mesg_color(T,C):- string(T),!,must(f_word(T,F)),!,functor_color(F,C).
mesg_color([_,_,_,T|_],C):-atom(T),mesg_color(T,C).
mesg_color([T|_],C):-atom(T),mesg_color(T,C).
mesg_color(T,C):-(atomic(T);is_list(T)), dmsg_text_to_string_safe(T,S),!,mesg_color(S,C).
mesg_color(T,C):-not(compound(T)),term_to_atom(T,A),!,mesg_color(A,C).
mesg_color(succeed(T),C):-nonvar(T),mesg_color(T,C).
% mesg_color((T),C):- \+ \+ ((predicate_property(T,meta_predicate(_)))),arg(_,T,E),compound(E),!,mesg_color(E,C).
mesg_color(=(T,_),C):-nonvar(T),mesg_color(T,C).
mesg_color(debug(T),C):-nonvar(T),mesg_color(T,C).
mesg_color(_:T,C):-nonvar(T),!,mesg_color(T,C).
mesg_color(T,C):-functor_safe(T,F,_),member(F,[color,ansi]),compound(T),arg(1,T,C),nonvar(C).
mesg_color(T,C):-functor_safe(T,F,_),member(F,[succeed,must,mpred_op_prolog]),compound(T),arg(1,T,E),nonvar(E),!,mesg_color(E,C).
mesg_color(T,C):-functor_safe(T,F,_),member(F,[fmt0,msg]),compound(T),arg(2,T,E),nonvar(E),!,mesg_color(E,C).
mesg_color(T,C):-predef_functor_color(F,C),mesg_arg1(T,F).
mesg_color(T,C):-nonvar(T),defined_message_color(F,C),matches_term(F,T),!.
mesg_color(T,C):-functor(T,F,_),!,functor_color(F,C),!.



%= 	 	 

%% prepend_each_line( ?Pre, :Goal) is nondet.
%
% Prepend Each Line.
%
prepend_each_line(Pre,Goal):-
  with_output_to_each(string(Str),Goal)*->once(print_prepended(Pre,Str)).

:- meta_predicate if_color_debug(0).
:- meta_predicate if_color_debug(0,0).

%= 	 	 

%% if_color_debug is det.
%
% If Color Debug.
%
if_color_debug:-current_prolog_flag(dmsg_color,true).

%= 	 	 

%% if_color_debug( :Goal) is nondet.
%
% If Color Debug.
%
if_color_debug(Goal):- if_color_debug(Goal, true).

%= 	 	 

%% if_color_debug( :Goal, :GoalUnColor) is det.
%
% If Color Debug.
%
if_color_debug(Goal,UnColor):- if_color_debug->Goal;UnColor.



color_line(C,N):- 
 quietly((
  format('~N',[]),
    forall(between(1,N,_),ansi_format([fg(C)],"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n",[])))).



% % = :- export((portray_clause_w_vars/4,ansicall/3,ansi_control_conv/2)).

:- thread_local(tlbugger:skipDumpST9/0).
:- thread_local(tlbugger:skipDMsg/0).

% @(dmsg0(succeed(S_1)),[S_1=logic])


:- thread_local(tlbugger:no_slow_io/0).
:- multifile(tlbugger:no_slow_io/0).
%:- asserta(tlbugger:no_slow_io).

:- create_prolog_flag(retry_undefined,none,[type(term),keep(true)]).

%= 	 	 

%% dmsg( ?C) is det.
%
% (debug)message.
%
dmsg(C):- quietly((tlbugger:no_slow_io,!,writeln(main_error,dmsg(C)))).
dmsg(V):- locally(set_prolog_flag(retry_undefined,none), if_defined_local(dmsg0(V),logicmoo_util_catch:ddmsg(V))),!.
%dmsg(F,A):- quietly((tlbugger:no_slow_io,on_x_fail(format(atom(S),F,A))->writeln(dmsg(S));writeln(dmsg_fail(F,A)))),!.
%dmsg(T):- isDebugOption(opt_debug=off),!.
dmsg(StuffIn):-copy_term(StuffIn,Stuff), randomVars(Stuff),!,dmsg('% ~q~n',[Stuff]).
%:- abolish(dmsg/1).
%dmsg(Stuff):- notrace((debugFmtS(Stuff))),!.

dmsg(T):-!,
    ((
    if_prolog(swi,
        (prolog_current_frame(Frame),
        prolog_frame_attribute(Frame,level,Depth),!,
        Depth2 = (Depth-25))),
    writeFmt(';;',[T]),!,
    indent_e(Depth2),!,
    writeFmt('~q\n',[T]))),!.
 

:- system:import(dmsg/1).
% system:dmsg(O):-logicmoo_util_dmsg:dmsg(O).
%= 	 	 

%% dmsg( ?F, ?A) is det.
%
% (debug)message.
%
dmsg(F,A):- locally(set_prolog_flag(retry_undefined, none),if_defined_local(dmsg0(F,A),logicmoo_util_catch:ddmsg(F,A))),!.
%dmsg(C,T):- isDebugOption(opt_debug=off),!.
dmsg(_,F):-F==[-1];F==[[-1]].
dmsg(F,A):-
        nl(user_error),
        wdmsg(user_error,F,A),
        nl(user_error),
        flush_output_safe(user_error),!.
dmsg(C,T):-!,((writeFmt('<font size=+1 color=~w>',[C]),dmsg(T),writeFmt('</font>',[]))),!.
 


with_output_to_main_error(G):- 
  % stream_property(In,file_no(0)),
  stream_property(Err,file_no(2)),
  current_input(I),
  current_output(O),
   setup_call_cleanup(set_prolog_IO(I,Err,Err),
    G,
     set_prolog_IO(I,O,O)).
   


%% wdmsg( ?X) is semidet.
%
% Wdmsg.
%
wdmsg(_):- current_prolog_flag(dmsg_level,never),!.
wdmsg(X):- quietly(show_source_location),
 quietly(with_all_dmsg(dmsg(X))),!.



%% wdmsg( ?F, ?X) is semidet.
%
% Wdmsg.
%
wdmsg(_,_):- current_prolog_flag(dmsg_level,never),!.
wdmsg(F,X):- quietly(ignore(with_all_dmsg(dmsg(F,X)))),!.


%% wdmsg( ?F, ?X) is semidet.
%
% Wdmsg.
%
wdmsg(W,F,X):- quietly(ignore(with_all_dmsg(dmsg(W,F,X)))),!.


:- meta_predicate wdmsgl(1,+).
:- meta_predicate wdmsgl(+,1,+).

%% wdmsgl( ?CNF) is det.
%
% Wdmsgl.
%
wdmsgl(X):- wdmsgl(fmt9,X),!.
wdmsgl(With,X):- (must((wdmsgl('',With,X)))),!.

wdmsgl(NAME,With,CNF):- is_ftVar(CNF),!,call(With,NAME=CNF).
wdmsgl(_,With,(C:-CNF)):- call(With,(C :-CNF)),!.
wdmsgl(_,With,'==>'(CNF,C)):- call(With,(C :- (fwc, CNF))),!.
wdmsgl(_,With,(NAME=CNF)):- wdmsgl(NAME,With,CNF),!.
wdmsgl(NAME,With,CNF):- is_list(CNF),must_maplist_det(wdmsgl(NAME,With),CNF),!.
wdmsgl('',With,(C:-CNF)):- call(With,(C :-CNF)),!.
wdmsgl(NAME,With,(C:-CNF)):- call(With,(NAME: C :-CNF)),!.
wdmsgl(NAME,With,(:-CNF)):- call(With,(NAME:-CNF)),!.
wdmsgl(NAME,With,CNF):- call(With,NAME:-CNF),!.



%% dmsginfo( ?V) is det.
%
% Dmsginfo.
%
dmsginfo(V):-dmsg(info(V)).

%= 	 	 

%% dmsg0( ?F, ?A) is det.
%
% (debug)message Primary Helper.
%
dmsg0(_,_):- current_prolog_flag(dmsg_level,never),!.
dmsg0(F,A):- is_sgr_on_code(F),!,dmsg(ansi(F,A)),!.
dmsg0(F,A):- with_output_to_main_error(dmsg(fmt0(F,A))),!.

%= 	 	 

%% vdmsg( ?L, ?F) is det.
%
% Vdmsg.
%
vdmsg(L,F):-loggerReFmt(L,LR),loggerFmtReal(LR,F,[]).

%= 	 	 

%% dmsg( ?L, ?F, ?A) is det.
%
% (debug)message.
%
dmsg(L,F,A):-loggerReFmt(L,LR),loggerFmtReal(LR,F,A).

:- thread_local(tlbugger:in_dmsg/1).
:- dynamic tlbugger:dmsg_hook/1.
:- multifile tlbugger:dmsg_hook/1.
:- thread_local(t_l:no_kif_var_coroutines/1).


%= 	 	 

%% dmsg0( ?V) is det.
%
% (debug)message Primary Helper.
%
dmsg0(V):-quietly(locally(t_l:no_kif_var_coroutines(true),ignore(with_output_to_main_error(dmsg00(V))))),!.

%= 	 	 

%% dmsg00( ?V) is det.
%
% (debug)message Primary Helper Primary Helper.
%
dmsg00(V):-cyclic_term(V),!,writeln(cyclic_term),flush_output,writeln(V),!.
dmsg00(V):- catch(logicmoo_util_dumpst:simplify_goal_printed(V,VV),_,fail),!,dmsg000(VV),!.
dmsg00(V):- dmsg000(V),!.


%% dmsg000( ?V) is det.
%
% (debug)message Primary Helper Primary Helper Primary Helper.
%
dmsg000(V):-
 with_output_to_main_error(
   (quietly(format(string(K),'~p',[V])),
   (tlbugger:in_dmsg(K)-> dmsg5(V);  % format_to_error('~N% ~q~n',[dmsg0(V)]) ;
      asserta(tlbugger:in_dmsg(K),Ref),call_cleanup(dmsg1(V),erase(Ref))))),!.

% = :- export(dmsg1/1).

%= 	 	 

%% dmsg1( ?V) is det.
%
% (debug)message Secondary Helper.
%
dmsg1(V):- tlbugger:is_with_dmsg(FP),!,FP=..FPL,append(FPL,[V],VVL),VV=..VVL,once(dmsg1(VV)).
dmsg1(_):- current_prolog_flag(dmsg_level,never),!.
dmsg1(V):- var(V),!,dmsg1(warn(dmsg_var(V))).
dmsg1(NC):- cyclic_term(NC),!,dtrace,format_to_error('~N% ~q~n',[dmsg_cyclic_term_1]).
dmsg1(NC):- tlbugger:skipDMsg,!,loop_check_early(dmsg2(NC),format_to_error('~N% ~q~n',[skipDMsg])),!.
dmsg1(V):- locally(tlbugger:skipDMsg,((once(dmsg2(V)), ignore((tlbugger:dmsg_hook(V),fail))))),!.

% = :- export(dmsg2/1).

%= 	 	 

%% dmsg2( :TermNC) is det.
%
% (debug)message Extended Helper.
%
dmsg2(NC):- cyclic_term(NC),!,format_to_error('~N% ~q~n',[dmsg_cyclic_term_2]).
dmsg2(NC):- var(NC),!,format_to_error('~N% DMSG VAR ~q~n',[NC]).
dmsg2(skip_dmsg(_)):-!.
%dmsg2(C):- \+ current_prolog_flag(dmsg_level,always), dmsg_hides_message(C),!.
%dmsg2(trace_or_throw(V)):- dumpST(350),dmsg(warning,V),fail.
%dmsg2(error(V)):- dumpST(250),dmsg(warning,V),fail.
%dmsg2(warn(V)):- dumpST(150),dmsg(warning,V),fail.
dmsg2(Msg):-quietly((tlbugger:no_slow_io,!,dmsg3(Msg))),!.
dmsg2(ansi(Ctrl,Msg)):- !, ansicall(Ctrl,dmsg3(Msg)).
dmsg2(color(Ctrl,Msg)):- !, ansicall(Ctrl,dmsg3(Msg)).
dmsg2(Msg):- mesg_color(Msg,Ctrl),ansicall(Ctrl,dmsg3(Msg)).


%= 	 	 

%% dmsg3( ?C) is det.
%
% Dmsg3.
%
dmsg3(C):- tlbugger:no_slow_io,!,writeln(dmsg3(C)).
dmsg3(C):- strip_module(C,_,SM),
  ((functor_safe(SM,Topic,_),debugging(Topic,_True_or_False),logger_property(Topic,once,true),!,
      (dmsg_log(Topic,_Time,C) -> true ; ((get_time(Time),asserta(dmsg_log(todo,Time,C)),!,dmsg4(C)))))),!.

dmsg3(C):-dmsg4(C),!.


%= 	 	 

%% dmsg4( ?Msg) is det.
%
% Dmsg4.
%
dmsg4(_):- current_prolog_flag(dmsg_level,never),!.
dmsg4(_):- quietly(show_source_location),fail.
dmsg4(Msg):-dmsg5(Msg).


%= 	 	 

%% dmsg5( ?Msg) is det.
%
% Dmsg5.
%
dmsg5(Msg):- to_stderror(in_cmt(fmt9(Msg))).

%= 	 	 

%% dmsg5( ?Msg, ?Args) is det.
%
% Dmsg5.
%
dmsg5(Msg,Args):- dmsg5(fmt0(Msg,Args)).



%= 	 	 

%% get_indent_level( :PRED2Max) is det.
%
% Get Indent Level.
%
get_indent_level(Max) :- if_prolog(swi,((prolog_current_frame(Frame),prolog_frame_attribute(Frame,level,FD)))),Depth is FD div 5,Max is min(Depth,40),!.
get_indent_level(2):-!.


/*
ansifmt(+Attributes, +Format, +Args) is det
Format text with ANSI attributes. This predicate behaves as format/2 using Format and Args, but if the current_output is a terminal, it adds ANSI escape sequences according to Attributes. For example, to print a text in bold cyan, do
?- ansifmt([bold,fg(cyan)], 'Hello ~w', [world]).
Attributes is either a single attribute or a list thereof. The attribute names are derived from the ANSI specification. See the source for sgr_code/2 for details. Some commonly used attributes are:

bold
underline
fg(Color), bg(Color), hfg(Color), hbg(Color)
Defined color constants are below. default can be used to access the default color of the terminal.

black, red, green, yellow, blue, magenta, cyan, white
ANSI sequences are sent if and only if

The current_output has the property tty(true) (see stream_property/2).
The Prolog flag color_term is true.

ansifmt(Ctrl, Format, Args) :- ansifmt(current_output, Ctrl, Format, Args).

ansifmt(Stream, Ctrl, Format, Args) :-
     % we can "assume"
        % ignore(((stream_property(Stream, tty(true)),current_prolog_flag(color_term, true)))), !,
	(   is_list(Ctrl)
	->  maplist(ansi_term:sgr_code_ex, Ctrl, Codes),
	    atomic_list_concat(Codes, (';'), OnCode)
	;   ansi_term:sgr_code_ex(Ctrl, OnCode)
	),
	'format'(string(Fmt), '\e[~~wm~w\e[0m', [Format]),
        retractall(tlbugger:last_used_color(Ctrl)),asserta(tlbugger:last_used_color(Ctrl)),
	'format'(Stream, Fmt, [OnCode|Args]),
	flush_output,!.
ansifmt(Stream, _Attr, Format, Args) :- 'format'(Stream, Format, Args).

*/

:- use_module(library(ansi_term)).

% = :- export(ansifmt/2).

%= 	 	 

%% ansifmt( ?Ctrl, ?Fmt) is det.
%
% Ansifmt.
%
ansifmt(Ctrl,Fmt):- colormsg(Ctrl,Fmt).
% = :- export(ansifmt/3).

%= 	 	 

%% ansifmt( ?Ctrl, ?F, ?A) is det.
%
% Ansifmt.
%
ansifmt(Ctrl,F,A):- colormsg(Ctrl,(format(F,A))).



%= 	 	 

%% debugm( ?X) is det.
%
% Debugm.
%
debugm(X):-quietly((compound(X),functor(X,F,_),!,debugm(F,X))),!.
debugm(X):-quietly((debugm(X,X))).

%= 	 	 

%% debugm( ?Why, ?Msg) is det.
%
% Debugm.
%
debugm(Why,Msg):- dmsg(debugm(Why,Msg)),!,debugm0(Why,Msg).
debugm0(Why,Msg):- quietly(( \+ debugging(mpred), \+ debugging(Why), \+ debugging(mpred(Why)),!, debug(Why,'~N~p~n',[Msg]))),!.
debugm0(Why,Msg):- quietly(( debug(Why,'~N~p~n',[Msg]))),!.



%% colormsg( ?Ctrl, ?Msg) is det.
%
% Colormsg.
%
colormsg(d,Msg):- mesg_color(Msg,Ctrl),!,colormsg(Ctrl,Msg).
colormsg(Ctrl,Msg):- ansicall(Ctrl,fmt0(Msg)).

% = :- export(ansicall/2).

%= 	 	 

%% ansicall( ?Ctrl, :Goal) is nondet.
%
% Ansicall.
%

% ansicall(_,Goal):-!,Goal.
ansicall(Ctrl,Goal):- quietly((current_output(Out), ansicall(Out,Ctrl,Goal))).


%= 	 	 

%% ansi_control_conv( ?Ctrl, ?CtrlO) is det.
%
% Ansi Control Conv.
%
ansi_control_conv(Ctrl,CtrlO):-tlbugger:no_slow_io,!,flatten([Ctrl],CtrlO),!.
ansi_control_conv([],[]):-!.
ansi_control_conv([H|T],HT):-!,ansi_control_conv(H,HH),!,ansi_control_conv(T,TT),!,flatten([HH,TT],HT),!.
ansi_control_conv(warn,Ctrl):- !, ansi_control_conv(warning,Ctrl),!.
ansi_control_conv(Level,Ctrl):- ansi_term:level_attrs(Level,Ansi),Level\=Ansi,!,ansi_control_conv(Ansi,Ctrl).
ansi_control_conv(Color,Ctrl):- ansi_term:ansi_color(Color,_),!,ansi_control_conv(fg(Color),Ctrl).
ansi_control_conv(Ctrl,CtrlO):-flatten([Ctrl],CtrlO),!.



%= 	 	 

%% is_tty( ?Out) is det.
%
% If Is A Tty.
%
:- multifile(tlbugger:no_colors/0).
:- thread_local(tlbugger:no_colors/0).
is_tty(Out):- \+ tlbugger:no_colors, \+ tlbugger:no_slow_io, is_stream(Out),stream_property(Out,tty(true)).


%= 	 	 

%% ansicall( ?Out, ?UPARAM2, :Goal) is nondet.
%
% Ansicall.
%
ansicall(Out,_,Goal):- \+ is_tty(Out),!,Goal.
ansicall(_Out,_,Goal):- tlbugger:skipDumpST9,!,Goal.

% in_pengines:- if_defined_local(relative_frame(source_context_module,pengines,_)).

ansicall(_,_,Goal):-tlbugger:no_slow_io,!,Goal.
ansicall(Out,CtrlIn,Goal):- once(ansi_control_conv(CtrlIn,Ctrl)),  CtrlIn\=Ctrl,!,ansicall(Out,Ctrl,Goal).
ansicall(_,_,Goal):- if_defined_local(in_pengines,fail),!,Goal.
ansicall(Out,Ctrl,Goal):-
   retractall(tlbugger:last_used_color(_)),asserta(tlbugger:last_used_color(Ctrl)),ansicall0(Out,Ctrl,Goal),!.


%= 	 	 

%% ansicall0( ?Out, ?Ctrl, :Goal) is nondet.
%
% Ansicall Primary Helper.
%
ansicall0(Out,[Ctrl|Set],Goal):-!, ansicall0(Out,Ctrl,ansicall0(Out,Set,Goal)).
ansicall0(_,[],Goal):-!,Goal.
ansicall0(Out,Ctrl,Goal):-if_color_debug(ansicall1(Out,Ctrl,Goal),keep_line_pos_w_w(Out, Goal)).


%= 	 	 

%% ansicall1( ?Out, ?Ctrl, :Goal) is nondet.
%
% Ansicall Secondary Helper.
%
ansicall1(Out,Ctrl,Goal):-
   quietly((must(sgr_code_on_off(Ctrl, OnCode, OffCode)),!,
     keep_line_pos_w_w(Out, (format(Out, '\e[~wm', [OnCode]))),
	call_cleanup(Goal,
           keep_line_pos_w_w(Out, (format(Out, '\e[~wm', [OffCode])))))).
/*
ansicall(S,Set,Goal):-
     call_cleanup((
         stream_property(S, tty(true)), current_prolog_flag(color_term, true), !,
	(is_list(Ctrl) ->  maplist(sgr_code_on_off, Ctrl, Codes, OffCodes),
          atomic_list_concat(Codes, (';'), OnCode) atomic_list_concat(OffCodes, (';'), OffCode) ;   sgr_code_on_off(Ctrl, OnCode, OffCode)),
        keep_line_pos_w_w(S, (format(S,'\e[~wm', [OnCode])))),
	call_cleanup(Goal,keep_line_pos_w_w(S, (format(S, '\e[~wm', [OffCode]))))).


*/





%= 	 	 

%% keep_line_pos_w_w( ?S, :GoalG) is det.
%
% Keep Line Pos.
%
keep_line_pos_w_w(S, G) :-
       (stream_property(S, position(Pos)),stream_position_data(line_position, Pos, LPos)) ->
         call_cleanup(G, set_stream_line_position_safe(S, LPos)) ;
         call(G).

set_stream_line_position_safe(S,Pos):-
  catch(set_stream(S, line_position(Pos)),E,dmsg(error(E))).

:- multifile(tlbugger:term_color0/2).
:- dynamic(tlbugger:term_color0/2).


%tlbugger:term_color0(retract,magenta).
%tlbugger:term_color0(retractall,magenta).

%= 	 	 

%% term_color0( ?VALUE1, ?VALUE2) is det.
%
% Hook To [tlbugger:term_color0/2] For Module Logicmoo_util_dmsg.
% Term Color Primary Helper.
%
tlbugger:term_color0(assertz,hfg(green)).
tlbugger:term_color0(ainz,hfg(green)).
tlbugger:term_color0(aina,hfg(green)).
tlbugger:term_color0(mpred_op,hfg(blue)).



%= 	 	 

%% f_word( ?T, ?A) is det.
%
% Functor Word.
%
f_word("",""):-!.
f_word(T,A):-concat_atom(List,' ',T),member(A,List),atom(A),atom_length(A,L),L>0,!.
f_word(T,A):-concat_atom(List,'_',T),member(A,List),atom(A),atom_length(A,L),L>0,!.
f_word(T,A):- string_to_atom(T,P),sub_atom(P,0,10,_,A),A\==P,!.
f_word(T,A):- string_to_atom(T,A),!.


%= 	 	 

%% mesg_arg1( :TermT, ?TT) is det.
%
% Mesg Argument Secondary Helper.
%
mesg_arg1(T,_TT):-var(T),!,fail.
mesg_arg1(_:T,C):-nonvar(T),!,mesg_arg1(T,C).
mesg_arg1(T,TT):-not(compound(T)),!,T=TT.
mesg_arg1(T,C):-compound(T),arg(1,T,F),nonvar(F),!,mesg_arg1(F,C).
mesg_arg1(T,F):-functor(T,F,_).


% = :- export(defined_message_color/2).
:- dynamic(defined_message_color/2).


%= 	 	 

%% defined_message_color( ?A, ?B) is det.
%
% Defined Message Color.
%
defined_message_color(todo,[fg(red),bg(black),underline]).
%defined_message_color(error,[fg(red),hbg(black),bold]).
defined_message_color(warn,[fg(black),hbg(red),bold]).
defined_message_color(A,B):-tlbugger:term_color0(A,B).



%= 	 	 

%% predef_functor_color( ?F, ?C) is det.
%
% Predef Functor Color.
%
predef_functor_color(F,C):- defined_message_color(F,C),!.
predef_functor_color(F,C):- defined_message_color(F/_,C),!.
predef_functor_color(F,C):- tlbugger:term_color0(F,C),!.


%= 	 	 

%% functor_color( ?F, ?C) is det.
%
% Functor Color.
%
functor_color(F,C):- predef_functor_color(F,C),!.
functor_color(F,C):- next_color(C),ignore(on_x_fail(assertz(tlbugger:term_color0(F,C)))),!.


:- thread_local(tlbugger:last_used_color/1).

% tlbugger:last_used_color(pink).


%= 	 	 

%% last_used_fg_color( ?LFG) is det.
%
% Last Used Fg Color.
%
last_used_fg_color(LFG):-tlbugger:last_used_color(LU),fg_color(LU,LFG),!.
last_used_fg_color(default).


%= 	 	 

%% good_next_color( ?C) is det.
%
% Good Next Color.
%
good_next_color(C):-var(C),!,trace_or_throw(var_good_next_color(C)),!.
good_next_color(C):- last_used_fg_color(LFG),fg_color(C,FG),FG\=LFG,!.
good_next_color(C):- not(unliked_ctrl(C)).


%= 	 	 

%% unliked_ctrl( ?X) is det.
%
% Unliked Ctrl.
%
unliked_ctrl(fg(blue)).
unliked_ctrl(fg(black)).
unliked_ctrl(fg(red)).
unliked_ctrl(bg(white)).
unliked_ctrl(hbg(white)).
unliked_ctrl(X):-is_list(X),member(E,X),nonvar(E),unliked_ctrl(E).


%= 	 	 

%% fg_color( ?LU, ?FG) is det.
%
% Fg Color.
%
fg_color(LU,FG):-member(fg(FG),LU),FG\=white,!.
fg_color(LU,FG):-member(hfg(FG),LU),FG\=white,!.
fg_color(_,default).

% = :- export(random_color/1).

%= 	 	 

%% random_color( ?M) is det.
%
% Random Color.
%
random_color([reset,M,FG,BG,font(Font)]):-Font is random(8),
  findall(Cr,ansi_term:ansi_color(Cr, _),L),
  random_member(E,L),
  random_member(FG,[hfg(E),fg(E)]),not(unliked_ctrl(FG)),
  contrasting_color(FG,BG), not(unliked_ctrl(BG)),
  random_member(M,[bold,faint,reset,bold,faint,reset,bold,faint,reset]),!. % underline,negative


% = :- export(tst_color/0).

%= 	 	 

%% tst_color is det.
%
% Tst Color.
%
tst_color:- make, ignore((( between(1,20,_),random_member(Goal,[colormsg(C,cm(C)),dmsg(color(C,dm(C))),ansifmt(C,C)]),next_color(C),Goal,fail))).
% = :- export(tst_color/1).

%= 	 	 

%% tst_color( ?C) is det.
%
% Tst Color.
%
tst_color(C):- make,colormsg(C,C).

% = :- export(next_color/1).

%= 	 	 

%% next_color( :TermC) is det.
%
% Next Color.
%
next_color(C):- between(1,10,_), random_color(C), good_next_color(C),!.
next_color([underline|C]):- random_color(C),!.

% = :- export(contrasting_color/2).

%= 	 	 

%% contrasting_color( ?A, ?VALUE2) is det.
%
% Contrasting Color.
%
contrasting_color(white,black).
contrasting_color(A,default):-atom(A),A \= black.
contrasting_color(fg(C),bg(CC)):-!,contrasting_color(C,CC),!.
contrasting_color(hfg(C),bg(CC)):-!,contrasting_color(C,CC),!.
contrasting_color(black,white).
contrasting_color(default,default).
contrasting_color(_,default).

:- thread_local(ansi_prop/2).



%= 	 	 

%% sgr_on_code( ?Ctrl, :PRED7OnCode) is det.
%
% Sgr Whenever Code.
%
sgr_on_code(Ctrl,OnCode):- sgr_on_code0(Ctrl,OnCode),!.
sgr_on_code(_Foo,7):-!. %  quietly((format_to_error('~NMISSING: ~q~n',[bad_sgr_on_code(Foo)]))),!.


%= 	 	 

%% is_sgr_on_code( ?Ctrl) is det.
%
% If Is A Sgr Whenever Code.
%
is_sgr_on_code(Ctrl):-quietly(sgr_on_code0(Ctrl,_)),!.


%= 	 	 

%% sgr_on_code0( ?Ctrl, :PRED6OnCode) is det.
%
% Sgr Whenever Code Primary Helper.
%
sgr_on_code0(Ctrl,OnCode):- ansi_term:sgr_code(Ctrl,OnCode).
sgr_on_code0(blink, 6).
sgr_on_code0(-Ctrl,OffCode):-  nonvar(Ctrl), sgr_off_code(Ctrl,OffCode).


%= 	 	 

%% sgr_off_code( ?Ctrl, :GoalOnCode) is det.
%
% Sgr Off Code.
%
sgr_off_code(Ctrl,OnCode):-ansi_term:off_code(Ctrl,OnCode),!.
sgr_off_code(- Ctrl,OnCode):- nonvar(Ctrl), sgr_on_code(Ctrl,OnCode),!.
sgr_off_code(fg(_), CurFG):- (ansi_prop(fg,CurFG)->true;CurFG=39),!.
sgr_off_code(bg(_), CurBG):- (ansi_prop(ng,CurBG)->true;CurBG=49),!.
sgr_off_code(bold, 21).
sgr_off_code(italic_and_franktur, 23).
sgr_off_code(franktur, 23).
sgr_off_code(italic, 23).
sgr_off_code(underline, 24).
sgr_off_code(blink, 25).
sgr_off_code(blink(_), 25).
sgr_off_code(negative, 27).
sgr_off_code(conceal, 28).
sgr_off_code(crossed_out, 29).
sgr_off_code(framed, 54).
sgr_off_code(overlined, 55).
sgr_off_code(_,0).



%= 	 	 

%% sgr_code_on_off( ?Ctrl, ?OnCode, ?OffCode) is det.
%
% Sgr Code Whenever Off.
%
sgr_code_on_off(Ctrl,OnCode,OffCode):-sgr_on_code(Ctrl,OnCode),sgr_off_code(Ctrl,OffCode),!.
sgr_code_on_off(Ctrl,OnCode,OffCode):-sgr_on_code(Ctrl,OnCode),sgr_off_code(Ctrl,OffCode),!.
sgr_code_on_off(_Ctrl,_OnCode,[default]):-!.



%= 	 	 

%% msg_to_string( :TermVar, ?Str) is det.
%
% Msg Converted To String.
%
msg_to_string(Var,Str):-var(Var),!,sformat(Str,'~q',[Var]),!.
msg_to_string(portray(Msg),Str):- with_output_to_each(string(Str),(current_output(Out),portray_clause_w_vars(Out,Msg,[],[]))),!.
msg_to_string(pp(Msg),Str):- sformat(Str,Msg,[],[]),!.
msg_to_string(fmt(F,A),Str):-sformat(Str,F,A),!.
msg_to_string(format(F,A),Str):-sformat(Str,F,A),!.
msg_to_string(Msg,Str):-atomic(Msg),!,sformat(Str,'~w',[Msg]).
msg_to_string(m2s(Msg),Str):-message_to_string(Msg,Str),!.
msg_to_string(Msg,Str):-sformat(Str,Msg,[],[]),!.


:- thread_local t_l:formatter_hook/4.


%= 	 	 

%% withFormatter( ?Lang, ?From, ?Vars, ?SForm) is det.
%
% Using Formatter.
%
withFormatter(Lang,From,Vars,SForm):- t_l:formatter_hook(Lang,From,Vars,SForm),!.
withFormatter(_Lang,From,_Vars,SForm):-sformat(SForm,'~w',[From]).


%= 	 	 

%% flush_output_safe is det.
%
% Flush Output Safely Paying Attention To Corner Cases.
%
flush_output_safe(X):-catch(flush_output(X),_,true),!.
flush_output_safe(_).

%= 	 	 

%% flush_output_safe( ?X) is det.
%
% Flush Output Safely Paying Attention To Corner Cases.
%
flush_output_safe(X):-ignore(catchv(flush_output(X),_,true)).


%= 	 	 

%% writeFailureLog( ?E, ?X) is det.
%
% Write Failure Log.
%
writeFailureLog(E,X):-
  get_thread_current_error(ERR),
		(fmt(ERR,'\n% error: ~q ~q\n',[E,X]),flush_output_safe(ERR),!,
		%,true.
		fmt('\n% error: ~q ~q\n',[E,X]),!,flush_output).
writeFailureLog(E,X):-
        writeFmt(user_error,'\n% error:  ~q ~q\n',[E,X]),flush_output_safe(user_error),!,
        %,true.
        writeFmt('\n;; error:  ~q ~q\n',[E,X]),!,flush_output. %,wdmsg([E,X]).
         

%unknown(Old, autoload).


%= 	 	 

%% cls is det.
%
% Clauses.
%
cls:- ignore(catch(system:shell(cls,0),_,fail)).

%:- ensure_loaded(logicmoo_util_varnames).
%:- ensure_loaded(logicmoo_util_catch).
% :- autoload([verbose(false)]).

/*
:- 'mpred_trace_none'(fmt(_)).
:- 'mpred_trace_none'(fmt(_,_)).
:- 'mpred_trace_none'(dfmt(_)).
:- 'mpred_trace_none'(dfmt(_,_)).
:- 'mpred_trace_none'(dmsg(_)).
:- 'mpred_trace_none'(dmsg(_,_)).
:- 'mpred_trace_none'(portray_clause_w_vars(_)).
*/

:- ignore((source_location(S,_),prolog_load_context(module,M),module_property(M,class(library)),
 forall(source_file(M:H,S),
 ignore((functor(H,F,A),
  ignore(((\+ atom_concat('$',_,F),(export(F/A) , current_predicate(system:F/A)->true; system:import(M:F/A))))),
  ignore(((\+ predicate_property(M:H,transparent), module_transparent(M:F/A), \+ atom_concat('__aux',_,F),debug(modules,'~N:- module_transparent((~q)/~q).~n',[F,A]))))))))).

:- '$hide'(wdmsg(_)).
:- '$hide'(wdmsg(_,_)).


:- fixup_exports.


end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.

:- meta_predicate(hideTrace(:,+)).
hideTrace(_:A, _) :-
        var(A), !, trace, fail,
        throw(error(instantiation_error, _)).
hideTrace(_:[], _) :- !.
hideTrace(A:[B|D], C) :- !,
        hideTrace(A:B, C),
        hideTrace(A:D, C),!.
 
hideTrace(M:A,T):-!,hideTraceMP(M,A,T),!.
hideTrace(MA,T):-hideTraceMP(_,MA,T),!.
 
hideTraceMP(M,F/A,T):-!,hideTraceMFA(M,F,A,T),!.
hideTraceMP(M,P,T):-functor(P,F,0),trace,hideTraceMFA(M,F,_A,T),!.
hideTraceMP(M,P,T):-functor(P,F,A),hideTraceMFA(M,F,A,T),!.
 
tryCatchIgnore(MFA):- catch(MFA,_E,true). %%dmsg(tryCatchIgnoreError(MFA:E))),!.
tryCatchIgnore(_MFA):- !. %%dmsg(tryCatchIgnoreFailed(MFA)).
 
tryHide(MFA):- tryCatchIgnore('$hide'(MFA)).
 
hideTraceMFA(_,M:F,A,T):-!,hideTraceMFA(M,F,A,T),!. 
hideTraceMFA(M,F,A,T):-user:nonvar(A),functor(P,F,A),predicate_property(P,imported_from(IM)),IM \== M,!,nop(dmsg(doHideTrace(IM,F,A,T))),hideTraceMFA(IM,F,A,T),!.
hideTraceMFA(M,F,A,T):-hideTraceMFAT(M,F,A,T),!.
 
hideTraceMFAT(M,F,A,T):-doHideTrace(M,F,A,T),!.
 
doHideTrace(_M,_F,_A,[]):-!.
doHideTrace(M,F,A,[hide|T]):- tryHide(M:F/A),!,doHideTrace(M,F,A,T),!.
doHideTrace(M,F,A,ATTRIB):- tryHide(M:F/A),!, 
   tryCatchIgnore(trace(M:F/A,ATTRIB)),!.
 
 
ctrace:-willTrace->trace;notrace.
 
bugger:-hideTrace,traceAll,guitracer,debug,list_undefined.
 
singletons(_).
 
 
 
dumpList(B):- currentContext(dumpList,Ctx),dumpList(Ctx,B).
dumpList(_,AB):-dmsg(dumpList(AB)),!.
 
dumpList(_,[]):-!.
%dumpList(Ctx,[A|B]):-!,say(Ctx,A),dumpList(Ctx,B),!.
%dumpList(Ctx,B):-say(Ctx,dumpList(B)).
 
 
ifThen(When,Do):-When->Do;true.
 
%%:- current_predicate(F/N),trace(F/N, -all),fail.
/*
traceAll:- current_predicate(user:F/N),
   functor(P,F,N),
   local_predicate(P,F/N),
   trace(F/N, +fail),fail.
traceAll:- not((predicate_property(clearCateStack/1,_))),!.
traceAll:-findall(_,(member(F,[member/2,dmsg/1,takeout/3,findall/3,clearCateStack/1]),trace(F, -all)),_).
*/                             
traceAll:-!.
hideTrace:-
   hideTrace([hotrace/1], -all),
   %%hideTrace(computeInnerEach/4, -all),
 
   hideTrace(
     [maplist_safe/2, 
              maplist_safe/3], -all),
 
 
   hideTrace([hideTrace/0,
         canTrace/0,
         ctrace/0,         
         willTrace/0], -all),
 
   hideTrace([
         traceafter_call/1,
 
         notrace_call/1], -all),
 
   hideTrace(user:[
      call/1,
      call/2,
      apply/2,
      '$bags':findall/3,
      '$bags':findall/4,
      once/1,
      ','/2,
      catch/3,
      member/2], -all),
 
   hideTrace(user:setup_call_catcher_cleanup/4,-all),
 
   hideTrace(system:throw/1, +all),
   %%hideTrace(system:print_message/2, +all),
   hideTrace(user:message_hook/3 , +all),
   hideTrace(system:message_to_string/2, +all),
   !,hideRest,!.
   %%findall(File-F/A,(functor_source_file(M,P,F,A,File),M==user),List),sort(List,Sort),dmsg(Sort),!.
 
hideRest:- fail, logicmoo_util_library:buggerDir(BuggerDir),
      functor_source_file(M,_P,F,A,File),atom_concat(BuggerDir,_,File),hideTraceMFA(M,F,A,-all),
      fail.
hideRest:- functor_source_file(system,_P,F,A,_File),hideTraceMFA(system,F,A,-all), fail.
hideRest.
 
 
functor_source_file(M,P,F,A,File):-functor_source_file0(M,P,F,A,File). %% prolog_must(ground((M,F,A,File))),prolog_must(user:nonvar(P)).
functor_source_file0(M,P,F,A,File):-current_predicate(F/A),functor(P,F,A),source_file(P,File),predicate_module(P,M).
 
predicate_module(P,M):- predicate_property(P,imported_from(M)),!.
predicate_module(M:_,M):-!. %strip_module(P,M,_F),!.
predicate_module(_P,user):-!. %strip_module(P,M,_F),!.
%%predicate_module(P,M):- strip_module(P,M,_F),!.
 
 
 
 
%%% peekAttributes/2,pushAttributes/2,pushCateElement/2.
 
/*
neverUse:- meta_predicate_transparent
    maplist_safe(2,:),
    maplist_safe(3,:,:),
        asserta_new(2,:),
        writeqnl(2,:),
        prolog_must_tracing(1),
        prolog_must(1),
        beenCaught(1),
        debugOnFailureEach(1), 
        prolog_must(1),ignore(1), %%withAttributes(3,:,:),call_cleanup(0,0),call_cleanup(0,?,0),
        !.
*/

%% debugOnFailureEach( :Goal) is semidet.
%
% Debug Whenever Failure Each.
%
debugOnFailureEach(Goal):-with_each(1,on_f_debug,Goal).



%% on_f_debug_ignore( :Goal) is semidet.
%
% Whenever Functor Debug Ignore.
%
on_f_debug_ignore(Goal):-ignore(on_f_debug(Goal)).


logOnFailure(Goal):-on_f_log_fail(Goal).



%% beenCaught( :TermGoal) is semidet.
%
% Been Caught.
%
beenCaught(must(Goal)):- !, beenCaught(Goal).
beenCaught((A,B)):- !,beenCaught(A),beenCaught(B).
beenCaught(Goal):- fail, predicate_property(Goal,number_of_clauses(_Count)), clause(Goal,(_A,_B)),!,clause(Goal,Body),beenCaught(Body).
beenCaught(Goal):- catchv(once(Goal),E,(dmsg(caugth(Goal,E)),beenCaught(Goal))),!.
beenCaught(Goal):- traceAll,dmsg(tracing(Goal)),debug,dtrace,Goal.





%% randomVars( :GoalTerm) is semidet.
%
% Random Variables.
%
randomVars(Term):- random(R), StartR is round('*'(R,1000000)), !,
 ignore(Start=StartR),
 snumbervars(Term, Start, _).



%% prolog_must_not( :Goal) is semidet.
%
% Prolog Must Be Successfull Not.
%
prolog_must_not(Call):-Call,!,dtrace,!,programmer_error(prolog_must_not(Call)).
prolog_must_not(_Call):-!.

% %retractall(E):- retractall(E),functor_safe(E,File,A),dynamic(File/A),!.


%% printPredCount( ?Msg, :GoalPred, ?N1) is semidet.
%
% Print Predicate Count.
%
printPredCount(Msg,Pred,N1):- compound(Pred), debugOnFailureEach((arg(_,Pred,NG))),nonvar(NG),!,
  findall(Pred,Pred,LEFTOVERS),length(LEFTOVERS,N1),dmsg(num_clauses(Msg,Pred,N1)),!.

printPredCount(Msg,Pred,N1):-!,functor_safe(Pred,File,A),functor_safe(FA,File,A), predicate_property(FA,number_of_clauses(N1)),dmsg(num_clauses(Msg,File/A,N1)),!.






%% showProfilerStatistics( :GoalFileMatch) is semidet.
%
% Show Profiler Statistics.
%
showProfilerStatistics(FileMatch):-
  statistics(global,Mem), MU is (Mem / 1024 / 1024),
  printPredCount('showProfilerStatistics: '(MU),FileMatch,_N1).


show_failure(X):- X*->true;(dmsg(failed(X)),fail).
show_failure(Why,X):- X*->true;(dmsg(failed(Why,X)),fail).

show_success(X):- X*->dmsg(success(X));fail.

% on_xf_cont(Goal):- ignore(catch(Goal,_,true)).
on_xf_cont(X):-ignore(logOnFailure(X)),!.
 
writeModePush(_Push):-!.
writeModePop(_Pop):-!.
 

%% on_f_log_ignore( :Goal) is semidet.
%
% Whenever Functor Log Ignore.
%
on_f_log_ignore(Goal):-ignore(logOnFailure0(on_x_log_throw(Goal))).
%% if_prolog( ?UPARAM1, :GoalG) is semidet.
%
% If Prolog.
%
if_prolog(swi,G):-call(G). % Run B-Prolog Specifics
if_prolog(_,_):-!. % Dont run SWI Specificd or others



%% fmtString( ?X, ?Y, ?Z) is semidet.
%
% Format String.
%
fmtString(X,Y,Z):-sformat(X,Y,Z).



%% fmtString( ?Y, ?Z) is semidet.
%
% Format String.
%
fmtString(Y,Z):-sformat(Y,Z).





%% saveUserInput is semidet.
%
% Save User Input.
%
saveUserInput:-retractall(isConsoleOverwritten_bugger),flush_output.



%% writeSavedPrompt is semidet.
%
% Write Saved Prompt.
%
writeSavedPrompt:-not(isConsoleOverwritten_bugger),!.
writeSavedPrompt:-flush_output.



%% writeOverwritten is semidet.
%
% Write Overwritten.
%
writeOverwritten:-isConsoleOverwritten_bugger,!.
writeOverwritten:-assert(isConsoleOverwritten_bugger).




%% writeErrMsg( ?Out, ?E) is semidet.
%
% Write Err Msg.
%
writeErrMsg(Out,E):- message_to_string(E,S),fmt(Out,'<cycml:error>~s</cycml:error>\n',[S]),!.



%% writeErrMsg( ?Out, ?E, ?Goal) is semidet.
%
% Write Err Msg.
%
writeErrMsg(Out,E,Goal):- message_to_string(E,S),fmt(Out,'<cycml:error>goal "~q" ~s</cycml:error>\n',[Goal,S]),!.



%% writeFileToStream( ?Dest, ?Filename) is semidet.
%
% Write File Converted To Stream.
%
writeFileToStream(Dest,Filename):-
    catchv((
    open(Filename,'r',Input),
    repeat,
        get_code(Input,Char),
        put(Dest,Char),
    at_end_of_stream(Input),
    close(Input)),E,
    fmt('<cycml:error goal="~q">~w</cycml:error>\n',[writeFileToStream(Dest,Filename),E])).




% =================================================================================
% Utils
% =================================================================================
% test_call(G):-writeln(G),ignore(once(catchv(G,E,writeln(E)))).




%% debugFmtList( ?ListI) is semidet.
%
% Debug Format List.
%
debugFmtList(ListI):-quietly((copy_term(ListI,List),debugFmtList0(List,List0),randomVars(List0),dmsg(List0))),!.



%% debugFmtList0( :TermA, :TermB) is semidet.
%
% Debug Format List Primary Helper.
%
debugFmtList0([],[]):-!.
debugFmtList0([A|ListA],[B|ListB]):-debugFmtList1(A,B),!,debugFmtList0(ListA,ListB),!.




%% debugFmtList1( ?Value, ?Value) is semidet.
%
% Debug Format List Secondary Helper.
%
debugFmtList1(Value,Value):-var(Value),!.
debugFmtList1(Name=Number,Name=Number):-number(Number).
debugFmtList1(Name=Value,Name=Value):-var(Value),!.
debugFmtList1(Name=Value,Name=(len:Len)):-copy_term(Value,ValueO),append(ValueO,[],ValueO),is_list(ValueO),length(ValueO,Len),!.
debugFmtList1(Name=Value,Name=(F:A)):-functor_safe(Value,F,A).
debugFmtList1(Value,shown(Value)).



%% unlistify( ?L, ?L) is semidet.
%
% Unlistify.
%
unlistify([L],O):-nonvar(L),unlistify(L,O),!.
unlistify(L,L).




%% listify( ?OUT, ?OUT) is semidet.
%
% Listify.
%
listify(OUT,OUT):-not(not(is_list(OUT))),!.
listify(OUT,[OUT]).





%% traceIf( :Goal) is semidet.
%
%  Trace if.
%
traceIf(_Call):-!.
traceIf(Call):-ignore((Call,dtrace)).

%getWordTokens(WORDS,TOKENS):-concat_atom(TOKENS,' ',WORDS).
%is_string(S):- pce_expansion:is_string(S).




% :-(forall(current_predicate(FA),mpred_trace_nochilds(FA))).
% hide this module from tracing
% :-(forall(current_predicate(logicmoo_util_strings:FA),mpred_trace_nochilds(logicmoo_util_strings:FA))).


%% programmer_error( :GoalE) is semidet.
%
% Programmer Error.
%
programmer_error(E):-dtrace, randomVars(E),dmsg("~q~n",[error(E)]),dtrace,randomVars(E),!,throw(E).



%=  :- mpred_trace_childs(must/1).

% must(C):- ( 1 is random(4)) -> rmust_det(C) ; C.





end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.



end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.


% File: /opt/PrologMUD/pack/logicmoo_base/prolog/logicmoo/util/logicmoo_util_rtrace.pl
:- module(rtrace,
   [
      nortrace/0,
      pop_tracer/0,
      push_tracer/0,
      push_tracer_and_notrace/0,
      pop_guitracer/0,
      rtrace/0,
      stop_rtrace/0,
      start_rtrace/0,
      push_guitracer/0,
      reset_tracer/0,
      rtrace/1,  % dtrace why choice points are left over
      ftrace/1, % tells why a call didn't succeed once
      restore_trace/1,
      on_x_debug/1,
      hotrace/1,
      maybe_leash/1      
    ]).

:- meta_predicate
	catchv(0,-,0),
        restore_trace(0),
        on_x_debug(0),
        % % ftrace(0),        gftrace(0),ggtrace(0),grtrace(0),rtrace(0),hotrace(0).

:- module_transparent
      hotrace/1,
      nortrace/0,
      pop_tracer/0,
      push_tracer/0,
      push_tracer_and_notrace/0,
      reset_tracer/0,
      pop_guitracer/0,
      rtrace/0,      
      push_guitracer/0.

% 



%! maybe_leash( +Flags) is det.
%
% Only leashs the main thread
%
%maybe_leash(-Some):- thread_self_main->leash(-Some);true.
%maybe_leash(+Some):- thread_self_main->leash(+Some);true.
maybe_leash(Some):- thread_self_main->leash(Some);true.

:- meta_predicate hotrace(0).

hotrace(Goal):-!,call(Goal).
hotrace(Goal):-
   ((tracing,notrace )-> Tracing = trace ;   Tracing = true),
   '$leash'(OldL, OldL),'$visible'(OldV, OldV),
   (Undo =   notrace(((notrace,'$leash'(_, OldL),'$visible'(_, OldV), Tracing)))),
   (RTRACE = notrace((visible(-all),visible(+exception),maybe_leash(-all),maybe_leash(+exception)))),!,
   scce_orig(RTRACE,(notrace,Goal),Undo).


% :- trace(hotrace/1, -all).       
% hotrace(Goal):- get_hotrace(Goal,Y),Y.
%:- mpred_trace_less(hotrace/1).
%:- maybe_hide(hotrace/1).
%:- maybe_hide(hotrace/1).


:- thread_local(tl_rtrace:rtracing/0).


% =========================================================================

 

%! rtrace is nondet.
%
% R Trace.
%
rtrace:- notrace,push_guitracer,set_prolog_flag(gui_tracer,false),start_rtrace,trace. % push_guitracer,noguitracer

start_rtrace:- asserta(tl_rtrace:rtracing),visible(+all),visible(+exception),maybe_leash(-all),maybe_leash(+exception).
:- maybe_hide(start_rtrace/0).



%! nortrace is nondet.
%
% Nor Trace.
%
nortrace:- notrace,stop_rtrace.

stop_rtrace:- ignore(retract(tl_rtrace:rtracing)),
 visible(+all),visible(+exception),maybe_leash(+all),maybe_leash(+exception).
:- maybe_hide(stop_rtrace/0).

push_tracer_and_notrace:- notrace,push_tracer,notrace.



%! rtrace( :Goal) is nondet.
%
% R Trace.
%
% rtrace(Goal):- hotrace(tl_rtrace:rtracing),!, Goal.

% rtrace(Goal):- wdmsg(rtrace(Goal)),!, restore_trace(scce_orig(rtrace,(trace,Goal),nortrace)).

% rtrace(Goal):- quietly(tl_rtrace:rtracing),!,call(Goal).
rtrace(Goal):- !,scce_orig(rtrace,(trace,Goal),stop_rtrace).
/*
rtrace(Goal):- !,scce_orig(notrace(start_rtrace),call((notrace(rtrace),Goal)),notrace(stop_rtrace)).
rtrace(Goal):- tracing,!,setup_call_cleanup(start_rtrace,call(Goal),notrace(stop_rtrace)).
rtrace(Goal):- \+ tracing,start_rtrace,!,setup_call_cleanup(trace,call(Goal),(notrace,stop_rtrace)).
rtrace(Goal):- 
  ((tracing,notrace )-> Tracing = trace ;   Tracing = true),
   '$leash'(OldL, OldL),'$visible'(OldV, OldV),
   wdmsg(rtrace(Goal)),
   (Undo =   (((notrace,ignore(retract(tl_rtrace:rtracing)),'$leash'(_, OldL),'$visible'(_, OldV), Tracing)))),
   (RTRACE = ((notrace,asserta(tl_rtrace:rtracing),visible(+all),maybe_leash(-all),maybe_leash(+exception),trace))),!,
   scce_orig(RTRACE,(trace,Goal),Undo).
*/
/*
:- maybe_hide(system:call_cleanup/2).
:- maybe_hide(system:call_cleanup/2).
:- maybe_hide(system:setup_call_cleanup/3).
:- maybe_hide(system:setup_call_cleanup/3).
:- maybe_hide(system:setup_call_catcher_cleanup/4).
:- maybe_hide(system:setup_call_catcher_cleanup/4).
*/
:- maybe_hide(hotrace/1).
:- maybe_hide(notrace/1).
:- maybe_hide(rtrace/0).
:- maybe_hide(nortrace/0).
:- maybe_hide(pop_tracer/0).
:- maybe_hide(tl_rtrace:rtracing/0).
:- maybe_hide(system:tracing/0).
:- maybe_hide(system:notrace/0).
:- maybe_hide(system:trace/0).
 :- meta_predicate  ftrace(0).





% :- mpred_trace_less(rtrace/0).
% :- mpred_trace_less(nortrace/0).
% :- mpred_trace_less(nortrace/0).
% :- mpred_trace_less(rtrace/0).

:- unlock_predicate(system:notrace/1).
% :- mpred_trace_less(system:notrace/1).
%:- maybe_hide(hotrace/1).
%:- maybe_hide(hotrace/1).
% :- if_may_hide('$hide'(hotrace/1)).
% :- if_may_hide('$hide'(system:notrace/1,  hide_childs, 1)).
% :- if_may_hide('$hide'(system:notrace/1)).
:- maybe_hide(notrace/1).
:- lock_predicate(system:notrace/1).


:- maybe_hide(system:trace/0).
:- maybe_hide(system:notrace/0).
:- maybe_hide(system:tracing/0).

%:- ( listing(hotrace/1),redefine_system_predicate(system:notrace(_)), mpred_trace_none(hotrace(0)) ).
% :- if_may_hide('$hide'(hotrace/1)).
% :- if_may_hide('$hide'(hotrace/1,  hide_childs, 1)).



%! on_x_debug( :GoalC) is nondet.
%
% If there If Is A an exception in  :Goal Class then r Trace.
%
on_x_debug(C):- !,
 notrace(((skipWrapper;tracing;(tl_rtrace:rtracing)),maybe_leash(+exception))) -> C;
   catchv(C,E,
     (wdmsg(on_x_debug(E)),catchv(rtrace(with_skip_bugger(C)),E,wdmsg(E)),dtrace(C))).
on_x_debug(Goal):- with_each(0,on_x_debug,Goal).



/*

rtrace(Goal):- notrace((tracing,'$leash'(OldL, OldL),'$visible'(OldV, OldV))),start_rtrace,!,
   (scce_orig(trace,Goal,stop_rtrace)*-> set_leash_vis(OldL,OldV) ; notrace((set_leash_vis(OldL,OldV),!,fail))).
rtrace(Goal):- 
  setup_call_cleanup(
  ('$leash'(OldL, OldL),'$visible'(OldV, OldV),start_rtrace),
   scce_orig(start_rtrace,Goal,stop_rtrace),
   (notrace,set_leash_vis(OldL,OldV))).

rtrace(Goal):- notrace((tracing,'$leash'(OldL, OldL),'$visible'(OldV, OldV))),start_rtrace,!,
   (Goal*-> set_leash_vis(OldL,OldV) ; notrace((set_leash_vis(OldL,OldV),!,fail))).

rtrace(Goal):- '$leash'(OldL, OldL),'$visible'(OldV, OldV),start_rtrace,!,
   (Goal*-> set_leash_vis(OldL,OldV) ; notrace((set_leash_vis(OldL,OldV),!,fail))).

rtrace(Goal):- notrace(tracing),!, restore_trace(scce_orig(start_rtrace,(Goal*->notrace;(stop_rtrace,!,fail)),notrace(stop_rtrace))).
rtrace(Goal):- !, restore_trace(scce_orig(start_rtrace,(Goal*->notrace;(notrace,!,nortrace,fail)),notrace(stop_rtrace))).

rtrace(Goal):-
  push_tracer,!,rtrace,trace,
  ((Goal,notrace,deterministic(YN),)*->
    (YN == true -> pop_tracer ; next_rtrace);
    ((notrace,pop_tracer,!,fail))).
*/


end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.



end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.
end_of_file.


% File: /opt/PrologMUD/pack/logicmoo_base/prolog/logicmoo/util/logicmoo_util_rtrace.pl
:- module(rtrace,
   [
      nortrace/0,
      pop_tracer/0,
      push_tracer/0,
      push_tracer_and_notrace/0,
      pop_guitracer/0,
      rtrace/0,
      stop_rtrace/0,
      start_rtrace/0,
      push_guitracer/0,
      reset_tracer/0,
      rtrace/1,  % dtrace why choice points are left over
      ftrace/1, % tells why a call didn't succeed once
      restore_trace/1,
      on_x_debug/1,
      hotrace/1,
      maybe_leash/1      
    ]).

:- meta_predicate
	catchv(0,-,0),
        restore_trace(0),
        on_x_debug(0),
        % % ftrace(0),        gftrace(0),ggtrace(0),grtrace(0),rtrace(0),hotrace(0).

:- module_transparent
      hotrace/1,
      nortrace/0,
      pop_tracer/0,
      push_tracer/0,
      push_tracer_and_notrace/0,
      reset_tracer/0,
      pop_guitracer/0,
      rtrace/0,      
      push_guitracer/0.

% 



%! maybe_leash( +Flags) is det.
%
% Only leashs the main thread
%
%maybe_leash(-Some):- thread_self_main->leash(-Some);true.
%maybe_leash(+Some):- thread_self_main->leash(+Some);true.
maybe_leash(Some):- thread_self_main->leash(Some);true.

:- meta_predicate hotrace(0).

hotrace(Goal):-!,call(Goal).
hotrace(Goal):-
   ((tracing,notrace )-> Tracing = trace ;   Tracing = true),
   '$leash'(OldL, OldL),'$visible'(OldV, OldV),
   (Undo =   notrace(((notrace,'$leash'(_, OldL),'$visible'(_, OldV), Tracing)))),
   (RTRACE = notrace((visible(-all),visible(+exception),maybe_leash(-all),maybe_leash(+exception)))),!,
   scce_orig(RTRACE,(notrace,Goal),Undo).


% :- trace(hotrace/1, -all).       
% hotrace(Goal):- get_hotrace(Goal,Y),Y.
%:- mpred_trace_less(hotrace/1).
%:- maybe_hide(hotrace/1).
%:- maybe_hide(hotrace/1).


:- thread_local(tl_rtrace:rtracing/0).


% =========================================================================

 

%! rtrace is nondet.
%
% R Trace.
%
rtrace:- notrace,push_guitracer,set_prolog_flag(gui_tracer,false),start_rtrace,trace. % push_guitracer,noguitracer

start_rtrace:- asserta(tl_rtrace:rtracing),visible(+all),visible(+exception),maybe_leash(-all),maybe_leash(+exception).
:- maybe_hide(start_rtrace/0).



%! nortrace is nondet.
%
% Nor Trace.
%
nortrace:- notrace,stop_rtrace.

stop_rtrace:- ignore(retract(tl_rtrace:rtracing)),
 visible(+all),visible(+exception),maybe_leash(+all),maybe_leash(+exception).
:- maybe_hide(stop_rtrace/0).

push_tracer_and_notrace:- notrace,push_tracer,notrace.



%! rtrace( :Goal) is nondet.
%
% R Trace.
%
% rtrace(Goal):- hotrace(tl_rtrace:rtracing),!, Goal.

% rtrace(Goal):- wdmsg(rtrace(Goal)),!, restore_trace(scce_orig(rtrace,(trace,Goal),nortrace)).

% rtrace(Goal):- quietly(tl_rtrace:rtracing),!,call(Goal).
rtrace(Goal):- !,scce_orig(rtrace,(trace,Goal),stop_rtrace).
/*
rtrace(Goal):- !,scce_orig(notrace(start_rtrace),call((notrace(rtrace),Goal)),notrace(stop_rtrace)).
rtrace(Goal):- tracing,!,setup_call_cleanup(start_rtrace,call(Goal),notrace(stop_rtrace)).
rtrace(Goal):- \+ tracing,start_rtrace,!,setup_call_cleanup(trace,call(Goal),(notrace,stop_rtrace)).
rtrace(Goal):- 
  ((tracing,notrace )-> Tracing = trace ;   Tracing = true),
   '$leash'(OldL, OldL),'$visible'(OldV, OldV),
   wdmsg(rtrace(Goal)),
   (Undo =   (((notrace,ignore(retract(tl_rtrace:rtracing)),'$leash'(_, OldL),'$visible'(_, OldV), Tracing)))),
   (RTRACE = ((notrace,asserta(tl_rtrace:rtracing),visible(+all),maybe_leash(-all),maybe_leash(+exception),trace))),!,
   scce_orig(RTRACE,(trace,Goal),Undo).
*/
/*
:- maybe_hide(system:call_cleanup/2).
:- maybe_hide(system:call_cleanup/2).
:- maybe_hide(system:setup_call_cleanup/3).
:- maybe_hide(system:setup_call_cleanup/3).
:- maybe_hide(system:setup_call_catcher_cleanup/4).
:- maybe_hide(system:setup_call_catcher_cleanup/4).
*/
:- maybe_hide(hotrace/1).
:- maybe_hide(notrace/1).
:- maybe_hide(rtrace/0).
:- maybe_hide(nortrace/0).
:- maybe_hide(pop_tracer/0).
:- maybe_hide(tl_rtrace:rtracing/0).
:- maybe_hide(system:tracing/0).
:- maybe_hide(system:notrace/0).
:- maybe_hide(system:trace/0).
 :- meta_predicate  ftrace(0).





% :- mpred_trace_less(rtrace/0).
% :- mpred_trace_less(nortrace/0).
% :- mpred_trace_less(nortrace/0).
% :- mpred_trace_less(rtrace/0).

:- unlock_predicate(system:notrace/1).
% :- mpred_trace_less(system:notrace/1).
%:- maybe_hide(hotrace/1).
%:- maybe_hide(hotrace/1).
% :- if_may_hide('$hide'(hotrace/1)).
% :- if_may_hide('$hide'(system:notrace/1,  hide_childs, 1)).
% :- if_may_hide('$hide'(system:notrace/1)).
:- maybe_hide(notrace/1).
:- lock_predicate(system:notrace/1).


:- maybe_hide(system:trace/0).
:- maybe_hide(system:notrace/0).
:- maybe_hide(system:tracing/0).

%:- ( listing(hotrace/1),redefine_system_predicate(system:notrace(_)), mpred_trace_none(hotrace(0)) ).
% :- if_may_hide('$hide'(hotrace/1)).
% :- if_may_hide('$hide'(hotrace/1,  hide_childs, 1)).



%! on_x_debug( :GoalC) is nondet.
%
% If there If Is A an exception in  :Goal Class then r Trace.
%
on_x_debug(C):- !,
 notrace(((skipWrapper;tracing;(tl_rtrace:rtracing)),maybe_leash(+exception))) -> C;
   catchv(C,E,
     (wdmsg(on_x_debug(E)),catchv(rtrace(with_skip_bugger(C)),E,wdmsg(E)),dtrace(C))).
on_x_debug(Goal):- with_each(0,on_x_debug,Goal).



/*

rtrace(Goal):- notrace((tracing,'$leash'(OldL, OldL),'$visible'(OldV, OldV))),start_rtrace,!,
   (scce_orig(trace,Goal,stop_rtrace)*-> set_leash_vis(OldL,OldV) ; notrace((set_leash_vis(OldL,OldV),!,fail))).
rtrace(Goal):- 
  setup_call_cleanup(
  ('$leash'(OldL, OldL),'$visible'(OldV, OldV),start_rtrace),
   scce_orig(start_rtrace,Goal,stop_rtrace),
   (notrace,set_leash_vis(OldL,OldV))).

rtrace(Goal):- notrace((tracing,'$leash'(OldL, OldL),'$visible'(OldV, OldV))),start_rtrace,!,
   (Goal*-> set_leash_vis(OldL,OldV) ; notrace((set_leash_vis(OldL,OldV),!,fail))).

rtrace(Goal):- '$leash'(OldL, OldL),'$visible'(OldV, OldV),start_rtrace,!,
   (Goal*-> set_leash_vis(OldL,OldV) ; notrace((set_leash_vis(OldL,OldV),!,fail))).

rtrace(Goal):- notrace(tracing),!, restore_trace(scce_orig(start_rtrace,(Goal*->notrace;(stop_rtrace,!,fail)),notrace(stop_rtrace))).
rtrace(Goal):- !, restore_trace(scce_orig(start_rtrace,(Goal*->notrace;(notrace,!,nortrace,fail)),notrace(stop_rtrace))).

rtrace(Goal):-
  push_tracer,!,rtrace,trace,
  ((Goal,notrace,deterministic(YN),)*->
    (YN == true -> pop_tracer ; next_rtrace);
    ((notrace,pop_tracer,!,fail))).
*/

