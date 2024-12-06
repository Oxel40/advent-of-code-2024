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

    fn generate_words(&self, x: i32, y: i32) -> [[u8; 4]; 8] {
        let mut out = [[0; 4]; 8];

        for e in 0..4 {
            let i = e as i32;
            out[0][e] = self[(x+i, y)];
            out[1][e] = self[(x-i, y)];
            out[2][e] = self[(x, y+i)];
            out[3][e] = self[(x, y-i)];
            out[4][e] = self[(x+i, y+i)];
            out[5][e] = self[(x+i, y-i)];
            out[6][e] = self[(x-i, y+i)];
            out[7][e] = self[(x-i, y-i)];
        }

        return out;
    }

    fn xmas(&self, x: i32, y: i32) -> usize {
        self.generate_words(x, y)
            .iter()
            .map(|w| {
                println!("w: {:?}", w);
                println!("ws: {:?}", std::str::from_utf8(w).unwrap());
                w
            })
            .filter(|w| *w == "XMAS".as_bytes())
            .map(|w| {
                println!("wf: {:?}", w);
                w
            })
            .count()
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
            println!("===> {:?}", (x, y));
            let a = mat.xmas(x, y);
            println!("{:?}", a);
            sum += a;
        }
    }
    println!("Answer: {:?}", sum);
    Ok(())
}
