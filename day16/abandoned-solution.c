#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <stdbool.h>

typedef struct {
    char *str;
    ssize_t len;
} string;

string readInput(char* fname) {
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;

    fp = fopen(fname, "r");
    if (fp == NULL) exit(EXIT_FAILURE);

    read = getline(&line, &len, fp);
    fclose(fp);

    string s;
    s.str = line;
    s.len = read;

    return s;
}

void set(char* str, int idx, char one, char two, char three, char four) {
    str[idx * 4] = one;
    str[idx * 4 + 1] = two;
    str[idx * 4 + 2] = three;
    str[idx * 4 + 3] = four;
}

string decodeInput(string input) {
    char* decoded = malloc(input.len * 4 + 1);
    ssize_t decoded_size = input.len * 4 + 1;

    // input.len - 1 to ignore newline
    for (int i = 0; i < input.len - 1; i++) {
        /*
         * 0 = 0000
         * 1 = 0001
         * 2 = 0010
         * 3 = 0011
         * 4 = 0100
         * 5 = 0101
         * 6 = 0110
         * 7 = 0111
         * 8 = 1000
         * 9 = 1001
         * A = 1010
         * B = 1011
         * C = 1100
         * D = 1101
         * E = 1110
         * F = 1111
         */
        switch (input.str[i]) {
            case '0':
                set(decoded, i, '0', '0', '0', '0');
                break;
            case '1':
                set(decoded, i, '0', '0', '0', '1');
                break;
            case '2':
                set(decoded, i, '0', '0', '1', '0');
                break;
            case '3':
                set(decoded, i, '0', '0', '1', '1');
                break;
            case '4':
                set(decoded, i, '0', '1', '0', '0');
                break;
            case '5':
                set(decoded, i, '0', '1', '0', '1');
                break;
            case '6':
                set(decoded, i, '0', '1', '1', '0');
                break;
            case '7':
                set(decoded, i, '0', '1', '1', '1');
                break;
            case '8':
                set(decoded, i, '1', '0', '0', '0');
                break;
            case '9':
                set(decoded, i, '1', '0', '0', '1');
                break;
            case 'A':
                set(decoded, i, '1', '0', '1', '0');
                break;
            case 'B':
                set(decoded, i, '1', '0', '1', '1');
                break;
            case 'C':
                set(decoded, i, '1', '1', '0', '0');
                break;
            case 'D':
                set(decoded, i, '1', '1', '0', '1');
                break;
            case 'E':
                set(decoded, i, '1', '1', '1', '0');
                break;
            case 'F':
                set(decoded, i, '1', '1', '1', '1');
                break;
        }
    }
    decoded[decoded_size] = '\0';

    string ret;
    ret.str = decoded;
    ret.len = decoded_size;

    return ret;
}

void print_bits(int c) {
    for (int i = CHAR_BIT - 1; i >= 0; --i) {
        printf("%d", (c >> i) & 1);
    }

    printf("\n");
}

typedef struct Packet {
    int _offset;

    uint8_t version;
    uint8_t typeID;

    uint16_t number;

    // These are only set if typeID != 4
    uint8_t lengthTypeID;
    struct Packet* subpackets;
} packet;

int versionSum = 0;

