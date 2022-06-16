-module (estado).
-export ([start_state/0,atualizaMelhoresPontos/2, converterInt/1]).
-import (cristais, [novoCristal/2,atualizaListaCristais/2,verificaColisoesCristalLista/2]).
-import (jogadores, [novoJogador/1,acelerarFrente/1, atualizaJogadores/4,calculaVelocidadeMax/1,vaiParaCoordenadas/3 ]).  
-import (timer, [send_after/3]).
-import (auxiliar, [multiplicaVector/2, geraObstaculo/2, normalizaVector/1]).
-import (conversores, [formatState/1,formatarPontuacoes/1, formataTecla/1]).
-import (math, [sqrt/1, pow/2, acos/1, cos/1, sin/1, pi/0]).



start_state() ->
    io:format(" Novo Jogo~n"),
    register(game,spawn( fun() -> gameManager (novoEstado(),#{}) end )),
    Timer = spawn( fun() -> refresh(game) end),
    SpawnReds = spawn ( fun() -> adicionarVerdes(game) end),    
    SpawnVerdes = spawn ( fun() -> adicionarReds(game) end),   
    SpawnAzuis= spawn ( fun() -> adicionarBlues(game) end), 
    Salas = criaSalas(),
    %io:format("Salas ~n ~p", [Salas]),
    register(statePid,spawn( fun() -> lounge(Salas)  end))
    .


refresh (Pid) -> receive after 10 -> Pid ! {refresh, self()}, refresh(Pid) end.
adicionarReds (Pid) -> receive after 500 -> Pid ! {addReds, self()}, adicionarReds(Pid) end.
adicionarVerdes (Pid) -> receive after 500 -> Pid ! {addVerde, self()}, adicionarVerdes(Pid) end.
adicionarBlues (Pid) -> receive after 500 -> Pid ! {addBlue, self()}, adicionarBlues(Pid) end.

novaSala() -> 

    [{spawn(fun() -> estado([],[]) end),[]}].

criaSalas() -> 
    novaSala() ++ novaSala() ++ novaSala() ++ novaSala(). 

lounge(Salas) -> 

    receive 
        {ready,Username, UserProcess} -> 

            Sala = verificaSala(Salas), 
            {Pid,ListaJogadores} = Sala,
            NovasSalas = remove(Sala,Salas),
            Pid ! {ready,Username,UserProcess},

            NovoJogadores = ListaJogadores ++ [{Username,UserProcess}],
            NovoSala = {Pid,NovoJogadores},

            lounge([NovoSala | NovasSalas]);

        {atualizaPontos, Username, UserProcess} ->

            ondEstaJogador(Salas,UserProcess) ! {atualizaPontos,Username,UserProcess},
            lounge(Salas);
        {leave, Username, UserProcess}  ->                                            
            ondEstaJogador(Salas,UserProcess) ! {leave,Username,UserProcess},
            lounge(Salas)
    end. 

remove(X, L) ->
    [Y || Y <- L, Y =/= X].


ondEstaJogador([],UserProcess) -> []; 

ondEstaJogador([{Pid,[X|Y]}|T],UserProcess) -> 
    {User,Process} = X, 

    if Process == UserProcess ->
        Pid;
    true -> 
        if length(Y) == 0 -> 
            ondEstaJogador([T],UserProcess);
        true-> 
            ondEstaJogador([{Pid,Y}|T],UserProcess)
        end
    end.


verificaSala([H|T]) -> 
    {Pid,ListaJogadores} = H, 

    if length(ListaJogadores) < 8 -> 
        H;
    true -> 
        verificaSala(T)
    end.


estado(Atuais_Jogadores, Espera_Jogadores) ->
    io:format("Entrei no estado ~n"),

    receive
        {ready, Username, UserProcess} -> 
            io:format("len ~p ~n", [length (Espera_Jogadores)]),   
            if
                length (Espera_Jogadores) < 1 ->  
                    io:format("Recebi ready de ~p mas ele vai esperar ~n", [Username]),                                                     % Recebemos ready de um user mas o jogo está cheio, vai esperar
                    estado(Atuais_Jogadores, Espera_Jogadores ++ [{Username, UserProcess}]);      %Adicionamos lo entao aos jogadores em espera
                true -> 
                    io:format("Recebi ready do User ~p e vou adicionar-lo ao jogo ~n",[Username]),
                    Espera_JogadoresAux = Espera_Jogadores ++ [{Username, UserProcess}],
                    [JogadorPid ! {comeca, game} || {_,JogadorPid} <- Espera_JogadoresAux],
                    [game ! {geraJogador,{Username,UserProcess}} || {Username,UserProcess} <- Espera_JogadoresAux],

                    estado(Espera_JogadoresAux, [])
            end;

        
        {atualizaPontos, Username, UserProcess} ->
            io:format("Recebi atualizaPontos de ~p ~n", [Username]),
            game ! {atualizaPontos,Username},
            estado(Atuais_Jogadores, Espera_Jogadores);

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
    State = {[], [], [], [], {1300,700}},
    io:fwrite("Estado novo Gerado: ~p ~n", [State]),
    State.

adicionaJogador(Estado,Jogador) ->
    {ListaJogadores, ListaVerdes, ListaReds, ListaAzul, TamanhoEcra} = Estado,
    State = { ListaJogadores ++ [{novoJogador(ListaAzul), Jogador}], ListaVerdes, ListaReds, ListaAzul, TamanhoEcra},
    io:fwrite("Estado: ~p ~n", [State]),
    State.

removeJogador(Estado,Jogador) ->
    {ListaJogadores, ListaVerdes, ListaReds, ListaAzul, TamanhoEcra} = Estado,
    State = { ListaJogadores -- [Jogador], ListaVerdes, ListaReds, ListaAzul, TamanhoEcra},
    io:fwrite("Estado com jogador removido: ~p ~n", [State]),
    State.




atualizaMelhoresPontos(Map,[]) -> Map;
atualizaMelhoresPontos(Map,[H|T]) -> 
    {U,P} = H,
    case maps:find(U,Map) of
        error ->
            atualizaMelhoresPontos(maps:put(U, P, Map),T);
        {_,PontosA} when PontosA < P ->
            atualizaMelhoresPontos(maps:put(U, PontosA+1, Map),T);
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
            %io:format("ENVIEI ESTES DADOS~p~n",[Data]),
            From ! {line,Data},
            %io:format("Pontuaçoes ~p~n",[formatarPontuacoes(maps:to_list(MelhoresPontuacoes))]), 
            gameManager(Estado,MelhoresPontuacoes);


        {Coordenadas, Data, From} ->
            

            Coordenadas1 = formataTecla(Data),
            
            if 
                Coordenadas1 =:= "LEFT" ->
                    NovoEstado = updateBoosts(Estado,From);
                true ->
                    Coordenadas2 = string:tokens(Coordenadas1, " "),
                    NovoEstado = updateTeclas(Estado,Coordenadas2,From) 
            
            end,
            %io:format("Y ~p~n", [Y]),
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
            %JogadoresPontos = [{User,P} || {{_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,P}, {User, _}} <- ListaJogadores ],
            %io:format("JogadoresPontos~p~n",[JogadoresPontos]),
            %io:format("Pontos melhores~p~n",[atualizaMelhoresPontos(MelhoresPontuacoes,JogadoresPontos)]), 
            gameManager(NovoEstado,MelhoresPontuacoes);

        {atualizaPontos, From} ->
            io:format("Vou atualizar pontos~n"),


            MelhoresPontuacoesAux = atualizaMelhoresPontos(MelhoresPontuacoes, [{From,1}]),


            gameManager(Estado,MelhoresPontuacoesAux);

        {leave, From} ->
            io:format("Alguem enviou leave~n"),
            {ListaJogadores, ListaVerdes, ListaReds, ListaAzul, TamanhoEcra} = Estado,
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
            {ListaJogadores, ListaVerdes, ListaReds, ListaAzul, TamanhoEcra} = Estado,
            if 
                length(ListaReds)<3 ->
                    %io:format("Vou Adicionar uma Cristal vermelha~n"),
                    Cristal = novoCristal(r,ListaAzul),
                    gameManager({ListaJogadores, ListaVerdes, ListaReds ++ [Cristal],ListaAzul, TamanhoEcra},MelhoresPontuacoes);
                    
                true ->
                    gameManager({ListaJogadores, ListaVerdes, ListaReds,ListaAzul, TamanhoEcra},MelhoresPontuacoes)
                
            end;

        {addBlue, _} ->
            %io:format("Entrei no addReds~n"),
            {ListaJogadores, ListaVerdes, ListaReds, ListaBlues, TamanhoEcra} = Estado,
            if 
                length(ListaBlues)<3 ->
                    %io:format("Vou Adicionar uma Cristal vermelha~n"),
                    Cristal = novoCristal(r,ListaBlues),
                    gameManager({ListaJogadores, ListaVerdes, ListaReds ,ListaBlues ++ [Cristal], TamanhoEcra},MelhoresPontuacoes);
                    
                true ->
                    gameManager({ListaJogadores, ListaVerdes, ListaReds,ListaBlues, TamanhoEcra},MelhoresPontuacoes)
                
            end;
            
        {addVerde, _} ->
            %io:format("Entrei no addVerdes~n"),
            {ListaJogadores, ListaVerdes, ListaReds, ListaAzul, TamanhoEcra} = Estado,
            if 
                length(ListaVerdes)<3 ->
                    %io:format("Vou Adicionar uma Cristal Verde~n"),
                    Cristal = novoCristal(v,ListaAzul),
                    gameManager({ListaJogadores, ListaVerdes ++ [Cristal], ListaReds ,ListaAzul, TamanhoEcra},MelhoresPontuacoes);
                    
                true ->
                    gameManager({ListaJogadores, ListaVerdes, ListaReds ,ListaAzul, TamanhoEcra},MelhoresPontuacoes)
            end

    end.

update(Estado) ->
    {ListaJogadores, ListaVerdes, ListaReds, ListaBlues, TamanhoEcra} = Estado,
    %COLISOES

    ListaColisaoVerde = [verificaColisoesCristalLista(Jogador,ListaVerdes) || {Jogador,{_,_}} <- ListaJogadores],
    ListaColisaoVermelho = [verificaColisoesCristalLista(Jogador,ListaReds) || {Jogador,{_,_}} <- ListaJogadores],
    ListaColisaoAzul = [verificaColisoesCristalLista(Jogador,ListaBlues) || {Jogador,{_,_}} <- ListaJogadores],
    
    LV=atualizaListaCristais(ListaVerdes--lists:append(ListaColisaoVerde),[]),
    LR=atualizaListaCristais(ListaReds--lists:append(ListaColisaoVermelho),[]),
    LB=atualizaListaCristais(ListaBlues--lists:append(ListaColisaoAzul),[]),
    
    LJ=atualizaJogadores(ListaJogadores,ListaColisaoVerde ,ListaColisaoVermelho, ListaColisaoAzul),
    %io:fwrite("Lista Nao Filtrada: ~p ~n", [LJ]),
    {Vencedores,Derrotados} = filtrar(LJ,{[],[]}),
    [P ! {line,"Perdeu\n"} || {_,P} <- Derrotados],
    [statePid ! {leave,U,P} || {U,P} <- Derrotados],

    

    if 
        length (Vencedores) =:= 1 ->
            io:fwrite("Houve vencedores~n"),
            [P ! {line,"Venceu\n"} || {_,{_,P}} <- Vencedores],
            [statePid ! {leave,U,P} || {_,{U,P}} <- Vencedores],
            [statePid ! {atualizaPontos,U,P} || {_,{U,P}} <- Vencedores],
            NovaLista = [];
        true -> 
            NovaLista = Vencedores
    end,

    {NovaLista, LV, LR, LB, TamanhoEcra}.





filtrar([],X) -> X;
filtrar([{{true,Posicao, Direcao, Velocidade, CorAtual,Raio, AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao},{U,P}}|T],{V,D}) -> 
    filtrar(T,{V++[{{true,Posicao, Direcao, Velocidade, CorAtual,Raio, AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao},{U,P}}],D});
filtrar([{_,{U,P}}|T],{V,D}) -> filtrar(T,{V,D++[{U,P}]}).





descobreJogador([],Pid,Coordenadas) -> [];
descobreJogador([{J, {U,Pid}} | T],Pid,Coordenadas) -> updateTecla({J, {U,Pid}},Coordenadas)++T;
descobreJogador([H | T],Pid,Coordenadas) -> [H]++descobreJogador(T,Pid,Coordenadas).

updateTeclas(Estado,Coordenadas,Pid) ->
    {ListaJogadores, ListaVerdes, ListaReds, ListaAzul, TamanhoEcra} = Estado,
    ListaJogadorAtual = descobreJogador(ListaJogadores,Pid,Coordenadas),
    {ListaJogadorAtual, ListaVerdes, ListaReds, ListaAzul, TamanhoEcra}.


updateTecla (JogadorAtual,Coordenadas) ->
    {J,{U,Pid}} = JogadorAtual,
    [XAUX,YAUX] = Coordenadas,

    {E,Posicao, Direcao, Velocidade, Cor,Raio,  AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin,Agilidade,Pontuacao} = J,

    {X,Y} = Posicao,
    {X2,Y2} = normalizaVector({converterInt(XAUX)-X,converterInt(YAUX)-Y}),


    Radians = (Direcao * pi()) / 180,
    VecDirecao = normalizaVector({cos(Radians), sin(Radians)}),
    {X1,Y1} = VecDirecao,
    
    if 
        ((X1 == 0) and (Y1 == 0)) -> Cos = 0;
        true -> Cos = (X1*X2 + Y1*Y2) / (sqrt(X1*X1 + Y1*Y1) * sqrt(X2*X2 + Y2*Y2))
    end,

    Angulo = acos(Cos) * 180 / pi(),
    
    if 
        Y2 > 0 ->  Angulo2 = 360 - Angulo;
        true -> Angulo2 = Angulo
    end,

    NovoJogador = vaiParaCoordenadas(J,converterInt(XAUX),converterInt(YAUX)),


    
    [{NovoJogador,{U,Pid}}].

    
    
updateBoosts(Estado,Pid) ->
    {ListaJogadores, ListaVerdes, ListaReds, ListaAzul, TamanhoEcra} = Estado,
    ListaJogadorAtual = descobreJogadorBoost(ListaJogadores,Pid),
    {ListaJogadorAtual, ListaVerdes, ListaReds, ListaAzul, TamanhoEcra}.


descobreJogadorBoost([],Pid) -> [];
descobreJogadorBoost([{J, {U,Pid}} | T],Pid) -> updateBoost({J, {U,Pid}})++T;
descobreJogadorBoost([H | T],Pid) -> [H]++descobreJogadorBoost(T,Pid).


updateBoost (JogadorAtual) ->
    {J,{U,Pid}} = JogadorAtual,

    {E,Posicao, Direcao, Velocidade, Cor,Raio,  AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin,Boost,Pontuacao} = J,

    if 
        Raio >= (RaioMin+70) ->
            NovoTamanho = Raio - 70,
            NBoost = Boost + 0.005;
        true ->
            NovoTamanho = Raio,
            NBoost = Boost
    end,   

    NovoJogador = {E,Posicao, Direcao, Velocidade, Cor,NovoTamanho,  AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin,NBoost,Pontuacao},
 
    [{NovoJogador,{U,Pid}}].


converterInt (Numero) ->
    %convert to int if its not int
    if
        integer(Numero) -> Numero;
        true -> list_to_integer(Numero)
    end.

