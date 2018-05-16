unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, ExtCtrls, ComCtrls, SPComm, SynHighlighterPas, uPSComponent,
  LazHelpCHM, Registry,windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button2: TButton;
    btnopencom: TButton;
    Button3: TButton;
    Button4: TButton;
    btnstoprec: TButton;
    Button5: TButton;
    Button6: TButton;
    Button8: TButton;
    Button9: TButton;
    CheckBox1: TCheckBox;
    cbRecHex: TCheckBox;
    cbsendHex: TCheckBox;
    chktop: TCheckBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Memo3: TMemo;
    Memo4: TMemo;
    Memo5: TMemo;
    Memo6: TMemo;
    Memo7: TMemo;
    Memo8: TMemo;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel13: TPanel;
    Panel14: TPanel;
    Panel15: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    TimeFlgChk: TCheckBox;
    CheckBox3: TCheckBox;
    chkauto: TCheckBox;
    chkcrc8: TCheckBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    ComboBox5: TComboBox;
    comlist: TComboBox;
    ComboBox2: TComboBox;
    combsecond: TComboBox;
    Comm1: TComm;
    Edit2: TEdit;
    Edit3: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label15: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    SaveDialog1: TSaveDialog;
    shpcom: TShape;
    StatusBar1: TStatusBar;
    tmsendauto: TTimer;
    TrackBar1: TTrackBar;
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnopencomClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure btnstoprecClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure chktopClick(Sender: TObject);
    procedure chkautoClick(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure ComboBox4Change(Sender: TObject);
    procedure ComboBox5Change(Sender: TObject);
    procedure comlistChange(Sender: TObject);
    procedure Comm1ModemStateChange(Sender: TObject; ModemEvent: DWORD);
    procedure Comm1ReceiveData(Sender: TObject; Buffer: Pointer;
      BufferLength: Word);
    procedure Edit3Change(Sender: TObject);
    procedure Edit3KeyPress(Sender: TObject; var Key: char);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure SendHex(S: String);
    procedure tmsendautoTimer(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);

  private
    { private declarations }
    FRXNum:int64;
    FTXNum:int64;
    bstop:boolean;
    procedure SendString(const str:string);
    procedure ShowStatus;
    procedure ShowRX;
    procedure ShowTX;

  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation


{$R *.lfm}

{ TForm1 }
var
  LogFile:string;

//接收1个字符，转换成功输出字符对应的数，转换失败输出-1
function hex(c:char):integer;
var
  x:integer;
begin
  //if c='' then
    //x:=0
  //else
  if (ord(c)>=ord('0'))and(ord(c)<=ord('9'))then
    x:=ord(c)-ord('0')
  else if (ord(c)>=ord('a'))and(ord(c)<=ord('f'))then
    x:=ord(c)-ord('a')+10
  else if (ord(c)>=ord('A'))and(ord(c)<=ord('F'))then
    x:=ord(c)-ord('A')+10
  else
    x:=-1;
    result:=x;
end;
function strtobcd(s:string):integer;

var
  tmpint1,tmpint2:integer;
begin
   if length(s)=1 then
   begin
    result:=hex(s[1]) ;
   end
   else
   begin
     if length(s)=2 then
     begin
      tmpint1:=hex(s[1]);
      tmpint2:=hex(s[2]);
      if (tmpint1=-1)or(tmpint2=-1) then
      begin
        result:=-1;
      end
      else
      begin
        result:=tmpint1*16+tmpint2;
      end;
     end
     else
       begin
         result:=-1;
       end;
   end;
end;
procedure GenerateCRC8(value:byte; var CrcValue:byte);
var
  CRC:word;
begin
  crc:= crcvalue xor value;
  crc:= crc xor (crc shl 1) xor (crc shl 2) xor (crc shl 3) xor (crc shl 4)
         xor (crc shl 5) xor (crc shl 6) xor (crc shl 7);
  crc:= (crc and $fe) xor ((crc shr 8) and $01);
  crcValue:= Crc;
end;

function GetCrc8(AStr: string; Count:integer):Byte;
var
  i:integer;
begin
  result:= 0;
  for i:= 1 to count do
    GenerateCRC8(ord(Astr[i]), result);
  result:= result xor $ff;
end;

function GetCrc8str(AStr: string):string;
var
 strsend,strtempsend:string;
 i,len,crc8:integer;
begin
     strsend :=AStr;
     len :=length(strsend);
     for i:=1 to len do
     begin
       if strsend[i]<>' 'then
       strtempsend:=strtempsend+ strsend[i] ;
     end;
     strsend:=strtempsend;
     strtempsend:='';
     len :=length(strsend);
     i:=1;
     while i<len do
     begin
       try
        strtempsend:=strtempsend + chr(strtobcd(copy(strsend,i,2)));
        i:=i+2;
       except
       end;
     end;
     strsend :=strtempsend;
     crc8 :=GetCrc8(strsend,length(strsend));
     result:=inttohex(crc8,2);
end;



procedure TForm1.SendHex(S: String);
var
  CRC8, s2:string;
  da:string;
  buf1:array[0..50000] of char;
  i:integer;
  len:integer;
begin
   if s = '' then
     exit;
  len:=0;
  s2:='';
  for i:=1 to  length(s) do
  begin
    if ((copy(s,i,1)>='0') and (copy(s,i,1)<='9'))or((copy(s,i,1)>='a') and (copy(s,i,1)<='f'))
        or((copy(s,i,1)>='A') and (copy(s,i,1)<='F')) then
    begin
        s2:=s2+copy(s,i,1);
    end;
  end;

   if chkcrc8.Checked then
   begin
     CRC8 :=GetCrc8str(s2);
     edit2.Text:= CRC8;
     s2 := s2 + CRC8;
   end;
   da := formatdatetime('mm-dd hh:mm:ss.zzz', now) + ' Tx: ';
  memo2.Lines.add( da + s2);
  for i:=0 to (length(s2) div 2-1) do
    buf1[i]:=char(strtoint('$'+copy(s2,i*2+1,2)));
  len:= length(s2) div 2;
  if Comm1.WriteCommData(buf1,len) then
  begin
      FTXNum:=FTXNum + len;
      ShowTX;
  end;
end;

procedure TForm1.SendString(const str: string);
begin
  if Comm1.WriteCommData(Pchar(str),Length(str))then
  begin
      FTXNum:=FTXNum+Length(str);
      ShowTX;
  end;
end;

procedure TForm1.tmsendautoTimer(Sender: TObject);
begin
  Button1CLICK(self);
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
   Form1.AlphaBlend :=true;
   label14.Caption:=IntToStr(TrackBar1.Position)+'%';
   Form1.AlphaBlendValue:=Byte(TrackBar1.Position*255 div TrackBar1.Max);
end;

//发送数据
procedure TForm1.Button1Click(Sender: TObject);
begin

   begin
     if cbsendHex.Checked then
       SendHex(Memo1.Text)   //发送十六进制
     else
       SendString(Memo1.Text);
   end;
end;
procedure TForm1.Button14Click(Sender: TObject);
begin
  form1.close;
end;

procedure TForm1.Button10Click(Sender: TObject);
begin
   SendHex(memo4.Text)   //发送十六进制
end;

procedure TForm1.Button11Click(Sender: TObject);
begin
   SendHex(memo5.Text)   //发送十六进制
end;

procedure TForm1.Button12Click(Sender: TObject);
begin
   SendHex(memo7.Text)   //发送十六进制
end;

procedure TForm1.Button13Click(Sender: TObject);
begin
   SendHex(memo8.Text)   //发送十六进制
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  memo1.Clear;
end;

procedure TForm1.ShowRX;
begin
  statusbar1.Panels[1].Text:='Rx:'+IntTostr(FRXNum);
end;
procedure TForm1.ShowTX;
begin
  statusbar1.Panels[2].Text:='Tx:'+IntTostr(FTXNum);
end;


procedure TForm1.ShowStatus;
begin
  if btnopencom.Caption = '关闭串口' then
  begin
    statusbar1.Panels[0].Text:=Format(' STATUS: %s Opened %s %s %s %s',[comlist.Text,
      {ComboBox2.Text,}IntToStr(Comm1.BaudRate),ComboBox4.Text,ComboBox3.Text,ComboBox5.Text]);
  end
  else statusbar1.Panels[0].Text:=' STATUS: COM Port Closed';
end;

procedure TForm1.btnopencomClick(Sender: TObject);
begin
  if btnopencom.Caption = '打开串口' then
  begin
    try
      Comm1.StartComm;

      shpcom.Brush.Color:=clred;
      shpcom.Pen.Color  :=clred;//clwhite;
      btnopencom.Caption :='关闭串口';
      ShowStatus;
     except on E:Exception do //拦截所有异常
     begin
      btnopencom.Caption :='打开串口';
      shpcom.Brush.Color:=clblack;
      shpcom.Pen.Color  :=clblack;//clwhite;
      Comm1.StopComm;
      showmessage('打开串口错误，错误信息：'+e.message);
     end;
    end;
 end
 else
 if btnopencom.Caption = '关闭串口' then
 begin
   Comm1.StopComm;
   shpcom.Brush.Color:=clblack;
   shpcom.Pen.Color  :=clwhite;
   btnopencom.Caption :='打开串口';
   ShowStatus;
 end;

end;




procedure TForm1.Button4Click(Sender: TObject);
begin
  memo2.Clear;
end;

procedure TForm1.btnstoprecClick(Sender: TObject);
begin
 if btnstoprec.Caption ='停止显示' then
 begin

   btnstoprec.Caption :='继续显示';
   bstop:=true;
 end
 else
 begin
   btnstoprec.Caption :='停止显示';
   bstop:=false;
 end;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  FRXNum:=0;
  FTXNum:=0;
  ShowRX;
  ShowTX;
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  textname: string;
begin
  SaveDialog1.DefaultExt := 'txt'; // 扩展名
  SaveDialog1.Filter := '*.txt|*.txt';
  if SaveDialog1.Execute then
  begin
    textname := SaveDialog1.FileName;
    if fileexists(textname) then // 文件是否存在
      if messagebox(0, pchar(textname + #13#10 + 'The same name already exists. Do you want to replace it?'),pchar('Save as'),
        MB_ICONWARNING + MB_YESNO) = mrNO then // 提示框
        exit;
    Memo2.Lines.SaveToFile(textname);
  end;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
   SendHex(memo3.Text)   //发送十六进制
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
   SendHex(memo6.Text)   //发送十六进制
end;

procedure TForm1.chktopClick(Sender: TObject);
begin
 if  chktop.Checked then
   form1.FormStyle:= fssystemstayontop
 else
     form1.FormStyle:= fsnormal;
end;

procedure TForm1.chkautoClick(Sender: TObject);
begin
 if chkauto.Checked = true then
 begin
   tmsendauto.Interval:=strtointdef(combsecond.Text,1000);
   tmsendauto.Enabled :=true;
 end
 else
 begin
   tmsendauto.Enabled :=false;
 end;

end;

procedure TForm1.ComboBox2Change(Sender: TObject);
var  BaudRate : Integer;
begin
  if ComboBox2.Text = 'Custom' then
    begin
      ComboBox2.Style := csDropDown;
      ComboBox2.SetFocus;
    end
  else begin
    if  ComboBox2.ItemIndex >0 then
      ComboBox2.Style := csDropDownList;
    if TryStrToInt(ComboBox2.Text,BaudRate) then
           Comm1.BaudRate := BaudRate;
  end;
  ShowStatus;
end;

procedure TForm1.ComboBox3Change(Sender: TObject);
begin
   //TByteSize = ( _5, _6, _7, _8 );
   Comm1.ByteSize :=  TByteSize(ComboBox3.ItemIndex);
   ShowStatus;
end;

procedure TForm1.ComboBox4Change(Sender: TObject);
begin
  //TParity = ( None, Odd, Even, Mark, Space );
  Comm1.Parity := TParity(ComboBox4.ItemIndex);
  ShowStatus;
end;

procedure TForm1.ComboBox5Change(Sender: TObject);
begin
  //TStopBits = ( _1, _1_5, _2 );
  Comm1.StopBits := TStopBits(ComboBox5.ItemIndex);
  ShowStatus;
end;

procedure TForm1.comlistChange(Sender: TObject);
begin
  Comm1.StopComm;
 try
  Comm1.CommName:=comlist.Text;
  comm1.StartComm;
  shpcom.Brush.Color:=clred;
  shpcom.Pen.Color  :=clwhite;
  btnopencom.Caption :='关闭串口';
  ShowStatus;
 except on E:Exception do
  begin
  shpcom.Brush.Color:=clblack;
  shpcom.Pen.Color  :=clwhite;
  Comm1.StopComm;
  ShowStatus;
  showmessage('打开串口错误，错误信息：'+e.message);
  btnopencom.Caption :='打开串口';
 end;
end;

end;

procedure TForm1.Comm1ModemStateChange(Sender: TObject; ModemEvent: DWORD);
begin

end;







function StrToHexStr(const S:string):string;
//字符串转换成16进制字符串
var
  I:Integer;
begin
  for I:=1 to Length(S) do
  begin
    if I=1 then
      Result:=IntToHex(Ord(S[1]),2) +' '
    else Result:=Result+IntToHex(Ord(S[I]),2)+' ';
  end;
end;

function StrPosCount(subs:string;source:string):integer;
var
Str : string;
begin
Result := 0;
str := source;
while Pos(Subs,Str)<>0 do
begin
Delete(Str,Pos(Subs,Str),Length(Subs));
Inc(Result);
end;

end;

procedure strsave(StrToWrite:string;path:string);
var
    afile:   TFileStream;
begin

    if   not   FileExists( path)   then
    begin
        try
            afile   :=   TFileStream.Create( path ,   fmCreate);
            afile.WriteBuffer(PChar(StrToWrite)^,Length(StrToWrite));
        finally
            afile.Free;
        end;
    end
    else   begin
        try
            afile   :=   TFileStream.Create( path,   fmOpenWrite);
            afile.Seek(0,   soEnd);
            afile.WriteBuffer(PChar(StrToWrite)^,Length(StrToWrite));
        finally
            afile.Free;
        end;
    end;
end;

//接受数据
procedure TForm1.Comm1ReceiveData(Sender: TObject; Buffer: Pointer;
  BufferLength: Word);
var
  str :string;
  strf:string;
  da,temp:string;
  head:string;
begin
  da:='';
  head:= edit1.text;
  if TimeFlgChk.Checked then
    da := formatdatetime('mm-dd hh:mm:ss.zzz', now) + ' Rx: ';
  SetLength(Str,BufferLength);
  move(buffer^,pchar(@Str[1])^,bufferlength);
 if not bstop   then
 begin
   if cbRecHex.Checked then
   begin
      temp:= StrToHexStr(str);// + #13#10;
      if StrPosCount(head,temp) >= 2 then
      begin
        strf:= StringReplace(temp,head,#13#10+ da +  head, [rfReplaceAll]);
        Delete(strf, 1, 2);
      end
      else
        strf:= da + temp;
        memo2.Lines.Add(strf);
      end
    else
         memo2.Lines.Add(Str);  // memo2.Text := memo2.Text + Str;
     end;
 FRXNum:=FRXNum+bufferlength;
 ShowRX;
end;

procedure TForm1.Edit3Change(Sender: TObject);
begin
   if edit3.text <> '' then
      comm1.ReadIntervalTimeout := strtoint( edit3.Text);
end;

procedure TForm1.Edit3KeyPress(Sender: TObject; var Key: char);
begin
    if not (key in ['0'..'9',#8]) then
    begin
     key :=#0;
     ShowMessage('请输入"0~9"之间的数');
    end;

end;


procedure EnumComDevicesFromRegistry(List: TStrings);
var
  Names: TStringList;
  i: Integer;
begin
  with TRegistry.Create do
  try
    RootKey := HKEY_LOCAL_MACHINE;
      if OpenKeyReadOnly('\HARDWARE\DEVICEMAP\SERIALCOMM') then
      begin
        Names := TStringList.Create;
        try
          GetValueNames(Names);
          for i := 0 to Names.Count - 1 do
            if GetDataType(Names[i]) = rdString then
              List.Add(ReadString(Names[i]));
        finally
          Names.Free;
        end
      end;
  finally
    Free;
  end;
end;

procedure EnumComPorts(Ports: TStrings);
var
  KeyHandle: HKEY;
  ErrCode, Index: Integer;
  ValueName, Data: string;
  ValueLen, DataLen, ValueType: DWORD;
  TmpPorts: TStringList;
begin
  ErrCode := RegOpenKeyEx(
    HKEY_LOCAL_MACHINE,
    'HARDWARE\DEVICEMAP\SERIALCOMM',
    0,
    KEY_READ,
    KeyHandle);

  if ErrCode <> ERROR_SUCCESS then
    Exit;  // raise EComPort.Create(CError_RegError, ErrCode);

  TmpPorts := TStringList.Create;
  try
    Index := 0;
    repeat
      ValueLen := 256;
      DataLen := 256;
      SetLength(ValueName, ValueLen);
      SetLength(Data, DataLen);
      ErrCode := RegEnumValue(
        KeyHandle,
        Index,
        PChar(ValueName),
        Cardinal(ValueLen),
        nil,
        @ValueType,
        PByte(PChar(Data)),
        @DataLen);

      if ErrCode = ERROR_SUCCESS then
      begin
        SetLength(Data, DataLen);
        TmpPorts.Add(Data);
        Inc(Index);
      end
      else
        if ErrCode <> ERROR_NO_MORE_ITEMS then
          exit; //raise EComPort.Create(CError_RegError, ErrCode);

    until (ErrCode <> ERROR_SUCCESS) ;

    TmpPorts.Sort;
    Ports.Assign(TmpPorts);
  finally
    RegCloseKey(KeyHandle);
    TmpPorts.Free;
  end;

end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  edit3.Text:= inttostr(comm1.ReadIntervalTimeout);
  EnumComPorts(comlist.Items);    //得到串口列表
  comlist.ItemIndex := 0;
  Comm1.CommName := comlist.Text;
  Comm1.BaudRate := StrToInt(ComboBox2.Text);
  ComboBox4.ItemIndex := 0;
  Comm1.Parity := None;
  ComboBox3.ItemIndex := 3;
  Comm1.ByteSize := _8;
  ComboBox5.ItemIndex := 0;
  Comm1.StopBits := _1;
  ShowStatus;
  ShowRX;
  ShowTX;
  try
  memo3.Lines.LoadFromFile('c:\comdata\command1.txt');
  memo4.Lines.LoadFromFile('c:\comdata\command2.txt');
  memo5.Lines.LoadFromFile('c:\comdata\command3.txt');
  memo6.Lines.LoadFromFile('c:\comdata\command4.txt');
  memo7.Lines.LoadFromFile('c:\comdata\command5.txt');
  memo8.Lines.LoadFromFile('c:\comdata\command6.txt');
  except
   MkDir('c:\comdata');
  end;

end;


procedure TForm1.Button3Click(Sender: TObject);
begin
   EnumComPorts(comlist.Items);
end;


//关闭串口
 procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Comm1.StopComm;
  try
   memo3.Lines.SaveToFile('c:\comdata\command1.txt');
   memo4.Lines.SaveToFile('c:\comdata\command2.txt');
   memo5.Lines.SaveToFile('c:\comdata\command3.txt');
   memo6.Lines.SaveToFile('c:\comdata\command4.txt');
   memo7.Lines.SaveToFile('c:\comdata\command5.txt');
   memo8.Lines.SaveToFile('c:\comdata\command6.txt');
   except
    MkDir('c:\comdata');
   end;
end;

end.

