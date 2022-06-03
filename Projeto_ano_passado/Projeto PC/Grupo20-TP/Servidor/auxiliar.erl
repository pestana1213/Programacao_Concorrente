-module(auxiliar).
-export([multiplicaVector/2, normalizaVector/1, adicionaPares/2, distancia/2,posiciona/2, geraObstaculo/2]).
-import (math, [sqrt/1, pow/2]).

%gerar lista obstaculos
geraObstaculo(ListaObs,0) -> ListaObs;
geraObstaculo(ListaObs,Numero) -> geraObstaculo(ListaObs++[{rand:uniform(950)+100,rand:uniform(550)+100,rand:uniform(50)+100}],Numero-1).

%dar uma posicacao fora de obstaculos
posiciona(Raio,ListaObstaculos)->
    Posicao= {float(rand:uniform(1200))+50,float(rand:uniform(600))+50},
    [OB1,OB2,OB3|_]=ListaObstaculos,
    {X1,Y1,T1}=OB1,
    {X2,Y2,T2}=OB2,
    {X3,Y3,T3}=OB3,
    D1=distancia(Posicao,{X1,Y1}),
    C1=D1 < (T1/2 + Raio/2)+20,
    D2=distancia(Posicao,{X2,Y2}),
    C2=D2 < (T2/2 + Raio/2)+20,
    D3=distancia(Posicao,{X3,Y3}),
    C3=D3 < (T3/2 + Raio/2)+20,

    if 
        C1 or C2 or C3->posiciona(Raio,ListaObstaculos);
        true -> Posicao
    end.


% Contas com vetores

normalizaVector(Vec) ->
    {X, Y} = Vec,
    D = sqrt( pow(X,2) + pow(Y,2) ),
    { X/D, Y/D }.

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




