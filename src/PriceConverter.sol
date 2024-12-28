// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // function to get the price of ethereum in usd
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI
        // AggregatorV3Interface priceFeed =AggregatorV3Interface();
        (, int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 1e10);
    }
    // function to convert a value based on th eprice

    function getConversion(uint256 _ethAmmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmmountInUsd = (_ethAmmount * ethPrice) / 1e18;
        return ethAmmountInUsd;
    }
}