packet parsePacket(char* s, int startingIdx) {
    packet p;

    // TODO(smolck): Need to keep track of the current position in the parsing more globally . . .
    // maybe
    int i = startingIdx;

    uint8_t version = 0;
    if (s[i++] == '1') version |= (1 << 2);
    if (s[i++] == '1') version |= (1 << 1);
    if (s[i++] == '1') version |= (1     );

    versionSum += version;
    p.version = version;

    uint8_t typeID = 0;
    if (s[i++] == '1') typeID |= (1 << 2);
    if (s[i++] == '1') typeID |= (1 << 1);
    if (s[i++] == '1') typeID |= (1     );

    p.typeID = typeID;

    if (typeID == 4) { // Literal value
        bool readLast = false;
        // uint16_t num = 0;
        // int n = 0;

        char *num = malloc(33);

        int j = 0;
        while (!readLast) {
            char c = s[i++];

            num[j++] = s[i++];
            num[j++] = s[i++];
            num[j++] = s[i++];
            num[j++] = s[i++];
            if (c == '0') {
                num[j++] = '\0';
                readLast = true;
            }
            /*printf("%c", s[i + 0]);
            printf("%c", s[i + 1]);
            printf("%c", s[i + 2]);
            printf("%c", s[i + 3]);*/
            // printf("\n");

            /*if (c == '0' && n == 0) { // TODO(smolck): Is this right?
                if (s[i++] == '1') num |= (1 << 4);
                if (s[i++] == '1') num |= (1 << 3);
                if (s[i++] == '1') num |= (1 << 2);
                if (s[i++] == '1') num |= (1 << 1);

                n += 4;
                readLast = true;
            } else if (c == '0') { // last bits of packet
                if (s[i++] == '1') num |= (1 << (11 - n));
                if (s[i++] == '1') num |= (1 << (10 - n));
                if (s[i++] == '1') num |= (1 << (9 - n));
                if (s[i++] == '1') num |= (1 << (8 - n));

                n += 4;
                readLast = true;
            } else {
                if (s[i++] == '1') num |= (1 << (11 - n));
                if (s[i++] == '1') num |= (1 << (10 - n));
                if (s[i++] == '1') num |= (1 << (9 - n));
                if (s[i++] == '1') num |= (1 << (8 - n));

                n += 4;
            }*/
        }

        p.number = strtol(num, NULL, 2);
        free(num);
    } else { // Operator packet
        uint8_t lengthTypeID = s[i++] - '0';

        if (lengthTypeID == 0) { // 15 bits, total length in bits of subpackets
            uint16_t totalBitsInSubpackets = 0;

            if (s[i++] == '1') totalBitsInSubpackets |= (1 << 14);
            if (s[i++] == '1') totalBitsInSubpackets |= (1 << 13);
            if (s[i++] == '1') totalBitsInSubpackets |= (1 << 12);
            if (s[i++] == '1') totalBitsInSubpackets |= (1 << 11);
            if (s[i++] == '1') totalBitsInSubpackets |= (1 << 10);
            if (s[i++] == '1') totalBitsInSubpackets |= (1 << 9);
            if (s[i++] == '1') totalBitsInSubpackets |= (1 << 8);
            if (s[i++] == '1') totalBitsInSubpackets |= (1 << 7);
            if (s[i++] == '1') totalBitsInSubpackets |= (1 << 6);
            if (s[i++] == '1') totalBitsInSubpackets |= (1 << 5);
            if (s[i++] == '1') totalBitsInSubpackets |= (1 << 4);
            if (s[i++] == '1') totalBitsInSubpackets |= (1 << 3);
            if (s[i++] == '1') totalBitsInSubpackets |= (1 << 2);
            if (s[i++] == '1') totalBitsInSubpackets |= (1 << 1);
            if (s[i++] == '1') totalBitsInSubpackets |= (1     );

            int bitsTraversed = 0;
            packet* packets = malloc(sizeof(packet) * 15);
            int n = 0;

            while (bitsTraversed < totalBitsInSubpackets) {
                packet p = parsePacket(s, i);
                printf("i: %d, offset: %d\n", i, p._offset);
                bitsTraversed += p._offset;
                i += p._offset;

                packets[n++] = p;
            }

            p.subpackets = packets;
        } else {
            int subpacketsContained = 0;

            if (s[i++] == '1') subpacketsContained |= (1 << 11);
            if (s[i++] == '1') subpacketsContained |= (1 << 10);
            if (s[i++] == '1') subpacketsContained |= (1 << 9);
            if (s[i++] == '1') subpacketsContained |= (1 << 8);
            if (s[i++] == '1') subpacketsContained |= (1 << 7);
            if (s[i++] == '1') subpacketsContained |= (1 << 6);
            if (s[i++] == '1') subpacketsContained |= (1 << 5);
            if (s[i++] == '1') subpacketsContained |= (1 << 4);
            if (s[i++] == '1') subpacketsContained |= (1 << 3);
            if (s[i++] == '1') subpacketsContained |= (1 << 2);
            if (s[i++] == '1') subpacketsContained |= (1 << 1);
            if (s[i++] == '1') subpacketsContained |= (1     );

            int packetsTraversed = 0;
            packet* packets = malloc(sizeof(packet) * 15);
            int n = 0;

            printf("subpackets contained: %d\n", subpacketsContained);
            while (packetsTraversed < subpacketsContained) {
                packet p = parsePacket(s, i);
                printf("i: %d, offset: %d\n", i, p._offset);
                i += p._offset;

                packets[n++] = p;
                packetsTraversed++;
            }

            // printf("other version, subpacketsContained: %d\n", subpacketsContained);
        }

        // printf("TODO(smolck): Handle operator packets\n");
    }

    p._offset = i - startingIdx;

    return p;
}

int main() {
    string input = readInput("input.txt");
    string decoded = decodeInput(input);
    free(input.str);

    packet p = parsePacket(decoded.str, 0);
    // packet p = parsePacket("11101110000000001101010000001100100000100011000001100000", 0);
    printf("stuff: %d\n", p.number);
    printf("more stuff: %d\n", versionSum);

    // packet p = parsePacket(decoded.str, 0);
    // printf("%d\n", versionSum);
    // packet p = parsePacket("110100101111111000101000", 0);
    // printf("version: %d, typeID: %d, encoded number: %d\n", p.version, p.typeID, p.number);

    // packet op = parsePacket("00111000000000000110111101000101001010010001001000000000", 0);
    // printf("version: %d, typeID: %d, lengthTypeID: %d, subpackets\n", op.version, op.typeID, op.lengthTypeID);

    // packet stuff = parsePacket("0101001000100100", 0);
    // packet stuff = parsePacket("11010001010", 0);
    // printf("STUFF: %d\n", stuff.number);

    // print_bits(parseInputPartOne(input));
    free(decoded.str);
}
