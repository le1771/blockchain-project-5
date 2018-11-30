pragma solidity ^0.4.24;

import "./ERC721Token.sol";
import "./stringutils.sol";

contract StarNotary is ERC721Token { 

    using strings for *;

    struct Star { 
        string name;
        string starStory;
        string ra; 
        string dec;
        string mag;
    }

    function stringToBytes32(string memory source) private pure returns (bytes32 result)  {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    mapping(uint256 => Star) public tokenIdToStarInfo; 
    mapping(uint256 => uint256) public starsForSale;
    mapping(bytes32 => bool) public starCoordinateExist;

    function createStar(string _name, string _story, string _ra, string _dec, string _mag, uint256 _tokenId) public { 
        
        require(tokenToOwner[_tokenId] == address(0), "Only unique star can be minted.");

        Star memory newStar = Star(_name, _story, _ra, _dec, _mag);

        string memory starCoordinateString = _ra.toSlice().concat(_dec.toSlice());
        starCoordinateString = starCoordinateString.toSlice().concat(_mag.toSlice());
        require(starCoordinateString.toSlice().len() <= 32, "Required coordinate ra && dec && mag to be less than 32 chars total.");
        
        bytes32 starCoordinate = stringToBytes32(starCoordinateString);

        require(starCoordinateExist[starCoordinate] == false, "Star coorindate already exist.");

        tokenIdToStarInfo[_tokenId] = newStar;
        starCoordinateExist[starCoordinate] = true;

        _mint(msg.sender, _tokenId);
    }

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public { 
        require(this.ownerOf(_tokenId) == msg.sender);

        starsForSale[_tokenId] = _price;
    }

    function buyStar(uint256 _tokenId) public payable { 
        require(starsForSale[_tokenId] > 0);
        
        uint256 starCost = starsForSale[_tokenId];
        address starOwner = this.ownerOf(_tokenId);
        require(msg.value >= starCost);

        _removeTokenFrom(starOwner, _tokenId);
        _addTokenTo(msg.sender, _tokenId);
        
        starOwner.transfer(starCost);

        if(msg.value > starCost) { 
            msg.sender.transfer(msg.value - starCost);
        }
    }

    function checkIfStarExist(string _ra, string _dec, string _mag) public returns (bool) { 
        string memory starCoordinateString = _ra.toSlice().concat(_dec.toSlice());
        starCoordinateString = starCoordinateString.toSlice().concat(_mag.toSlice());
        require(starCoordinateString.toSlice().len() <= 32, "Required coordinate ra && dec && mag to be less than 32 chars total");
        
        bytes32 starCoordinate = stringToBytes32(starCoordinateString);

        return starCoordinateExist[starCoordinate];
    }

    //function mint(address to, uint256 tokenId) internal {
    //    _mint(to, tokenId);
    //}

    // All these function are inherited from open-zeppelin ERC721
    // approve()
    // safeTransferFrom()
    // SetApprovalForAll()
    // getApproved()
    // isApprovedForAll()
    // ownerOf()

}