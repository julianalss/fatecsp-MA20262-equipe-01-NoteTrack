// cad_Etapa2 -- lista tudo o que existe no arquivo da Etapa 2 (abas e tabelas)
let
    Fonte = Excel.Workbook(File.Contents(pArquivoEtapa2), null, true)
in
    Fonte
