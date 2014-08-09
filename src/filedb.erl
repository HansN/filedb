-module(filedb).

-export([read/2,
	 write/1]).

-compile(export_all).

read(Tab, Id) ->
    case file:consult(file_name(Tab,Id)) of
	{ok,Term} -> [Term];
	_ -> []
    end.

write(Term) ->
    file:write_file(ensure_path(file_name(Term)), io_lib:format("~p.~n",[Term])).

%%%================================================================
%%%
%%% Internal

file_name(Tab, Id) when is_integer(Id) -> 
    file_name(Tab, integer_to_list(Id));
file_name(Tab, Id) ->
    {ok,Root} = application:get_env(filedb, root),
    filename:join([Root, Tab, Id]) ++ ".txt".

file_name(Term) -> file_name(tab(Term), id(Term)).


tab(Term) -> element(1, Term).
id(Term) -> element(keypos(tab(Term)), Term).


ensure_path(FileName) -> 
    {ok,Cwd} = file:get_cwd(),
    [begin 
	 file:make_dir(D),
	 ok=file:set_cwd(D)
     end || D <- lists:droplast(filename:split(FileName))],
    file:set_cwd(Cwd),
    FileName.


keypos(Tab) ->
    proplists:get_value(Tab, application:get_env(filedb, keypos, []), 2).
