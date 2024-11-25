use cardano/address
use cardano/assets
use cardano/transaction.{
  InlineDatum, Input, NoDatum, Output, OutputReference, Transaction,
}
use validations_answers.{
  CampaignDatum, Cancelled, Finished, Running, must_consume_state_token,
  must_have_been_cancelled, must_mint_prize_tokens, must_mint_state_token,
  must_reach_goal, must_refund, must_resend_state_token, must_spend_own_utxo,
  must_update_campaign_state, state_token,
}

test must_consume_state_token_test() {
  let tx =
    Transaction {
      ..transaction.placeholder,
      inputs: [
        Input {
          output_reference: OutputReference("TxHash", 0),
          output: Output {
            address: address.from_script("PolicyId_1"),
            value: assets.from_asset_list(
              [
                Pair("", [Pair("", 2_000_000)]),
                Pair("PolicyId_1", [Pair(state_token, 1)]),
              ],
            ),
            datum: InlineDatum(
              CampaignDatum {
                name: "Campaign Name",
                goal: 9_000_000_000,
                deadline: 1928374650000,
                creator: ("PaymentKeyHash", "StakeKeyHash"),
                state: Running,
              },
            ),
            reference_script: None,
          },
        },
      ],
    }
  and {
    must_consume_state_token(tx, "PolicyId_1"),
    !must_consume_state_token(tx, "PolicyId_2"),
  }
}

test must_resend_state_token_test() {
  let target_datum =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: ("PaymentKeyHash", "StakeKeyHash"),
      state: Running,
    }
  let wrong_datum =
    CampaignDatum {
      name: "Campaign Name",
      goal: 800_000_000,
      deadline: 1828374650000,
      creator: ("PaymentKeyHash", "StakeKeyHash"),
      state: Running,
    }

  let tx =
    Transaction {
      ..transaction.placeholder,
      outputs: [
        Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list(
            [
              Pair("", [Pair("", 2_000_000)]),
              Pair("PolicyId_1", [Pair(state_token, 1)]),
            ],
          ),
          datum: InlineDatum(target_datum),
          reference_script: None,
        },
      ],
    }
  and {
    must_resend_state_token(tx, "PolicyId_1", target_datum),
    !must_resend_state_token(tx, "PolicyId_2", target_datum),
    !must_resend_state_token(tx, "PolicyId_1", wrong_datum),
  }
}

test must_mint_state_token_test_positive() {
  let creator_pkh = "VerificationKeyHash"
  let nonce = OutputReference("Nonce", 1)

  let target_datum =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: ("PaymentKeyHash", "StakeKeyHash"),
      state: Running,
    }

  let tx =
    Transaction {
      ..transaction.placeholder,
      inputs: [
        Input {
          output_reference: nonce,
          output: Output {
            address: address.from_verification_key(creator_pkh),
            value: assets.from_asset_list([Pair("", [Pair("", 30_000_000)])]),
            datum: NoDatum,
            reference_script: None,
          },
        },
      ],
      outputs: [
        Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list(
            [
              Pair("", [Pair("", 2_000_000)]),
              Pair("PolicyId_1", [Pair(state_token, 1)]),
            ],
          ),
          datum: InlineDatum(target_datum),
          reference_script: None,
        },
        Output {
          address: address.from_verification_key(creator_pkh),
          value: assets.from_asset_list([Pair("", [Pair("", 28_000_000)])]),
          datum: NoDatum,
          reference_script: None,
        },
      ],
      extra_signatories: [creator_pkh],
    }

  must_mint_state_token(tx, creator_pkh, nonce, "PolicyId_1", target_datum)
}

