-module(jogadores).
-export([novoJogador/1,acelerarFrente/1, atualizaJogadores/4,calculaVelocidadeMax/1, vaiParaCoordenadas/3]).
-import(auxiliar, [multiplicaVector/2, normalizaVector/1, adicionaPares/2, distancia/2,posiciona/1]).
-import (math, [sqrt/1, pow/2, acos/1, cos/1, sin/1, pi/0]).

%Player = {true,Posicao, Direcao, Velocidade, Cor,Raio, AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin, Agilidade}
novoJogador(ListaAzul) ->

    %constantes
    RaioMax = 400.0,
    RaioMin = 20.0,
    Arrasto = 0.04,
    AceleracaoLinear = 0.35,
    AceleracaoAngular = 0.08,

    %variaveis
    
    CorAtual = 0,
    Velocidade = 0.10,
    Raio=80.0,
    Direcao = 0.0,
    Agilidade = 1.0,
    Pontuacao = 0,
    Posicao = posiciona(Raio),
    {true,Posicao, Direcao, Velocidade, CorAtual,Raio, AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao}.



calculaVelocidadeMax(Raio) ->
    VelocidadeMax = 600/Raio,
    VelocidadeMax.


%
verificaColisaoAzuis(Jogador, ListaAzul) ->
    {true,Posicao, Direcao, Velocidade, CorAtual,Raio, AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao}=Jogador,
    {PosX,PosY} = Posicao,
    T5 = verificaColisaoLimiteMapa(Jogador),
    %io:fwrite("RAIO MINIMO: ~p ~n", [RaioMin]),
    %io:fwrite("RAIO: ~p ~n", [Raio]),
    %io:fwrite("CONDICOES: ~p ~n", [T1 or T2 or T3 or T5]),
    

    if
        T5 ->
            E = true,
            DirecaoA = Direcao,
            Radians = (DirecaoA * pi()) / 180,
            if 
                PosX >= 1000 -> 
                    NPosicao=adicionaPares(Posicao,{-1299 + Raio ,0});
                PosX =< 300 -> 
                    NPosicao=adicionaPares(Posicao,{1299 - Raio,0});
                PosY >= 400 -> 
                   NPosicao=adicionaPares(Posicao,{0,-700 + Raio });
               true -> 
                   NPosicao=adicionaPares(Posicao,{0,700 - Raio})
            end,
            NPosicao;
    
        true ->
            E = true,
            NPosicao = Posicao,
            DirecaoA = Direcao
    end,

    {E,NPosicao, DirecaoA, Velocidade, CorAtual,Raio, AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao}.



verificaColisaoLimiteMapa (Jogador) ->
    {_,Posicao, _, _, _,Raio, _, _, _, _, _,  _,_}=Jogador,
    {PosX,PosY} = Posicao,
    if ((PosX + Raio/2) > 1300) or ((PosX - Raio/2) < 0) or ((PosY + Raio/2) > 700) or ((PosY - Raio/2) < 0) ->
        true;
    true ->
        false
    end.



atualizaColisaoVerdes( Jogador, Cristais ) ->
    TamanhoLista = length(Cristais),
    {{E,Posicao, Direcao, Velocidade, CorAtual,Raio, AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao},{U,P}} = Jogador,
    
    if 
        Raio+((20-0.05*Raio))*TamanhoLista > RaioMax ->
            NRaio = RaioMax;
        true ->
            NRaio = Raio+((20-0.05*Raio))*TamanhoLista
    end,

    if 
        TamanhoLista /= 0 ->
            NCorAtual = 0;
        true ->
            NCorAtual = CorAtual
    end,

    {{E,Posicao, Direcao, Velocidade, NCorAtual,NRaio, AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao},{U,P}} .



atualizaColisaoVermelhos( Jogador, Cristais ) ->
    TamanhoLista = length(Cristais),
    {{E,Posicao, Direcao, Velocidade, CorAtual,Raio, AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao},{U,P}} = Jogador,

    if 
        Raio+((20-0.05*Raio))*TamanhoLista > RaioMax ->
            NRaio = RaioMax;
        true ->
            NRaio = Raio+((20-0.05*Raio))*TamanhoLista
    end,

    if 
        TamanhoLista /= 0 ->
            NCorAtual = 1;
        true ->
            NCorAtual = CorAtual
    end,

    {{E,Posicao, Direcao, Velocidade, NCorAtual,Raio, AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao},{U,P}} .


