-module(criaturas).
-export([novaCriatura/2,atualizaListaCriaturas/2,verificaColisoesCriaturaLista/2,atualizaCriatura/2]).
-import(jogadores, [jogadorRaioMin/1]).
-import(auxiliar, [multiplicaVector/2, normalizaVector/1, meioVectores/2, adicionaPares/2, distancia/2,posiciona/1]).
-import (math, [sqrt/1, pow/2, cos/1, sin/1, pi/0]).

novaCriatura(Tipo,ListaAzul) ->
    Direcao = float(rand:uniform(360)),
    Tamanho = 25,
    Velocidade = 5.0,
    Posicao = posiciona(25),
    {Posicao, Direcao, Tamanho, Tipo, Velocidade}.

atualizaCriatura(Criatura, ListaAzul)->
    {Posicao, Direcao, Tamanho, Tipo, Velocidade}=Criatura,
    Radians = (Direcao * pi()) / 180,
    %VecDirecao = normalizaVector(multiplicaVector({cos(Radians), sin(Radians)}, Velocidade)),
    %NPosicao= adicionaPares(Posicao, VecDirecao),
    {NovoX, NovoY} = Posicao,
    %if 
    %    NovoXX > 1300 - Tamanho/2 ->
    %        NovoX = NovoXX - 10.0;
    %    NovoXX < 0 + Tamanho/2 ->
    %        NovoX = NovoXX + 10.0;
    %    true ->
    %        NovoX = NovoXX
    %end,
    %if 
    %    NovoYY > 700 - Tamanho/2 ->
    %        NovoY = NovoYY - 10.0;
    %    NovoYY < 0 + Tamanho/2->
    %        NovoY = NovoYY + 10.0;         
    %    true ->
    %        NovoY = NovoYY
    %end,
    %if 
    %    ((NovoYY) > 700 - Tamanho/2) or ((NovoYY) < 0 + Tamanho/2) or ((NovoXX) < 0 + Tamanho/2) or ((NovoXX) > 1300 - Tamanho/2) ->
    %        VecXA = Direcao-180.0;
    %    true -> 
    %        VecXA = Direcao + float(rand:uniform(1))*0.3
    %end,
    %if 
    %    VecXA > 360 ->
    %        VecX = VecXA - 360.0;
    %    VecXA < 0 ->
    %        VecX = VecXA + 360.0;
    %    true ->
    %        VecX = VecXA 
    %end,

    Nposs = {NovoX, NovoY},
    verificaColisaoObstaculos({Nposs, Direcao, Tamanho, Tipo, Velocidade},ListaAzul).

atualizaListaCriaturas(Criaturas, ListaAzul) ->
    [atualizaCriatura(Criatura, ListaAzul) || Criatura <- Criaturas].



verificaColisaoObstaculos(Criatura, ListaAzul) ->
    {PosicaoA, DirecaoX, Tamanho, Tipo, Velocidade}=Criatura,
    %[Obs1 | T] = ListaAzul,
    %[Obs2 | Ta1] = T,
    %[Obs3 | T4] = Ta1,
    %T1 = verificaColisaoObstaculo(Criatura,Obs1),
    %T2 = verificaColisaoObstaculo(Criatura,Obs2),
    %T3 = verificaColisaoObstaculo(Criatura,Obs3),
    %if
    %    T1 or T2 or T3 ->
    %        Direcao = DirecaoX-180,
    %        Radians = (Direcao * pi()) / 180,
    %        VecDirecao = multiplicaVector({cos(Radians), sin(Radians)}, 20),
    %        NPosicao= adicionaPares(PosicaoA, VecDirecao);
    %    true ->
    %        Direcao = DirecaoX,
    %        NPosicao=PosicaoA
    %end,

    Direcao = DirecaoX,
    NPosicao=PosicaoA,
    {NPosicao, Direcao, Tamanho, Tipo, Velocidade}.



verificaColisaoObstaculo( Criatura, Obstaculo ) ->
    %{ObsX, ObsY, Tamanho1} = Obstaculo,
    %{Posicao, Direcao, Tamanho, Tipo, Velocidade}=Criatura,
    %D=distancia(Posicao, {ObsX,ObsY}),
    %if
    %    D < (Tamanho1/2 + Tamanho/2) -> true;
    %    true -> false
    %end.

    false.


    
verificaColisoesCriaturaLista( Jogador, Criaturas ) ->
    if
        Criaturas == [] -> [];
        true -> 
            [Criatura | Cauda ] = Criaturas,
            verificaColisaoCriatura(Jogador, Criatura) ++ verificaColisoesCriaturaLista(Jogador, Cauda)
    end.

verificaColisaoCriatura( Jogador, Criatura ) ->
    % testar se o jogador tem raio minimo se sim pode dar return a true se colidiu
    {Posicao, Direcao, Tamanho, Tipo, Velocidade} = Criatura,
    {_,JPosicao, _, _, _,JRaio, _, _, _, _, _, _,_}=Jogador,
    {CPosicao, _, CTamanho, _, _}=Criatura,
    D=distancia(JPosicao, CPosicao),
    if
        D < (JRaio/2 + CTamanho/2) -> [Criatura];
        true -> []
    end.