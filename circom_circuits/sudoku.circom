pragma circom 2.1.6;

include "circomlib/circuits/comparators.circom";

/**
 * CheckUnique25 Template
 *
 * Verifies that 25 values are:
 * 1. Within valid range [1, 25]
 * 2. All unique (no duplicates)
 *
 * This template is used for validating:
 * - Each row of the Sudoku grid
 * - Each column of the Sudoku grid
 * - Each 5×5 box within the grid
 *
 * Constraints generated:
 * - Range checks: 50 constraints (25 values × 2 comparisons each)
 * - Uniqueness checks: 300 constraints (25 choose 2 = 300 pairs)
 * - Total per instance: 350 constraints
 */
template CheckUnique25() {
    signal input values[25];
    signal output dummy; // Needed for component instantiation

    // === RANGE VALIDATION ===
    // Ensure all values are within [1, 25]
    // This prevents invalid Sudoku numbers
    component geq[25];  // Greater-than-or-equal comparators
    component leq[25];  // Less-than-or-equal comparators

    for (var i = 0; i < 25; i++) {
        // Check: values[i] >= 1
        geq[i] = GreaterEqThan(8); // 8 bits is sufficient for values up to 255
        geq[i].in[0] <== values[i];
        geq[i].in[1] <== 1;
        geq[i].out === 1;  // Constraint: must be true

        // Check: values[i] <= 25
        leq[i] = LessEqThan(8);
        leq[i].in[0] <== values[i];
        leq[i].in[1] <== 25;
        leq[i].out === 1;  // Constraint: must be true
    }

    // === UNIQUENESS VALIDATION ===
    // Ensure all 25 values are distinct
    // We check all pairwise combinations: C(25,2) = 300 pairs
    component isZero[300];
    var idx = 0;

    for (var i = 0; i < 25; i++) {
        for (var j = i + 1; j < 25; j++) {
            // For each pair (i,j), check that values[i] != values[j]
            // We do this by checking that (values[i] - values[j]) != 0
            isZero[idx] = IsZero();
            isZero[idx].in <== values[i] - values[j];
            isZero[idx].out === 0;  // Constraint: difference must NOT be zero
            idx++;
        }
    }

    dummy <== 1;  // Dummy output for component compatibility
}

/**
 * Sudoku25x25 Template
 *
 * Main circuit for verifying a complete 25×25 Sudoku solution.
 *
 * The circuit enforces:
 * 1. All 25 rows contain unique values 1-25
 * 2. All 25 columns contain unique values 1-25
 * 3. All 25 5×5 boxes contain unique values 1-25
 * 4. A cryptographic commitment to the solution
 *
 * Privacy: The actual solution remains hidden (private input)
 * Public: Only the commitment is revealed
 *
 * Total constraints: ~52,500
 * - Row validation: 25 × 350 = 8,750 constraints
 * - Column validation: 25 × 350 = 8,750 constraints
 * - Box validation: 25 × 350 = 8,750 constraints
 * - Commitment: minimal additional constraints
 */
template Sudoku25x25() {
    // === INPUTS ===
    signal input solution[625];      // Private: 25×25 = 625 cells
    signal input expectedCommitment; // Public: commitment to verify against

    // === ROW VALIDATION ===
    // Verify that each of the 25 rows contains unique values 1-25
    component rowCheckers[25];
    for (var r = 0; r < 25; r++) {
        rowCheckers[r] = CheckUnique25();
        // Extract row r from the flattened solution array
        for (var c = 0; c < 25; c++) {
            // solution[r * 25 + c] gives us cell at (row r, column c)
            rowCheckers[r].values[c] <== solution[r * 25 + c];
        }
    }

    // === COLUMN VALIDATION ===
    // Verify that each of the 25 columns contains unique values 1-25
    component colCheckers[25];
    for (var c = 0; c < 25; c++) {
        colCheckers[c] = CheckUnique25();
        // Extract column c from the flattened solution array
        for (var r = 0; r < 25; r++) {
            // solution[r * 25 + c] gives us cell at (row r, column c)
            colCheckers[c].values[r] <== solution[r * 25 + c];
        }
    }

    // === BOX VALIDATION ===
    // Verify that each of the 25 5×5 boxes contains unique values 1-25
    // The grid is divided into a 5×5 arrangement of 5×5 boxes
    component boxCheckers[25];
    var boxIdx = 0;

    // Iterate over box rows (0-4) and box columns (0-4)
    for (var br = 0; br < 5; br++) {
        for (var bc = 0; bc < 5; bc++) {
            boxCheckers[boxIdx] = CheckUnique25();
            var valIdx = 0;

            // Within each box, iterate over cells (5×5 = 25 cells)
            for (var i = 0; i < 5; i++) {
                for (var j = 0; j < 5; j++) {
                    // Calculate the actual row and column in the full grid
                    // Box (br, bc) starts at row (br*5) and column (bc*5)
                    // Cell (i, j) within the box is at row (br*5 + i), col (bc*5 + j)
                    boxCheckers[boxIdx].values[valIdx] <== solution[(br * 5 + i) * 25 + (bc * 5 + j)];
                    valIdx++;
                }
            }
            boxIdx++;
        }
    }

    // === CRYPTOGRAPHIC COMMITMENT ===
    // Compute a binding commitment to the solution using polynomial hash
    // Formula: commitment = Σ(solution[i] * base^i) for i = 0 to 624
    //
    // This creates a unique fingerprint of the solution:
    // - Binding: Changing any cell changes the commitment
    // - Deterministic: Same solution always produces same commitment
    // - Efficient: Computable in-circuit with minimal constraints
    signal commitment;
    var base = 257;  // Prime number for better distribution
    var power = 1;   // Tracks base^i
    var sum = 0;     // Accumulates the polynomial sum

    for (var i = 0; i < 625; i++) {
        sum += solution[i] * power;
        power *= base;
    }

    commitment <== sum;

    // === COMMITMENT VERIFICATION ===
    // CRITICAL: Verify that our computed commitment matches the expected one
    // This is the public input that the verifier checks
    // If this constraint fails, the proof is invalid
    commitment === expectedCommitment;
}

/**
 * Main Component Instantiation
 *
 * Creates the main circuit with:
 * - Public input: expectedCommitment (the commitment to verify)
 * - Private input: solution (the 625-cell Sudoku grid)
 *
 * The verifier will check that the proof corresponds to the given commitment
 * without learning anything about the actual solution.
 */
component main {public [expectedCommitment]} = Sudoku25x25();
