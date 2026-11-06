Modelo de dados – NoteTrack_03_PowerPivot.xlsx

Os dados vêm do arquivo da Etapa 2 (02-powerquery/NoteTrack_02_PowerQuery.xlsx), lido pelo parâmetro pArquivoEtapa2. Nada foi digitado nesta etapa.


Tabelas

- fAnuncios (fato): cada linha é um anúncio que entrou na análise. Chave: ID_Anuncio. 76 linhas.
- dModelo (dimensão): cada linha é um modelo analisado. Chave: Cod_Modelo. 6 linhas.
- dCPU (dimensão): cada linha é um processador. Chave: CPU_Padrao. 10 linhas.
- dRAM (dimensão): cada linha é uma quantidade de RAM. Chave: RAM. 4 linhas.
- dGPU (dimensão): cada linha é uma placa de vídeo. Chave: GPU_Padrao. 4 linhas.
- dCalendario (dimensão): cada linha é um dia de 2026. Chave: Data. 365 linhas.
- Rejeitados (auditoria): cada linha é um anúncio que saiu, com o motivo. Sem chave. 291 linhas.


Ligações

Todas são de muitos para um, ativas, com o filtro indo da dimensão para a fato.

1. fAnuncios[Cod_Modelo] com dModelo[Cod_Modelo]
2. fAnuncios[CPU_Padrao] com dCPU[CPU_Padrao]
3. fAnuncios[RAM] com dRAM[RAM]
4. fAnuncios[GPU_Padrao] com dGPU[GPU_Padrao]
5. fAnuncios[Data_Coleta] com dCalendario[Data]

dCalendario está marcada como tabela de datas. Os meses estão ordenados pelo número do mês, e a RAM pelo número de GB.

Os anúncios não têm data própria. Data_Coleta é a data em que a coleta foi feita (23/09/2026), definida na Etapa 1.

Rejeitados fica fora das ligações. Ela só é usada para conferir se todos os anúncios lidos foram para uma das duas tabelas.

O diagrama do modelo está no arquivo diagrama_modelo.png, nesta mesma pasta.