test must_mint_state_token_test_negative_1() fail {
  let creator_pkh = "VerificationKeyHash"
  let invalid_pkh = "InvalidKeyHash"

  let nonce = OutputReference("Nonce", 1)

  let target_datum =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: ("PaymentKeyHash", "StakeKeyHash"),
      state: Running,
    }

  let tx =
    Transaction {
      ..transaction.placeholder,
      inputs: [
        Input {
          output_reference: nonce,
          output: Output {
            address: address.from_verification_key(creator_pkh),
            value: assets.from_asset_list([Pair("", [Pair("", 30_000_000)])]),
            datum: NoDatum,
            reference_script: None,
          },
        },
      ],
      outputs: [
        Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list(
            [
              Pair("", [Pair("", 2_000_000)]),
              Pair("PolicyId_1", [Pair(state_token, 1)]),
            ],
          ),
          datum: InlineDatum(target_datum),
          reference_script: None,
        },
        Output {
          address: address.from_verification_key(creator_pkh),
          value: assets.from_asset_list([Pair("", [Pair("", 28_000_000)])]),
          datum: NoDatum,
          reference_script: None,
        },
      ],
      extra_signatories: [creator_pkh],
    }

  must_mint_state_token(tx, invalid_pkh, nonce, "PolicyId_1", target_datum)
}

test must_mint_state_token_test_negative_2() fail {
  let creator_pkh = "VerificationKeyHash"

  let nonce = OutputReference("Nonce", 1)
  let wrong = OutputReference("Wrong", 2)

  let target_datum =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: ("PaymentKeyHash", "StakeKeyHash"),
      state: Running,
    }

  let tx =
    Transaction {
      ..transaction.placeholder,
      inputs: [
        Input {
          output_reference: nonce,
          output: Output {
            address: address.from_verification_key(creator_pkh),
            value: assets.from_asset_list([Pair("", [Pair("", 30_000_000)])]),
            datum: NoDatum,
            reference_script: None,
          },
        },
      ],
      outputs: [
        Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list(
            [
              Pair("", [Pair("", 2_000_000)]),
              Pair("PolicyId_1", [Pair(state_token, 1)]),
            ],
          ),
          datum: InlineDatum(target_datum),
          reference_script: None,
        },
        Output {
          address: address.from_verification_key(creator_pkh),
          value: assets.from_asset_list([Pair("", [Pair("", 28_000_000)])]),
          datum: NoDatum,
          reference_script: None,
        },
      ],
      extra_signatories: [creator_pkh],
    }

  must_mint_state_token(tx, creator_pkh, wrong, "PolicyId_1", target_datum)
}

test must_mint_state_token_test_negative_3() fail {
  let creator_pkh = "VerificationKeyHash"
  let nonce = OutputReference("Nonce", 1)

  let target_datum =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: ("PaymentKeyHash", "StakeKeyHash"),
      state: Running,
    }

  let tx =
    Transaction {
      ..transaction.placeholder,
      inputs: [
        Input {
          output_reference: nonce,
          output: Output {
            address: address.from_verification_key(creator_pkh),
            value: assets.from_asset_list([Pair("", [Pair("", 30_000_000)])]),
            datum: NoDatum,
            reference_script: None,
          },
        },
      ],
      outputs: [
        Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list(
            [
              Pair("", [Pair("", 2_000_000)]),
              Pair("PolicyId_1", [Pair(state_token, 1)]),
            ],
          ),
          datum: InlineDatum(target_datum),
          reference_script: None,
        },
        Output {
          address: address.from_verification_key(creator_pkh),
          value: assets.from_asset_list([Pair("", [Pair("", 28_000_000)])]),
          datum: NoDatum,
          reference_script: None,
        },
      ],
      extra_signatories: [creator_pkh],
    }

  must_mint_state_token(tx, creator_pkh, nonce, "PolicyId_2", target_datum)
}

test must_mint_state_token_test_negative_4() fail {
  let creator_pkh = "VerificationKeyHash"
  let nonce = OutputReference("Nonce", 1)

  let target_datum =
    CampaignDatum {
      name: "Campaign Name",
      goal: 9_000_000_000,
      deadline: 1928374650000,
      creator: ("PaymentKeyHash", "StakeKeyHash"),
      state: Running,
    }
  let wrong_datum =
    CampaignDatum {
      name: "Campaign Name",
      goal: 800_000_000,
      deadline: 1828374650000,
      creator: ("PaymentKeyHash", "StakeKeyHash"),
      state: Running,
    }

  let tx =
    Transaction {
      ..transaction.placeholder,
      inputs: [
        Input {
          output_reference: nonce,
          output: Output {
            address: address.from_verification_key(creator_pkh),
            value: assets.from_asset_list([Pair("", [Pair("", 30_000_000)])]),
            datum: NoDatum,
            reference_script: None,
          },
        },
      ],
      outputs: [
        Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list(
            [
              Pair("", [Pair("", 2_000_000)]),
              Pair("PolicyId_1", [Pair(state_token, 1)]),
            ],
          ),
          datum: InlineDatum(target_datum),
          reference_script: None,
        },
        Output {
          address: address.from_verification_key(creator_pkh),
          value: assets.from_asset_list([Pair("", [Pair("", 28_000_000)])]),
          datum: NoDatum,
          reference_script: None,
        },
      ],
      extra_signatories: [creator_pkh],
    }

  must_mint_state_token(tx, creator_pkh, nonce, "PolicyId_1", wrong_datum)
}

