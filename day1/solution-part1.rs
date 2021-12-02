fn main() {
    // https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.filter_map
    let numbers: Vec<i32> = include_str!("input.txt").split('\n').filter_map(|x| x.parse().ok()).collect();

    let mut sum = 0;
    let mut prev_num = None;
    for num in numbers {
        if let Some(prev_num) = prev_num {
            if num > prev_num {
                sum += 1;
            }
        }

        prev_num = Some(num);
    }

    println!("Answer: {}", sum);
}
