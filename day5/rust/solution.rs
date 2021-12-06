#![feature(hash_drain_filter)]

use std::collections::HashMap;

#[derive(Debug, Hash, PartialOrd, PartialEq, Eq)]
struct Point {
    x: i32,
    y: i32,
}

#[derive(Debug)]
struct Line(Point, Point);

impl Line {
    fn is_straight(&self) -> bool {
        let Line(Point { x: x0, y: y0 }, Point { x: x1, y: y1 }) = self;

        x0 == x1 || y0 == y1
    }

    // Bresenham's line algorithm (https://en.wikipedia.org/wiki/Bresenham's_line_algorithm#All_cases)
    //
    // TODO(smolck): I should probably look into exactly how this works with the err and stuff, haven't taken the
    // time to understand how it works exactly . . .
    fn points(&self) -> Vec<Point> {
        let Line(Point { x: x0, y: y0 }, Point { x: x1, y: y1 }) = self;

        let dx = (x1 - x0).abs();
        let sx = if x0 < x1 { 1 } else { -1 };
        let dy = -(y1 - y0).abs();
        let sy = if y0 < y1 { 1 } else { -1 };
        let mut points = vec![];

        let mut err = dx + dy;
        let mut x = x0.clone();
        let mut y = y0.clone();

        loop {
            points.push(Point { x, y });
            if x == *x1 && y == *y1 { break; }

            let e2 = 2 * err;
            if e2 >= dy {
                err += dy;
                x += sx;
            }

            if e2 <= dx {
                err += dx;
                y += sy;
            }
        }

        return points;
    }
}

fn parse_input(input: &str) -> Vec<Line> {
    input
        .lines()
        .map(|line| {
            let mut parts = line.split(" -> ");

            let mut p1 = parts.next().unwrap().split(",");
            let x1 = p1.next().unwrap().parse::<i32>().unwrap();
            let y1 = p1.next().unwrap().parse::<i32>().unwrap();

            let mut p2 = parts.next().unwrap().split(",");
            let x2 = p2.next().unwrap().parse::<i32>().unwrap();
            let y2 = p2.next().unwrap().parse::<i32>().unwrap();

            let p1 = Point { x: x1, y: y1 };
            let p2 = Point { x: x2, y: y2 };

            Line(p1, p2)
            /*if p1 > p2 {
                Line(p2, p1)
            } else {
                Line(p1, p2)
            }*/
        })
        .collect()
}

fn main() {
    // let example_input = include_str!("example-input.txt");
    let input = include_str!("input.txt");

    // Part one
    let mut map: HashMap<Point, i32> = HashMap::new();
    for point in parse_input(input).iter().filter(|line| line.is_straight()).flat_map(|line| line.points()) {
        if map.contains_key(&point) {
            let thing = map.get_mut(&point).unwrap();
            *thing += 1;
        } else {
            map.insert(point, 1);
        }
    }

    println!("Part one answer: {:?}", map.drain_filter(|_k, v| v >= &mut 2).collect::<HashMap<Point, i32>>().len());

    let mut map: HashMap<Point, i32> = HashMap::new();
    for point in parse_input(input).iter().flat_map(|line| line.points()) {
        if map.contains_key(&point) {
            let thing = map.get_mut(&point).unwrap();
            *thing += 1;
        } else {
            map.insert(point, 1);
        }
    }

    println!("Part two answer: {:?}", map.drain_filter(|_k, v| v >= &mut 2).collect::<HashMap<Point, i32>>().len());
    // println!("{:?}", Line(Point { x: 0, y: 1 }, Point { x: 6, y: 4 }).points());
}
