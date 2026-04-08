// test/AdvancedToken.t.sol 
pragma solidity ^0.8.34; 
import {Test} from "forge-std/Test.sol"; 
import {AdvancedToken} from "../src/AdvancedToken.sol"; 
contract AdvancedTokenTest is Test { 
    AdvancedToken token; 
    address owner = address(this); 
    address alice = address(0xA11CE); 
    address bob = address(0xB0B); 
    function setUp() public { 
        // Créer un token avec un cap de 10 millions 
        token = new AdvancedToken("Advanced Token", "ADV", 1_000_000, 10_000_000); 
    } 
    // ── Tests de mint() ── 
    function test_Mint_OwnerPeutMint() public { 
        token.mint(alice, 500_000 ether); 
        assertEq(token.balanceOf(alice), 500_000 ether); 
        assertEq(token.totalSupply(), 1_500_000 ether); 
    } 
    function test_Mint_NonOwnerNePeutPas() public { 
        vm.prank(alice); 
        vm.expectRevert("Not owner"); 
        token.mint(bob, 1000 ether); 
    } 
    function test_Mint_RespecteLeCap() public { 
        vm.expectRevert("Cap exceeded"); 
        token.mint(alice, 10_000_000 ether); // totalSupply serait 11M > cap 10M 
    } 
    // ── Tests de burn() ── 
    function test_Burn() public { 
        token.transfer(alice, 1000 ether); 
        vm.prank(alice); 
        token.burn(500 ether); 
        assertEq(token.balanceOf(alice), 500 ether); 
        assertEq(token.totalSupply(), 1_000_000 ether - 500 ether); 
    } 
    function test_BurnFrom() public { 
        token.transfer(alice, 1000 ether); 
        vm.prank(alice); 
        token.approve(bob, 500 ether); 
        vm.prank(bob); 
        token.burnFrom(alice, 300 ether); 
        assertEq(token.balanceOf(alice), 700 ether); 
        assertEq(token.allowance(alice, bob), 200 ether); 
    } 
    // ── Tests de pause() ── 
    function test_Pause_BloqueTransfers() public { 
        token.transfer(alice, 1000 ether); 
        token.pause(); 
        vm.prank(alice); 
        vm.expectRevert("Token is paused"); 
        token.transfer(bob, 100 ether); 
    } 
    function test_Unpause_ReautoriseTransfers() public { 
        token.pause(); 
        token.unpause(); 
        token.transfer(alice, 1000 ether); // devrait passer 
        assertEq(token.balanceOf(alice), 1000 ether); 
    } 
    function test_Pause_NonOwnerNePeutPas() public { 
        vm.prank(alice); 
        vm.expectRevert("Not owner"); 
        token.pause(); 
    } 
    // ── Tests de transferOwnership() ── 
    function test_TransferOwnership() public { 
        token.transferOwnership(alice); 
        assertEq(token.owner(), alice); 
        // L'ancien owner ne peut plus mint 
        vm.expectRevert("Not owner"); 
        token.mint(bob, 1000 ether); 
        // Le nouveau owner peut mint 
        vm.prank(alice); 
        token.mint(bob, 1000 ether); 
        assertEq(token.balanceOf(bob), 1000 ether); 
    } 
    function test_RenounceOwnership() public { 
        token.renounceOwnership(); 
        assertEq(token.owner(), address(0)); 
        // Plus personne ne peut mint 
        vm.expectRevert("Not owner"); 
        token.mint(alice, 1000 ether); 
    } 
} 