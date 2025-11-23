// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IUltraVerifier {
    function verify(bytes calldata _proof, bytes32[] calldata _publicInputs) external view returns (bool);
}

contract SudokuVerifier {
    IUltraVerifier public verifier;

    event ProofVerified(address indexed solver, bytes32 solutionHash, uint256 timestamp);
    event VerificationFailed(address indexed solver, uint256 timestamp);

    mapping(bytes32 => bool) public verifiedSolutions;
    mapping(address => uint256) public solverCount;

    constructor(address _verifierAddress) {
        verifier = IUltraVerifier(_verifierAddress);
    }

    function verifySudokuProof(
        bytes calldata proof,
        bytes32[] calldata publicInputs
    ) external returns (bool) {
        require(publicInputs.length > 0, "Public inputs required");

        bytes32 solutionHash = publicInputs[0];
        require(!verifiedSolutions[solutionHash], "Solution already verified");

        bool isValid = verifier.verify(proof, publicInputs);

        if (isValid) {
            verifiedSolutions[solutionHash] = true;
            solverCount[msg.sender]++;
            emit ProofVerified(msg.sender, solutionHash, block.timestamp);
            return true;
        } else {
            emit VerificationFailed(msg.sender, block.timestamp);
            return false;
        }
    }

    function isSolutionVerified(bytes32 solutionHash) external view returns (bool) {
        return verifiedSolutions[solutionHash];
    }

    function getSolverCount(address solver) external view returns (uint256) {
        return solverCount[solver];
    }
}
