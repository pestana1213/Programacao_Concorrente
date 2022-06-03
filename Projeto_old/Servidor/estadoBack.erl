-module (estado).
-export ([start/0]).
-import (criaturas, [novaCriatura/1, atualizaCriatura/4, verificaColisoesVermelhas/3, verificaColisoesLista/2, verificaColisao/2, atualizaListaCriaturas/4]).
-import (jogadores, [novoJogador/1, acelerarFrente/1, viraDireita/1, viraEsquerda/1, atualizaJogadores/5 ]).   %%%%
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

% GAME END



millis() ->
  {Mega, Sec, Micro} = os:timestamp(),
  (Mega*1000000 + Sec)*1000 + round(Micro/1000).

start() ->
    io:format(" Novo Jogo~n"),
    register(?GAME,spawn( fun() -> gameManager (novoEstado(), erlang:timestamp(), self(), millis()) end )),
    Timer = spawn( fun() -> refreshTimer(?GAME) end),
    SpawnReds = spawn ( fun() -> addReds(?GAME) end),    
    estado(#{}, [], [], [])
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


estado(Pontuacoes_Jogadores, Atuais_Jogadores, Espera_Jogadores, MelhoresPontuacoes) ->
    io:format("Entrei no estado ~n"),
    receive
        {ready, Username, UserProcess} when Length (Atuais_Jogadores) =:= 3 -> % Recebemos ready de um user mas o jogo está cheio, vai esperar
            io:format("Recebi ready de ~p mas ele vai esperar ~n", [Username]),
            estado(Pontuacoes_Jogadores, Atuais_Jogadores, Espera_Jogadores ++ [{Username, UserProcess}], MelhoresPontuacoes); %Adicionamos lo entao aos jogadores em espera
        
        {ready, Username, UserProcess} when Length (Atuais_Jogadores) < 3 -> % Recebemos ready de um user vamos adicionar lo ao jogo                                              
            io:format("Recebi ready do User ~p e vou adicionar-lo ao jogo ~n",[Username]),
            UserProcess ! {comeca, ?GAME},
            ?GAME ! {geraJogador,{Username, UserProcess}},
            estado(Pontuacoes_Jogadores, Atuais_Jogadores ++ [{Username, UserProcess}], Espera_Jogadores, MelhoresPontuacoes); 

        {leave, Username, UserProcess}  -> % Recebemos leave de alguem vamos adicionar outro ao jogo                                              
            io:format("Recebi leave do User ~p ~n",[Username]),
            if 
                length(Espera_Jogadores) == 0 -> 
                    ?GAME ! {leave,{Username, UserProcess}},
                    estado(Pontuacoes_Jogadores, Atuais_Jogadores -- [{Username, UserProcess}], Espera_Jogadores, MelhoresPontuacoes); 
                true -> 
                    ?GAME ! {leave,{Username, UserProcess}},
                    [H | T] = Espera_Jogadores,
                    {_, UP} = H,
                    UP ! {comeca, ?GAME},
                    ?GAME ! {geraJogador,H},
                    estado(Pontuacoes_Jogadores, Atuais_Jogadores -- [{Username, UserProcess}] ++ H, T, MelhoresPontuacoes); 

            end; 
    end
.


novoEstado() ->
    
    State = {[], [], [], [], {1200,800}},
    io:fwrite("Estado: ~p ~n", [State]),
    State.

adicionaJogador(Estado,Jogador) ->
    {ListaJogadores, ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra} = Estado,
    State = { ListaJogadores ++ [{novoJogador(), Jogador}], ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra},
    io:fwrite("Estado: ~p ~n", [State]),
    State.

removeJogador(Estado,Jogador) ->
    {ListaJogadores, ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra} = Estado,
    State = { ListaJogadores -- [{_, Jogador}], ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra},
    io:fwrite("Estado: ~p ~n", [State]),
    State.


processKeyPressData( Data ) ->
    % Tem que retornar "w", "a" ou "d".
    Key = re:replace(Data, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
    io:format("Carregou na tecla ~p~n", [Key]),
    Key.


gameManager(Estado, TempoInicio, PidEstado, UltimoUpdateTime)->
    ServerRefreshRate = 50, % WARNING : If you change this, change it in refreshTimer's Time too. (too lazy to change other stuff now)
    io:format("Game Manager a correr ~n"),
    % Como calcular a pontuação?
    % Processo que faz a gestão do jogo entre dois users, contem stats e trata de toda a lógica da partida
    receive
        {keyPressed, Data, From} ->
            io:format("Entrei no keyPressed ~n"),
            KeyPressed = processKeyPressData( Data ),
            { AlguemPerdeu, ListaPerdeu } = verificaDerrota(Estado),
            if
                AlguemPerdeu ->
                    io:format("Someone Lost~n"),
                    endGame(Estado, TempoInicio, erlang:timestamp(), ListaPerdeu, PidEstado); %gameManager(State, TimeStarted); % TODO: handle end game
                true ->
                    io:format("Update with KeyPress~n"),
                    Now = millis(),
                    Interpolacao = (Now - UltimoUpdateTime)/ServerRefreshRate,
                    NovoEstado = updateWithKeyPress(Estado, KeyPressed, From, Interpolacao),
                    %Res = formatState(NewState),
                    gameManager(NovoEstado, TempoInicio, PidEstado, Now)
            end;

        {leave, From} ->
            io:format("Alguem enviou leave"),
            gameManager(adicionaJogador(Estado,From), TempoInicio, PidEstado, UltimoUpdateTime);


        {geraJogador, From} ->
            io:format("Vou gerar jogador"),
            gameManager(removeJogador(Estado,From), TempoInicio, PidEstado, UltimoUpdateTime);

        {refresh, _} ->
            io:format("Entrei no ramo refresh ~n"),
            { SomeoneLost, WhoLost } = checkLosses(Estado),
            {{_, {_, Pid1}}, {_, {_, Pid2}}, _, _, _} = Estado,

            if
                SomeoneLost ->
                    io:format("alguem morreu no refresh do gameManager~n"),
                    endGame(Estado, TempoInicio, erlang:timestamp(), WhoLost, PidEstado);
                true ->
                    Now = millis(),
                    Interpolacao = (Now - UltimoUpdateTime)/ServerRefreshRate,
                    NovoEstado = update(Estado, Interpolacao),
                    Res = formatState(NovoEstado, TempoInicio),
                    io:format("Novo estado : ~p~n",[Res]),
                    Pid1 ! Pid2 ! {line, list_to_binary(Res)},
                    gameManager(NovoEstado, TempoInicio, PidEstado, Now)
            end
            ;


        {addReds, _} ->
            io:format("Entrei no addReds~n"),
            {ListaJogadores, ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra} = Estado,
            io:format("Vou Adicionar uma criatura vermelha~n"),
            Creature = newCreature(r),
            gameManager({ListaJogadores, ListaVerdes, ListaReds ++ [Creature],ListaObstaculos, TamanhoEcra}, TempoInicio, PidEstado, UltimoUpdateTime)

    end.

endGame(Estado, TempoInicio, TempoFim, ListaPerdeu, PidEstado) ->
    %Construir as pontuações
    {{_, {U1, Pid1}}, {_, {U2, Pid2}}, _, _, _} = Estado,
    {LoserUsername, _} = ListaPerdeu,
    io:format("Enviar mensagem ao estado e aos users~n"),
    Res = formatResult(Result),
    %Pid1 ! Pid2 ! {gameEnd, Res},
    PidEstado ! {gameEnd, Result, Res, Pid1, Pid2, self() }.

%Não sei se funciona mas em principio sim , o processo e o mesmo





updateWithKeyPress(State, KeyPressed, From, InterpolateBy) ->
    {{P1, {U1,PID_P1}}, {P2, {U2,PID_P2}}, GreenCreatures, RedCreatures, ArenaSize } = State,

    if
        From == PID_P1 ->
            if
                KeyPressed == "w" -> NewPlayer = acelerarFrente(P1);
                KeyPressed == "a" -> NewPlayer = viraEsquerda(P1);
                KeyPressed == "d" -> NewPlayer = viraDireita(P1);
                true -> NewPlayer = P1
            end,
            update({{NewPlayer, {U1,PID_P1}}, {P2, {U2,PID_P2}}, GreenCreatures, RedCreatures, ArenaSize }, InterpolateBy);
        From == PID_P2 ->
            if
                KeyPressed == "w" -> NewPlayer = acelerarFrente(P2);
                KeyPressed == "a" -> NewPlayer = viraEsquerda(P2);
                KeyPressed == "d" -> NewPlayer = viraDireita(P2);
                true -> NewPlayer = P2
            end,
            update({{P1, {U1,PID_P1}}, {NewPlayer, {U2,PID_P2}}, GreenCreatures, RedCreatures, ArenaSize }, InterpolateBy);
        true ->
            io:format("Unkown id ~p in updateWithKeyPress", [From]),
            update({{P1, {U1,PID_P1}}, {P2, {U2,PID_P2}}, GreenCreatures, RedCreatures, ArenaSize }, InterpolateBy)
    end.



verificaDerrota(Estado) ->
    %% Determines if a player if lost
    %% Which means determining if a player as touched a red creature,
    %% or if a player as gone outside the board
    %% returns a pair where the first element is a boolean value saying if someon loss
    %% the second value is the id of the player o lost.
    %% if no player lost then the second value is `none`
    %% eg.: {true, PlayerID}, or {false, none}. Where PlayerID is some value that represents the player
    
    
    % Um jogador perde (saindo do jogo) quando, tendo o tamanho o mınimo, colide com uma criatura
    % venenosa, obstaculo, ou parede.


    {ListaJogadores, _, ListaReds, ListaObstaculos,TamanhoEcra} = Estado,
    {TemColisoes, JogadoresColidiram } = verificaColisoesVermelhas(ListaJogadores, ListaReds),   
    % verifica colisao obstaculo
    {ContraParede, JogadoresContraParede} = verificaColisaoParede(ListaJogadores, TamanhoEcra),
    if
        TemColisoes == true -> {true, JogadoresColidiram};
        %ContraObstaculo == true -> {true, JogadoresContraObstaculo};
        ContraParede == true -> {true, JogadoresContraParede};
        true -> {false, []}
    end.



update(State, InterpolateBy) ->
    {{P1, {U1,PID_P1}}, {P2, {U2,PID_P2}}, GreenCreatures, RedCreatures, ArenaSize} = State,
    {Green1, Green2} = GreenCreatures,

    % Update Players
    GreenColisions_P1 = checkGreenColisions(P1, GreenCreatures),
    GreenColisions_P2 = checkGreenColisions(P2, GreenCreatures),
    {NewP1, NewP2} = updatePlayers(P1, P2, GreenColisions_P1, GreenColisions_P2, InterpolateBy),

    % Update Green Creatures
    Green1Colided = checkColision(P1, Green1) or checkColision(P2, Green1),
    Green2Colided = checkColision(P1, Green2) or checkColision(P2, Green2),
    if
        Green1Colided == true -> NewGreen1 = newCreature(g);
        true -> NewGreen1 = updateCreature(Green1, P1, P2, InterpolateBy)
    end,
    if
        Green2Colided == true -> NewGreen2 = newCreature(g);
        true -> NewGreen2 = updateCreature(Green2, P1, P2, InterpolateBy)
    end,
    NewGreenCreatures = { NewGreen1, NewGreen2 },

    % Update Red Creatures
    NewRedCreatures = updateCreaturesList(RedCreatures, P1, P2, InterpolateBy),

    % Return New State
    { {NewP1, {U1,PID_P1}}, {NewP2,{U2,PID_P2}}, NewGreenCreatures, NewRedCreatures, ArenaSize }.



checkGreenColisions( Player, GreenCreatures ) ->
    {Creature1, Creature2} = GreenCreatures,
    Colided1 = checkColision(Player, Creature1),
    Colided2 = checkColision(Player, Creature2),
    if
        Colided1 and Colided2 -> 2;
        Colided1 and not Colided2 -> 1;
        not Colided1 and Colided2 -> 1;
        true -> 0
    end.



temColisao (Jogador, TamanhoEcra) ->
    {{JogadorPos, _, _, _, _, _, _, _, _, _, _, _}, ID_Jogador} = Jogador,
    {ArenaX, ArenaY} = TamanhoEcra,
    { X, Y } = JogadorPos,
    if  
        (X < 0) or (X > ArenaX) or (Y < 0) or (Y > ArenaY) -> true;
        true -> false
    end.


verificaColisaoParede(ListaJogadores, TamanhoEcra) ->  
    JogadoresColidiram = [X || X <- ListaJogadores, temColisao(X)],
    IDsJogadoresColidiram = [ID_Jogador || {A,ID_Jogador} <- ListaJogadores],
    if  
        length(IDsJogadoresColidiram) =:= 0 -> {false;[]};
        true -> {true;IDsJogadoresColidiram}
    end.



formatTops(ScoreTop, LevelTop) ->
    %TOP:,\n
    TopScoreList = [User ++ ": " ++ float_to_list(Score, [{decimals, 3}] )|| {User, Score} <- ScoreTop],
    ScoreData = string:join(TopScoreList, ","),
    TopLevelList = [User ++ ": " ++ integer_to_list(Level) || {User, Level} <- LevelTop ],
    LevelData = string:join(TopLevelList, ","),
    Res = "TOP:," ++ ScoreData ++",,Levels:,"++ LevelData ++ ",",
    Res.



formatResult({{U1, S1}, {U2, S2}}) ->
    Res = "result,"++ U1 ++ "," ++ float_to_list(S1, [{decimals, 3}] ) ++ "," ++ U2 ++ "," ++ float_to_list(S2, [{decimals, 3}] ) ++ ",",
    Res.

formatState(State, TimeStarted) ->
    %P1 and P2 contain the Player objects, Player1 and Player 2 contain {Username, UserProcess}
    %"elisio",1,2, 0,0,20,1,2.25,0.55,20,2,0.2,0.1,100;
    % "\n",1,2, 0,0,20,2,2.25,0.55,20,2,0.2,0.1,100;
    % 1;
    % 1,2 0, 3,4, 50, g,1;
    % 1,2, 0,3,4, 50, g,1;
    % 1;
    % 1,2, 0,3,4, 50, g,1;
    { {P1, {Username1, _}}, {P2, {Username2, _}}, GreenCreatures, RedCreatures, _} = State,
    User1 = formatPlayer(P1, Username1),
    User2 = formatPlayer(P2, Username2),
    Score = (timer:now_diff(erlang:timestamp(), TimeStarted)) / 1000000,
    %io:format("User1 : ~p~n",[User1]),

    {Green1, Green2} = GreenCreatures,
    GreenCreaturesLen = 2,
    GreenCreaturesAux = [formatCreatures(Green1), formatCreatures(Green2)],
    GreenCreaturesData = string:join(GreenCreaturesAux, ","),


    %io:format("Green : ~p~n",[GreenCreaturesData]),

    RedCreaturesLen = length(RedCreatures),
    RedCreaturesAux = [formatCreatures(Creature) || Creature <- RedCreatures],
    RedCreaturesData = string:join(RedCreaturesAux, ","),


    %io:format("Red : ~p~n",[RedCreaturesData]),
    % CENA NOVA!!!!!
    Result = "state," ++ float_to_list(Score, [{decimals, 3}]) ++ "," ++ User1 ++ "," ++
             User2 ++ "," ++
             integer_to_list(GreenCreaturesLen) ++ "," ++
             GreenCreaturesData ++ "," ++
             integer_to_list(RedCreaturesLen) ++ "," ++
             RedCreaturesData ++ "\n",
    Result.

formatCreatures(Creature) ->
    {{X, Y}, {DirX, DirY}, {Dx, Dy}, Size, Type, Velocity} = Creature,
    if
        Type == g ->
            StrType = "g";
        true ->
            StrType = "r"
    end,
    Result = float_to_list(X, [{decimals, 3}]) ++ "," ++
             float_to_list(Y, [{decimals, 3}]) ++ "," ++
             float_to_list(DirX, [{decimals, 3}]) ++ "," ++
             float_to_list(DirY, [{decimals, 3}]) ++ "," ++
             float_to_list(Dx, [{decimals, 3}]) ++ "," ++
             float_to_list(Dy, [{decimals, 3}]) ++ "," ++
             float_to_list(Size, [{decimals, 3}]) ++ "," ++
             StrType ++ "," ++
            float_to_list(Velocity, [{decimals, 3}]),
    Result.

formatPlayer(P1, Username1) ->
    {{P1x, P1y}, P1Direction, P1Velocity, P1Energy, P1Type, P1FrontAcceleration, P1AngularVelocity, P1MaxEnergy, P1EnergyWaste, P1EnergyGain, P1Drag, P1Size} = P1,
    User1 = Username1 ++ "," ++
            float_to_list(P1x, [{decimals, 3}]) ++ "," ++
            float_to_list(P1y, [{decimals, 3}]) ++ "," ++
            float_to_list(P1Direction, [{decimals, 3}]) ++ "," ++
            float_to_list(P1Velocity, [{decimals, 3}]) ++ "," ++
            float_to_list(P1Energy, [{decimals, 3}]) ++ "," ++
            integer_to_list(P1Type) ++ "," ++
            float_to_list(P1FrontAcceleration, [{decimals, 3}]) ++ "," ++
            float_to_list(P1AngularVelocity, [{decimals, 3}]) ++ "," ++
            float_to_list(P1MaxEnergy, [{decimals, 3}]) ++ "," ++
            float_to_list(P1EnergyWaste, [{decimals, 3}]) ++ "," ++
            float_to_list(P1EnergyGain, [{decimals, 3}]) ++ "," ++
            float_to_list(P1Drag, [{decimals, 3}]) ++ "," ++
            float_to_list(P1Size, [{decimals, 3}]),
    User1.
