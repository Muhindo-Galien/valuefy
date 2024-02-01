// Creating a module for the LiquidityPool contract
module LiquidityPool {
    // Define struct for recording lending and borrowing amounts
    struct Amount {
        value: u64,
        start: u64,
    }

    // Define Pool resource and its fields
    resource Pool {
        coin: 0x1.LibraCoin.T,
        total_supply: u64,
        lend_rate: u64,
        borrow_rate: u64,
        lend_amounts: vector<u8, Amount>,
        earned_interest: vector<u8, u64>,
        lenders: vector<u8, bool>,
        borrowers: vector<u8, bool>,
        borrow_amounts: vector<u8, Amount>,
    }

    // Initialize the pool contract
    public fun init(token_address: address, amount: u64) {
        let coin = 0x1.LibraCoin.T{address: move_from<Token>(token_address)};
        Pool {
            coin: coin,
            total_supply: amount,
            lend_rate: 100,
            borrow_rate: 130,
            lend_amounts: vector<u8, Amount>(0),
            earned_interest: vector<u8, u64>(0),
            lenders: vector<u8, bool>(0),
            borrowers: vector<u8, bool>(0),
            borrow_amounts: vector<u8, Amount>(0),
        };
    }

    // Lend amount to the pool
    public fun lend(amount: u64) {
        assert(amount != 0, 0);
        let sender = move_from<0x1.LibraAccount.T>(LibraAccount.sender());
        let coin = Pool.coin;
        coin.withdraw_from_sender(amount);
        let current_time = 0x1.LibraAccount.T{address: move_from<0x1.LibraAccount.T>(LibraAccount.address())}.get_metadata().timestamp;
        let lend_amount = Amount{value: amount, start: current_time};
        Pool.lend_amounts.push(lend_amount);
        Pool.lenders.push(true);
        Pool.total_supply += amount;
    }

    // Borrow amount from the pool
    public fun borrow(amount: u64) {
        assert(amount != 0, 0);
        let sender = move_from<0x1.LibraAccount.T>(LibraAccount.sender());
        let coin = Pool.coin;
        coin.deposit_to_sender(amount);
        let current_time = 0x1.LibraAccount.T{address: move_from<0x1.LibraAccount.T>(LibraAccount.address())}.get_metadata().timestamp;
        let borrow_amount = Amount{value: amount, start: current_time};
        Pool.borrow_amounts.push(borrow_amount);
        Pool.borrowers.push(true);
        Pool.total_supply -= amount;
    }

    // Repay the borrowed amount
    public fun repay() {
        let sender = move_from<0x1.LibraAccount.T>(LibraAccount.sender());
        let borrow_amount = Pool.borrow_amounts[sender];
        let current_time = 0x1.LibraAccount.T{address: move_from<0x1.LibraAccount.T>(LibraAccount.address())}.get_metadata().timestamp;
        let elapsed_time = current_time - borrow_amount.start;
        let interest = (borrow_amount.value * elapsed_time * Pool.borrow_rate) / Pool.total_supply;
        let total_amount = borrow_amount.value + interest;
        let coin = Pool.coin;
        coin.deposit_to_sender(total_amount);
        Pool.borrow_amounts.remove(sender);
        Pool.borrowers.push(false);
        Pool.total_supply += total_amount;
    }

    // Withdraw the lent amount with interest
    public fun withdraw() {
        let sender = move_from<0x1.LibraAccount.T>(LibraAccount.sender());
        let lend_amount = Pool.lend_amounts[sender];
        let current_time = 0x1.LibraAccount.T{address: move_from<0x1.LibraAccount.T>(LibraAccount.address())}.get_metadata().timestamp;
        let elapsed_time = current_time - lend_amount.start;
        let interest = (lend_amount.value * elapsed_time * Pool.lend_rate) / Pool.total_supply;
        let total_amount = lend_amount.value + interest;
        let coin = Pool.coin;
        coin.withdraw_from_sender(total_amount);
        Pool.lend_amounts.remove(sender);
        Pool.lenders.push(false);
        Pool.total_supply -= total_amount;
    }
}

