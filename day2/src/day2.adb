with Text_IO; use Text_IO;

with Ada.Containers.Indefinite_Vectors, Ada.Strings.Fixed, Ada.Strings.Maps;
use Ada.Containers, Ada.Strings, Ada.Strings.Fixed, Ada.Strings.Maps;

procedure Day2 is
    package String_Vectors is new Indefinite_Vectors (Positive, String);
    use String_Vectors;

    -- Why is a general version of this not in the stdlib?
    -- https://www.rosettacode.org/wiki/Tokenize_a_string#Ada
    function SplitOnSpace (Input : String) return String_Vectors.Vector is
       Start  : Positive := Input'First;
       Finish : Natural  := 0;
       Output : String_Vectors.Vector := Empty_Vector;
    begin
       -- Ada (ADA, aDa, ADa, aDA) is case-insensitive, so let's be case-insensitive.
       WhIlE StArT <= InPuT'LaSt LoOp
          Find_Token (Input, To_Set (' '), Start, Outside, Start, Finish);
          exit when Start > Finish;
          Output.Append (Input (Start .. Finish));
          Start := Finish + 1;
       end loop;

       return Output;
    end SplitOnSpace;

    File : File_Type;

    procedure Part_One is
        Horizontal_Pos : Integer := 0;
        Depth : Integer := 0;
    begin
        Open (File => File,
              Mode => In_File,
              Name => "input.txt");
        while not End_Of_File (File) loop
            declare
                Line : String := Get_Line (File);
                Tokens : String_Vectors.Vector := SplitOnSpace (Line);

                Command : String := Tokens.First_Element;
                Value : Integer := Integer'Value (Tokens.Last_Element);
            begin
                if Command = "forward" then
                    Horizontal_Pos := Horizontal_Pos + Value;
                elsif Command = "down" then
                    Depth := Depth + Value;
                elsif Command = "up" then
                    Depth := Depth - Value;
                end if;
            end;
        end loop;
        Close (File);

        Put_Line ("Depth: " & Integer'Image (Depth) & ", " & 
                  "Horizontal_Pos: " & Integer'Image (Horizontal_Pos) & 
                  ", Total: " & Integer'Image (Depth * Horizontal_Pos));
    end Part_One;

    procedure Part_Two is
        Horizontal_Pos : Integer := 0;
        Depth : Integer := 0;
        Aim : Integer := 0;
    begin
        Open (File => File,
              Mode => In_File,
              Name => "input.txt");
        while not End_Of_File (File) loop
            declare
                Line : String := Get_Line (File);
                Tokens : String_Vectors.Vector := SplitOnSpace (Line);

                Command : String := Tokens.First_Element;
                Value : Integer := Integer'Value (Tokens.Last_Element);
            begin
                if Command = "forward" then
                    Horizontal_Pos := Horizontal_Pos + Value;
                    Depth := Depth + (Aim * Value);
                elsif Command = "down" then
                    Aim := Aim + Value;
                elsif Command = "up" then
                    Aim := Aim - Value;
                end if;
            end;
        end loop;
        Close (File);

        Put_Line ("Depth: " & Integer'Image (Depth) & ", " & 
                  "Horizontal_Pos: " & Integer'Image (Horizontal_Pos) & 
                  ", Total: " & Integer'Image (Depth * Horizontal_Pos));
    end Part_Two;
begin
    Put_Line ("Part 1");
    Part_One;

    Put_Line ("");

    Put_Line ("Part 2");
    Part_Two;
end Day2;
