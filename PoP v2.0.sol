contract PoP {
    
    address owner;
    uint bidcounter;
    address[] bidaddress;
    //uint balance = 0;
    
    //hash of the previous owner, next owner, decision, 
    
    struct Asset {
        string asset;
        uint asset_id;
        uint price;
        address owner;
        address[] previousowners;
        string SellOrRent;
        address Loanee;
        uint timestamp;
        bytes32 hash;
        uint rent_duration_in_epoch;
    }
    
    struct BiddingData{
        address bidder;
        string typeofbid;
        uint asset_id;
        uint amount;
        string Decision;
    }
    
    mapping (address => BiddingData) public bids;
    mapping (address => uint) public balances;
    
    Asset public asset_ADAM;
    
    function PoP() public{
        owner = msg.sender; //owner should be the one initializing the contract
    }
    
    //modifier expire(address addr) {
    //    asset_ADAM.rent_duration_in_epoch = 0;
    //    _;
    //}
    
    function CreateAsset(string asset_type, uint asset_id, uint asking_price, string Sell_or_Rent, uint rent_duration_in_epoch) public{
        if (msg.sender == owner) {                  //only the owner can create the asset
            asset_ADAM.asset = asset_type;
            asset_ADAM.asset_id = asset_id;
            asset_ADAM.price = asking_price;
            asset_ADAM.owner = owner;               //current owner
            asset_ADAM.SellOrRent = Sell_or_Rent;   //Decide whether to sell or rent the asset
            asset_ADAM.timestamp = block.timestamp; //timestamp for creation of the asset
            //expire(msg.sender);
            asset_ADAM.hash = setHash(asset_ADAM.asset_id, asset_ADAM.owner, asset_ADAM.previousowners);
            asset_ADAM.rent_duration_in_epoch = block.timestamp + rent_duration_in_epoch;
            bidcounter = 0;
        }
    }
    
    function setHash(uint asset_id, address owner, address[] previousowners) public returns(bytes32) {
        return(keccak256(asset_id, owner, previousowners));
    }
    
    function Bid (string typeofbid, uint asset_id, uint amount) public {
        if (msg.sender != owner && bids[msg.sender].amount < amount) {                  //owner cannot bid
            bidaddress.push(msg.sender);
            var bid1 = bids[msg.sender];
            bidcounter += 1;
            bid1.asset_id = asset_id;
            bid1.typeofbid = typeofbid;
            bid1.bidder = msg.sender;
            bid1.amount = amount;
            balances[msg.sender] = 5000;            //initialize the balance of the bidder to 5000 units
            //One bid only, or multiple bids of higher value
        }
    }
    
    function GetBidders () view public returns(address[]) {
        if (msg.sender == owner){
            return bidaddress;
        }
    }
    
    function Sell(uint asset_id, address address1) public returns (bool) {
        if(msg.sender == owner){
            
            if (asset_ADAM.Loanee == 0x0000000000000000000000000000000000000000 && 
            asset_id == asset_ADAM.asset_id && 
            balances[address1] > bids[address1].amount){
                asset_ADAM.previousowners.push(owner);
                balances[owner] += bids[address1].amount;
                balances[address1] -= bids[address1].amount;
                asset_ADAM.owner = address1;
                asset_ADAM.SellOrRent = 'None';
                asset_ADAM.price = bids[address1].amount;
                asset_ADAM.timestamp = block.timestamp;
                asset_ADAM.hash = setHash(asset_ADAM.asset_id, asset_ADAM.owner, asset_ADAM.previousowners);
                bids[address1].Decision = 'Accept';
                uint bidlength = bidaddress.length;
                for (uint j = 0; j < bidlength; j++){
                    bids[bidaddress[i]].Decision = 'Reject';
                }
                bids[address1].Decision = 'Accept';
                for (uint i = 0; i < bidlength; i++){
                    delete bidaddress[i];
                }
            return true;
            }
            else{
                bids[address1].Decision = 'Reject';
                return false;
            }
        }
    }
    
    function Rent(uint asset_id, address address1, uint rent_duration) public {
        if(msg.sender == owner) {
            if (asset_ADAM.Loanee == 0x0000000000000000000000000000000000000000 &&
            asset_id == asset_ADAM.asset_id &&
            balances[address1] > bids[address1].amount) {
                asset_ADAM.SellOrRent = 'None';
                bids[address1].Decision = 'Accept';
				asset_ADAM.Loanee = address1;
            }
        }
    }
}
