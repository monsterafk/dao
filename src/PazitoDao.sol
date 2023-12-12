// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";
import "@openzeppelin/contracts/governance/utils/IVotes.sol";
import "@openzeppelin/contracts/interfaces/IERC165.sol";

contract PazitoDao is Governor,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl {
        
        constructor(
            IVotes _token, 
            TimelockController _timelock
        ) Governor("PazitoDao") GovernorVotes(_token) GovernorVotesQuorumFraction(4) GovernorTimelockControl(_timelock) {}

        function votingDelay() public pure override returns (uint256) {
            return 1 days;
        }
    
        function votingPeriod() public pure override returns (uint256) {
            return 1 weeks;
        }

        function state(uint256 proposalId) public view override(Governor, GovernorTimelockControl) returns (ProposalState){
            return super.state(proposalId);
        }

        function proposalNeedsQueuing(
            uint256 proposalId
        ) public view virtual override(Governor, GovernorTimelockControl) returns (bool) {
            return super.proposalNeedsQueuing(proposalId);
        }

        function _queueOperations(
            uint256 proposalId,
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory calldatas,
            bytes32 descriptionHash
        ) internal override(Governor, GovernorTimelockControl) returns (uint48) {
            return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
        }
    
        function _executeOperations(
            uint256 proposalId,
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory calldatas,
            bytes32 descriptionHash
        ) internal override(Governor, GovernorTimelockControl) {
            super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
        }
    
        function _cancel(
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory calldatas,
            bytes32 descriptionHash
        ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
            return super._cancel(targets, values, calldatas, descriptionHash);
        }
    
        function _executor() internal view override(Governor, GovernorTimelockControl) returns (address) {
            return super._executor();
        }
    }