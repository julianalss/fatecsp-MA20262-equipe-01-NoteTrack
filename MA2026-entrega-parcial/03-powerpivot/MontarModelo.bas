Attribute VB_Name = "MontarModelo"
'==============================================================================
' NoteTrack - Etapa 3 (Power Pivot e DAX)
' Monta NoteTrack_03_PowerPivot.xlsx a partir de uma pasta de trabalho EM BRANCO:
'  1. cria as consultas de scripts_m (lêem o arquivo da Etapa 2 pelo parâmetro pArquivoEtapa2);
'  2. carrega fAnuncios, dModelo, dCPU, dRAM, dGPU, Rejeitados e dCalendario SOMENTE no Modelo de Dados;
'  3. cria as 5 relações 1:N do modelo estrela e as medidas DAX (dax\medidas_preliminares.dax);
'  4. monta as abas Validacao (tabelas dinâmicas do modelo) e Conferencia (VALORCUBO x Etapa 2).
' Uso: salve a pasta em branco como 03-powerpivot\NoteTrack_03_PowerPivot.xlsx, feche o arquivo da
'      Etapa 2, Alt+F11 > Arquivo > Importar arquivo (este .bas) > F5 em MontarModeloNoteTrack.
' Depois: passos manuais na janela do Power Pivot (README, seção "Passos na janela do Power Pivot")
' e Salvar como .xlsx (o Excel avisa que o módulo VBA será descartado: Salvar e apagar recursos).
'==============================================================================
Option Explicit

