// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundeMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;
    address[] private s_funders;
    mapping(address funder => uint256 amountFunded) private s_addressToAmmountFunded;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        // msg.value->returns value of eth sended to contract by user
        require(msg.value.getConversion(s_priceFeed) >= MINIMUM_USD, "did't send enoght ETH"); //1e18 = 1 ETH = 1 * 10**18 wei
        // msg.sender->return address of the user who is calling function
        s_funders.push(msg.sender);
        s_addressToAmmountFunded[msg.sender] = s_addressToAmmountFunded[msg.sender] + msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function withdrawCheaper() public onlyOwner {
        uint256 funderLength = s_funders.length;
        for (uint256 funderIndex = 0; funderIndex < funderLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}(""); //in call parametere we entere the function which we want to call
        require(callSuccess, "send failed");
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmmountFunded[funder] = 0;
        }
        // reset the array funder
        s_funders = new address[](0);

        // withdraw funds
        // transfer method -> revert the method automatically
        // payable(msg.sender).transfer(address(this).balance);
        // send method -> do not rever the method automatically
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"Send failed");
        // call -> can you used for many thing but for now we are seeing for transaction
        // cant revert automatically like transfer

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}(""); //in call parametere we entere the function which we want to call
        require(callSuccess, "send failed");
    }

    modifier onlyOwner() {
        // require(msg.sender==i_owner,"Sender is not owner");
        if (msg.sender != i_owner) revert FundeMe__NotOwner();
        _;
    }

    // what happen if someone sends this contract ETH without calling the fund function
    // receive : trigger this function when some one send us eth
    //           trigger this function when some do not send use data
    receive() external payable {
        fund();
    }
    // fallback : trigger this function when some one send random data

    fallback() external payable {
        fund();
    }

    // getter functions
    // set the getter of the private storage variable
    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        return s_addressToAmmountFunded[fundingAddress];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }
}
