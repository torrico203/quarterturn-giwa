// SeasonBadge 배포 — GIWA Sepolia
//   npx hardhat run scripts/deploy.js --network giwaSepolia
const hre = require('hardhat');

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log('deployer :', deployer.address);
  console.log('balance  :', hre.ethers.formatEther(await hre.ethers.provider.getBalance(deployer.address)), 'ETH');

  // baseURI 는 메타데이터 서버 확정 전까지 빈 값 — setBaseURI 로 추후 설정.
  const badge = await hre.ethers.deployContract('SeasonBadge', ['']);
  await badge.waitForDeployment();

  const addr = await badge.getAddress();
  console.log('SeasonBadge deployed :', addr);
  console.log('explorer             :', `https://sepolia-explorer.giwa.io/address/${addr}`);
  console.log('\nverify:');
  console.log(`  npx hardhat verify --network giwaSepolia ${addr} ""`);
}

main().catch((e) => {
  console.error(e);
  process.exitCode = 1;
});
