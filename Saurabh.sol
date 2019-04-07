pragma solidity ^0.5.0;
contract AltCraiglist {
    
    address owner;
    address[] bidaddress;
    uint higgestbidamt;
    address higgestbidadd;
    //uint balance = 0;
    //hash of the previous owner, next owner, decision, 
    
    struct Asset {
        uint asset_id;
        string asset_description;
        string status;
        uint price;
        uint minimum_price_in_bid;
        address owner;
        string bid_open_till_in_hours;
        string reviews;
    }
    
    struct BiddingData{
        address bidder;
        uint asset_id;
        uint amount;
        string Decision;
        string Error;
    }
    
    mapping (address => BiddingData) public bidsandoffers;
    mapping (address => uint) public balances;
    
    Asset public asset_listing;
    
    constructor() public{
        owner = msg.sender; //owner should be the one initializing the contract
    }
    
    function MyAsset( uint asset_id,string memory asset_description, string memory For_sale_or_Bid, uint fix_price_in_$, uint minimum_price_of_bid, string memory bid_open_till_in_hours) public{
        if (msg.sender == owner) {
            asset_listing.asset_description = asset_description;
            asset_listing.asset_id = asset_id;
            asset_listing.status = For_sale_or_Bid;
            asset_listing.price = fix_price_in_$;
            asset_listing.minimum_price_in_bid = minimum_price_of_bid;
            asset_listing.owner = owner;
            asset_listing.bid_open_till_in_hours = bid_open_till_in_hours;
        }
        
    }
    
    function BidorBuy (uint asset_id, uint amount) public returns (string memory) {
        if (msg.sender != owner && bidsandoffers[msg.sender].amount < amount) {
            bidaddress.push(msg.sender);
            bidsandoffers[msg.sender].asset_id = asset_id;
            bidsandoffers[msg.sender].bidder = msg.sender;
            bidsandoffers[msg.sender].amount = amount;
            balances[msg.sender] = 5000;
            if (asset_listing.price != 0 && amount >= asset_listing.price){
                balances[owner] += bidsandoffers[msg.sender].amount;
                balances[msg.sender] -= bidsandoffers[msg.sender].amount;
                asset_listing.owner = msg.sender;
                asset_listing.status = 'Sold';
                bidsandoffers[msg.sender].Decision = 'Accepted';
                owner = msg.sender;
            }
            else{
                HiggestBid();   
            }
        }
    }
    
    function GetBidders () view public returns(address[] memory) {
        if (msg.sender == owner){
            return bidaddress;
        }
    }
    
    function HiggestBid ()private {
        if (bidsandoffers[msg.sender].amount > higgestbidamt){
            higgestbidamt = bidsandoffers[msg.sender].amount;
            higgestbidadd = msg.sender;
        }
        
    }
    
    function CloseBid() public returns (bool) {
        if(msg.sender == owner){
            address[] memory higbidder; 
            uint alength = bidaddress.length;
            balances[owner] += bidsandoffers[higgestbidadd].amount;
            balances[higgestbidadd] -= bidsandoffers[higgestbidadd].amount;
            asset_listing.owner = higgestbidadd;
            owner = higgestbidadd;
            asset_listing.status = 'Sold';
//          asset_listing.price = bidsandoffers[address1].amount;
            bidsandoffers[higgestbidadd].Decision = 'Accepted';
            uint bidlength = bidaddress.length;
            for (uint j = 0; j < bidlength; j++){
                bidsandoffers[bidaddress[j]].Decision = 'Reject';
            }
            bidsandoffers[higgestbidadd].Decision = 'Accepted';
            for (uint i = 0; i < bidlength; i++){
                delete bidaddress[i];
            }
            return true;
        }
    }
    
    function GiveReview(uint asset_id, string memory review) public{
        if (msg.sender == owner){
            asset_listing.reviews = review;
            asset_listing.status = "Off Market";
        }
    }
    
}