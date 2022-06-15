-module(conversores).
-export([formatState/1,formatarPontuacoes/1, formataTecla/1]).

formataTecla( Data ) ->
    Key = re:replace(Data, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
    Key.

jogador_para_string(Jogador) ->
    {{_,{X,Y}, Direcao, _, CorAtual,Raio, _, _, _, _, _, Agilidade,Pontuacao},U} = Jogador,
    Lista = [U,integer_to_list(Pontuacao),integer_to_list(CorAtual),float_to_list(X, [{decimals, 3}]), float_to_list(Y, [{decimals, 3}]), float_to_list(Raio, [{decimals, 3}]),float_to_list(Direcao, [{decimals, 3}]),  float_to_list(Agilidade, [{decimals, 3}])],
    string:join(Lista, " ").


jogadores_para_string([]) -> "";
jogadores_para_string([H]) -> jogador_para_string(H) ++ " ";
jogadores_para_string([H|T]) -> jogador_para_string(H) ++ " " ++  jogadores_para_string(T).

criatura_para_string(Criatura) ->
    {{X,Y}, Direcao, Tamanho, _, _} = Criatura,
    Lista = [float_to_list(X, [{decimals, 3}]), float_to_list(Y, [{decimals, 3}])],
    string:join(Lista, " ").


criaturas_para_string([]) -> "";
criaturas_para_string([H]) -> criatura_para_string(H) ++ " ";
criaturas_para_string([H|T]) -> criatura_para_string(H) ++ " " ++ criaturas_para_string(T).


obstaculo_para_string(Obstaculo) ->
    {X,Y,Tamanho} = Obstaculo,
    Lista = [integer_to_list(X), integer_to_list(Y)],
    string:join(Lista, " ").


obstaculos_para_string([]) -> "";
obstaculos_para_string([H]) -> obstaculo_para_string(H) ++ " ";
obstaculos_para_string([H|T]) -> obstaculo_para_string(H) ++ " " ++ obstaculos_para_string(T).


formatarPontuacoes ([]) -> "";
formatarPontuacoes ([{U,P}|T]) -> U ++ " " ++  integer_to_list(P) ++ " " ++ formatarPontuacoes(T) ++ "\n".

formatState (Estado) ->
    {ListaJogadores, ListaVerdes, ListaReds, ListaBlues, _} = Estado,
    Len1 = integer_to_list(length(ListaJogadores)) ++ " ",
    L1 = [{J,U} || {J, {U,_}} <- ListaJogadores ],
    R1 = jogadores_para_string(L1),
    Len2 = integer_to_list(length(ListaVerdes)) ++ " ",
    R2 = criaturas_para_string(ListaVerdes),
    Len3 = integer_to_list(length(ListaReds)) ++ " ",
    R3 = criaturas_para_string(ListaReds),
    Len4 = integer_to_list(length(ListaBlues)) ++ " ",
    R4 = criaturas_para_string(ListaBlues),
    Resultado = "Estado " ++ Len1 ++ R1 ++ Len2 ++ R2 ++ Len3 ++ R3 ++ Len4 ++ R4 ++ "\n",
    Resultado.