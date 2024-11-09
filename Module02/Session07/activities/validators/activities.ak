use aiken/crypto.{VerificationKeyHash}
use aiken/interval.{
  Finite, Interval, IntervalBound, between, entirely_between, is_entirely_after,
  is_entirely_before,
}
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

/// 2. Make it work!
fn check_redeemer_action(redeemer: Action) -> Bool {
  when redeemer is {
    0 -> True 
    1 -> True
    2 -> True
    _ -> False
  }
}

/// 3. A
// fn in_the_window_of_time(
//   window_interval: Interval<Int>,
//   tx_interval: ValidityRange,
// ) -> Bool {
//     let upper_val = when window_interval.upper_bound.bound_type is {
//     Finite(upper_bound) -> {
//       is_entirely_before(tx_interval, upper_bound) 
//     }
//     _ -> {
//       False
//     }
//   }
//   let lower_val = when window_interval.lower_bound.bound_type is {
//     Finite(lower_bound) -> {
//       is_entirely_after(tx_interval, lower_bound)
//     }
//     _ -> {
//       False
//     }
//   }
//   (upper_val && lower_val)?
// }

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

test test_02() {
  and {
    check_redeemer_action(0),
    check_redeemer_action(1),
    check_redeemer_action(2),
    !check_redeemer_action(333),
  }
}

test test_a03() {
  let window = entirely_between(1731171600000, 1731173400000)
  in_the_window_of_time(window, between(1731172200000, 1731172800000)) && !in_the_window_of_time(
    window,
    between(1731171400000, 1731171800000),
  )
}
