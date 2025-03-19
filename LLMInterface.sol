// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface ILLMContract {
    function llm(string memory inputText) external returns (string memory);
}
