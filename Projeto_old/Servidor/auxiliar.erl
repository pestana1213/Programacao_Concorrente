-module(auxiliar).
-export([multiplicaVector/2, normalizaVector/1, meioVectores/2, adicionaPares/2, distancia/2, subtraiVectores/2]).
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

