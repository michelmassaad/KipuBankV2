// Oracle.sol
// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import {IOracle} from "./IOracle.sol";

// Mock del oráculo
contract Oracle is IOracle {
    // La firma ahora coincide perfectamente
    function latestRoundData() external pure returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        // Devolvemos el precio fijo en la segunda posición ("answer")
        // y 0 para el resto.
        return (0, 3934 * 10**8, 0, 0, 0);
    }
}