// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract FundMeDeployScript is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUSDPriceFeed = helperConfig.activeNetConfig();

        vm.startBroadcast();
        FundMe fundme = new FundMe(ethUSDPriceFeed);
        vm.stopBroadcast();
        return fundme;
    }
}
