program USS;
uses crt, Windows;
type
     tablica=array[1..10] of string;
    wsk=^slownik;

    slownik=record
    koniec:boolean;
    next:array [char] of wsk;
    slowo:string;
    tlumaczenie:string;
     end;
    {Slownik to record. ktory przechowuje tablice wskaznikow adresowana znakami ASCII.

    }

    wska=^wyswietlacz;

    wyswietlacz=record
    pn: wska;
    slowo,tlumaczenie:string;
    wiersz:integer;
     end;
var
  enpl:array [1..2] of wsk;
  lista:wska;
  x:integer;
  slo,tlu:string;
  l,h:integer;
  f_time:double;
  freq,timestart,timeend:int64;

function nowa:wsk;                //tworzy nowy_wezelj drzewa trie
var p:wsk; c:char;
begin
  new(p);
   for c:=low(char) to high(char) do begin
       p^.next[c]:=NIL;
       p^.koniec:=false;
   end;
  nowa:=p;
end;
function w_nowy:wska;            //tworzy nowy wezel listy sluzacej do wyswietlania na ekranie
var
  nowy:wska;
begin
  new (nowy);
  nowy^.pn:=nil;
  nowy^.slowo:='';
  nowy^.tlumaczenie:='';
  nowy^.wiersz:=1;
  w_nowy:=nowy;

end;
procedure w_dodaj(root:wska;s,s1:string);  //dodaje wezel do listy wyswietlajacej
var
  nowy:wska;
begin
  while root^.pn<>nil do
        begin
              root:=root^.pn;
        end;
  if (root^.pn=nil) and (root^.slowo='') then
   begin
        root^.slowo:=s;
        root^.tlumaczenie:=s1;
   end
  else begin
   new(nowy);
   nowy^.pn:=nil;
   nowy^.slowo:=s;
   nowy^.tlumaczenie:=s1;
   nowy^.wiersz:=root^.wiersz+1;
   root^.pn:=nowy;
  end;


end;
procedure w_usun(var root:wska);           //usuwa cala liste oprocz korzenia
var
  tmp:wska;
begin

  while(root<>nil) do
        begin
           tmp:=root;
           root:=root^.pn;
           dispose(tmp);
           tmp:=nil;


        end;
  lista:=w_nowy;
end;
procedure w_wyswietl(root:wska;nr:integer);  //funkcja wyswietlajaca na ekranie liste. umozliwia przesuwanie ekranu konsoli w gore i w dol
begin
   if root<>nil then
     begin
         if (root^.wiersz>l) and (root^.wiersz<h) then
           begin
                if (nr<>root^.wiersz) then writeln(root^.wiersz,'. ',root^.slowo)
                else
                begin
                     textcolor(2);
                                  writeln(root^.wiersz,'. ',root^.slowo,' - ',root^.tlumaczenie)  ;
                     textcolor(15);
                end;

          end;
          w_wyswietl(root^.pn,nr);
     end;
end;
procedure dodaj(root:wsk;s,s1:string);         //dodaje nowy element drzewa trie
 var c:char;i:integer;p:wsk;pyt:char;
begin
     for i:=1 to length(s) do
     begin
         if (root^.next[s[i]]<>NIL) then root:=root^.next[s[i]]
         else
         begin
            p:=nowa;
            root^.next[s[i]]:=p;
            root:=p;
         end;
     end;
     if root^.koniec=true then
     begin
     end
     else
     begin
          root^.koniec:=true;
          root^.slowo:=s;
          root^.tlumaczenie:=s1;

     end;
end;

{Funkcja dodawania elementow do struktury slownikowej:.
Jest to struktura ktorej kazdy element ma tablice wskaznikow na wszystkie znaki ASCII.
Przed dodaniem pierwszego slowa do tej struktury w strukturze tej istnieje tylko wskaznik root.
Root wskazuje jakby na poczatek tej strukture, a ze nie ma zadnego slowa dodanego
to kazdy wskaznik z tej tablicy wskaznikow ktore sa adresowane znakami ASCII(next) wskazuja na NULL.
jak dodajemy jakies slowo. np ADAM. to struktura bedzie wygladac tak: (w skrocie bo ascii ma 255 znakow wiec za duzo pisania).

element, Literka oznaczajaca wskaznik-Literka na jaki wskaznik wskazuje,  czy koniec slowa(to jest wartosc boolean, true albo false)
1,A-D,false
2,D-A,false
3,A-M,true.

teraz jesli chcielibysmy dodac np. ADAMA to struktura bd wygladac tak.
1,A-D, false
2,D-A, false
3,A-M, true
4,M-A, true

To dziala tak jak w tym drzewie trie .
}