atualizaColisaoAzuis( Jogador, Cristais ) ->
    TamanhoLista = length(Cristais),
    {{E,Posicao, Direcao, Velocidade, CorAtual,Raio, AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao},{U,P}} = Jogador,

    if 
        Raio+((20-0.05*Raio))*TamanhoLista > RaioMax ->
            NRaio = RaioMax;
        true ->
            NRaio = Raio+((20-0.05*Raio))*TamanhoLista
    end,

    if 
        TamanhoLista /= 0 ->
            NCorAtual = 2;
        true ->
            NCorAtual = CorAtual
    end,

    {{E,Posicao, Direcao, Velocidade, NCorAtual,NRaio, AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao},{U,P}} .



movimentaJogador(Jogador) ->

    {E,Posicao, Direcao, Velocidade, CorAtual,NRaio, AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao} = Jogador,
    

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
    NagilidadeA = Agilidade - 0.0004 ,
    if
        NagilidadeA < 0.5 -> Nagilidade = 0.5;
        true -> Nagilidade = NagilidadeA
    end,

    {E,NPosicao, Direcao, NVelocidade, CorAtual,NovoTamanho, AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin, Nagilidade,Pontuacao}.


    verificaColisaoJogadoresL(Jogador,[]) -> Jogador;
    verificaColisaoJogadoresL(Jogador,[H | T]) -> verificaColisaoJogadoresL(verificaColisaoJogadores2(Jogador,H),T).



    verificaVitoriaColisao (Cor1,Cor2,Tamanho1,Tamanho2) ->
        % return true if player 1 beats player 2
        % first check by color 
        %vermelho > verde > azul > vermelho
        % 1 > 0 > 2 > 1
        % then by size

        if 
            ((Cor1 == Cor2) and (Tamanho1 > Tamanho2))->
                true;
            true ->
                false
        end,    

        if 
            ((Cor1 == 1) and (Cor2 == 0)) ->
                true;
            ((Cor1 == 0) and (Cor2 == 2)) ->
                true;
            ((Cor1 == 2) and (Cor2 == 1)) ->
                true;
            true ->
                false
        end.



    verificaColisaoJogadores2 (Jogador1, Jogador2) ->

        {E1,NPosicao1, Direcao1, Velocidade1, Cor1, Tamanho1, AceleracaoLinear1, AceleracaoAngular1, Arrasto1, RaioMax1, RaioMin1, Agilidade1, Pontuacao1} = Jogador1,
        {_,NPosicao2, _, _, Cor2, Tamanho2, _, _, _, _, _, _, _} = Jogador2,
        {PosX1,PosY1} = NPosicao1,
        {PosX2,PosY2} = NPosicao2,
        D=distancia(NPosicao1, NPosicao2),
        
        Vitoria1 = verificaVitoriaColisao (Cor1,Cor2,Tamanho1,Tamanho2),

        if
            D < (Tamanho1/2 + Tamanho2/2) -> 
                Colidiu = true;
            true -> 
                Colidiu = false
        end,
        if
            Colidiu and not(Vitoria1) and (Tamanho1 =< RaioMin1) ->         %perdeu
                {false,NPosicao1, Direcao1, Velocidade1, Cor1, Tamanho1, AceleracaoLinear1, AceleracaoAngular1,  Arrasto1, RaioMax1, RaioMin1, Agilidade1, Pontuacao1};
            
            Colidiu and not(Vitoria1) and (Tamanho1 > RaioMin1) ->          %reset
                if
                    (Tamanho1 - 10)< RaioMin1 ->
                        NTamanho1 = RaioMin1;
                    true ->
                        NTamanho1 = Tamanho1 - 10
                end,

                DirecaoA = Direcao1-180,
                Radians = (DirecaoA * pi()) / 180,
                VecDirecao = multiplicaVector({cos(Radians), sin(Radians)}, 100),
                NPosicao= adicionaPares(NPosicao1, VecDirecao),  

                {true,NPosicao, DirecaoA,  Velocidade1, Cor1, NTamanho1, AceleracaoLinear1, AceleracaoAngular1, Arrasto1, RaioMax1, RaioMin1, Agilidade1, 0};                              
            
        
            Colidiu and Vitoria1  ->          %o outro perdeu/resetou
                if
                    (Tamanho1 + 20) > RaioMax1 ->
                        NTamanho1 = RaioMax1;
                    true ->
                        NTamanho1 = Tamanho1 + 20
                end,

                DirecaoA = Direcao1-180,
                Radians = (DirecaoA * pi()) / 180,
                VecDirecao = multiplicaVector({cos(Radians), sin(Radians)}, 100),
                NPosicao= adicionaPares(NPosicao1, VecDirecao),  

                {true,NPosicao, DirecaoA,  Velocidade1, Cor1, NTamanho1, AceleracaoLinear1, AceleracaoAngular1,  Arrasto1, RaioMax1, RaioMin1, Agilidade1, Pontuacao1+1};
            true -> 
                {E1,NPosicao1, Direcao1, Velocidade1, Cor1, Tamanho1, AceleracaoLinear1, AceleracaoAngular1,  Arrasto1, RaioMax1, RaioMin1, Agilidade1, Pontuacao1}
        end.
        


