// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/// @title  QUARTER TURN Season Badge (Soulbound)
/// @notice 웹게임 포털 QUARTER TURN 의 시즌 랭킹 "명예의 전당" 뱃지.
///         시즌 마감 시 오프체인 검증 서버(오라클)가 확정한 상위 랭커에게
///         티어별 뱃지를 배치 민팅한다.
///
///         설계 원칙 (규제-호환):
///           - 양도 불가(soulbound, ERC-5192): 뱃지는 명예의 기록일 뿐
///             거래·환금 가치가 없다. 게임산업법상 환전 금지 조항 비해당.
///           - 민팅 권한은 오너(시즌 확정 오라클)에게만 있다. 검증을 거친
///             시즌 결과만 온체인에 오른다.
contract SeasonBadge is ERC721, Ownable {
    using Strings for uint256;

    /// @notice ERC-5192 (Minimal Soulbound) — 민팅 시 영구 잠금을 알린다.
    event Locked(uint256 tokenId);

    /// @notice 시즌 확정 기록 (감사 추적용)
    event SeasonFinalized(uint256 indexed seasonId, string gameId, uint256 minted);

    struct Badge {
        uint64 seasonId;  // 시즌 번호 (예: 202631 = 2026년 31주차)
        uint8 tier;       // 1=gold, 2=silver, 3=bronze
        uint32 rank;      // 시즌 최종 순위
        string gameId;    // 포털 게임 식별자
    }

    uint256 private _nextId = 1;
    mapping(uint256 tokenId => Badge) public badges;

    /// @dev seasonId => gameId => 확정 여부. 같은 시즌·게임의 이중 민팅을 막는다.
    mapping(uint64 => mapping(string => bool)) public finalized;

    string public baseURI;

    constructor(string memory baseURI_) ERC721("QUARTER TURN Season Badge", "QTSB") Ownable(msg.sender) {
        baseURI = baseURI_;
    }

    // ── 시즌 확정 (오너 = 오프체인 검증 오라클) ──────────────────

    /// @notice 시즌 마감 후 확정된 상위 랭커에게 뱃지를 배치 민팅한다.
    /// @param seasonId  시즌 번호
    /// @param gameId    게임 식별자
    /// @param winners   순위순 수령 주소 (winners[0] = 1위)
    /// @param tiers     winners 와 같은 길이의 티어 배열
    function finalizeSeason(
        uint64 seasonId,
        string calldata gameId,
        address[] calldata winners,
        uint8[] calldata tiers
    ) external onlyOwner {
        require(winners.length > 0 && winners.length == tiers.length, "bad input");
        require(!finalized[seasonId][gameId], "season already finalized");
        finalized[seasonId][gameId] = true;

        for (uint256 i = 0; i < winners.length; i++) {
            require(tiers[i] >= 1 && tiers[i] <= 3, "bad tier");
            uint256 tokenId = _nextId++;
            badges[tokenId] = Badge({
                seasonId: seasonId,
                tier: tiers[i],
                rank: uint32(i + 1),
                gameId: gameId
            });
            _safeMint(winners[i], tokenId);
            emit Locked(tokenId);
        }
        emit SeasonFinalized(seasonId, gameId, winners.length);
    }

    // ── Soulbound: 민팅 외 모든 이전 차단 ────────────────────────

    /// @notice ERC-5192: 모든 뱃지는 영구 잠금 상태다.
    function locked(uint256 tokenId) external view returns (bool) {
        _requireOwned(tokenId);
        return true;
    }

    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = _ownerOf(tokenId);
        require(from == address(0), "SeasonBadge: soulbound, transfer disabled");
        return super._update(to, tokenId, auth);
    }

    // ── 메타데이터 ───────────────────────────────────────────────

    function setBaseURI(string calldata baseURI_) external onlyOwner {
        baseURI = baseURI_;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /// @dev ERC-5192 인터페이스(0xb45a3c0e) 지원을 알린다.
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == 0xb45a3c0e || super.supportsInterface(interfaceId);
    }
}
