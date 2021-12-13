// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

interface IERC20 {
    function decimals() external view returns (uint8);
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

interface IStaking {
    function stake( uint _amount, address _recipient ) external returns ( bool );
    function claim( address _recipient ) external;
    function unstake( uint _amount, bool _trigger ) external;
}

contract MigrateV2 {

    address public immutable VSD;
    address public immutable sVSDOLD;
    address public immutable stakingOLD;

    address public immutable stakingNEW;

    constructor ( address _VSD, address _sVSDOLD, address _stakingOLD, address _stakingNEW ) {
        require( _VSD != address(0) );
        VSD = _VSD;

        require( _sVSDOLD != address(0) );
        sVSDOLD = _sVSDOLD;

        require( _stakingOLD != address(0) );
        stakingOLD = _stakingOLD;

        require( _stakingNEW != address(0) );
        stakingNEW = _stakingNEW;
    }

    function migrate() external {
        require(block.number >= 520957);
        uint256 amount = IERC20( sVSDOLD ).balanceOf( msg.sender );
        require( amount > 0 );

        IERC20( sVSDOLD ).transferFrom( msg.sender, address( this ), amount );
        IERC20( sVSDOLD ).approve( stakingOLD, amount );
        IStaking( stakingOLD ).unstake( amount, false );

        IERC20( VSD ).approve( stakingNEW, amount );
        IStaking( stakingNEW ).stake( amount, msg.sender );
        IStaking( stakingNEW ).claim( msg.sender );
    }

}
