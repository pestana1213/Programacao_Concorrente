-module (estado).
-export ([start_state/0]).
-import (criaturas, [novaCriatura/1]).
-import (jogadores, [novoJogador/0]).   %%%%
-import (auxiliar, [multiplicaVector/2, normalizaVector/1, meioVectores/2, adicionaPares/2, distancia/2, subtraiVectores/2]).
-import (timer, [send_after/3]).
-import (math, [sqrt/1, pow/2, cos/1, sin/1]).

% O que será necessário manter no estado?
% - Map User -> {PartidasVencidas, Nivel} -- Reset ao PartidasVencidas quando subir de nivel
% - Lista de users em espera, tem {Username, Nivel, Pid do Processo User}
% - Top Pontuaçoes e Top Niveis - Not so sure -- Listas maybe, fáceis de ordenar..
% - Como vamos guardar os jogos que estão a decorrer? Outro processo? Faz sentido o estado, quando recebe um novo user ter um processo diferente que
% trate da parte do jogo em si e que depois comunique no final o resultado certo? Esse processo comunica por mensagens com os processos user dos clientes
%

%% IMPORTANT note about the User
%% In the State we save a pair that represents the user: {PlayerAvartar, UserObject}
%%  - The first element represents the PlayerAvatar; referenced as (P#)
%%  - The second Element is another pair representing the User {Username, UserProcess}: referenced as whole as (ID_P#)
%%     -- The first element is the User's username;   referenced as (U#)
%%     -- The first element is the User's Process ID; referenced as (PID_P#)

% game END



millis() ->
  {Mega, Sec, Micro} = os:timestamp(),
  (Mega*1000000 + Sec)*1000 + round(Micro/1000).

start_state() ->
    io:format(" Novo Jogo~n"),
    register(game,spawn( fun() -> gameManager (novoEstado(), erlang:timestamp(), self(), millis()) end )),
    Timer = spawn( fun() -> refreshTimer(game) end),
    SpawnReds = spawn ( fun() -> addReds(game) end),    
    SpawnVerdes = spawn ( fun() -> addVerdes(game) end),   
    register(statePid,spawn( fun() -> estado(#{}, [], [], [])  end))
    .


refreshTimer (Pid) ->
    %Step needs to be an integer!
    io:format("Refresh ativo ~n"),
    %FramesPerSecond = 40,
    %Step = 1000/FramesPerSecond,
    %NumStep = integer_to_float(Step),
    Time = 50, % WARNING : If you change this, change it in gameManager' ServerRefreshRate too. (too lazy to change other stuff now)
    receive
        stop ->
            {}
    after
        Time ->
            Pid ! {refresh, self()},
            refreshTimer(Pid)
    end
    .

addReds (Pid) ->
    io:format("Red Ativo ~n"),
    Time = 10000,

    receive
        stop ->
        {}
    after Time ->
            Pid ! {addReds, self()},
            addReds(Pid)
    end
    .


addVerdes (Pid) ->
    io:format("Verde Ativo ~n"),
    Time = 10000,

    receive
        stop ->
        {}
    after Time ->
            Pid ! {addVerde, self()},
            addVerdes(Pid)
    end
    .


estado(Pontuacoes_Jogadores, Atuais_Jogadores, Espera_Jogadores, MelhoresPontuacoes) ->
    io:format("Entrei no estado ~n"),
    receive
        {ready, Username, UserProcess} -> 
            io:format("len ~p ~n", [length (Atuais_Jogadores)]),   
            if
                length (Atuais_Jogadores) == 3 ->             
                    io:format("Recebi ready de ~p mas ele vai esperar ~n", [Username]),                                                     % Recebemos ready de um user mas o jogo está cheio, vai esperar
                    estado(Pontuacoes_Jogadores, Atuais_Jogadores, Espera_Jogadores ++ [{Username, UserProcess}], MelhoresPontuacoes);      %Adicionamos lo entao aos jogadores em espera
                true -> 
                    io:format("Recebi ready do User ~p e vou adicionar-lo ao jogo ~n",[Username]),
                    UserProcess ! {comeca, game},
                    game ! {geraJogador,{Username, UserProcess}},
                    estado(Pontuacoes_Jogadores, Atuais_Jogadores ++ [{Username, UserProcess}], Espera_Jogadores, MelhoresPontuacoes)
            end;

        {leave, Username, UserProcess}  -> % Recebemos leave de alguem vamos adicionar outro ao jogo                                              
            io:format("Recebi leave do User ~p ~n",[Username]),
            case length (Espera_Jogadores) of
                0 -> 
                    game ! {leave,{Username, UserProcess}},
                    estado(Pontuacoes_Jogadores, Atuais_Jogadores -- [{Username, UserProcess}], Espera_Jogadores, MelhoresPontuacoes); 
                true -> 
                    game ! {leave,{Username, UserProcess}},
                    [H | T] = Espera_Jogadores,
                    {_, UP} = H,
                    UP ! {comeca, game},
                    game ! {geraJogador,H},
                    estado(Pontuacoes_Jogadores, Atuais_Jogadores -- [{Username, UserProcess}] ++ H, T, MelhoresPontuacoes)
            end
    end
.

geraObstaculo(ListaObs,0) -> ListaObs;
geraObstaculo(ListaObs,Numero) -> geraObstaculo(ListaObs++[{rand:uniform(1000)+100,rand:uniform(600)+100,rand:uniform(70)+30}],Numero-1).

novoEstado() ->
    %player, green, red, obstaculos, screensize
    ObstaculosLista = geraObstaculo([],2),
    State = {[], [], [], ObstaculosLista, {1200,800}},

    io:fwrite("Estado novo Gerado: ~p ~n", [State]),
    State.

adicionaJogador(Estado,Jogador) ->
    {ListaJogadores, ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra} = Estado,
    State = { ListaJogadores ++ [{novoJogador(), Jogador}], ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra},
    io:fwrite("Estado: ~p ~n", [State]),
    State.

removeJogador(Estado,Jogador) ->
    {ListaJogadores, ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra} = Estado,
    State = { ListaJogadores -- [Jogador], ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra},
    io:fwrite("Estado: ~p ~n", [State]),
    State.


processKeyPressData( Data ) ->
    % Tem que retornar "w", "a" ou "d".
    Key = re:replace(Data, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
    io:format("Carregou na tecla ~p~n", [Key]),
    Key.



propagar_msg_aux(_,[]) -> io:format("Mensagem foi propagada para todos!!! ~n");
propagar_msg_aux(Msg,[H|T]) ->
                io:format("Propagar ~p  para ~p~n",[Msg,H]),	
		H ! {line,Msg},
		propagar_msg_aux(Msg,T). 


jogador_para_string(Jogador) ->
    {_,{X,Y}, Direcao, _, EnergiaAtual,Raio, _, _, _, _, _, _, _,_, Agilidade} = Jogador,
    Lista = [integer_to_list(X), integer_to_list(Y), integer_to_list(Raio),float_to_list(Direcao, [{decimals, 3}]), float_to_list(EnergiaAtual, [{decimals, 3}]), float_to_list(Agilidade, [{decimals, 3}])],
    string:join(Lista, " ").


jogadores_para_string([]) -> "";
jogadores_para_string([H]) -> jogador_para_string(H) ++ " ";
jogadores_para_string([H|T]) -> jogador_para_string(H) ++ " " ++  jogadores_para_string(T).

criatura_para_string(Criatura) ->
    {{X,Y}, Direcao, _, _, _} = Criatura,
    Lista = [integer_to_list(X), integer_to_list(Y),float_to_list(Direcao, [{decimals, 3}])],
    string:join(Lista, " ").


criaturas_para_string([]) -> "";
criaturas_para_string([H]) -> criatura_para_string(H) ++ " ";
criaturas_para_string([H|T]) -> criatura_para_string(H) ++ " " ++ criaturas_para_string(T).


obstaculo_para_string(Obstaculo) ->
    {X,Y,Tamanho} = Obstaculo,
    Lista = [integer_to_list(X), integer_to_list(Y),integer_to_list(Tamanho)],
    string:join(Lista, " ").


obstaculos_para_string([]) -> "";
obstaculos_para_string([H]) -> obstaculo_para_string(H) ++ " ";
obstaculos_para_string([H|T]) -> obstaculo_para_string(H) ++ " " ++ obstaculos_para_string(T).


formatState (Estado) ->
    {ListaJogadores, ListaVerdes, ListaReds, ListaObstaculos, _} = Estado,
    Len1 = integer_to_list(length(ListaJogadores)) ++ " ",
    L1 = [J || {J, {_,_}} <- ListaJogadores ],
    R1 = jogadores_para_string(L1),
    Len2 = integer_to_list(length(ListaVerdes)) ++ " ",
    R2 = criaturas_para_string(ListaVerdes),
    Len3 = integer_to_list(length(ListaReds)) ++ " ",
    R3 = criaturas_para_string(ListaReds),
    Len4 = integer_to_list(length(ListaObstaculos)) ++ " ",
    R4 = obstaculos_para_string(ListaObstaculos),
    Resultado = Len1 ++ R1 ++ Len2 ++ R2 ++ Len3 ++ R3 ++ Len4 ++ R4 ++ "\n",
    Resultado.


gameManager(Estado, TempoInicio, PidEstado, UltimoUpdateTime)->
    ServerRefreshRate = 50, % WARNING : If you change this, change it in refreshTimer's Time too. (too lazy to change other stuff now)
    io:format("Game Manager a correr ~n"),
    % Como calcular a pontuação?
    % Processo que faz a gestão do jogo entre dois users, contem stats e trata de toda a lógica da partida
    receive
        {keyPressed, Data, From} ->
            io:format("Entrei no keyPressed ~n"),
            KeyPressed = processKeyPressData( Data );

        {geraJogador, From} ->
            io:format("Vou gerar jogador~n"),    
            gameManager(adicionaJogador(Estado,From), TempoInicio, PidEstado, UltimoUpdateTime);
            
        {refresh, From} ->
            io:format("Vou fazer refresh~n"),
            {ListaJogadores, _, _, _, _} = Estado,
            Pids = [Pid || {_, {User, Pid}} <- ListaJogadores ],
            EstadoM = formatState(Estado),
            %io:format("Estado String~p~n",[EstadoM]),
            propagar_msg_aux(formatState(Estado),Pids),
            gameManager(Estado, TempoInicio, PidEstado, UltimoUpdateTime);

        {leave, From} ->
            io:format("Alguem enviou leave~n"),
            {ListaJogadores, ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra} = Estado,
            if
                length(ListaJogadores) == 1->
                    [H|T] = ListaJogadores,
                    {_, {User1, Pid1}} = H,
                    if
                        Pid1 == From ->
                            gameManager(removeJogador(Estado,H), TempoInicio, PidEstado, UltimoUpdateTime);
                        true ->
                            gameManager(Estado, TempoInicio, PidEstado, UltimoUpdateTime)
                    end;
                length(ListaJogadores) == 2 ->
                    [H1|H2] = ListaJogadores,
                    {_, {User1, Pid1}} = H1,
                    {_, {User2, Pid2}} = H2,
                    if
                        Pid1 == From ->
                            gameManager(removeJogador(Estado,H1), TempoInicio, PidEstado, UltimoUpdateTime);
                        Pid2 == From ->
                            gameManager(removeJogador(Estado,H2), TempoInicio, PidEstado, UltimoUpdateTime);
                        true ->
                            gameManager(Estado, TempoInicio, PidEstado, UltimoUpdateTime)
                    end;
                length(ListaJogadores) == 3 ->
                    [H1|T] = ListaJogadores,
                    {_, {User1, Pid1}} = H1,
                    [H2|H3] = T,
                    {_, {User2, Pid2}} = H2,
                    {_, {User3, Pid3}} = H3,
                    if
                        Pid1 == From ->
                            gameManager(removeJogador(Estado,H1), TempoInicio, PidEstado, UltimoUpdateTime);
                        Pid2 == From ->
                            gameManager(removeJogador(Estado,H2), TempoInicio, PidEstado, UltimoUpdateTime);
                        Pid3 == From ->
                            gameManager(removeJogador(Estado,H3), TempoInicio, PidEstado, UltimoUpdateTime);
                        true ->
                            gameManager(Estado, TempoInicio, PidEstado, UltimoUpdateTime)
                    end;
                true ->
                    gameManager(Estado, TempoInicio, PidEstado, UltimoUpdateTime)
            end;


        {addReds, _} ->
            io:format("Entrei no addReds~n"),
            {ListaJogadores, ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra} = Estado,
            io:format("Vou Adicionar uma criatura vermelha~n"),
            Creature = novaCriatura(r),
            gameManager({ListaJogadores, ListaVerdes, ListaReds ++ [Creature],ListaObstaculos, TamanhoEcra}, TempoInicio, PidEstado, UltimoUpdateTime);

        {addVerde, _} ->
            io:format("Entrei no addVerdes~n"),
            {ListaJogadores, ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra} = Estado,
            io:format("Vou Adicionar uma criatura Verde~n"),
            Creature = novaCriatura(v),
            gameManager({ListaJogadores, ListaVerdes ++ [Creature], ListaReds ,ListaObstaculos, TamanhoEcra}, TempoInicio, PidEstado, UltimoUpdateTime)

    end.