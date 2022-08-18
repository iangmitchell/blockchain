//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

interface SimpleToken{
    	function addAccount(address _account) external;
    	function deposit(address _from, uint _amount) external payable;
	function freezeAccount(address _account)  external;
	function isFrozen(address _account) external returns(bool);
	function withdraw(address _to, uint amount) external payable;
    	function thawAccount(address _account) external;
}

contract MDXToken is SimpleToken{
    address banker;
    uint balance;
	mapping (address => uint) public balanceMap;
	mapping (address => bool) public freezeMap;
    mapping (address => uint) public freezeInterval;
	uint constant MAX_LIMIT = 1000000000; //mdx-wei
    uint interval = 60;
	event Transfer(address, uint);

    constructor () {
        banker = msg.sender;
        balance = msg.sender.balance;
    }
	function addAccount(address _account) public override {
        balanceMap[_account] = MAX_LIMIT;
        freezeMap[_account] = false;
        freezeInterval[_account] = block.timestamp;
    }
    function deposit(address _from, uint _amount) public override payable{
        require(balanceMap[_from]>=_amount, "Not enough in account");
        balanceMap[_from]-=_amount;
        balance+=_amount;
        freezeAccount(_from);
    }
	function withdraw(address _to, uint _amount) public override payable {
		require(freezeInterval[_to]<=block.timestamp, "Can't withdraw due to time limit");
            thawAccount(_to);
			balance-= _amount;
			balanceMap[_to]+=_amount;
		emit Transfer(_to, _amount);
	}
	function freezeAccount(address _account) public override {
		freezeMap[_account] = true;
        freezeInterval[_account] = block.timestamp + interval;
	}
    function thawAccount(address _account) public override {
        freezeMap[_account]=false;    
    }
	function isFrozen(address _account) public override view returns (bool){
		if ( freezeMap[_account] )
			return true;
		return false;
	}
