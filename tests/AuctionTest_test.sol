// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "remix_tests.sol"; // Импортируем библиотеку для тестирования в Remix
import "../lessonSix/Auction.sol";

contract AuctionTest {
    Auction auction;
    address seller;
    address bidder1;
    address bidder2;

    function beforeEach() public {
        seller = address(this); // Используем текущий контракт как продавца
        bidder1 = address(0x456);
        bidder2 = address(0x789);

        auction = new Auction("Test Item", 1 ether, 5 ether, 2, 60);
    }

    // Проверяет начальное состояние контракта после его развертывания.
    function testInitialState() public {
        Assert.equal(auction.Item(), "Test Item", "Item should be 'Test Item'");
        Assert.equal(auction.SELLER(), seller, "Seller should be the deployer");
        Assert.equal(auction.StartingCost(), 1 ether, "Starting cost should be 1 ether");
        Assert.equal(auction.BidStep(), 5 ether, "Bid step should be 0.5 ether");
        Assert.equal(auction.MaxParticipants(), 2, "Max participants should be 2");
        Assert.equal(auction.StepTime(), 60, "Step time should be 60");
        Assert.equal(auction.HasStarted(), false, "Auction should not have started");
        Assert.equal(auction.HasEnded(), false, "Auction should not have ended");
    }

    // Проверяет, что аукцион может быть успешно запущен продавцом.
    function testStartAuction() public {
        auction.StartAuction();
        Assert.equal(auction.HasStarted(), true, "Auction should have started");
        Assert.equal(auction.StartTime(), block.timestamp, "Start time should be current timestamp");
    }

    // Проверяет, что участники могут делать ставки и что ставки корректно обрабатываются.
    function testBid() public {
        auction.StartAuction();

        auction.GetPermission(bidder1);
        auction.GetPermission(bidder2);

        try auction.Bid{value: 1 ether}() {
            Assert.ok(false, "Bid should fail with not enough ether");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Not enough ether. Current cost plus bid: 1.5", "Expected revert message");
        }

        try auction.Bid{value: 1.5 ether}() {
            Assert.ok(true, "Bid should succeed with correct amount");
        } catch {
            Assert.ok(false, "Bid should not fail with correct amount");
        }

        Assert.equal(auction.CurrentCost(), 1.5 ether, "Current cost should be 1.5 ether");
        Assert.equal(auction.HighestBidder(), address(this), "Highest bidder should be the current contract");
    }

    // Проверяет, что аукцион может быть завершен вручную продавцом.
    function testEndAuction() public {
        auction.StartAuction();

        auction.GetPermission(bidder1);
        auction.GetPermission(bidder2);

        auction.Bid{value: 15 ether}();

        auction.EndAuction();

        Assert.equal(auction.HasEnded(), true, "Auction should have ended");
        Assert.equal(auction.Winner(), address(this), "Winner should be the current contract");
    }

    // Проверяет, что участники, которые не выиграли аукцион, могут вернуть свои ставки.
    function testRefund() public {
        auction.StartAuction();

        auction.GetPermission(bidder1);
        auction.GetPermission(bidder2);

        auction.Bid{value: 1.5 ether}();

        auction.EndAuction();

        try auction.Refund() {
            Assert.ok(false, "Refund should fail for the winner");
        } catch Error(string memory reason) {
            Assert.equal(reason, "The winner cannot refund.", "Expected revert message");
        }
    }

    // Проверяет, что победитель может получить сообщение о победе.
    function testGetItem() public {
        auction.StartAuction();

        auction.GetPermission(bidder1);
        auction.GetPermission(bidder2);

        auction.Bid{value: 15 ether}();

        auction.EndAuction();

        string memory message = auction.GetItem();
        Assert.equal(message, "Congratulations! You are the winner. Here is your item.", "Message should be correct");
    }
}