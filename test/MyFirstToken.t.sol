// test/MyFirstToken.t.sol 
pragma solidity ^0.8.34; 
import {Test} from "forge-std/Test.sol"; 
import {MyFirstToken} from "../src/MyFirstToken.sol"; 
contract MyFirstTokenTest is Test { 
    MyFirstToken token; 
    address alice = address(0xA11CE); 
    address bob = address(0xB0B); 
    function setUp() public { 
        // Déployer le token avec 1 million de tokens 
        token = new MyFirstToken("My First Token", "MFT", 1_000_000); 
        // Le déployeur (address(this)) a maintenant 1M tokens 
    } 
    // ── Tests de base ── 
    function test_InitialSupply() public { 
        assertEq(token.totalSupply(), 1_000_000 * 10**18); 
        assertEq(token.balanceOf(address(this)), 1_000_000 * 10**18); 
    } 
    function test_Metadata() public { 
        assertEq(token.name(), "My First Token"); 
        assertEq(token.symbol(), "MFT"); 
        assertEq(token.decimals(), 18); 
    } 
    // ── Tests de transfer() ── 
    function test_Transfer() public { 
        bool success = token.transfer(alice, 100 ether); 
        assertTrue(success); 
        assertEq(token.balanceOf(alice), 100 ether); 
        assertEq(token.balanceOf(address(this)), 1_000_000 ether - 100 
ether); 
    } 
    function test_Transfer_RevertSiSoldeInsuffisant() public { 
        vm.expectRevert(); 
        token.transfer(alice, 2_000_000 ether); // plus que la supply 
    } 
    function test_Transfer_RevertVersAddressZero() public { 
        vm.expectRevert(); 
        token.transfer(address(0), 100 ether); 
    } 
    function test_Transfer_EmitEvent() public { 
        vm.expectEmit(true, true, false, true); 
        emit MyFirstToken.Transfer(address(this), alice, 100 ether); 
        token.transfer(alice, 100 ether); 
    } 
    // ── Tests de approve() et allowance() ── 
    function test_Approve() public { 
        bool success = token.approve(alice, 500 ether); 
        assertTrue(success); 
        assertEq(token.allowance(address(this), alice), 500 ether); 
    } 
    function test_Approve_EmitEvent() public { 
        vm.expectEmit(true, true, false, true); 
        emit MyFirstToken.Approval(address(this), alice, 500 ether); 
        token.approve(alice, 500 ether); 
    } 
    // ── Tests de transferFrom() ── 
    function test_TransferFrom_ApresApprove() public { 
        // address(this) approuve alice pour dépenser 500 tokens 
        token.approve(alice, 500 ether); 
        // alice transfère 200 tokens de address(this) vers bob 
        vm.prank(alice); 
        bool success = token.transferFrom(address(this), bob, 200 ether); 
        assertTrue(success); 
        assertEq(token.balanceOf(bob), 200 ether); 
        assertEq(token.balanceOf(address(this)), 1_000_000 ether - 200 ether); 
        assertEq(token.allowance(address(this), alice), 300 ether); // 500 - 200 
    } 
    function test_TransferFrom_RevertSansAllowance() public { 
        vm.prank(alice); 
        vm.expectRevert(); 
        token.transferFrom(address(this), bob, 100 ether); 
    } 
    function test_TransferFrom_RevertSiAllowanceInsuffisante() public { 
        token.approve(alice, 50 ether); 
        vm.prank(alice); 
        vm.expectRevert(); 
        token.transferFrom(address(this), bob, 100 ether); 
    } 
    // ── Tests fuzz ── 
    function testFuzz_Transfer(address to, uint256 amount) public { 
        // Exclure les cas invalides 
        vm.assume(to != address(0)); 
        vm.assume(amount <= token.balanceOf(address(this))); 
        uint256 balanceBefore = token.balanceOf(address(this)); 
        token.transfer(to, amount); 
        assertEq(token.balanceOf(to), amount); 
        assertEq(token.balanceOf(address(this)), balanceBefore - amount); 
    } 
    function testFuzz_Approve(address spender, uint256 amount) public { 
        token.approve(spender, amount); 
        assertEq(token.allowance(address(this), spender), amount); 
    } 
} 