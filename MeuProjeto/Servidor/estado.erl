-module (estado).
-export ([start_state/0,atualizaMelhoresPontos/2]).
-import (criaturas, [novaCriatura/2,atualizaListaCriaturas/2,verificaColisoesCriaturaLista/2]).
-import (jogadores, [novoJogador/1,acelerarFrente/1, viraDireita/1, viraEsquerda/1,atualizaJogadores/4 ]).   
-import (timer, [send_after/3]).
-import (auxiliar, [geraObstaculo/2]).
-import (conversores, [formatState/1,formatarPontuacoes/1, formataTecla/1]).



start_state() ->
    io:format(" Novo Jogo~n"),
    register(game,spawn( fun() -> gameManager (novoEstado(),#{}) end )),
    Timer = spawn( fun() -> refresh(game) end),
    SpawnReds = spawn ( fun() -> adicionarVerdes(game) end),    
    SpawnVerdes = spawn ( fun() -> adicionarReds(game) end),   
    register(statePid,spawn( fun() -> estado([], [])  end))
    .


refresh (Pid) -> receive after 10 -> Pid ! {refresh, self()}, refresh(Pid) end.
adicionarReds (Pid) -> receive after 5000 -> Pid ! {addReds, self()}, adicionarReds(Pid) end.
adicionarVerdes (Pid) -> receive after 5000 -> Pid ! {addVerde, self()}, adicionarVerdes(Pid) end.


estado(Atuais_Jogadores, Espera_Jogadores) ->
    io:format("Entrei no estado ~n"),
    receive
        {ready, Username, UserProcess} -> 
            io:format("len ~p ~n", [length (Atuais_Jogadores)]),   
            if
                length (Atuais_Jogadores) == 3 ->             
                    io:format("Recebi ready de ~p mas ele vai esperar ~n", [Username]),                                                     % Recebemos ready de um user mas o jogo está cheio, vai esperar
                    estado(Atuais_Jogadores, Espera_Jogadores ++ [{Username, UserProcess}]);      %Adicionamos lo entao aos jogadores em espera
                true -> 
                    io:format("Recebi ready do User ~p e vou adicionar-lo ao jogo ~n",[Username]),
                    UserProcess ! {comeca, game},
                    game ! {geraJogador,{Username, UserProcess}},
                    estado(Atuais_Jogadores ++ [{Username, UserProcess}], Espera_Jogadores)
            end;

        {leave, Username, UserProcess}  -> % Recebemos leave de alguem vamos adicionar outro ao jogo                                              
            io:format("Recebi leave do User ~p ~n",[Username]),
            case length (Espera_Jogadores) of
                0 -> 
                    game ! {leave,UserProcess},
                    Lista = Atuais_Jogadores -- [{Username, UserProcess}],
                    io:format("CASE 0 - A lista de jogadores ativos atuais ~p ~n",[Lista]),
                    estado(Lista, Espera_Jogadores); 
                _ -> 
                    game ! {leave, UserProcess},
                    io:format("A lista de jogadores ativos atuais ~p ~n",[Atuais_Jogadores]),
                    io:format("Vou tirar o da lista ~p ~n",[{Username, UserProcess}]),
                    Lista = Atuais_Jogadores -- [{Username, UserProcess}],
                    io:format("Lista jogador removido ~p ~n",[Lista]),
                    if 
                        length (Espera_Jogadores) > 0 ->
                            [H | T] = Espera_Jogadores,
                            {_, UP} = H,
                            UP ! {comeca, game},
                            game ! {geraJogador,H},                            
                            ListaA = Lista ++ [H];
                        true ->
                            T = [],
                            ListaA = Lista
                    end,
                    estado(ListaA, T)
            end
    end
.


novoEstado() ->
    %player, green, red, obstaculos, screensize
    ObstaculosLista = geraObstaculo([],3),
    State = {[], [], [], ObstaculosLista, {1300,700}},
    io:fwrite("Estado novo Gerado: ~p ~n", [State]),
    State.

adicionaJogador(Estado,Jogador) ->
    {ListaJogadores, ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra} = Estado,
    State = { ListaJogadores ++ [{novoJogador(ListaObstaculos), Jogador}], ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra},
    io:fwrite("Estado: ~p ~n", [State]),
    State.

removeJogador(Estado,Jogador) ->
    {ListaJogadores, ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra} = Estado,
    State = { ListaJogadores -- [Jogador], ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra},
    io:fwrite("Estado com jogador removido: ~p ~n", [State]),
    State.




atualizaMelhoresPontos(Map,[]) -> Map;
atualizaMelhoresPontos(Map,[H|T]) -> 
    {U,P} = H,
    case maps:find(U,Map) of
        error ->
            atualizaMelhoresPontos(maps:put(U, P, Map),T);
        {_,PontosA} when PontosA < P ->
            atualizaMelhoresPontos(maps:put(U, P, Map),T);
        _ ->
            atualizaMelhoresPontos(Map,T)
    end.
            

            
gameManager(Estado, MelhoresPontuacoes)->
    receive
        {geraJogador, From} ->
            io:format("Vou gerar jogador~n"),    
            gameManager(adicionaJogador(Estado,From),MelhoresPontuacoes);
        
        {pontos, From} ->
            Data = "Pontos" ++ " " ++ integer_to_list(length(maps:to_list(MelhoresPontuacoes))) ++ " " ++ formatarPontuacoes(maps:to_list(MelhoresPontuacoes)),
            io:format("ENVIEI ESTES DADOS~p~n",[Data]),
            From ! {line,Data},
            %io:format("Pontuaçoes ~p~n",[formatarPontuacoes(maps:to_list(MelhoresPontuacoes))]), 
            gameManager(Estado,MelhoresPontuacoes);


        {keyPressed, Data, From} ->
            %io:format("Entrei no keyPressed ~n"),
            KeyPressed = formataTecla(Data),
            NovoEstado = updateTeclas(Estado,KeyPressed,From), 
            %io:format("Estado Antigo~p~n",[Estado]), 
            %io:format("Novo Estado~p~n",[NovoEstado]), 
            gameManager(NovoEstado,MelhoresPontuacoes);

            
        {refresh, _} ->
            %io:format("Vou fazer refresh~n"),

            NovoEstado = update(Estado),
            {ListaJogadores, _, _, _, _} = Estado,
            Pids = [Pid || {_, {User, Pid}} <- ListaJogadores ],
            %EstadoM = formatState(NovoEstado),
            %io:format("Estado String~p~n",[EstadoM]),
            [ H ! {line,formatState(NovoEstado)} || H <- Pids],
            JogadoresPontos = [{User,P} || {{_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,P}, {User, _}} <- ListaJogadores ],
            %io:format("JogadoresPontos~p~n",[JogadoresPontos]),
            %io:format("Pontos melhores~p~n",[atualizaMelhoresPontos(MelhoresPontuacoes,JogadoresPontos)]), 
            gameManager(NovoEstado,atualizaMelhoresPontos(MelhoresPontuacoes,JogadoresPontos));

        {leave, From} ->
            io:format("Alguem enviou leave~n"),
            {ListaJogadores, ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra} = Estado,
            if
                length(ListaJogadores) == 1->
                    [H|T] = ListaJogadores,
                    {_, {_, Pid1}} = H,
                    if
                        Pid1 == From ->
                            gameManager(removeJogador(Estado,H),MelhoresPontuacoes);
                        true ->
                            gameManager(Estado,MelhoresPontuacoes)
                    end;
                length(ListaJogadores) == 2 ->
                    [H1,H2 | T] = ListaJogadores,
                    {_, {_, Pid1}} = H1,
                    {_, {_, Pid2}} = H2,
                    if
                        Pid1 == From ->
                            gameManager(removeJogador(Estado,H1),MelhoresPontuacoes);
                        Pid2 == From ->
                            gameManager(removeJogador(Estado,H2),MelhoresPontuacoes);
                        true ->
                            gameManager(Estado,MelhoresPontuacoes)
                    end;
                length(ListaJogadores) == 3 ->
                    [H1, H2, H3 |T] = ListaJogadores,
                    {_, {_, Pid1}} = H1,
                    {_, {_, Pid2}} = H2,
                    {_, {_, Pid3}} = H3,
                    if
                        Pid1 == From ->
                            gameManager(removeJogador(Estado,H1),MelhoresPontuacoes);
                        Pid2 == From ->
                            gameManager(removeJogador(Estado,H2),MelhoresPontuacoes);
                        Pid3 == From ->
                            gameManager(removeJogador(Estado,H3),MelhoresPontuacoes);
                        true ->
                            gameManager(Estado,MelhoresPontuacoes)
                    end;
                true ->
                    gameManager(Estado,MelhoresPontuacoes)
            end;


        {addReds, _} ->
            %io:format("Entrei no addReds~n"),
            {ListaJogadores, ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra} = Estado,
            if 
                length(ListaReds)<3 ->
                    %io:format("Vou Adicionar uma criatura vermelha~n"),
                    Creature = novaCriatura(r,ListaObstaculos),
                    gameManager({ListaJogadores, ListaVerdes, ListaReds ++ [Creature],ListaObstaculos, TamanhoEcra},MelhoresPontuacoes);
                    
                true ->
                    gameManager({ListaJogadores, ListaVerdes, ListaReds,ListaObstaculos, TamanhoEcra},MelhoresPontuacoes)
                
            end;

        {addVerde, _} ->
            %io:format("Entrei no addVerdes~n"),
            {ListaJogadores, ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra} = Estado,
            if 
                length(ListaVerdes)<3 ->
                    %io:format("Vou Adicionar uma criatura Verde~n"),
                    Creature = novaCriatura(v,ListaObstaculos),
                    gameManager({ListaJogadores, ListaVerdes ++ [Creature], ListaReds ,ListaObstaculos, TamanhoEcra},MelhoresPontuacoes);
                    
                true ->
                    gameManager({ListaJogadores, ListaVerdes, ListaReds ,ListaObstaculos, TamanhoEcra},MelhoresPontuacoes)
            end

    end.

update(Estado) ->
    {ListaJogadores, ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra} = Estado,
    %COLISOES

    ListaColisaoVerde = [verificaColisoesCriaturaLista(Jogador,ListaVerdes) || {Jogador,{_,_}} <- ListaJogadores],
    ListaColisaoVermelho = [verificaColisoesCriaturaLista(Jogador,ListaReds) || {Jogador,{_,_}} <- ListaJogadores],

    
    LV=atualizaListaCriaturas(ListaVerdes--lists:append(ListaColisaoVerde),ListaObstaculos),
    LR=atualizaListaCriaturas(ListaReds--lists:append(ListaColisaoVermelho),ListaObstaculos),

    
    LJ=atualizaJogadores(ListaJogadores,ListaColisaoVerde ,ListaColisaoVermelho, ListaObstaculos),
    %io:fwrite("Lista Nao Filtrada: ~p ~n", [LJ]),
    {Vencedores,Derrotados} = filtrar(LJ,{[],[]}),
    [P ! {line,"Perdeu\n"} || {_,P} <- Derrotados],
    [statePid ! {leave,U,P} || {U,P} <- Derrotados],
    %io:fwrite("Vencedores: ~p ~n", [Vencedores]),
    %io:fwrite("Derrotados: ~p ~n", [Derrotados]),
    
    {Vencedores, LV, LR, ListaObstaculos, TamanhoEcra}.





filtrar([],X) -> X;
filtrar([{{true,Posicao, Direcao, Velocidade, EnergiaAtual,Raio, AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao},{U,P}}|T],{V,D}) -> 
    filtrar(T,{V++[{{true,Posicao, Direcao, Velocidade, EnergiaAtual,Raio, AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao},{U,P}}],D});
filtrar([{_,{U,P}}|T],{V,D}) -> filtrar(T,{V,D++[{U,P}]}).





descobreJogador([],Pid,KeyPressed) -> [];
descobreJogador([{J, {U,Pid}} | T],Pid,KeyPressed) -> updateTecla({J, {U,Pid}},KeyPressed)++T;
descobreJogador([H | T],Pid,KeyPressed) -> [H]++descobreJogador(T,Pid,KeyPressed).

updateTeclas(Estado,KeyPressed,Pid) ->
    {ListaJogadores, ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra} = Estado,
    ListaJogadorAtual = descobreJogador(ListaJogadores,Pid,KeyPressed),
    {ListaJogadorAtual, ListaVerdes, ListaReds, ListaObstaculos, TamanhoEcra}.

updateTecla (JogadorAtual,KeyPressed) ->
    {J,{U,Pid}} = JogadorAtual,
    if
        KeyPressed == "w" -> NovoJogador = acelerarFrente(J);
        KeyPressed == "a" -> NovoJogador = viraDireita(J);
        KeyPressed == "d" -> NovoJogador = viraEsquerda(J);
        true -> NovoJogador = J
    end,
    [{NovoJogador,{U,Pid}}].