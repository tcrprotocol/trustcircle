/*
 * ooooooooooooooooooooooooooooooooooooooooooooooooo
 * ────────╔════╗──────╔╗─╔═══╗─────╔╗──────────────
 * ────────║╔╗╔╗║─────╔╝╚╗║╔═╗║─────║║──────────────
 * ────────╚╝║║╠╩╦╗╔╦═╩╗╔╝║║─╚╬╦═╦══╣║╔══╗──────────
 * ──────────║║║╔╣║║║══╣║─║║─╔╬╣╔╣╔═╣║║║═╣──────────
 * ──────────║║║║║╚╝╠══║╚╗║╚═╝║║║║╚═╣╚╣║═╣──────────
 * ──────────╚╝╚╝╚══╩══╩═╝╚═══╩╩╝╚══╩═╩══╝──────────
 * ooooooooooooooooooooooooooooooooooooooooooooooooo
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DefaultTrustCircle is Context, IERC20, Ownable {

    using SafeMath for uint256;
    address constant _pool = 0x9BFaF8A14600422Ef8Fdb9304115eC85AddBf156;

    struct trusted {
        address _trusted;
        uint256 _amount;
    }

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => int8) private  _level;
    mapping(int8 => uint256) private _levelCounts;
    mapping(address => trusted[]) private upgrade;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

     /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 1000, "amount to small, maths will break");

        // subtract send balanced
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev withdraw the Pool to burn.
     * 
     * Requirements:
     * - `amount` tcr amount. 
     * - onlyOwner.
     */
    function withdrawPool(uint256 amount) public onlyOwner {
        require(_balances[_pool] != 0, "Insufficient founds");
        _burn(address(0), amount);
    }

    /**
     * @dev Calculate the level.
     * 
     * Requirements:
     * 
     * - `_t` cannot be the zero address.
     */
    function getLevel() public view returns (int8) {
        return _level[msg.sender];
    }

    /**
     * @dev PoolAddress.
     * 
     * returns type -> address:
     * 
     */
    function getTrustPool() public pure returns(address){
        return _pool;
    }

    /**
     * @dev Calculate the `TCR` amount required for different level upgrades.
     * 
     * to updrade 1  =>  100
     * to upgrade 2  =>  200
     * to upgrade 3  =>  300
     * to upgrade 4  =>  400
     * 
     * `the max level = 4`
     */
    function _calculateFees(int8 _l) internal pure returns (uint256) {
        if (_l < 1) {
            return 100;
        } else if (_l < 2) {
            return 200;
        } else if (_l < 3) {
            return 300;
        } else {
            return 400;
        }
    }

    /**
     * @dev Upgrade based on trust between addresses.
     * 
     * notice:
     * The trustor's level must not exceed the maximum level of 4.
     * Trustor's level must be lower than the trustee's level.
     * The trustor needs to spend the corresponding amount of trust equity to the trustee.
     * 
     * Please refer to `_calculateFees()` for specific trust level upgrade benefits.
     * 
     * Requirements:
     * 
     * - `_trustedAccount` cannot be the zero address.
     * - `_amount` uint256 
     */
    function upgradeLevel(address _trustedAccount, uint256 _amount) public {
        require(_level[_msgSender()] < 4, "max level");
        require(_level[_trustedAccount] > _level[_msgSender()], "trusted level < trust");
        require(_amount >= _calculateFees(_level[_msgSender()]).mul(10**18), "Insufficient funds to upgrade");
        _transfer(_msgSender(), _trustedAccount, _amount);
        if(_level[_msgSender()] != 0) {
            _levelCounts[_level[_msgSender()]] = _levelCounts[_level[_msgSender()]].sub(1);
        }
        upgrade[_trustedAccount].push(trusted(msg.sender,_amount));
        _level[_msgSender()] = _level[_msgSender()] + 1;
        _levelCounts[_level[_msgSender()]] = _levelCounts[_level[_msgSender()]].add(1);
        emit Transfer(_msgSender(), _trustedAccount, _amount);
    }

    /**
     * @dev Upgrade based on trust by pool.
     * 
     * notice:
     * The trustor's level must not exceed the maximum level of 4.
     * The trustor needs to spend the corresponding amount of trust equity to the pool.
     * 
     * Please refer to `_calculateFees()` for specific trust level upgrade benefits.
     * 
     * Requirements:
     * 
     * - `_amount` uint256  Upgrade cost.
     */
    function upgradeByPool(uint256 _amount) public {
        require(_level[_msgSender()] < 4, "max level");
        require(_amount >= _calculateFees(_level[_msgSender()]).mul(10**18), "Insufficient funds to upgrade");
        _transfer(_msgSender(), _pool, _amount);
        if(_level[_msgSender()] != 0) {
            _levelCounts[_level[_msgSender()]] = _levelCounts[_level[_msgSender()]].sub(1);
        }
        _level[_msgSender()] += 1;
        _levelCounts[_level[_msgSender()]] = _levelCounts[_level[_msgSender()]].add(1);
        emit Transfer(_msgSender(), _pool, _amount);
    }

    /**
     * @dev get trust info by struct.
     * 
     * returns []
     * memory
     */
    function trustInfo() public view returns (trusted[] memory) {
        return upgrade[msg.sender];
    }

}

