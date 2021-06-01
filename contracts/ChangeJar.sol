// // SPDX-License-Identifier: GPL-3.0
// pragma solidity ^0.8.0;
//
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// // import { IYearnVault } from "./IYearnVaults.sol";
// import "../interfaces/IVaultAdapter.sol";
// import "../interfaces/ICurvePool.sol";
//
//
//
// contract ChangeJar is ERC20 {
//
//     address constant DAI;
//     address constant IVaultAdapter;
//     address constant DAO;
//     address constant USDC;
//     address constant pool;
//     address constant alUSD;
//     mapping (address => uint256) public investments;
//
//     modifier OnlyDAO() override {
//         DAO = this;
//         _;
//     }
//
//     event Invested(address indexed investor, uint amount);
//
//     function deposit(uint amount) external {
//
//         require(IERC20(DAI).approval(msg.sender, address(this)) >= amount, "Not Enough to Approve");
//         IERC20(DAI).transferFrom(msg.sender, address(this), amount);
//
//         investments[msg.sender] += amount;
//         _mint(msg.sender, amount);
//
//         emit Invested(msg.sender, amount);
//
//         IERC20(DAI).approve(msg.sender, address(this), amount);
//         // IALCXVAULT(ALCXVAULT).deposit(amount);
//         // will add custom interface cloning Alchemix Vault Interface
//         // sol 0.8.0
//     }
//
//     //tuition cost has been determined
//     //Be careful with decimals
//     function dispurseFunds(address recipient, uint256 amount) public {
//         require(msg.sender == DAO);
//
//         //changing our Alchemix DAI (multiply by 2) => alUSD
//         //deposit goes to DAO before recipient
//         IVaultAdapter(DAI).deposit(address(this), amount * 2);
//         IVaultAdapter(alUSD).withdraw(address(this), amount);
//         ICurvePool(ALCHMXExchange).exchange(1, 0, IERC20(alUSD).balanceOf(address(this)), amount);
//         // need to figure out the index for alUSD, USDC and DAI
//          // DAI is 1, alUSD is 0
//
//         // IERC20(USDC).transfer(receipient, IERC20(USDC).balanceOf(address(this)));
//         IERC20(USDC).transfer(receipient, amount);
//         if ( IERC20(USDC).balanceOf(self) > 0 ) {
//             ICurvePool(pool).exchange(1, 0, IERC20(USDC).balanceOf(self), 0);
//             IERC20(DAI).approve(IVaultAdapter, IERC20(DAI).balanceOf(self));
//             IVaultAdapter(DAI).deposit(IERC20(DAI).balanceOf(self));
//         // need token index for USDC in Curve Swaps
//         }
//     }
//
//     //prevent transferring CHANGE Token to non-investor wallet
//     function _beforeTokenTransfer(address , address , uint256 amount) internal virtual {
//         if (to != address(0)) {
//             revert("Transfer not allowed");
//         }
//     }
//
//     //Student Applicant is Student
// //Investor is ChangeMaker
// }
