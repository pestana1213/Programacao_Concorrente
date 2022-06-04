-module(jogadores).
-export([novoJogador/1,acelerarFrente/1, viraDireita/1, viraEsquerda/1 ,atualizaJogadores/4,calculaVelocidadeMax/1]).
-import(auxiliar, [multiplicaVector/2, normalizaVector/1, adicionaPares/2, distancia/2,posiciona/2]).
-import (math, [sqrt/1, pow/2, cos/1, sin/1, pi/0]).

%Player = {true,Posicao, Direcao, Velocidade, Energia,Raio, AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin, Agilidade}
novoJogador() ->

    %constantes
    RaioMax = 220.0,
    RaioMin = 20.0,
    EnergiaMax = 20.0,
    Arrasto = 0.04,
    AceleracaoLinear = 0.35,
    AceleracaoAngular = 0.2,
    GastoEnergia = 0.10,
    GanhoEnergia= 0.03,

    %variaveis
    
    EnergiaAtual = 20.0,
    Velocidade = 0.30,
    Raio=60.0,
    Direcao = 0.0,
    Agilidade = 1.0,
    Pontuacao = 0,
    Posicao = posiciona(Raio),
    {true,Posicao, Direcao, Velocidade, EnergiaAtual,Raio, AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao}.



calculaVelocidadeMax(Raio) ->
    VelocidadeMax = 300/Raio,
    VelocidadeMax.


verificaColisaoLimiteMapa (Jogador) ->
    {_,Posicao, _, _, _,Raio, _, _, _, _, _, _, _,_, _,_}=Jogador,
    {PosX,PosY} = Posicao,
    if ((PosX + Raio/2) > 1300) or ((PosX - Raio/2) < 0) or ((PosY + Raio/2) > 700) or ((PosY - Raio/2) < 0) ->
        true;
    true ->
        false
    end.


%


atualizaColisaoVerdes( Jogador, Criaturas ) ->
    TamanhoLista = length(Criaturas),
    {{E,Posicao, Direcao, Velocidade, EnergiaAtual,Raio, AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao},{U,P}} = Jogador,

    if 
        Agilidade+(0.25*TamanhoLista) > 2.0 ->
            NAgilidade = 2.0;
        true ->
            NAgilidade = Agilidade+(0.25*TamanhoLista)
    end,
    
    if 
        Raio+((32.22222-0.1111111*Raio))*TamanhoLista > RaioMax ->
            NRaio = RaioMax;
        true ->
            NRaio = Raio+((32.22222-0.1111111*Raio))*TamanhoLista
    end,


    {{E,Posicao, Direcao, Velocidade, EnergiaAtual,NRaio, AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin, NAgilidade,Pontuacao},{U,P}} .



atualizaColisaoVermelhos( Jogador, Criaturas ) ->
    TamanhoLista = length(Criaturas),
    {{E,Posicao, Direcao, Velocidade, EnergiaAtual,Raio, AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao},{U,P}} = Jogador,

    if 
        Agilidade-(0.25*TamanhoLista) < 0.5 ->
            NAgilidade = 0.5;
        true ->
            NAgilidade = Agilidade-(0.25*TamanhoLista)
    end,

    if 
        (Raio =< RaioMin) and (TamanhoLista > 0) ->
            NE = false;
        true ->
            NE = E
    end,

    {{NE,Posicao, Direcao, Velocidade, EnergiaAtual,Raio, AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin, NAgilidade,Pontuacao},{U,P}} .


    


