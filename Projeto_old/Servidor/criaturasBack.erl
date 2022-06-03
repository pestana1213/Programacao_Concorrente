-module(criaturas).
-export([novaCriatura/1, atualizaCriatura/4, verificaColisoesVermelhas/3, verificaColisoesLista/2, verificaColisao/2, atualizaListaCriaturas/4]).
-import(auxliar, [multiplicaVector/2, normalizaVector/1, meioVectores/2, adicionaPares/2, distancia/2, subtraiVectores/2]).

novaCriatura(Tipo) ->
    Direcao = {0.0,0.0},
    DirecaoApontada = {1.0,1.0},
    Tamanho = 50.0,
    Velocidade = 1.0,
    Posicao = {float(rand:uniform(1200)),float(rand:uniform(800))},
    {Posicao, Direcao, DirecaoApontada, Tamanho, Tipo, Velocidade}.


atualizaCriatura(Creatura, P1, P2, Interpolacao) ->
    {Posicao, Direcao, DirecaoApontada, Tamanho, Tipo, Velocidade} = Creatura,
    {PosicaoP1, _, _, _, _, _, _, _, _, _, _, _} = P1,
    {PosicaoP2, _, _, _, _, _, _, _, _, _, _, _} = P2,

    DistanciaP1 = distancia(Posicao, PosicaoP1),
    DistanciaP2 = distancia(Posicao, PosicaoP2),

    if
        DistanciaP1 < DistanciaP2 -> NovaDirecaoApontar = subtraiVectores(Position, PositionP1);
        true -> NovaDirecaoApontar = subtraiVectores(Position, PositionP1)
    end,

    NovaDirecao = multiplicaVector(normalizaVector(meioVectores(Direcao, NovaDirecaoApontar)), Velocidade * Interpolacao),
    NovaPosicao = adicionaPares(Posicao, NovaDirecao),

    {NovaPosicao, NovaDirecao, NovaDirecaoApontar, Tamanho, Tipo, Velocidade}.


verificaColisoesVermelhas(ListaJogadores, CriaturasVermelhas ) ->
    
    if
        Length (ListaJogadores) =:= 3 -> 
            [Jogador1 | ListJ] =  ListaJogadores,
            [Jogador2 | LJ] =ListJ,
            [Jogador3 | T_1 ] = LJ,
            {P1, ID_P1} = Jogador1,
            {P2, ID_P2} = Jogador2,
            {P3, ID_P3} = Jogador3,
            ColisoesP1 = verificaColisoesLista(P1, CriaturasVermelhas),
            ColisoesP2 = verificaColisoesLista(P2, CriaturasVermelhas),
            ColisoesP3 = verificaColisoesLista(P3, CriaturasVermelhas),    
            IDS_Colisao = [],
            
            if
                ColisoesP1 == true -> IDS_Colisao = IDS_Colisao ++ ID_P1;
                ColisoesP2 == true -> IDS_Colisao = IDS_Colisao ++ ID_P2;
                ColisoesP3 == true -> IDS_Colisao = IDS_Colisao ++ ID_P3
            end,       
            if
                ColisoesP1 or ColisoesP2 or ColisoesP3 -> {true, IDS_Colisao};
                true -> {false, none}
            end;
        Length (ListaJogadores) =:= 2 -> 
            [Jogador1 | Jogador2 ] =  ListaJogadores,
            {P1, ID_P1} = Jogador1,
            {P2, ID_P2} = Jogador2,
            ColisoesP1 = verificaColisoesLista(P1, CriaturasVermelhas),
            ColisoesP2 = verificaColisoesLista(P2, CriaturasVermelhas),
            IDS_Colisao = [],

            if
                ColisoesP1 == true -> IDS_Colisao = IDS_Colisao ++ ID_P1;
                ColisoesP2 == true -> IDS_Colisao = IDS_Colisao ++ ID_P2
            end,        
            if
                ColisoesP1 or ColisoesP2 -> {true, IDS_Colisao};
                true -> {false, none}
            end;
        Length (ListaJogadores) =:= 1 -> 
            [Jogador1] =  ListaJogadores,
            {P1, ID_P1} = Jogador1,
            ColisoesP1 = verificaColisoesLista(P1, CriaturasVermelhas),
            if
                ColisoesP1 -> {true, [ID_P1]};
                true -> {false, none}
            end
    end.


verificaColisoesLista( Jogador, Criaturas ) ->
    if
        Criaturas == [] -> false;
        true -> 
            [Criatura | Cauda ] = Criaturas,
            verificaColisao(Jogador, Criatura) or verificaColisoesLista(Jogador, Cauda)
    end.


verificaColisao( Jogador, Criatura ) ->
    % testar se o jogador tem raio minimo se sim pode dar return a true se colidiu
    {P1Pos, _, _, _, _, _, _, _, _, _, _, P1Size} = Player,
    {CriaPos, _, _, CriaSize, _, _} = Creature,
    if
        distancia(P1Pos, P1Pos) < (P1Size/2 + CriaSize/2) -> true;
        true -> false
    end.

atualizaListaCriaturas(Criaturas, P1, P2, Interpolacao) ->
    [atualizaCriatura(Criatura, P1, P2, Interpolacao) || Criatura <- Criaturas].