// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

contract Wallet {
    address[] approvers;
    uint256 public quorum;

    struct Transfer {
        uint256 id;
        uint256 amount;
        address payable to;
        uint256 approvals;
        bool sent;
    }

    Transfer[] transfers;
    mapping(address => mapping(uint256 => bool)) public approvals;

    constructor(address[] memory _approvers, uint256 _quorum) public {
        approvers = _approvers;
        quorum = _quorum;
    }

    function getApprovers() external view returns (address[] memory) {
        return approvers;
    }

    function getTransfers() external view returns (Transfer[] memory) {
        return transfers;
    }

    function createTransfer(uint256 amount, address payable to) external {
        transfers.push(
            Transfer(transfers.length, amount * (10**18), to, 0, false)
        );
    }

    function approveTransfer(uint256 id) external {
        require(
            transfers[id].sent != true,
            "This transfer has already been sent!"
        );
        require(
            approvals[msg.sender][id] != true,
            "Cannot approve a single transfer twice"
        );

        approvals[msg.sender][id] = true;
        transfers[id].approvals++;

        if (transfers[id].approvals >= quorum) {
            transfers[id].sent = true;
            address payable to = transfers[id].to;
            to.transfer(transfers[id].amount);
        }
    }

    receive() external payable {}
}
