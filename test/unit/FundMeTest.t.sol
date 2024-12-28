// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {FundMeDeployScript} from "script/FundeMeDeployScript.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    address USER = makeAddr("user"); // --> Create address for the
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundme = new FundMe();
        FundMeDeployScript fundeMeDeploy = new FundMeDeployScript();
        fundme = fundeMeDeploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsFundMeTest() public view {
        // us address deploy --> fundMeTest.t.sol (fundmeTest.t.sol address deploy) --> fundMe.sol
        // that why we checking owner address is equal to this test address
        // assertEq(fundme.i_owner(),address(this));

        // code after refactoring
        assertEq(fundme.getOwner(), msg.sender);
        console.log(fundme.getOwner());
        console.log(address(this));
    }

    function testFundFailWithoutEnoughEth() public {
        vm.expectRevert(); //--> the next value after this should be reverted if not test should be failed
        fundme.fund(); //-->we send value 0
    }

    modifier funded() {
        vm.prank(USER); //Next Txn will be send be done through USER address
        fundme.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdateFundDataStructure() public funded {
        uint256 amountFunded = fundme.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER); //ChatGPT : why we are using this again ?
        vm.expectRevert();
        fundme.withdraw();
    }

    function testAddFunderToArrayOfFunder() public funded {
        address funder = fundme.getFunder(0);
        assertEq(funder, USER);
    }

    function testWithdrawWithSingleFunder() public funded {
        // ARRANGE
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        // ACT
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; //tx.gasprice build in cheatcode solidity function get current gas price
        console.log("withdraw consumed gas : %d", gasUsed);
        // ASSERT
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundMeBalance = address(fundme).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawFromMultipleFunder() public funded {
        // ARRANGE
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank() // --> new address
            // vm.deal() // --> aidrop some eth in generated address
            // hoak do both prank and deal
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;
        // ACT
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        // ASSERT

        assertEq(address(fundme).balance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, fundme.getOwner().balance);
    }

    function testWithdrawFromMultipleFunderCheaper() public funded {
        // ARRANGE
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank() // --> new address
            // vm.deal() // --> aidrop some eth in generated address
            // hoak do both prank and deal
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;
        // ACT
        vm.prank(fundme.getOwner());
        fundme.withdrawCheaper();
        // ASSERT

        assertEq(address(fundme).balance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, fundme.getOwner().balance);
    }
}
