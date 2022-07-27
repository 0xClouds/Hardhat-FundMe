//SPDX-License-Identifier: MIT
//Pragma
pragma solidity ^0.8.8;
//Imports
import "./PriceConverter.sol";
import "hardhat/console.sol";
//Errors
error FundMe__NotOwner();

//Interfaces, Libraries, Contracts

/** @title A contract for crowd funding
 *   @author Cloud
 *   @notice This contract is to demo a sample funding contract
 *   @dev This implements price feeds as our library
 */
contract FundMe {
    //Type Declarations
    using PriceConverter for uint256;
    //State Variables
    uint256 public constant MINIMUM_USD = 1 * 1e18;
    address[] private s_funders;
    address private immutable i_owner;
    mapping(address => uint256) private s_addressToAmountFunded;
    AggregatorV3Interface private s_priceFeed;

    //Modifiers
    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Sender is not owner!");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    //Events

    //Functions
    //// Constructor
    //// recieve
    //// fallback
    //// external
    //// public
    //// internal
    //// private
    //// view/pure

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    //recieve();
    receive() external payable {
        fund();
    }

    //fallback();
    fallback() external payable {
        fund();
    }

    /**
     *   @notice This function funds this contract
     *   @dev this implements price feeds as our library
     */
    function fund() public payable {
        //Set minimum fund amount in USD
        // 1. How do we send ETH to this contract?
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didnt send enough"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        //mappings cant be in in memory

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunders(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