procedure time_start;                //procedura pobierajaca aktualny stan zegara procesora
begin
QueryPerformanceCounter(TimeStart);
end;
procedure time_stop();           //procedura pobierajaca aktualny stan zegara procesora i wyliczajaca roznice w ms. pomiedzy tym a poprzednim pomiarem
begin
QueryPerformanceCounter(TimeEnd);
f_time:=((timeend-timestart)/freq)*1000;
writeln('Wyszukanie skonczono w :',f_time:2:6,' ms');
end;

function szukaj(root:wsk;s:string;var przesuniecia:integer):string; // wyszukiwanie konkretnego slowa w drzewie trie
var c:char;i:integer;p:boolean;
begin
     p:=true;
     for i:=1 to length(s) do
     begin
         if root^.next[s[i]]=NIL then
            begin
              p:=false;
              break;

            end
         else
         begin
              root:=root^.next[s[i]];
              inc(przesuniecia);
         end;

     end;
     if(root^.koniec=true) and(p=true) then
        begin
        szukaj:=(root^.slowo+' ->'+root^.tlumaczenie);
        end
     else szukaj:=(' -> brak w slowniku');
end;
procedure wypisz(root:wsk;var licznik:integer;root2:wska); // funkcja przepisuje slowa z drzewa zaczynajace sie konkretna litera do listy wyswietlajacej
var c:char;i:integer;p:wsk;
begin
if root<>nil then begin
  if root^.koniec then
     begin
      licznik:=licznik+1;
      w_dodaj(root2,root^.slowo,root^.tlumaczenie);
     end;
  for c:=low(char) to high(char) do
    if root^.next[c]<>nil then wypisz(root^.next[c],licznik,root2);
    end;
end;
{Funkcja dziala tak:
Funkcja przeszukuje wszystkie elementy (czyli jakby w drzewie trie, kolejne poziomy).
jesli root^.koniec= true tzn ze w tym momencie konczy sie jakies slowo. i przepisujemy to slowo do listy wyswietlajacej.

}
procedure wyswietlacz_listy(c:char;kind:integer);        //przesuwanie listy gora dol
var
    kier:char;
    liczba_el,nr:integer;
begin
  liczba_el:=1;

if (ord(c)<>13) then
   begin
        if   QueryPerformanceFrequency(Freq) then
        begin
        time_Start;
        wypisz(enpl[kind]^.next[c],liczba_el,lista);
        time_stop;

        end;

   end
   else
      begin
        if   QueryPerformanceFrequency(Freq) then
        begin
        time_Start;
        wypisz(enpl[kind],liczba_el,lista);
        time_stop;

   end   ;

      end;


readln;

 nr:=l+1;
      repeat
                  clrscr;

                         w_wyswietl(lista,nr);
                         kier:=readkey;
                                     if kier='w' then
                                        begin
                                         if (nr-1>l) then
                                            begin
                                                 dec(nr);
                                            end
                                         else if nr-1<=l then
                                            begin
                                             if (l-1>=0) then
                                                begin
                                                     l:=l-24;
                                                     h:=h-24;
                                                     dec(nr);
                                                end;
                                            end;
                                        end;
                                     if kier='s' then
                                        begin
                                          if (nr+1<h) and (nr+1<liczba_el) then
                                             begin
                                                 inc(nr);
                                             end
                                          else if(nr+1>=h) then
                                             begin
                                                       h:=h+24;
                                                       l:=l+24;
                                                       inc(nr);
                                             end;
                                        end;
                  until kier='q';
                         w_usun(lista);



end;

function waliduj(s:string):boolean;               //walidacja czy char nie jest liczba
var
    code,l:byte;
begin
waliduj:=false;
              val(s,l,code) ;
              if code<>0 then waliduj:=true;
end;

procedure wybierz();   //glowne cialo programu
var
  w,licznik,kind:integer;
  c:char;

begin
kind:=1;
     repeat
     l:=0;
     h:=24;
     w:=0;
     licznik:=0;
    clrscr;
    if kind=1 then writeln('Slownik Angielsko-Polski')
    else if kind=2 then writeln('Slownik Polsko-Angielski');
    writeln('1)Dodaj slowo                  #');
    writeln('2)Wyszukaj tlumaczenie         #');
    writeln('3)en-pl / pl-en                #');
    writeln('4)Wyswietl slownik             #');
    writeln('5)Zakoncz                      #');
    write('wybor :');
    readln(x);
              if (x=1) then
                 begin
                  write('slowo: ');
                  readln(slo);
                  writeln();
                  write('tlumaczenie: ');
                  readln(tlu);
                  writeln;
                  dodaj(enpl[kind],slo,tlu);
                 end;
              if (x=2) then
                 begin
                  write('slowo: ');
                  readln(slo);
                  writeln();

                   if QueryPerformanceFrequency(Freq) then
                    begin
                         time_start;
                         slo:=szukaj(enpl[kind],slo,licznik);
                         time_stop;

                    end;
                  writeln(slo);
                  writeln('wykonano ',licznik,' przesuniec w galezi drzewa');
                  readln;
                 end ;
              if (x=4) then
                 begin
                  write('Slowa zaczynajace sie na litere [enter=cala baza]: ');
                  readln(c);
                  if waliduj(c)=true then
                  wyswietlacz_listy(c,kind);


                 end;
              if (x=3) then
              begin
                   if kind=1 then kind:=2
                   else kind:=1;
              end;

  until x=5;
