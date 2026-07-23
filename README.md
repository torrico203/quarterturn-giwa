# QUARTER TURN × GIWA — Season Badge Contracts

[QUARTER TURN](https://fakedev.pages.dev) 웹게임 포털의 **시즌 랭킹 명예의 전당**을 GIWA 체인에 올리는 컨트랙트입니다. GASOK 2026 (Track 05. Mass Adoption) 지원 프로젝트.

## 개념

시즌(주간/월간) 리더보드가 마감되면, 오프체인 검증 서버(오라클)가 확정한 상위 랭커에게
티어별 뱃지를 배치 민팅합니다. 뱃지는 **양도 불가(soulbound, ERC-5192) + 무가치** —
명예의 영구 기록일 뿐 거래·환금 가치가 없습니다.

```
게임 플레이 → 점수 제출 → 서버 검증·집계 (오프체인)
                              ↓ 시즌 마감
                    finalizeSeason() — 확정 결과만 온체인 커밋 (배치 민팅)
```

설계 원칙:
- 게임 재화는 오프체인 유지 — 토큰화하지 않음
- 랭킹 보상으로 유가 토큰을 지급하지 않음 (환금 루프 원천 배제)
- 민팅 권한은 검증 오라클(오너)에게만 — 검증을 거친 결과만 체인에 오름

## 배포 (GIWA Sepolia Testnet)

| | |
|---|---|
| Contract | `SeasonBadge` (ERC-721 + ERC-5192 soulbound) |
| Address | [`0x9BCaB4D9d77aeF28E31399E95F06E3d6Ed3d8c04`](https://sepolia-explorer.giwa.io/address/0x9BCaB4D9d77aeF28E31399E95F06E3d6Ed3d8c04) |
| Network | GIWA Sepolia — Chain ID 91342 |

## 개발

```bash
npm install
npx hardhat compile
cp .env.example .env   # PRIVATE_KEY 에 배포 키(테스트넷 버너) 설정
npm run deploy:giwa-sepolia
```

## 라이선스

MIT