test must_mint_prize_tokens_test_positive() {
  let backer_inputs =
    [
      Input {
        output_reference: OutputReference("TxHash_1", 1),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 30_000_000)])]),
          datum: InlineDatum(("Backer1", "")),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference("TxHash_2", 2),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 40_000_000)])]),
          datum: InlineDatum(("Backer2", "")),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference("TxHash_3", 3),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 50_000_000)])]),
          datum: InlineDatum(("Backer3", "")),
          reference_script: None,
        },
      },
    ]
  let backer_outputs =
    [
      Output {
        address: address.from_verification_key("Backer1"),
        value: assets.from_asset_list(
          [Pair("PolicyId_1", [Pair("Backer1", 1)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
      Output {
        address: address.from_verification_key("Backer2"),
        value: assets.from_asset_list(
          [Pair("PolicyId_1", [Pair("Backer2", 1)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
      Output {
        address: address.from_verification_key("Backer3"),
        value: assets.from_asset_list(
          [Pair("PolicyId_1", [Pair("Backer3", 1)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
    ]

  let tx =
    Transaction {
      ..transaction.placeholder,
      inputs: backer_inputs,
      outputs: backer_outputs,
    }

  must_mint_prize_tokens(tx, backer_inputs, "PolicyId_1")
}

test must_mint_prize_tokens_test_negative_1() fail {
  let backer_inputs =
    [
      Input {
        output_reference: OutputReference("TxHash_1", 1),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 30_000_000)])]),
          datum: InlineDatum(("Backer1", "")),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference("TxHash_2", 2),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 40_000_000)])]),
          datum: InlineDatum(("Backer2", "")),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference("TxHash_3", 3),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 50_000_000)])]),
          datum: InlineDatum(("Backer3", "")),
          reference_script: None,
        },
      },
    ]
  let wrong_inputs =
    [
      Input {
        output_reference: OutputReference("TxHash_1", 1),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 30_000_000)])]),
          datum: InlineDatum(("Backer1", "")),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference("TxHash_2", 2),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 40_000_000)])]),
          datum: InlineDatum(("Backer2", "")),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference("TxHash_3", 3),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 50_000_000)])]),
          datum: InlineDatum(("Backer3", "")),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference("TxHash_4", 4),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 60_000_000)])]),
          datum: InlineDatum(("Backer4", "")),
          reference_script: None,
        },
      },
    ]
  let backer_outputs =
    [
      Output {
        address: address.from_verification_key("Backer1"),
        value: assets.from_asset_list(
          [Pair("PolicyId_1", [Pair("Backer1", 1)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
      Output {
        address: address.from_verification_key("Backer2"),
        value: assets.from_asset_list(
          [Pair("PolicyId_1", [Pair("Backer2", 1)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
      Output {
        address: address.from_verification_key("Backer3"),
        value: assets.from_asset_list(
          [Pair("PolicyId_1", [Pair("Backer3", 1)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
    ]

  let tx =
    Transaction {
      ..transaction.placeholder,
      inputs: backer_inputs,
      outputs: backer_outputs,
    }

  must_mint_prize_tokens(tx, wrong_inputs, "PolicyId_1")
}

test must_mint_prize_tokens_test_negative_2() fail {
  let backer_inputs =
    [
      Input {
        output_reference: OutputReference("TxHash_1", 1),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 30_000_000)])]),
          datum: InlineDatum(("Backer1", "")),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference("TxHash_2", 2),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 40_000_000)])]),
          datum: InlineDatum(("Backer2", "")),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference("TxHash_3", 3),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 50_000_000)])]),
          datum: InlineDatum(("Backer3", "")),
          reference_script: None,
        },
      },
    ]
  let backer_outputs =
    [
      Output {
        address: address.from_verification_key("Backer1"),
        value: assets.from_asset_list(
          [Pair("PolicyId_1", [Pair("Backer1", 1)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
      Output {
        address: address.from_verification_key("Backer2"),
        value: assets.from_asset_list(
          [Pair("PolicyId_1", [Pair("Backer2", 1)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
      Output {
        address: address.from_verification_key("Backer3"),
        value: assets.from_asset_list(
          [Pair("PolicyId_1", [Pair("Backer3", 1)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
    ]

  let tx =
    Transaction {
      ..transaction.placeholder,
      inputs: backer_inputs,
      outputs: backer_outputs,
    }

  must_mint_prize_tokens(tx, backer_inputs, "PolicyId_2")
}

test must_reach_goal_test() {
  let backer_inputs =
    [
      Input {
        output_reference: OutputReference("TxHash_1", 1),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 30_000_000)])]),
          datum: InlineDatum(("Backer1", "")),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference("TxHash_2", 2),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 40_000_000)])]),
          datum: InlineDatum(("Backer2", "")),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference("TxHash_3", 3),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 50_000_000)])]),
          datum: InlineDatum(("Backer3", "")),
          reference_script: None,
        },
      },
    ]

  and {
    must_reach_goal(backer_inputs, 120_000_000),
    !must_reach_goal(backer_inputs, 9_000_000_000),
  }
}

