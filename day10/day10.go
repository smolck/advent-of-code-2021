package main

import (
    "bufio"
    "fmt"
    "os"
    "sort"
)

// Thanks @elianiva for the idea of using a stack, works nicely!

// copilot/stack overflow
// (https://stackoverflow.com/questions/28541609/looking-for-reasonable-stack-implementation-in-golang)
// stack implementation
type Stack struct {
    data []rune
}

func NewStack() *Stack {
    return &Stack{
        data: make([]rune, 0),
    }
}

func (s *Stack) push(v rune) {
    s.data = append(s.data, v)
}

func (s *Stack) pop() rune {
    v := (s.data)[len(s.data)-1]
    s.data = (s.data)[:len(s.data)-1]
    return v
}

func (s *Stack) last() rune {
    return (s.data)[len(s.data)-1]
}
// end of copilot/stack overflow stack implementation

func closerFor(opener rune) rune {
    switch opener {
    case '(':
        return ')'
    case '[':
        return ']'
    case '{':
        return '}'
    case '<':
        return '>'
    default:
        return ' '
    }
}

func checkClosesProperly(opener, closer rune) bool {
    switch opener {
    case '(':
        return closer == ')'
    case '[':
        return closer == ']'
    case '{':
        return closer == '}'
    case '<':
        return closer == '>'
    default:
        return false
    }
}

func errorFor(char rune) int {
    switch char {
    case ')':
        return 3
    case ']':
        return 57
    case '}':
        return 1197
    case '>':
        return 25137
    default:
        return 0
    }
}

func scoreFor(char rune) int {
    switch char {
    case ')':
        return 1
    case ']':
        return 2
    case '}':
        return 3
    case '>':
        return 4
    default:
        return 0
    }
}

func main() {
    fmt.Println("Hello, World!")

    file, err := os.Open("input.txt")
    if err != nil {
        fmt.Println(err)
        return
    }
    defer file.Close()

    scanner := bufio.NewScanner(file)

    sumOfErrors := 0
    errorScore := 0

    i := 1

    incompleteLines := make([]string, 0)

    for scanner.Scan() {
        line := scanner.Text()
        s := NewStack()

        lineIsCorrupt := false
        for pos, char := range line {
            if char == ')' || char == ']' || char == '}' || char == '>' {
                if checkClosesProperly(s.last(), char) {
                    s.pop()
                } else {
                    fmt.Printf("Error at line %d position %d: expected %s got %s\n", i, pos, string(closerFor(s.last())), string(char))
                    sumOfErrors++
                    errorScore += errorFor(char)
                    lineIsCorrupt = true
                    break
                }
            } else {
                s.push(char)
            }
        }

        if !lineIsCorrupt {
            incompleteLines = append(incompleteLines, line)
        }

        i++
    }

    fmt.Println("Part one!")
    fmt.Printf("Score for %d errors: %d\n", sumOfErrors, errorScore)
    fmt.Println()

    // Part two

    scores := make([]int, 0)

    for _, line := range incompleteLines {
        s := NewStack()

        for _, char := range line {
            if char == '(' || char == '[' || char == '{' || char == '<' {
                s.push(char)
            } else if char == ')' || char == ']' || char == '}' || char == '>' {
                s.pop()
            }
        }

        score := 0
        for i = len(s.data) - 1; i >= 0; i-- {
            c := closerFor(s.data[i])
            score = (score * 5) + scoreFor(c)
        }
        scores = append(scores, score)
    }

    sort.Ints(scores)

    fmt.Println("Part two!")
    fmt.Printf("Answer: %d\n", scores[len(scores) / 2])
}