atualizaJogadores (ListaJogadores,ListaColisaoVerde ,ListaColisaoVermelho, ListaColisaoAzul) -> 
    

    %io:fwrite("Lista Nao Filtrada: ~p ~n", [ListaJogadores]),
    ListaJogadoresMexidos = [{movimentaJogador(Jogador),{U,P}} || {Jogador,{U,P}} <- ListaJogadores],
    
    ListaJogadoesObjetos = [{verificaColisaoAzuis(Jogador,[]),{U,P}} || {Jogador,{U,P}} <- ListaJogadoresMexidos],
    ListaJogadoesObjetosF = [J || {J,{_,_}} <- ListaJogadoesObjetos],
    ListaJogadoresColisaoJogadores = [{verificaColisaoJogadoresL(Jogador,ListaJogadoesObjetosF--[Jogador]),{U,P}} || {Jogador,{U,P}} <- ListaJogadoesObjetos],
    LengthVerdes = length(ListaColisaoVerde),
    
    if 
        LengthVerdes == 1 ->
            [HG1] = ListaColisaoVerde,
            [HR1] = ListaColisaoVermelho,
            [HB1] = ListaColisaoAzul,
            [HJ1] = ListaJogadoresColisaoJogadores,
            LJVerdes = atualizaColisaoVerdes(HJ1,HG1),
            LJAzul = atualizaColisaoAzuis(LJVerdes,HB1),
            LJVermelhos = [atualizaColisaoVermelhos(LJAzul,HR1)];
        LengthVerdes == 2 -> 
            [HG1 , HG2 | _] = ListaColisaoVerde,
            [HR1 , HR2 | _] = ListaColisaoVermelho,
            [HB1 , HB2 | _] = ListaColisaoAzul,
            [HJ1 , HJ2 | _] = ListaJogadoresColisaoJogadores,
            LJVerdes = [atualizaColisaoVerdes(HJ1,HG1)] ++ [atualizaColisaoVerdes(HJ2,HG2)],
            [A1, A2 | _] = LJVerdes,
            LJAzul = [atualizaColisaoAzuis(A1,HB1)] ++ [atualizaColisaoAzuis(A2,HB2)],
            [B1, B2 | _] = LJAzul,
            LJVermelhos = [atualizaColisaoVermelhos(B1,HR1)] ++ [atualizaColisaoVermelhos(B2,HR2)];    
        LengthVerdes == 3 -> 
            [HG1 , HG2, HG3 | _] = ListaColisaoVerde,
            [HR1 , HR2, HR3 | _] = ListaColisaoVermelho,
            [HB1 , HB2, HB3 | _] = ListaColisaoAzul,
            [HJ1 , HJ2, HJ3 | _] = ListaJogadoresColisaoJogadores,
            LJVerdes = [atualizaColisaoVerdes(HJ1,HG1)] ++ [atualizaColisaoVerdes(HJ2,HG2)] ++ [atualizaColisaoVerdes(HJ3,HG3)],
            [A1, A2, A3 | _] = LJVerdes,
            LJAzul = [atualizaColisaoAzuis(A1,HG1)] ++ [atualizaColisaoAzuis(A2,HG2)] ++ [atualizaColisaoAzuis(A3,HG3)],
            [B1, B2, B3 | _] = LJAzul,
            LJVermelhos = [atualizaColisaoVermelhos(B1,HR1)] ++ [atualizaColisaoVermelhos(B2,HR2)] ++ [atualizaColisaoVermelhos(B3,HR3)];
        true ->
            LJVermelhos = ListaJogadores
    end,
    %io:format("Lista Return Update~p~n",[LJVermelhos]),
    LJVermelhos.



