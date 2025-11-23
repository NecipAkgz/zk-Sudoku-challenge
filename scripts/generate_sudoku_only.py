import random
import json


def generate_sudoku_25x25():
    n = 5
    size = 25
    board = [[0] * size for _ in range(size)]
    for r in range(size):
        for c in range(size):
            val = (r * n + r // n + c) % size
            board[r][c] = val + 1  # 1-25
    return board


def main():
    board = generate_sudoku_25x25()
    mapping = list(range(25))  # 0..24

    # Flatten board
    flat_board = [cell for row in board for cell in row]

    data = {"solution": flat_board, "mapping": mapping}

    with open("circuits/Prover.toml", "w") as f:
        f.write(f"solution = {json.dumps(flat_board)}\n")
        f.write(f"mapping = {json.dumps(mapping)}\n")

    print("Generated Prover.toml")


if __name__ == "__main__":
    main()
