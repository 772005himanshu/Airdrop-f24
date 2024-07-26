

// pragma solidity ^0.8.20;

// import {Test,console} from "forge-std/Test.sol";
// import { MerkleAirdrop } from "../src/MerkleAirdrop.sol";
// import {AnimeToken} from "../src/AnimeToken.sol";
// import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
// import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";



// contract TestMerkleAirdrop is ZkSyncChainChecker,Test {
//     MerkleAirdrop airdrop;
//     AnimeToken token;

//     bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
//     uint256 public constant AMOUNT_TO_CLAIM = 25 * 1e18 ;
//     uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;

//     bytes32 proofOne = 0x4fd31fee0e75780cd67704fbc43caee70fddcaa43631e2e1bc9fb233fada2394;
//     bytes32 proofTwo = 0x81f0e530b56872b6fc3e10f8873804230663f8407e21cef901b8aeb06a25e5e2;
//     bytes32[] public PROOF = [proofOne,proofTwo];
//     address public gasPayer;
//     address user;
//     uint256 userPrivKey;


//     function setUp() public {
//         if(!isZkSyncChain()){
//             // DEPLOY WITH SCRIPT
//             DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
//             (airdrop,token) = deployer.deployerMerkleAirdrop();
//         }
//         else{
//             token = new AnimeToken();
//             airdrop = new MerkleAirdrop(ROOT,token);
//             token.mint(token.owner(),AMOUNT_TO_SEND);
//             token.transfer(address(airdrop),AMOUNT_TO_SEND);
//             // (user,userPrivKey) = makeAddrAndKey("user");
//         }
//         (user,userPrivKey) = makeAddrAndKey("user");
//         gasPayer = makeAddr("gasPayer");

//     }
//     function testUsersCanClaim() public {
//         uint256 startingBalance = token.balanceOf(user);
//         bytes32 digest = airdrop.getMessageHash(user,AMOUNT_TO_CLAIM);

//         // sign a message 
//         (uint8 v,bytes32 r,bytes32 s) = vm.sign(userPrivKey,digest);


//         // gaspayer calls claim using the signed message
//         vm.prank(gasPayer);
//         airdrop.claim(user,AMOUNT_TO_CLAIM,PROOF,v,r,s);
//         // vm.prank() --> line next line

//         uint256 endingBalance = token.balanceOf(user);
//         console.log("Ending Balance:%d",endingBalance);



//         assertEq(endingBalance-startingBalance , AMOUNT_TO_CLAIM);
//     }
// }


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {AnimeToken} from "../../src/AnimeToken.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {DeployMerkleAirdrop} from "../../script/DeployMerkleAirdrop.s.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop airdrop;
    AnimeToken token;
    address gasPayer;
    address user;
    uint256 userPrivKey;

    bytes32 merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 amountToCollect = (25 * 1e18); // 25.000000
    uint256 amountToSend = amountToCollect * 4;

    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [proofOne, proofTwo];

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployerMerkleAirdrop();
        } else {
            token = new AnimeToken();
            airdrop = new MerkleAirdrop(merkleRoot, token);
            token.mint(token.owner(), amountToSend);
            token.transfer(address(airdrop), amountToSend);
        }
        gasPayer = makeAddr("gasPayer");
        (user, userPrivKey) = makeAddrAndKey("user");
    }

    function signMessage(uint256 privKey, address account) public view returns (uint8 v, bytes32 r, bytes32 s) {
        bytes32 hashedMessage = airdrop.getMessageHash(account, amountToCollect);
        (v, r, s) = vm.sign(privKey, hashedMessage);
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);

        // get the signature
        vm.startPrank(user);
        (uint8 v, bytes32 r, bytes32 s) = signMessage(userPrivKey, user);
        vm.stopPrank();

        // gasPayer claims the airdrop for the user
        vm.prank(gasPayer);
        airdrop.claim(user, amountToCollect, proof, v, r, s);
        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending balance: %d", endingBalance);
        assertEq(endingBalance - startingBalance , amountToCollect);
    }
}