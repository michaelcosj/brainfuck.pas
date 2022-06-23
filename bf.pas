
Program brainfuck;

Uses SysUtils;

Type data = Array Of char;

Var 
  src: data;
  filename: string;

Procedure bf_Interprete(src: data);

Var 
  mem: Array[1..30000] Of byte;
  dataPtr: word = 1;
  iPtr: word = 0;
  inChar: char;
  braceCount: word;
Begin
  FillByte(mem, sizeof(mem), 0);
  While iPtr <= length(src) Do
    Begin
      inc(iPtr);
      Case (src[iPtr]) Of 
        '>' : inc(dataPtr);
        '<' : dec(dataPtr);
        '+' : inc(mem[dataPtr]);
        '-' : dec(mem[dataPtr]);
        '.' : write(chr(mem[dataPtr]));
        ',' :
              Begin
                read(inChar);
                mem[dataPtr] := ord(inChar);
              End;
        '[' :
              Begin
                If mem[dataPtr] = 0 Then
                  Begin
                    braceCount := 1;
                    While Not(iPtr > length(src)) And Not(braceCount = 0) Do
                      Begin
                        inc(iPtr);
                        If src[iPtr] = '[' Then
                          inc(braceCount)
                        Else
                          If src[iPtr] = ']' Then
                            dec(braceCount);
                      End
                  End
              End;
        ']' :
              Begin
                If Not(mem[dataPtr] = 0) Then
                  Begin
                    braceCount := 1;
                    While Not(iPtr > length(src)) And Not(braceCount = 0) Do
                      Begin
                        dec(iPtr);
                        If src[iPtr] = ']' Then
                          inc(braceCount)
                        Else
                          If src[iPtr] = '[' Then
                            dec(braceCount);
                      End
                  End
              End;
      End;
    End;
End;

(* Takes in a filename and loads the source file by that name *)
Procedure bf_LoadProgramFromFile(filename: String; Var src: data);

Var 
  buf: char;
  srcFile: TextFile;
  counter: word = 1;
Begin
  Assign(srcFile, filename);

  {$i-}
  reset(srcFile);
  {$i+}

  If Not (IoResult = 0) Then
    Begin
      writeln('File ', filename, ' not found');
      halt(1);
    End;

  setlength(src, sizeof(srcFile));
  While counter <= length(src) Do
    Begin
      If eof(srcFile) Then
        break;
      read(srcFile, buf);
      If (buf = '>') Or (buf = '<') Or (buf = '+')
         Or (buf = '-') Or (buf = '.') Or (buf = ',')
         Or ( buf = '[') Or (buf = ']') Then
        Begin
          src[counter] := buf;
          inc(counter)
        End
    End;
  Close(srcFile);
End;

Procedure usage(program_name: String);
Begin
  writeln('Brainfuck Interpreter');
  writeln(format('Usage %s <file-name>', [program_name]));
End;

{=== Main ===}
Begin
  If ParamCount < 1 Then
    Begin
      usage(ParamStr(0));
      halt(1);
    End;

  filename := ParamStr(1);
  bf_LoadProgramFromFile(filename, src);
  bf_Interprete(src);
End.
