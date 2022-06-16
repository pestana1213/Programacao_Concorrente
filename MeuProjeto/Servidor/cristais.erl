-module(cristais).
-export([novoCristal/2,atualizaListaCristais/2,verificaColisoesCristalLista/2,atualizaCristal/2]).
-import(jogadores, [jogadorRaioMin/1]).
-import(auxiliar, [multiplicaVector/2, normalizaVector/1, meioVectores/2, adicionaPares/2, distancia/2,posiciona/1]).
-import (math, [sqrt/1, pow/2, cos/1, sin/1, pi/0]).

 %Classe dos cristais 

novoCristal(Tipo,ListaAzul) ->
    Direcao = float(rand:uniform(360)),
    Tamanho = 25,
    Velocidade = 0.0,
    Posicao = posiciona(25),
    {Posicao, Direcao, Tamanho, Tipo, Velocidade}.

atualizaCristal(Cristal, ListaAzul)->
    {Posicao, Direcao, Tamanho, Tipo, Velocidade}=Cristal,
    Radians = (Direcao * pi()) / 180,
    {NovoX, NovoY} = Posicao,

    Nposs = {NovoX, NovoY},
    verificaColisaoAzuis({Nposs, Direcao, Tamanho, Tipo, Velocidade},ListaAzul).

atualizaListaCristais(Cristais, ListaAzul) ->
    [atualizaCristal(Cristal, ListaAzul) || Cristal <- Cristais].


verificaColisaoAzuis(Cristal, ListaAzul) ->
    {PosicaoA, DirecaoX, Tamanho, Tipo, Velocidade}=Cristal,

    Direcao = DirecaoX,
    NPosicao=PosicaoA,
    {NPosicao, Direcao, Tamanho, Tipo, Velocidade}.

    
verificaColisoesCristalLista( Jogador, Cristais ) ->
    if
        Cristais == [] -> [];
        true -> 
            [Cristal | Cauda ] = Cristais,
            verificaColisaoCristal(Jogador, Cristal) ++ verificaColisoesCristalLista(Jogador, Cauda)
    end.

% testar se o jogador tem raio minimo se sim pode dar return a true se colidiu

verificaColisaoCristal( Jogador, Cristal ) ->
    {Posicao, Direcao, Tamanho, Tipo, Velocidade} = Cristal,
    {_,JPosicao, _, _, _,JRaio, _, _, _, _, _, _,_}=Jogador,
    {CPosicao, _, CTamanho, _, _}=Cristal,
    D=distancia(JPosicao, CPosicao),
    if
        D < (JRaio/2 + CTamanho/2) -> [Cristal];
        true -> []
    end.