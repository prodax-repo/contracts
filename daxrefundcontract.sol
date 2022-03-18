//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

// Refund can be done only once so if you refund and stake again. you will not be able to claim again

    abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}



contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

    interface OD {
        function userInfo(address account) external view returns (uint256 for_withdraw, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus);
    }


    contract DaxRefund is Ownable {
        mapping(address => bool) public isRefunded;
        uint256 public refundAmount;
        address oldStake = 0xdbF843cb81E326900800703f96BeA23Dac4dd8aE;
        
    function RefundDax() public {
            require(isRefunded[msg.sender] == false);
            uint256 amount;
            uint256 bonus;
            amount = checkInvestment(msg.sender);
            bonus = amount / 10;
            refundAmount = amount + bonus;
            payable(msg.sender).transfer(refundAmount);
            isRefunded[msg.sender] = true;
        }

    function checkInvestment(address _address) public view returns(uint256) {
        uint256 for_withdraw;
        uint256 total_invested;
        uint256 total_withdrawn;
        uint256 total_match_bonus;
        (for_withdraw,total_invested,total_withdrawn,total_match_bonus) =  OD(oldStake).userInfo(_address);
        return total_invested;
    }   
    
    function resetClaim(address unclaimed, bool _status) public onlyOwner{
        isRefunded[unclaimed] = _status;
    }
    function takeExcessDAX(uint256 amount, address wallet) public onlyOwner{
        payable(wallet).transfer(amount);
    }

      
    }
