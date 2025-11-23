use dep::std;

fn main(solution: [u8; 625], expected_commitment: pub Field) {
    // 1. Verify full 25x25 Sudoku constraints
    verify_sudoku(solution);

    // 2. Compute commitment from solution
    let actual_commitment = compute_board_commitment(solution);

    // 3. CRITICAL: Assert that computed commitment matches expected commitment
    // This ensures the verifier checks the commitment as a public input
    assert(actual_commitment == expected_commitment);
}

fn compute_board_commitment(grid: [u8; 625]) -> Field {
    // Create a binding commitment by hashing all cells
    // We use a simple polynomial hash: sum of (cell_value * position^power)
    // This is binding because changing any cell changes the commitment

    let mut commitment: Field = 0;
    let base: Field = 257; // Prime number for better distribution
    let mut power: Field = 1;

    for i in 0..625 {
        commitment = commitment + (grid[i] as Field) * power;
        power = power * base;
    }

    commitment
}

fn verify_sudoku(grid: [u8; 625]) {
    // Verify ALL rows
    for r in 0..25 {
        let mut row_vals = [0; 25];
        for c in 0..25 {
            row_vals[c] = grid[r * 25 + c];
        }
        assert_unique(row_vals);
    }

    // Verify ALL columns
    for c in 0..25 {
        let mut col_vals = [0; 25];
        for r in 0..25 {
            col_vals[r] = grid[r * 25 + c];
        }
        assert_unique(col_vals);
    }

    // Verify ALL 5x5 sub-grids (boxes)
    for br in 0..5 {
        for bc in 0..5 {
            let mut box_vals = [0; 25];
            for i in 0..5 {
                for j in 0..5 {
                    box_vals[i * 5 + j] = grid[(br * 5 + i) * 25 + (bc * 5 + j)];
                }
            }
            assert_unique(box_vals);
        }
    }
}

fn assert_unique(vals: [u8; 25]) {
    // Verify each value is in range [1, 25]
    for i in 0..25 {
        assert(vals[i] >= 1);
        assert(vals[i] <= 25);
    }

    // Verify all values are unique (pairwise comparison)
    for i in 0..25 {
        for j in (i + 1)..25 {
            assert(vals[i] != vals[j]);
        }
    }
}
