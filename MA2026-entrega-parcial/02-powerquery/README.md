Etapa 2 – Power Query

Arquivo: NoteTrack_02_PowerQuery.xlsx

Na Etapa 1 a limpeza foi feita com fórmulas, olhando anúncio por anúncio. Aqui a gente fez a mesma coisa no Power Query, de forma automática: as consultas leem o CSV da coleta, aplicam as regras e entregam as tabelas prontas para análise. Se chegar uma coleta nova, basta colocar o arquivo na pasta e clicar em Atualizar Tudo.

As regras não estão escritas nas consultas. Elas vêm do arquivo da Etapa 1: palavras-chave, termos, limite de 40%, mínimo de 5 anúncios e data da coleta. Assim, se a equipe mudar uma regra, muda num lugar só.


Como abrir

O Power Query lê duas coisas:

- a pasta da coleta, NoteTrack/dados_brutos/anuncios, onde fica o Notebooks 2025.csv (parâmetro pPastaAnuncios);
- o arquivo da Etapa 1, 01-excel/NoteTrack_01_Excel.xlsx (parâmetro pArquivoEtapa1).

Os dois parâmetros guardam o caminho completo do computador onde o arquivo foi montado. Em outro computador, abra Dados → Consultas e Conexões, ajuste os dois caminhos e clique em Atualizar Tudo.

Para montar do zero, abra uma pasta de trabalho em branco, importe a macro MontarConsultas.bas (Alt + F11 → Arquivo → Importar) e rode MontarConsultasNoteTrack. Ela cria as 37 consultas na ordem do arquivo scripts_m/_ordem.txt. O código de cada consulta está em scripts_m/.


O que as consultas fazem

1. Leem a coleta em UTF-8, o que já resolve os acentos estragados da Etapa 1, e convertem o preço de texto ("R$ 17.990,00") para número.
2. Tiram do título o processador, a RAM, o armazenamento e a placa de vídeo, usando as mesmas tabelas de termos da Etapa 1.
3. Aplicam as regras e separam os anúncios em duas tabelas: fAnuncios, com os que entram na análise, e Rejeitados, com os que saíram e o motivo.
4. Montam as tabelas de apoio: modelos (dModelo), processadores (dCPU), RAM (dRAM) e placas de vídeo (dGPU).
5. Conferem o resultado na aba Conferencia.

Cada anúncio que sai fica registrado com o primeiro motivo que o tirou, nesta ordem: repetido, outro modelo, modelo de 2026, recondicionado, caixa aberta, preço fora da média e modelo com poucos anúncios.


As 37 consultas

No editor do Power Query, as consultas estão separadas em seis grupos, na ordem em que os dados passam por elas.

Grupo 01_Parametros:

- pPastaAnuncios: pasta onde ficam os CSVs da coleta.
- pArquivoEtapa1: caminho do arquivo da Etapa 1.
- pLimiteDesvio: quanto o preço pode se afastar da média do modelo. Valor atual: 0,4 (40%).
- pMinAnuncios: mínimo de anúncios para o modelo entrar na análise. Valor atual: 5.
- pDataColeta: data da coleta. Valor atual: 23/09/2026.

Os três últimos são lidos da tabela Tab_Parametros da Etapa 1, então mudam quando ela muda.

Grupo 02_Funcoes:

- fnLerCsv: lê um CSV da coleta em UTF-8, o que já conserta os acentos.
- fnPadronizarColunas: deixa as colunas com o nome e a ordem esperados.
- fnLerAnuncios: lê, padroniza e numera as linhas de um arquivo da coleta.
- fnLimparTexto: tira espaços sobrando, como o ARRUMAR da Etapa 1.
- fnTextoBusca: prepara o título para a busca de termos (minúsculas, sem pontuação).
- fnPreco: converte " R$ 17.990,00 " em 17990.
- fnExtrairTermo: acha no título o termo de processador, RAM, armazenamento ou placa de vídeo.
- fnCodAnuncio: tira da URL o código do anúncio (MLB...).

Grupo 03_Cadastros:

