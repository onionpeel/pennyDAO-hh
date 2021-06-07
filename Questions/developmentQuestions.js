1. Should Ownable or AccessControl be used?
https://docs.openzeppelin.com/contracts/4.x/api/access

2. What is the proper natspec format for documenting?

3. What event items should be indexed?

4. Should public functions in ChangeMakers.sol be changed to external?

// 5. How to handle IMPACT minting
//   a) initial amount?
//   b) mint as sponsors deposit?
//   c) burn as sponsors withdraw?

6. Should there be a function in ImpactToken, so that ChangeDao can mint IMPACT tokens and distribute those so that the recipient can they pick a project and use those tokens.
  Use case:  The community could vote to allocate funds from the community fund to a project directly.  Or instead of this, the community could vote to allocate IMPACT to groups/individuals and let them use those tokens as a way to choose which projects receive the community fund money.

7. How to handle the keys of the ChangeDaoTeam and CommunityFund so that if that address needs to change, it can.


ChangeMaker.sol
1. What type of uint should be used for changeMaker ids?