test must_update_campaign_state_test_cancelled() {
  let tx =
    Transaction {
      ..transaction.placeholder,
      inputs: [
        Input {
          output_reference: OutputReference("TxHash", 0),
          output: Output {
            address: address.from_script("PolicyId_1"),
            value: assets.from_asset_list(
              [
                Pair("", [Pair("", 2_000_000)]),
                Pair("PolicyId_1", [Pair(state_token, 1)]),
              ],
            ),
            datum: InlineDatum(
              CampaignDatum {
                name: "Campaign Name",
                goal: 9_000_000_000,
                deadline: 1928374650000,
                creator: ("PaymentKeyHash", "StakeKeyHash"),
                state: Running,
              },
            ),
            reference_script: None,
          },
        },
      ],
      outputs: [
        Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list(
            [
              Pair("", [Pair("", 2_000_000)]),
              Pair("PolicyId_1", [Pair(state_token, 1)]),
            ],
          ),
          datum: InlineDatum(
            CampaignDatum {
              name: "Campaign Name",
              goal: 9_000_000_000,
              deadline: 1928374650000,
              creator: ("PaymentKeyHash", "StakeKeyHash"),
              state: Cancelled,
            },
          ),
          reference_script: None,
        },
      ],
    }

  must_update_campaign_state(tx, "PolicyId_1", Cancelled)
}

