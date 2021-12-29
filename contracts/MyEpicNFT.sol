// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import these helper functions
import {Base64} from "./libraries/Base64.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract MyEpicNFT is ERC721URIStorage {
    // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string svgPartOne =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string svgPartTwo =
        "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // Three arrays, each with their own theme of random words.
    string[] firstWords = [
        "White",
        "Yellow",
        "Blue",
        "Red",
        "Green",
        "Black",
        "Brown",
        "Azure",
        "Ivory",
        "Teal",
        "Silver",
        "Purple",
        "Navy blue",
        "Pea green",
        "Gray",
        "Orange",
        "Maroon",
        "Charcoal",
        "Aquamarine",
        "Coral"
    ];
    string[] secondWords = [
        "Excitement",
        "Optimism",
        "Lust",
        "Excitement",
        "Love",
        "Hatred",
        "Shame",
        "Love",
        "Remorse",
        "Surprise",
        "Love",
        "Surprise",
        "Horror",
        "Horror",
        "Shock",
        "Bliss",
        "Humility",
        "Torment",
        "Pain",
        "Sadness"
    ];
    string[] thirdWords = [
        "Sloth",
        "Marmoset",
        "Walrus",
        "Camel",
        "Hyena",
        "Jackal",
        "Lion",
        "Gorilla",
        "Mountain goat",
        "Lynx",
        "Sheep",
        "Goat",
        "Fox",
        "Alpaca",
        "Gazelle",
        "Aardvark",
        "Iguana",
        "Tiger",
        "Mandrill",
        "Fox"
    ];

    // Random colors 
    string[] colors = ["red", "#08C2A8", "black", "yellow", "blue", "green"];

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    // We need to pass the name of our NFTs token and its symbol.
    // this first is the name of the NFT collection on OpenSea
    // the next is the name of each unique NFT - ex: punk 001
    constructor() ERC721("TheThreeWordNFT", "TTW") {
        console.log("This is my NFT contract. Woah!");
    }

    // Function to randomly pick a word from each array.
    function pickRandomFirstWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // I seed the random generator
        uint256 rand = random(
            string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId)))
        );
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId)))
        );
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId)))
        );
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    // Pick a random color
    function pickRandomColor(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("COLOR", Strings.toString(tokenId)))
        );
        rand = rand % colors.length;
        return colors[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    // A function our user will hit to get their NFT.
    function makeAnEpicNFT() public {
        // Get the current tokenId, this starts at 0.
        // tokenIds is automatically set to 0 when we declare "private _tokenIds"
        // when makeAnEpicNFT() is first called, netItemId is 0; when next called, it's = 1; etc.
        uint256 newItemId = _tokenIds.current();

        // We go and randomly grab one word from each of the three arrays.
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory randomColor = pickRandomColor(newItemId);
        string memory combinedWord = string(
            abi.encodePacked(first, second, third)
        );

        // I concatenate it all together, and then close the <text> and <svg> tags.
        string memory finalSvg = string(
            abi.encodePacked(
                svgPartOne,
                randomColor,
                svgPartTwo,
                combinedWord,
                "</text></svg>"
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        // Actually mint the NFT to the sender using msg.sender.
        // Mint the NFT with id newItemId to the user with address msg.sender
        _safeMint(msg.sender, newItemId);

        // Set the NFTs data.
        // tokenURI is where the actual NFT data lives. And it usually links to a JSON file called the metadata
        // all NFTs utilize this metadata format
        // set json data here and get link: https://jsonkeeper.com/

        _setTokenURI(newItemId, finalTokenUri);
        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );

        // Increment the counter for when the next NFT is minted.
        _tokenIds.increment();

        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}
