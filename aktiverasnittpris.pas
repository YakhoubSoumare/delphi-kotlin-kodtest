unit AktiveraSnittpris;

interface
// Multi Lang ver 3

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, LMDCustomControl, LMDCustomPanel, LMDCustomBevelPanel,
  LMDCustomParentPanel, LMDCustomGroupBox, LMDGroupBox, DB, WAUniDac,
  ComCtrls, IniFiles, Printers, LMDControl, MemDS, DBAccess, Uni;

type
  TAktiveraSnittprisFrm = class(TForm)
    LMDGroupBox1: TLMDGroupBox;
    AktiveraSnittpriserBtn: TButton;
    AvbrytBtn: TButton;
    TestaInkopspriserBtn: TButton;
    LagerQ: TWAUniQuery;
    LagerRE: TRichEdit;
    SkrivUtBtn: TButton;
    AntalArtiklarLbl: TLabel;
    TotAntalArtiklarLbl: TLabel;
    procedure FormShow(Sender: TObject);
    procedure AvbrytBtnClick(Sender: TObject);
    procedure AktiveraSnittpriserBtnClick(Sender: TObject);
    procedure TestaInkopspriserBtnClick(Sender: TObject);
    procedure SkrivUtBtnClick(Sender: TObject);
  private
    function AddBlanks(S: string; Antal, Typ: integer): string;
  public
    AvbrytF: boolean;
    procedure InitFrmTxt;
    constructor Create(AOwner: TComponent); override;
  end;

var
  AktiveraSnittprisFrm: TAktiveraSnittprisFrm;

const
  alRIGHT = 0;
  alLEFT = 1;

implementation

uses
  WAFWOversattning,
  DModule,
  Utils,
  Utils.Dialogs,
  Vanta,
  Snurra,
  PPrinter,
  SQLDM_Generell;

{$R *.dfm}

procedure TAktiveraSnittprisFrm.FormShow(Sender: TObject);
begin
  AvbrytF := True;
  LagerQ.Databasename := Data2Path;
  LagerRE.Clear;
  AntalArtiklarLbl.Caption := '';
  TotAntalArtiklarLbl.Caption := '';
end;

procedure TAktiveraSnittprisFrm.AvbrytBtnClick(Sender: TObject);
begin
// Avbryt
  Close;
end;

procedure TAktiveraSnittprisFrm.AktiveraSnittpriserBtnClick(Sender: TObject);
var
  ArtMK,
  MK,
  RK,
  VG,
  PG,
  Brutto,
  Netto: string;
  AssistIni: TIniFile;
  Antal: integer;
  Datum: string;
  Tid: string;
  LagerStatus: integer;
begin
// AktiveraSnittpriserBtn
  if AskRequest(L_(168, 'Aktivera Snittpriser?'), L_(169, 'Snittpriser'), False) then
  begin
    Antal := 0;
    DateTimeToString(Datum, Datumformat, Date);
    DateTimeToString(Tid, 'hh:mm', Now);
    with DM.Lager do
    begin
      OrderFields := 'mk';
      Open;	
      with SnurraFrm do
      begin
        TitelLbl.Caption := L_(171, 'Aktiverar Snittpriser...!');
        ProgressBar.Position := 0;
        ProgressBar.Max := DM.Lager.RecordCount;
        Show;
        Application.ProcessMessages;
      end;
      while not EOF do
      begin
        ArtMK := FieldByName('ARTIKELMK').AsString;
        LagerStatus := StrToIntDef(FieldByName('LGRSTATUS').AsString, 0);
        with DM.Artiklar do
        begin
          if LocateSQL(['artikelmk'], [ArtMK]) then
          begin
            MK := FieldByName('MK').AsString;
            RK := DM.Artiklar.FieldByName('RABATTKOD').AsString;
            VG := DM.Artiklar.FieldByName('VARUGRUPP').AsString;
            PG := DM.Artiklar.FieldByName('PRODGRUPP').AsString;
            if DM.Artiklar.FieldByName('FASTPRIS').AsBoolean then
            begin
              Brutto := DM.Artiklar.FieldByName('PRIS').AsString;
              Netto := DM.Artiklar.FieldByName('INKOP').AsString;
            end
            else if DM.Artiklar.FieldByName('USENETTO').AsBoolean then
            begin
              Brutto := DM.Artiklar.FieldByName('VNETTO').AsString;
              Netto := GetInkopsprisVNetto(Brutto, MK, RK, VG, PG);
            end
            else
            begin
              Brutto := FieldByName('PRIS').AsString;
              Netto := GetInkopsPris(Brutto, MK, RK, PG, VG);
            end;
            Inc(Antal);
            IsFloatStr(Netto);
            IsFloatStr(Brutto);
            Edit;
            FieldByName(cSENINKOPSPRIS).AsString := Netto;
            FieldByName(cSNITTPRIS).AsString := Netto;
            Post;
