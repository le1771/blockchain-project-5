pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';


/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Token is ERC721 {

  mapping (uint256 => address) tokenToOwner;
  mapping (address => uint256) ownerToBalance;
  mapping (uint256 => address) tokenToApproved;
  mapping (address => mapping(address => bool)) ownerToOperator;

  modifier hasPermission(address _caller, uint256 _tokenId) {
    require(_caller == tokenToOwner[_tokenId] 
    || getApproved(_tokenId) == _caller
    || isApprovedForAll(tokenToOwner[_tokenId], _caller));
    _;
  }

  function _transferFrom(address _from, address _to, uint256 _tokenId) external payable hasPermission(msg.sender, _tokenId) {

    _transferFromHelper(_from, _to, _tokenId);

  }

  function _transferFromHelper(address _from, address _to, uint256 _tokenId) internal {

    tokenToOwner[_tokenId] = _to;
    ownerToBalance[_from] -= 1;

    emit Transfer(_from, _to, _tokenId);

  }

}
