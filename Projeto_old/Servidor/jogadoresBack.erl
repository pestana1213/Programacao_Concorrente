-module(jogador).
-export([novoJogador/1, acelerarFrente/1, viraDireita/1, viraEsquerda/1, atualizaJogadores/5 ]).
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
    Posicao = {float(rand:uniform(1200)),float(rand:uniform(800))},
    EnergiaAtual = 20.0,
    Velocidade = 1.0,
    Raio=50.0,
    Direcao = 0.0,
    Agilidade = 1.0,

    {true,Posicao, Direcao, Velocidade, Energia,Raio, AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin, Agilidade}.

calculaVelocidadeMax(Raio) ->
    VelocidadeMax = 100/Raio,
    VelocidadeMax.



acelerarFrente(Jogador) ->
    {E,Posicao, Direcao, Velocidade, Energia,Raio, AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin, Agilidade} = Jogador,
    VelocidadeMaxRaio = calculaVelocidadeMax(Raio),
    case E of
        true ->
            if
                Energia >= GastoEnergia ->                    
                    NvelocidadeA = Velocidade + Agilidade * AceleracaoLinear,
                    NEnergia   = Energia - GastoEnergia,

                    if 
                    NvelocidadeA > VelocidadeMaxRaio ->
                        Nvelocidade = VelocidadeMax;
                    true ->     
                        Nvelocidade =  NvelocidadeA
                    end;

                true ->
                    Nvelocidade = Velocidade,
                    NEnergia   = Energia
                
            end,
            {true,Posicao, Direcao, NVelocidade, NEnergia,Raio,  AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin,Agilidade};
        false -> 
            Jogador
    end.




viraDireita(Jogador) ->
    {E,Posicao, Direcao, Velocidade, Energia,Raio,  AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin,Agilidade} = Jogador,
    case E of
        true ->
            if
                Energia >= GastoEnergia ->
                    NDirecao = Direcao + AceleracaoAngular * Agilidade ,
                    NEnergia = Energia - GastoEnergia;
                    
                true ->
                    NDirecao = Direcao,
                    NEnergia = Energia 
            end,
            {true,Posicao, NDirecao, Velocidade, NEnergia,Raio,  AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin,Agilidade};
        false -> 
            Jogador
    end.

viraEsquerda(Jogador) ->
    {E,Posicao, Direcao, Velocidade, Energia,Raio,  AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin,Agilidade}= Jogador,
    case E of
        true ->
            if
                Energia >= GastoEnergia ->
                    NDirecao = Direcao - AceleracaoAngular  * Agilidade,
                    NEnergia   = Energia - GastoEnergia;
                    
                true ->
                    NDirecao = Direcao,
                    NEnergia = Energia 
            end,
            {true,Posicao, NDirecao, Velocidade, NEnergia,Raio,  AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin,Agilidade};
        false->
            Jogador
        end.



