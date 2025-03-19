// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./LLMInterface.sol";

contract ERC721AI is ERC721 {
    // NFT personality core data
    struct Character {
        string prompt;  // AI personality prompt words
    }

    // Chat record structure
    struct ChatRecord {
        string userInput;
        string aiResponse;
        uint256 timestamp;
    }

    // Storage Structure
    mapping(uint256 => Character) private _characters;
    mapping(uint256 => ChatRecord[]) private _chatHistory;

     // Address of the LLM Target contract
    address constant targetContractAddress = address(0xEc6a7Ac166C20a9cDB4617594dC586b9796A8571);

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    // Initialize personality when minting NFT
    function mint(uint256 tokenId, string memory initialPrompt) public {
        _mint(msg.sender, tokenId);
        _characters[tokenId] = Character(initialPrompt);
    }

    // Core chat features
    function chat(uint256 tokenId, string memory input) public returns (string memory) {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        
        // On-chain AI reasoning
        string memory response = _callOnchainAI(input);
        
        // Store complete records
        _chatHistory[tokenId].push(ChatRecord({
            userInput: input,
            aiResponse: response,
            timestamp: block.timestamp
        }));

        return response;
    }

    // Get chat history
    function getChatHistory(uint256 tokenId) public view returns (ChatRecord[] memory) {
        return _chatHistory[tokenId];
    }

    // Get personality prompt words
    function getPrompt(uint256 tokenId) public view returns (string memory) {
        return _characters[tokenId].prompt;
    }

    // On-chain AI calls
    function _callOnchainAI(string memory input) internal returns (string memory){
       ILLMContract llmc = ILLMContract(targetContractAddress);
       string memory result = llmc.llm(input);
       return result;
    }
}