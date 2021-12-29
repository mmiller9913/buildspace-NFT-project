const main = async () => {
    //compile contract and generate the necessary files in /artifacts
    const nftContractFactory = await hre.ethers.getContractFactory('MyEpicNFT');
    //hardhat creates a local ethereum network just for this contract
    //after this script completes, it destroys that network 
    //so, every time we run the contract, it's like a "fresh blockchain"
    const nftContract = await nftContractFactory.deploy();
    //wait until the contract is minted and deployed to our local blockchain
    await nftContract.deployed();
    console.log("Contract deployed to:", nftContract.address);

    // Call the function.
    let txn = await nftContract.makeAnEpicNFT()
    // Wait for it to be mined.
    await txn.wait()

    // Mint another NFT for fun.
    txn = await nftContract.makeAnEpicNFT()
    // Wait for it to be mined.
    await txn.wait()
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();