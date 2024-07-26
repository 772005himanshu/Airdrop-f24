// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";




contract ClaimAirdrop is Script {

    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 ;
    uint256 AMOUNT_TO_COLLECT = 25 * 1e18 ;
    bytes32[] PROOF_ONE = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32[] PROOF_TWO = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [PROOF_ONE,PROOF_TWO];
    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();  // this is for starting th Transaction
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, AMOUNT_TO_COLLECT, proof, v, r, s);
        vm.stopBroadcast();  


    }
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainId);
        claimAirdrop(mostRecentlyDeployed);
        
    }
}