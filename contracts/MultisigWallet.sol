// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract MultisigWallet{
    event Deposit(address indexed sender, uint amount);
    event Submit(uint indexed txId);
    event Approve(address indexed owner, uint indexed txId);
    event Revoke(address indexed owner, uint indexed txId);
    event Execute(uint indexed txId);

    struct Transaction{
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numApprovals;
    }

    address[] public owners;
    mapping(address => bool) public isOwner;
    // no of approvals required for a transaction
    uint public required;

    Transaction[] public transactions;
    // mapping from tx id to owner to approval status
    mapping(uint => mapping(address => bool)) public isApproved;

    modifier onlyOwner(){
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    modifier txExists(uint _txId){
        require(_txId < transactions.length, "Tx does not exist");
        _;
    }

    modifier notExecuted(uint _txId){
        require(!transactions[_txId].executed, "Tx already executed");
        _;
    }

    modifier notApproved(uint _txId){
        require(!isApproved[_txId][msg.sender], "Tx already approved");
        _;
    }

    constructor(address[] memory _owners, uint _required){
        require(_owners.length > 0, "Owners required");
        require(_required > 0 && _required <= _owners.length, "Invalid number of required Owners");

        // for loop to save owners to state variables
        for(uint i=0; i<_owners.length; i++){
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Owner not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }
        required = _required;
    }

    // function to enable wallet to receive ether
    receive() external payable{
        emit Deposit(msg.sender, msg.value);
    }

    function submitTransaction(address _to, uint _value, bytes calldata _data) external onlyOwner {
        uint txId = transactions.length - 1;
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numApprovals: 0
        }));

        emit Submit(txId);
    }

    function approveTransaction(uint _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId){
        Transaction storage transaction = transactions[_txId];
        transaction.numApprovals += 1;

        isApproved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function execute(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId){
        Transaction storage transaction = transactions[_txId];
        require(transaction.numApprovals >= required, "Not enough approvals");

        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "Tx failed");

        emit Execute(_txId);
    }

    function revokeApproval(uint _txId) onlyOwner txExists(_txId) notExecuted(_txId) external{
        require(isApproved[_txId][msg.sender], "Not approved");
        
        Transaction storage transaction = transactions[_txId];
        transaction.numApprovals -= 1;

        isApproved[_txId][msg.sender] = false;

        emit Revoke(msg.sender, _txId);
    }

    function getOwner() external view returns(address[] memory){
        return owners;
    }

    function getTransactionCount() external view returns(uint){
        return transactions.length;
    }

    function getTransaction(uint _txId) external view returns(address to, uint value, bytes memory data, bool executed, uint numApprovals){
        Transaction storage transaction = transactions[_txId];
        return (transaction.to, transaction.value, transaction.data, transaction.executed, transaction.numApprovals);
    }
}