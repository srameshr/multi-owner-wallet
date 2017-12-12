pragma solidity ^0.4.0;

contract MultiSigWallet {
    address private owner;
    
    // Other people can add money to this wallet
    mapping(address => bool) owners;
    
    modifier isOwner() {
        require(owner == msg.sender);
        _;
    }
    
    // As soon as someone tries to deposit we need to get logs about the operation
    event DepositFunds(address from, uint amount);
    // As soon as someone tries to withdraw log that event
    event WithdrawFunds(address to, uint amount);
    event TransferFunds(address from, address to, uint amount);
    
    // Check if a given address is one of the owners of the wallet
    modifier isAOwner(address _addr) {
        require(_addr == owner || owners[_addr] == true);
        _;
    }
    
    function MultiSigWallet()
        public {
        owner = msg.sender;
    }
    
    // The current owner (main) can add more owners to this wallet
    function addOwner(address newOwner)
        isOwner
        public {
        owners[newOwner] = true;
    }
    
    // Remove suspicious owner
    function removeOwner(address existingOwner)
        isOwner 
        public {
        delete owners[existingOwner];
    }
    
    // Deposit funds into this wallet
    function deposit()
        isAOwner(msg.sender)
        payable
        public {
        DepositFunds(msg.sender, msg.value);
    }
    
    // Allow a owner to withdra an amount which is not greater than his balance
    function withdraw(uint amount)
        isAOwner(msg.sender)
        public {
            require(address(this).balance >= amount);
            msg.sender.transfer(amount);
            WithdrawFunds(msg.sender, amount);
        }
    
    // Allow an existing owner to transfer to funds to other people
    function transferTo(address to, uint amount)
        isAOwner(msg.sender)
        public {
            require(address(this).balance >= amount);
            to.transfer(amount);
            TransferFunds(msg.sender, to, amount);
    }
}
