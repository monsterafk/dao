const ethers = require("ethers")

const abi = require("./out/PazitoDao.sol/PazitoDao.json").abi
require("dotenv").config

const rpc = process.env.RPC
const addr = process.env.SC

async function check() {
    try{
        const provider = new ethers.providers.EtherscanProvider("sepolia", rpc)
        const test = new ethers.Contract(addr, abi, provider)

        test.on("ProposalCreated", (id, proposer, targets, value,  event) => {
            let data = {
                id: id,
                proposer: proposer,
                targets: targets,
                value: value,
                event: event
            }
            console.log(JSON.stringify(data, null, 4))

            //
            // any code
            //

        })
    } catch(e) {
        console.error(e)
    }

}

check()