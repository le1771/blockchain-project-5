const StarNotary = artifacts.require('StarNotary')

contract('StarNotary', accounts => { 
    
    let user1 = accounts[1]
    let user2 = accounts[2]
    let randomMaliciousUser = accounts[3]

    let name = 'awesome star!'
    let starStory = "this star was bought for my wife's birthday"
    let ra = "ra_032.155"
    let dec = "dec_121.874"
    let mag = "mag_245.978"
    let starId = 1

    beforeEach(async function() { 
        this.contract = await StarNotary.new({from: accounts[0]})
    })
    
    describe('can create a star', () => { 
        it('can create a star and get its name', async function () { 
            await this.contract.createStar(name, starStory, ra, dec, mag, starId, {from: user1})
            let starInfo = await this.contract.tokenIdToStarInfo(starId)
            assert.equal(starInfo[0], name)
        })
    })

    describe('star uniqueness', () => { 
        beforeEach(async function() {
            await this.contract.createStar(name, starStory, ra, dec, mag, starId, {from: user1})
        })
        
        it('only stars unique stars can be minted', async function() { 
            // first we mint our first star
            // then we try to mint the same star, and we expect an error
            // try to mint a star with the same id (1) that already minted
            // let result = await this.contract.createStar('New star name', 'New Story', 'ra_000.001', 'dec_121.871', 'mag_245.971', starId, {from: user1})
            // console.log(result)
            // let starInfo = await this.contract.tokenIdToStarInfo(starId)
            // console.log(starInfo)
            await expectThrow(this.contract.createStar('New star name', 'New Story', 'ra_000.001', 'dec_121.871', 'mag_245.971', starId, {from: user1}))
        })

        it('only stars unique stars can be minted even if their ID is different', async function() { 
            // first we mint our first star
            // then we try to mint the same star, and we expect an error
            // try to mint a star with same name but different id
            await expectThrow(this.contract.createStar(name, starStory, ra, dec, mag, 2, {from: user1}))
        })

        it('minting unique stars does not fail', async function() { 
            for(let i = 0; i < 10; i ++) { 
                let id = i + 2
                let newRa = 'ra_000.00' + i.toString()
                let newDec = 'dec_000.00' + i.toString()
                let newMag = 'mag_000.00' + i.toString()

                await this.contract.createStar(name, starStory, newRa, newDec, newMag, id, {from: user1})

                let starInfo = await this.contract.tokenIdToStarInfo(starId)
                assert.equal(starInfo[0], name)
            }
        })
    })

    describe('buying and selling stars', () => { 
        let user1 = accounts[1]
        let user2 = accounts[2]
        let randomMaliciousUser = accounts[3]
        
        let starId = 1
        let starPrice = web3.toWei(.01, "ether")

        beforeEach(async function () { 
            await this.contract.createStar(name, starStory, ra, dec, mag, starId, {from: user1})  
        })

        it('user1 can put up their star for sale', async function () { 
            assert.equal(await this.contract.ownerOf(starId), user1)
            await this.contract.putStarUpForSale(starId, starPrice, {from: user1})
            
            assert.equal(await this.contract.starsForSale(starId), starPrice)
        })

        describe('user2 can buy a star that was put up for sale', () => { 
            beforeEach(async function () { 
                await this.contract.putStarUpForSale(starId, starPrice, {from: user1})
            })

            it('user2 is the owner of the star after they buy it', async function() { 
                await this.contract.buyStar(starId, {from: user2, value: starPrice, gasPrice: 0})
                assert.equal(await this.contract.ownerOf(starId), user2)
            })

            it('user2 ether balance changed correctly', async function () { 
                let overpaidAmount = web3.toWei(.05, 'ether')
                const balanceBeforeTransaction = web3.eth.getBalance(user2)
                await this.contract.buyStar(starId, {from: user2, value: overpaidAmount, gasPrice: 0})
                const balanceAfterTransaction = web3.eth.getBalance(user2)

                assert.equal(balanceBeforeTransaction.sub(balanceAfterTransaction), starPrice)
            })
        })
    })
})

let expectThrow = async function (promise){
    try{
        await promise;
    } catch (error) {
        assert.exists(error);
        return;
    }

    assert.fail('Expect an error but didnt see one!!');
}