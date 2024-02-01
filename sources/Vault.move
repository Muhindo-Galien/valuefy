// This module is named Vault
module Vault {
    // This resource named Pool contains the token, total supply of tokens, and a balance mapping for each user
    resource Pool {
        token: 0x1::LibraCoin::T,
        total_supply: u64,
        balance_of: vector<u8, u64>,
    }

    // This function mints new tokens and adds them to the total supply and the balance of the recipient
    public fun mint(to: address, shares: u64) acquires Pool {
        let pool = borrow_global_mut<Pool>(0x1);
        pool.total_supply += shares;
        pool.balance_of[to] += shares;
    }

    // This function burns tokens from a user's balance and reduces the total supply
    public fun burn(from: address, shares: u64) acquires Pool {
        let pool = borrow_global_mut<Pool>(0x1);
        pool.total_supply -= shares;
        pool.balance_of[from] -= shares;
    }

    // This function allows a user to deposit tokens into the pool
    public fun deposit(amount: u64) acquires Pool {
        let sender = move_from<0x1::LibraAccount::T>(LibraAccount::address_of(&sender));
        let pool = borrow_global_mut<Pool>(0x1);
        let shares: u64;
        // If the total supply is 0, the number of shares is equal to the amount deposited
        if (pool.total_supply == 0) {
            shares = amount;
        } else {
            // Otherwise, the number of shares is calculated based on the amount deposited and the current total supply
            shares = amount * pool.total_supply / LibraCoin::balance_of_address(&pool.token);
        }
        // The new shares are minted for the sender
        mint(sender, shares);
        // The amount is transferred from the sender's account
        LibraAccount::pay_from_sender<LibraCoin::T>(amount);
    }

    // This function allows a user to withdraw their tokens from the pool
    public fun withdraw(shares: u64) acquires Pool {
        let sender = move_from<0x1::LibraAccount::T>(LibraAccount::address_of(&sender));
        let pool = borrow_global_mut<Pool>(0x1);
        // The amount to be withdrawn is calculated based on the number of shares and the current total supply
        let amount = (shares * LibraCoin::balance_of_address(&pool.token)) / pool.total_supply;
        // The shares are burned from the sender's balance
        burn(sender, shares);
        // The amount is transferred to the sender's account
        LibraAccount::pay_from_sender<LibraCoin::T>(amount);
    }
}