//            if (LagerStatus = lgrJA) or (LagerStatus = lgrHEMTAGEN) or (LagerStatus = lgrUTGAENDE) or (LagerStatus = lgrAVSKRIVEN) then
            begin
              with DM.LagerOms do
              begin
                Append;
                FieldByName('ARTIKELMK').AsString := DM.Artiklar.FieldByName('ARTIKELMK').AsString;
                FieldByName('ARTIKELNR').AsString := DM.Artiklar.FieldByName('ARTIKELNR').AsString;
                FieldByName('MK').AsString := DM.Artiklar.FieldByName('MK').AsString;
                FieldByName('DATUM').AsString := Datum;
                FieldByName('TID').AsString := Tid;
                FieldByName('ANTAL').AsString := NullString;
                FieldByName('SALDO').AsString := DM.Lager.FieldByName('LAGERANTAL').AsString;
                FieldByName('NETTO').AsString := Netto;
                FieldByName('SNITT').AsString := Netto;
                FieldByName('BRUTTO').AsString := Brutto;
                FieldByName('LGRPLATS1').AsString := DM.Lager.FieldByName('LGRPLATS1').AsString;
                FieldByName('LGRPLATS2').AsString := DM.Lager.FieldByName('LGRPLATS1').AsString;
                FieldByName('LGRSTATUS').AsString := DM.Lager.FieldByName('LGRSTATUS').AsString;
                FieldByName('KOD').AsString :=  omsSNITTPRISER;
                FieldByName('ANVANDARE').AsString := getSerializedUserName();
                Post;
              end;
            end;
          end;
        end;
        with SnurraFrm do
        begin
          ProgressBar.Position := ProgressBar.Position + 1;
          Application.ProcessMessages;
        end;
        Next;
      end;
      Close;
      OrderFields := ''; 
    end;
    SnurraFrm.Close;
    DM.Artiklar.Close;
    gUseSnittPris := True;
    gInveteringMinDatum := Date;

    SQLDMGenerell.WriteSnittpriserSettingsToGlobalsData();

    AssistIni := TIniFile.Create(IniPath + 'Assist.Ini');
    with AssistIni do
    begin
      WriteInteger('Beteende', 'InventMinDatum', Trunc(gInveteringMinDatum));
      WriteBool('Beteende', 'AnvändSnittpriser', gUseSnittPris);
      UpDateFile;
    end;
    AssistIni.Free;
    TDialogUtils.VisaInfo(Format(L_(194, 'Antal aktiverade artiklar med snittpriser: %d   '), [Antal]), False);
    AvbrytF := False;
    Close;
  end;
end;

procedure TAktiveraSnittprisFrm.TestaInkopspriserBtnClick(Sender: TObject);
var
  ArtMK,
  ArtNr,
  Typ,
  Kod,
  MK,
  RK,
  VG,
  PG,
  Benamning,
  Brutto,
  Netto: string;
  TaMed: boolean;
  Antal: integer;
  LgrStatus: integer;
