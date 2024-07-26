// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {AnimeToken} from "../src/AnimeToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract DeployMerkleAirdrop is Script{

    bytes32 public s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private s_amountToTransfer = 4 * 25 * 1e18;


    function deployerMerkleAirdrop() public returns(MerkleAirdrop,AnimeToken){
        vm.startBroadcast();
        AnimeToken token = new AnimeToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(s_merkleRoot,IERC20(address(token)));
        token.mint(token.owner(),s_amountToTransfer);
        token.transfer(address(airdrop),s_amountToTransfer);
        vm.stopBroadcast();

    }

    function run() external returns(MerkleAirdrop,AnimeToken){
        return deployerMerkleAirdrop();
    }
}