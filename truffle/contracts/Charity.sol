pragma solidity >=0.5.8 <0.9.0;

/// @title A contract that is able to facilitate donations to different charities
/// whenever a user wants to make a transfer of funds to another user.
contract Charity {
    address payable owner;
    address payable target;
    uint amount;
    address payable[] addresses;
    mapping(address=>bool) signers;
    mapping(address=>bool) approvers;


    /// @param addresses_ The list of addresses tat is valid to do actions.
    constructor(address payable[] memory addresses_) public {
        owner = payable(msg.sender);
        addresses = addresses_;
        target = payable(address(this));
        amount = 0;
        addresses.push(owner);
        for(uint i=0; i<addresses.length; i++){
            signers[addresses[i]] = true;
        }
        for(uint i=0; i<addresses.length; i++){
            approvers[addresses[i]] = false;
        }
    }

    /// Restricts the access only to the user who deployed the contract or authorised signers.
    modifier restrictToAuthoriser() {
        require(signers[msg.sender]==true , 'Method available only to the user that deployed the contract or the authorsed signer');
        _;
    }

    modifier isValid(address sender) {
        require(payable(sender).send(0) , 'Method available only to a valid payable address');
        _;
    }

    modifier isAuthoriseAllowed() {
        require(target!=payable(address(this)) && amount != 0, 'Method available only when target and amount has been set');
        _;
    }

    modifier hasApproved() {
        require(approvers[msg.sender]!=true, 'Method available only when user has not approved');
        _;
    }

    /// Validates that the donated amount is within acceptable limits.
    ///
    /// @param donationAmount The target donation amount.
    modifier validateDonationAmount(uint256 donationAmount) {
        require((donationAmount*1000000000) <= address(this).balance && (donationAmount*1000000000)>0,
            'Vault does not conatin enough for donation');
        _;
    }

    /// Validates that the amount to transfer is not zero.
    modifier validateTransferAmount() {
        require(msg.value > 0, 'Transfer amount has to be greater than 0.');
        _;
    }

    /// Transmits the address of the donor and the amount donated.
    event Donation(
        address indexed _donor,
        uint256 _value
    );

    function deposit() public 
    validateTransferAmount() payable {
        uint256 donationAmount = msg.value;
        emit Donation(msg.sender, donationAmount);
    }

    function requestAction(address destinationAddress, uint256 donationAmount) public 
    restrictToAuthoriser()
    isValid(destinationAddress)
    validateDonationAmount(donationAmount) {
        target = payable(destinationAddress);
        amount = donationAmount;
        for(uint i=0; i<addresses.length; i++){
            approvers[addresses[i]] = false;
        }
        approvers[msg.sender] = true;
    }

    function getAllSigners() public restrictToAuthoriser() view returns(uint) {
        uint count = 0;
        for(uint i=0; i<addresses.length; i++){
            if (signers[addresses[i]] == true){
                count+=1;
            }
        }

        return count;
    }

    function getAllApprovers() public restrictToAuthoriser() view returns(uint) {
        uint count = 0;
        for(uint i=0; i<addresses.length; i++){
            if (approvers[addresses[i]] == true){
                count+=1;
            }
        }

        return count;
    }

    function getTarget() public restrictToAuthoriser() view returns(address) {
        return target;
    }

    function getAmount() public restrictToAuthoriser() view returns(uint) {
        return amount;
    }

    function hasApproveAction() public
    restrictToAuthoriser() view returns(bool)
    {
        return approvers[msg.sender];
    }
    
    function approveAction() public 
    restrictToAuthoriser()
    hasApproved()
    isAuthoriseAllowed() {
        approvers[msg.sender] = true;
        uint count = 0;
        for(uint i=0; i<addresses.length; i++){
            if (approvers[addresses[i]] == true) {
                count+=1;
            }
        }
        if (count == (addresses.length)){
            for(uint i=0; i<addresses.length; i++){
                approvers[addresses[i]] = false;
            }
            target.transfer(amount*1000000000);
            target = payable(address(this));
            amount = 0;
        }
    }

    function resetApprovers() public restrictToAuthoriser() {
        target = payable(address(this));
        amount = 0;
        for(uint i=0; i<addresses.length; i++){
            approvers[addresses[i]] = false;
        }
    }

    function isAdmin() public view returns(bool) {
        if (signers[msg.sender] == true){
            return true;
        }
        return false;
    }

}