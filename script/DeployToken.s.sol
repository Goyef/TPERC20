// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.34; 
import {Script, console} from "forge-std/Script.sol"; 
import {AdvancedToken} from "../src/AdvancedToken.sol"; 
/** 
 * @title DeployToken 
 * @notice Script de déploiement pour AdvancedToken 
 * 
 * Usage : 
 *   # Simulation (dry-run) 
 *   forge script script/DeployToken.s.sol --rpc-url $SEPOLIA_RPC_URL 
 * 
 *   # Déploiement réel 
 *   forge script script/DeployToken.s.sol --rpc-url $SEPOLIA_RPC_URL -
broadcast --verify 
 */ 
contract DeployToken is Script { 
    function run() external { 
        // Charger la clé privée depuis les variables d'environnement 
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY"); 
        // Paramètres du token 
        string memory name = "MyToken"; 
        string memory symbol = "MTK"; 
        uint256 initialSupply = 1_000_000;  // 1 million 
        uint256 cap = 10_000_000;           // cap de 10 millions 
        console.log("Deploying AdvancedToken with:"); 
        console.log("  Name:", name); 
        console.log("  Symbol:", symbol); 
        console.log("  Initial Supply:", initialSupply); 
        console.log("  Cap:", cap); 
        // Démarrer la diffusion des transactions 
        vm.startBroadcast(deployerPrivateKey); 
        // Déployer le contrat 
        AdvancedToken token = new AdvancedToken(name, symbol, initialSupply, cap); 

        vm.stopBroadcast(); 
        // Afficher l'adresse du contrat déployé 
        console.log("\nToken deployed at:", address(token)); 
        console.log("Transaction hash will be shown after broadcast"); 
        console.log("\nAdd this token to MetaMask with:"); 
        console.log("  Address:", address(token)); 
        console.log("  Symbol:", symbol); 
        console.log("  Decimals: 18"); 
    } 
} 