// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Test } from "forge-std/Test.sol";
import { MaivToken } from "../src/token/MaivToken.sol";

contract BaseTest is Test {
    MaivToken public sampleToken;

    address public admin = makeAddr("admin");

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public carol = makeAddr("carol");

    uint256 public oneThousand = 1000 ** 18;

    function setUp() public virtual {
        vm.startPrank(admin);
        sampleToken = new MaivToken(admin, admin, [admin, alice, bob]);

        vm.stopPrank();
    }

    /// @dev Expects an event to be emitted by checking all three topics and the data. As mentioned
    /// in the Foundry
    /// Book, the extra `true` arguments don't hurt.
    function expectEmit() public {
        vm.expectEmit({ checkTopic1: true, checkTopic2: true, checkTopic3: true, checkData: true });
    }
}
