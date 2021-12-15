import std.stdio;
import std.file;
import std.string : split, splitLines, empty;
import std.algorithm: sort;

void main()
{
    string content = readText("input.txt");
    string[] lines = splitLines(content);

    // so I was using `int` and . . . yeah, part 2 of this problem overflows 32-bit integers lol
    long[string] map;
    for (int i = 0; i + 2 <= lines[0].length; i++)
    {
        map[lines[0][i .. i + 2]]++;
    }

    long[char] lettersSum;
    foreach (letter; lines[0])
    {
        lettersSum.require(letter, 0);
        lettersSum[letter]++;
    }

    string[string] polyMap;
    foreach (const ref string line; lines[1 .. lines.length])
    {
        if (empty(line))
        {
            continue;
        }

        string[] split = split(line, " -> ");
        polyMap[split[0]] = split[1];

        // Put all possible combinations in map.
        map.require(split[0], 0);
    }

    long[string] map2 = map.dup;
    long[char] lettersSum2 = lettersSum.dup;

    // Part one
    for (int _ = 0; _ < 10; _++)
    {
        runStep(polyMap, map, lettersSum);
    }

    auto sums = lettersSum.values.sort;
    writeln("Part one answer: ", sums[sums.length - 1] - sums[0]);

    // Part two
    for (int _ = 0; _ < 40; _++)
    {
        runStep(polyMap, map2, lettersSum2);
    }

    auto sums2 = lettersSum2.values.sort;
    writeln("Part two answer: ", sums2[sums2.length - 1] - sums2[0]);
}

void runStep(const ref string[string] polyMap, ref long[string] map, ref long[char] lettersSum)
{
    import std.conv: to;

    string[] keys = map.keys.dup;
    long[string] lookup = map.dup;

    for (int i = 0; i < keys.length; i++)
    {
        if (lookup[keys[i]] == 0) {
            continue;
        }

        string newElement = polyMap[keys[i]];
        lettersSum[newElement[0]] += lookup[keys[i]];

        string firstNewPolymer = to!string(keys[i][0]) ~ newElement;
        string secondNewPolymer = newElement ~ to!string(keys[i][1]);

        auto x = lookup[keys[i]];
        map[keys[i]] -= x;
        map[firstNewPolymer] += x;
        map[secondNewPolymer] += x;
    }
}