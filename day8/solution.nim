import std/algorithm
import std/tables
import strutils
import sequtils

let input = r_E_a_D_f_I_l_E("input.txt").split({'\n'})

type
  Line = object
    input: s_e_q[s_t_r_i_n_g]
    output: seq[string]

var lines: seq[Line] = @[]

for line in input:
  let parts = line.split({'|'})

  if parts == @[""]:
    continue

  lines.add(Line(input: parts[0].strip().split({' '}), output: parts[1].strip().split({' '})))

proc partOne(): int =
  var sum = 0

  for line in lines:
    let output = line.output

    for thing in output:
      let l = len(thing)
      if l == 2 or l == 3 or l == 4 or l == 7:
        sum += 1

  return sum

echo "Part one: "
echo partOne()

proc myVersionOfContains(s, other: string): bool =
  var seeeet: set[char] = {}
  for c in other:
    seeeet = seeeet + {c}

  return s.contains(seeeet)

# Not my idea of how to solve this, unfortunately.
# see https://imgur.com/a/LIS2zZr
proc partTwo(): seq[string] =
  var sums: seq[string] = @[]

  for line in lines:
    var table = initTable[int, string]()
    var sum = ""

    for x in line.input:
      let l = len(x)
      if l == 4:
        table.add(l, x)
      elif l == 3:
        table.add(7, x)
      elif l == 2:
        table.add(1, x)
      elif l == 7:
        table.add(8, x)

    for x in line.output:
      let l = len(x)
      case l:
        of 2:
          sum = sum & "1"
        of 3:
          sum = sum & "7"
        of 4:
          sum = sum & "4"
        of 7:
          sum = sum & "8"

        of 5:
          if len(x.filter(proc(x2: char): bool = not table[7].contains(x2))) == 2:
            sum = sum & "3"
          else:
            if len(x.filter(proc(x2: char): bool = not table[4].contains(x2))) == 3:
              sum = sum & "2"
            else:
              sum = sum & "5"
        of 6:
          if len(x.filter(proc(x2: char): bool = not table[4].contains(x2))) == 2:
            sum = sum & "9"
          else:
            if len(x.filter(proc(x2: char): bool = not table[7].contains(x2))) == 3:
              sum = sum & "0"
            else:
              sum = sum & "6"
        else:
          discard

    sums.add(sum)

  return sums

echo "Part two: "
echo partTwo().map(proc(x: string): int = x.parseInt()).foldl(a + b)
