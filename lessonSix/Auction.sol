// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/utils/Strings.sol";

contract Auction{
    using Strings for uint256;
  
    string public Item;
    address public immutable SELLER;
    address public HighestBidder;
    address public Winner;
    uint public StartingCost;
    uint public BidStep;
    uint public CurrentCost;
    bool public HasStarted;
    bool public HasEnded;
    uint public StartTime;
    uint public StepTime;
    uint private PreviousBidTime;
    uint public MaxParticipants;
    uint public CurrentParticipantsAmount;

    mapping (address => bool) private Permissions;
    mapping(address => uint) private Bids;

    constructor(string memory _item,
                uint _startingCost,
                uint _bidStep,
                uint _maxParticipants,
                uint _stepTime){
        SELLER = msg.sender;
        Item = _item;
        StartingCost = _startingCost * 1 ether;
        CurrentCost = StartingCost;
        BidStep = _bidStep * 1 ether;
        MaxParticipants = _maxParticipants;
        StepTime = _stepTime;
    }

    modifier OnlyOwner(){
        require(msg.sender == SELLER, "You are not the seller.");
        _;
    }

    modifier AuctionHasStarted(){
        require(HasStarted == true, "The auction has not started yet.");
        _;
    }

    modifier AuctionHasEnded(){
        require(HasEnded == true, "The auction has been ended.");
        _;
    }

    function GetPermission(address account) public OnlyOwner {
        require(CurrentParticipantsAmount < MaxParticipants, "Max limit for participants.");
        Permissions[account] = true;
        CurrentParticipantsAmount += 1;
    }

    function StartAuction() public OnlyOwner {
        require(!HasEnded, "The auction has been ended.");
        require(!HasStarted, "The auction has already started.");
        HasStarted = true;
        StartTime = block.timestamp;
        PreviousBidTime = StartTime;
    }

    function Bid() public payable {
        require(!HasEnded, "The auction has been ended.");
        require(Permissions[msg.sender] == true, "You have no permissions.");
        require(msg.value == CurrentCost + BidStep,
            string.concat("Not enough ether. Current cost plus bid: ", ((CurrentCost + BidStep) / 1 ether).toString()));
        Bids[msg.sender] += msg.value; //Сохраняем ставку участника
        HighestBidder = msg.sender;
        CurrentCost += BidStep;
        PreviousBidTime = block.timestamp;
        BidHistory.push(BidRecord(msg.sender, msg.value, block.timestamp)); //Добавляем запись в историю ставок
        CheckTimeAndWinner();
    }

    function CheckTimeAndWinner() private {
        if (block.timestamp >= PreviousBidTime + StepTime){
            HasEnded = true;
            Winner = HighestBidder;
            Withdraw();
        }
    }

    function Withdraw() private returns (bool) {
        if (HighestBidder != address(0) && !HasEnded) {
            payable(HighestBidder).transfer(CurrentCost);
            return true;
        }
        return false;
    }

    function GetItem() public view returns (string memory){
        require(msg.sender == Winner, "You are not the winner.");
        return "Congratulations! You are the winner. Here is your item.";
    }

    //Эта функция позволяет продавцу завершить аукцион вручную досрочно.
    function EndAuction() public OnlyOwner {
        require(HasStarted, "The auction has not started yet.");
        require(!HasEnded, "The auction has already ended.");
        HasEnded = true;
        Winner = HighestBidder;
        Withdraw();
    }

    //Эта функция позволяет участникам, которые не выиграли аукцион, вернуть свои ставки.
    function Refund() public {
        require(HasEnded, "The auction has not ended yet.");
        require(msg.sender != Winner, "The winner cannot refund.");
        uint amount = Bids[msg.sender];
        Bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
    
    struct BidRecord {
        address bidder;
        uint amount;
        uint timestamp;
    }
    
    BidRecord[] private BidHistory;
    
    //Эта функция позволяет просмотреть историю ставок.
    function GetBidHistory() public view returns (BidRecord[] memory){
        return BidHistory;
    }
}