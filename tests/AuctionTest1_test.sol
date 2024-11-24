// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "remix_tests.sol"; // Импортируем библиотеку для тестирования в Remix
import "../lessonSix/Auction.sol";

contract AuctionTest {
    Auction private auction;
    address private owner;
    address private participant1;
    address private participant2;

    function beforeAll() public {
        //Создаем учетные записи для тестирования
        owner = address(this);
        participant1 = address(0x1);
        participant2 = address(0x2);

        //Создаем экземпляр контракта аукциона
        auction = new Auction("Test Item", 1, 1, 2, 60);
    }

    //Проверка начальных параметров контракта
    function checkInitialParameters() public {
        Assert.equal(auction.Item(), "Test Item", "Item name mismatch");
        Assert.equal(auction.StartingCost(), 1 ether, "Starting cost mismatch");
        Assert.equal(auction.BidStep(), 1 ether, "Bid step mismatch");
        Assert.equal(auction.MaxParticipants(), 2, "Max participants mismatch");
    }

    //Проверка получения разрешений участниками
    function testGetPermission() public {
        auction.GetPermission(participant1);
        Assert.equal(auction.CurrentParticipantsAmount(), 1, "Participant amount mismatch");

        auction.GetPermission(participant2);
        Assert.equal(auction.CurrentParticipantsAmount(), 2, "Participant amount mismatch");
    }

    //Проверка запуска аукциона
    function testStartAuction() public {
        auction.StartAuction();
        Assert.ok(auction.HasStarted(), "Auction should be started");
        Assert.equal(auction.StartTime() > 0, true, "Start time not set");
    }

    //Проверка ставок
    function testBidding() public payable {
        //Имитация отправки ставки от participant1
        (bool success1, ) = address(auction).call{value: 2 ether}(
            abi.encodeWithSignature("Bid()")
        );
        Assert.ok(success1, "Bid from participant1 failed");

        //Проверяем статус
        Assert.equal(auction.CurrentCost(), 2 ether, "Current cost mismatch");
        Assert.equal(auction.HighestBidder(), participant1, "Highest bidder mismatch");

        //Имитация отправки ставки от participant2
        (bool success2, ) = address(auction).call{value: 3 ether}(
            abi.encodeWithSignature("Bid()")
        );
        Assert.ok(success2, "Bid from participant2 failed");

        //Проверяем статус
        Assert.equal(auction.CurrentCost(), 3 ether, "Current cost mismatch");
        Assert.equal(auction.HighestBidder(), participant2, "Highest bidder mismatch");
    }

    //Проверка ручного завершения аукциона
    function testEndAuction() public {
        auction.EndAuction();
        Assert.ok(auction.HasEnded(), "Auction should be ended");
        Assert.equal(auction.Winner(), participant2, "Winner mismatch");
    }

    //Проверка возврата ставок
    function testRefund() public {
        uint initialBalance = address(participant1).balance;

        (bool success, ) = address(auction).call(
            abi.encodeWithSignature("Refund()")
        );
        Assert.ok(success, "Refund failed");

        uint finalBalance = address(participant1).balance;
        Assert.ok(finalBalance > initialBalance, "Refund amount incorrect");
    }

    //Проверка истории ставок
    function testBidHistory() public {
    //Получаем всю историю ставок
    Auction.BidRecord[] memory history = auction.GetBidHistory();

    //Проверяем длину массива через итерацию
    uint historyLength = 0;
    for (uint i = 0; i < history.length; i++) {
        historyLength++;
    }
    Assert.equal(historyLength, 2, "History length mismatch");

    //Проверяем первую запись
    Auction.BidRecord memory firstBid = history[0];
    Assert.equal(firstBid.bidder, participant1, "First bid mismatch");
    Assert.equal(firstBid.amount, 2 ether, "First bid amount mismatch");

    //Проверяем вторую запись
    Auction.BidRecord memory secondBid = history[1];
    Assert.equal(secondBid.bidder, participant2, "Second bid mismatch");
    Assert.equal(secondBid.amount, 3 ether, "Second bid amount mismatch");
    }
}