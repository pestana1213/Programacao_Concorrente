-module(auxiliar).
-export([multiplicaVector/2, normalizaVector/1, adicionaPares/2, distancia/2,posiciona/1]).
-import (math, [sqrt/1, pow/2]).


%dar uma posicacao fora de obstaculos
posiciona(Raio)->
    Posicao= {float(rand:uniform(1200))+50,float(rand:uniform(600))+50},
    Posicao.

% Contas com vetores

normalizaVector(Vec) ->
    {X, Y} = Vec,
    D = sqrt( pow(X,2) + pow(Y,2) ),
    if 
        D == 0 -> {0, 0};
        true -> { X/D, Y/D }
    end.
    

multiplicaVector(Vec, Multiplica) ->
    {X,Y} = Vec,
    { X * Multiplica, Y * Multiplica}.


% Contas com posições

adicionaPares(P1, P2) ->
    {X1, Y1} = P1,
    {X2, Y2} = P2,
    {X1 + X2, Y1 + Y2}.

distancia(P1, P2) ->
    {X1, Y1} = P1,
    {X2, Y2} = P2,
    sqrt( pow(X1 - X2, 2) + pow(Y1 - Y2, 2)).




