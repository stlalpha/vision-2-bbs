{$R-,S-,I-,D-,F+,V-,B-,N-,L+,O+}

Unit Chat;

Interface

Uses Dos,Crt,MDosIo,DosMem,ConfigRt,Gentypes,Gensubs,Modem,Subs1,Subs2;

Procedure Fake_Chat;

Implementation

Procedure Fake_Chat;

const
  bbs_chat_file = 'BBSCHAT.NET';    {script file name}

type
  string_12 = string[12];           { global types }
  string_25 = string[25];
  string_80 = string[80];
  string_255 = string[255];
  bull_line_ptr = ^string_80;
  charset = set of char;

const
  alphabet : charset = ['A'..'Z'];      {global variables used in the bbs}
  locase : array['A'..'Z'] of char =
    ('a','b','c','d','e','f','g','h','i','j','k',
     'l','m','n','o','p','q','r','s','t','u','v','w','x','y','z');

var
  case_switch : boolean;       {tells the input routine on the bbs to}
                               {convert lower case to upper.  serves}
                               {no purpose here, though}
  text_file : text;

procedure check_time_limit;

begin
end;

procedure clear_buffer;

begin
end;

  procedure chat_with_eliza;

  const
    max_trans = 24;   {number of words to transpose}
    max_reply = 20;   {the maximum number of replies for each set of responses}
    max_key = 100;    {maximum number of key words}

  type
    keyrec = record
               word : string_25;
               resp_set : integer;
             end;

    reprec = record
               tot_resp : integer;
               last_resp : integer;
               reply : array[0..max_reply] of bull_line_ptr;
             end;

    key_word_array = array[1..max_key] of keyrec;

    resp_set_array = array[1..max_key] of reprec;

    transpose_array = array[1..max_trans] of string_12;

   var
    tmp_str               : string_255;
    end_of_chat           : boolean;
    this_keyword          : string_255;
    user_input            : string_255;
    current_response      : integer;
    i                     : integer;
    key_no                : integer;
    key                   : key_word_array;
    key_found             : boolean;
    keywords              : integer;
    l                     : integer;
    my_resp               : reprec;
    my_str                : string_255;
    no_key                : reprec;
    null_input            : boolean;
    null_resp             : reprec;
    prog_output           : string_255;
    puncs                 : set of char;
    resp_no               : integer;
    response              : string_255;
    responses             : integer;
    response_set          : resp_set_array;
    save_key_no           : integer;
    signon                : reprec;
    transpose             : integer;
    wordin                : transpose_array;
    wordout               : transpose_array;
    x                     : byte;
    quit_str              : string_255;

  function right(rstr : string_255; len : integer) : string_255;

  begin
    right := copy(rstr,(length(rstr) - len + 1),len);
  end;

  procedure write_line(tstr : string_255);

  var
    i : integer;

    procedure write_char(char1 : char);

    begin
      delay(25 + random(75));
      if char1 in alphabet then
        char1 := locase[char1];
      write(char1);
    end;

  begin
    for i := 1 to length(tstr) do
      begin
        if random(50) = 0 then
          begin
            write_char(chr(random(26)+65));
            delay(65 + random(100));
            write_char(#8);
          end;
        write_char(tstr[i]);
      end;
    writeln;
  end;

  procedure read_script;

  var
    line_buffered : boolean;
    line_no : integer;
    rec_type : char;

    procedure read_script_line;

    begin
      repeat
        if not eof(text_file) then
          begin
            line_no := line_no + 1;
            readln(text_file,tmp_str);
            if tmp_str = '' then
              tmp_str := ';';
          end
        else
          tmp_str := #0;
      until tmp_str[1] <> ';';
    end;

    procedure add_transpose;

    begin
      if transpose <> max_trans then
        begin
          transpose := transpose + 1;
          tmp_str[0] := pred(tmp_str[0]);
          wordin[transpose] := tmp_str;
          read_script_line;
          if tmp_str[1] = 'T' then
            begin
              delete(tmp_str,1,1);
              tmp_str[0] := pred(tmp_str[0]);
              wordout[transpose] := tmp_str;
            end
          else
            end_of_chat := true;
        end;
    end;

    procedure add_keyword;

    begin
      if keywords <> max_key then
        begin
          keywords := keywords + 1;
          tmp_str[0] := pred(tmp_str[0]);
          key[keywords].word := tmp_str;
          key[keywords].resp_set := current_response;
        end
      else
        end_of_chat := true;
    end;

    procedure add_response(var tmp_resp : reprec);

    begin
      with tmp_resp do
        if tot_resp <= max_reply then
          begin
            new(reply[tot_resp]);
            reply[tot_resp]^ := tmp_str;
            tot_resp := tot_resp + 1;
          end
        else
          end_of_chat := true;
    end;

    procedure add_response_set;

    begin
      with response_set[current_response] do
        begin
          responses := responses + 1;
          tot_resp := 0;
          while rec_type = 'R' do
            begin
              add_response(response_set[current_response]);
              read_script_line;
              rec_type := tmp_str[1];
              delete(tmp_str,1,1);
            end;
        end;
      current_response := current_response + 1;
      line_buffered := (rec_type <> #0);
    end;

  begin
    assign(text_file, cfg.visiondir + bbs_chat_file);
    reset(text_file);
    line_no := 0;
    if ioresult <> 0 then
      end_of_chat := true
    else
      begin
        keywords := 0;
        transpose := 0;
        current_response := 1;
        my_resp.tot_resp := 0;
        null_resp.tot_resp := 0;
        no_key.tot_resp := 0;
        signon.tot_resp := 0;
        responses := 0;
        line_buffered := false;
        quit_str := 'Did you enjoy talking to a computer??..';
        while not (eof(text_file) or end_of_chat) do
          begin
            if not line_buffered then
              begin
                read_script_line;
                rec_type := tmp_str[1];
                delete(tmp_str,1,1);
              end;
            line_buffered := false;
            case rec_type of
              'S' : add_response(signon);
              'T' : add_transpose;
              'N' : add_response(null_resp);
              'M' : add_response(my_resp);
              'X' : add_response(no_key);
              'K' : add_keyword;
              'R' : add_response_set;
              'Q' : quit_str := tmp_str;
            else
              end_of_chat := true;
            end;
          end;
        textclose(text_file);
      end;
    if end_of_chat then
      begin
        writeln('Script file error.  Line ',line_no);
        writeln;
      end;
  end;

  procedure get_response;
  var l : byte;
  begin
    check_time_limit;
    clear_buffer;
    NoChain := True;
    GetStr(True);
    If HungUpOn Then Exit;
    tmp_str := '';
    i := 0;
    User_Input := Inpt;
    End_of_Chat := UpString(User_Input) = '/Q';
    If UpString(User_Input) = 'EXIT'
      then End_of_Chat := True;
    for l := 1 to length(user_input) do
      begin
        if not (user_input[l] in puncs) then
          begin
            i := i + 1;
            tmp_str[i] := upcase(user_input[l]);
          end;
      end;
    tmp_str[0] := char(i);
    while tmp_str[length(tmp_str)] = ' ' do
      tmp_str[0] := pred(tmp_str[0]);
    while tmp_str[1] = ' ' do
      begin
        tmp_str[1] := #0;
        delete(tmp_str,1,1);
      end;
    null_input := (tmp_str = '');
    user_input := '  ' + tmp_str + '  ';
    if end_of_chat then
      begin
        writeln;
        write_line(quit_str);
        end_of_chat := true;
      end;
  end;

  procedure find_keyword;
  var i : byte;
  begin
    key_found := false;
    this_keyword := '';
    prog_output := '';
    key_no := 0;
    while (not key_found) and (key_no <> keywords) do
      begin
        key_no := key_no + 1;
        for i := 1 to (length(user_input)-length(key[key_no].word)+1) do
          if copy(user_input,i,length(key[key_no].word)) =
             key[key_no].word then
            begin
              this_keyword := key[key_no].word;
              l := i;
              key_found := true;
            end;
      end;
    if key_found then
      prog_output := ' ' +
        right(user_input,(length(user_input)-length(this_keyword)-l+1)) +
        ' ';
  end;

  procedure conjugate_and_transpose;
  var i : byte;
  begin
    l := 1;
    while l <= length(prog_output) do
      begin
        for i := 1 to transpose do
          if (copy(prog_output,l,length(wordin[i])) = wordin[i]) then
            begin
              prog_output := copy(prog_output,1,l-1) + wordout[i] +
                right(prog_output,(length(prog_output) - l - length(wordin[i]) + 1));
              l := l + length(wordout[i]) - 2;
            end;
        l := l + 1;
      end;
    while prog_output[1] = ' ' do
      begin
        prog_output[1] := #0;
        delete(prog_output,1,1);
      end;
    x := length(prog_output);
    while prog_output[x] = ' ' do
      x := x-1;
    prog_output[0] := chr(x);
    if this_keyword = 'MY ' then
      my_str := prog_output;
  end;

  procedure show_response(var rset : reprec; var prog_out : string_255);

  begin
    with rset do
      begin
        resp_no := random(tot_resp);
        if tot_resp > 1 then
          while resp_no = last_resp do
            resp_no := random(tot_resp);
        response := reply[resp_no]^;
        last_resp := resp_no;
        i := pos('*',response);
        if i = 0 then
          write_line(response)
        else
          begin
            if i <> length(response)-1 then
              tmp_str := copy(response,1,(i-1)) +
                          ' ' + prog_out + ' ' +
                          copy(response,(i+1),length(response)-i)
            else
              tmp_str := copy(response,1,(i-1)) +
                          ' ' + prog_out + response[i+1];
            write_line(tmp_str);
          end;
      end;
    writeln;
  end;

  procedure show_reply;

  begin
    writeln;
    if (not key_found) then
      begin
        if (my_str <> '') and (random(5) = 0) then
          show_response(my_resp,my_str)
        else
          begin
            tmp_str := '';
            if null_input then
              show_response(null_resp,tmp_str)
            else
              show_response(no_key,tmp_str);
          end;
      end
    else
      begin
        current_response := key[key_no].resp_set;
        show_response(response_set[current_response],prog_output);
      end;
  end;

  begin
    my_resp.last_resp := -1;
    null_resp.last_resp := -1;
    no_key.last_resp := -1;
    for i := 1 to max_key do
      response_set[i].last_resp := -1;
    puncs := ['.', ',', ';', '!', '?'];
    my_str := '';
    end_of_chat := false;
    case_switch := false;
    Writehdr('Enter /Q to quit chatting');
    MultiColor(Strng^.EnterChat);
    Writeln(^M);
    AnsiColor(Urec.Color3);
    read_script;
    if not end_of_chat then
      begin
        if hungupon
          then exit;
        i := random(signon.tot_resp);
        write_line(signon.reply[i]^);
        writeln;
        get_response;
        while not end_of_chat do
          begin
            find_keyword;
            if key_found then
              conjugate_and_transpose;
            show_reply;
            get_response;
          end;
      end;
    case_switch := true;
    with signon do
      for i := 1 to tot_resp do
        dispose(reply[i-1]);
    with null_resp do
      for i := 1 to tot_resp do
        dispose(reply[i-1]);
    with no_key do
      for i := 1 to tot_resp do
        dispose(reply[i-1]);
    with my_resp do
      for i := 1 to tot_resp do
        dispose(reply[i-1]);
    for l := 1 to responses do
      with response_set[l] do
        for i := 1 to tot_resp do
          dispose(reply[i-1]);
  end;

begin
  if not exist(cfg.visiondir + bbs_chat_file)
    then exit;
  randomize;
  chat_with_eliza;
end;

begin
end.