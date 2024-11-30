  const txCompA = user
    .newTx()
    .pay.ToAddressWithData(addr, { kind: "inline", value: Data.to(0n) }, {});
  const txCompB = user
    .newTx()
    .pay.ToAddressWithData(addr, { kind: "inline", value: Data.to(10n) }, {})
    .compose(
      user
        .newTx()
        .pay.ToAddressWithData(addr, { kind: "inline", value: Data.to(1n) }, {})
        .compose(
          user
            .newTx()
            .pay.ToAddressWithData(
              addr,
              { kind: "inline", value: Data.to(2n) },
              {},
            ),
        ),
    );
  const tx = user
    .newTx()
    .compose(txCompA)
    .compose(txCompB)
    .pay.ToAddressWithData(addr, { kind: "inline", value: Data.to(3n) }, {});