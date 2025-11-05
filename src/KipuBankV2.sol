// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

 // --- Imports ---
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title KipuBankV2
 * @author Michel Massaad
 * @notice A decentralized bank that supports ETH and USDC deposits and withdrawals.
 * @dev This contract implements a USD-based deposit cap for ETH using Chainlink Price Feeds.
 * It is owned by the deployer and follows best practices for security and documentation.
 */
contract KipuBankV2 is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    // =================================================================================================================
    //                                                       STRUCTS
    // =================================================================================================================
    /**
     * @notice A struct to store the balances of each user for supported assets.
     * @param eth The user's balance of ETH in wei.
     * @param usdc The user's balance of USDC in its smallest unit (6 decimals).
     */
    struct Balances {
        uint256 eth;
        uint256 usdc;
    }

    // =================================================================================================================
    //                                                      VARIABLES
    // =================================================================================================================
    /// @notice The interface to interact with the Chainlink ETH/USD price feed.
    AggregatorV3Interface public immutable priceFeed;
    /// @notice The ERC20 token contract for USDC.
    IERC20 public immutable USDC;
    /// @notice The global deposit cap for ETH, denominated in USD with 8 decimals.
    uint256 public immutable BANK_CAP_USD;
    /// @notice Total amount of ETH currently deposited in the contract (in wei).
    uint256 public totalEthDeposited;

    // --- Mappings ---
    /// @notice Mapping of each user’s address to their balances.
    mapping (address => Balances) private balances;

    // =================================================================================================================
    //                                                       EVENTS
    // =================================================================================================================

    /**
     * @notice Emitted when a user successfully deposits ETH or USDC.
     * @param user Address of the depositor.
     * @param token Type of asset deposited ("USDC" or "ETH").
     * @param amount Amount deposited.
     */
    event Deposit(address indexed user, address indexed token, uint256 amount);

    /**
     * @notice Emitted when a user successfully withdraws funds.
     * @param user The address of the withdrawer.
     * @param token Type of asset withdrawn ("USDC" or "ETH").
     * @param amount The amount withdrawn in the token's smallest unit.
     */
    event Withdrawal(address indexed user, address indexed token, uint256 amount);

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
    error WithdrawalFailed();
    
    /// @notice Error for reentrancy guard, thrown when a reentrant call is detected.
    error ReentrantCall();

    /// @notice Thrown when a provided address is invalid (zero address).
    error InvalidAddress();

    // =================================================================================================================
    //                                                      MODIFIERS
    // =================================================================================================================

    /**
     * @notice Ensures the provided amount is greater than zero.
     * @param _amount The amount to check.
     */
    modifier nonZeroAmount(uint256 _amount) {
        if (_amount == 0) revert InvalidAmount();
        _;
    }

    /**
     * @notice Checks if a new ETH deposit would exceed the bank's total USD cap.
     */
    modifier checkBankCap() {
        uint256 futureTotalEth = totalEthDeposited + msg.value;
        uint256 futureTotalEthUSD = getEthValueInUSD(futureTotalEth);
        if (futureTotalEthUSD > BANK_CAP_USD) revert BankCapExceeded();
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
    function depositEth() external payable 
    nonZeroAmount(msg.value) 
    checkBankCap {
        // --- Checks ---
        // --- Effects ---
        uint256 currentTotalEth = totalEthDeposited;
        uint256 currentUserEth = balances[msg.sender].eth;

        unchecked {
            totalEthDeposited = currentTotalEth + msg.value;
            balances[msg.sender].eth = currentUserEth + msg.value;
        }
        // --- Interactions ---
        emit Deposit(msg.sender,address(0), msg.value);
    }

    /**
     * @notice Deposits USDC tokens into the user's balance.
     * @dev The user must call `approve` on the USDC contract to authorize this contract first.
     * @param _amount The amount of USDC (in its smallest unit) to deposit.
     */
    function depositUSDC(uint256 _amount) external nonZeroAmount(_amount) {
        uint256 currentUserUsdc = balances[msg.sender].usdc;
        
        // --- Effects ---
        unchecked {
            balances[msg.sender].usdc = currentUserUsdc + _amount;
        }
        // --- Interactions ---
        USDC.safeTransferFrom(msg.sender, address(this), _amount);
        emit Deposit(msg.sender, address(USDC), _amount);
    }

    /**
     * @notice Withdraws ETH from the user's balance to their address.
     * @dev Follows the Checks-Effects-Interactions pattern to prevent reentrancy.
     * @param _amount The amount of ETH (in wei) to withdraw.
     */
    function withdrawEth(uint256 _amount) external 
    nonReentrant 
    nonZeroAmount(_amount) 
    {
        uint256 currentTotalEth = totalEthDeposited;
        uint256 currentUserEth = balances[msg.sender].eth;

        // --- Checks ---
        if (_amount > currentUserEth) revert InsufficientBalance();

        // --- Effects ---
        unchecked {
            balances[msg.sender].eth = currentUserEth - _amount;
            totalEthDeposited = currentTotalEth - _amount;
        }
        
        // --- Interaction ---
        _transferEth(payable(msg.sender), _amount);
        emit Withdrawal(msg.sender,address(0), _amount);
    }
    
    /**
     * @notice Allows users to withdraw USDC from their account.
     * @param _amount Amount of USDC to withdraw.
     * @dev Uses a reentrancy guard for security.
     */
    function withdrawalUSDC(uint256 _amount) external 
    nonReentrant 
    nonZeroAmount(_amount) 
    {
        uint256 currentUserUsdc = balances[msg.sender].usdc;
       // --- Checks ---
        if (_amount > currentUserUsdc) revert InsufficientBalance();
        
        // --- Effects ---
        unchecked {
            balances[msg.sender].usdc = currentUserUsdc - _amount;
        }
       
        // --- Interaction ---
        USDC.safeTransfer(msg.sender, _amount);
        emit Withdrawal(msg.sender, address(USDC) , _amount);
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
        (bool success,) = _to.call{value: _amount}("");
        if (!success) {
            revert WithdrawalFailed();
        }
    }

}