Public Sub MontarModeloNoteTrack()
    Dim wb As Workbook, pasta As String, linhas() As String, i As Long
    Dim partes() As String, nome As String, formula As String, pEtapa2 As String

    Set wb = ActiveWorkbook
    pasta = wb.Path & "\scripts_m\"
    If Dir(pasta & "_ordem.txt") = "" Then
        MsgBox "Não encontrei " & pasta & "_ordem.txt. Salve este arquivo na pasta 03-powerpivot (com a subpasta scripts_m).", vbCritical
        Exit Sub
    End If
    pEtapa2 = InputBox("Caminho do arquivo da Etapa 2 (pArquivoEtapa2). Ele precisa estar FECHADO:", "NoteTrack - Etapa 3", _
                       Replace(wb.Path, "03-powerpivot", "02-powerquery") & "\NoteTrack_02_PowerQuery.xlsx")
    If pEtapa2 = "" Then Exit Sub
    If Dir(pEtapa2) = "" Then MsgBox "Arquivo não encontrado: " & pEtapa2, vbCritical: Exit Sub

    Application.ScreenUpdating = False
    wb.Queries.FastCombine = True   ' = Ignorar os Níveis de Privacidade (guia, seção 2.3)

    ' 1) consultas
    linhas = Split(Replace(LerUtf8(pasta & "_ordem.txt"), vbCr, ""), vbLf)
    For i = LBound(linhas) To UBound(linhas)
        If Trim(linhas(i)) <> "" Then
            partes = Split(linhas(i), ";")
            nome = partes(0)
            formula = LerUtf8(pasta & nome & ".pq")
            If nome = "pArquivoEtapa2" Then formula = TrocarTextoParametro(formula, pEtapa2)
            ApagarConsulta wb, nome
            wb.Queries.Add Name:=nome, Formula:=formula, Description:="Grupo " & partes(1)
        End If
    Next i
    ' 2) carga somente no Modelo de Dados
    For i = LBound(linhas) To UBound(linhas)
        If Trim(linhas(i)) <> "" Then
            partes = Split(linhas(i), ";")
            If partes(2) = "modelo" Then AdicionarAoModelo wb, partes(0)
        End If
    Next i

    ' 3) relações N:1 (fato -> dimensão)
    On Error GoTo FalhaRel
    With wb.Model
        .ModelRelationships.Add .ModelTables("fAnuncios").ModelTableColumns("Cod_Modelo"), .ModelTables("dModelo").ModelTableColumns("Cod_Modelo")
        .ModelRelationships.Add .ModelTables("fAnuncios").ModelTableColumns("CPU_Padrao"), .ModelTables("dCPU").ModelTableColumns("CPU_Padrao")
        .ModelRelationships.Add .ModelTables("fAnuncios").ModelTableColumns("RAM"), .ModelTables("dRAM").ModelTableColumns("RAM")
        .ModelRelationships.Add .ModelTables("fAnuncios").ModelTableColumns("GPU_Padrao"), .ModelTables("dGPU").ModelTableColumns("GPU_Padrao")
        .ModelRelationships.Add .ModelTables("fAnuncios").ModelTableColumns("Data_Coleta"), .ModelTables("dCalendario").ModelTableColumns("Data")
    End With
    On Error GoTo 0

    ' 4) medidas (todas na tabela fAnuncios)
    CriarMedida wb, "Soma Preços", "SUMX ( fAnuncios, fAnuncios[Preco_BRL] )", "moeda", "Quanto somam os preços anunciados no recorte? (medida de volume; base do preço médio)"
    CriarMedida wb, "Qtd Anúncios", "DISTINCTCOUNT ( fAnuncios[ID_Anuncio] )", "inteiro", "Quantos anúncios válidos existem no recorte? (contagem distinta pelo código do anúncio)"
    CriarMedida wb, "Preço Médio", "DIVIDE ( [Soma Preços], [Qtd Anúncios] )", "moeda", "Quanto custa, em média, um notebook do recorte? (KPI central do projeto)"
    CriarMedida wb, "Preço Mínimo", "MIN ( fAnuncios[Preco_BRL] )", "moeda", "Qual o anúncio mais barato do recorte?"
    CriarMedida wb, "Preço Máximo", "MAX ( fAnuncios[Preco_BRL] )", "moeda", "Qual o anúncio mais caro do recorte?"
    CriarMedida wb, "Preço Médio Geral", "CALCULATE ( [Preço Médio], ALL ( fAnuncios ) )", "moeda", "Qual o preço médio de todos os anúncios, ignorando os filtros? (referência para comparar)"
    CriarMedida wb, "Variação vs Média Geral %", "DIVIDE ( [Preço Médio] - [Preço Médio Geral], [Preço Médio Geral] )", "porcentagem", "Quanto o recorte está acima (+) ou abaixo (-) da média geral?"
    CriarMedida wb, "Qtd Modelos", "DISTINCTCOUNT ( fAnuncios[Cod_Modelo] )", "inteiro", "Quantos modelos aparecem no recorte?"
    CriarMedida wb, "RAM Total (GB)", "SUMX ( fAnuncios, RELATED ( dRAM[RAM_GB] ) )", "inteiro", "Quantos GB de RAM somam os anúncios do recorte? (busca RAM_GB no cadastro dRAM pelo relacionamento)"
    CriarMedida wb, "Preço por GB de RAM", "DIVIDE ( CALCULATE ( [Soma Preços], dRAM[RAM_GB] > 0 ), [RAM Total (GB)] )", "moeda", "Quanto se paga por GB de memória? (só anúncios com a RAM identificada)"
    CriarMedida wb, "Preço Médio GPU Dedicada", "CALCULATE ( [Preço Médio], fAnuncios[GPU_Tipo] = ""Dedicada"" )", "moeda", "Quanto custa, em média, um notebook com placa de vídeo dedicada?"
    CriarMedida wb, "% Anúncios GPU Dedicada", "DIVIDE ( CALCULATE ( [Qtd Anúncios], fAnuncios[GPU_Tipo] = ""Dedicada"" ), [Qtd Anúncios] )", "porcentagem", "Que parte dos anúncios do recorte tem placa de vídeo dedicada?"
    CriarMedida wb, "Conf Linhas fAnuncios", "COUNTROWS ( fAnuncios )", "inteiro", "Conferência: linhas de fAnuncios no modelo (= aceitas na Etapa 2)"
    CriarMedida wb, "Conf Linhas Rejeitados", "COUNTROWS ( Rejeitados )", "inteiro", "Conferência: linhas de Rejeitados no modelo (= Etapa 2)"
    CriarMedida wb, "Conf Linhas Lidas", "[Conf Linhas fAnuncios] + [Conf Linhas Rejeitados]", "inteiro", "Conferência: aceitas + rejeitadas (= linhas lidas na Etapa 2)"
    CriarMedida wb, "Conf Anuncios sem Modelo", "COUNTROWS ( FILTER ( fAnuncios, ISBLANK ( RELATED ( dModelo[Modelo] ) ) ) ) + 0", "inteiro", "Integridade: anúncios sem modelo no cadastro (deve ser 0)"
    CriarMedida wb, "Conf Anuncios sem CPU", "COUNTROWS ( FILTER ( fAnuncios, ISBLANK ( RELATED ( dCPU[Fabricante] ) ) ) ) + 0", "inteiro", "Integridade: anúncios sem processador em dCPU (deve ser 0)"
    CriarMedida wb, "Conf Anuncios sem RAM", "COUNTROWS ( FILTER ( fAnuncios, ISBLANK ( RELATED ( dRAM[RAM] ) ) ) ) + 0", "inteiro", "Integridade: anúncios sem RAM em dRAM (deve ser 0)"
    CriarMedida wb, "Conf Anuncios sem GPU", "COUNTROWS ( FILTER ( fAnuncios, ISBLANK ( RELATED ( dGPU[Tipo_da_GPU] ) ) ) ) + 0", "inteiro", "Integridade: anúncios sem GPU em dGPU (deve ser 0)"
    CriarMedida wb, "Conf Anuncios sem Data", "COUNTROWS ( FILTER ( fAnuncios, ISBLANK ( RELATED ( dCalendario[Mes] ) ) ) ) + 0", "inteiro", "Integridade: anúncios com data fora do calendário (deve ser 0)"
    CriarMedida wb, "Conf PK Duplicada", "( COUNTROWS ( dModelo ) - DISTINCTCOUNT ( dModelo[Cod_Modelo] ) ) + ( COUNTROWS ( dCPU ) - DISTINCTCOUNT ( dCPU[CPU_Padrao] ) ) + ( COUNTROWS ( dRAM ) - DISTINCTCOUNT ( dRAM[RAM] ) ) + ( COUNTROWS ( dGPU ) - DISTINCTCOUNT ( dGPU[GPU_Padrao] ) ) + ( COUNTROWS ( dCalendario ) - DISTINCTCOUNT ( dCalendario[Data] ) )", "inteiro", "Integridade: chaves primárias repetidas nas dimensões (deve ser 0)"
    CriarMedida wb, "Conf ID Duplicado", "COUNTROWS ( fAnuncios ) - DISTINCTCOUNT ( fAnuncios[ID_Anuncio] )", "inteiro", "Integridade: o mesmo anúncio duas vezes na fato (deve ser 0)"
    CriarMedida wb, "Conf Dif Preco", "ROUND ( SUM ( fAnuncios[Preco_BRL] ) - [Soma Preços], 2 )", "moeda", "Conferência: a medida reproduz a coluna da Etapa 2 (deve ser 0)"

    ' 5) abas de validação e conferência
    MontarValidacao wb
    MontarConferencia wb
    Application.ScreenUpdating = True
    wb.Worksheets("Conferencia").Activate
    MsgBox "Modelo montado: " & wb.Model.ModelTables.Count & " tabelas, " & wb.Model.ModelRelationships.Count & _
           " relações, " & wb.Model.ModelMeasures.Count & " medidas." & vbCrLf & _
           "Confira a aba Conferencia (diferenças 0) e faça os passos na janela do Power Pivot (README).", vbInformation, "NoteTrack"
    Exit Sub
