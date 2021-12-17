#include <vector>
#include <array>
#include <iostream>
#include <fcntl.h> // O_RDONLY
#include <sys/stat.h> // struct stat
#include <sys/mman.h> // PROT_READ, MAP_PRIVATE

// ref for mmap stuff https://stackoverflow.com/a/20460969
std::array<int, 100> readInput(const char* file) {
    std::array<int, 100> input;

    // Pls no mem leaks or UB, I'm a programmer not a cop :D
    // (okay that second part is a copilot completion and I'm leaving it)
    int fd = open(file, O_RDONLY);

    // Get the size of the file.
    struct stat s;
    int status = fstat (fd, & s);
    int fsize = s.st_size;

    char *f = (char *)mmap(0, fsize, PROT_READ, MAP_PRIVATE, fd, 0);

    int idx = 0;
    for (int i = 0; i < fsize; i++) {
        char c = f[i];
        if (c == '\n') {
            continue;
        } else {
            input[idx] = c - '0';
            idx++;
        }
    }

    return input;
}

struct Position {
    int row, col;
};

int traverse(int acc, Position startingPos, std::array<int, 100>& arr) {
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

    int ret = acc;
    for (const auto &pos : positions) {
        if (pos.row < 0 || pos.row > 9 || pos.col < 0 || pos.col > 9) {
            continue;
        }
        auto idx = pos.row * 10 + pos.col;

        if (arr[idx] == 0) {
            continue;
        }
        arr[idx]++;

        if (arr[idx] > 9) {
            ret++;
            arr[idx] = 0;
            ret += traverse(0, pos, arr);
        }
    }

    return ret;
}

int runStep(std::array<int, 100>& v) {
    int flashes = 0;
    std::vector<Position> positions;
    positions.reserve(10); // arbitrary

    for (int row = 0; row < 10; row++) {
        for (int col = 0; col < 10; col++) {
            int idx = row * 10 + col;

            v[idx]++;
            if (v[idx] > 9) {
                flashes++;
                v[idx] = 0;
                positions.push_back({ .row = row, .col = col });
            }
        }
    }

    for (const auto &pos : positions) {
        flashes += traverse(0, pos, v);
    }

    return flashes;
}

int main() {
    std::array<int, 100> input = readInput("input.txt");

    int flashes = 0;

    // Part one
    for (int i = 0; i < 100; i++) {
        flashes += runStep(input);
    }

    std::cout << "Part one answer: " << flashes << " flashes occurred over 100 steps\n";

    // Part two
    int step = 100; // 100 for previous iterations above

    int numFlashed = 0;
    do {
        numFlashed = runStep(input);
        step++;
    } while(numFlashed != 100);

    std::cout << "Part two answer: at step " << step << " the octupuses flashed simultaneously\n";
}
