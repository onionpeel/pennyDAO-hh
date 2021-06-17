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

8. What type of uint should be used for changeMaker ids?

9. Why does ImpactNFT_Generator need to be abstract?

10. How to handle decimals/exponents in dealing with funding threshold and dai amounts?

11. what is supportsInterface?

12.  The _mint() function in ImpactNFT_Generator.sol is called within Projects:createTokens().  Can _mint() be accessed externally even though createTokens() has security checks to limit it to just the changeMaker that craeted the project?  ImpactNFT_Generator.sol is created inside of Projects.sol, so does this prevent the address of ImpactNFT_Generator.sol from being used to call _mint directly?

13.  projectSponsorIds will be a problem as more sponsors get listed because it keeps track of all sponsors in this mapping.  The sponsors need to be enumerated per project so the numbers do not grow to large.  The problem arises in the event of a refund, in which all the sponsor ids must be looped over to check if they are in the array of sponsors for a given project.

14. Is the math in Projects: withdrawNinetyEightPercent() a safe way to calculate the 98%?

15. What is the proper order of elements inside a contract?
