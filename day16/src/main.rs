fn decode_input(input: &str) -> String {
    let mut decoded = String::new();
    decoded.reserve(input.len() * 4);

    for c in input.chars() {
        if c == '\n' {
            break; // only do one line of input
        }

        decoded.push_str(match c {
            '0' => "0000",
            '1' => "0001",
            '2' => "0010",
            '3' => "0011",
            '4' => "0100",
            '5' => "0101",
            '6' => "0110",
            '7' => "0111",
            '8' => "1000",
            '9' => "1001",
            'A' => "1010",
            'B' => "1011",
            'C' => "1100",
            'D' => "1101",
            'E' => "1110",
            'F' => "1111",
            _ => unreachable!(),
        });
    }

    decoded
}

#[derive(Debug)]
struct Header {
    version: u8,
    type_id: u8,
}

fn parse_header<I>(i: &mut I) -> Header
where
    I: Iterator<Item = char>,
{
    let mut version: u8 = 0;
    if i.next().unwrap() == '1' {
        version |= 1 << 2
    };
    if i.next().unwrap() == '1' {
        version |= 1 << 1
    };
    if i.next().unwrap() == '1' {
        version |= 1
    };

    let mut type_id: u8 = 0;
    if i.next().unwrap() == '1' {
        type_id |= 1 << 2
    };
    if i.next().unwrap() == '1' {
        type_id |= 1 << 1
    };
    if i.next().unwrap() == '1' {
        type_id |= 1
    };

    Header { version, type_id }
}

#[derive(Debug)]
enum Packet {
    LiteralPacket {
        version: u8,
        value: u64,
    },
    OperatorPacket {
        version: u8,
        subpackets: Vec<Packet>,
    },
}

fn parse_literal_packet<I>(i: &mut I) -> (i32, u64)
where
    I: Iterator<Item = char>,
{
    let mut num = String::new();
    num.reserve(33);

    let mut read_bits = 0;
    loop {
        let c = i.next().unwrap();

        num.push(i.next().unwrap());
        num.push(i.next().unwrap());
        num.push(i.next().unwrap());
        num.push(i.next().unwrap());

        read_bits += 5;
        if c == '0' {
            break;
        }
    }

    (read_bits, u64::from_str_radix(&num, 2).unwrap())
}

fn parse_packet<I>(i: &mut I) -> (i32, Packet)
where
    I: Iterator<Item = char>,
{
    let header = parse_header(i);
    if header.type_id == 4 {
        let (read_bits, p) = parse_literal_packet(i);
        return (
            6 + read_bits,
            Packet::LiteralPacket {
                version: header.version,
                value: p,
            },
        );
    }

    let mut read_bits = 6;
    let length_type_id = i.next().unwrap().to_digit(2).unwrap();
    read_bits += 1;

    #[derive(Debug)]
    enum ForParsing {
        TotalBitsOfSubpackets(u32),
        NumOfSubpackets(u32),
    }

    let for_parsing = if length_type_id == 0 {
        let mut total_bits = String::with_capacity(15);

        for _ in 0..15 {
            total_bits.push(i.next().unwrap());
            read_bits += 1;
        }

        ForParsing::TotalBitsOfSubpackets(u32::from_str_radix(&total_bits, 2).unwrap())
    } else {
        let mut num_of_subpackets = String::with_capacity(11);

        for _ in 0..11 {
            num_of_subpackets.push(i.next().unwrap());
            read_bits += 1;
        }

        ForParsing::NumOfSubpackets(u32::from_str_radix(&num_of_subpackets, 2).unwrap())
    };

    let mut subpackets = vec![];
    match for_parsing {
        ForParsing::NumOfSubpackets(n) => {
            for _ in 0..n {
                let (b, p) = parse_packet(i);
                subpackets.push(p);
                read_bits += b;
            }
        }
        ForParsing::TotalBitsOfSubpackets(total_bits) => {
            let mut current_bits_read = 0;
            while current_bits_read < total_bits as i32 {
                let (b, p) = parse_packet(i);
                subpackets.push(p);
                current_bits_read += b;
            }

            read_bits += total_bits as i32;
        }
    }

    (read_bits, Packet::OperatorPacket { version: header.version, subpackets })
}

fn sum_packet_versions(packet: &Packet) -> u32 {
    match packet {
        Packet::LiteralPacket { version, .. } => *version as u32,
        Packet::OperatorPacket { version, subpackets } => {
            let mut sum = *version as u32;
            for subpacket in subpackets {
                sum += sum_packet_versions(subpacket);
            }

            sum
        }
    }
}

fn main() {
    let input = decode_input(include_str!("../input.txt"));

    let mut char_iter = input.chars().into_iter();
    let (_bits_read, p) = parse_packet(&mut char_iter);

    println!("Part one answer, sum of packet versions: {}", sum_packet_versions(&p));
}
