// fnTextoBusca -- mesma regra da coluna Busca da Etapa 1: minúsculas, pontuação vira espaço,
// um espaço em cada ponta (para achar termos como " m4 ")
(titulo as nullable text) as text =>
    let
        Base = if titulo = null then "" else Text.Lower(titulo),
        Pontuacao = {"/", "-", ",", "|", "(", ")", ":", ";", """", "'", "•", "”", Character.FromNumber(8209)},
        SemPontuacao = List.Accumulate(Pontuacao, Base, (estado, simbolo) => Text.Replace(estado, simbolo, " ")),
        Limpo = fnLimparTexto(SemPontuacao)
    in
        " " & Limpo & " "
