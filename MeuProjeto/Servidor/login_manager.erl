-module (login_manager).
-export( [start_Login_Manager/1, create_account/2, close_account/2, login/2, logout/1, mapa_para_string/1,maps_para_string/1,booleanoString/1]).

start_Login_Manager (Mapa) ->
    Pid = spawn ( fun() -> loop ( Mapa ) end ),
    register (module,Pid).




call(Request)->
    module ! {Request,self()},          %mandar request ao module com o meu pid
    receive Res -> Res end.   % esperar receber resposta


create_account(Username, Passwd) -> call({create_account,Username,Passwd}).

close_account(Username, Passwd) -> call({close_account,Username,Passwd}).

login(Username, Passwd) -> call({login,Username,Passwd}).

logout(Username) -> call({logout,Username}).




booleanoString(Estado) ->
    case Estado of
        true -> "true";
        false -> "false"
    end.    


mapa_para_string(Mapa) ->
    {Username, {Pass, Estado}} = Mapa,
    Lista = "{" ++ "\"" ++ Username ++ "\"" ++ ", {" ++ "\"" ++ Pass ++ "\"" ++ "," ++ booleanoString(Estado) ++ "}}",  
    io:format("TESTE ~s~n",[Lista]),
    Lista.


maps_para_string([]) -> "";
maps_para_string([H]) -> mapa_para_string(H) ++ ".";
maps_para_string([H|T]) -> mapa_para_string(H) ++ "." ++ "\n" ++  maps_para_string(T).


loop(Map) ->
    receive
        {{create_account, Username, Pass}, From} ->
            case maps:find (Username,Map) of
                error when Username =:= "", Pass =:= "" ->
                    From ! bad_arguments,              % mandar mensagem ao from a dizer que nao gostou dos argumentos (ambos vazios)
                    loop (Map);
                error ->                                    % mandar mensagem ao from a dizer ok caso que criou a conta
                    From ! ok,
                    Data = [Username, {Pass, false}],
                    Map2 = maps:put(Username, {Pass, false}, Map),
                    file:delete("Logins.txt"),
                    file:open("Logins.txt",write),
                    F = maps_para_string(maps:to_list(Map2)),
                    file:write_file("Logins.txt", io_lib:fwrite("~s~n", [F])),
                    loop ( Map2 );
                _ ->
                    From ! invalid,           % mandar mensagem ao from a dizer que o user ja existe pois o find nao deu erro
                    loop (Map)
            end;
        

        {{close_account, Username, Pass}, From} ->
            case maps:find (Username, Map) of
                {ok , {Pass, _ } } ->                       % _ -> uma coisa qualquer onde diz se esta online (T/F)
                        From ! ok,
                        %delete user from file
                        Map2 = maps:remove (Username,Map),
                        file:delete("Logins.txt"),
                        file:open("Logins.txt",write),
                        file:write_file("Logins.txt", io_lib:fwrite("~p\n", [Map2])),
                        loop ( Map2 );

                _ ->
                    From ! invalid,
                    loop ( Map )
            end;
        

        {{login , Username , Pass}, From} ->
            case maps:find (Username,Map) of
                {ok, {Pass,false}} ->
                    From ! ok,
                    loop ( maps:put ( Username, {Pass,true}, Map) ) ;
                _ ->
                    From ! invalid,
                    loop ( Map )
            end;
        
        
        {{logout, Username }, From} ->
            case maps:find (Username,Map) of
                {ok, {Pass,true}} ->
                    From ! ok,          
                    loop ( maps:put ( Username, {Pass, false}, Map) );
                _ ->
                    From ! invalid,
                    loop ( Map )
            end
    end.
