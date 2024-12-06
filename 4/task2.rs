use std::io;
use std::ops::Index;

#[derive(Debug)]
struct CharMat {
    buffers: Vec<Vec<u8>>
}

impl Index<(i32, i32)> for CharMat {
    type Output = u8;

    fn index(&self, pair: (i32, i32)) -> &Self::Output {
        if pair.0 < 0 || pair.1 < 0 {
            return &0;
        }
        let length: i32 = self.buffers.len() as i32;
        let width: i32 = self.buffers[0].len() as i32;
        if pair.0 >= length || pair.1 >= width {
            return &0;
        }
        let l = pair.0 as usize;
        let w = pair.1 as usize;

        &self.buffers[l][w]
    }
}

impl CharMat {
    fn length(&self) -> i32 {
        self.buffers.len() as i32
    }

    fn width(&self) -> i32 {
        self.buffers[0].len() as i32
    }

    fn generate_words(&self, x: i32, y: i32) -> [[u8; 3]; 4] {
        let mut out = [[0; 3]; 4];

        for e in 0..=2 {
            let i = e as i32-1;
            out[0][e] = self[(x+i, y+i)];
            out[1][e] = self[(x+i, y-i)];
            out[2][e] = self[(x-i, y+i)];
            out[3][e] = self[(x-i, y-i)];
        }

        return out;
    }

    fn xmas(&self, x: i32, y: i32) -> usize {
        let p = x == 5 && y == 2;
        let c = 
            self.generate_words(x, y)
            .iter()
            .map(|w| {
                if p {
                    println!("ws: {:?}", std::str::from_utf8(w).unwrap());
                }
                w
            })
            .filter(|w| *w == "MAS".as_bytes())
            .map(|w| {
                if p {
                    println!("wf: {:?}", std::str::from_utf8(w).unwrap());
                }
                w
            })
            .count();

        if c>1 {1} else {0}
    }

    fn create_char_mat() -> CharMat {
        let stdin = io::stdin();
        let mut buffers: Vec<Vec<u8>> = vec![];
        for line in stdin.lines() {
            let content = line.unwrap();
            println!("Got line: {}", content);
            if content.len() > 0 {
                buffers.push(content.as_bytes().to_vec());
            }
        }

        CharMat{ buffers: buffers }
    }
}


fn main() -> io::Result<()> {
    let mat = CharMat::create_char_mat();
    println!("{:?}", mat);
    let mut sum = 0;
    for x in 0..mat.length() {
        for y in 0..mat.width() {
            let a = mat.xmas(x, y);
            sum += a;
            if a > 0 {
                println!("===> {:?}", (x, y));
                println!("{:?}", a);
                println!("sum: {:?}", sum);
            }
        }
    }
    println!("Answer: {:?}", sum);
    Ok(())
}
