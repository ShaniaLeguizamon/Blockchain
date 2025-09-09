// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract DiplomaNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter; // en vez de Counters

    struct DiplomaData {
        string studentName;
        string academicProgram;
        string graduationDate;
        bool isRevoked;
    }

    mapping(uint256 => DiplomaData) private _diplomaData;

    event DiplomaRevoked(uint256 indexed tokenId);

    constructor()
    ERC721("DiplomaNFT", "DPLM")
    Ownable()
    {}

    function mintDiploma(
        address to,
        string calldata uri,
        string calldata studentName,
        string calldata academicProgram,
        string calldata graduationDate
    ) public onlyOwner {
        uint256 tokenId = _tokenIdCounter;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        _diplomaData[tokenId] = DiplomaData({
            studentName: studentName,
            academicProgram: academicProgram,
            graduationDate: graduationDate,
            isRevoked: false
        });

        _tokenIdCounter += 1; // ahora incrementamos manualmente
    }

    function getDiplomaData(uint256 tokenId)
        public
        view
        returns (string memory, string memory, string memory, bool)
    {
        DiplomaData storage data = _diplomaData[tokenId];
        return (
            data.studentName,
            data.academicProgram,
            data.graduationDate,
            data.isRevoked
        );
    }

    function isDiplomaValid(uint256 tokenId) public view returns (bool) {
        return !_diplomaData[tokenId].isRevoked;
    }

    function revokeDiploma(uint256 tokenId) public onlyOwner {
        require(!_diplomaData[tokenId].isRevoked, "El diploma ya ha sido revocado.");
        _diplomaData[tokenId].isRevoked = true;
        emit DiplomaRevoked(tokenId);
    }
}