atualizaJogadores(P1, P2, P3, ColisaoVerde1, ColisaoVerde2,ColisaoVerde3,ColisaoVermelho1 ,ColisaoVermelho2 ,ColisaoVermelho3 ,Interpolacao) ->
    {E1,Posicao1, Direcao1, Velocidade1, Energia1,Raio1,  AceleracaoLinear1, AceleracaoAngular1, EnergiaMax1, GastoEnergia1, GanhoEnergia1, Arrasto1, RaioMax1,RaioMin1,Agilidade1} = P1,
    {E2,Posicao2, Direcao2, Velocidade2, Energia2,Raio2,  AceleracaoLinear2, AceleracaoAngular2, EnergiaMax2, GastoEnergia2, GanhoEnergia2, Arrasto2, RaioMax2,RaioMin2,Agilidade2} = P2,
    {E3,Posicao3, Direcao3, Velocidade3, Energia3,Raio3,  AceleracaoLinear3, AceleracaoAngular3, EnergiaMax3, GastoEnergia3, GanhoEnergia3, Arrasto3, RaioMax3,RaioMin3,Agilidade3} = P3,

    
    case E1 of
        true->
            VecDirecao1 = multiplicaVector({cos(Direcao1), sin(Direcao1)}, Velocidade1 * Interpolacao),
            NPosicao1 = adicionaPares(Posicao1, VecDirecao1),
            if
                Velocidade1 > 0.0 -> NVelocidade1 = Velocidade1 -  Arrasto1*Interpolacao;
                true -> NVelocidade1 = 0.0
            end,
            if
                (Energia1 + GanhoEnergia1) > EnergiaMax1 -> NEnergia1 = EnergiaMax1;
                true -> NEnergia1 = PEnergia1 + GanhoEnergia1
            end,


            NagilidadeA = Agilidade1 + ColisaoVerde1/4 - ColisaoVermelho1/4 - 0.01 * Interpolacao ;
            if
                NagilidadeA < 0.1 -> Nagilidade1 = 0.1;
                true -> Nagilidade1 = NagilidadeA
            end,


            NRaioA = Raio1 + ColisaoVerde1*10,
            if
                NRaioA > RaioMax1 -> NRaio1 = VRaioMax1;
                true -> NRaio1 = NRaioA
            end;


        false->
            NPosicao1=Posicao1,
            NVelocidade1=Velocidade1,
            NEnergia1=Energia1,
            NRaio1 = Raio1,
            Nagilidade1 = Agilidade1
    end,

    case E2 of
        true->
            VecDirecao2 = multiplicaVector({cos(Direcao2), sin(Direcao2)}, Velocidade2 * Interpolacao),
            NPosicao2 = adicionaPares(Posicao2,VecDirecao2),
            if
                Velocidade2 > 0.0 -> NVelocidade2 = Velocidade2 -  Arrasto2*Interpolacao;
                true -> Velocidade2 = 0.0
            end,
            if
                (Energia2 + GanhoEnergia2 ) > EnergiaMax2 -> NEnergia2 = EnergiaMax2;
                true -> NEnergia2 = Energia2 + GanhoEnergia2 
            end,

            NagilidadeB = Agilidade2 + ColisaoVerde2/4 - ColisaoVermelho2/4 - 0.01 * Interpolacao ;
            if
                NagilidadeB < 0.1 -> Nagilidade2 = 0.1;
                true -> Nagilidade2 = NagilidadeB
            end,


            NRaioB = Raio2 + ColisaoVerde2*10,
            if
                NRaioB > RaioMax2 -> NRaio2 = VRaioMax2;
                true -> NRaio2 = NRaioB
            end;


        false-> 
            NPosicao2=Posicao2,
            NVelocidade2=Velocidade2,
            NEnergia2=Energia2,
            NRaio2 = Raio2,
            Nagilidade2 = Agilidade2
    end,

    case E3 of
        true->
            VecDirecao3 = multiplicaVector({cos(Direcao3), sin(Direcao3)}, Velocidade3 * Interpolacao),
            NPosicao3 = adicionaPares(Posicao3, VecDirecao3),
            if
                Velocidade3 > 0.0 -> NVelocidade3 = Velocidade3 -  Arrasto3*Interpolacao;
                true -> NVelocidade3 = 0.0
            end,

            if
                (Energia3 + GanhoEnergia3) > EnergiaMax3 -> NEnergia3 = EnergiaMax3;
                true -> NEnergia3 = PEnergia3 + GanhoEnergia3
            end,

            NagilidadeC = Agilidade3 + ColisaoVerde3/4 - ColisaoVermelho3/4 - 0.01 * Interpolacao ;
            if
                NagilidadeC < 0.1 -> Nagilidade3 = 0.1;
                true -> Nagilidade3 = NagilidadeC
            end,


            NRaioC = Raio3 + ColisaoVerde3*10,
            if
                NRaioC > RaioMax3 -> NRaio3 = VRaioMax3;
                true -> NRaio3 = NRaioC
            end;

        false->
            NPosicao3=Posicao3,
            NVelocidade3=Velocidade3,
            NEnergia3=Energia3
            NRaio3 = Raio3,
            Nagilidade3 = Agilidade3
    end,


    {
        {E1,NPosicao1, Direcao1, NVelocidade1, NEnergia1,NRaio1, AceleracaoLinear1, AceleracaoAngular1, EnergiaMax1, GastoEnergia1, GanhoEnergia1, Arrasto1, RaioMax1,RaioMin1,NAgilidade1},
        {E2,NPosicao2, Direcao2, NVelocidade2, NEnergia2,NRaio2, AceleracaoLinear2, AceleracaoAngular2, EnergiaMax2, GastoEnergia2, GanhoEnergia2, Arrasto2, RaioMax2,RaioMin2,NAgilidade2},
        {E3,NPosicao3, Direcao3, NVelocidade3, NEnergia3,NRaio3, AceleracaoLinear3, AceleracaoAngular3, EnergiaMax3, GastoEnergia3, GanhoEnergia3, Arrasto3, RaioMax3,RaioMin3,NAgilidade3},
    }.




