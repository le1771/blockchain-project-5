pragma solidity ^0.4.24;

import './ERC721Token.sol';

contract StarNotary is ERC721Token { 

    struct Star { 
        string name;
        string starStory;
        string ra; 
        string dec;
        string mag;
    }

    mapping(uint256 => Star) public tokenIdToStarInfo; 
    mapping(uint256 => uint256) public starsForSale;
    mapping(bytes32 => bool) public starCoordinateExist;

    function concatStarCoordinate(bytes _raBytes, bytes _decBytes, bytes _magBytes) internal pure returns (bytes32) {
        bytes memory tempValueBytes;
        bytes32 returnValueBytes32;
        uint offset = 0;
        uint i;
        uint j;
        for(i=0; i<_raBytes.length; i++) {
            tempValueBytes[j++] = _raBytes[i];
        }
        for(i=0; i<_decBytes.length; i++) {
            tempValueBytes[j++] = _decBytes[i];
        }
        for(i=0; i<_magBytes.length; i++) {
            tempValueBytes[j++] = _decBytes[i];
        }

        for (i = 0; i < 32; i++) {
            returnValueBytes32 |= bytes32(tempValueBytes[offset + i] & 0xFF) >> (i * 8);
        }

        return returnValueBytes32;
    }

    function createStar(string _name, string _story, string _ra, string _dec, string _mag, uint256 _tokenId) public { 
        Star memory newStar = Star(_name, _story, _ra, _dec, _mag);
        bytes memory _raBytes = bytes(_ra);
        bytes memory _decBytes = bytes(_dec);
        bytes memory _magBytes = bytes(_mag);


        //Check star coordinate must come in format: "ra_032.155", "dec_121.874", "mag_245.978"
        require(_raBytes.length + _decBytes.length + _magBytes.length == 32,"Required coordinate format: ra_###.###, dec_###.###, mag_###.###");

        //Concatenate the coordinate for look up & check Uniqless by coordinates 
        //bytes32 starCoordinate = concatStarCoordinate(_raBytes, _decBytes, _magBytes);

        //require(starCoordinateExist[starCoordinate] == false,"Star coorindate already exist.");

        tokenIdToStarInfo[_tokenId] = newStar;
        //starCoordinateExist[starCoordinate] = true;

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
        bytes memory _raBytes = bytes(_ra);
        bytes memory _decBytes = bytes(_dec);
        bytes memory _magBytes = bytes(_mag);

        //Check star coordinate must come in format: "ra_032.155", "dec_121.874", "mag_245.978"
        require(_raBytes.length + _decBytes.length + _magBytes.length == 32,"Required coordinate format: ra_###.###, dec_###.###, mag_###.###");

        bytes32 starCoordinate = concatStarCoordinate(_raBytes, _decBytes, _magBytes);

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

    function starsForSale() public {
    }

    /*function tokenIdToStarInfo(uint256 tokenId) public returns(string) {
        require(_exists(tokenId), "Token does not exist");
        return tokenIdToStarInfo[tokenId];
    }*/
}