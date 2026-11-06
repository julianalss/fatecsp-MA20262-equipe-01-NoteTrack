// fnExtrairTermo -- mesmo papel do PROC(2;1/ÉNÚM(LOCALIZAR(...))) da Etapa 1:
// devolve o valor do ÚLTIMO termo da lista encontrado no texto (termos mais específicos ficam no fim)
(busca as text, termos as list, valores as list) as any =>
    let
        Posicoes = List.Select(List.Positions(termos), each Text.Contains(busca, termos{_}))
    in
        if List.IsEmpty(Posicoes) then null else valores{List.Last(Posicoes)}
