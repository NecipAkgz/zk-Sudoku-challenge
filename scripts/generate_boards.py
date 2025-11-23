import random
import json
import hashlib


def generate_sudoku_25x25():
    """Generate a valid 25x25 Sudoku using pattern-based construction"""
    n = 5
    size = 25
    board = [[0] * size for _ in range(size)]

    # Use standard construction formula for n^2 x n^2 Sudoku
    for r in range(size):
        for c in range(size):
            val = (r * n + r // n + c) % size + 1  # 1-25
            board[r][c] = val

    return board


def shuffle_board(board):
    """Shuffle the board while maintaining Sudoku validity"""
    size = 25
    n = 5

    # Shuffle symbols (1-25 mapping)
    symbols = list(range(1, 26))
    random.shuffle(symbols)

    # Apply symbol permutation
    new_board = [[symbols[board[r][c] - 1] for c in range(size)] for r in range(size)]

    # Shuffle rows within bands (groups of 5 rows)
    for band in range(n):
        rows = list(range(band * n, (band + 1) * n))
        random.shuffle(rows)
        temp_rows = [new_board[i][:] for i in rows]
        for i, row_idx in enumerate(rows):
            new_board[band * n + i] = temp_rows[i]

    # Shuffle columns within stacks (groups of 5 columns)
    for stack in range(n):
        cols = list(range(stack * n, (stack + 1) * n))
        random.shuffle(cols)
        temp_board = [row[:] for row in new_board]
        for new_idx, old_idx in enumerate(cols):
            for r in range(size):
                new_board[r][stack * n + new_idx] = temp_board[r][old_idx]

    # Shuffle bands
    bands = list(range(n))
    random.shuffle(bands)
    temp_board = [row[:] for row in new_board]
    for new_band, old_band in enumerate(bands):
        for i in range(n):
            new_board[new_band * n + i] = temp_board[old_band * n + i]

    # Shuffle stacks
    stacks = list(range(n))
    random.shuffle(stacks)
    temp_board = [row[:] for row in new_board]
    for new_stack, old_stack in enumerate(stacks):
        for r in range(size):
            for i in range(n):
                new_board[r][new_stack * n + i] = temp_board[r][old_stack * n + i]

    return new_board


def verify_sudoku(board):
    """Verify that the board is a valid 25x25 Sudoku"""
    size = 25
    n = 5

    # Check rows
    for r in range(size):
        if len(set(board[r])) != size or min(board[r]) != 1 or max(board[r]) != size:
            return False

    # Check columns
    for c in range(size):
        col = [board[r][c] for r in range(size)]
        if len(set(col)) != size or min(col) != 1 or max(col) != size:
            return False

    # Check 5x5 boxes
    for br in range(n):
        for bc in range(n):
            box = []
            for i in range(n):
                for j in range(n):
                    box.append(board[br * n + i][bc * n + j])
            if len(set(box)) != size or min(box) != 1 or max(box) != size:
                return False

    return True


def compute_commitment_field(board):
    """
    Compute the commitment using the same polynomial hash as the circuit.
    Field modulus: 21888242871839275222246405745257275088548364400416034343698204186575808495617
    """
    MODULUS = (
        21888242871839275222246405745257275088548364400416034343698204186575808495617
    )
    flat = [cell for row in board for cell in row]

    commitment = 0
    base = 257
    power = 1

    for val in flat:
        term = (val * power) % MODULUS
        commitment = (commitment + term) % MODULUS
        power = (power * base) % MODULUS

    return f"0x{commitment:x}"


def main():
    print("Generating 5 different valid 25x25 Sudoku boards...")

    boards = []
    for i in range(5):
        print(f"\nGenerating board {i+1}...")
        base_board = generate_sudoku_25x25()
        board = shuffle_board(base_board)

        # Verify
        if verify_sudoku(board):
            print(f"✓ Board {i+1} is valid!")
            boards.append(board)

            # Compute commitment
            commitment = compute_commitment_field(board)
            print(f"  Field commitment: {commitment}")
        else:
            print(f"✗ Board {i+1} is INVALID!")
            return

    # Save all boards
    print("\n" + "=" * 60)
    print("Saving boards to files...")

    for i, board in enumerate(boards):
        # Flatten board
        flat_board = [cell for row in board for cell in row]

        # Compute commitment again for safety
        commitment = compute_commitment_field(board)

        # Save Circom input.json
        circom_input = {
            "solution": [int(x) for x in flat_board],
            "expectedCommitment": str(commitment)
        }
        circom_filename = f"circom_circuits/input_{i+1}.json"
        with open(circom_filename, "w") as f:
            json.dump(circom_input, f, indent=2)
        print(f"✓ Saved {circom_filename}")

        # Also save the first one as standard input.json for convenience
        if i == 0:
            with open("circom_circuits/input.json", "w") as f:
                json.dump(circom_input, f, indent=2)

        # Also save human-readable version
        readable_file = f"boards/board_{i+1}.txt"
        with open(readable_file, "w") as f:
            f.write(f"Board {i+1}\n")
            f.write("=" * 50 + "\n\n")
            for row in board:
                f.write(" ".join(f"{cell:2d}" for cell in row) + "\n")
        print(f"✓ Saved {readable_file}")

    print("\n" + "=" * 60)
    print("✓ All 5 boards generated successfully!")
    print("\nNext steps:")
    print("1. Copy Prover_1.toml to circuits/Prover.toml")
    print("2. Run: cd circuits && nargo execute witness")
    print("3. Generate proof with bb.js")
    print("4. Repeat for all 5 boards")


if __name__ == "__main__":
    import os

    os.makedirs("boards", exist_ok=True)
    main()
