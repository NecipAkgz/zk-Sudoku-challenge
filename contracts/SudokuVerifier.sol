// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IGroth16Verifier {
    function verifyProof(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[1] calldata _pubSignals
    ) external view returns (bool);
}

contract SudokuVerifier {
    IGroth16Verifier public verifier;

    event ProofVerified(
        address indexed solver,
        uint256 commitment,
        uint256 timestamp
    );
    event VerificationFailed(address indexed solver, uint256 timestamp);

    mapping(uint256 => bool) public verifiedSolutions;
    mapping(address => uint256) public solverCount;

    constructor(address _verifierAddress) {
        verifier = IGroth16Verifier(_verifierAddress);
    }

    function verifySudokuProof(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[1] calldata _pubSignals // commitment
    ) external returns (bool) {
        uint256 commitment = _pubSignals[0];
        require(commitment != 0, "Commitment required");
        require(!verifiedSolutions[commitment], "Solution already verified");

        bool isValid = verifier.verifyProof(_pA, _pB, _pC, _pubSignals);

        if (isValid) {
            verifiedSolutions[commitment] = true;
            solverCount[msg.sender]++;
            emit ProofVerified(msg.sender, commitment, block.timestamp);
            return true;
        } else {
            emit VerificationFailed(msg.sender, block.timestamp);
            return false;
        }
    }

    function isSolutionVerified(
        uint256 solutionHash
    ) external view returns (bool) {
        return verifiedSolutions[solutionHash];
    }

    function getSolverCount(address solver) external view returns (uint256) {
        return solverCount[solver];
    }
}
