// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract DiplomaNFT is ERC721URIStorage, Ownable, AccessControl {
    // Roles
    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");
    bytes32 public constant REVOKER_ROLE = keccak256("REVOKER_ROLE");

    // Variables
    uint256 private _tokenIdCounter;
    
    struct DiplomaData {
        string studentName;
        string academicProgram;
        string institution;
        string graduationDate;
        uint256 issuedAt;
        bool isRevoked;
        string credentialHash; // Hash del documento
    }

    // Mappings
    mapping(uint256 => DiplomaData) private _diplomaData;
    mapping(address => bool) private _approvedIssuers;
    mapping(uint256 => bool) private _revokedTokens;
    
    // Events
    event DiplomaIssued(
        uint256 indexed tokenId,
        address indexed student,
        string studentName,
        uint256 issuedAt
    );
    
    event DiplomaRevoked(
        uint256 indexed tokenId,
        string reason,
        uint256 revokedAt
    );
    
    event DiplomaVerified(
        uint256 indexed tokenId,
        address indexed verifier,
        bool isValid,
        uint256 verifiedAt
    );

    constructor() 
        ERC721("Academic Credential NFT", "ACRED") 
        Ownable()
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // ============ FUNCIONES DE EMISIÓN ============

    function mintDiploma(
        address to,
        string calldata uri,
        string calldata studentName,
        string calldata academicProgram,
        string calldata institution,
        string calldata graduationDate,
        string calldata credentialHash
    ) public onlyRole(ISSUER_ROLE) returns (uint256) {
        require(to != address(0), "Dirección inválida");
        require(bytes(studentName).length > 0, "Nombre requerido");
        
        uint256 tokenId = _tokenIdCounter;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        _diplomaData[tokenId] = DiplomaData({
            studentName: studentName,
            academicProgram: academicProgram,
            institution: institution,
            graduationDate: graduationDate,
            issuedAt: block.timestamp,
            isRevoked: false,
            credentialHash: credentialHash
        });

        _tokenIdCounter += 1;
        
        emit DiplomaIssued(tokenId, to, studentName, block.timestamp);
        return tokenId;
    }

    // ============ FUNCIONES DE VERIFICACIÓN ============

    function getDiplomaData(uint256 tokenId)
        public
        view
        returns (DiplomaData memory)
    {
        require(_ownerOf(tokenId) != address(0), "Token no existe");
        return _diplomaData[tokenId];
    }

    function isDiplomaValid(uint256 tokenId) 
        public 
        view 
        returns (bool) 
    {
        return !_diplomaData[tokenId].isRevoked && _ownerOf(tokenId) != address(0);
    }

    function verifyDiploma(uint256 tokenId)
        public
        returns (bool isValid)
    {
        isValid = isDiplomaValid(tokenId);
        emit DiplomaVerified(tokenId, msg.sender, isValid, block.timestamp);
        return isValid;
    }

    // ============ FUNCIONES DE REVOCACIÓN ============

    function revokeDiploma(uint256 tokenId, string calldata reason)
        public
        onlyRole(REVOKER_ROLE)
    {
        require(_ownerOf(tokenId) != address(0), "Token no existe");
        require(!_diplomaData[tokenId].isRevoked, "Ya está revocado");
        
        _diplomaData[tokenId].isRevoked = true;
        _revokedTokens[tokenId] = true;
        
        emit DiplomaRevoked(tokenId, reason, block.timestamp);
    }

    function reinstateNFT(uint256 tokenId)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(_diplomaData[tokenId].isRevoked, "No está revocado");
        
        _diplomaData[tokenId].isRevoked = false;
        emit DiplomaIssued(
            tokenId,
            _ownerOf(tokenId),
            _diplomaData[tokenId].studentName,
            block.timestamp
        );
    }

    // ============ FUNCIONES DE ADMINISTRACIÓN ============

    function grantIssuerRole(address account) public onlyOwner {
        _grantRole(ISSUER_ROLE, account);
    }

    function grantRevokerRole(address account) public onlyOwner {
        _grantRole(REVOKER_ROLE, account);
    }

    function revokeIssuerRole(address account) public onlyOwner {
        _revokeRole(ISSUER_ROLE, account);
    }

    // ============ FUNCIONES REQUERIDAS ============

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _ownerOf(uint256 tokenId) 
        internal 
        view 
        returns (address) 
    {
        try this.ownerOf(tokenId) returns (address owner) {
            return owner;
        } catch {
            return address(0);
        }
    }
}
