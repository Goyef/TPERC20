// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.34; 
import "./MyFirstToken.sol"; 
/** 
 * @title AdvancedToken 
 * @notice Token ERC20 avec fonctionnalités avancées 
 */ 
contract AdvancedToken is MyFirstToken { 
    // --- Access Control --- 
    address public owner; 
    modifier onlyOwner() { 
        require(msg.sender == owner, "Not owner"); 
        _; 
    } 
    // --- Pause --- 
    bool public paused; 
    modifier whenNotPaused() { 
        require(!paused, "Token is paused"); 
        _; 
    } 
    // --- Cap --- 
    uint256 public cap; // 0 = pas de cap 
    // --- Events --- 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); 
    event Paused(address account); 
    event Unpaused(address account); 
    event Minted(address indexed to, uint256 amount); 
    event Burned(address indexed from, uint256 amount); 
    constructor( 
        string memory _name, 
        string memory _symbol, 
        uint256 _initialSupply, 
        uint256 _cap 
    ) MyFirstToken(_name, _symbol, _initialSupply) { 
        owner = msg.sender; 
        cap = _cap * 10**decimals; 
        // Vérifier que l'initialSupply ne dépasse pas le cap 
        if (cap > 0) { 
            require(totalSupply <= cap, "Initial supply exceeds cap"); 
        } 
    } 
    // 
    // Access Control 
    // 
 
    function transferOwnership(address newOwner) external onlyOwner { 
        require(newOwner != address(0), "New owner is zero address"); 
        address oldOwner = owner; 
        owner = newOwner; 
        emit OwnershipTransferred(oldOwner, newOwner); 
    } 
    function renounceOwnership() external onlyOwner { 
        address oldOwner = owner; 
        owner = address(0); 
        emit OwnershipTransferred(oldOwner, address(0)); 
    } 
    // 
    // Pause 
    // 
    function pause() external onlyOwner { 
        paused = true; 
        emit Paused(msg.sender); 
    } 
    function unpause() external onlyOwner { 
        paused = false; 
        emit Unpaused(msg.sender); 
    } 
    // 
    // Mint et Burn 
    // 
    /** 
     * @notice Crée de nouveaux tokens (owner seulement) 
     * @dev Respecte le cap si défini 
     */ 
    function mint(address to, uint256 amount) external onlyOwner { 
        if (cap > 0) { 
            require(totalSupply + amount <= cap, "Cap exceeded"); 
        } 
        _mint(to, amount); 
        emit Minted(to, amount); 
    } 
    /** 
     * @notice Détruit des tokens de son propre compte 
     */ 
    function burn(uint256 amount) external { 
        _burn(msg.sender, amount); 
        emit Burned(msg.sender, amount); 
    } 
    /** 
     * @notice Détruit des tokens d'un autre compte (nécessite allowance) 
     */ 
    function burnFrom(address from, uint256 amount) external { 
        uint256 currentAllowance = _allowances[from][msg.sender]; 
        require(currentAllowance >= amount, "Burn amount exceeds allowance"); 
        _allowances[from][msg.sender] = currentAllowance - amount; 
        _burn(from, amount); 
        emit Burned(from, amount); 
    } 
    // 
    // Override transfer() et transferFrom() pour ajouter whenNotPaused 
    // 
    function transfer(address to, uint256 amount) 
        public 
        override 
        whenNotPaused 
        returns (bool) 
    { 
        return super.transfer(to, amount); 
    } 
    function transferFrom(address from, address to, uint256 amount) 
        public 
        override 
        whenNotPaused 
        returns (bool) 
    { 
        return super.transferFrom(from, to, amount); 
    } 
}