begin
// Testa Inköpspriser
  Screen.Cursor := crHourGlass;
  Antal := 0;
  LagerRE.Clear;
  AntalArtiklarLbl.Caption := '';
  TotAntalArtiklarLbl.Caption := '';
  gAktuellInkopsrabatt := 1;
  with DM.Lager do
  begin
    OrderFields := 'mk';
    Open;
    while not EOF do
    begin
      ArtMK := FieldByName('ARTIKELMK').AsString;
      LgrStatus := FieldByName('LGRSTATUS').AsInteger;
      TaMed := False;
      if (LgrStatus = lgrJA) or (LgrStatus = lgrHEMTAGEN) or (LgrStatus = lgrUTGAENDE) then
      begin
        with DM.Artiklar do
        begin
          if LocateSQL(['artikelmk'], [ArtMK]) then
          begin
            Inc(Antal);
            ArtNr := FieldByName('ARTIKELNR').AsString;
            MK := FieldByName('MK').AsString;
            Benamning := FieldByName('BENAMNING1').AsString;
            RK := DM.Artiklar.FieldByName('RABATTKOD').AsString;
            VG := DM.Artiklar.FieldByName('VARUGRUPP').AsString;
            PG := DM.Artiklar.FieldByName('PRODGRUPP').AsString;
            if DM.Artiklar.FieldByName('FASTPRIS').AsBoolean then
            begin
              Typ := 'F';
              Kod := 'IS';
              Brutto := DM.Artiklar.FieldByName('PRIS').AsString;
              Netto := DM.Artiklar.FieldByName('INKOP').AsString;
              TaMed := Netto = '';
            end
            else if DM.Artiklar.FieldByName('USENETTO').AsBoolean then
            begin
              Typ := 'V';
              Brutto := DM.Artiklar.FieldByName('VNETTO').AsString;
              Netto := GetInkopsprisVNetto(Brutto, MK, RK, VG, PG);
              IsFloatStr(Brutto);
              IsFloatStr(Netto);
              TaMed := (RK = '') or (StrToFloat(Netto) >= StrToFloat(Brutto));
              if RK = '' then
                Kod := 'RS'
              else
                Kod := 'RV';
            end
            else
            begin
              Typ := 'B';
              Brutto := FieldByName('PRIS').AsString;
              Netto := GetInkopsPris(Brutto, MK, RK, PG, VG);
              IsFloatStr(Brutto);
              IsFloatStr(Netto);
              TaMed := (RK = '') or (StrToFloat(Netto) >= StrToFloat(Brutto));
              if RK = '' then
                Kod := 'RS'
              else
                Kod := 'RV';
            end;
            IsFloatStr(Netto);
            IsFloatStr(Brutto);
          end
          else
          begin
            ArtNr := DM.Lager.FieldByName('ARTIKELNR').AsString;
            MK := DM.Lager.FieldByName('MK').AsString;
            Benamning := L_(199, 'SAKNAS I ARTIKELREGISTER!!');
            Typ := '';
            Kod := '';
            RK := '';
            Brutto := '';
            Netto := '';
            TaMed := True;
          end;
        end;
      end;
      if TaMed then
      begin
        Typ := AddBlanks(Typ, 4, alLEFT);
        Kod := AddBlanks(Kod, 4, alLEFT);
        ArtNr := AddBlanks(ArtNr, 18, alLEFT);
        MK := AddBlanks(MK, 5, alLEFT);
        RK := AddBlanks(RK, 5, alLEFT);
        Benamning := AddBlanks(Benamning, 30, alLEFT);
        Netto := AddBlanks(Netto, 10, alRIGHT);
        Brutto := AddBlanks(Brutto, 10, alRIGHT);
        LagerRE.Lines.Add(Typ+Kod+ArtNr+MK+RK+Benamning+Netto+Brutto);
        Application.ProcessMessages;
      end;
      Next;
    end;
    Close;
    OrderFields := ''; 
  end;
  DM.Artiklar.Close;
  LagerRE.Lines.Add('');
  LagerRE.Lines.Add(L_(200, 'Typer:'));
  LagerRE.Lines.Add(L_(201, 'B = Inköpspris beräknat på rabattkod mot bruttopris'));
  LagerRE.Lines.Add(L_(202, 'V = Inköpspris beräknat på rabattkod mot verkstadsnetto'));
  LagerRE.Lines.Add(L_(203, 'F = Fast inköpspris'));

  LagerRE.Lines.Add('');
  LagerRE.Lines.Add(L_(204, 'Koder:'));
  LagerRE.Lines.Add(L_(205, 'IS = Inköpspris saknas'));
  LagerRE.Lines.Add(L_(206, 'RS = Rabattkod saknas'));
  LagerRE.Lines.Add(L_(207, 'RV = Rabattkod saknar värde'));

  Typ := AddBlanks('Typ', 4, alLEFT);
  Kod := AddBlanks('Kod', 4, alLEFT);
  ArtNr := AddBlanks(L_(37, 'Artikelnr'), 18, alLEFT);
  MK := AddBlanks('MK', 5, alLEFT);
  RK := AddBlanks('RK', 5, alLEFT);
  Benamning := AddBlanks(L_(98, 'Benämning'), 30, alLEFT);
  Netto := AddBlanks(L_(209, 'Inköp'), 10, alRIGHT);
  Brutto := AddBlanks(L_(102, 'Pris'), 10, alRIGHT);
  LagerRE.Lines.Insert(0, '--------------------------------------------------------------------------------------');
  LagerRE.Lines.Insert(0, Typ+Kod+ArtNr+MK+RK+Benamning+Netto+Brutto);
  LagerRE.SelStart := 1;
  SkrivUtBtn.Enabled := LagerRE.Lines.Count > 2;
  AntalArtiklarLbl.Caption := Format(L_(210, 'Antal artiklar att bearbeta: %d'), [LagerRE.Lines.Count - 12]);
  TotAntalArtiklarLbl.Caption := Format(L_(211, 'Totalt antal artiklar i lager: %d'), [Antal]);
  Screen.Cursor := crDefault;