- cad_Etapa1: abre o arquivo da Etapa 1.
- cad_Parametros, cad_DeParaModelo, cad_ChavesModelo, cad_ForaRecorte, cad_CPU, cad_RAM, cad_Armazenamento e cad_GPU: as tabelas da aba Cadastros da Etapa 1.
- ColunasAlvo: as colunas que a coleta deve ter.
- DeParaColunas: outros nomes que uma coleta futura pode usar para as mesmas colunas.

Grupo 04_Preparacao:

- stg_Anuncios_Bruto: junta todos os CSVs da pasta numa tabela só.
- stg_Anuncios_Novos: guarda os anúncios únicos, do modelo pesquisado, de 2025 e novos.
- stg_PrecoRef: calcula o preço de referência de cada modelo para a regra dos 40%.

Grupo 05_Saida (carregadas em planilhas):

- fAnuncios: os 76 anúncios que entram na análise.
- Rejeitados: os 291 que saíram, cada um com o motivo.
- dModelo, dCPU, dRAM e dGPU: modelos, processadores, quantidades de RAM e placas de vídeo.

Grupo 06_Conferencia (carregadas na aba Conferencia):

- Conf_Reconciliacao: lidas = aceitas + rejeitadas, com a diferença.
- Conf_Motivos: quantos anúncios saíram por cada motivo.
- Conf_Colunas: colunas da coleta que não foram reconhecidas (fica vazia).
- Conf_Modelos: anúncios e preço médio por modelo, para comparar com a Etapa 1.


Resultado

Dos 367 anúncios lidos, 76 ficaram para a análise e 291 saíram:

- 233 eram de outro modelo;
- 49 eram repetidos;
- 4 eram recondicionados;
- 2 eram de caixa aberta;
- 2 eram de um modelo com poucos anúncios (Dell Pro 14 Premium);
- 1 era do MacBook Pro com M5 Max, lançado em 2026.

Nenhum saiu por preço fora da média: os 2 casos que a Etapa 1 marcou já tinham saído como repetidos.

Por que só 4 recondicionados aqui, se a Etapa 1 achou 93? Porque cada anúncio aparece com um motivo só. A maioria dos recondicionados também era de outro modelo ou repetida, e saiu antes por esse motivo.

Preço médio por modelo:

- Acer Predator Helios Neo 16 AI: R$ 16.621,86 (7 anúncios)
- Apple MacBook Pro 14 M5: R$ 16.385,78 (9 anúncios)
- Lenovo ThinkPad T14 Gen 6: R$ 11.850,00 (9 anúncios)
- Apple MacBook Air 13 M4: R$ 11.511,46 (13 anúncios)
- Dell Pro 14: R$ 9.446,80 (5 anúncios)
- ASUS Zenbook A14: R$ 8.725,58 (33 anúncios)

O preço médio geral é de R$ 11.253,97. São os mesmos preços que a Etapa 1 calculou com fórmulas.

A pasta dados_limpos/ tem essas tabelas em CSV, para quem quiser conferir sem abrir o Excel.


Conferência

- A pasta inteira é lida: 367 linhas.
- Toda linha lida termina em fAnuncios ou em Rejeitados: 367 = 76 + 291.
- Nenhuma coluna da coleta ficou sem ser reconhecida.
- Os preços médios por modelo batem com os da Etapa 1.
- O arquivo não tem macro, relacionamento nem cálculo DAX. Isso fica para a Etapa 3.


Teste de reenvio da coleta

Em 01/11/2026 colocamos uma cópia do CSV na pasta da coleta, com outro nome (Notebooks 2025 - copia teste.csv), e clicamos em Atualizar Tudo.

O resultado foi 734 linhas lidas, 76 aceitas e 658 rejeitadas, com diferença 0. Os anúncios repetidos passaram de 49 para 416 (os 49 de antes mais os 367 da cópia), e os preços por modelo não mudaram. Ou seja, se alguém mandar a mesma coleta duas vezes, nada entra em dobro.

Depois apagamos a cópia, atualizamos de novo e voltaram os 367, 76 e 291.


Capturas de tela (pasta evidencias/)

- etapa2_conferencia.png: a aba Conferencia.
- painel_consultas.png: o painel de consultas com os seis grupos.
- etapas_aplicadas_fAnuncios.png: os passos aplicados da consulta fAnuncios.
- teste_reenvio_csv.png: a aba Conferencia durante o teste de reenvio.