FalhaRel:
    Application.ScreenUpdating = True
    MsgBox "Falha ao criar os relacionamentos: " & Err.Description, vbExclamation
End Sub

Private Sub AdicionarAoModelo(wb As Workbook, nome As String)
    Dim c As WorkbookConnection
    For Each c In wb.Connections
        If c.Name = "Consulta - " & nome Then c.Delete: Exit For
    Next c
    ' CommandText = nome entre aspas + tipo 6: o Modelo de Dados usa o nome da consulta como nome da tabela
    wb.Connections.Add2 "Consulta - " & nome, "Conexão com a consulta '" & nome & "' na pasta de trabalho.", _
        "OLEDB;Provider=Microsoft.Mashup.OleDb.1;Data Source=$Workbook$;Location=" & nome & ";Extended Properties=""""", _
        Chr(34) & nome & Chr(34), 6, True, False
End Sub

Private Sub CriarMedida(wb As Workbook, nome As String, formula As String, formato As String, descricao As String)
    Dim fmt As Object, m As Object
    With wb.Model
        For Each m In .ModelMeasures
            If m.Name = nome Then m.Delete: Exit For
        Next m
        On Error Resume Next
        Select Case formato
            Case "moeda": Set fmt = .ModelFormatCurrency("R$", 2)
                          If Err.Number <> 0 Then Err.Clear: Set fmt = .ModelFormatDecimalNumber(True, 2)
            Case "porcentagem": Set fmt = .ModelFormatPercentageNumber(False, 1)
            Case "inteiro": Set fmt = .ModelFormatWholeNumber(True)
            Case Else: Set fmt = .ModelFormatDecimalNumber(True, 2)
        End Select
        Err.Clear
        .ModelMeasures.Add nome, .ModelTables("fAnuncios"), formula, fmt, descricao
        If Err.Number <> 0 Then
            ' Excel com separador de lista ";" (português): tenta de novo
            Err.Clear
            .ModelMeasures.Add nome, .ModelTables("fAnuncios"), Replace(formula, ",", ";"), fmt, descricao
        End If
        If Err.Number <> 0 Then
            ' formato recusado: cria com número decimal
            Err.Clear
            .ModelMeasures.Add nome, .ModelTables("fAnuncios"), formula, .ModelFormatDecimalNumber(True, 2), descricao
        End If
        If Err.Number <> 0 Then MsgBox "Não consegui criar a medida [" & nome & "]: " & Err.Description & vbCrLf & _
                                       "Crie à mão (dax\medidas_preliminares.dax).", vbExclamation
        On Error GoTo 0
    End With
End Sub

Private Sub MontarValidacao(wb As Workbook)
    Dim ws As Worksheet
    Set ws = ObterPlanilha(wb, "Validacao")
    ws.Cells.Clear
    ws.Range("A1").Value = "Validação - preço médio por modelo e mês da coleta (fonte: Modelo de Dados)"
    ws.Range("A1").Font.Bold = True: ws.Range("A1").Font.Size = 13
    NovaTabelaDinamica wb, ws.Range("A3"), "TD_Validacao", Array("[dModelo].[Modelo]"), Array("[dCalendario].[NomeMes]"), _
        Array("[Measures].[Preço Médio]")
    ws.Range("A13").Value = "Processador: anúncios, preço médio e variação contra a média geral"
    ws.Range("A13").Font.Bold = True
    NovaTabelaDinamica wb, ws.Range("A14"), "TD_Processador", Array("[dCPU].[Fabricante]", "[dCPU].[CPU_Padrao]"), Array(), _
        Array("[Measures].[Qtd Anúncios]", "[Measures].[Preço Médio]", "[Measures].[Variação vs Média Geral %]")
    ws.Range("H2").Value = "Memória RAM"
    ws.Range("H2").Font.Bold = True
    NovaTabelaDinamica wb, ws.Range("H3"), "TD_RAM", Array("[dRAM].[RAM]"), Array(), _
        Array("[Measures].[Qtd Anúncios]", "[Measures].[Preço Médio]", "[Measures].[Preço por GB de RAM]")
    ws.Range("H13").Value = "Tipo de GPU"
    ws.Range("H13").Font.Bold = True
    NovaTabelaDinamica wb, ws.Range("H14"), "TD_GPU", Array("[dGPU].[Tipo_da_GPU]"), Array(), _
        Array("[Measures].[Qtd Anúncios]", "[Measures].[Preço Médio]", "[Measures].[Variação vs Média Geral %]")
    ws.Columns("A:M").AutoFit
End Sub

Private Sub NovaTabelaDinamica(wb As Workbook, destino As Range, nome As String, linhas As Variant, colunas As Variant, valores As Variant)
    Dim pc As PivotCache, pt As PivotTable, k As Long
    Set pc = wb.PivotCaches.Create(SourceType:=xlExternal, SourceData:=wb.Connections("ThisWorkbookDataModel"))
    Set pt = pc.CreatePivotTable(TableDestination:=destino, TableName:=nome)
    pt.ManualUpdate = True
    For k = LBound(linhas) To UBound(linhas)
        pt.CubeFields(linhas(k)).Orientation = xlRowField
    Next k
    For k = LBound(colunas) To UBound(colunas)
        pt.CubeFields(colunas(k)).Orientation = xlColumnField
    Next k
    For k = LBound(valores) To UBound(valores)
        pt.AddDataField pt.CubeFields(valores(k))
    Next k
    pt.RowAxisLayout xlTabularRow
    pt.ManualUpdate = False
End Sub

Private Sub MontarConferencia(wb As Workbook)
    Dim ws As Worksheet
    Set ws = ObterPlanilha(wb, "Conferencia")
    ws.Cells.Clear
    ws.Range("A1:D1").Value = Array("Indicador", "Etapa 2 (referência)", "Modelo (Etapa 3)", "Diferença")
    ws.Range("A1:D1").Font.Bold = True
    ' coluna B: valores lidos na aba Conferencia e na tabela fAnuncios da Etapa 2
    ws.Range("A2").Value = "Soma de Preco_BRL (fAnuncios)": ws.Range("B2").Value = 855302.0
    ws.Range("C2").Formula = "=CUBEVALUE(""ThisWorkbookDataModel"",""[Measures].[Soma Preços]"")"
    ws.Range("D2").Formula = "=ROUND(C2-B2,2)"
    ws.Range("A3").Value = "Linhas aceitas (fAnuncios)": ws.Range("B3").Value = 76
    ws.Range("C3").Formula = "=CUBEVALUE(""ThisWorkbookDataModel"",""[Measures].[Conf Linhas fAnuncios]"")"
    ws.Range("D3").Formula = "=ROUND(C3-B3,2)"
    ws.Range("A4").Value = "Linhas rejeitadas": ws.Range("B4").Value = 291
    ws.Range("C4").Formula = "=CUBEVALUE(""ThisWorkbookDataModel"",""[Measures].[Conf Linhas Rejeitados]"")"
    ws.Range("D4").Formula = "=ROUND(C4-B4,2)"
    ws.Range("A5").Value = "Linhas lidas": ws.Range("B5").Value = 367
    ws.Range("C5").Formula = "=CUBEVALUE(""ThisWorkbookDataModel"",""[Measures].[Conf Linhas Lidas]"")"
    ws.Range("D5").Formula = "=ROUND(C5-B5,2)"
    ws.Range("A6").Value = "Anúncios distintos": ws.Range("B6").Value = 76
    ws.Range("C6").Formula = "=CUBEVALUE(""ThisWorkbookDataModel"",""[Measures].[Qtd Anúncios]"")"
    ws.Range("D6").Formula = "=ROUND(C6-B6,2)"
    ws.Range("A7").Value = "Modelos em análise": ws.Range("B7").Value = 6
    ws.Range("C7").Formula = "=CUBEVALUE(""ThisWorkbookDataModel"",""[Measures].[Qtd Modelos]"")"
    ws.Range("D7").Formula = "=ROUND(C7-B7,2)"
    ws.Range("A8").Value = "Preço médio geral": ws.Range("B8").Value = 11253.97
    ws.Range("C8").Formula = "=CUBEVALUE(""ThisWorkbookDataModel"",""[Measures].[Preço Médio]"")"
    ws.Range("D8").Formula = "=ROUND(C8-B8,2)"
    ws.Range("A10").Value = "Medidas de integridade (todas devem ser 0)": ws.Range("A10").Font.Bold = True
    ws.Range("A11").Value = "Conf Anuncios sem Modelo"
    ws.Range("C11").Formula = "=CUBEVALUE(""ThisWorkbookDataModel"",""[Measures].[Conf Anuncios sem Modelo]"")"
    ws.Range("A12").Value = "Conf Anuncios sem CPU"
    ws.Range("C12").Formula = "=CUBEVALUE(""ThisWorkbookDataModel"",""[Measures].[Conf Anuncios sem CPU]"")"
    ws.Range("A13").Value = "Conf Anuncios sem RAM"
    ws.Range("C13").Formula = "=CUBEVALUE(""ThisWorkbookDataModel"",""[Measures].[Conf Anuncios sem RAM]"")"
    ws.Range("A14").Value = "Conf Anuncios sem GPU"
    ws.Range("C14").Formula = "=CUBEVALUE(""ThisWorkbookDataModel"",""[Measures].[Conf Anuncios sem GPU]"")"
    ws.Range("A15").Value = "Conf Anuncios sem Data"
    ws.Range("C15").Formula = "=CUBEVALUE(""ThisWorkbookDataModel"",""[Measures].[Conf Anuncios sem Data]"")"
    ws.Range("A16").Value = "Conf PK Duplicada"
    ws.Range("C16").Formula = "=CUBEVALUE(""ThisWorkbookDataModel"",""[Measures].[Conf PK Duplicada]"")"
    ws.Range("A17").Value = "Conf ID Duplicado"
    ws.Range("C17").Formula = "=CUBEVALUE(""ThisWorkbookDataModel"",""[Measures].[Conf ID Duplicado]"")"
    ws.Range("A18").Value = "Conf Dif Preco"
    ws.Range("C18").Formula = "=CUBEVALUE(""ThisWorkbookDataModel"",""[Measures].[Conf Dif Preco]"")"
    ws.Range("B2:D2,B8:D8").NumberFormat = "#,##0.00"
    ws.Range("A1").ColumnWidth = 44: ws.Columns("B:D").ColumnWidth = 20
    With ws.Range("D2:D8,C11:C18").FormatConditions
        .Delete
        .Add(xlCellValue, xlEqual, "=0").Interior.Color = RGB(198, 239, 206)
        .Add(xlCellValue, xlNotEqual, "=0").Interior.Color = RGB(255, 199, 206)
    End With
End Sub

Private Function ObterPlanilha(wb As Workbook, nome As String) As Worksheet
    On Error Resume Next
    Set ObterPlanilha = wb.Worksheets(nome)
    On Error GoTo 0
    If ObterPlanilha Is Nothing Then
        If wb.Worksheets.Count = 1 And wb.Worksheets(1).UsedRange.Address = "$A$1" And IsEmpty(wb.Worksheets(1).Range("A1")) _
           And nome = "Validacao" Then
            Set ObterPlanilha = wb.Worksheets(1)
        Else
            Set ObterPlanilha = wb.Worksheets.Add(After:=wb.Worksheets(wb.Worksheets.Count))
        End If
        ObterPlanilha.Name = nome
    End If
End Function

Private Sub ApagarConsulta(wb As Workbook, nome As String)
    Dim q As WorkbookQuery
    For Each q In wb.Queries
        If q.Name = nome Then q.Delete: Exit Sub
    Next q
End Sub

' troca o texto entre as primeiras aspas do parâmetro: "C:\..." meta [...]
Private Function TrocarTextoParametro(formula As String, valor As String) As String
    Dim a As Long, b As Long
    a = InStr(1, formula, """")
    b = InStr(a + 1, formula, """")
    TrocarTextoParametro = Left(formula, a) & valor & Mid(formula, b)
End Function

Private Function LerUtf8(caminho As String) As String
    Dim st As Object
    Set st = CreateObject("ADODB.Stream")
    st.Type = 2: st.Charset = "utf-8": st.Open
    st.LoadFromFile caminho
    LerUtf8 = st.ReadText
    st.Close
End Function
