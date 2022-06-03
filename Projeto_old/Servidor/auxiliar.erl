-module(auxiliar).
-export([multiplicaVector/2, normalizaVector/1, meioVectores/2, adicionaPares/2, distancia/2, subtraiVectores/2,posiciona/1]).
-import (math, [sqrt/1, pow/2]).

% Contas com vetores

normalizaVector(Vec) ->
    {X, Y} = Vec,
    D = sqrt( pow(X,2) + pow(Y,2) ),
    { X/D, Y/D }.


meioVectores(Vec1, Vec2) ->
    {X1, Y1} = Vec1,
    {X2, Y2} = Vec2,
    { (X1 + X2)/2, (Y1 + Y2)/2}.


multiplicaVector(Vec, Cons) ->
    {X,Y} = Vec,
    { Cons * X, Cons * Y}.


% Contas com posições

adicionaPares(P1, P2) ->
    {X1, Y1} = P1,
    {X2, Y2} = P2,
    {X1 + X2, Y1 + Y2}.

distancia(P1, P2) ->
    {X1, Y1} = P1,
    {X2, Y2} = P2,
    sqrt( pow(X1 - X2, 2) + pow(Y1 - Y2, 2)).

subtraiVectores(P1, P2) ->
    {X1, Y1} = P1,
    {X2, Y2} = P2,
    {X2 - X1, Y2 - Y1}.



posiciona(ListaObstaculos)->
    Posicao= {float(rand:uniform(1100))+50,float(rand:uniform(700))+50},
    [OB1,OB2,OB3|_]=ListaObstaculos,
    {X1,Y1,T1}=OB1,
    {X2,Y2,T2}=OB2,
    {X3,Y3,T3}=OB3,
    D1=distancia(Posicao,{X1,Y1}),
    C1=D1 < (T1/2 + 50.0/2)+20,
    D2=distancia(Posicao,{X2,Y2}),
    C2=D2 < (T2/2 + 50.0/2)+20,
    D3=distancia(Posicao,{X3,Y3}),
    C3=D3 < (T3/2 + 50.0/2)+20,

    if 
        C1 or C2 or C3->posiciona(ListaObstaculos);
        true -> Posicao
    end.