movimentaJogador(Jogador) ->

    {E,Posicao, Direcao, Velocidade, EnergiaAtual,NRaio, AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao} = Jogador,
    

    if 
        NRaio > RaioMin ->
            NovoTamanho = NRaio - 0.035;
        true ->
            NovoTamanho = NRaio
    end,
    VecDirecao = multiplicaVector({cos(Direcao), sin(Direcao)}, Velocidade),
    NPosicao = adicionaPares(Posicao, VecDirecao),

    if
        Velocidade > 0.0 -> NVelocidade = Velocidade -  Arrasto;
        true -> NVelocidade = 0.0
    end,
    if
        (EnergiaAtual + GanhoEnergia) > EnergiaMax -> NEnergia = EnergiaMax;
        true -> NEnergia = EnergiaAtual + GanhoEnergia
    end,
    NagilidadeA = Agilidade - 0.0004 ,
    if
        NagilidadeA < 0.5 -> Nagilidade = 0.5;
        true -> Nagilidade = NagilidadeA
    end,

    {E,NPosicao, Direcao, NVelocidade, NEnergia,NovoTamanho, AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin, Nagilidade,Pontuacao}.


    verificaColisaoJogadoresL(Jogador,[]) -> Jogador;
    verificaColisaoJogadoresL(Jogador,[H | T]) -> verificaColisaoJogadoresL(verificaColisaoJogadores2(Jogador,H),T).



    verificaColisaoJogadores2 (Jogador1, Jogador2) ->
        %io:format("Jogador1  ~p~n",[Jogador1]),
        {E1,NPosicao1, Direcao1, Velocidade1, Energia1, Tamanho1, AceleracaoLinear1, AceleracaoAngular1, EnergiaMax1, GastoEnergia1, GanhoEnergia1, Arrasto1, RaioMax1, RaioMin1, Agilidade1, Pontuacao1} = Jogador1,
        %io:format("Jogador2  ~p~n",[Jogador2]),
        {_,NPosicao2, _, _, _, Tamanho2, _, _, _, _, _, _, _, _, _, _} = Jogador2,
        {PosX1,PosY1} = NPosicao1,
        {PosX2,PosY2} = NPosicao2,
        D=distancia(NPosicao1, NPosicao2),
        
        if
            D < (Tamanho1/2 + Tamanho2/2) -> 
                Colidiu = true;
            true -> 
                Colidiu = false
        end,
        if
            Colidiu and (Tamanho1 < Tamanho2) and (Tamanho1 =< RaioMin1) ->         %perdeu
                {false,NPosicao1, Direcao1, Velocidade1, Energia1, Tamanho1, AceleracaoLinear1, AceleracaoAngular1, EnergiaMax1, GastoEnergia1, GanhoEnergia1, Arrasto1, RaioMax1, RaioMin1, Agilidade1, Pontuacao1};
            Colidiu and (Tamanho1 < Tamanho2) and (Tamanho1 > RaioMin1) ->          %reset
                if
                    (Tamanho1 - 10)< RaioMin1 ->
                        NTamanho1 = RaioMin1;
                    true ->
                        NTamanho1 = Tamanho1 - 10
                end,
                if
                    (Agilidade1 + 0.5) > 2.0 ->
                        NAgilidade1 = 2.0;
                    true ->
                        NAgilidade1 = Agilidade1 + 0.5
                end,
                {true,posiciona(NTamanho1), 0.0,  0.30, 20.0, NTamanho1, AceleracaoLinear1, AceleracaoAngular1, EnergiaMax1, GastoEnergia1, GanhoEnergia1, Arrasto1, RaioMax1, RaioMin1, NAgilidade1, 0};                              
            Colidiu and (Tamanho2 < Tamanho1) ->          %o outro perdeu/resetou
                if
                    (Tamanho1 + 20) > RaioMax1 ->
                        NTamanho1 = RaioMax1;
                    true ->
                        NTamanho1 = Tamanho1 + 20
                end,
                if
                    (Agilidade1 - 0.25) < 0.5 ->
                        NAgilidade1 = 0.5;
                    true ->
                        NAgilidade1 = Agilidade1 - 0.25
                end,
                {E1,NPosicao1, Direcao1, Velocidade1, Energia1, NTamanho1, AceleracaoLinear1, AceleracaoAngular1, EnergiaMax1, GastoEnergia1, GanhoEnergia1, Arrasto1, RaioMax1, RaioMin1, NAgilidade1, Pontuacao1+1};
            true -> 
                {E1,NPosicao1, Direcao1, Velocidade1, Energia1, Tamanho1, AceleracaoLinear1, AceleracaoAngular1, EnergiaMax1, GastoEnergia1, GanhoEnergia1, Arrasto1, RaioMax1, RaioMin1, Agilidade1, Pontuacao1}
        end.
        


