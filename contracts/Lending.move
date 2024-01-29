module LiquidityPool {
    // Defining the struct for recording lending and borrowing amounts
    struct Amount {
        value: u64,
        start: u64,
    }

    // Defining the struct for the pool contract
    resource Pool {
        coin: 0x1.LibraCoin.T,
        total_supply: u64,
        lend_rate: u64,
        borrow_rate: u64,
        period_borrowed: u64,
        lend_amounts: vector<Amount>,
        earned_interest: vector<u64>,
        lenders: vector<bool>,
        borrowers: vector<bool>,
        borrow_amounts: vector<Amount>,
        pay_interest: vector<u64>,
    }

    // Function to initialize the pool contract
    public fun init(token_address: address, amount: u64): Pool {
        let coin: 0x1.LibraCoin.T;
        coin = 0x1.LibraCoin.T{address: move_from<Token>(token_address)};
        Pool {
            coin: coin,
            total_supply: amount,
            lend_rate: 100,
            borrow_rate: 130,
            period_borrowed: 0,
            lend_amounts: empty<Amount>(),
            earned_interest: empty<u64>(),
            lenders: empty<bool>(),
            borrowers: empty<bool>(),
            borrow_amounts: empty<Amount>(),
            pay_interest: empty<u64>(),
        }
    }

    // Function to lend amount to the pool
    public fun lend(amount: u64) {
        assert(amount != 0, 0);
        let sender: address = move_from<0x1.LibraAccount.T>(LibraAccount.sender());
        let current_time: u64 = 0x1.LibraAccount.T{address: move_from<0x1.LibraAccount.T>(LibraAccount.address())}.get_metadata().timestamp;
        let lend_amount: Amount = Amount{value: amount, start: current_time};
        Pool.lend_amounts.push(lend_amount);
        Pool.lenders.push(true);
        Pool.total_supply = Pool.total_supply + amount;
    }

    // Function to borrow amount from the pool
    public fun borrow(amount: u64) {
        assert(amount != 0, 0);
        let sender: address = move_from<0x1.LibraAccount.T>(LibraAccount.sender());
        let current_time: u64 = 0x1.LibraAccount.T{address: move_from<0x1.LibraAccount.T>(LibraAccount.address())}.get_metadata().timestamp;
        let borrow_amount: Amount = Amount{value: amount, start: current_time};
        Pool.borrow_amounts.push(borrow_amount);
        Pool.borrowers.push(true);
        Pool.total_supply = Pool.total_supply - amount;
    }

    // Function to repay the borrowed amount
    public fun repay() {
        let sender: address = move_from<0x1.LibraAccount.T>(LibraAccount.sender());
        let borrow_amount: Amount = Pool.borrow_amounts[Pool.borrowers.indexOf(true)];
        let current_time: u64 = 0x1.LibraAccount.T{address: move_from<0x1.LibraAccount.T>(LibraAccount.address())}.get_metadata().timestamp;
        let elapsed_time: u64 = current_time - borrow_amount.start;
        let interest: u64 = (borrow_amount.value * elapsed_time * Pool.borrow_rate) / Pool.total_supply;
        let total_amount: u64 = borrow_amount.value + interest;
        let coin: 0x1.LibraCoin.T = Pool.coin;
        coin.deposit_to_sender(total_amount);
        Pool.borrow_amounts.remove(borrow_amount);
        Pool.borrowers.remove(true);
        Pool.total_supply = Pool.total_supply + total_amount;
    }

    // Function to withdraw the lent amount with interest
    public fun withdraw() {
        let sender: address = move_from<0x1.LibraAccount.T>(LibraAccount.sender());
        let lend_amount: Amount = Pool.lend_amounts[Pool.lenders.indexOf(true)];
        let current_time: u64 = 0x1.LibraAccount.T{address: move_from<0x1.LibraAccount.T>(LibraAccount.address())}.get_metadata().timestamp;
        let elapsed_time: u64 = current_time - lend_amount.start;
        let interest: u64 = (lend_amount.value * elapsed_time * Pool.lend_rate) / Pool.total_supply;
        let total_amount: u64 = lend_amount.value + interest;
        let coin: 0x1.LibraCoin.T = Pool.coin;
        coin.withdraw_from_sender(total_amount);
        Pool.lend_amounts.remove(lend_amount);
        Pool.lenders.remove(true);
        Pool.total_supply = Pool.total_supply - total_amount;
    }
}
