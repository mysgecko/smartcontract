//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

// For Testing
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MGEKUSDCToken is ERC20{
    constructor(string memory name, string memory symbol, uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }

    function mint(uint256 amount) external {
        require(amount > 0, "FiatToken: mint amount not greater than 0");
        _mint(msg.sender, amount);
    }
}
