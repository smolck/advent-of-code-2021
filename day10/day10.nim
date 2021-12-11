import std/deques
import std/algorithm
import strutils

# Thanks @elianiva for the idea of using a stack (here a deque), works nicely!

let input = readFile("example-input.txt").split({'\n'})

proc checkClosesProperly(opener, closer: char): bool =
  if opener == '(':
    closer == ')'
  elif opener == '[':
    closer == ']'
  elif opener == '{':
    closer == '}'
  elif opener == '<':
    closer == '>'
  else:
    false

proc error(c: char): int =
  case c:
    of ')': 3
    of ']': 57
    of '}': 1197
    of '>': 25137
    else: 0

var uncorruptLines: seq[string] = @[]
var errorScore = 0

# Part one
for line in input:
  var deque = Deque[char]()
  var lineIsCorrupt = false

  for c in line:
    if (c == ')' or c == ']' or c == '}' or c == '>'):
      if checkClosesProperly(deque.peekLast, c):
        discard deque.popLast
      else:
        errorScore += c.error
        lineIsCorrupt = true
        break
    else:
      deque.addLast(c)

  if not lineIsCorrupt:
    uncorruptLines.add(line)

echo "Answer to part one: " & errorScore.intToStr()

# Part two
proc closer(c: char): char =
  if c == '(': ')'
  elif c == '[': ']'
  elif c == '{': '}'
  elif c == '<': '>'
  else: ' '

proc score(c: char): int =
  case c:
    of ')': 1
    of ']': 2
    of '}': 3
    of '>': 4
    else: 0

var scores: seq[int] = @[]
for line in uncorruptLines:
  var deque = Deque[char]()

  for c in line:
    if (c == '(' or c == '[' or c == '{' or c == '<'):
      deque.addFirst(c)
    else:
      deque.popFirst

  var score = 0
  for c in deque:
    score = (score * 5) + c.closer.score

  scores.add(score)

scores.sort()
echo "Part two answer: " & scores[int(len(scores) / 2)].intToStr()
