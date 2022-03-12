'reach 0.1';

const Player = {
    getHand: Fun([],UInt),
    seeOutcome: Fun([UInt],Null),
}

export const main = Reach.App(()=>{
    const Alice = Participant('Alice',{
        //specify Alice's interact interface here
        ...Player,
        wager: UInt,
    });

    const Bob = Participant('Bob',{
        //specify Bob's interact interface here
        ...Player,
        acceptWager: Fun([UInt],Null)
    });
    init();

    //writer you program here 
    Alice.only(()=> {
        const wager = declassify(interact.wager);
        const handAlice = declassify(interact.getHand());
    });
    Alice.publish(wager,handAlice)
        .pay(wager);
    commit();
    
    // add line that verifies that Bob doesn't know handAlice at this
    // point of the program
    unknowable(Bob, Alice(handAlice));
    Bob.only(() => {
        interact.acceptWager(wager);
        //honest Bob
        const handBob = declassify(interact.getHand());
        //dishonest Bon
        // const handBob = (handAlice + 1) % 3;
    });
    Bob.publish(handBob)
        .pay(wager);
    
    const outcome = (handAlice + (4 - handBob)) % 3;
    //test for dishonest Bob
    // require(handBob == (handAlice + 1) % 3);
    // assert(outcome == 0);
    const           [forAlice, forBob] =
        outcome == 2 ? [ 2, 0]:
        outcome == 0 ? [ 0, 2]:
        /*tie */       [ 1, 1];
    transfer(forAlice * wager).to(Alice);
    transfer(forBob * wager).to(Bob);
    commit();
    
    each([Alice, Bob], () => {
        interact.seeOutcome(outcome)
    })
})

