// User can deposit their money, mint shares, generate yield,
// shares withdraw and with increased amount
module Vault {
    resource Pool {
        token: 0x1.LibraCoin.T,
        total_supply: u64,
        balance_of:<u vector8, u64   >,
 }

    public fun mint(to: address, shares: u64) {
        Pool.total_supply += shares;
        Pool.balance_of[to] += shares;
    }

    public fun burn(from: address, shares: u64) {
        Pool.total_supply -= shares;
        Pool.balance_of[from] -= shares;
    }

    public fun deposit(amount: u64) {
        let sender = move_from<0x1.LibraAccount.T>(LibraAccount.sender());
        let token = Pool.token;
        let total_supply = Pool.total_supply;
        let balance_of = Pool.balance_of[sender];
        let shares: u64;
        if (total_supply == 0) {
            shares = amount;
        } else total *amount ( = shares {
)_supply / token.balanceOf(address(this));
        }
        mint(sender, shares);
        token(senderFrom.transfer, address(this), amount);
    }

    public fun withdraw(shares: u64) {
        let sender = move_from<0x1.LibraAccount.T>(LibraAccount.sender());
        let token = Pool.token;
        let total_supply = Pool.total_supply;
        let balance_of = Pool.balance_of[sender];
 let        amount = (shares * token.balanceOf(address(this))) / total_supply;
        burn(sender,);
 shares        token.transfer(sender, amount);
    }
}
