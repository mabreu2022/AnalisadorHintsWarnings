# 🧠 Analisador de Hints e Warnings Delphi

Ferramenta para análise de projetos Delphi que coleta, organiza e exibe **Hints e Warnings** emitidos durante a compilação. Pode ser usada de duas formas:

- ✅ Console (`AnalisadorHints.exe`): gera relatórios em **HTML** e **CSV**
- 📊 Visual (`FerramentaVisual.exe`): carrega o CSV e exibe **gráficos interativos** via QuickChart.io

---

## 📦 Estrutura do Projeto

### `AnalisadorHints` (Console Delphi)

- Varre diretórios contendo arquivos `.dpr`
- Usa `dcc32` para compilar silenciosamente cada projeto
- Identifica e coleta mensagens do tipo:
  - `Hint Hxxxx`
  - `Warning Wxxxx`
- Gera dois arquivos:
  - `RelatorioCompleto.html`: visual com os detalhes por projeto
  - `RelatorioCompleto.csv`: dados prontos para Power BI ou análise posterior

### `ferramentavisual` (Aplicação VCL)

- Abre o `RelatorioCompleto.csv`
- Exibe **3 gráficos de pizza** com base nas colunas:
  - **Gráfico 1**: Percentual de Hints vs Warnings
  - **Gráfico 2**: Distribuição por TipoCompleto (`Hint H2077`, `Warning W1036`) com legenda à direita
  - **Gráfico 3**: Contagem de avisos por Projeto
- Usa `QuickChart.io` para renderizar os gráficos como imagens PNG
- Não requer bibliotecas externas nem conexão com Power BI

---

## 🚀 Como usar

### ⚙️ Console

```bash
AnalisadorHints.exe "C:\ProjetosDelphi" "C:\Relatorios"
