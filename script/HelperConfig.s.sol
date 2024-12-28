// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// 1. Deploy mock when we are on a loacl anvil chain
// 2. keep track of contract address across different chain
// SEPOLIA ETH/USD
// Mainet ETH/USD

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.t.sol";

contract HelperConfig is Script {
    // if we are on a local anvil,we deploy mocks
    // otherwise ,graps the exisiting addresss from the live network

    // Magic Numbers
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetConfig {
        address priceFeed;
    }

    NetConfig public activeNetConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetConfig = getSepoliaEthConfig();
        } else {
            activeNetConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetConfig memory) {
        NetConfig memory sepoliaConfig = NetConfig({priceFeed: 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF});
        return sepoliaConfig;
    }

    function getAnvilEthConfig() public returns (NetConfig memory) {
        // chekcing whether the activeNetConfig is already set if yes so there is no need to execute below contract
        if (activeNetConfig.priceFeed != address(0)) {
            return activeNetConfig;
        }
        // deploy the mock
        // return the mock address

        // step-1 : deploy the mock
        vm.startBroadcast();
        MockV3Aggregator mockContract = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetConfig memory anvilConfig = NetConfig({priceFeed: address(mockContract)});

        // step-2 : return the mock address
        return anvilConfig;
    }
}
