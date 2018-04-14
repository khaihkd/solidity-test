pragma solidity ^0.4.19;
// ================= Ownable Contract start =============================
/*
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
    address public owner;

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}
// ================= Ownable Contract end ===============================

// ================= Safemath Lib ============================
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
// ================= Safemath Lib end ==============================

// ================= ERC20 Token Contract start =========================
/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// ================= ERC20 Token Contract end ===========================

// ================= Standard Token Contract start ======================
contract StandardToken is ERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    uint256 totalSupply_;

    /**
    * @dev total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
}
// ================= Standard Token Contract end ========================

// ================= Pausable Token Contract start ======================
/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
    * @dev modifier to allow actions only when the contract IS paused
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev modifier to allow actions only when the contract IS NOT paused
    */
    modifier whenPaused {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() public onlyOwner whenNotPaused returns (bool) {
        paused = true;
        Pause();
        return true;
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() public onlyOwner whenPaused returns (bool) {
        paused = false;
        Unpause();
        return true;
    }
}
// ================= Pausable Token Contract end ========================

// ================= BinkabiToken  start =======================
contract BinkabiTokenCreate is StandardToken, Pausable{
    string public constant name = "Binkabi";
    string public constant symbol = "BNB";
    uint256 public constant decimals = 18;

    address public tokenSaleAddress;
    address public binkabiDepositAddress; // MultiSigWallet

    uint256 public constant binkabiDeposit = 100000000 * 10 ** decimals;

    function BinkabiTokenCreate(address _binkabiDepositAddress) public {
        binkabiDepositAddress = _binkabiDepositAddress;

        balances[binkabiDepositAddress] = binkabiDeposit;
        Transfer(0x0, binkabiDepositAddress, binkabiDeposit);
        totalSupply_ = binkabiDeposit;
    }    

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool success) {
        return super.transfer(_to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool success) {
        return super.approve(_spender, _value);
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return super.balanceOf(_owner);
    }

    // Setup Token Sale Smart Contract
    function setTokenSaleAddress(address _tokenSaleAddress) public onlyOwner {
        if (_tokenSaleAddress != address(0)) {
            tokenSaleAddress = _tokenSaleAddress;
        }
    }

    function mint(address _recipient, uint256 _value) public whenNotPaused returns (bool success) {
        require(_value > 0);
        // This function is only called by Token Sale Smart Contract
        require(msg.sender == tokenSaleAddress);

        balances[binkabiDepositAddress] = balances[binkabiDepositAddress].sub(_value);
        balances[_recipient] = balances[_recipient].add(_value);

        Transfer(binkabiDepositAddress, _recipient, _value);
        return true;
    }

}
// ================= ICO Token Contract end =======================

contract BinkabiTokenSale is Pausable {
    using SafeMath for uint256;
    address public binkabiDepositAddress;
    uint256 public constant tokenExchangeRate = 1000;
    uint256 public constant totalTokenSale = 50000000 * 10 ** 18;
    uint256 public totalTokenSold = 0;

    BinkabiTokenCreate binkabi;

    event MintBinkabi(address from, address to, uint256 val);
    event RefundBinkabi(address to, uint256 val);
    event LogBinkabi(address add, uint256 val);

    function BinkabiTokenSale(
        BinkabiTokenCreate _binkabiTokenAddress,
        address _binkabiDepositAddress
    ) public {
        binkabi = BinkabiTokenCreate(_binkabiTokenAddress);
        binkabiDepositAddress = _binkabiDepositAddress;
    }

    function buy(address to, uint256 val) internal returns (bool success) {
        MintBinkabi(binkabiDepositAddress, to, val);
        return binkabi.mint(to, val);
    }

    function () public payable {
        createTokens(msg.sender, msg.value);
    }

    function createTokens(address _beneficiary, uint256 _value) internal whenNotPaused {
        uint256 tokens = _value.mul(tokenExchangeRate);
        uint256 tokenAvailable = totalTokenSale - totalTokenSold;
        uint256 etherToRefund = 0;
        uint256 currentTokenSell = 0;

        require(tokenAvailable > 0);

        if (tokens > tokenAvailable){
            currentTokenSell  = tokenAvailable;
            etherToRefund = (tokens - tokenAvailable).div(tokenExchangeRate);
        } else {
            currentTokenSell = tokens;
        }

        buy(_beneficiary, currentTokenSell);
        totalTokenSold += currentTokenSell;

        if (etherToRefund > 0){
            RefundBinkabi(msg.sender, etherToRefund);
            msg.sender.transfer(etherToRefund);
        }

        binkabiDepositAddress.transfer(this.balance);
        return;
    }


  /// @dev Ends the funding period and sends the ETH home
  function finalize() external onlyOwner {
    binkabiDepositAddress.transfer(this.balance);
  }
}

