object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 659
  ClientWidth = 1088
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Image1: TImage
    Left = 0
    Top = 2
    Width = 497
    Height = 335
    Stretch = True
  end
  object Image2: TImage
    Left = 0
    Top = 343
    Width = 497
    Height = 269
    Stretch = True
  end
  object Image3: TImage
    Left = 503
    Top = 2
    Width = 577
    Height = 335
    Stretch = True
  end
  object Memo1: TMemo
    Left = 950
    Top = 16
    Width = 130
    Height = 57
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
    Visible = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 618
    Width = 1088
    Height = 41
    Align = alBottom
    TabOrder = 1
    ExplicitLeft = 96
    ExplicitTop = 392
    ExplicitWidth = 185
    object btnAbrirCSV: TButton
      Left = 757
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Abrir CSV'
      TabOrder = 0
      OnClick = btnAbrirCSVClick
    end
  end
  object Memo2: TMemo
    Left = 948
    Top = 143
    Width = 132
    Height = 57
    Lines.Strings = (
      'Memo1')
    TabOrder = 2
    Visible = False
  end
  object Memo3: TMemo
    Left = 948
    Top = 79
    Width = 132
    Height = 58
    Lines.Strings = (
      'Memo1')
    TabOrder = 3
    Visible = False
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.csv'
    Filter = 'Arquivos CSV (*.csv)|*.csv'
    Left = 1016
    Top = 248
  end
end