acelerarFrente(Jogador) ->
    {E,Posicao, Direcao, Velocidade, Cor,Raio, AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao} = Jogador,
    VelocidadeMaxRaio = calculaVelocidadeMax(Raio),
    if 
        E ->
                       
            NvelocidadeA = Velocidade + Agilidade/2 * AceleracaoLinear,
            if 
                NvelocidadeA > VelocidadeMaxRaio ->
                    NVelocidade = VelocidadeMaxRaio;
                true ->     
                    NVelocidade =  NvelocidadeA
            end,
            
            {true,Posicao, Direcao, NVelocidade, Cor,Raio,  AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin,Agilidade,Pontuacao};
        true -> 
            Jogador
    end.


vaiParaCoordenadas(Jogador,X,Y) -> 
    {E,Posicao, Direcao, Velocidade, Cor,Raio, AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin, Agilidade,Pontuacao} = Jogador,
    {X1,Y1} = Posicao,
    VelocidadeMaxRaio = calculaVelocidadeMax(Raio),
    NvelocidadeA = Velocidade + Agilidade/2 * AceleracaoLinear,
    if 
        NvelocidadeA > VelocidadeMaxRaio ->
            NVelocidade = VelocidadeMaxRaio;
        true ->     
            NVelocidade =  NvelocidadeA
    end, 


    {X2,Y2} = normalizaVector({ X-X1,Y-Y1}),


    Radians = (Direcao * pi()) / 180,
    VecDirecao = normalizaVector({cos(Radians), sin(Radians)}),
    {X3,Y3} = VecDirecao,
    
    if 
        ((X3 == 0) and (Y3 == 0)) -> Cos = 0;
        true -> Cos = (X3*X2 + Y3*Y2) / (sqrt(X3*X3 + Y3*Y3) * sqrt(X2*X2 + Y2*Y2))
    end,

    Angulo = acos(Cos) * 180 / pi(),
    
    if 
        Y2 > 0 ->  Angulo2 = 360 - Angulo;
        true -> Angulo2 = Angulo
    end,
    Angulo2Rad =- ((Angulo2 * pi()) /180),

    case E of 
        true -> 
            if 
                (( Y > Y1) and (X>X1)) -> 
                    NDirecao = Direcao + AceleracaoAngular * Agilidade/2 ,
                    {true,Posicao, Angulo2Rad, NVelocidade, Cor,Raio,  AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin,Agilidade,Pontuacao};
                ((Y < Y1) and (X>X1)) ->
                        NDirecao = Direcao - AceleracaoAngular  * Agilidade/2,
                    {true,Posicao, Angulo2Rad, NVelocidade, Cor,Raio,  AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin,Agilidade,Pontuacao};
                
                (( Y > Y1) and (X<X1)) -> 
                    NDirecao = Direcao - AceleracaoAngular  * Agilidade/2,
                    {true,Posicao, Angulo2Rad, NVelocidade, Cor,Raio,  AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin,Agilidade,Pontuacao};
                ((Y < Y1) and (X<X1)) ->
                        NDirecao = Direcao + AceleracaoAngular * Agilidade/2 ,
                    {true,Posicao, Angulo2Rad, NVelocidade, Cor,Raio,  AceleracaoLinear, AceleracaoAngular,    Arrasto, RaioMax,RaioMin,Agilidade,Pontuacao};
                true -> 
                    Jogador
                
            end;
        false -> 
            Jogador
    end.