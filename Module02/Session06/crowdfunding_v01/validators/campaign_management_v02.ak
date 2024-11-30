use aiken/collection/list
use aiken/crypto.{VerificationKeyHash}
use cardano/transaction.{OutputReference, Transaction, find_input}
use cardano/assets.{PolicyId}
/// shorthand notation for custom types
/// the full version would have the explicit Data Constructor like
/// type Datum { Datum {...fields are the same...} }
pub type CFdatum {
  goal: Int,
  backer: VerificationKeyHash,
  deadline: Int,
}

/// Actions Enumerator
///  0 -> Cancel Campaign
///  1 -> Support Campaign
///  2 -> Claims

///
pub type CFredeemer = Int

///  0 -> Campaign Token
///  1 -> Backers Tokens
///  2 -> Burn Campaign Token
///  3 -> Burn Backer Token
pub type MintAction = Int

validator manage_campaign(campaign_id: Int, title: ByteArray, creator: VerificationKeyHash, appkey: VerificationKeyHash) {
  spend(
    datum: Option<CFdatum>,
    redeemer: CFredeemer,
    _utxo: OutputReference,
    transaction: Transaction,
  ) {

    expect Some(datum) = datum
    expect(must_spend_token(transaction, campaign_id))


    when redeemer is {
      0 -> 
        cancel_campaign(
          datum,
          creator,
          transaction.extra_signatories,
        )

      1 -> 
        support_campaign(
          datum,
          transaction.extra_signatories,
        )

      2 -> 
        claims(
          datum,
          creator,
          transaction.extra_signatories,
        )
      _ -> fail
    }
  }

  mint(
    redeemer: MintAction, 
    policy: PolicyId,
    tx_info: Transaction){
    when redeemer is {
      0 -> must_be_signed_by(appkey, tx_info.extra_signatories) && must_be_signed_by(creator, tx_info.extra_signatories) 
      1 -> True
      2 -> True
      3 -> True
      _ -> False
    }

  }

  else(_) {
    fail
  }
}


fn must_spend_token(tx: Transaction, utxo: OutputReference) -> Bool {
  // TODO: Implement
  // Spend the token
  // mint the campaign token
  // update the datum

  expect(Some(input)) = 
    tx.inputs
    |> transaction.find_input(utxo)



      
    

}


/// Cancellation conditions
///  Datum.creator => Authorize transaction by signing it.
///
fn cancel_campaign(
  datum: CFdatum,
  creator: VerificationKeyHash,
  signatories: List<VerificationKeyHash>,
) -> Bool {
   datum.backer == "" && must_be_signed_by(
    creator,
    signatories,
  )
}



/// Update conditions
///    Datum.campaignId == Redeemer.campaignId
///    Datum.backer => Authorize his support by signing the transaction.
///
fn support_campaign(
  datum: CFdatum,
  signatories: List<VerificationKeyHash>,
) -> Bool {
  must_be_signed_by(
    datum.backer,
    signatories,
  )
}

/// Claims conditions
///   Datum.campaignId == Redeemer.campaignId
///   Datum.current_funds >= Datum.goal
///   Datum.creator => Authorize transaction by signingn it.
///
fn claims(
  datum: CFdatum,
  creator: VerificationKeyHash,
  signatories: List<VerificationKeyHash>,
) -> Bool {
  must_be_signed_by(
    creator,
    signatories,
  )
}

fn must_be_signed_by(
  signer: VerificationKeyHash,
  signatories: List<VerificationKeyHash>,
) -> Bool {
  // The verificationKeyHash is the hash of the verification key of the signature
  list.has(signatories, signer)
}

// This contract is like swiss cheese, full of holes.