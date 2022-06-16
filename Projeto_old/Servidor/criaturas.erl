-module(Cristais).
-export([novoCristal/2,atualizaListaCristais/2,verificaColisoesCristalLista/2,atualizaCristal/2]).
-import(jogadores, [jogadorRaioMin/1]).
-import(auxiliar, [multiplicaVector/2, normalizaVector/1, meioVectores/2, adicionaPares/2, distancia/2,posiciona/2]).
-import (math, [sqrt/1, pow/2, cos/1, sin/1, pi/0]).

novoCristal(Tipo,ListaObstaculos) ->
    Direcao = float(rand:uniform(360)),
    Tamanho = 50,
    Velocidade = 5.0,
    Posicao = posiciona(50,ListaObstaculos),
    {Posicao, Direcao, Tamanho, Tipo, Velocidade}.

atualizaCristal(Cristal, ListaObstaculos)->
    {Posicao, Direcao, Tamanho, Tipo, Velocidade}=Cristal,
    Radians = (Direcao * pi()) / 180,
    VecDirecao = normalizaVector(multiplicaVector({cos(Radians), sin(Radians)}, Velocidade)),
    NPosicao= adicionaPares(Posicao, VecDirecao),
    {NovoXX, NovoYY} = NPosicao,
    if 
        NovoXX > 1300 - Tamanho/2 ->
            NovoX = NovoXX - 10.0;
        NovoXX < 0 + Tamanho/2 ->
            NovoX = NovoXX + 10.0;
        true ->
            NovoX = NovoXX
    end,
    if 
        NovoYY > 700 - Tamanho/2 ->
            NovoY = NovoYY - 10.0;
        NovoYY < 0 + Tamanho/2->
            NovoY = NovoYY + 10.0;         
        true ->
            NovoY = NovoYY
    end,
    if 
        ((NovoYY) > 700 - Tamanho/2) or ((NovoYY) < 0 + Tamanho/2) or ((NovoXX) < 0 + Tamanho/2) or ((NovoXX) > 1300 - Tamanho/2) ->
            VecXA = Direcao-180.0;
        true -> 
            VecXA = Direcao + float(rand:uniform(1))*0.3
    end,
    if 
        VecXA > 360 ->
            VecX = VecXA - 360.0;
        VecXA < 0 ->
            VecX = VecXA + 360.0;
        true ->
            VecX = VecXA 
    end,

    Nposs = {NovoX, NovoY},
    verificaColisaoAzuis({Nposs, VecX, Tamanho, Tipo, Velocidade},ListaObstaculos).

atualizaListaCristais(Cristais, ListaObstaculos) ->
    [atualizaCristal(Cristal, ListaObstaculos) || Cristal <- Cristais].



verificaColisaoAzuis(Cristal, ListaObstaculos) ->
    {PosicaoA, DirecaoX, Tamanho, Tipo, Velocidade}=Cristal,
    [Obs1 | T] = ListaObstaculos,
    [Obs2 | Ta1] = T,
    [Obs3 | T4] = Ta1,
    T1 = verificaColisaoObstaculo(Cristal,Obs1),
    T2 = verificaColisaoObstaculo(Cristal,Obs2),
    T3 = verificaColisaoObstaculo(Cristal,Obs3),
    if
        T1 or T2 or T3 ->
            Direcao = DirecaoX-180,
            Radians = (Direcao * pi()) / 180,
            VecDirecao = multiplicaVector({cos(Radians), sin(Radians)}, 20),
            NPosicao= adicionaPares(PosicaoA, VecDirecao);
        true ->
            Direcao = DirecaoX,
            NPosicao=PosicaoA
    end,
    {NPosicao, Direcao, Tamanho, Tipo, Velocidade}.



verificaColisaoObstaculo( Cristal, Obstaculo ) ->
    {ObsX, ObsY, Tamanho1} = Obstaculo,
    {Posicao, Direcao, Tamanho, Tipo, Velocidade}=Cristal,
    D=distancia(Posicao, {ObsX,ObsY}),
    if
        D < (Tamanho1/2 + Tamanho/2) -> true;
        true -> false
    end.


    
verificaColisoesCristalLista( Jogador, Cristais ) ->
    if
        Cristais == [] -> [];
        true -> 
            [Cristal | Cauda ] = Cristais,
            verificaColisaoCristal(Jogador, Cristal) ++ verificaColisoesCristalLista(Jogador, Cauda)
    end.

verificaColisaoCristal( Jogador, Cristal ) ->
    % testar se o jogador tem raio minimo se sim pode dar return a true se colidiu
    {_,JPosicao, _, _, _,JRaio, _, _, _, _, _, _, _,_, _,_}=Jogador,
    {CPosicao, _, CTamanho, _, _}=Cristal,
    D=distancia(JPosicao, CPosicao),
    if
        D < (JRaio/2 + CTamanho/2) -> [Cristal];
        true -> []
    end.