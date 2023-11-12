// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8 .17;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract MultiSigWallet is AccessControl {
    event Deposit(address indexed sender, uint amount, uint balance);
    event ProposeTransaction(
        address indexed signer,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event ApproveTransaction(address indexed signer, uint indexed txIndex);
    event RevokeConfirmation(address indexed signer, uint indexed txIndex);
    event ExecuteTransaction(address indexed account, uint indexed txIndex);
    event Initialized();

    uint public numConfirmationsRequired;
    bool public initialized;

    // Role identifiers
    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    // mapping from tx index => owner => bool
    mapping(uint => mapping(address => bool)) public isConfirmed;

    Transaction[] public transactions;

    modifier onlySigner() {
        require(hasRole(SIGNER_ROLE, msg.sender), "not signer");
        _;
    }

    modifier onlyOwner() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "not owner");
        _;
    }

    modifier ownerOrSigner() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(SIGNER_ROLE, msg.sender), "not owner nor signer");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    // Modifier to check if the contract is initialized
    modifier onlyInitialized() {
        require(initialized, "Contract not yet initialized");
        _;
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /// @dev Initialize contract.
    /// @param _signers Address of new signer to add.
    /// @param _numConfirmationsRequired Number of required confirmations.
    function initialize(address[] memory _signers, uint256 _numConfirmationsRequired)
    public
    onlyOwner {
        require(initialized == false, "contract already initialized");
        require(_signers.length > 0, "signers required");
        require(
            _numConfirmationsRequired > 0 &&
            _numConfirmationsRequired <= _signers.length,
            "invalid number of required confirmations"
        );

        for (uint i = 0; i < _signers.length; i++) {
            address signer = _signers[i];

            require(signer != address(0), "invalid signer");
            require(!hasRole(SIGNER_ROLE, signer), "signer not unique");

            _grantRole(SIGNER_ROLE, _signers[i]);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
        initialized = true;
        emit Initialized();
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function proposeTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyInitialized {
        uint txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 0
            })
        );

        emit ProposeTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    function approveTransaction(uint _txIndex)
    public
    onlySigner
    txExists(_txIndex)
    notExecuted(_txIndex)
    notConfirmed(_txIndex) onlyInitialized {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit ApproveTransaction(msg.sender, _txIndex);
    }

    function executeTransaction(uint _txIndex)
    public
    ownerOrSigner
    txExists(_txIndex)
    notExecuted(_txIndex) onlyInitialized {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx"
        );

        transaction.executed = true;

        (bool success, ) = transaction.to.call {
            value: transaction.value
        }(
            transaction.data
        );
        require(success, "tx failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint _txIndex)
    public
    onlySigner
    txExists(_txIndex)
    notExecuted(_txIndex) onlyInitialized {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function getTransactionCount() public view returns(uint) {
        return transactions.length;
    }

    function getTransaction(uint _txIndex)
    public
    view
    returns(
        address to,
        uint value,
        bytes memory data,
        bool executed,
        uint numConfirmations
    ) {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
}