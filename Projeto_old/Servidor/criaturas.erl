-module(criaturas).
-export([novaCriatura/1]).
-import(auxliar, [multiplicaVector/2, normalizaVector/1, meioVectores/2, adicionaPares/2, distancia/2, subtraiVectores/2]).

novaCriatura(Tipo) ->
    Direcao = 0.0,
    Tamanho = 50,
    Velocidade = 1.0,
    Posicao = {rand:uniform(1200),rand:uniform(800)},
    {Posicao, Direcao, Tamanho, Tipo, Velocidade}.

