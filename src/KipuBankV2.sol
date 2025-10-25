// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

 // --- Imports ---
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
//import {IOracle} from "./IOracle.sol"; // for testing in Remix environment


/**
 * @title KipuBankV2
 * @author Michel Massaad
 * @notice A decentralized bank that supports ETH and USDC deposits and withdrawals.
 * @dev This contract implements a USD-based deposit cap for ETH using Chainlink Price Feeds.
 * It is owned by the deployer and follows best practices for security and documentation.
 */
contract KipuBankV2 is Ownable {

    // =================================================================================================================
    //                                                   STATE VARIABLES
    // =================================================================================================================

    // --- Immutable & Constant Variables ---

    /// @notice The interface to interact with the Chainlink ETH/USD price feed.
    AggregatorV3Interface public immutable priceFeed;
    /// @notice The ERC20 token contract for USDC.
    IERC20 public immutable USDC;
    /// @notice The global deposit cap for ETH, denominated in USD with 8 decimals.
    uint256 public immutable BANK_CAP_USD;

    // --- Storage Variables ---
    /// @notice Total amount of ETH currently deposited in the contract (in wei).
    uint256 public totalEthDeposited;
    /// @notice Reentrancy guard flag.
    bool private locked;

    /**
     * @notice A struct to store the balances of each user for supported assets.
     * @param eth The user's balance of ETH in wei.
     * @param usdc The user's balance of USDC in its smallest unit (6 decimals).
     */
    struct Balances {
        uint256 eth;
        uint256 usdc;
    }
    
    // --- Mappings ---
    /// @notice Mapping of each user’s address to their balances.
    mapping (address => Balances) public balances;

    // =================================================================================================================
    //                                                       EVENTS
    // =================================================================================================================

    /**
     * @notice Emitted when a user successfully deposits ETH or USDC.
     * @param user Address of the depositor.
     * @param usdcOrEth Type of asset deposited ("USDC" or "ETH").
     * @param amount Amount deposited.
     */
    event Deposit(address indexed user, string indexed usdcOrEth, uint256 amount);

    /**
     * @notice Emitted when a user successfully withdraws funds.
     * @param user The address of the withdrawer.
     * @param usdcOrEth Type of asset withdrawn ("USDC" or "ETH").
     * @param amount The amount withdrawn in the token's smallest unit.
     */
    event Withdrawal(address indexed user, string indexed usdcOrEth, uint256 amount);

    // =================================================================================================================
    //                                                      ERRORS
    // =================================================================================================================

    /// @notice Thrown when total ETH deposits exceed the global bank cap.
    error BankCapExceeded();
    
    /// @notice Error thrown when a user tries to withdraw more than their balance.
    error InsufficientBalance();
    
    /// @notice Error thrown when the provided amount is invalid (e.g., 0).
    error InvalidAmount();
    
    /// @notice Error thrown when a withdrawal transfer fails.
    /// @param errorData The data returned by the failed call.
    error WithdrawalFailed(bytes errorData);
    
    /// @notice Error for reentrancy guard, thrown when a reentrant call is detected.
    error ReentrantCall();

    /// @notice Thrown when a provided address is invalid (zero address).
    error InvalidAddress();

    // =================================================================================================================
    //                                                      MODIFIERS
    // =================================================================================================================

    /**
     * @notice Prevents reentrancy attacks by locking function execution.
     * @dev If the contract is already executing a `nonReentrant` function, it reverts.
     */
     modifier nonReentrant() {
        if (locked) revert ReentrantCall();
        locked = true;
        _;
        locked = false;
    }

    /**
     * @notice Ensures the provided amount is greater than zero.
     * @param _amount The amount to check.
     */
    modifier nonZeroAmount(uint256 _amount) {
        if (_amount == 0) revert InvalidAmount();
        _;
    }

    // =================================================================================================================
    //                                                      CONSTRUCTOR
    // =================================================================================================================

    /**
    * @notice Initializes the contract.
    * @param _priceFeedAddress The Chainlink ETH/USD price feed address.
    * @param _usdcTokenAddress The address of the USDC token contract.
    * @param _bankCapUSD The total deposit cap for ETH, in whole USD (e.g., 10000 for $10,000).
    */
    constructor(
        address _priceFeedAddress, // 0x694AA1769357215DE4FAC081bf1f309aDC325306
        address _usdcTokenAddress, // 0xA58B942043A0017bC318AE2BAa1d8D2FeeBD56fE
        uint256 _bankCapUSD        
    ) Ownable(msg.sender) { 
        if (_priceFeedAddress == address(0) || _usdcTokenAddress == address(0)) {
            revert InvalidAddress();
        }

        priceFeed = AggregatorV3Interface(_priceFeedAddress);
        USDC = IERC20(_usdcTokenAddress);
        BANK_CAP_USD = _bankCapUSD * (10**8); // Adjust for 8 decimal precision
    }

    // =================================================================================================================
    //                                                 EXTERNAL FUNCTIONS
    // =================================================================================================================

    /**
     * @notice Deposits ETH into the user's balance, respecting the global USD bank cap.
     * @dev The function is payable and expects ETH to be sent with the transaction.
     */
    function depositEth() external payable nonZeroAmount(msg.value) {
        // --- Checks ---
        uint256 futureTotalEthValueUSD = getEthValueInUSD(totalEthDeposited + msg.value);
        if (futureTotalEthValueUSD > BANK_CAP_USD) {
            revert BankCapExceeded();
        }
        // --- Effects ---
        unchecked {
            totalEthDeposited += msg.value;
        }
        balances[msg.sender].eth += msg.value;

        // --- Interactions ---
        emit Deposit(msg.sender,"ETH", msg.value);
    }

    /**
     * @notice Deposits USDC tokens into the user's balance.
     * @dev The user must call `approve` on the USDC contract to authorize this contract first.
     * @param _amount The amount of USDC (in its smallest unit) to deposit.
     */
    function depositUSDC(uint256 _amount) external nonZeroAmount(_amount) {
        balances[msg.sender].usdc += _amount;
        USDC.transferFrom(msg.sender, address(this), _amount);
        emit Deposit(msg.sender,"USDC", _amount);
    }

    /**
     * @notice Withdraws ETH from the user's balance to their address.
     * @dev Follows the Checks-Effects-Interactions pattern to prevent reentrancy.
     * @param _amount The amount of ETH (in wei) to withdraw.
     */
    function withdrawalEth(uint256 _amount) external nonReentrant nonZeroAmount(_amount) {

        // --- Checks ---
        uint256 userBalance = balances[msg.sender].eth; // Read state once to save gas
        if (_amount > userBalance) revert InsufficientBalance();

        // --- Effects ---
        balances[msg.sender].eth = userBalance - _amount;
        totalEthDeposited -= _amount;

        // --- Interaction ---
        _transferEth(payable(msg.sender), _amount);

        emit Withdrawal(msg.sender,"ETH", _amount);
    }
    
    /**
     * @notice Allows users to withdraw USDC from their account.
     * @param _amount Amount of USDC to withdraw.
     * @dev Uses a reentrancy guard for security.
     */
    function withdrawalUSDC(uint256 _amount) external nonReentrant nonZeroAmount(_amount) {
        uint256 userBalance = balances[msg.sender].usdc; // Read state once to save gas

        // --- Checks ---
        if (_amount > userBalance) revert InsufficientBalance();

        // --- Effects ---
        balances[msg.sender].usdc = userBalance - _amount;
        USDC.transfer(msg.sender, _amount);

        // --- Interaction ---
        emit Withdrawal(msg.sender,"USDC", _amount);
    }
    
    /**
     * @notice Gets the balances of a specific user.
     * @param _user The address of the user.
     * @return The user's balances of ETH and USDC.
     */
    function getBalances(address _user) external view returns (Balances memory) {
        return balances[_user];
    }

    /**
     * @notice Converts an ETH amount to its equivalent USD value.
     * @param _ethAmount Amount of ETH in wei.
     * @return Equivalent USD value with 8 decimal precision.
     */
    function getEthValueInUSD(uint256 _ethAmount) public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // ETH tiene 18 decimales, el precio del oráculo tiene 8.
        // La fórmula correcta es (cantidad * precio) / 10**18 para cancelar los decimales de ETH.
        // El resultado ya queda con los 8 decimales del precio.
        return (uint256(price) * _ethAmount) / 10**18;
    }

    // =================================================================================================================
    //                                                 PRIVATE FUNCTIONS
    // =================================================================================================================

    /**
     * @notice Internal function that performs a safe ETH transfer using the .call method.
     * @param _to The recipient's address.
     * @param _amount The amount to transfer.
     * @dev Reverts with WithdrawalFailed if the transfer fails.
     */
    function _transferEth(address payable _to, uint256 _amount) private {
        (bool success, bytes memory errorData) = _to.call{value: _amount}("");
        if (!success) {
            revert WithdrawalFailed(errorData);
        }
    }

}