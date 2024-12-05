// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Crowdfunding {
    enum Products { Prod1, Prod2 }

    address private _campaignStarted;
    string private _name;
    uint256 private _goal;
    uint256 private _startTime;
    uint256 private _fundingPeriodInSeconds;
    string private _product1;
    uint256 private _product1Price;
    string private _product2;
    uint256 private _product2Price;
    uint private _currentFunds;

    //mapping (address => uint) private _fundingMap;
    mapping (address => Product) private _fundingMapWithStruct;

    uint private _productCounter = 1;
    mapping (uint => Product) private _productsMap;

    event ContributionReceived(address indexed contributor, uint256 amount);
    event CampaignSuccessful(address indexed owner, uint256 totalFunds);
    event RefundIssued(address indexed contributor, uint256 amount);

    struct Product {
        string productName;
        uint investments;
    }

    constructor (
        string memory name,
        uint256 goal,
        uint256 fundingPeriodInDays,
        string memory product1,
        uint256 product1Price,
        string memory product2,
        uint256 product2Price
    ) {
        _campaignStarted = msg.sender;
        _name = name;
        _goal = goal;
        _startTime = block.timestamp;
        _fundingPeriodInSeconds = 1 days * fundingPeriodInDays;
        _product1 = product1;
        _product1Price = product1Price;
        _product2 = product2;
        _product2Price = product2Price;
    }

    function AddNewProduct(string memory newProductName, uint newProductPrice) public {
        _productsMap[_productCounter].productName = newProductName;
        _productsMap[_productCounter].investments = newProductPrice;
        _productCounter += 1;
    }

    function FundProduct1() external payable  {
        require(msg.value == _product1Price, "Please check value.");
        _fundingMapWithStruct[msg.sender].productName = _product1;
        _fundingMapWithStruct[msg.sender].investments = msg.value;
        _currentFunds += msg.value;

        emit ContributionReceived(msg.sender, msg.value);
    }

    function FundProduct2() external payable {
        require(msg.value == _product2Price, "Please check value.");
        _fundingMapWithStruct[msg.sender].productName = _product2;
        _fundingMapWithStruct[msg.sender].investments = msg.value;
        _currentFunds += msg.value;

        emit ContributionReceived(msg.sender, msg.value);
    }

    function FundWithIfElse(Products selectedProduct) external payable {
        if (selectedProduct == Products.Prod1) {
            require(msg.value == _product1Price, "Please check value.");
            _fundingMapWithStruct[msg.sender].productName = _product1;
            _fundingMapWithStruct[msg.sender].investments = msg.value;
            _currentFunds += msg.value;
        }
        else if (selectedProduct == Products.Prod2) {
            require(msg.value == _product2Price, "Please check value.");
            _fundingMapWithStruct[msg.sender].productName = _product2;
            _fundingMapWithStruct[msg.sender].investments = msg.value;
            _currentFunds += msg.value;
        }
    }

    function IsGoalAchieved() internal  view returns (bool) {
        return _currentFunds >= _goal;
    }

    function IsTimeEnded() internal view returns (bool) {
        return block.timestamp > _startTime + _fundingPeriodInSeconds;
    }

    function WithDraw() external {
        address baker = msg.sender;
        require(_fundingMapWithStruct[baker].investments > 0, "Sorry, you have no investments");
        require(IsTimeEnded(), "The campaign is still going.");
        require(!IsGoalAchieved(), "Sorry, the campaigh is successful.");
        payable(baker).transfer(_fundingMapWithStruct[baker].investments);

        emit RefundIssued(baker, _fundingMapWithStruct[baker].investments);
    }

    function GetFunds() external {
        require(_campaignStarted == msg.sender, "You are not the owner.");
        require(IsTimeEnded(), "The campaign is still going.");
        require(IsGoalAchieved(), "Sorry, the campaigh was unsuccessful.");
        payable(_campaignStarted).transfer(_currentFunds);

        emit CampaignSuccessful(_campaignStarted, _currentFunds);
    }
}