atualizaJogadores (ListaJogadores,ListaColisaoVerde ,ListaColisaoVermelho) -> 
    
    ListaJogadoresMexidos = [{movimentaJogador(Jogador),{U,P}} || {Jogador,{U,P}} <- ListaJogadores],
    
    ListaJogadoesObjetos = [{Jogador,{U,P}} <- ListaJogadoresMexidos],
    ListaJogadoesObjetosF = [J || {J,{_,_}} <- ListaJogadoesObjetos],
    ListaJogadoresColisaoJogadores = [{verificaColisaoJogadoresL(Jogador,ListaJogadoesObjetosF--[Jogador]),{U,P}} || {Jogador,{U,P}} <- ListaJogadoesObjetos],
    LengthVerdes = length(ListaColisaoVerde),
    
    if 
        LengthVerdes == 1 ->
            [HG1] = ListaColisaoVerde,
            [HR1] = ListaColisaoVermelho,
            [HJ1] = ListaJogadoresColisaoJogadores,
            LJVerdes = atualizaColisaoVerdes(HJ1,HG1),
            LJVermelhos = [atualizaColisaoVermelhos(LJVerdes,HR1)];
        
        LengthVerdes == 2 -> 
            [HG1 , HG2 | _] = ListaColisaoVerde,
            [HR1 , HR2 | _] = ListaColisaoVermelho,
            [HJ1 , HJ2 | _] = ListaJogadoresColisaoJogadores,
            LJVerdes = [atualizaColisaoVerdes(HJ1,HG1)] ++ [atualizaColisaoVerdes(HJ2,HG2)],
            [A1, A2 | _] = LJVerdes,
            LJVermelhos = [atualizaColisaoVermelhos(A1,HR1)] ++ [atualizaColisaoVermelhos(A2,HR2)];    
        LengthVerdes == 3 -> 
            [HG1 , HG2, HG3 | _] = ListaColisaoVerde,
            [HR1 , HR2, HR3 | _] = ListaColisaoVermelho,
            [HJ1 , HJ2, HJ3 | _] = ListaJogadoresColisaoJogadores,
            LJVerdes = [atualizaColisaoVerdes(HJ1,HG1)] ++ [atualizaColisaoVerdes(HJ2,HG2)] ++ [atualizaColisaoVerdes(HJ3,HG3)],
            [A1, A2, A3 | _] = LJVerdes,
            LJVermelhos = [atualizaColisaoVermelhos(A1,HR1)] ++ [atualizaColisaoVermelhos(A2,HR2)] ++ [atualizaColisaoVermelhos(A3,HR3)];
        true ->
            LJVermelhos = ListaJogadores
    end,
    %io:format("Lista Return Update~p~n",[LJVermelhos]),
    LJVermelhos.



acelerarFrente(Jogador) ->
    {E,Posicao, Direcao, Velocidade, Energia,Raio, AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao} = Jogador,
    VelocidadeMaxRaio = calculaVelocidadeMax(Raio),
    if 
        E ->
            if
                Energia >= GastoEnergia->                    
                    NvelocidadeA = Velocidade + Agilidade/2 * AceleracaoLinear,
                    NEnergia   = Energia - GastoEnergia,

                    if 
                    NvelocidadeA > VelocidadeMaxRaio ->
                        NVelocidade = VelocidadeMaxRaio;
                    true ->     
                        NVelocidade =  NvelocidadeA
                    end;

                true ->
                    NVelocidade = Velocidade,
                    NEnergia   = Energia
                
            end,
            {true,Posicao, Direcao, NVelocidade, NEnergia,Raio,  AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin,Agilidade,Pontuacao};
        true -> 
            Jogador
    end.


viraDireita(Jogador) ->
    {E,Posicao, Direcao, Velocidade, Energia,Raio,  AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin,Agilidade,Pontuacao} = Jogador,
    case E of
        true ->
            NDirecao = Direcao + AceleracaoAngular * Agilidade/2 ,
            {true,Posicao, NDirecao, Velocidade, Energia,Raio,  AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin,Agilidade,Pontuacao};
        false -> 
            Jogador
    end.

viraEsquerda(Jogador) ->
    {E,Posicao, Direcao, Velocidade, Energia,Raio,  AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin,Agilidade,Pontuacao}= Jogador,
    case E of
        true ->
            NDirecao = Direcao - AceleracaoAngular  * Agilidade/2,
            {true,Posicao, Energia, Velocidade, Energia,Raio,  AceleracaoLinear, AceleracaoAngular, EnergiaMax, GastoEnergia, GanhoEnergia, Arrasto, RaioMax,RaioMin,Agilidade,Pontuacao};
        false->
            Jogador
        end.