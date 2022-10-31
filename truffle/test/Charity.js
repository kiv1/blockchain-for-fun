const assert = require('assert').strict;

const Charitable = artifacts.require('Charity');

contract('Charity', (accounts) => {
	describe('validate authoriser, transfers and deposit:', () => {
		// TODO add a test for the version of the function that does not expect a donation amount.
		it('Should properly check all accounts are valid or signers', async () => {
			const instance = await Charitable.deployed();

			let isAdmin = await instance.isAdmin({
				from: accounts[0],
			});

			let isAdmin1 = await instance.isAdmin({
				from: accounts[1],
			});

			let isAdmin2 = await instance.isAdmin({
				from: accounts[2],
			});
			
			let isAdmin3 = await instance.isAdmin({
				from: accounts[3],
			});

			let isAdmin4 = await instance.isAdmin({
				from: accounts[4],
			});

			assert.equal(isAdmin, true);
			assert.equal(isAdmin1, true);
			assert.equal(isAdmin2, true);
			assert.equal(isAdmin3, true);
			assert.equal(isAdmin4, false);

		})

		it('Should properly check if the value is deposit and sent after the approval', async () => {
			const instance = await Charitable.deployed();

			const balances ={
				before: {
					contract: await web3.eth.getBalance(instance.address),
					account5: await web3.eth.getBalance(accounts[5]),
				},
				after: {
					contract: null,
					account5: null
				}
			};

			const transferAmount = Number(web3.utils.toWei('1', 'ether')) / 2;
			await instance.deposit( {
				from: accounts[5],
				value: transferAmount
			});

			const toTransfer = (Number(web3.utils.toWei('1', 'ether'))/1000000000) / 2;
			await instance.requestAction( accounts[5], toTransfer, {
				from: accounts[1]
			});

			await instance.approveAction({
				from: accounts[0]
			});
			await instance.approveAction({
				from: accounts[2]
			});
			await instance.approveAction({
				from: accounts[3]
			});

			balances.after.account5 = await web3.eth.getBalance(accounts[5]);
			balances.after.contract = await web3.eth.getBalance(instance.address);

			assert.equal(balances.before.contract, balances.after.contract);
			assert.notEqual(balances.before.account5, balances.after.account5);
		})

		it('Should properly reset all approvers', async () => {
			const instance = await Charitable.deployed();

			const balances ={
				before: {
					contract: await web3.eth.getBalance(instance.address),
				},
				after: {
					contract: null,
				}
			};

			const transferAmount = Number(web3.utils.toWei('1', 'ether')) / 2;
			await instance.deposit( {
				from: accounts[5],
				value: transferAmount
			});

			const toTransfer = (Number(web3.utils.toWei('1', 'ether'))/1000000000) / 2;
			await instance.requestAction( accounts[5], toTransfer, {
				from: accounts[1]
			});

			await instance.approveAction({
				from: accounts[0]
			});

			await instance.resetApprovers({
				from: accounts[0]
			});

			balances.after.contract = await web3.eth.getBalance(instance.address);

			assert.notEqual(balances.before.contract, balances.after.contract);
		})
	});
});