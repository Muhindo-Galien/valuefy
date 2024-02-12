module LendingPool {
    use Sui::coin::{Coin, Self};
    use Sui::tx_context::TxContext;
    use Sui::transfer::Self;
    use Sui::clock::Clock;

    // Struct to represent a lender
    struct Lender {
        address: address,
        amount: u64,
    }

    // Struct to represent a borrower
    struct Borrower {
        address: address,
        amount: u64,
        borrow_timestamp: u64,
    }

    // Define lending pool contract
    resource Pool {
        pool_address: address,
        base_cap: u64,
        quote_cap: u64,
        base_balance: u64,
        quote_balance: u64,
        interest_rate: u64,
        lenders: vector<u8, Lender>,
        borrowers: vector<u8, Borrower>,
    }

    public fun create_pool(pool_address: address, base_cap: u64, quote_cap: u64, interest_rate: u64) {
        let new_pool = Pool {
            pool_address: pool_address,
            base_cap: base_cap,
            quote_cap: quote_cap,
            base_balance: 0,
            quote_balance: 0,
            interest_rate: interest_rate,
            lenders: Vector(),
            borrowers: Vector(),
        };
        move_to<T>(new_pool, pool_address);
    }

    public fun lend_to_pool(pool_address: address, amount: u64) {
        let pool: &mut Pool;
        pool = borrow_global_mut<Pool>(pool_address);
        
        // Deposit amount to the pool
        let coin: Coin<T>;
        coin = Coin<T>::new(amount);

        book::make_base_deposit(pool, move(coin), custodian::create_account());
        
        // Record the lender
        let sender: address;
        sender = TxContext::sender();
        let lender = Lender {
            address: sender,
            amount: amount,
        };
        pool.lenders.push(lender);
    }

    public fun borrow_from_pool(pool_address: address, amount: u64) {
        let pool: &mut Pool;
        pool = borrow_global_mut<Pool>(pool_address);

        // Check if the pool has enough balance for borrowing
        assert(pool.base_balance >= amount, 0);

        // Record the borrower
        let sender: address;
        sender = TxContext::sender();
        let borrow_timestamp: u64;
        borrow_timestamp = Clock::now();
        let borrower = Borrower {
            address: sender,
            amount: amount,
            borrow_timestamp: borrow_timestamp,
        };
        pool.borrowers.push(borrower);

        // Withdraw the borrowed amount
        let coin: Coin<T>;
        coin = Coin<T>::new(amount);

        book::make_base_deposit(pool, move(coin), custodian::create_account());
    }

    // Function to calculate interest
    public fun calculate_interest(borrow_timestamp: u64, current_timestamp: u64, interest_rate: u64, amount: u64): u64 {
        let time_difference: u64;
        time_difference = current_timestamp - borrow_timestamp;
        let interest: u64;
        interest = (amount * time_difference * interest_rate) / 100; // Assuming interest_rate is in percentage
        return interest;
    }

    // Function to repay borrowed amount
    public fun repay(pool_address: address, amount: u64) {
        let pool: &mut Pool;
        pool = borrow_global_mut<Pool>(pool_address);

        // Find the borrower
        let sender: address;
        sender = TxContext::sender();
        let borrower_index: u64;
        let mut borrower_found: bool;
        borrower_found = false;
        for (index, borrower) in pool.borrowers.iter().enumerate() {
            if (borrower.address == sender && borrower.amount == amount) {
                borrower_index = index as u64;
                borrower_found = true;
                break;
            }
        }
        assert(borrower_found, 0);

        // Withdraw interest
        let current_timestamp: u64;
        current_timestamp = Clock::now();
        let interest: u64;
        interest = calculate_interest(pool.borrowers[borrower_index].borrow_timestamp, current_timestamp, pool.interest_rate, amount);

        let coin: Coin<T>;
        coin = Coin<T>::new(amount + interest);

        book::make_base_deposit(pool, move(coin), custodian::create_account());

        // Remove borrower from the list
        pool.borrowers.swap_remove(borrower_index as usize);
    }

    // Function for lender to withdraw
    public fun withdraw(pool_address: address, amount: u64) {
        let pool: &mut Pool;
        pool = borrow_global_mut<Pool>(pool_address);

        // Find the lender
        let sender: address;
        sender = TxContext::sender();
        let lender_index: u64;
        let mut lender_found: bool;
        lender_found = false;
        for (index, lender) in pool.lenders.iter().enumerate() {
            if (lender.address == sender && lender.amount == amount) {
                lender_index = index as u64;
                lender_found = true;
                break;
            }
        }
        assert(lender_found, 0);

        // Withdraw amount with interest
        let current_timestamp: u64;
        current_timestamp = Clock::now();
        let interest: u64;
        interest = calculate_interest(0, current_timestamp, pool.interest_rate, amount);

        let coin: Coin<T>;
        coin = Coin<T>::new(amount + interest);

        book::make_base_deposit(pool, move(coin), custodian::create_account());

        // Remove lender from the list
        pool.lenders.swap_remove(lender_index as usize);
    }
}