test must_update_campaign_state_test_finished() {
  let backer_inputs =
    [
      Input {
        output_reference: OutputReference("TxHash_1", 1),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 3_000_000_000)])]),
          datum: InlineDatum(("Backer1", "")),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference("TxHash_2", 2),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 3_000_000_000)])]),
          datum: InlineDatum(("Backer2", "")),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference("TxHash_3", 3),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 3_000_000_000)])]),
          datum: InlineDatum(("Backer3", "")),
          reference_script: None,
        },
      },
    ]
  let backer_outputs =
    [
      Output {
        address: address.from_verification_key("Backer1"),
        value: assets.from_asset_list(
          [Pair("PolicyId_1", [Pair("Backer1", 1)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
      Output {
        address: address.from_verification_key("Backer2"),
        value: assets.from_asset_list(
          [Pair("PolicyId_1", [Pair("Backer2", 1)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
      Output {
        address: address.from_verification_key("Backer3"),
        value: assets.from_asset_list(
          [Pair("PolicyId_1", [Pair("Backer3", 1)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
    ]

  let tx =
    Transaction {
      ..transaction.placeholder,
      inputs: [
        Input {
          output_reference: OutputReference("TxHash", 0),
          output: Output {
            address: address.from_script("PolicyId_1"),
            value: assets.from_asset_list(
              [
                Pair("", [Pair("", 2_000_000)]),
                Pair("PolicyId_1", [Pair(state_token, 1)]),
              ],
            ),
            datum: InlineDatum(
              CampaignDatum {
                name: "Campaign Name",
                goal: 9_000_000_000,
                deadline: 1928374650000,
                creator: ("PaymentKeyHash", "StakeKeyHash"),
                state: Running,
              },
            ),
            reference_script: None,
          },
        },
        ..backer_inputs
      ],
      outputs: [
        Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list(
            [
              Pair("", [Pair("", 2_000_000)]),
              Pair("PolicyId_1", [Pair(state_token, 1)]),
            ],
          ),
          datum: InlineDatum(
            CampaignDatum {
              name: "Campaign Name",
              goal: 9_000_000_000,
              deadline: 1928374650000,
              creator: ("PaymentKeyHash", "StakeKeyHash"),
              state: Finished,
            },
          ),
          reference_script: None,
        },
        ..backer_outputs
      ],
    }

  must_update_campaign_state(tx, "PolicyId_1", Finished)
}

test must_update_campaign_state_test_cancelled_negative() fail {
  let tx =
    Transaction {
      ..transaction.placeholder,
      inputs: [
        Input {
          output_reference: OutputReference("TxHash", 0),
          output: Output {
            address: address.from_script("PolicyId_1"),
            value: assets.from_asset_list(
              [
                Pair("", [Pair("", 2_000_000)]),
                Pair("PolicyId_1", [Pair(state_token, 1)]),
              ],
            ),
            datum: InlineDatum(
              CampaignDatum {
                name: "Campaign Name",
                goal: 9_000_000_000,
                deadline: 1928374650000,
                creator: ("PaymentKeyHash", "StakeKeyHash"),
                state: Running,
              },
            ),
            reference_script: None,
          },
        },
      ],
      outputs: [
        Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list(
            [
              Pair("", [Pair("", 2_000_000)]),
              Pair("PolicyId_1", [Pair(state_token, 1)]),
            ],
          ),
          datum: InlineDatum(
            CampaignDatum {
              name: "Campaign Name",
              goal: 9_000_000_000,
              deadline: 1928374650000,
              creator: ("PaymentKeyHash", "StakeKeyHash"),
              state: Cancelled,
            },
          ),
          reference_script: None,
        },
      ],
    }

  must_update_campaign_state(tx, "PolicyId_2", Cancelled)
}

test must_update_campaign_state_test_finished_negative() fail {
  let backer_inputs =
    [
      Input {
        output_reference: OutputReference("TxHash_1", 1),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 3_000_000_000)])]),
          datum: InlineDatum(("Backer1", "")),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference("TxHash_2", 2),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 3_000_000_000)])]),
          datum: InlineDatum(("Backer2", "")),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference("TxHash_3", 3),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 3_000_000_000)])]),
          datum: InlineDatum(("Backer3", "")),
          reference_script: None,
        },
      },
    ]
  let backer_outputs =
    [
      Output {
        address: address.from_verification_key("Backer1"),
        value: assets.from_asset_list(
          [Pair("PolicyId_1", [Pair("Backer1", 1)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
      Output {
        address: address.from_verification_key("Backer2"),
        value: assets.from_asset_list(
          [Pair("PolicyId_1", [Pair("Backer2", 1)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
      Output {
        address: address.from_verification_key("Backer3"),
        value: assets.from_asset_list(
          [Pair("PolicyId_1", [Pair("Backer3", 1)])],
        ),
        datum: NoDatum,
        reference_script: None,
      },
    ]

  let tx =
    Transaction {
      ..transaction.placeholder,
      inputs: [
        Input {
          output_reference: OutputReference("TxHash", 0),
          output: Output {
            address: address.from_script("PolicyId_1"),
            value: assets.from_asset_list(
              [
                Pair("", [Pair("", 2_000_000)]),
                Pair("PolicyId_1", [Pair(state_token, 1)]),
              ],
            ),
            datum: InlineDatum(
              CampaignDatum {
                name: "Campaign Name",
                goal: 9_000_000_000,
                deadline: 1928374650000,
                creator: ("PaymentKeyHash", "StakeKeyHash"),
                state: Running,
              },
            ),
            reference_script: None,
          },
        },
        ..backer_inputs
      ],
      outputs: [
        Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list(
            [
              Pair("", [Pair("", 2_000_000)]),
              Pair("PolicyId_1", [Pair(state_token, 1)]),
            ],
          ),
          datum: InlineDatum(
            CampaignDatum {
              name: "Campaign Name",
              goal: 9_000_000_000,
              deadline: 1928374650000,
              creator: ("PaymentKeyHash", "StakeKeyHash"),
              state: Finished,
            },
          ),
          reference_script: None,
        },
        ..backer_outputs
      ],
    }

  must_update_campaign_state(tx, "PolicyId_2", Finished)
}

test must_spend_own_utxo_test() {
  let backer_inputs =
    [
      Input {
        output_reference: OutputReference("TxHash_1", 1),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 3_000_000_000)])]),
          datum: InlineDatum(("Backer1", "")),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference("TxHash_2", 2),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 3_000_000_000)])]),
          datum: InlineDatum(("Backer2", "")),
          reference_script: None,
        },
      },
      Input {
        output_reference: OutputReference("TxHash_3", 3),
        output: Output {
          address: address.from_script("PolicyId_1"),
          value: assets.from_asset_list([Pair("", [Pair("", 3_000_000_000)])]),
          datum: InlineDatum(("Backer3", "")),
          reference_script: None,
        },
      },
    ]
  let tx =
    Transaction {
      ..transaction.placeholder,
      inputs: backer_inputs,
      extra_signatories: ["Backer1"],
    }
  and {
    must_spend_own_utxo(tx, OutputReference("TxHash_1", 1)),
    !must_spend_own_utxo(tx, OutputReference("TxHash_2", 2)),
  }
}

