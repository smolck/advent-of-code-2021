#include <vector>
#include <iostream>

std::vector<std::vector<int>> readInput(const char* file) {
    std::vector<std::vector<int>> input = { {} };

    FILE* fp = fopen(file, "r");
    if (fp == NULL)
        exit(EXIT_FAILURE);

    size_t i = 0;

    while (true) {
        char c = fgetc(fp);
        if (c == EOF)
            break;
        else if (c == '\n') {
            input.push_back({});
            i++;
            continue;
        } else {
            input[i].push_back(c - '0');
        }
    }

    fclose(fp);
    return input;
}

std::vector<int> vecWithRepeating(size_t capacity, int repeat) {
    std::vector<int> vec;
    vec.reserve(capacity);
    for (size_t i = 0; i < capacity; i++) {
        vec.push_back(repeat);
    }
    return vec;
}

void padVector(std::vector<std::vector<int>>& v, int padValue) {
    auto padding = vecWithRepeating(v.size() - 1, padValue);
    v.insert(v.begin(), padding);
    v[v.size() - 1] = padding; // The last element in `input` is for some reason empty, so we just use it as the padding.

    for (auto &row : v) {
        row.insert(row.begin(), padValue);
        row.push_back(padValue);
    }
}

struct Position {
    int row, col;
};

int traverse(int acc, Position startingPos, std::vector<std::vector<int>>& v) {
    int ret = acc;

    Position positions[8];
    int sr = startingPos.row;
    int sc = startingPos.col;

    positions[0] = { .row = sr - 1, .col = sc - 1 }; // top left
    positions[1] = { .row = sr - 1, .col = sc     }; // top middle
    positions[2] = { .row = sr - 1, .col = sc + 1 }; // top right

    positions[3] = { .row = sr    , .col = sc - 1 }; // left
    positions[4] = { .row = sr    , .col = sc + 1 }; // right

    positions[5] = { .row = sr + 1, .col = sc - 1 }; // bottom left
    positions[6] = { .row = sr + 1, .col = sc     }; // bottom middle
    positions[7] = { .row = sr + 1, .col = sc + 1 }; // bottom right

    for (const Position &pos : positions) {
        if (v[pos.row][pos.col] == 0) {
            continue;
        }
        v[pos.row][pos.col]++;
        if (v[pos.row][pos.col] > 9) {
            ret++;
            v[pos.row][pos.col] = 0;
            ret += traverse(0, pos, v);
        }
    }

    return ret;
}

int runStep(std::vector<std::vector<int>>& v) {
    int flashes = 0;
    std::vector<Position> positions;
    positions.reserve(10); // arbitrary

    // 1 and - 1 to only iterate within valid grid, the rest is just padding
    for (int row = 1; row < v.size() - 1; row++) {
        for (int col = 1; col < v[row].size() - 1; col++) {
            v[row][col]++;
            if (v[row][col] > 9) {
                flashes++;
                v[row][col] = 0;
                positions.push_back({ .row = row, .col = col });
            }
        }
    }

    for (auto &pos : positions) {
        flashes += traverse(0, pos, v);
    }

    return flashes;
}

int main() {
    auto input = readInput("input.txt");

    // arbitrary padding number, just small enough such that it'll never be > 0,
    // so absolute value should be smaller than total iteration number.
    int padding = -5000;
    padVector(input, padding);

    int flashes = 0;

    // Part one
    for (int i = 0; i < 100; i++) {
        flashes += runStep(input);
    }

    std::cout << "Part one answer: " << flashes << " flashes occurred over 100 steps\n";

    // Part two
    int step = 100; // 100 for previous iterations above
    while (true) {
        int numFlashed = runStep(input);
        step++;

        if (numFlashed == (input[1].size() - 2) * (input.size() - 2)) {
            break;
        }
    }

    std::cout << "Part two answer: at step " << step << " the octupuses flashed simultaneously\n";
}
