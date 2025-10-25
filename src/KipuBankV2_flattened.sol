// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

// File: src/KipuBankV2.sol


pragma solidity ^0.8.0;

/**
 * @title KipuBank
 * @author Michel Massaad
 * @notice A simple banking contract where users can deposit and withdraw ETH.
 * @dev Implements transaction limits, a global deposit cap, custom errors, and follows security best practices.
 */




contract KipuBankV2 is Ownable {

    // =================================================================================================================
    //                                                   STATE VARIABLES
    // =================================================================================================================

    // --- Immutable & Constant Variables ---
    /// @notice The per-transaction withdrawal limit.
    // uint256 public immutable WITHDRAWAL_LIMIT;
    /// @notice The global deposit cap for the entire bank.
    uint256 public immutable BANK_CAP_USD;

    AggregatorV3Interface public priceFeed;
    IERC20 public immutable USDC;

    // --- Storage Variables ---
    /// @notice The total amount of ETH currently deposited in the contract.
    uint256 public totalEthDeposited;
    /// @notice Reentrancy guard flag.
    bool private locked;

    // La "ficha" que guarda los saldos de cada usuario
    struct Balances {
        uint256 eth;
        uint256 usdc;
    }
    // --- Mappings ---
    /// @notice Mapping from address to user balance.
    // Un mapeo que asocia la dirección de cada usuario con su "ficha" de saldos.
    mapping (address => Balances) public balances;


    // =================================================================================================================
    //                                                       EVENTS
    // =================================================================================================================

    // Unificamos los eventos para una mejor observabilidad. address(0) será para ETH.
    event Deposit(address indexed user, string indexed usdcOrEth, uint256 amount);
    event Withdrawal(address indexed user, string indexed usdcOrEth, uint256 amount);

    // =================================================================================================================
    //                                                      ERRORS
    // =================================================================================================================

    /// @notice Error thrown when the total deposits would exceed the bank's global cap.
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

    error InvalidAddress();


    // =================================================================================================================
    //                                                      MODIFIERS
    // =================================================================================================================

    /// @notice Prevents reentrancy attacks by locking the contract during a function's execution.
    modifier nonReentrant() {
        if (locked) revert ReentrantCall();
        locked = true;
        _;
        locked = false;
    }

    /// @notice Checks if the provided amount is greater than zero.
    /// @param _amount The amount to check.
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
        address _priceFeedAddress, // 1. Recibe la DIRECCIÓN del oráculo chainlink// 0x694AA1769357215DE4FAC081bf1f309aDC325306
        address _usdcTokenAddress, // 2. Recibe la DIRECCIÓN del token USDC// 0x93f8dddd876c7dBE3323723500e83E202A7C96CC
        uint256 _bankCapUSD        // 3. Recibe el LÍMITE como un número
    ) Ownable(msg.sender) { // 4. Asigna al desplegador como el dueño
        
        // NUEVO: Verificación para evitar desplegar con direcciones vacías.
        if (_priceFeedAddress == address(0) || _usdcTokenAddress == address(0)) {
            revert InvalidAddress();
        }

        // 5. Convierte la dirección del oráculo en un "control remoto" (interfaz)
        //    y lo guarda en la variable 'priceFeed' para usarlo después.
        priceFeed = AggregatorV3Interface(_priceFeedAddress);

        // 6. Hace lo mismo con la dirección de USDC, creando un "control remoto"
        //    para el token y guardándolo en 'USDC_TOKEN'.
        USDC = IERC20(_usdcTokenAddress);

        // 7. Toma el límite (ej. 10000) y lo multiplica por 10**8 para ajustarlo
        //    a los 8 decimales que usa el oráculo, guardándolo en 'BANK_CAP_USD'.
        BANK_CAP_USD = _bankCapUSD * (10**8);
    }

    // =================================================================================================================
    //                                                 EXTERNAL FUNCTIONS
    // =================================================================================================================

    /**
     * @notice Deposits ETH into the user's balance.
     * @dev Reverts if the amount is zero or if the deposit would exceed the global bank cap.
     * @dev Follows the checks-effects-interactions pattern.
     */
    function depositEth() external payable nonZeroAmount(msg.value) {
        // --- Checks ---//OJJOOOOO ARREGLAR LO DE BANK_CAP ACA SON ETH PERO NO PUEDO COMPARAR ETH CON USD
        // 1. Calcula cuál sería el valor total en USD *después* del depósito.
        uint256 futureTotalEthValueUSD = getEthValueInUSD(totalEthDeposited + msg.value);
        
        // 2. Compara ese valor futuro con el límite.
        if (futureTotalEthValueUSD > BANK_CAP_USD) {
            revert BankCapExceeded();
        }
        // --- Effects ---
        // Using unchecked as the check above prevents overflow, saving gas.
        unchecked {
            totalEthDeposited += msg.value;
        }
        balances[msg.sender].eth += msg.value;

        // --- Interactions (none in this function) ---

        emit Deposit(msg.sender,"ETH", msg.value);
    }

    function depositUSDC(uint256 _amount) external nonZeroAmount(_amount) {
        // --- Effects ---
        balances[msg.sender].usdc += _amount;
        // Transfiere los tokens desde el usuario hacia este contrato.
        USDC.transferFrom(msg.sender, address(this), _amount);

        // --- Interactions (none in this function) ---
        emit Deposit(msg.sender,"USDC", _amount);
    }

    /**
     * @notice Withdraws ETH from the user's balance.
     * @param _amount The amount to withdraw in wei.
     * @dev Reverts if the amount is zero, exceeds the withdrawal limit, or if the user has insufficient balance.
     * @dev Follows the checks-effects-interactions pattern.
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
     * @notice Converts an amount of ETH (in wei) to its equivalent value in USD.
     * @param _ethAmount The amount of ETH in wei (1e18).
     * @return The value in USD, adjusted to 8 decimals.
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
     */
    function _transferEth(address payable _to, uint256 _amount) private {
        (bool success, bytes memory errorData) = _to.call{value: _amount}("");
        if (!success) {
            revert WithdrawalFailed(errorData);
        }
    }

}