-module(jogadores).
-export([novoJogador/0 ]).
-import(auxiliar, [multiplicaVector/2, normalizaVector/1, meioVectores/2, adicionaPares/2, distancia/2, subtraiVectores/2]).
-import (math, [sqrt/1, pow/2, cos/1, sin/1]).

%Player = {true,Posicao, Direcao, Velocidade, Energia,Raio, AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin, Agilidade}
novoJogador() ->

    %constantes
    RaioMax = 100.0,
    RaioMin = 5.0,
    EnergiaMax = 20.0,
    Arrasto = 0.1,
    AceleracaoLinear = 2.25,
    AceleracaoAngular = 0.55,
    GastoEnergia = 2.0,
    GanhoEnergia= 0.2,

    %variaveis
    Posicao = {rand:uniform(1200),rand:uniform(800)},
    EnergiaAtual = 20.0,
    Velocidade = 1.0,
    Raio=50,
    Direcao = 0.0,
    Agilidade = 1.0,

    {true,Posicao, Direcao, Velocidade, EnergiaAtual,Raio, AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin, Agilidade}.

