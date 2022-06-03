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
            %io:format("Recebi estes Dados~p~n",[StrData]),
            ListaDados = string:tokens(string:substr(StrData,1,(string:len(StrData)-2)), " "),
            LenghtListaDados = length(ListaDados),
            if 
                LenghtListaDados == 1 ->
                    [Acao | Aux] = ListaDados,
                    User = "",
                    Pass = "";
                LenghtListaDados == 2 ->
                    [Acao | Aux] = ListaDados,
                    [User | Passs] = Aux,
                    Pass = "";
                true ->
                    [Acao | Aux] = ListaDados,
                    [User | Passs] = Aux,
                    [Pass1 | T] = Passs,
                    Pass = Pass1
            end,
            %io:format("Acao = ~p~n",[Acao]),
            %io:format("User = ~p~n",[User]),
            %io:format("Pass = ~p~n",[Pass]),

            case Acao of
                "login" when User =:= "" ->
                    io:format("Login Falhou User inválido ~n"),
                    gen_tcp:send(Sock,<<"Login Falhou User inválido\n">>),
                    authenticator(Sock);

                "login" when Pass =:= "" ->
                    io:format("Login Falhou Pass inválida ~n"),
                    gen_tcp:send(Sock,<<"Login Falhou Pass inválida\n">>),
                    authenticator(Sock);

                "login" ->
                   
                    U = re:replace(User, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
                    P = re:replace(Pass, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),                   
                    
                    case login(U,P) of
                        ok ->
                            io:format("Login Deu ~n"),
                            gen_tcp:send(Sock, <<"Login feito com sucesso!\n">>),
                            user(Sock, U);
                        _ ->
                            io:format("Login nao deu ~n"),
                            gen_tcp:send(Sock,<<"Username e Password não correspondem!\n">>),
                            authenticator(Sock) % Volta a tentar autenticar-se
                    end;
                "create_account" when User =:= "" ->
                    io:format("Create Account Falhou User inválido ~n"),
                    gen_tcp:send(Sock,<<"Create Account Falhou User inválido\n">>),
                    authenticator(Sock);

                "create_account" when Pass =:= "" ->
                    io:format("Create Account Falhou Pass inválida ~n"),
                    gen_tcp:send(Sock,<<"Create Account Falhou Pass inválida\n">>),
                    authenticator(Sock);

                "create_account" ->
                    
                    U = re:replace(User, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
                    P = re:replace(Pass, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
                    case create_account(U,P) of
                        ok ->
                            io:format("Create Account feito com sucesso! ~n"),
                            gen_tcp:send(Sock, <<"Create Account feito com sucesso!\n">>),
                            %user(Sock, U);
                            authenticator(Sock);
                        _ ->
                            io:format("Username e Password não correspondem! ~n"),
                            gen_tcp:send(Sock,<<"Conta já existente!\n">>),
                            authenticator(Sock)
                    end;

                "close_account" when User =:= "" ->
                    io:format("Close Account Falhou User inválido ~n"),
                    gen_tcp:send(Sock,<<"Close Account Falhou User inválido \n">>),
                    authenticator(Sock);

                "close_account" when Pass =:= "" ->
                    io:format("Close Account Falhou Pass inválida ~n"),
                    gen_tcp:send(Sock,<<"Close Account Falhou Pass inválida\n">>),
                    authenticator(Sock);

                "close_account" ->
                    
                    U = re:replace(User, "(^\s+)|(\s+$)", "", [global,{return,list}]),
                    P = re:replace(Pass, "(^\s+)|(\s+$)", "", [global,{return,list}]),
                    case close_account(U,P) of
                        ok ->
                            io:format("Close Account feito com sucesso! ~n"),
                            gen_tcp:send(Sock, <<"Close Account feito com sucesso!\n">>),
                            %user(Sock, U);
                            authenticator(Sock);
                        _ ->
                            io:format("Username e Password não correspondem! ~n"),
                            gen_tcp:send(Sock,<<"Username e Password não correspondem!\n">>),
                            authenticator(Sock)
                    end;


                _ ->
                    gen_tcp:send(Sock,<<"Opção Inválida \n">>),
                    %io:format("dados ~p~n",[Data]),
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
            %io:format("ENVIEI ESTES DADOS~p~n",[Data]),
            gen_tcp:send(Sock, Data),
            cicloJogo(Sock, Username, GameManager);
        {tcp, _, Data} -> % Recebemos alguma coisa do socket (Cliente), enviamos para o GameManager
            NewData = re:replace(Data, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
            case NewData of
                "pontos" -> 
                    io:format("Recebi pontos"),
                    GameManager ! {pontos, self()},
                    cicloJogo(Sock, Username, GameManager);
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