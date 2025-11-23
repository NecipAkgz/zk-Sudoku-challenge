import random
from mnemonic import Mnemonic
import sys

# Configuration
MNEMONIC_LEN = 12  # Try 12 first. If easy, try 24.
GRID_SIZE = 25
BOX_SIZE = 5

mnemo = Mnemonic("english")
wordlist = mnemo.wordlist
word_to_index = {w: i for i, w in enumerate(wordlist)}

# We need a mapping from Sudoku Symbols (1..25) to BIP39 Words.
# We will just pick 25 random words to start.
# But wait, to make the "intersection" strategy work, we need the set of 25 words
# to effectively cover the "valid completions" space.
# Actually, we can't change the mapping dynamically during backtracking easily.
# So we fix the mapping first.
# If we fix the mapping, we might get stuck.
# But let's try.


def get_valid_completions(prefix_words, target_len):
    # Returns a set of words (strings) that complete the prefix to a valid mnemonic
    # This is expensive to compute for every step if we iterate all 2048 words.
    # But we only need to check against our 25 available words!
    # So we just check each of the 25 words.
    valid = set()
    # We assume our "mapping" provides the candidate words.
    # But here we just return indices 1..25 that are valid.
    return valid


class SudokuSolver:
    def __init__(self, mapping_words):
        self.mapping = mapping_words  # List of 25 words
        self.mapping_map = {
            i + 1: w for i, w in enumerate(mapping_words)
        }  # 1..25 -> Word
        self.board = [[0] * GRID_SIZE for _ in range(GRID_SIZE)]

        self.rows = [set() for _ in range(GRID_SIZE)]
        self.cols = [set() for _ in range(GRID_SIZE)]
        self.boxes = [set() for _ in range(GRID_SIZE)]

    def get_box_index(self, r, c):
        return (r // BOX_SIZE) * BOX_SIZE + (c // BOX_SIZE)

    def is_valid_bip39(self, numbers):
        words = [self.mapping_map[n] for n in numbers]
        try:
            return mnemo.check(" ".join(words))
        except:
            return False

    def solve(self, r, c):
        if r == GRID_SIZE:
            return True  # Done

        next_r, next_c = (r, c + 1) if c < GRID_SIZE - 1 else (r + 1, 0)

        # Candidates based on Sudoku constraints
        candidates = set(range(1, 26))
        candidates -= self.rows[r]
        candidates -= self.cols[c]
        candidates -= self.boxes[self.get_box_index(r, c)]

        # BIP39 Constraints
        # If we are at the end of a mnemonic block in ROW
        # (e.g. col == MNEMONIC_LEN - 1)
        # We must ensure the row so far forms a valid mnemonic.
        # We can filter candidates.

        if c == MNEMONIC_LEN - 1:
            # We are placing the last word of the row mnemonic
            # Filter candidates that make the row valid
            valid_candidates = []
            current_row_prefix = self.board[r][:c]  # 0..c-1

            for val in candidates:
                # Check if prefix + val is valid
                if self.is_valid_bip39(current_row_prefix + [val]):
                    valid_candidates.append(val)
            candidates = valid_candidates
        elif c > MNEMONIC_LEN - 1:
            # If we are past the mnemonic length, no BIP39 constraint for ROW (unless we have multiple)
            pass

        # If we are at the end of a mnemonic block in COL
        if r == MNEMONIC_LEN - 1:
            # Filter candidates that make the col valid
            valid_candidates = []
            # We need to construct the col prefix
            current_col_prefix = [self.board[i][c] for i in range(r)]

            # Note: candidates is already filtered by Row check above if applicable
            # So we iterate the current candidates
            temp_candidates = []
            for val in candidates:
                if self.is_valid_bip39(current_col_prefix + [val]):
                    temp_candidates.append(val)
            candidates = temp_candidates

        # Shuffle candidates to get random solutions
        candidates = list(candidates)
        random.shuffle(candidates)

        for val in candidates:
            # Place
            self.board[r][c] = val
            self.rows[r].add(val)
            self.cols[c].add(val)
            self.boxes[self.get_box_index(r, c)].add(val)

            if self.solve(next_r, next_c):
                return True

            # Backtrack
            self.board[r][c] = 0
            self.rows[r].remove(val)
            self.cols[c].remove(val)
            self.boxes[self.get_box_index(r, c)].remove(val)

        return False


def main():
    while True:
        print("Picking new set of 25 words...")
        mapping_words = random.sample(wordlist, 25)
        solver = SudokuSolver(mapping_words)

        print("Attempting to solve...")
        if solver.solve(0, 0):
            print("SOLUTION FOUND!")
            print("Mapping:", mapping_words)
            for row in solver.board:
                print(row)

            # Verify
            print("Verifying...")
            valid_rows = 0
            for r in range(GRID_SIZE):
                nums = solver.board[r][:MNEMONIC_LEN]
                if solver.is_valid_bip39(nums):
                    valid_rows += 1
            print(f"Valid Rows (first {MNEMONIC_LEN}): {valid_rows}")

            valid_cols = 0
            for c in range(GRID_SIZE):
                nums = [solver.board[r][c] for r in range(MNEMONIC_LEN)]
                if solver.is_valid_bip39(nums):
                    valid_cols += 1
            print(f"Valid Cols (first {MNEMONIC_LEN}): {valid_cols}")

            if valid_rows == GRID_SIZE and valid_cols == GRID_SIZE:
                print("PERFECT!")
                # Save to file
                with open("solution.txt", "w") as f:
                    f.write(str(mapping_words) + "\n")
                    for row in solver.board:
                        f.write(str(row) + "\n")
                break
        else:
            print("Failed with this mapping. Retrying...")


if __name__ == "__main__":
    main()
