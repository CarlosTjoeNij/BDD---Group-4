// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract CharityNEW {
    string public name; //define a token name
    string public symbol; //define a token symbol
    address payable public  tokenOwner;  //tokenOwner, the address can receive ether
    uint256 constant tokenPrice = 10; // token price, unit wei
    uint256 private _totalSupply; //the total supply of the tokenOwner
    uint256 constant amountOfItem_threshold = 5; // The amount of items that need to be scanned (bags have 5 items)
    
    // different roles
    enum Role {
    Donor,
    Charity, 
    Retailer
    }
    // define a struct "Project"
    struct Project {
        uint256 ID; // the project identifier
    }
    // define a struct "Donation"
    struct Donation {
        uint256 ID; // the donation identifier
        string url; // the donation url containing information
        uint256 itemAmount;
        bool rightAmountOfItems;
    }
    // define a struct "Actor"
    struct Actor {
        Role role;
        string name;
        bool isDefined;
    }
    
     mapping (address => uint256) private balances; 
     mapping (address => Actor) private actors;
     mapping (uint256 => Project) private projects; // a mapping from projectID to a project
     mapping (uint256 => Donation) private donations; // a mapping from donationID to a donation
    
    // constructor, to be intialized when the contract is deployed 
    constructor (string memory _name, string memory _symbol, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        _totalSupply = _initialSupply;
        tokenOwner = payable(msg.sender); //the address deploying the smart contract
        balances[msg.sender] = _initialSupply; // the balances of the tokenOwner is intialized as the totalsupply
    }
    
    // modifier to check if the caller is the token owner
    modifier OnlyTokenOwner() {
        require(msg.sender == tokenOwner, 'caller is not the token owner.');
        _;
    }
    
    modifier OnlyDonor() {
        require(actors[msg.sender].role == Role.Donor, 'caller is not a donor.');
        _;
    }
    
    modifier OnlyRetailer() {
        require(actors[msg.sender].role == Role.Retailer, 'caller is not a retailer.');
        _;
    }
    
    modifier OnlyCharity() {
        require(actors[msg.sender].role == Role.Charity, 'caller is not a charity.');
        _;
    }
    
    modifier registered(address _addr) {
      require(actors[_addr].isDefined, 'Actor does not exist.');
      _;
    }

    //return the token balance of a passed address
    function tokenBalance(address _addr) public view returns (uint256) {
        return balances[_addr];
    }
    
    // return the ether banlance of a passed address
    function etherBalance(address _addr) public view returns (uint256) {
        return _addr.balance;
    }
    
    // token minting, only the token owner can mint tokens, _amount is the number of tokens to be mint
    function mint(uint256 _amount) public OnlyTokenOwner {
        _totalSupply += _amount; // the total token supply increases
        balances[msg.sender] += _amount; //the token balance of the token owner increases
    }
    
    // token burning, only the token owner can burn a certain amount of tokens, 
    // the owner can burn amount of tokens of a given account
    function burn(address _account, uint256 _amount) public OnlyTokenOwner {
        require(_account != address(0)); // the address is a non-zero address
        require(_amount <= balances[_account]); // the amount of burned should not be more than the current balance
        _totalSupply -= _amount;
        balances[_account] -= _amount;
    }
    
    // Buy tokens from the token owner
    function buyToken() public payable {
       uint256 tokenNum = msg.value/tokenPrice; //number of tokens to be bought
       require(msg.value > 0); //the paid money should be more than 0
      tokenOwner.transfer(msg.value); //transfer ether from the buyer to the seller (i.e., tokenOwner)
        balances[tokenOwner] -= tokenNum; // the number of tokens held by the token owner decreases
        balances[msg.sender] += tokenNum;  // the buyer gets the corresponding number of tokens
    }

    // token transfer from the caller to a specified account
    function tokenTransfer(address _to, uint256 _amount) public returns (bool) {
        require(balances[msg.sender] >= _amount); // the token balance of the caller should be more than the amount of tokens
        require(_to != address(0));
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        return true;
    }
    
    function register(address _addr, Role _role, string memory _name) public {
        Actor memory actor = actors[_addr];
        actor.role = _role;
        actor.name = _name;
        actor.isDefined = true;
        actors[_addr] = actor;
    }
    // check if 5 items have been scanned, and therefore if the right amount of items are received
    function checkScannedItems(uint256 _id) private {
        Donation storage _donation = donations[_id];
        if (_donation.itemAmount == amountOfItem_threshold)
        donations[_id].rightAmountOfItems = true;
        else
        donations[_id].rightAmountOfItems = false;
    }
    
    // retrieve event/donation information
    function getEventInfo(uint256 _id) public view returns
    (
        uint256 project_id, 
        uint256 donation_id,
        string memory url,
        bool RightAmountOfItems
    )
    {
        project_id = projects[_id].ID;
        donation_id = donations[_id].ID;
        url = donations[_id].url;
        RightAmountOfItems = donations[_id].rightAmountOfItems;
        
    }
    
    // retrieve an actor's information
    function getActorInfo(address _addr) public view returns
    (
        Role _role,
        string memory _name
    )
    {
        _role = actors[_addr].role;
        _name = actors[_addr].name;
    }
}
