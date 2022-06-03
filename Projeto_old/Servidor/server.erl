-module (server).
-export ([start/0]).
-import (login_manager, [start_Login_Manager/0, create_account/2, close_account/2, login/2, logout/1, online/0]). 
-import (estado, [start_state/0]). 

start () ->
    io:format("Iniciei o Server~n"),
    PidState = spawn ( fun() -> estado:start_state() end),  %Iniciar o processo com o estado do servidor
    register(state,PidState),
    register(login_manager, spawn( fun() -> login_manager:start_Login_Manager() end)), % Criar processo que se encarrega de guardar os logins e validar passwords
    Port = 12345,
    {ok, Socket} = gen_tcp:listen(Port, [binary, {packet, line}, {reuseaddr, true}]),    %criar o Socket
    acceptor(Socket).

acceptor ( Socket )->
    {ok, Sock} = gen_tcp:accept(Socket),
    spawn( fun() -> acceptor( Socket ) end), % Geramos outro aceptor para permitir que outros clientes se possam conectar ao servidor
    authenticator(Sock).

authenticator(Sock) ->
    io:format("Iniciei o Autenticador~n"),
    receive
        {tcp, _ , Data}->
            StrData = binary:bin_to_list(Data),
            io:format("Recebi estes Dados~p~n",[StrData]),
            [Acao | Aux] = string:tokens(StrData, " "),
            [User | Passs] = Aux,
            [Pass1 | T] = Passs,
            Pass = string:substr(Pass1,1,(string:len(Pass1)-2)),
            io:format("Acao = ~p~n",[Acao]),
            io:format("User = ~p~n",[User]),
            io:format("Pass = ~p~n",[Pass]),

            case Acao of
                "login" when User =:= "" ->
                    io:format("Login Falhou ~n"),
                    U = 0,
                    P = 0,
                    gen_tcp:send(Sock,<<"login error\n">>),
                    authenticator(Sock);

                "login" when Pass =:= "" ->
                    io:format("Login Falhou ~n"),
                    U = 0,
                    P = 0,
                    gen_tcp:send(Sock,<<"login error\n">>),
                    authenticator(Sock);

                "login" ->
                    io:format("Login Deu ~n"),
                    U = re:replace(User, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
                    P = re:replace(Pass, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),                   
                    
                    case login(U,P) of
                        ok ->
                            gen_tcp:send(Sock, <<"login successful\n">>),
                            user(Sock, U);
                        _ ->
                            gen_tcp:send(Sock,<<"login error\n">>),
                            authenticator(Sock) % Volta a tentar autenticar-se
                    end;
                "create_account" when User =:= "" ->
                    io:format("Create Account Falhou ~n"),
                    U = 0,
                    P = 0,
                    gen_tcp:send(Sock,<<"create_account error\n">>),
                    authenticator(Sock);

                "create_account" when Pass =:= "" ->
                    io:format("Create Account Falhou ~n"),
                    U = 0,
                    P = 0,
                    gen_tcp:send(Sock,<<"create_account error\n">>),
                    authenticator(Sock);

                "create_account" ->
                    io:format("Create Account Deu ~n"),
                    U = re:replace(User, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
                    P = re:replace(Pass, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
                    case create_account(U,P) of
                        ok ->
                            gen_tcp:send(Sock, <<"create_account successful\n">>),
                            %user(Sock, U);
                            authenticator(Sock);
                        _ ->
                            gen_tcp:send(Sock,<<"create_account error\n">>),
                            authenticator(Sock)
                    end;

                "close_account" when User =:= "" ->
                    io:format("Close Account Falhou ~n"),
                    U = 0,
                    P = 0,
                    gen_tcp:send(Sock,<<"close_account error\n">>),
                    authenticator(Sock);

                "close_account" when Pass =:= "" ->
                    io:format("Close Account Falhou ~n"),
                    U = 0,
                    P = 0,
                    gen_tcp:send(Sock,<<"close_account error\n">>),
                    authenticator(Sock);

                "close_account" ->
                    io:format("Close Account Deu ~n"),
                    U = re:replace(User, "(^\s+)|(\s+$)", "", [global,{return,list}]),
                    P = re:replace(Pass, "(^\s+)|(\s+$)", "", [global,{return,list}]),
                    case close_account(U,P) of
                        ok ->
                            gen_tcp:send(Sock, <<"close_account successful\n">>),
                            %user(Sock, U);
                            authenticator(Sock);
                        _ ->
                            gen_tcp:send(Sock,<<"close_account error\n">>),
                            authenticator(Sock)
                    end;
                _ ->
                    gen_tcp:send(Sock,<<"Opção Inválida \n">>),
                    io:format("dados ~p~n",[Data]),
                    authenticator(Sock)
            end
    end.




user(Sock, Username) ->
    statePid ! {ready, Username, self()},
    gen_tcp:send(Sock, <<"Há espera por vaga\n">>),
    io:format("Estou á espera de um Começa!~n"),
    receive % Enquanto não receber resposta fica bloqueado
        {comeca, GameManager} ->
            gen_tcp:send(Sock, <<"Comeca\n">>),
            io:format("Desbloquiei vou começar o jogo~n"),
            cicloJogo(Sock, Username, GameManager) % Desbloqueou vai para a função principal do jogo
    end.

logout (Username, Sock) ->
    receive
        {tcp, _ , Data}->
            StrData = binary:bin_to_list(Data),
            Str = re:replace(StrData, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
            io:format("User said ~p~n",[Str]),
            case Str of
                "logout" ->
                    case logout(Username) of
                        ok ->
                            gen_tcp:send(Sock, <<"logout successful\n">>);
                            %gen_tcp:close(Sock);
                        _ ->
                            gen_tcp:send(Sock,<<"logout error\n">>),
                            logout(Username, Sock)
                    end;
                _ ->
                    logout(Username, Sock)
            end
        end
    .



cicloJogo(Sock, Username, GameManager) -> % Faz a mediação entre o Cliente e o processo GameManager
    receive
        {line, Data} -> % Recebemos alguma coisa do processo GameManager
            io:format("ENVIEI ESTES DADOS~p~n",[Data]),
            gen_tcp:send(Sock, Data),
            cicloJogo(Sock, Username, GameManager);
        {tcp, _, Data} -> % Recebemos alguma coisa do socket (Cliente), enviamos para o GameManager
            NewData = re:replace(Data, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
            case NewData of
                "quit" ->
                    io:format("Recebi quit"),
                    GameManager ! {leave, self()},
                    cicloJogo(Sock, Username, GameManager);
                _ ->
                    GameManager ! {keyPressed, Data, self()}, % Precisamos de saber quem foi que premiu a tecla!
                    cicloJogo(Sock, Username, GameManager)
            end;
        {tcp_closed, _} ->
            GameManager ! {leave, self()};
        {tcp_error, _} ->
            GameManager ! {leave, self()};
        {gameEnd, Result} ->
            gen_tcp:send(Sock, Result),
            logout(Username, Sock)
    end.