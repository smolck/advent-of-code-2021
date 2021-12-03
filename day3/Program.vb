Imports System
Imports System.IO

Module Program
    ' https://www.dotnetperls.com/streamreader-vbnet
    Function ReadFromFile(file As String) as List(Of String)
        Dim list As New List(Of String)

        Using r As StreamReader = New StreamReader(file)
            Dim line = r.ReadLine

            Do While (Not line Is Nothing)
                list.Add(line)
                line = r.ReadLine
            Loop
        End Using

        return list
    End Function

    Sub PartOne(input As List(Of String))
        Dim lineLen = input(0).Length - 1

        Dim gammaNums As New List(Of Integer)
        Dim epsilonNums As New List(Of Integer)

        For i = 0 To lineLen
            Dim otherI = i ' Get a warning about unexpected results with the query if I don't do this
            Dim grouped = From num In input
                          Select x = Val(num(otherI))
                          Group By y = x
                          Into Classes = Group, Count()
                          Order By y

            Dim zeroes = grouped(0)
            Dim ones = grouped(1)

            If zeroes.Count > ones.Count Then
                gammaNums.Add(zeroes.y)
                epsilonNums.Add(ones.y)
            Else
                gammaNums.Add(ones.y)
                epsilonNums.Add(zeroes.y)
            End If
        Next

        Dim gamma = Convert.ToInt32(String.Join("", gammaNums), 2)
        Dim epsilon = Convert.ToInt32(String.Join("", epsilonNums), 2)
        Console.WriteLine("Power consumption: " & gamma * epsilon)
    End Sub

    Sub PartTwo(input As List(Of String))
        Dim lineLen = input(0).Length - 1

        ' This actually filters nothing but otherwise VB complains about types and stuff
        Dim oxygenNums = From num in input
                         Where num(0) = "0" Or num(0) = "1"
        For i = 0 To lineLen
            Dim otherI = i
            Dim groupedBits = From num In oxygenNums
                              Select x = num(otherI)
                              Group By y = x
                              Into Classes = Group, Count()

            Dim bitsOne = groupedBits(0)
            Dim bitsTwo = groupedBits(1)

            Dim oxygenGeneratorBit As Char
            If bitsOne.Count = bitsTwo.Count Then
                oxygenGeneratorBit = "1"
            Else If bitsOne.Count > bitsTwo.Count Then
                oxygenGeneratorBit = bitsOne.y
            Else
                oxygenGeneratorBit = bitsTwo.y
            End If

            oxygenNums = From num In oxygenNums
                         Where num(otherI) = oxygenGeneratorBit

            If oxygenNums.Count = 1 Then
                Exit For
            End If
        Next

        Dim co2Nums = From num in input
                      Where num(0) = "0" Or num(0) = "1"

        For i = 0 To lineLen
            Dim otherI = i
            Dim groupedBits = From num In co2Nums
                              Select x = num(otherI)
                              Group By y = x
                              Into Classes = Group, Count()

            Dim bitsOne = groupedBits(0)
            Dim bitsTwo = groupedBits(1)

            Dim co2ScrubberBit As Char
            If bitsOne.Count = bitsTwo.Count Then
                co2ScrubberBit = "0"
            Else If bitsOne.Count < bitsTwo.Count Then
                co2ScrubberBit = bitsOne.y
            Else
                co2ScrubberBit = bitsTwo.y
            End If

            co2Nums = From num In co2Nums
                         Where num(otherI) = co2ScrubberBit

            If co2Nums.Count = 1 Then
                Exit For
            End If
        Next

        Dim o2GenRating = Convert.ToInt32(oxygenNums(0), 2)
        Dim co2ScrubberRating = Convert.ToInt32(co2Nums(0), 2)
        Console.WriteLine("Oxygen Generator Rating: " & o2GenRating)
        Console.WriteLine("CO2 Scrubber Rating: " & co2ScrubberRating)
        Console.WriteLine("Answer: " & o2GenRating * co2ScrubberRating)
    End Sub

    Sub Main(args As String())
        Dim input = ReadFromFile("input.txt")

        Console.WriteLine("Part One")
        PartOne(input)

        Console.WriteLine("")

        Console.WriteLine("Part Two")
        PartTwo(input)
    End Sub
End Module
