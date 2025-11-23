pragma circom 2.1.6;

include "circomlib/circuits/comparators.circom";

// Template to check if 25 values are unique and in range [1, 25]
template CheckUnique25() {
    signal input values[25];
    signal output dummy; // Needed for component instantiation

    // Check range [1, 25] using constraints
    component geq[25];
    component leq[25];

    for (var i = 0; i < 25; i++) {
        // values[i] >= 1
        geq[i] = GreaterEqThan(8); // 8 bits enough for values up to 255
        geq[i].in[0] <== values[i];
        geq[i].in[1] <== 1;
        geq[i].out === 1;

        // values[i] <= 25
        leq[i] = LessEqThan(8);
        leq[i].in[0] <== values[i];
        leq[i].in[1] <== 25;
        leq[i].out === 1;
    }

    // Check uniqueness using IsZero (values[i] - values[j] != 0)
    component isZero[300]; // 25 * 24 / 2 = 300 pairs
    var idx = 0;
    for (var i = 0; i < 25; i++) {
        for (var j = i + 1; j < 25; j++) {
            isZero[idx] = IsZero();
            isZero[idx].in <== values[i] - values[j];
            isZero[idx].out === 0; // Must NOT be zero (must be different)
            idx++;
        }
    }

    dummy <== 1;
}

// Main Sudoku verification template
template Sudoku25x25() {
    signal input solution[625];      // Private: the solution
    signal input expectedCommitment; // Public: the commitment to verify

    // Verify all rows
    component rowCheckers[25];
    for (var r = 0; r < 25; r++) {
        rowCheckers[r] = CheckUnique25();
        for (var c = 0; c < 25; c++) {
            rowCheckers[r].values[c] <== solution[r * 25 + c];
        }
    }

    // Verify all columns
    component colCheckers[25];
    for (var c = 0; c < 25; c++) {
        colCheckers[c] = CheckUnique25();
        for (var r = 0; r < 25; r++) {
            colCheckers[c].values[r] <== solution[r * 25 + c];
        }
    }

    // Verify all 5x5 boxes
    component boxCheckers[25];
    var boxIdx = 0;
    for (var br = 0; br < 5; br++) {
        for (var bc = 0; bc < 5; bc++) {
            boxCheckers[boxIdx] = CheckUnique25();
            var valIdx = 0;
            for (var i = 0; i < 5; i++) {
                for (var j = 0; j < 5; j++) {
                    boxCheckers[boxIdx].values[valIdx] <== solution[(br * 5 + i) * 25 + (bc * 5 + j)];
                    valIdx++;
                }
            }
            boxIdx++;
        }
    }

    // Compute commitment using polynomial hash
    signal commitment;
    var base = 257;
    var power = 1;
    var sum = 0;

    for (var i = 0; i < 625; i++) {
        sum += solution[i] * power;
        power *= base;
    }

    commitment <== sum;

    // CRITICAL: Assert that computed commitment matches expected commitment
    commitment === expectedCommitment;
}

// Main component
component main {public [expectedCommitment]} = Sudoku25x25();