end;

function TAktiveraSnittprisFrm.AddBlanks(S: string; Antal, Typ: integer): string;
var
  i: integer;
begin
// AddBlanks
  Result := S;
  for i := 1 to Antal - Length(S) do
  begin
    if Typ = alLEFT then
      Result := Result + #32
    else
      Result := #32 + Result;
  end;
end;

procedure TAktiveraSnittprisFrm.SkrivUtBtnClick(Sender: TObject);
begin
// Skriv Ut
  Printer.Printerindex := Printer.Printers.Indexof(GetPrinterName(gOvrigaListorPrn));
  SetBin(15, gBin[15], False);
  LagerRE.Print(L_(212, 'Inköpspriser Lager'));
end;

constructor TAktiveraSnittprisFrm.Create(AOwner: TComponent);
begin
  inherited;
  InitFrmTxt;  (* *)

end;

procedure TAktiveraSnittprisFrm.InitFrmTxt;  (* *)
begin
  Caption := L__(212, 'Inköpspriser lager');
  AntalArtiklarLbl.Caption:= L__(210, 'Antal artiklar att bearbeta:');
  TotAntalArtiklarLbl.Caption:= L__(211, 'Totalt antal artiklar i lager:');
  AktiveraSnittpriserBtn.Caption:= L__(168, 'Aktivera Snittpriser');
  AvbrytBtn.Caption:= L__(27, 'Avbryt');
  TestaInkopspriserBtn.Caption:= L__(213, 'Testa Inköpspriser');
  SkrivUtBtn.Caption:= L__(2223, 'Skriv &ut');
end;

end.
