use std::collections::{binary_heap::BinaryHeap, HashMap};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd)]
struct Node {
    x: i32,
    y: i32,
    risk: u32,
}

impl Ord for Node {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        other
            .risk
            .cmp(&self.risk)
            .then_with(|| self.x.cmp(&other.x))
            .then_with(|| self.y.cmp(&other.y))
    }
}

fn manhattan_dist(n1: &Node, n2: &Node) -> u32 {
    ((n2.x - n1.x).abs() + (n2.y - n1.y).abs()) as u32
}

fn main() {
    let input = include_str!("../example-input.txt");
    let line_length = input.split("\n").next().unwrap().len() as i32;
    let input = input
        .split("\n")
        .enumerate()
        .map(|(row, line)| {
            line.chars().enumerate().map(move |(col, x)| Node {
                risk: x.to_digit(10).unwrap(),
                x: col as i32,
                y: row as i32,
            })
        })
        .flatten()
        .collect::<Vec<Node>>();

    let mut frontier = BinaryHeap::new();
    frontier.push((&input[0], 0));

    let mut came_from = HashMap::new();
    let mut cost_so_far = HashMap::new();
    came_from.insert(&input[0], None);
    cost_so_far.insert(&input[0], 0);

    while let Some((current, _)) = frontier.pop() {
        let current_idx = (line_length * current.y + current.x) as usize;
        let idx_above = ((line_length * (current.y - 1)) + current.x) as usize;
        let idx_below = ((line_length * (current.y + 1)) + current.x) as usize;

        let neighbors = &[
            input.get(current_idx + 1), // right
            input.get(current_idx.wrapping_sub(1)), // left
            input.get(idx_above), // above
            input.get(idx_below), // below
        ];

        for next in neighbors {
            if let Some(next) = next {
                let new_cost = cost_so_far[&current] + next.risk;
                if !cost_so_far.contains_key(next) || new_cost < cost_so_far[next] {
                    if let Some(cost) = cost_so_far.get_mut(next) {
                        *cost = new_cost;
                    } else {
                        cost_so_far.insert(next, new_cost);
                    }

                    let prio = new_cost + manhattan_dist(next, input.last().unwrap());
                    frontier.push((next, prio));
                    came_from.insert(next, Some(current));
                }
            }
        }
    }

    let mut risk = 0;
    let mut current = input.last().unwrap();

    loop {
        println!("({}, {})", current.x, current.y);
        risk += current.risk;
        if let Some(node) = came_from[current] {
            current = node;
        } else {
            break;
        }
    }
    println!("{:?}", cost_so_far.values());

    println!("{:?}", risk);
}
