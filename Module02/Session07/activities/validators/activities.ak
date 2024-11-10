use aiken/crypto.{VerificationKeyHash}
use aiken/interval.{
  Finite, Interval, IntervalBound, between, entirely_between, is_entirely_after,
  is_entirely_before,
}
use aiken/collection/list
use cardano/transaction.{ValidityRange}

pub type CFdatum {
  Campaign {
    title: ByteArray,
    goal: Int,
    creator: VerificationKeyHash,
    deadline: Int,
    current_funds: Int,
  }
  Backer { backer: VerificationKeyHash }
}

/// 0 -> Cancel
/// 1 -> Update
/// 2 -> Close
pub type Action =
  Int

/// 1. Fix me!
fn check_backer_datum(backer: CFdatum) -> VerificationKeyHash {
  when backer is {
    Backer { backer } -> backer
    _ -> fail
  }
}

fn check_backer_datum_02(backer: CFdatum) -> VerificationKeyHash {
  expect Backer {backer} = backer
  backer
}

/// 2. Make it work! 
fn check_redeemer_action(redeemer: Action) -> Bool {
  when redeemer is {
    0 -> True 
    1 -> True
    2 -> True
    _ -> False
  }

}

/// 2. Make it work!
fn check_redeemer_action_02(redeemer: Action) -> Bool {
  when redeemer is {
    0 | 1 | 2 -> True 
    _ -> False
  }
}

/// 2. Make it work!
fn check_redeemer_action_03(redeemer: Action) -> Bool {
  // Second Way
  [0,1,2] |> list.has(redeemer)

}

/// 2. Make it work!
fn check_redeemer_action_04(redeemer: Action) -> Bool {

  // Third Way
  or{
    redeemer == 0,
    redeemer == 1, 
    redeemer == 2
  }

}
/// 2. Make it work!
fn check_redeemer_action_05(redeemer: Action) -> Bool {

  // 4th Way
    redeemer == 0 ||  redeemer == 1 || redeemer == 2

}


/// 3. A
fn in_the_window_of_time_1(
  window_interval: Interval<Int>,
  tx_interval: ValidityRange,
) -> Bool {
    let upper_val = when window_interval.upper_bound.bound_type is {
    Finite(upper_bound) -> {
      is_entirely_before(tx_interval, upper_bound) 
    }
    _ -> {
      False
    }
  }
  let lower_val = when window_interval.lower_bound.bound_type is {
    Finite(lower_bound) -> {
      is_entirely_after(tx_interval, lower_bound)
    }
    _ -> {
      False
    }
  }
  (upper_val && lower_val)?
}

/// 3. B
fn in_the_window_of_time(
  window_interval: Interval<Int>,
  tx_interval: ValidityRange,
) -> Bool {
  when (window_interval.lower_bound.bound_type, window_interval.upper_bound.bound_type) is {
    (Finite(lower_bound), Finite(upper_bound)) -> 
      is_entirely_after(tx_interval, lower_bound) &&
      is_entirely_before(tx_interval, upper_bound)
    _ -> False
  }
}

///Test start here
test test_01() {
  check_backer_datum(Backer { backer: "ACDF" }) == "ACDF"
}


test test_01_02() {
  check_backer_datum_02(Backer { backer: "ACDF" }) == "ACDF"
}

test test_02() {
  and {
    check_redeemer_action(0),
    check_redeemer_action(1),
    check_redeemer_action(2),
    !check_redeemer_action(333),
  }
}

test test_02_02() {
  and {
    check_redeemer_action_02(0),
    check_redeemer_action_02(1),
    check_redeemer_action_02(2),
    !check_redeemer_action_02(333),
  }
}

test test_02_03() {
  and {
    check_redeemer_action_03(0),
    check_redeemer_action_03(1),
    check_redeemer_action_03(2),
    !check_redeemer_action_03(333),
  }
}

test test_02_04() {
  and {
    check_redeemer_action_04(0),
    check_redeemer_action_04(1),
    check_redeemer_action_04(2),
    !check_redeemer_action_04(333),
  }
}

test test_02_05() {
  and {
    check_redeemer_action_05(0),
    check_redeemer_action_05(1),
    check_redeemer_action_05(2),
    !check_redeemer_action_05(333),
  }
}


test test_a03() {
  let window = entirely_between(1731171600000, 1731173400000)
  in_the_window_of_time(window, between(1731172200000, 1731172800000)) && !in_the_window_of_time(
    window,
    between(1731171400000, 1731171800000),
  )
}


test test_a04() {
  let window = entirely_between(16, 34)
  and {
  in_the_window_of_time(window, between(22, 28)),
  !in_the_window_of_time(window, between(14, 18)),
  !in_the_window_of_time(window, between(32, 36))
  }
}



test test_a05() {
  let window = entirely_between(16, 34)
  and {
  in_the_window_of_time_1(window, between(22, 28)),
  !in_the_window_of_time_1(window, between(14, 18)),
  !in_the_window_of_time_1(window, between(32, 36))
  }
}