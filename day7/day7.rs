fn main() {
    let mut input = include_str!("input.txt").split(",").map(|x| x.trim().parse::<i32>().unwrap()).collect::<Vec<i32>>();
    input.sort();

    let mut smallest_sum1 = i32::MAX;
    let mut smallest_sum2 = i32::MAX;

    let last = input[input.len() - 1];

    for align in 0..last {
        let mut sum1 = 0;
        let mut sum2 = 0;

        for num in &input {
            let n = (num - align).abs();

            sum1 += n;
            sum2 += (n * (n + 1)) / 2
        }

        if sum1 < smallest_sum1 {
            smallest_sum1 = sum1;
        }

        if sum2 < smallest_sum2 {
            smallest_sum2 = sum2;
        }
    }

    println!("Part one solution: {}", smallest_sum1);
    println!("Part two solution: {}", smallest_sum2);
}