test must_have_been_cancelled_test_positive() {
  let tx =
    Transaction {
      ..transaction.placeholder,
      reference_inputs: [
        Input {
          output_reference: OutputReference("TxHash", 0),
          output: Output {
            address: address.from_script("PolicyId_1"),
            value: assets.from_asset_list(
              [
                Pair("", [Pair("", 2_000_000)]),
                Pair("PolicyId_1", [Pair(state_token, 1)]),
              ],
            ),
            datum: InlineDatum(
              CampaignDatum {
                name: "Campaign Name",
                goal: 9_000_000_000,
                deadline: 1928374650000,
                creator: ("PaymentKeyHash", "StakeKeyHash"),
                state: Cancelled,
              },
            ),
            reference_script: None,
          },
        },
      ],
    }
  must_have_been_cancelled(tx, "PolicyId_1")
}

test must_have_been_cancelled_test_negative() fail {
  let tx =
    Transaction {
      ..transaction.placeholder,
      reference_inputs: [
        Input {
          output_reference: OutputReference("TxHash", 0),
          output: Output {
            address: address.from_script("PolicyId_1"),
            value: assets.from_asset_list(
              [
                Pair("", [Pair("", 2_000_000)]),
                Pair("PolicyId_1", [Pair(state_token, 1)]),
              ],
            ),
            datum: InlineDatum(
              CampaignDatum {
                name: "Campaign Name",
                goal: 9_000_000_000,
                deadline: 1928374650000,
                creator: ("PaymentKeyHash", "StakeKeyHash"),
                state: Cancelled,
              },
            ),
            reference_script: None,
          },
        },
      ],
    }
  must_have_been_cancelled(tx, "PolicyId_2")
}

