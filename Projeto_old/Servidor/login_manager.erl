-module (login_manager).
-export( [start_Login_Manager/0, create_account/2, close_account/2, login/2, logout/1]).

start_Login_Manager () ->
    Pid = spawn ( fun() -> loop ( #{} ) end ),
    register (module,Pid).




call(Request)->
    module ! {Request,self()},          %mandar request ao module com o meu pid
    receive Res -> Res end.   % esperar receber resposta


create_account(Username, Passwd) -> call({create_account,Username,Passwd}).

close_account(Username, Passwd) -> call({close_account,Username,Passwd}).

login(Username, Passwd) -> call({login,Username,Passwd}).

logout(Username) -> call({logout,Username}).



loop(Map) ->
    io:format("MAPA LOGINS~p~n",[maps:to_list(Map)]),
    receive
        {{create_account, Username, Pass}, From} ->
            case maps:find (Username,Map) of
                error when Username =:= "", Pass =:= "" ->
                    From ! bad_arguments,              % mandar mensagem ao from a dizer que nao gostou dos argumentos (ambos vazios)
                    loop (Map);
                error ->                                    % mandar mensagem ao from a dizer ok caso que criou a conta
                    From ! ok,
                    loop ( maps:put(Username, {Pass, false}, Map) );
                _ ->
                    From ! invalid,           % mandar mensagem ao from a dizer que o user ja existe pois o find nao deu erro
                    loop (Map)
            end;
        

        {{close_account, Username, Pass}, From} ->
            case maps:find (Username, Map) of
                {ok , {Pass, _ } } ->                       % _ -> uma coisa qualquer onde diz se esta online (T/F)
                        From ! ok,
                        loop ( maps:remove (Username,Map) );

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
