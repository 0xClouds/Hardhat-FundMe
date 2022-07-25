const { deployments, ethers, getNamedAccounts } = require("hardhat")
describe("FundMe", async function () {
    let fundMe
    beforeEach(async function () {
        const { deployer } = await getNamedAcounts()
        await deployments.fixture(["all"])
        fundMe = await ethers.getContract("FundMe", deployer)
    })

    describe("constructor", async function () {})
})