test must_refund_test_positive() {
  let tx =
    Transaction {
      ..transaction.placeholder,
      reference_inputs: [
        Input {
          output_reference: OutputReference("TxHash", 0),
          output: Output {
            address: address.from_script("PolicyId_1"),
            value: assets.from_asset_list(
              [
                Pair("", [Pair("", 2_000_000)]),
                Pair("PolicyId_1", [Pair(state_token, 1)]),
              ],
            ),
            datum: InlineDatum(
              CampaignDatum {
                name: "Campaign Name",
                goal: 9_000_000_000,
                deadline: 1928374650000,
                creator: ("PaymentKeyHash", "StakeKeyHash"),
                state: Cancelled,
              },
            ),
            reference_script: None,
          },
        },
      ],
      inputs: [
        Input {
          output_reference: OutputReference("TxHash_1", 1),
          output: Output {
            address: address.from_script("PolicyId_1"),
            value: assets.from_asset_list([Pair("", [Pair("", 3_000_000_000)])]),
            datum: InlineDatum(("Backer1", "")),
            reference_script: None,
          },
        },
      ],
      outputs: [
        Output {
          address: address.from_verification_key("Backer1"),
          value: assets.from_asset_list([Pair("", [Pair("", 3_000_000_000)])]),
          datum: NoDatum,
          reference_script: None,
        },
      ],
      extra_signatories: ["Backer1"],
    }
  must_refund(tx, "PolicyId_1", OutputReference("TxHash_1", 1))
}

test must_refund_test_negative_1() fail {
  let tx =
    Transaction {
      ..transaction.placeholder,
      reference_inputs: [
        Input {
          output_reference: OutputReference("TxHash", 0),
          output: Output {
            address: address.from_script("PolicyId_1"),
            value: assets.from_asset_list(
              [
                Pair("", [Pair("", 2_000_000)]),
                Pair("PolicyId_1", [Pair(state_token, 1)]),
              ],
            ),
            datum: InlineDatum(
              CampaignDatum {
                name: "Campaign Name",
                goal: 9_000_000_000,
                deadline: 1928374650000,
                creator: ("PaymentKeyHash", "StakeKeyHash"),
                state: Cancelled,
              },
            ),
            reference_script: None,
          },
        },
      ],
      inputs: [
        Input {
          output_reference: OutputReference("TxHash_1", 1),
          output: Output {
            address: address.from_script("PolicyId_1"),
            value: assets.from_asset_list([Pair("", [Pair("", 3_000_000_000)])]),
            datum: InlineDatum(("Backer1", "")),
            reference_script: None,
          },
        },
      ],
      outputs: [
        Output {
          address: address.from_verification_key("Backer1"),
          value: assets.from_asset_list([Pair("", [Pair("", 3_000_000_000)])]),
          datum: NoDatum,
          reference_script: None,
        },
      ],
      extra_signatories: ["Backer1"],
    }
  must_refund(tx, "PolicyId_2", OutputReference("TxHash_1", 1))
}

test must_refund_test_negative_2() fail {
  let tx =
    Transaction {
      ..transaction.placeholder,
      reference_inputs: [
        Input {
          output_reference: OutputReference("TxHash", 0),
          output: Output {
            address: address.from_script("PolicyId_1"),
            value: assets.from_asset_list(
              [
                Pair("", [Pair("", 2_000_000)]),
                Pair("PolicyId_1", [Pair(state_token, 1)]),
              ],
            ),
            datum: InlineDatum(
              CampaignDatum {
                name: "Campaign Name",
                goal: 9_000_000_000,
                deadline: 1928374650000,
                creator: ("PaymentKeyHash", "StakeKeyHash"),
                state: Cancelled,
              },
            ),
            reference_script: None,
          },
        },
      ],
      inputs: [
        Input {
          output_reference: OutputReference("TxHash_1", 1),
          output: Output {
            address: address.from_script("PolicyId_1"),
            value: assets.from_asset_list([Pair("", [Pair("", 3_000_000_000)])]),
            datum: InlineDatum(("Backer1", "")),
            reference_script: None,
          },
        },
      ],
      outputs: [
        Output {
          address: address.from_verification_key("Backer1"),
          value: assets.from_asset_list([Pair("", [Pair("", 3_000_000_000)])]),
          datum: NoDatum,
          reference_script: None,
        },
      ],
      extra_signatories: ["Backer1"],
    }
  must_refund(tx, "PolicyId_1", OutputReference("TxHash_2", 2))
}