end;
function trim(s:string):string;                     //funkcja obcina spacje na poczatku i koncu stringa
var i:integer;
    p:integer;
begin
  for i:=1 to length(s) do
  begin
      if s[i]<>' ' then
         begin
          p:=i;
          break;
          end;
  end;
  s:=copy(s,p,length(s));
    for i:=length(s) downto 1 do
    begin
    if(s[i]<>' ') then
       begin
        p:=i;
        break;
       end;
    end;
    trim:=copy(s,1,p);
end;
function podziel_slowa(s,s2:string):tablica;        //dzieli stringa na mniejsze, wyznacznikiem podzialu jest przecinek
var
  p,i,n:integer;
  tab:tablica;
begin
  p:= pos(',',s);
  i:=1;
  while(p<>0) do
     begin
     tab[i]:=trim(copy(s,1,p-1)) ;
     delete(s,1,p);
     p:= pos(',',s);
     inc(i);
     end;
  tab[i]:=trim(s);
  for  n:=1 to i do
       dodaj(enpl[2],tab[n],s2);

  {funkcja dziala tak:
  1. do zmiennej p przypisujemy nr pozycji wystapienia przecinka.
  2. jesli p <> 0 (czyli znalazl jakis przecinek) dzielimy stringa na mniejsze stringi:
     Od pozycji 0 do znalezionego przecinka kopiujemy tekst do tablicy stringow.
     Usuwamy przecinek.
     Szukamy kolejnego przecinka
     Zwiekszamy i(i odpowiada za ilosc slow).
     Jesli znow znalezlismy przecinek to powtarzamy jeszcze raz.
  3. W petli od 1 do i(i to ilosc znalezionych tlumaczen). Dodajemy dla kazdego znalezionego slowa polskiego tlumaczenie angielskie.
     przyklad.
  altogether       zupelnie, calkowicie, razem
  szukamy slow zupelnie;calkowicie;razem. Wrzucamy je do tablicy tab. Zmienna i=3.
  pozniej dodajemy do struktury enpl[2](czyli slownik polski angielski) :
  zupelnie - altogether
  calkowicie - altogether
  razem - altogether.
  }
end;
procedure stri(st:string);      //funkcja dzieli stringa pobrane z pliku na dwa mniejsze, enpl od 1 znaku do 16 a drugi od 16 do konca
var                             //nastepnie wywoluje funkcje podziel_slowa dla stringa przechowujacego polskie tlumaczenie
  s1:string;
  s2:string;
begin
  trim(st);
  st:=lowercase(st);
  if (length(st)>0) then
     begin
          s1:=trim(copy(st,1,16));
          delete(st,1,16);
          s2:=trim(st);
          dodaj(enpl[1],s1,s2);

     end;
  podziel_slowa(s2,s1);
end;
{Funkcja dziala tak:
 1. usuwamy spacje z konca slowa i z poczatku(funkcja trim)
 2. zmieniamy wszystkie litery na male (lowercase)
 3. Dzielimy caly wiersz wczytany z pliku na dwa stringi. Jeden od 1 do 16 elementu. Drugi to bedzie reszta.
 4. znow obcinamy spacje teraz z drugiego slowa czyli tlumaczenia.
 5. wywolujemy funkcje dodaj(enpl[1]), ktora dodaje do uniwersalenj struktury kolejne slowo i tlumaczenie . Jako root podajemy wskaznik na slownik angielsko polski enpl[1].
 6. wywolujemy funkcje podziel_slowa w ktorej dzielimy drugiego stringa(tego co zawiera slowa po polsku, podzielone przecinkami). a nastepnie dla kazdego slowa polskiego dodaje tlumaczenie angielskie (takie samo).
}

procedure wczytaj_plik();         //wczytywanie pliku
var
  F:text;
  s:string;
begin

  Assign(f,'slownik.txt');
  reset(f);
           while not eof(f) do
              begin
                 readln(f,s);
                 stri(s);
              end;
  close(f);
end;

begin
  textcolor(15);   //zmiana koloru czcionki
  l:=0;            //zmienna odpowiadajaca za najnizszy nr. wyswietlanego slowa przez funkcje wyswietlacz
  h:=25;           //podobnie jak zmienna l, ale odpowiada za najwyzszy.
  enpl[1]:=nowa;
  enpl[2]:=nowa;//enpl to root dla drzewa trie
  lista:=w_nowy;     //lista to root dla listy
  wczytaj_plik();         //wczytanie pliku
  wybierz;
end.



