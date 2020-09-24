// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "./openzeppelin/Ownable.sol";

contract Contract is Ownable {
    string[] private questions;
    string[] private answers;

    struct User {
        uint8 level;
        bytes32 message;
        bool done;
        bool registered;
    }

    mapping(address => User) public users;

    // event fired when an user is registered
    event NewUserRegistered(address indexed id);

    // event fired when a non technical submission is received
    event NonTechnicalSubmission(address indexed id, bytes32 message);

    // event fired when a technical submission is received
    event TechnicalSubmission(address indexed id, bytes32 message);

    // Modifier: check if the caller of the smart contract is registered
    modifier onlyRegistered {
        require(users[msg.sender].registered);
        _;
    }

    modifier onlyLevel(uint8 _level) {
        require(users[msg.sender].level == _level, "Wrong Level!");
        _;
    }

    function sendMessageNonTechnical(string memory _message) public payable {
        require(msg.value >= 0.1 ether, "GIVE ME MONEY!");
        require(!users[msg.sender].done, "Done already!");

        users[msg.sender].message = keccak256(abi.encodePacked(_message));
        users[msg.sender].done = true;
        emit NonTechnicalSubmission(
            msg.sender,
            keccak256(abi.encodePacked(_message))
        );
    }

    function register() public payable {
        require(msg.value >= 0.1 ether, "GIVE ME MONEY!");

        users[msg.sender] = User({
            message: "",
            level: 0,
            done: false,
            registered: true
        });

        emit NewUserRegistered(msg.sender);
    }

    function getQuestions()
        public
        view
        onlyRegistered
        returns (
            string memory,
            string memory,
            string memory,
            string memory
        )
    {
        return (questions[0], questions[1], questions[2], questions[3]);
    }

    function sendQuestionA(string memory _answer) public onlyLevel(3) {
        require(
            keccak256(abi.encode(_answer)) == keccak256(abi.encode(answers[0])),
            "Wrong Answer"
        );
        users[msg.sender].level = 4;
    }

    function sendQuestionB(string memory _answer) public onlyLevel(2) {
        require(
            keccak256(abi.encode(_answer)) == keccak256(abi.encode(answers[1])),
            "Wrong Answer"
        );
        users[msg.sender].level = 3;
    }

    function sendQuestionC(string memory _answer) public onlyLevel(0) {
        require(
            keccak256(abi.encode(_answer)) == keccak256(abi.encode(answers[2])),
            "Wrong Answer"
        );
        users[msg.sender].level = 1;
    }

    function sendQuestionD(string memory _answer) public onlyLevel(1) {
        require(
            keccak256(abi.encode(_answer)) == keccak256(abi.encode(answers[3])),
            "Wrong Answer"
        );
        users[msg.sender].level = 2;
    }

    function sendMessageTechnical(string memory _message) public onlyLevel(4) {
        require(!users[msg.sender].done, "Done already!");

        users[msg.sender].message = keccak256(abi.encodePacked(_message));
        users[msg.sender].done = true;
        emit TechnicalSubmission(
            msg.sender,
            keccak256(abi.encodePacked(_message))
        );
    }

    function addQuestionAnswer(string memory _question, string memory _answer)
        public
        onlyOwner
    {
        questions.push(_question);
        answers.push(_answer);
    }

    function popQuestionAnswer() public onlyOwner {
        if (questions.length > 0) {
            questions.pop();
            answers.pop();
        }
    }
}
