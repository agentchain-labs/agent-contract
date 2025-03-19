// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./LLMInterface.sol";

contract ERC1155AI is ERC1155 {
    // Data Structure
    struct Agent {
        string prompt; // Personality Tips
        mapping(uint256 => ChatRecord) history; // Chat History Mapping
        uint256 historySize; // Number of chat records
        address creator; // Creator Address
    }

    struct ChatRecord {
        string input; // User Input
        string response; // AI Response
        uint256 timestamp; // Timestamp
    }

    mapping(uint256 => Agent) private _agents; // Mapping of token ID to Agent
    address constant targetContractAddress = address(0xEc6a7Ac166C20a9cDB4617594dC586b9796A8571); // LLM target contract address

    constructor() ERC1155("") {}

    // mint AI Agent
    function mint(
        uint256 tokenId,
        string memory initialPrompt,
        uint256 amount
    ) public {
        require(
            _agents[tokenId].creator == address(0),
            "TokenId already exists"
        );

        _mint(msg.sender, tokenId, amount, "");

        // Initialize the fields of the Agent structure separately
        _agents[tokenId].prompt = initialPrompt;
        _agents[tokenId].historySize = 0;
        _agents[tokenId].creator = msg.sender;
    }

    // get Chat Record
    function getChatRecord(uint256 tokenId)
        public
        view
        returns (ChatRecord[] memory)
    {
        require(
            _agents[tokenId].creator != address(0),
            "TokenId does not exist"
        );
        Agent storage agent = _agents[tokenId];
        ChatRecord[] memory records = new ChatRecord[](agent.historySize);
        for (uint256 i = 0; i < agent.historySize; i++) {
            records[i] = agent.history[i + 1];
        }
        return records;
    }

    // get Prompt
    function getPrompt(uint256 tokenId) public view returns (string memory) {
        return _agents[tokenId].prompt;
    }

    
    // chat
    function chat(uint256 tokenId, string memory input)
        public
        returns (string memory)
    {
        require(balanceOf(msg.sender, tokenId) > 0, "Not owner");

        // call chain AI
        string memory response = _callAI(input);

        
        _addChatRecord(tokenId, input, response);

        return response;
    }

    // call chain AI
    function _callAI(string memory userInput) internal returns (string memory) {
        ILLMContract llmc = ILLMContract(targetContractAddress);
        string memory response = llmc.llm(userInput);
        return response;
    }

    // add chat record
    function _addChatRecord(
        uint256 tokenId,
        string memory input,
        string memory response
    ) internal {
        require(
            _agents[tokenId].creator != address(0),
            "TokenId does not exist"
        );
        _agents[tokenId].historySize++;
        uint256 recordId = _agents[tokenId].historySize;
        _agents[tokenId].history[recordId] = ChatRecord({
            input: input,
            response: response,
            timestamp: block.timestamp
        });
    }

    // override URI
    function uri(uint256 tokenId) public view override returns (string memory) {
        return super.uri(tokenId);
    }
}
