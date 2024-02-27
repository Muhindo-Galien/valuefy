module Staking {
    resource Pool {
        rewards_token:  0x1.LibraCoin.T,
        staking_token:  0x1.LibraCoin.T,
        reward_rate: u64,
        last_update_time: u64,
        reward_per_token_stored: u64,
        rewards: vector<u8, u64>,
        rewards_per_token_paid: vector<u8, u64>,
        staked: vector<u8, u64>,
        total_supply: u64,
    }

    public fun rewardPerToken(): u64 {
        let total_supply = Pool.total_supply;
        let reward_per_token_stored = Pool.reward_per_token_stored;
        let last_time_update = Pool.last_update_time;
        let reward_rate = Pool.reward_rate;
        if (total_supply ==  0) {
            return reward_per_token_stored;
        }
        let current_time =  0x1.LibraAccount.T{address: move_from<0x1.LibraAccount.T>(LibraAccount.address())}.get_metadata().timestamp;
        return reward_per_token_stored + (((current_time - last_time_update) * reward_rate *  1e18) / total_supply);
    }

    public fun earned(account: address): u64 {
        let staked = Pool.staked[account];
        let reward_per_token = rewardPerToken();
        let rewards_per_token_paid = Pool.rewards_per_token_paid[account];
        let rewards = Pool.rewards[account];
        return ((staked * (reward_per_token - rewards_per_token_paid)) /  1e18) + rewards;
    }

    public fun updateReward(account: address) {
        let reward_per_token_stored = rewardPerToken();
        let last_update_time =  0x1.LibraAccount.T{address: move_from<0x1.LibraAccount.T>(LibraAccount.address())}.get_metadata().timestamp;
        let rewards = earned(account);
        Pool.rewards[account] = rewards;
        Pool.rewards_per_token_paid[account] = reward_per_token_stored;
        Pool.reward_per_token_stored = reward_per_token_stored;
        Pool.last_update_time = last_update_time;
    }

    public fun stake(amount: u64) {
        let sender = move_from<0x1.LibraAccount.T>(LibraAccount.sender());
        let staking_token = Pool.staking_token;
        let total_supply = Pool.total_supply;
        let staked = Pool.staked[sender];
        staking_token.deposit_to_sender(amount);
        Pool.total_supply = total_supply + amount;
        Pool.staked[sender] = staked + amount;
    }

    public fun withdraw(amount: u64) {
        let sender = move_from<0x1.LibraAccount.T>(LibraAccount.sender());
        let staking_token = Pool.staking_token;
        let total_supply = Pool.total_supply;
        let staked = Pool.staked[sender];
        staking_token.withdraw_from_sender(amount);
        Pool.total_supply = total_supply - amount;
        Pool.staked[sender] = staked - amount;
    }

    public fun getReward() {
        let sender = move_from<0x1.LibraAccount.T>(LibraAccount.sender());
        let rewards_token = Pool.rewards_token;
        let rewards = Pool.rewards[sender];
        rewards_token.transfer(sender, rewards);
        Pool.rewards[sender] =  0;
    }
}
