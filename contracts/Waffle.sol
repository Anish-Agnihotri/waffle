//SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.6.10;

// ============ Imports ============

import "@openzeppelin/contracts/utils/SafeMath.sol";
import "@openzeppelin/contracts/tokens/ERC721/IERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Waffle is IERC721Receiver, VRFConsumerBase {
  // Use OpenZeppelin SafeMath for uint
  using SafeMath for uint256;

  // ============ Mutable storage ============

  // Chainlink keyHash
  bytes32 internal keyHash;
  // Chainlink fee
  uint256 internal fee;
  // Result from Chainlink VRF
  uint256 public randomResult = 0;
  // Toggled when contract requests result from Chainlink VRF
  bool public randomResultRequested = false;

  // NFT owner
  address public owner;
  // Price (in Ether) per raffle slot
  uint256 public slotPrice;
  // Number of total available raffle slots
  uint256 public numSlotsAvailable;
  // Number of filled raffle slots
  uint256 public numSlotsFilled = 0;
  // Array of slot owners
  address[] public slotOwners;
  // Mapping of slot owners to number of slots owned
  mapping(address => uint256) public addressToSlotsOwned;

  // Address of NFT contract
  address public nftContract;
  // NFT ID
  uint256 public nftID;
  // Toggled when contract holds NFT to raffle
  bool public nftOwned = false;

  // ============ Events ============

  // Address of slot claimee and number of slots claimed
  event SlotsClaimed(address indexed claimee, uint256 numClaimed);
  // Address of raffle winner
  event RaffleWon(address indexed winner);

  // ============ Constructor ============

  constructor(
    address _owner,
    address _nftContract,
    address _ChainlinkVRFCoordinator,
    address _ChainlinkLINKToken,
    address _ChainlinkKeyHash,
    uint256 _fee,
    uint256 _nftID,
    uint256 _slotPrice, 
    uint256 _numSlotsAvailable,
  ) VRFConsumerBase(
    _ChainlinkVRFCoordinator,
    _ChainlinkLINKToken
  ) public {
    owner = _owner;
    keyHash = _ChainlinkKeyHash;
    fee = _fee;
    nftContract = _nftContract;
    nftID = _nftID;
    slotPrice = _slotPrice;
    numSlotsAvailable = _numSlotsAvailable;
  }

  // ============ Functions ============

  /**
   * Enables purchasing _numSlots slots in the raffle
   */
  function purchaseSlot(uint256 _numSlots) payable {
    // Require purchasing at least 1 slot
    require(_numSlots > 0, "Waffle: Cannot purchase 0 slots.");
    // Require the raffle contract to own the NFT to raffle
    require(nftOwned == true, "Waffle: Contract does not own raffleable NFT.");
    // Require there to be available raffle slots
    require(numSlotsFilled < numSlotsAvailable, "Waffle: All raffle slots are filled.");
    // Prevent claiming after winner selection
    require(randomResultRequested == false, "Waffle: Cannot purchase slot after winner has been chosen.");
    // Require appropriate payment for number of slots to purchase
    require(msg.value == _numSlots.mul(slotPrice), "Waffle: Insufficient ETH provided to purchase slots.");
    // Require number of slots to purchase to be <= number of available slots
    require(_numSlots <= numSlotsAvailable.sub(numSlotsFilled), "Waffle: Requesting to purchase too many slots.");

    // For each _numSlots
    for (int i = 0; i < _numSlots; i++) {
      // Add address to slot owners array
      slotOwners.push(msg.sender);
    }

    // Increment filled slots
    numSlotsFilled = numSlotsFilled.add(_numSlots);
    // Increment slots owned by address
    addressToSlotsOwned[msg.sender] = addressToSlotsOwned[msg.sender].add(_numSlots);

    // Emit claim event
    emit SlotsClaimed(msg.sender, _numSlots);
  }

  // TODO: function refundSlot() {}

  /**
   * Collects randomness from Chainlink VRF to propose a winner.
   */
  function collectRandomWinner() {
    // Require at least 1 raffle slot to be filled
    require(numSlotsFilled > 0, "Waffle: No slots are filled");
    // Require NFT to be owned by raffle contract
    require(nftOwned == true, "Waffle: Contract does not own raffleable NFT.");
    // Require caller to be raffle deployer
    require(msg.sender == owner, "Waffle: Only owner can call winner collection.");
    // Require this to be the first time that randomness is requested
    require(randomResultRequested == false, "Waffle: Cannot collect winner twice.");

    // Toggle randomness requested
    randomResultRequested = true;

    // Call for random number
    return requestRandomness(keyHash, fee);
  }

  /**
   * Collects random number from Chainlink VRF
   */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    // Store random number as randomResult
    randomResult = randomness;
  }

  /**
   * Disburses NFT to winner and raised raffle pool to owner
   */
  function disburseWinner() {
    // Require that the contract holds the NFT
    require(nftOwned == true, "Waffle: Cannot disurbse NFT to winner without holding NFT.");
    // Require that a winner has been collected already
    require(randomResultRequested == true, "Waffle: Cannot disburse to winner without having collected one.");
    // Require that the random result is not 0
    require(randomResult != 0, "Waffle: Please wait for Chainlink VRF to update the winner first.");

    // Transfer raised raffle pool to owner
    payable(owner).transfer(address(this).balance);

    // Find winner of NFT
    address winner = slotOwners[randomResult.mod(numSlotsFilled)];

    // Transfer NFT to winner
    IERC721(nftContract).safeTransferFrom(address(this), winner, nftID);

    // Toggle nftOwned
    nftOwned = false;

    // Emit raffle winner
    emit RaffleWon(winner);
  }

  /**
   * Deletes raffle, assuming that contract owns NFT and a winner has not been selected
   */
  function deleteRaffle() {
    // Require being owner to delete raffle
    require(msg.sender == owner, "Waffle: Only owner can delete raffle.");
    // Require that the contract holds the NFT
    require(nftOwned == true, "Waffle: Cannot cancel raffle without raffleable NFT.");
    // Require that a winner has not been collected already
    require(randomResultRequested == false, "Waffle: Cannot delete raffle after collecting winner.");

    // Transfer NFT to original owner
    IERC721(nftContract).safeTransferFrom(address(this), msg.sender, nftID);

    // Toggle nftOwned
    nftOwned = false;

    // For each slot owner
    for (uint256 i = numSlotsFilled - 1; i >= 0; i--) {
      // Refund slot owner
      payable(slotOwners[i]).transfer(slotPrice);
      // Pop address from slot owners array
      slotOwners.pop();
    }
  }
}
