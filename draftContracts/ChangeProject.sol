// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/EnumerableSet.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/Initializable.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";

interface IERC20Detailed {
    function decimals() external view returns (uint256);
}

interface Oracle {
    function latestRoundData()
        external
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        );
}

interface ICurveAddressProvider {
    function get_address(uint256 _id) external view returns (address);
}

interface ICurveExchange {
    function get_best_rate(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (address, uint256);

    function exchange(
        address _pool,
        address _from,
        address _to,
        uint256 _amount,
        uint256 _expected
    ) external payable returns (uint256);
}

contract ChangeProject is Initializable, ERC721("", "") {
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    struct RebalanceData {
        address _pool;
        address _from;
        address _to;
        uint256 _dx;
        uint256 _min_dy;
    }

    ICurveAddressProvider constant CURVE_ADDRESS_PROVIDER =
        ICurveAddressProvider(0x0000000022D53366457F9d5E68Ec105046FC4383);
    address constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address ETH_USD_ORACLE = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    EnumerableSet.AddressSet permittedTokens;
    Counters.Counter tokenId;

    address public changeMaker;
    uint256 public goalAmount;
    address public goalToken;
    bool public goalReached;

    constructor() {
        // prevent the implementation contract from being initialized
        goalAmount = uint256(-1);
    }

    // Allow the receipt of ETH
    fallback() external payable {}

    function initialize(
        address[] memory _permittedTokens,
        address _goalToken,
        uint256 _goalAmount
    ) external initializer {
        require(goalAmount == 0);

        for (uint256 idx; idx < _permittedTokens.length; idx++) {
            permittedTokens.add(_permittedTokens[idx]);
        }
        require(permittedTokens.contains(_goalToken));

        goalToken = _goalToken;
        goalAmount = _goalAmount;
    }

    /// @notice Check the status of the project's funding
    /// @dev Iterate through permittedTokens, calculating the sum of all balances
    function isFunded() internal view returns (bool) {
        uint256 precision = 0;
        address token = address(0);
        uint256 total = 0;

        for (uint256 idx; idx < permittedTokens.length(); idx++) {
            token = permittedTokens.at(idx);
            if (token == ETH_ADDRESS) {
                (, int256 eth_to_usd, , , ) = Oracle(ETH_USD_ORACLE)
                .latestRoundData();
                total += address(this).balance * uint256(eth_to_usd) * 10**10;
            } else {
                precision = (18 - IERC20Detailed(token).decimals());
                total += IERC20(token).balanceOf(address(this)) * 10**precision;
            }
        }

        return
            total / 10**(18 - IERC20Detailed(goalToken).decimals()) >=
            goalAmount;
    }

    modifier preventOverFunding() {
        require(!goalReached);
        _;
    }

    /// @notice Fund the change project in exchange for an NFT
    /// @param _token a permitted token in the _permittedTokens set
    /// @param _amount an amount to transfer from the msg.sender to this contract
    function fund(address _token, uint256 _amount)
        external
        payable
        preventOverFunding
    {
        // checks
        require(permittedTokens.contains(_token)); // dev: token disallowed

        // effects
        if (ERC721.balanceOf(msg.sender) == 0) {
            _safeMint(msg.sender, tokenId.current());
            tokenId.increment();
        }

        // interactions
        if (_token == ETH_ADDRESS) {
            require(msg.value == _amount);
        } else {
            IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount); // dev: bad response
        }

        if (isFunded()) {
            goalReached = true;
        }
    }

    function getRebalanceData()
        external
        view
        returns (RebalanceData[] memory rebalanceData)
    {
        uint256 size = permittedTokens.length();
        rebalanceData = new RebalanceData[](size);

        address exchangeAddr = CURVE_ADDRESS_PROVIDER.get_address(2);
        ICurveExchange curveExchange = ICurveExchange(exchangeAddr);

        address to = goalToken;
        address self = address(this);

        address pool = address(0);
        address from = address(0);
        uint256 amount = 0;
        uint256 min_dy = 0;
        uint256 pos = 0;

        for (uint256 idx; idx < size; idx++) {
            from = permittedTokens.at(idx);
            if (from != ETH_ADDRESS) {
                amount = IERC20(from).balanceOf(self);
            } else {
                amount = address(this).balance;
            }

            if (amount == 0) continue;
            (pool, min_dy) = curveExchange.get_best_rate(from, to, amount);
            rebalanceData[pos] = RebalanceData(pool, from, to, amount, min_dy);
            pos++;
        }
    }

    function rebalance(RebalanceData[] calldata _rebalanceData) external {
        address exchangeAddr = CURVE_ADDRESS_PROVIDER.get_address(2);
        ICurveExchange curveExchange = ICurveExchange(exchangeAddr);

        RebalanceData memory rebalanceData;

        for (uint256 idx; idx < _rebalanceData.length; idx++) {
            rebalanceData = _rebalanceData[idx];
            if (rebalanceData._from != ETH_ADDRESS) {
                IERC20(rebalanceData._from).safeApprove(
                    exchangeAddr,
                    rebalanceData._dx
                );
                curveExchange.exchange(
                    rebalanceData._pool,
                    rebalanceData._from,
                    rebalanceData._to,
                    rebalanceData._dx,
                    rebalanceData._min_dy
                );
            } else {
                /// handle ETH being sent
                curveExchange.exchange{value: rebalanceData._dx}(
                    rebalanceData._pool,
                    rebalanceData._from,
                    rebalanceData._to,
                    rebalanceData._dx,
                    rebalanceData._min_dy
                );
            }
        }
    }
}
