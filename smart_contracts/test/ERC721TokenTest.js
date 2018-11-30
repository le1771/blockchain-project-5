const ERC721Token = artifacts.require ('ERC721Token');

contract ('ERC721Token', accounts => {
    let defaultAccount = accounts[0];
    let user1 = accounts[1];
    let user2 = accounts[2];
    let operator = accounts[3];

    beforeEach(async function () {
        this.contract = await ERC721Token.new({from: defaultAccount})
    });
    
    describe ('can  create a token', () => {
        let tokenId = 1;
        let tx;

        beforeEach(async function () {
            tx = await this.contract.mint(tokenId, {from: user1});
        });

        it('ownerOf tokenId is user1', async function () {
            assert.equal(await this.contract.ownerOf(tokenId), user1);
        });
    
        it('balanceOf user1 is increased by 1', async function() {
            let balance = await this.contract.balanceOf(user1);
            assert.equal(balance.toNumber(), 1);
        });
    
        it('emits the correct event during creation of a new function', async function () {
            assert.equal(tx.logs[0].event, 'Transfer');
        })
    });

    describe ('can transfer token', () =>{
        let tokenId = 1;
        let tx;
        
        beforeEach(async function(){
            await this.contract.mint(tokenId, {from: user1});

            tx = await this.contract.transferFrom(user1, user2, tokenId, {from: user1});
        });

        it('token has new owner', async function (){
            assert.equal(await this.contract.ownerOf(tokenId), user2);
        });

        it('emits the contract event', async function (){

            assert.equal(tx.logs[0].event,'Transfer');
            //assert.equal(tx.logs[0].args._tokenId, tokenId);
            //assert.equal(tx.logs[0].args._to, user2);
            //assert.equal(tx.logs[0].args._from, user1);
        });

        it('only permissioned users can trasfer tokens', async function(){
            let randomPersonTryingToStealToken = accounts[4];
            // console.log('user1: ', user1);
            // console.log('user2: ', user2);
            // console.log('check owner of token1 is: ', await this.contract.ownerOf(tokenId));
            await expectThrow(this.contract.transferFrom(user1, randomPersonTryingToStealToken, tokenId, {from: randomPersonTryingToStealToken}));
        });
    });

    describe ('can grant approval to transfer', () => {
        let tokenId = 1;
        let tx;

        beforeEach(async function(){
            await this.contract.mint(tokenId, {from: user1});
            tx = await this.contract.approve(user2, tokenId, {from: user1});
        });

        it('set user2 as an approved address', async function(){
            assert.equal(await this.contract.getApproved(tokenId), user2);
        });

        it('user2 can now transfer', async function(){
            await this.contract.transferFrom (user1, user2, tokenId, {from: user2});

            assert.equal(await this.contract.ownerOf(tokenId), user2);
        });

        it('emits the correct event', async function (){
            assert.equal(tx.logs[0].event, 'Approval');
        });
    });

    describe ('can set an operator', () =>{
        let tokenId = 1
        let tx

        beforeEach(async function(){
            await this.contract.mint(tokenId, {from: user1});
            tx = await this.contract.setApprovalForAll(operator, true, {from: user1});
        });

        it('can set an operator', async function(){
            assert.equal(await this.contract.isApprovedForAll(user1, operator), true);
        });

        it('operator can now transfer', async function(){
            await this.contract.transferFrom (user1, user2, tokenId, {from: operator});
            
            assert.equal(await this.contract.ownerOf(tokenId), user2);
        });

        it('emits the correct event', async function(){
            assert.equal(tx.logs[0].event, 'ApprovalForAll');
        })
    })
});

let expectThrow = async function (promise){
    try{
        await promise;
    } catch (error) {
        assert.exists(error);
        return;
    }

    assert.fail('Expect an error but didnt see one!!');
}