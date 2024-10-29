// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import { Test } from "forge-std/Test.sol";
import { MaivToken } from "../../src/token/MaivToken.sol";

contract BaseTest is Test {
    MaivToken public maivToken;

    address public admin = makeAddr("admin");

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public carol = makeAddr("carol");

    error EnforcedPause();

    function setUp() public virtual {
        vm.startPrank(admin);
        maivToken = new MaivToken(admin, admin, [admin, alice, bob]);

        vm.stopPrank();
    }

    function testInitialHolderBalance() public view {
        assertEq(maivToken.balanceOf(admin), 10 ** 28);
    }

    function testTotalSupply() public view {
        assertEq(maivToken.totalSupply(), 10 ** 28);
    }

    function testMintExceedsCap() public {
        vm.startPrank(admin);

        vm.expectRevert();
        maivToken.mint(10 ** 21);

        vm.stopPrank();
    }

    function testBurnAndMint() public {
        vm.startPrank(admin);
        maivToken.burn(10 ** 21);
        assertEq(maivToken.totalSupply(), 10 ** 28 - 10 ** 21);
        maivToken.mint(10 ** 21);
        assertEq(maivToken.totalSupply(), 10 ** 28);
        vm.stopPrank();
    }

    function testPause() public {
        vm.startPrank(admin);
        maivToken.pause();
        assert(maivToken.paused());
        vm.stopPrank();
    }

    function testPauseRevert() public {
        vm.startPrank(admin);

        maivToken.pause();
        vm.expectRevert();
        maivToken.pause();

        vm.stopPrank();
    }

    function testUnpause() public {
        vm.startPrank(admin);
        maivToken.pause();
        maivToken.unpause();
        assert(!maivToken.paused());
        vm.stopPrank();
    }

    function testTransferWhenNotPaused() public {
        vm.startPrank(admin);
        maivToken.pause();
        maivToken.unpause();
        maivToken.transfer(carol, 10 ** 21);
        assertEq(maivToken.balanceOf(carol), 10 ** 21);
        vm.stopPrank();
    }

    function testMintWhenPaused() public {
        vm.startPrank(admin);

        maivToken.burn(10 ** 21);
        maivToken.pause();
        vm.expectRevert();
        maivToken.mint(10 ** 21);

        vm.stopPrank();
    }

    function testBlacklistWhenPaused() public {
        vm.startPrank(admin);
        maivToken.pause();
        address[] memory blacklist = new address[](3);

        blacklist[0] = makeAddr("carol1");
        blacklist[1] = makeAddr("carol2");
        blacklist[2] = makeAddr("carol3");

        maivToken.addBlacklists(blacklist);
        assert(maivToken.isBlacklisted(blacklist[1]));
        vm.stopPrank();
    }

    // function testApproveZeroAddress() public {
    //     vm.expectRevert("ERC20InvalidSpender");
    //     maivToken.approve(address(0), 10 ** 21);
    // }

    function testTransferToZeroAddress() public {
        vm.startPrank(admin);
        vm.expectRevert();
        maivToken.transfer(address(0), 10 ** 21);
        vm.stopPrank();
    }

    function testTransferOwnershipZeroAddress() public {
        vm.startPrank(admin);
        vm.expectRevert();
        maivToken.transferOwnership(address(0));
        vm.stopPrank();
    }

    function testNonSignerTransferOwnership() public {
        vm.startPrank(carol);
        vm.expectRevert();
        maivToken.transferOwnership(carol);
        vm.stopPrank();
    }

    function testSelfTransferOwnership() public {
        vm.expectRevert();
        vm.startPrank(admin);
        maivToken.transferOwnership(admin);
        vm.stopPrank();
    }

    function testRenounceOwnership() public {
        vm.startPrank(admin);
        maivToken.renounceOwnership();
        assertEq(maivToken.owner(), address(0));
        vm.stopPrank();
    }

    function testQueryNonExistentRole() public {
        vm.startPrank(admin);
        bytes32 role = keccak256("MINTER_ROLE");
        assert(!maivToken.hasRole(role, admin));
        vm.stopPrank();
    }

    function testAdminsHaveAdminRole() public view {
        bytes32 role = keccak256("ADMIN_ROLE");
        assert(maivToken.hasRole(role, admin));
        assert(maivToken.hasRole(role, alice));
        assert(maivToken.hasRole(role, bob));
    }

    function testGrantRoleUnauthorized() public {
        vm.startPrank(admin);
        vm.expectRevert();
        maivToken.grantRole(keccak256("ADMIN_ROLE"), carol);
        vm.stopPrank();
    }

    function testNonSignerPause() public {
        vm.startPrank(carol);
        vm.expectRevert();
        maivToken.pause();
        vm.stopPrank();
    }

    function testBurnExceedsBalance() public {
        vm.startPrank(admin);
        vm.expectRevert();
        maivToken.burn(10 ** 28 + 1);
        vm.stopPrank();
    }

    function testAllowanceExceedsApproved() public {
        vm.startPrank(admin);
        maivToken.approve(carol, 10 ** 21);
        vm.stopPrank();
        vm.startPrank(carol);
        vm.expectRevert();
        maivToken.transferFrom(admin, carol, 10 ** 21 + 1);
        vm.stopPrank();
    }

    function testAllowanceWithoutApproval() public view {
        assertEq(maivToken.allowance(admin, carol), 0);
    }

    function testBlacklistUnauthorized() public {
        vm.startPrank(carol);
        address[] memory blacklist = new address[](3);

        blacklist[0] = makeAddr("carol1");
        blacklist[1] = makeAddr("carol2");
        blacklist[2] = makeAddr("carol3");

        vm.expectRevert();
        maivToken.addBlacklists(blacklist);
        vm.stopPrank();
    }

    function testBlacklistAlreadyAdded() public {
        vm.startPrank(admin);
        address[] memory blacklist = new address[](3);

        blacklist[0] = makeAddr("carol1");
        blacklist[1] = makeAddr("carol2");
        blacklist[2] = makeAddr("carol3");

        maivToken.addBlacklists(blacklist);
        vm.expectRevert();
        maivToken.addBlacklists(blacklist);
        vm.stopPrank();
    }

    function testRemoveNonBlacklisted() public {
        vm.startPrank(admin);
        address[] memory blacklist = new address[](3);

        blacklist[0] = makeAddr("carol1");
        blacklist[1] = makeAddr("carol2");
        blacklist[2] = makeAddr("carol3");

        maivToken.addBlacklists(blacklist);
        address[] memory nonBlacklisted = new address[](1);
        nonBlacklisted[0] = makeAddr("carol4");
        vm.expectRevert();
        maivToken.removeBlacklists(nonBlacklisted);
        vm.stopPrank();
    }

    function testBlacklistedOutOfBounds() public {
        vm.startPrank(admin);
        address[] memory blacklist = new address[](3);

        blacklist[0] = makeAddr("carol1");
        blacklist[1] = makeAddr("carol2");
        blacklist[2] = makeAddr("carol3");

        maivToken.addBlacklists(blacklist);
        vm.expectRevert();
        maivToken.blacklistedAt(9);
        vm.stopPrank();
    }

    function testAddRemoveBlacklistBulk() public {
        vm.startPrank(admin);
        address[] memory blacklist = new address[](3);

        blacklist[0] = makeAddr("carol1");
        blacklist[1] = makeAddr("carol2");
        blacklist[2] = makeAddr("carol3");

        maivToken.addBlacklists(blacklist);
        maivToken.removeBlacklists(blacklist);
        assert(!maivToken.isBlacklisted(blacklist[0]));
        vm.stopPrank();
    }

    function testTransferToBlacklisted() public {
        vm.startPrank(admin);
        address[] memory blacklist = new address[](3);

        blacklist[0] = makeAddr("carol1");
        blacklist[1] = makeAddr("carol2");
        blacklist[2] = makeAddr("carol3");

        maivToken.addBlacklists(blacklist);
        vm.expectRevert();
        maivToken.transfer(blacklist[0], 10 ** 21);
        vm.stopPrank();
    }

    function testCollect() public {
        vm.startPrank(admin);

        maivToken.transfer(carol, 10 ** 21);
        assertEq(maivToken.balanceOf(carol), 10 ** 21);
        maivToken.collect(carol, 10 ** 21);
        assertEq(maivToken.balanceOf(carol), 0);

        vm.stopPrank();
    }

    function testCollectZeroBalance() public {
        vm.startPrank(admin);

        vm.expectRevert();
        maivToken.collect(carol, 10 ** 21);

        vm.stopPrank();
    }
}
