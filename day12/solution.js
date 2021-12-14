const fs = require('fs');

// https://stackoverflow.com/a/31415820
const isLowerCase = (str) => str == str.toLowerCase() && str != str.toUpperCase()

const input = fs.readFileSync('input.txt', 'utf8')
const map = new Map()
for (const line of input.split('\n')) {
    if (line === "") {
        continue;
    }

    const [cave1, cave2] = line.split('-')
    if (map[cave1]) {
        map[cave1].push(cave2)
    } else {
        map[cave1] = [cave2]
    }

    if (map[cave2]) {
        map[cave2].push(cave1)
    } else {
        map[cave2] = [cave1]
    }
}

const partOne = () => {
    const visited = new Map()
    let count = 0

    // @seandewar wrote this, although I had gotten pretty far myself just not quite.
    // TYVM Sean, for helping me *again* :)
    const search = (cave) => {
        if ((visited[cave] > 0 && isLowerCase(cave)) || cave === "start") {
            return;
        }

        if (cave === "end") {
            count++;
            return;
        }

        if (isLowerCase(cave)) {
            if (visited[cave]) {
                visited[cave]++
            } else {
                visited[cave] = 1
            }
        }

        for (const subcave of map[cave]) {
            search(subcave)
        }

        visited[cave]--
    }

    for (const cave of map['start']) {
        search(cave)
    }

    return count
}

// Part one
console.log(`Part one: ${partOne()}`)

const partTwo = () => {
    const visited = new Map()
    let count = 0

    let caveWeCanVisitTwice

    const search = (cave) => {
        if (cave === "start") {
            return;
        }

        // Thanks @seandewar for helping me with this as well :D
        let caveWasSet = false
        if (visited[cave] > 0 && isLowerCase(cave)) {
            if (caveWeCanVisitTwice) {
                if (cave !== caveWeCanVisitTwice) {
                    return
                } else {
                    if (visited[cave] > 1) {
                        return
                    }
                }
            } else {
                caveWeCanVisitTwice = cave
                caveWasSet = true
            }
        }

        if (cave === "end") {
            count++;
            return;
        }

        if (isLowerCase(cave)) {
            if (visited[cave]) {
                visited[cave]++
            } else {
                visited[cave] = 1
            }
        }

        for (const subcave of map[cave]) {
            search(subcave)
        }

        visited[cave]--
        if (caveWasSet) {
            caveWeCanVisitTwice = undefined
        }
    }

    for (const cave of map['start']) {
        search(cave)
    }

    return count
}

// Part two
console.log(`Part two: ${partTwo()}`)
